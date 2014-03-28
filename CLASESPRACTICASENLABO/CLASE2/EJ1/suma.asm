global suma2Enteros

section .text

suma2Enteros:

	; Esto es un comentario
	
	; int suma2Enteros(int a, int b);
	; a-> RDI
	; b-> RSI
	
	; Armo stack frame SALVANDO TODOS los registros
	push RBP
	mov RBP, RSP
	push RBX
	push R12
	push R13
	push R14
	push R15
	
	;CODIGO
	
	; Hago rdi= rdi+rsi
	add RDI, RSI
	
	; Devuelvo por RAX
	mov RAX, RDI	
	
	; Descarmo stack frame
	pop r15
	pop r14
	pop r13
	pop r12
	pop rbx
	pop rbp
	ret
