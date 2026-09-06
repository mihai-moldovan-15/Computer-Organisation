.data ## read write section
message: .asciz "My name is Mihai, netID mmoldovan1, assignment name power\n"

.text ## read-only section
.global main ## for the OS to see the beginning of the programme

main:
    ## prologue
    pushq %rbp  
    movq %rsp, %rbp 
    
    movq $0, %rax

    movq $message, %rdi ## copying the address of message into RDI register

    call printf ## calling printf

    ## epilogue
    movq %rbp, %rsp
    popq %rbp

    ret ## returning to the caller (OS)
    