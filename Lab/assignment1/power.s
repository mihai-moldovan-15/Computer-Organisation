.text
prompt: .asciz "Please enter a base and a positive exponent "
input: .asciz "%ld %ld"
output: .asciz "Your output is: %ld\n"

.global main

pow: 
# prologue
    pushq %rbp
    movq %rsp, %rbp

    movq $1, %rax

loop:
    cmp $0, %rsi
    je endLoop

    movq %rsi, %rcx
    andq $1, %rcx

    cmpq $0, %rcx
    je skipStep

    mulq %rdi

    skipStep:
    imulq %rdi, %rdi
    shr $1, %rsi

    jmp loop

endLoop:
#epilogue
    movq %rbp, %rsp
    popq %rbp
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
    subq $32, %rsp
    leaq -32(%rbp), %rsi
    leaq -16(%rbp), %rdx
    
    call scanf

    movq -32(%rbp), %rdi
    movq -16(%rbp), %rsi
    movq $0, %rax                   # no vector registers for pow
   
    call pow    

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

