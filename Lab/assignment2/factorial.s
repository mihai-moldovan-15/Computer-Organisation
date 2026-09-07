.text
prompt: .asciz "Please enter a non-negative number: "
input: .asciz "%ld"
output: .asciz "Your output is: %ld\n"

.global main

factorial:
    # prologue
    pushq %rbp
    movq %rsp, %rbp
    cmpq $0, %rdi
    je baseCase

    subq $1, %rdi
    call factorial
    addq $1, %rdi

    mulq %rdi

    #epilogue
    movq %rbp, %rsp
    popq %rbp
    ret
    
    baseCase:
    #epilogue
    movq %rbp, %rsp
    popq %rbp
    movq $1, %rax
    ret 

main:
    # prologue
    pushq %rbp
    movq %rsp, %rbp

    movq $prompt, %rdi               # param1: format string
    movq $0, %rax                    # no vector registers for scanf

    call printf
    
    movq $0, %rax
    movq $input, %rdi
    subq $16, %rsp
    leaq -16(%rbp), %rsi
    
    call scanf

    movq -16(%rbp), %rdi
    movq $0, %rax                   # no vector registers for pow
   
    call factorial    

    movq $output, %rdi
    movq %rax, %rsi

    movq $0, %rax
    call printf

    #epilogue
    movq %rbp, %rsp
    popq %rbp

end:                                # exits the program
    movq $0, %rdi                      
    call exit   

