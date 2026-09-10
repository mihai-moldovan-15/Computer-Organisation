.text

success: .asciz "Valid\n"
failure: .asciz "Invalid\n"

.include "basicInvalid.s"

.global main

# *******************************************************************************************
# Subroutine: check_validity                                                                *
# Description: checks the validity of the parenthesization of multiple strings,             *
#              as defined in Assignment 5.                                                  *
# Parameters:                                                                               *
#   first: the first string that should be checked                                          *
#   return: the number of strings that were considered invalid                              *
# *******************************************************************************************

output: .asciz "%c"

# ( = 40      ) = 41  
# { = 123     } = 125 
# [ = 91      ] = 93  
# < = 60      > = 62  

check_validity:
	# prologue
	pushq	%rbp 			    # push the base pointer (and align the stack)
	movq	%rsp, %rbp		    # copy stack pointer value to base pointer

    movq    %rdi, %r12          # %r12 - the address of the string

    outerLoop:
        resetStack:
            cmpq %rsp, %rbp
            je cleanedTheStack
            addq $8, %rsp
            jmp resetStack

        cleanedTheStack:
        cmpb $0, (%r12)
        je end
        movq    $1, %rax
        innerLoop:
            cmpb $0, (%r12)         # chek if we reached \0
            je endInnerLoopSuccessfully        
            
            cmpb $0, %al           
	        jne continue
            addq $1, %r12       
            jmp innerLoop
        continue:
            movb (%r12), %r13b

            cmpb $40, %r13b       
            je opensSmth
            cmpb $123, %r13b       
            je opensSmth
            cmpb $91, %r13b
            je opensSmth
            cmpb $60, %r13b
            je opensSmth

            cmpb $41, %r13b        
            je closesType1
            cmpb $125, %r13b       
            je closesType2
            cmpb $93, %r13b
            je closesType3
            cmpb $62, %r13b
            je closesType4

            add $1, %r12
            jmp innerLoop                # doesn't open, doesn't close, just a character to ignore
            opensSmth:
                pushq %r13               # add the value to the stack
                addq $1, %r12            # go to the next character 
                jmp innerLoop
            
            closesType1:            # Type 1 is ()
                cmpq %rbp, %rsp     # check is stack is empty
                je failed

                cmpb $40, (%rsp)
                jne failed
                popq %r14           # pop the stack, retinem in r14 momentan, nu prea mai avem nevoie de ea
                addq $1, %r12       # go to the next character    
                jmp innerLoop  
            
            closesType2:            # Type 2 is {}
                cmpq %rbp, %rsp     # check is stack is empty
                je failed

                cmpb $123, (%rsp)
                jne failed
                popq %r14           # pop the stack, retinem in r14 momentan, nu prea mai avem nevoie de ea 
                addq $1, %r12       # go to the next character    
                jmp innerLoop  

            closesType3:            # Type 3 is []
                cmpq %rbp, %rsp     # check is stack is empty
                je failed

                cmpb $91, (%rsp)
                jne failed
                popq %r14           # pop the stack, retinem in r14 momentan, nu prea mai avem nevoie de ea 
                addq $1, %r12       # go to the next character    
                jmp innerLoop  

            closesType4:            # Type 4 is <>
                cmpq %rbp, %rsp     # check is stack is empty
                je failed

                cmpb $60, (%rsp)
                jne failed
                popq %r14           # pop the stack, retinem in r14 momentan, nu prea mai avem nevoie de ea 
                addq $1, %r12       # go to the next character    
                jmp innerLoop 

            failed:
                movq $0, %rax
                addq $1, %r12           
                jmp innerLoop 

        endInnerLoopSuccessfully:
        cmpq %rsp, %rbp
        jne failed1

        jmp endInnerLoop    
        failed1:
            movq $0, %rax
    
    endInnerLoop:
    addq $1, %r12
    ///aici vine si o afisare
    cmpb $0, %al           
	je printfailure
    
    printsuccess:
        movq $success, %rdi
        movq $0, %rax
        call printf 

        jmp outerLoop

    printfailure:
        movq $failure, %rdi
        movq $0, %rax
        call printf 
            
        jmp outerLoop

end:
	movq	%rbp, %rsp		# clear local variables from stack
	popq	%rbp			# restore base pointer location 
	ret

main:
	pushq	%rbp 			# push the base pointer (and align the stack)
	movq	%rsp, %rbp		# copy stack pointer value to base pointer

	movq	$MESSAGE, %rdi		# first parameter: address of the message
	call	check_validity		# call check_validity

endProgramme:
    popq	%rbp			# restore base pointer location 
	movq	$0, %rdi		# load program exit code
	call	exit			# exit the program

