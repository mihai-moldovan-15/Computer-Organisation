.section .data
format:
    .asciz "%ld\n"

.section .text
.globl main
.extern printf

main:
    movq    $2, %rax
    movq    $1, %rcx
    addq    %rax, %rcx

    movq    %rcx, %rsi      
    leaq    format(%rip), %rdi
    movl    $0, %eax        

    call    printf

    movl    $0, %eax
    ret
