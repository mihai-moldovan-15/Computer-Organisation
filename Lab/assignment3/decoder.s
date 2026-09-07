.text

output: .asciz "%c"

.include "helloWorld.s"

.global main

# ************************************************************
# Subroutine: decode                                         *
# Description: decodes message as defined in Assignment 3    *
#   - 2 byte unknown                                         *
#   - 4 byte index                                           *
#   - 1 byte amount                                          *
#   - 1 byte character                                       *
# Parameters:                                                *
#   first: the address of the message to read                *
#   return: no return value                                  *
# ************************************************************
decode:
	# prologue
	pushq	%rbp 			# push the base pointer (and align the stack)
	movq	%rsp, %rbp		# copy stack pointer value to base pointer


    #rcx - value adress (0X00020000000A0148)
    #rdx - adress of the pointer to the first message
    #r12 - initially equal with #rdx, we modify it in the outerLoop, #rdx should be constant
    #r8 - the counter
    #r9 - the character we output
    #r11 - next adress (the offsetul) - multiplied by 8?
    
    #r8, 9, 11 - we operate on the bits of rcx

    movq (%rdi), %rcx
    movq %rdi, %rdx
    movq %rdx, %r12

    # at the adress of  %rdx we have %rcx, %rcx is something like 0X00020000000A0148
    #do while
    outerLoop:
        # prelucram ce e la %rdx - bits of rcx
        # the counter
        movq $0, %r9
        movq %rcx, %r14
        shr $6, %r14
        movb %r14b, %r9b

        # the char
        movq $0, %r8
        movq %rcx, %r14
        shr $7, %r14
        movb %r14b, %r8b

        innerLoop:
            cmpq $0, %r9
            je endInnerLoop

            subq $1, %r9
            movq $0, %rax
  
            movq $output, %rdi  # param1: format string
            movq %r8, %rsi      # param2: the char

            call printf
            jmp innerLoop

        endInnerLoop:
    
        # modificam r10 ...

        # %r11 - offsetul
        mov $0, %r11
        movq %rcx, %r14
        shr $2, %r14
        movl %r14d, %r11d
      
        cmpq $0, %r11
        je endOuterLoop

        ///trebuie sa actualizam rcx
        leaq (%rdx, %r11, 8), %r12 
        movq (%r12), %rcx
        jmp outerLoop

    endOuterLoop:
    # epilogue
	movq	%rbp, %rsp		# clear local variables from stack
	popq	%rbp			# restore base pointer location 
	ret

main:
	pushq	%rbp 			# push the base pointer (and align the stack)
	movq	%rsp, %rbp		# copy stack pointer value to base pointer

	movq	$MESSAGE, %rdi	# first parameter: address of the message
	call	decode			# call decode


	popq	%rbp			# restore base pointer location 
	movq	$0, %rdi		# load program exit code
	call	exit			# exit the program

