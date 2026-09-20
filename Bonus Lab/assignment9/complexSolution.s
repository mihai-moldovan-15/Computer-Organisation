.data
hashTable:
    .skip 2048 * 257                 # 2048 branches, each holding a historyPattern in the first byte and a pattern history table in the next 256

magicConstant:
    .quad 11400714819323198485

///these two are taken from https://github.com/aappleby/smhasher/blob/master/src/MurmurHash3.cpp
largeOddNumber1:
    .quad 0xff51afd7ed558ccd

largeOddNumber2:
    .quad 0xc4ceb9fe1a85ec53

tableSize:
    .quad 2048

branchSize:
    .quad 257

.text
.global predict_branch
.global actual_branch
.global init

/*
    gdb ./out
    b 79 (breakpoint on line 79)
    r (for run)
    c (for continue)
    s (for step)
    p $rdi (i think this prints a string)
    x/x $rdi (prints 4 bytes starting at address in rdi)
    x/100x $rdi (same but 100 bytes)
    x/100x &hashTable (same but address of section)


    Page manual 11 - cheat sheet
*/

/*
	Approach: Local 2-bit (saturating) counter (for each branch)

    00                     01                  10                11
strongly not taken   weakly not taken     weakly taken     strongly taken
*/

/*
    Hash function with the golden ratio - Fibonacci hashing (ska hashmap uses this)
    https://probablydance.com/2018/06/16/fibonacci-hashing-the-optimization-that-the-world-forgot-or-a-better-alternative-to-integer-modulo/

    Idee: 
    Hash = (Memory address of the branch) * 11400714819323198485 >> 53
    
    de ce 11400714819323198485? 2^64 / goldenRatio
    de ce >> 53 ? pentru ca avem nevoie de distributia pe 11 biti (11 + 53 = 64)
*/

# actually a worse hash than just MOD
# might update later


///     history for a branch given a HASH:          hashTable + HASH * 257
///     accessing a specific counter given a HASH:  hashtable + HASH * 257 + historyPattern + 1



# most significant bits may stay 0 after the right shift, so we apply the finalizer from MurmurHash3 hashing technique
    /*
        C ++ code
        size_t h = address;
        h ^= h >> 33;
        h *= 0xff51afd7ed558ccd; (large odd number)
        h ^= h >> 33;
        h *= 0xc4ceb9fe1a85ec53; (...)
        h ^= h >> 33;

       return (h * 11400714819323198485ULL) >> 53; /// The Fibonacci thing - maps out a big value on a small interval
       /// the big constants are taken from the original repo: https://github.com/aappleby/smhasher/blob/master/src/MurmurHash3.cpp
    */
    
getHash:                                       # %rdi has the number we want to hash
    # prologue
	pushq	%rbp
	movq	%rsp, %rbp

    movq    %rdi, %rax

    movq    %rax, %rdx 
    shr     $33, %rdx
    xorq    %rdx, %rax

    mulq    largeOddNumber1;

    movq    %rax, %rdx 
    shr     $33, %rdx
    xorq    %rdx, %rax

    mulq    largeOddNumber2;

    movq    %rax, %rdx 
    shr     $33, %rdx
    xorq    %rdx, %rax

  
    mulq    magicConstant
      
    shr $53, %rax                       # %rax - hash of %rdi
   
    # epilogue
    movq %rbp, %rsp
    popq %rbp
    ret

    

# TODO: update correctly the history pattern
init:                                               # place the counter in a weak state (weakly not taken) - 01
    # prologue
	pushq	%rbp
	movq	%rsp, %rbp

    movq    tableSize, %rax
    leaq    hashTable, %rdx                         # %rdx has the current address from which we calculate the offset
    outerLoop:
        cmpq    $0, %rax
        je      endOuterLoop

        movq    branchSize, %rcx
        innerLoop:
            cmpq    $0, %rcx
            je      endInnerLoop

            movb    $0x01, (%rdx, %rcx, 1)           # place 01 in hashTable
            subq    $1, %rcx
            jmp innerLoop
        endInnerLoop:
        subq    $1, %rax
        addq    $257, %rdx
        jmp     outerLoop
    endOuterLoop:

    # epilogue 
	movq	%rbp, %rsp
	popq	%rbp
	ret


///     history for a branch given a HASH:          hashTable + HASH * 257
///     accessing a specific counter given a HASH:  hashtable + HASH * 257 + historyPattern + 1
predict_branch:                         # %rdi - the address of the branch
	# prologue
    pushq	%rbp
	movq	%rsp, %rbp

    call getHash   
    
                                                                # %rax is the HASH     
    movq    $257, %rcx
    mulq    %rcx

    movq    $0, %rdi
    movb    hashTable(, %rax, 1), %dil

    ///%dil - historyPattern
    addq    %rdi, %rax
    incq    %rax

    movb    hashTable(, %rax , 1), %dl        # (rdx) dl is the value of the specific counter
    cmpb    $1, %dl

    jle  skipBranch
    movq $1, %rax
    jmp endPredict

skipBranch:
    movq $0, %rax

endPredict:
    # epilogue
	movq	%rbp, %rsp
	popq	%rbp
	ret

actual_branch:
    # prologue
	pushq	%rbp
	movq	%rsp, %rbp

    call getHash                        

    movq    $257, %rcx
    mulq    %rcx
    movq    %rax, %r9                                                           # %rax is the HASH, %r9 is the initial value, needed in the epilogue

    leaq    hashTable(, %rax, 1), %rdi                                          # %rdi - adresa history patternului
    

    # scoatem cel mai semnificativ bit din history
    movq    $0, %r8
    movb    (%rdi), %r8b
    shl     $1, %r8b
    cmpq    $0, %rsi
    je      branchNotTaken
    incb    %r8b                                                     # daca am decis sa luam un branch modificam history patternul
    branchNotTaken:

    # aici stim ca %r8 este history patterul corect, putem sa aflam rdx
    addq    %r8, %rax
    incq    %rax
    
    leaq    hashTable(, %rax , 1), %rdx                             # (rdx) address of the specific counter

    cmpq $0, %rsi
    je  skipped

    //if was not skipped
    cmpb $3, (%rdx)
    je  endUpdate
    addb $1, (%rdx)                                                 # marim contorul daca se poate
    jmp endUpdate

    skipped:
    cmpb $0, (%rdx)
    je  endUpdate
    subb $1, (%rdx)
                                                                # %r9 - calculate displacement for historyPattern
                                                                # %rax - displacement for specific counter
endUpdate:
    movq $0, %rcx
    movb (%rdx), %cl                                            # update la contor
    movb %cl, hashTable(, %rax, 1)

    movb %r8b, hashTable(, %r9, 1)                              # update la historyPattern
    
    # epilogue
	movq	%rbp, %rsp
	popq	%rbp
	ret
