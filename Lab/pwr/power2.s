# Lab Assignment 1 - complete code
# check doar sa nu faca overflow, daca rez incape in 64 nu face, 
# putem avea si rez pe 128 daca folosim rdx:rax la inmultire

.text                           # code section - read only
input: .asciz "%ld %ld"         # can include ascii strings in .text
prompt: .asciz "Please enter a base and a positive exponent: "
output: .asciz "Your result is: %ld\n"

.global main                    # main needs to be visible to the OS

main:
    #prologue
    pushq %rbp
    movq %rsp, %rbp


    movq $0, %rax               # no vector registers in use for printf
    movq $prompt, %rdi          # first argument of printf

    call printf                 # call printf to prompt the user for input

    subq $32, %rsp              # reserve space on the stack for input (2 * 16)
    movq $0, %rax               # no vector registers in use for scanf
    movq $input, %rdi           # param1: input format string
    leaq -32(%rbp), %rsi        # param2: address of the reserved (base)
    leaq -16(%rbp), %rdx        # param3: address of the reserved (exponent)

    call scanf                  # call scanf to scan the user input

    mov $0, %rax                # no vector registers in use for pow 
    movq -32(%rbp), %rdi        # param1: address of the base
    movq -16(%rbp), %rsi        # param2: address of the exponent

    call pow                    # call pow to calculate the result

    movq %rax, %rsi             # second argument of printf
    movq $0, %rax               # no vector registers in use for printf
    movq $output, %rdi          # first argument of printf

    call printf                 # call printf to output the result

    #epilogue
    mov %rbp, %rsp
    popq %rbp

end:
    movq $0, %rdi
    call exit

# pow function   
pow:
    #prologue
    pushq %rbp
    movq %rsp, %rbp

    movq $1, %rax               # the result of the funtion will be returned in %rax

    loop:
        cmpq $0, %rsi           # compare RSI to 0
        je endloop              # if RSI == 0, exit the loop

        movq %rsi, %rcx   
        andq $1, %rcx
        
        cmpq $0, %rcx           # check if the exponent is even
        je skipcode
        
        mulq %rdi               # %rax *= %rdi

        skipcode:
            imulq %rdi, %rdi    # %rdi *= %rdi
            shr $1, %rsi        # %rsi /= 2
            jmp loop            # continue the loop

    endloop:

    #epilogue
    movq %rbp, %rsp
    popq %rbp

    ret




    