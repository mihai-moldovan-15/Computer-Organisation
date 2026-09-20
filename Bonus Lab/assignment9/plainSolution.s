.data
hashTable:
    .skip 2048                      # one byte / element, initialy 0

magicConstant:
    .quad 11400714819323198485

tableSize:
    .quad 2048

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

init:                                           # place the counter in a weak state (weakly not taken) - 01
    # prologue
	pushq	%rbp
	movq	%rsp, %rbp

    pushq   %rax
    pushq   %rdi

    movq    tableSize, %rax
    loop:
        cmpq $0, %rax
        je endLoop

        movb $0x01, hashTable(, %rax, 1)        # place 01 in hashTable + %rax
        subq $1, %rax
        
        jmp loop
    endLoop:

    popq    %rdi
    popq    %rax   

    # epilogue 
	movq	%rbp, %rsp
	popq	%rbp
	ret

predict_branch:                         # %rdi - the address of the branch
	# prologue
    pushq	%rbp
	movq	%rsp, %rbp

    pushq   %rcx                        

    # hashing logic
    movq $0, %rdx
    movq %rdi, %rax
    movq $2048, %r10
    divq %r10
#--------------------------

    #movq %rdi, %rax    
    #mulq magicConstant

    #movq %rdx, %rcx                     # %rdx has the upper bits, those are the one relevant                     
    #shr $53, %rcx                       # %rcx - hash of %rdi
#-----------------------------
    movq %rdx, %rcx
    movq $0, %rdi
    movb hashTable(, %rcx, 1), %dil


    cmpb    $1, %dil

    jle  skipBranch
    movq $1, %rax
    jmp endPredict

skipBranch:
    movq $0, %rax

endPredict:
    popq    %rcx
    # epilogue
	movq	%rbp, %rsp
	popq	%rbp
	ret

actual_branch:
    # prologue
	pushq	%rbp
	movq	%rsp, %rbp

    pushq   %rcx                        # %rcx - hash of %rdi
    
    # movq %rdi, %rax
    #mulq magicConstant
    #movq %rdx, %rcx
    #shr $53, %rcx
    movq $0, %rdx
    movq %rdi, %rax
    movq $2048, %r10
    divq %r10
    movq %rdx, %rcx
    
    leaq hashTable(, %rcx, 1), %rdi

    cmpq $0, %rsi
    je  skipped

    //if was not skipped
    cmpb $3, (%rdi)
    je  endUpdate
    addb $1, (%rdi)
    jmp endUpdate

    skipped:
    cmpb $0, (%rdi)
    je  endUpdate
    subb $1, (%rdi)
    
endUpdate:
    movb (%rdi), %al
    movb %al, hashTable(, %rcx, 1)
    popq    %rcx
    # epilogue
	movq	%rbp, %rsp
	popq	%rbp
	ret
