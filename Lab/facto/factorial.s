# Lab Assignment 2 - complete code
# La fel, overflow de la 21! 
# Rezultatul trebuie memorat in %RDX:%RAX

.text                           # code section - read only
input:  .asciz "%ld"            # can include ascii strings in .text
prompt: .asciz "Please enter a positive number "
output: .asciz "Your result is: %ld\n"

.global main                    # main needs to be visible to the OS

main:
    # prologue
    pushq %rbp
    movq %rsp, %rbp

    movq $0, %rax               # no vector registers in use for printf
    movq $prompt, %rdi          # first argument of printf

    call printf                 # call printf to prompt the user for input
    
    movq $0, %rax               # no vector registers in use for scanf
    subq $16, %rsp              # reserve space on the stack for the input
    movq $input, %rdi           # param1: input format string
    leaq -16(%rbp), %rsi        # param2: address of the reserved

    call scanf                  # call scanf to scan for user input

    movq -16(%rbp), %rdi        # param1: input number
    movq $0, %rax               # no vector registers in use for factorial

    call factorial              

    movq %rax, %rsi
    movq $0, %rax               # no vector registers in use for printf
    movq $output, %rdi

    call printf

    # epilogue
    movq %rbp, %rsp
    popq %rbp

end:
    movq $0, %rdi
    call exit 

# factorial function   
factorial:                      
    # prologue
    pushq %rbp
    movq %rsp, %rbp

    cmpq $0, %rdi
    je returned

    subq $1, %rdi
    call factorial 
    addq $1, %rdi

    mulq %rdi

    # epilogue 
    mov %rbp, %rsp
    popq %rbp
    ret

    # epilogue
    returned:
        mov $1, %rax
        # epilogue
        mov %rbp, %rsp
        popq %rbp

        ret    
