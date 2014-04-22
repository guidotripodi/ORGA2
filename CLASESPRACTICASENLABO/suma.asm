global print
section .text
	print:
	ADDSD XMM0, XMM1
	RET
