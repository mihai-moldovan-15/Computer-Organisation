.text

# 10 test sequences (mix of valid and invalid)
MESSAGE:
	.asciz "()"
	.asciz "(())"
	.asciz "([{}])"
	.asciz "([)]"
	.asciz "{[<>]}"
	.asciz "<>>"
	.asciz "((()"
	.asciz "a(b)c[d]e"
	.asciz "{[()]}<>"
	.asciz "]{[("
	.byte 0
