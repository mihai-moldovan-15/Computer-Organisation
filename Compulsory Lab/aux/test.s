.data
hello: .asciz "Hello class of %u\n"
message: .quad 2026

.text
.global main
main:
    push %rbp
    mov %rsp, %rbp
    
    mov $hello, %rdi
    mov message, %rsi

    call printf

    mov %rbp, %rsp
    pop %rbp

    ret
