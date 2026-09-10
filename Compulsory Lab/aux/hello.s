.data ## read not executed
hello: .asciz "Hello Class of %u\n"
thisYear: .quad 2026

.text ## read and executed
.global main
main:
    push %rbp ##base pointer from OS
    mov %rsp, %rbp ##set up base pointer
    
    mov thisYear, %rsi
    mov $hello, %rdi
    call printf

    mov %rbp, %rsp ##throw away local stack 
    pop %rbp

    ret
## pie - position independent executable

