.text

.global diff
.global check_flags

#######################################################################
# Subroutine CHECK_FLAGS                                              *
# Check for -i and -b flags in command line arguments                 *
# Parameters: argc, argv                                              *
# Returns:                                                            *
#   0 for no flags                                                    *
#   1 for -i only                                                     *
#   2 for -b only                                                     *
#   3 for both flags                                                  *
#   4 for error (anything else)                                       *
#######################################################################
check_flags:
  pushq %rbp
  movq  %rsp, %rbp

  # RSI - array of pointers
  movq  $3, %rcx        # RCX - iterator, first 3 pointers in argv are file names
  xorq  %r8, %r8        # R8  - 1 if -b flag appears
  xorq  %r9, %r9        # R9  - 1 if -i flag appears

  loop:
      cmpq  %rcx, %rdi
      je  endLoopSuccess
                        # R10 - argv[RCX]
      movq  (%rsi, %rcx, 8), %r10
      
                        # compare char by char, a for loop is not necessary
                        # R11 - stores a specific char from R10
      movb  (%r10), %r11b
      cmpb  $45, (%r11) # first char is a '-'
      jne   endLoopError

      movb  1(%r10), %r11b
      cmpb  $98, (%r11) # second char is 'b'
      jne    notBflag

      movq  $1, %r8
      movb  2(%r10), %r11b
      cmpb  $0, (%r11)  # third char is \0
      jne   endLoopError

      jmp   continueLoop

      notBflag:
      cmpb  $105, (%r11) # second char is 'i'
      jne   endLoopError

      movq  $1, %r9
      movb  2(%r10), %r11b
      cmpb  $0, (%r11)  # third char is \0
      jne   endLoopError      

    continueLoop:
      incq  %rcx
      jmp loop

  endLoopSuccess:
                    # R11 - the result of R8 && R9
  movq  $1, %r11
  andq  %r8, %r11
  andq  %r9, %r11

  cmpq  $1, %r11
  jne   notBothAreTrue
  movq  $3, %rax
  jmp   end

  notBothAreTrue:
  cmpq  $1, %r8
  jne   onlyIflagCouldBeTrue
  movq  $2, %rax
  jmp   end

  onlyIflagCouldBeTrue:
  cmpq  $1, %r9
  jne   NoneAreTrue
  movq  $1, %rax
  jmp  end
  
  NoneAreTrue:
  movq  $0, %rax
  jmp   end  


  endLoopError:
  movq  $4, %rax


  end:
  movq %rbp, %rsp
  popq %rbp
  ret


#######################################################################
# Subroutine DIFF                                                     *
# Compare file1 and file2 line by line and print changes to stdout    *
# Parameters:                                                         *
#   - Pointer to contents of file 1                                   *
#   - Pointer to contents of file 2                                   *
#   - Boolean for -i flag                                             *
#   - Boolean for -b flag                                             *
# Returns: 0 if files were equal, 1 otherwise                         *
#######################################################################
diff:
  pushq %rbp
  movq %rsp, %rbp

  # Your code goes here, good luck!

  movq %rbp, %rsp
  popq %rbp
  ret
