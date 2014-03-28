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
	MOV RDX, 'HOLA'
	; Hago rsi= 1
	MOV RDI, 1
	
	;DOY VALOR DOUBLE PARA XMM1
	MOVAPs XMM0, 0.01
	
	MOv RSI, [RDI]
	; Devuelvo por RAX = 1 solicitado para printf
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
