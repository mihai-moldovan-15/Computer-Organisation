.text
output: .asciz "%c"

.include "final.s"

.global main

decode:
	# prologue
    pushq	%rbp 			                
	movq	%rsp, %rbp		                

    pushq   %rbx                            # saves the callee-saved register on the stack
    pushq   %r12                            # saves the callee-saved register on the stack

                                            # rdx - adress of the pointer to the first message
                                            # rcx = *rdx; rcx - value adress (0X00020000000A0148)
                                            # r12 - initially equal with %rdx, we modify it in the outerLoop, %rdx should be constant (used as a base adress for the offset)
                                            # r8 - the character we output
                                            # r9 - the counter for the inner loop (the number of times we output the character)
                                            # r10 - next address (the offset) - multiplied by 8
                                            # r8, 9, 10 - we operate on the bits of rcx

    movq (%rdi), %rcx                       # %rcx stores the value of the first message (0X00020000000A0148)
    movq %rdi, %rdx                         # %rdx stores the address of the first message (the base address for the offset)


                                            # at the adress of %rdx we have %rcx, %rcx is something like 0X00020000000A0148
                                            # do ... while()
    outerLoop:
        # the counter
        movq $0, %r9                        # initializes the innerLoop counter to 0
        movq %rcx, %rbx                     # copies the value of %rcx into %rbx
        shr $(1 * 8), %rbx                  # removes the least significant byte

        movb %bl, %r9b                      # moves the (second) least significant byte of %rbx into %r9b (the counter for the inner loop)

        # the char
        movq $0, %r8                        # movb does not switch the other bits to 0
        movb %cl, %r8b                      # moves the least significant byte of %rcx into %r8b (the character to output)

        innerLoop:
            cmpq $0, %r9                    # check if the loop is over
            je endInnerLoop                 # if the loop is over, jump to endInnerLoop

            subq $1, %r9                    # decrements the innerLoop counter by 1

            movq $0, %rax                   # no vector registers for printf
            movq $output, %rdi              # param1: format string
            movq %r8, %rsi                  # param2: the char we want to output

                                            # r8, r9, rcx, rdx are all caller saved, we save them in the stack before
                                            # calling printf bcs printf can modify them (convention)
            pushq %r8               
            pushq %r9
            pushq %rcx
            pushq %rdx

            call printf                     # prints the character stored in %r8

            popq %rdx
            popq %rcx
            popq %r9
            popq %r8

            jmp innerLoop

        endInnerLoop:

                                            # %r10 - offset from .MESSAGE
        movq %rcx, %rbx                     # copies the value of %rcx into %rbx
        shr $(2 * 8), %rbx                  # removes the two least significant bytes
        movl %ebx, %r10d                    # moves the least significant 4 bytes of %rbx into %r10d (the offset from .MESSAGE)
      
        cmpq $0, %r10                       # checks if the offset is 0 (if we have reached the end of the message)
        je endOuterLoop                     # if the offset is 0, jump to endOuterLoop

        
        leaq (%rdx, %r10, 1 * 8), %r12      # calculates the address of the next message (the offset from .MESSAGE) and stores it in %r12
        movq (%r12), %rcx                   # %rcx is still the "value" address
        jmp outerLoop                       # continues the outer loop

    endOuterLoop:
    popq    %r12                            # pops the value of r12 from the stack and restores it to the r12 register
    popq    %rbx                            # pops the value of rbx from the stack and restores it to the rbx register

    # epilogue
	movq	%rbp, %rsp		                # clear local variables from stack
	popq	%rbp			                # restore base pointer location 
	ret

main:
	pushq	%rbp 			                # push the base pointer (and align the stack)
	movq	%rsp, %rbp		                # copy stack pointer value to base pointer

	movq	$MESSAGE, %rdi	                # first parameter: address of the message
	call	decode			                # call decode

    #epilogue
	popq	%rbp			                # restore base pointer location 
	movq	$0, %rdi		                # load program exit code
	call	exit			                # exit the program

