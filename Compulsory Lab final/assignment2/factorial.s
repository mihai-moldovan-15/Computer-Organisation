.text
prompt: .asciz "Please enter a non-negative number: "
input: .asciz "%ld"
output: .asciz "Your output is: %ld\n"

.global main

factorial:
    # prologue
    pushq %rbp
    movq %rsp, %rbp
 
    cmpq $0, %rdi                   # checks if the number has reached 0
    je baseCase                     # if the number is 0, return 1 (base case)

    subq $1, %rdi                   # decrements the number by 1 for the recursive call
    call factorial                  # calls the factorial function recursively
    addq $1, %rdi                   # increments the number back to its original value after the recursive call

    mulq %rdi                       # multiplies the result of the recursive call by the current number     

    #epilogue
    movq %rbp, %rsp
    popq %rbp
    ret
    
    baseCase:
    #epilogue
    movq %rbp, %rsp
    popq %rbp

    movq $1, %rax                   # returns 1 for the base case of factorial(0)
    ret                             # returns to the caller

main:
    # prologue
    pushq %rbp
    movq %rsp, %rbp

    movq $prompt, %rdi              # param1: format string
    movq $0, %rax                   # no vector registers for printf

    call printf                     # asks the user for input (number)
    
    movq $0, %rax                   # no vector registers for scanf
    movq $input, %rdi               # param1: format string
    subq $16, %rsp                  # allocates space on the stack for the input
    leaq -8(%rbp), %rsi             # loads the address of the input variable into %rsi (param 2)
    
    call scanf                      # reads the input from the user and stores it into %rsi (number)

    movq -8(%rbp), %rdi             # loads the number into %rdi (param 1) for the factorial function
   
    call factorial                  # calls the factorial function

    movq $output, %rdi              # copies the output format string into %rdi (param 1)
    movq %rax, %rsi                 # copies the result of the factorial function into %rsi (param 2)

    movq $0, %rax                   # no vector registers for printf
    call printf                     # prints the result of the factorial function

    #epilogue
    movq %rbp, %rsp
    popq %rbp

end:
    movq $0, %rdi                      
    call exit                       # exits the program with a status code of 0
    