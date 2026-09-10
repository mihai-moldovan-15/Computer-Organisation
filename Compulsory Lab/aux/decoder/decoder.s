.data
# BUFFER .skip 1024 		# worst-case scenario we need ((2^25 ) - 1 ) * (2^9 - 1) bytes

# Segmentation fault 

.text
output: .asciz "%c"

outputAdress: .asciz "Your adress is: %lX\n" 

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
	#subq	 $8, %rsp		# allign the stack pointer

	
	movq %rdi, %rcx
	movq (%rdi), %r12

	# R8 - next memory block to visit
	# R9 - how many times to print
	# R10 - the ASCII character needed

	#cu rcx avem treaba
outerLoop:
	movq $0, %r9		# count
	movb 6(%rcx), %r9b
	
	movq $0, %r10		# the character
	movb 7(%rcx), %r10b

	innerLoop:
		cmpq $0, %r9
		je endInner
		
		subq $1, %r9
		movq $0, %rax	# no vector registers for printf
		movq $output, %rdi	# param1: format string
		movq %r10, %rsi 	# param1: r10 - character
		
		call printf
		
		jmp innerLoop

	endInner:

	## adresa urmatoare
	movq $0, %r8
	movl 2(%rcx), %r8d
	
	cmpq $0, %r8
	je endOuter

	leaq (%r12, %r8), %rcx
	jmp outerLoop
endOuter:

	# epilogue
	movq	%rbp, %rsp		# clear local variables from stack
	popq	%rbp			# restore base pointer location 
	ret

main:
	# prologue 
	pushq	%rbp 			# push the base pointer (and align the stack)
	movq	%rsp, %rbp		# copy stack pointer value to base pointer

	movq	$MESSAGE, %rdi	# first parameter: address of the message
	call	decode			# call decode

	# epilogue
	movq 	%rbp, %rsp
	popq	%rbp			# restore base pointer location 
	movq	$0, %rdi		# load program exit code
	call	exit			# exit the program

