section .data
	msg: DB 'en 100 me voy ... 99',10
	largo EQU $ - msg
global _start
section .text
	_start:
	mov esi, 10
	ciclo:
		mov ebp, 9
		subCiclo:
			mov rax, 4 ; funcion 4
			mov rbx, 1 ; stdout
			mov rcx, msg; menaje
			mov rdx, largo; longitud
			int 0x80
			dec byte [msg+largo-2]
			dec ebp
			cmp ebp, 0
		jnz subCiclo
		
		mov rax, 4 ; funcion 4
		mov rbx, 1 ; stdout
		mov rcx, msg; menaje
		mov rdx, largo; longitud
		int 0x80
		dec byte [msg+largo-3]
		dec esi
		mov byte [msg+largo-2], '9'
		cmp esi, 0
	jnz ciclo
	
	
	mov rax, 1
	mov rbx, 0
	int 0x80
