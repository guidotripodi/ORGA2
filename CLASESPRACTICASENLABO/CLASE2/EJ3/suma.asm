global main
extern imprime_parametros
section .text

main:

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
	MOV RDX, 0x00000080
	MOV RDI,1
	MOV RSI, [RDX]
	; Devuelvo por RAX
	mov RAX, 1
	call imprime_parametros
	; Descarmo stack frame
	pop r15
	pop r14
	pop r13
	pop r12
	pop rbx
	pop rbp
	ret
