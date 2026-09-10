.data
input: .asciz "%ld %ld" # why doesn't this work?:  input: .asciz "Please enter a base and an exponent: %ld %ld"
output: .asciz "The result is: %ld\n"

.text
.global main

# scanf - (input adress, adress of param1(on the stack, cannot be a register), adress of param2(on stack also, can t be directly on the register))

main: 
    pushq %rbp
    movq %rsp, %rbp

    movq $0, %rax

    subq $32, %rsp
    movq $input, %rdi
    leaq -32(%rbp), %rsi
    leaq -16(%rbp), %rdx

    call scanf

    movq -32(%rbp), %rdi # move the variables
    movq -16(%rbp), %rsi
    
    call pow

    movq %rax, %rcx
    movq $0, %rax 

    movq $output, %rdi
    movq %rcx, %rsi 
    
    call printf

    movq %rbp, %rsp
    popq %rbp

exit:
    movq $0, %rdi
    ret

pow: 
    pushq %rbp
    mov %rsp, %rbp

    movq $1, %rax # the result of the function

    loop:
        cmpq $1, %rsi
        jl end

        mulq %rdi
        subq $1, %rsi
        jmp loop

    end:

    movq %rbp, %rsp
    popq %rbp 

    ret
