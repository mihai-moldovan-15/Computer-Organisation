.data
BUFFER .skip 1024 		# worst-case scenario we need ((2^25 ) - 1 ) * (2^9 - 1) bytes

.text

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

	# rdi - adresa primului mesaj
	# rcx = rdi 
	# dupa ce procesezi un quad, dai switch la primul byte sau bit, primii 2 bytes sunt unknown deci nu prea conteaza
		# te opresti cand ajungi la un %rcx pentru care bit-byte ul de check e on
	# %rcx = %rdi + offset, unde offset = 4 byte index 
	
	

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

