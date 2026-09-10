.text

output: .asciz "%c"

.include "helloWorld.s"

.global main

decode:
	# prologue
	pushq	%rbp 			            # push the base pointer (and align the stack)
	movq	%rsp, %rbp		            # copy stack pointer value to base pointer

    pushq   %r14
    pushq   %r12

                                        # rcx - value adress (0X00020000000A0148)
                                        # rdx - adress of the pointer to the first message
                                        # rcx = *rdx
                                        # r12 - initially equal with #rdx, we modify it in the outerLoop, #rdx should be constant
                                        # r8 - the counter
                                        # r9 - the character we output
                                        # r11 - next adress (the offsetul) - multiplied by 8?
                                        
                                        # r8, 9, 10 - we operate on the bits of rcx; 
                                        # !! little-endian allignment !!

    movq (%rdi), %rcx
    movq %rdi, %rdx


                                        # at the adress of %rdx we have %rcx, %rcx is something like 0X00020000000A0148
                                        # do ... while()
    outerLoop:
        # the counter
        movq $0, %r9                    # movb does not switch the other bits to 0
        movq %rcx, %r14
        shr $(1 * 8), %r14              # little-endian allignment, shr removes the most significant byte (8th one)
        movb %r14b, %r9b

        # the char
        movq $0, %r8                    # movb does not switch the other bits to 0
        movb %cl, %r8b

        innerLoop:
            cmpq $0, %r9                # check if the loop is over
            je endInnerLoop

            subq $1, %r9

            movq $0, %rax               # no vector registers for printf
            movq $output, %rdi          # param1: format string
            movq %r8, %rsi              # param2: the char

                                        # r8, r9, rcx, rdx are all caller saved, we save them before calling printf bcs printf can modify them (convention)
            pushq %r8               
            pushq %r9
            pushq %rcx
            pushq %rdx
            call printf
            popq %rdx
            popq %rcx
            popq %r9
            popq %r8

            jmp innerLoop

        endInnerLoop:

                                        # %r10 - offset from .MESSAGE
        movq %rcx, %r14
        shr $(2 * 8), %r14
        movl %r14d, %r10d               # movl does switch the other bits to 0
      
        cmpq $0, %r10
        je endOuterLoop

        
        leaq (%rdx, %r10, 1 * 8), %r12  # %r12 = base + offset 
        movq (%r12), %rcx               # rcx is still the "value" address
        jmp outerLoop


    endOuterLoop:
    # epilogue
    movq	%rbp, %rsp		# clear local variables from stack
	popq	%rbp			# restore base pointer location 
	ret

main:
	pushq	%rbp 			# push the base pointer (and align the stack)
	movq	%rsp, %rbp		# copy stack pointer value to base pointer

	movq	$MESSAGE, %rdi	        # first parameter: address of the message
	call	decode			# call decode


	popq	%rbp			# restore base pointer location 
	movq	$0, %rdi		# load program exit code
	call	exit			# exit the program

