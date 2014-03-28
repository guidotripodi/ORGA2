extern malloc, free

global diagonalej2, suma, diagonalej1

section .data

section .text


diagonalej1:

	;en rdi tengo la matriz
	;en rsi tengo el tamaño
	;en rdx tengo el vector
	
	xor rcx, rcx
	mov cx, si	;iteraciones = columnas
.ciclo:	
					;buscamos los elementos de la diagonal
	mov r8w, [rdi]	;guardamos el elemento
	mov [rdx], r8w
	
	lea rdi, [rdi+2*rsi+2]  ;nos movemos hasta el siguiente elemento de la diagonal
	lea rdx, [rdx+2]		;nos movemos un lugar en el vector
	loop .ciclo
.fin:	
	ret

diagonalej2:

	;en rdi tengo la matriz
	;en rsi tengo el tamaño de la matriz

	push rdi
	push rsi
					;creamos el vector
	mov rdi, rsi
	shl rdi, 2		;calculo el tamaño en bytes: multiplico nx2 porque son shorts
	call malloc 	;en rax tengo el puntero al vector nuevo
	mov r15, rax    ;guardo el puntero al inicio del vector
	
	pop rsi
	pop rdi
	
	xor rcx, rcx
	mov cx, si	;iteraciones = columnas
.ciclo:	
					;buscamos los elementos de la diagonal
	mov r8w, [rdi]	;guardamos el elemento
	mov [rax], r8w
	
	lea rdi, [rdi+2*rsi+2]  ;nos movemos hasta el siguiente elemento de la diagonal
	lea rax, [rax+2]		;nos movemos un lugar en el vector
	loop .ciclo
	mov rax, r15			;devolvemos el puntero al inicio del vector
	
.fin:
	ret

suma:

	;en rdi tengo el vector
	;en rsi tengo el tamaño
	mov rbx, rdi	;copio el puntero al inicio del vector
	
	xor r12,r12      ;registro acumulador
	
	xor rcx, rcx
	mov cx, si	 ;iteraciones = columnas
.cicloSuma:
	add r12w, [rdi]
	lea rdi, [rdi+2] ; me muevo dentro del vector
	loop .cicloSuma
	
	mov rdi, rbx
	call free

	mov rax, r12
	
.fin:
	ret
	

