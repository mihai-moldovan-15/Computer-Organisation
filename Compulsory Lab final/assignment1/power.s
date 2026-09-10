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

    movq $1, %rax                               # initializes the result to 1

loop:
    cmp $0, %rsi                                # checks if the exponent is 0
    je endLoop                                  # if exponent is 0, exit the loop

    movq %rsi, %rcx                             # copies the exponent to %rcx
    andq $1, %rcx                               # checks if the exponent is odd

    cmpq $0, %rcx                               
    je skipStep                                 # skips the multiplication step if the exponent is even

    mulq %rdi                                   # multiplies the result by the base if the exponent is odd

    skipStep:
    imulq %rdi, %rdi                            # squares the base
    shr $1, %rsi                                # shifts the exponent to the right by 1 (divides by 2)

    jmp loop                                    # continues the loop

endLoop:                                        # exits the loop when the exponent is 0
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

    call printf                                 # asks the user for input (base)

    movq $0, %rax                               # no vector registers for scanf
    movq $input, %rdi                           # param1: format string
    subq $16, %rsp                              # allocates space on the stack for the input      
    leaq -8(%rbp), %rsi                         # loads the address of the input variable into %rsi (param 2)
    call scanf                                  # reads the input from the user and stores it into %rsi (base)

    movq -8(%rbp), %rbx                        # loads the base into %rbx (param 1)
    movq $promptExponent, %rdi                  # param1: format string
    movq $0, %rax                               # no vector registers for printf

    call printf                                 # asks the user for input (exponent)

    movq $0, %rax                               # no vector registers for scanf
    movq $input, %rdi                           # param1: format string 
    subq $16, %rsp                              # allocates space on the stack for the input
    leaq -8(%rbp), %rsi                         # loads the address of the input variable into %rsi (param 2)
    call scanf                                  # reads the input from the user and stores it into %rsi (exponent)

    movq -8(%rbp), %rsi                        # loads the exponent into %rsi (param 2)
    movq %rbx, %rdi                             # loads the base into %rdi (param 1)    
    
    call pow                                    # calls the pow function

    movq $output, %rdi                          # param1: format string
    movq %rax, %rsi                             # param2: result of pow function
    movq $0, %rax                               # no vector registers for printf

    call printf                                 # prints the result of the pow function

    #epilogue
    movq %rbp, %rsp
    popq %rbp

end:                                # exits the program
    movq $0, %rdi                      
    call exit   

