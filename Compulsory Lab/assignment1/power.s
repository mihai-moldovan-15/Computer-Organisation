.text
promptBase: .asciz "Please enter a (positive) base: "
promptExponent: .asciz "Please enter a positive exponent: "
input: .asciz "%ld"
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

    movq $promptBase, %rdi                      # param1: format string
    movq $0, %rax                               # no vector registers for printf

    call printf

    movq $0, %rax                               # no vector registers for scanf
    movq $input, %rdi
    subq $16, %rsp
    leaq -16(%rbp), %rsi
    call scanf

    movq -16(%rbp), %r12
    movq $promptExponent, %rdi                  # param1: format string
    movq $0, %rax                               # no vector registers for printf

    call printf

    movq $0, %rax                               # no vector registers for scanf
    movq $input, %rdi
    subq $16, %rsp
    leaq -16(%rbp), %rsi
    call scanf

    movq -16(%rbp), %rsi
    movq %r12, %rdi

    movq $0, %rax                                # no vector registers for pow
    
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

