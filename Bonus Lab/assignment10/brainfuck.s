.global brainfuck
.bss
tape:		.skip 240000
jumpTable:	.skip 8000000
.text
format_str: .asciz "We should be executing the following code:\n%s\n"

/// What happens if i go out of bounds?

/*
	>	62		pointer right
	<	60		pointer left
	+	43		increment this cell
	-	45		decrement 
	.	46		output the current cell(ASCII char)
	,	44		Read one input byte into the current cell
	[	91		Jump past the matching ] if the current cell is 0
	]	93		Jump back to the matching [ if the current cell is nonzero
*/

# Your brainfuck subroutine will receive one argument:
# a zero termianted string containing the code to execute.
brainfuck:
	pushq 	%rbp
	movq 	%rsp, %rbp

	movq	%rdi, %r14					# r14 - address of the string
	

	movq 	%rdi, %rsi					
	movq 	$format_str, %rdi
	movq	$0, %rax
	call 	printf

	# Computing the jump table 
	xorq	%r12, %r12
	movb	(%r14), %cl					# rcx - the character

	computeLoop:
	cmpb	$0, %cl
	je		endComputeLoop

	cmpb	$91, %cl
	jne		notOpening
	pushq	%r12
	jmp		continueComputeLoop
	
	notOpening:
	cmpb	$93, %cl
	jne		continueComputeLoop
										# r13 - indexul la care se deschide paranteza
										# r12 - indexul la care se inchide paranteza
	popq	%r15
	mov		%r12, jumpTable(, %r15, 8)
	mov		%r15, jumpTable(, %r12, 8)

	continueComputeLoop:
	incq	%r12
	movb	(%r14, %r12, 1), %cl 
	jmp 	computeLoop
	endComputeLoop:
	
	xorq	%r12, %r12					# r12 - the offset from the beginning
	movb	(%r14), %cl					# rcx - the character
	
	xorq	%r13, %r13					# r13 - the tape index

	loop:
	cmpb	$0, %cl
	je		endLoop

	cmpb	$62, %cl
	je		movePointerRight

	cmpb	$60, %cl
	je		movePointerLeft

	cmpb	$43, %cl
	je		incrementCell

	cmpb	$45, %cl
	je		decrementCell

	cmpb	$46, %cl
	je		outputCurrentCell

	cmpb	$44, %cl
	je		readIntoCurrentCell

	cmpb	$91, %cl
	je		openForLoop

	cmpb	$93, %cl
	je		closeForLoop

	jmp		continueLoop
#----------------------------------------------
	movePointerRight:
	incq	%r13
	cmpq	$30000, %r13
	je		wrapBigIndex
	jmp		continueLoop

	wrapBigIndex:
	movq	$0, %r13
	jmp		continueLoop
#----------------------------------------------
	movePointerLeft:
	decq	%r13
	cmpq	$-1, %r13
	je		wrapSmallIndex
	jmp		continueLoop

	wrapSmallIndex:
	movq	$29999, %r13
	jmp		continueLoop
#----------------------------------------------
	incrementCell:
	incq	tape(, %r13, 8)
	cmpq	$256, tape(, %r13, 8)
	je		wrapBigValue
	jmp		continueLoop

	wrapBigValue:
	movq	$0, tape(, %r13, 8)
	jmp 	continueLoop
#----------------------------------------------	
	decrementCell:
	decq	tape(, %r13, 8)
	cmpq	$-1, tape(, %r13, 8)
	je		wrapSmallValue
	jmp		continueLoop

	wrapSmallValue:
	movq	$255, tape(, %r13, 8)
	jmp 	continueLoop
#----------------------------------------------	
	outputCurrentCell:
	movq	tape(, %r13, 8), %rdi
	call	putchar
	jmp		continueLoop
#----------------------------------------------
	readIntoCurrentCell:
	call	getchar
	movq	%rax, tape(, %r13, 8)
	jmp		continueLoop
#----------------------------------------------	
	openForLoop:
	cmpq	$0, tape(, %r13, 8)
	je		exitForLoop
	jmp		continueLoop

	exitForLoop:
	movq	jumpTable(, %r12, 8), %r12
	jmp		continueLoop
#----------------------------------------------
	closeForLoop:
	cmpq	$0, tape(, %r13, 8)
	je		continueLoop
	movq	jumpTable(, %r12, 8), %r12
	jmp		continueLoop
#----------------------------------------------
	continueLoop:
	incq	%r12
	movb	(%r14, %r12, 1), %cl 
	jmp 	loop
	endLoop:
	movq %rbp, %rsp
	popq %rbp
	ret
