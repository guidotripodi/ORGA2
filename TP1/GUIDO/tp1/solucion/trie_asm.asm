global trie_crear
global nodo_crear
global insertar_nodo_en_nivel
global trie_agregar_palabra
global trie_construir
global trie_borrar
global trie_imprimir
global buscar_palabra
global palabras_con_prefijo
global trie_pesar
global nodo_buscar
extern malloc
extern calloc
extern free
extern fopen
extern fprintf
extern fclose
extern strlen
extern printf
extern fscanf
extern feof
extern lista_crear
extern lista_agregar
extern lista_concatenar

;etiquetas para impresion 

modoFOpen: db "a", 0
modoFOpenRead: db "r", 0
abreLLave: db "{ ", 0
cierraLLave: db " }", 0
abreCorchete: db "[ ", 0
cierraCorchete: db" ]", 0
espacio: db " ", 0
stringVacio: db "", 0
string: DB '%c', 0
string1: DB '%s', 0
trieVacio: db "<>", 0
saltoDeLinea: DB '%s', 10, 0
vacio: DB '', 0
llaveAbrir: DB '{ ', 0
llaveCerrar: DB ' }', 0
corcheteAbrir: DB '[ ', 0
corcheteCerrar: DB ' ]', 0
float1: DD 1.00000000000000000001



; SE RECOMIENDA COMPLETAR LOS DEFINES CON LOS VALORES CORRECTOS
%define offset_sig 0
%define offset_hijos 8
%define offset_c 16
%define offset_fin 17

%define size_nodo 18

%define offset_raiz 0

%define size_trie 8

%define offset_prim 0

%define offset_valor 0
%define offset_sig_lnodo 8

%define NULL 0

%define FALSE 0
%define TRUE 1

section .rodata

section .data

section .text

; FUNCIONES OBLIGATORIAS. PUEDEN CREAR LAS FUNCIONES AUXILIARES QUE CREAN CONVENIENTES

trie_crear:
;trie *trie_crear(void)
	PUSH rbp
	MOV rbp, rsp

	MOV rdi, size_trie
	CALL malloc
	MOV qword[rax], NULL
;	MOV r15, RAX
	
	
	POP rbp
	ret
	
trie_borrar:
;void trie_borrar(trie *t)
	push rbp ; Pila Alineada
	mov rbp, rsp
	push r12 ; Pila Desalineada
	sub rsp, 8 ; Pila Alineada
	mov r12, rdi
	cmp qword [r12], NULL
	je .borrarTrieVacio
	mov rdi, [r12]
	call borrarTrieNoVacio

.borrarTrieVacio:
	mov rdi, r12
	call free
	add rsp, 8
	pop r12
	pop rbp
	ret

; ~ void borrarTrieNoVacio(nodo_t *self) si no esta vacio el trie voy nodo por nodo
borrarTrieNoVacio:
	push rbp ; Pila Alineada
	mov rbp, rsp
	push r12 ; Pila Desalineada
	sub rsp, 8 ; Pila Alineada
	mov r12, rdi
	cmp qword [r12 + offset_sig], NULL
	je .borrarActual
	mov rdi, [r12 + offset_sig]
	call borrarTrieNoVacio

.borrarActual:
	mov rdi, r12
	call borroConHijos
	add rsp, 8
	pop r12
	pop rbp
	ret

; ~ void borroConHijos(nodo_t *self) hago recursion en los nodos hijos de la supuesta palabra
borroConHijos:
	push rbp ; Pila Alineada
	mov rbp, rsp
	push r12 ; Pila Desalineada
	sub rsp, 8 ; Pila Alineada

	mov r12, rdi
	cmp qword [r12 + offset_hijos], NULL
	je .borrarActual
	
	mov rdi, [r12 + offset_hijos]
	call borroConHijos

.borrarActual:

	mov rdi, r12
	call nodo_borrar

	add rsp, 8
	pop r12
	pop rbp
	ret

; ~ void nodo_borrar(nodo_t *self) borro todo el nodo EN CASO DE PERDER MEMORIA CHEQUEAR SI ESTA BIEN ESTE
nodo_borrar:

	push rbp ; Pila Alienada
	mov rbp, rsp
	push r12 ; Pila Desalineada
	sub rsp, 8 ; Pila Alineada
	call free
	add rsp, 8
	pop r12
	pop rbp
	ret

nodo_crear:
;nodo *nodo_crear(char c)
	PUSH rbp
	MOV rbp, rsp
	XOR RBX, RBX
	MOV RBX, RDI ; COPIO EL CHAR
	MOV RDI, size_nodo ; paso tam del nodo
	Call malloc ; recibo en rax el puntero
	
	
	MOV qword [RAX], NULL ; el siguiente nodo a este es NULL
	MOV qword [RAX+offset_hijos], NULL ; como estoy creando un nodo no tengo hijo = NULL
	MOV [RAX + offset_c], BL, ;guardo el char
	MOV byte[RAX + offset_fin], FALSE; palabra no termina
	
	
	POP RBP
	RET
insertar_nodo_en_nivel:
	;RDI DIRECCION DEL 1er NODO de ese nivel; esto apunta a hijos del padre
	;RSI CHAR que tengo que agregar
	push RBP
	mov RBP, RSP
	push RBX
	push R13
	push R14
	push R15
	mov R13, RDI ; copio puntero del nodo
	mov R14, R13 
	mov RDI, RSI ;paso char a rdi para crear nodo
	cmp qword [R13], NULL
	je .nivelVacio ; en caso que mi trie inicie vacio o me pasen un puntero a hijos del padre null
	;mov R14, [R14+offset_sig]
	.ciclo:
		cmp [R14 + offset_c], SIL; si es igual lo doy y temine
		je .noAgrego
		cmp [R14+offset_c], SIL ; lo comparo con el char que esta en RSI  
		jg .agregoPrimero ; si es menor va primero y no tengo anterior
		cmp qword [R14+offset_sig], NULL ; si el siguiente nodo esta vacio agrego al nuevo al final significando q es el mayor a todos
		je .agregoUltimo
		MOV R15, [R14+offset_sig] ; es el siguiente nodo
		cmp [R15+offset_c], SIL ; lo comparo con el sig nodo
		jg .agregoEnElMedio
		mov R14, [R14+offset_sig]
		jmp .ciclo
		
	
	.noAgrego:
		mov RAX, R14
		jmp .fin
	.agregoPrimero:
		call nodo_crear ;en RAX tengo el nuevo nodo
		mov [RAX+offset_sig], R14 ;el siguiente de rax es el primero del nivel original
		mov [R13+offset_hijos] , RAX  ;el papa del nivel apunta al nuevo nodo ahora
		jmp .fin
	.agregoUltimo:
		call nodo_crear ;en RAX tengo el nuevo nodo
		mov [R14+offset_sig], RAX
		jmp .fin
	.agregoEnElMedio:
		call nodo_crear ;en RAX tengo el nuevo nodo
		mov [R14+offset_sig], RAX
		Mov [RAX+offset_sig], R15
		jmp .fin
	.nivelVacio:
		call nodo_crear ;en RAX tengo el nuevo nodo
		mov [R13], RAX
		
	.fin:
		pop R15
		pop R14
		pop R13
		pop RBX
		pop RBP
		ret
	

trie_agregar_palabra:
	;void trie_agregar_palabra(trie *t, char *p)
	;RDI tengo el puntero a trie
	;RSI tengo el puntero a char, palabra a agregar
	push RBP ; pila al
	mov RBP, RSP
	push RBX ; pila des
	Push R13 ;pila al
	mov R13, RSI ;copio el puntero a char de RSI a R13
	
	.agregoPalabra:
	XOR rsi, rsi
	mov byte SIL, [R13]
	CMP byte SIL, NULL
	je .fin
	call insertar_nodo_en_nivel ; recibo en rax el nodo insertado

	lea RDI, [RAX+offset_hijos] ; voy al nivel de abajo
	MOV RSI, R13
	lea R13, [RSI+1] ; voy a la siguiente letra a agregar
	XOR RSI, RSI
	MOV byte SIL, [R13]
	cmp byte SIL, NULL
	jne .agregoPalabra
	MOV QWORD [RAX+offset_fin], TRUE ;si llego al final del puntero del string de palabra termino palabra
	
	.fin:
	pop R13
	pop RBX
	pop RBP
	ret


	
trie_imprimir:
;void trie_imprimir(trie *t, char *nombre_archivo)
	push rbp ; Pila Alineada
	mov rbp, rsp
	push r12 ; Pila Desalineada
	push r15 ; Pila Alineada
	
	
	mov r12, rsi ; Archivo
	mov r15, rdi ; TRIE

	mov rdi, r12
	mov rsi, modoFOpen ; seteo el modo de abrir el arvhivo
	call fopen

	mov r12, rax ; Guardo el puntero al archivo abierto
	
	cmp qword [r15], NULL
	JNE .noEsVacia

.esVacia:

	mov rdi, r12
	mov rsi, trieVacio
	mov rax, 1
	call fprintf
	jmp .terminarArchivo

.noEsVacia:
	call lista_crear
	MOV R14, RAX ;ME GUARDO LA LISTA CREADA Q SE VA A IMPRIMIR
	MOV R15, [R15+offset_sig]
	jmp .punteroParaPrefijo
.ciclo:
	XOR RSI, RSI
	MOV SIL, [R15+offset_c]
	MOV byte [R11], SIL
	MOV RDI, R15
	MOV RSI, R11
	call palabras_con_prefijo
	MOV RDI, R14 ; paso putnero a la lista creada para imprimir
	MOV RSI, RAX ;LISTA DE palabras_con_prefijo
	PUSH R11 ; LO GUARDO ACA POR LA CONVENCION SINO SE PIERDE
	SUB RBP, 8
	call lista_concatenar
	ADD RBP,8
	POP R11
	MOV RDI, R15
	CMP qword[R15 + offset_sig], NULL
	JE .eliminoPuntero
	MOV R15,[R15 +offset_sig]
	ADD R13,1
	jmp .ciclo

			.punteroParaPrefijo:
				MOV RDI, 1
				call malloc
				MOV qword [RAX], NULL ;inicializo puntero NULL
				MOV R11, RAX ;GUARDO EL PUNTERO CREADO
				jmp .ciclo

					.eliminoPuntero:
						MOV RDI, R11
						call free
				.recorroParaImprimir:
					MOV R14,[R14 +offset_prim] 
					XOR r15,r15
					XOR RBX, RbX
					LEA RBX, [R14 + offset_valor]
					MOV r15, [RBX] ;esto me da un puntero a char
					jmp .imprimirCharDePalabra
					.sigoEnLaLista:
					mov rdi, r12
					mov rsi, espacio
					mov rax, 1
					call fprintf
					CMP qword [r14 +offset_sig_lnodo], NULL 
					je .terminarArchivo
					LEA R14,[R14 +offset_sig_lnodo] 
					jmp .recorroParaImprimir

						.imprimirCharDePalabra:
							;XOR RSI, RSI
							mov rdi, r12
							mov rsi, string
							mov rdx, [r15]
							mov rax, 1
							call fprintf
							CMP byte [r15+1], 0
							JE .sigoEnLaLista
							LEA r15, [r15+1]
							jmp .imprimirCharDePalabra


					
	.terminarArchivo:

	mov rdi, r12
	mov rsi, saltoDeLinea
	mov rdx, stringVacio
	mov rax, 1
	call fprintf

	mov rdi, r12
	call fclose

	pop r15
	pop r12
	pop rbp	
	ret



buscar_palabra:
;bool buscar_palabra(trie *t, char *p)
	PUSH RBP
	MOV RBP, RSP
	PUSH R15
	PUSH R14
	CMP QWORD [RDI], NULL
	JE .noEsta
	MOV R15, RSI  ;COPIO EL PUNTERO
	MOV RDI, [RDI +offset_sig]
	.continuo:
	XOR RSI, RSI ; LIMPIO RSI
	MOV byte SIL, [R15] ; se lo copio a la parte baja de rsi
	call nodo_buscar 
	CMP byte RAX, NULL ;si no esta un nodo termino
	JE .noEsta
	;CMP byte [RAX+ offset_c], NULL ;si no esta un nodo termino
	;JE .noEsta
	;MOV RDI, [RDI +offset_sig]
	;MOV R14, [R15+1]  ; voy a la siguiente letra a buscar
	cmp byte [r15+1], NULL
	JNE .siguePalabra
.siEsta:
	MOV qword RAX, TRUE
	POP R14
	POP R15
	POP RBP
	RET

.siguePalabra:
	CMP qword [RAX + offset_hijos], NULL ;antes de continuar chequeo que queden hijos que puedan continuar la palabra
	JE .noEsta
	MOV RAX, [RAX + offset_hijos] ; si encontro el nodo voy bajando al hijo
	MOV RDI, RAX 
	ADD R15, 1
	jmp .continuo
	

.noEsta:
	MOV qword RAX, FALSE
	;ADD RBP,8
	POP R14
	POP R15
	POP RBP
	RET

nodo_buscar:
;nodo *nodo_buscar(nodo *n, char c)
	PUSH RBP
	MOV RBP,RSP
	PUSH R15
	SUB RBP,8
	MOV R15, RDI
	CMP qword R15, NULL
	JE .fin
	.seguimos:
		CMP [R15 + offset_c], SIL
		JE .fin
		CMP byte [R15 + offset_sig], NULL
		JE .noEsta
		MOV R15, [r15 + offset_sig]
		jmp .seguimos

	.noEsta:
		MOV R15, [R15 + offset_sig]
		jmp .fin
	.fin:
		MOV RAX, r15 ;devuelvo null o el nodo
		ADD RBP, 8
		POP R15
		POP RBP
		ret


trie_pesar:
;double trie_pesar(trie *t, double (*funcion_pesaje)(char*))
	PUSH RBP
	MOV RBP, RSP
	PUSH R15
	PUSH R13
	;EN RDI TENGO EL TRIE
	;EN RSI TENGO LA DIRECCION DONDE EMPIEZA LA FUNCION
	;LA GUARDO EN R13
	MOV R15, RDI
	MOV R13, RSI
	CMP qword R15, NULL
	JE .terminarArchivo
	call lista_crear
	MOV R14, RAX ;ME GUARDO LA LISTA CREADA Q SE VA A IMPRIMIR
	MOV R15, [R15+offset_sig]
	XOR R10, R10
	XOR R12, R12
	xorpd xmm0, xmm0
	xorpd xmm2, xmm2
	jmp .punteroParaPrefijo
.ciclo:
	XOR RSI, RSI
	MOV SIL, [R15+offset_c]
	MOV byte [R11], SIL
	MOV RDI, R15
	MOV RSI, R11
	call palabras_con_prefijo
	MOV RDI, R14 ; paso putnero a la lista creada para imprimir
	MOV RSI, RAX ;LISTA DE palabras_con_prefijo
	PUSH R11 ; LO GUARDO ACA POR LA CONVENCION SINO SE PIERDE
	PUSH R10
	call lista_concatenar
	POP R10
	POP R11
	MOV RDI, R15
	CMP qword[R15 + offset_sig], NULL
	JE .recorroParaImprimir
	MOV R15,[R15 +offset_sig]
	ADD R13,1
	jmp .ciclo

			.punteroParaPrefijo:
				MOV RDI, 1
				PUSH R11 ; LO GUARDO ACA POR LA CONVENCION SINO SE PIERDE
				PUSH R10
				call malloc
				POP R10
				POP R11
				MOV qword [RAX], NULL ;inicializo puntero NULL
				MOV R11, RAX ;GUARDO EL PUNTERO CREADO
				jmp .ciclo

				.recorroParaImprimir:
					MOV R14,[R14 +offset_prim] 
					XOR r15,r15
					XOR RBX, RbX
					LEA RBX, [R14 + offset_valor]
					MOV r15, [RBX] ;esto me da un puntero a char
					jmp .sacarPesoYSumar
					.sigoEnLaLista:
					CMP qword [r14 +offset_sig_lnodo], NULL 
					je .promedio
					LEA R14,[R14 +offset_sig_lnodo] 
					jmp .recorroParaImprimir

						.sacarPesoYSumar:
							;XOR RSI, RSI
							xorpd xmm1, xmm1
							mov rdi, r15
							mov rsi, r15
							PUSH R10
							SUB RBP,8
							call R13
							ADD RBP,8
							POP R10 
							movq XMM1, RAX
							addsd XMM2, XMM1
							add R10, 1
							Jmp .sigoEnLaLista

					.promedio:
						xorpd xmm3, xmm3
						movq XMM3, R10
						CVTDQ2PD XMM1, XMM3
						divpd xmm2, xmm1
										
					;.eliminoPuntero:
					;	MOV RDI, R11
					;	call free
					;	jmp .terminarArchivo


.terminarArchivo:

	movq xmm0, XMM2

	pop r13
	pop r15
	pop rbp	
	ret




palabras_con_prefijo:
	;listaP *palabras_con_prefijo(trie *t, char *prefijo)
	;USO RbX PARA GUARDAR PUNTERO A LA LISTA
	;USO R13 PARA GUARDAR EL PUNTERO AL NODO OBTENIDO POR nodo_prefijo Y recorrer los siguientes
	;USO R12 PARA PUNTERO A PALABRA
	;USO R15 PARA GUARDAR TRIE
	;USO R14 PARA EL prefijo
	;USO RcX PARA RECORRER LOS HIJOS
	; R11 PARA OBTENER EL CHAR Y PASARLO AL PUNTERO
	; R10 PARA PUNTERO AL PRINCIPIO DE LA PALABRA
	PUSH RBP
	MOV RBP, RSP
	PUSH R15
	PUSH R14
	PUSH R13
	PUSH R12
	PUSH R11
	PUSH R10
	PUSH RCX
	PUSH RBX
	XOR R9, R9
	XOR R8,R8
	PUSH R9
	PUSH R8
	MOV R14, RDI
	MOV R15, RSI
	CMP qword RSI, NULL
	JE .listaVacia  ; si me dan un trie o prefijo vacio devuelvo lista vacia
	call nodo_prefijo
	CMP qword RAX, NULL
	JE .listaVacia  ;si no encuentra prefijo devuelvo vacio
	MOV R13, RAX
	call lista_crear 
	MOV RBX, RAX
	LEA R13, [R13 + offset_hijos]
	jmp .punteroParaPalabra
	.ciclo:
		XOR R14,R14
		MOV R13, [R13 + offset_sig]
		CMP qword R13, NULL
		JE .elPrefijoEsPalabra
		MOV R14, R13
		jmp .armoPalabra
	.terminoCiclo:
		CMP qword [R13 + offset_sig], NULL
		JE .borroPunteroCreado
		LEA R13,[R13 + offset_sig]
		jmp .ciclo

		.armoPalabra:
			XOR R11, R11
			MOV R11, [R14 + offset_c] ; le copio el caracter 
			CMP qword [R14 + offset_sig], NULL
			JNE .guardoElDeAlLado
		.sigo:
			MOV [R12], R11
			CMP byte[R14 + offset_fin], TRUE
			JE .unionALista
			add r12,1 
			MOV R14,[R14 + offset_hijos]
			jmp .armoPalabra

			.unionALista:
					MOV byte [R12 +1], 0
					MOV RDI, RBX ; COPIO EL PUNTERO A LA LISTA
					MOV RSI, R10
					PUSH R10
					SUB RBP,8
					call lista_agregar
					ADD RBP, 8
					POP R10
					MOV RBX, RAX
					CMP byte [r14 + offset_hijos], NULL
					JNE .sigoBajando
					pop R8
					pop R9
					CMP qword r8, NULL
					JNE .meCorroALsiguiente
					jmp .terminoCiclo

			.sigoBajando:
				MOV R14,[R14 + offset_hijos]
				ADD R12, 1
				jmp .armoPalabra

			.meCorroALsiguiente:
				MOV R14,R8
				mov r12, R9
				jmp .armoPalabra

			.guardoElDeAlLado:
				MOV R9, R12
				MOV R8, [R14 + offset_sig]
				PUSH R9
				PUSH R8
				jmp .sigo

				.elPrefijoEsPalabra:
					MOV byte [R12 +1], 0
					MOV RDI, RBX ; COPIO EL PUNTERO A LA LISTA
					MOV RSI, R10
					PUSH R10
					SUB RBP,8
					call lista_agregar
					ADD RBP, 8
					POP R10
					POP R8
					POP R9
					JMP .borroPunteroCreado
		.borroPunteroCreado:
		;	MOV RDI, R10
		;	call free
			jmp .fin		

	.punteroParaPalabra:
			PUSH RBX
			PUSH R13
			MOV RDI, 1025
			;MOV RSI, 1025
			Call malloc ;creo el puntero para las palabras
			MOV R12, RAX
			MOV R10, R12
			POP R13
			POP RBX
			jmp .recorroElPrefijo

			.recorroElPrefijo:
				XOR r14,r14
				MOV r14, [R15]
				MOV [R12], r14
				LEA r12,[R12 +1] 
				CMP byte [R15+1], 0 ; si termina me quedo con el prefijo para ir juntando las palabras mas facil
				JE .ciclo
				ADD R15, 1
				jmp .recorroElPrefijo

		.listaVacia:
		call lista_crear 
		MOV RBX, RAX ;GUARDO EL PUNTERO A LA LISTA CREADA
		POP R8
		POP R9
		jmp .fin

	.fin:
	POP RBX
	POP RCX
	POP R10
	POP R11
	POP R12
	POP R13
	POP R14
	POP R15
	POP RBP
	RET

nodo_prefijo:
;nodo *nodo_prefijo(nodo *n, char *p)
; en rdi recibo el puntero a nodo
; en rsi recibo el puntero a char
	PUSH RBP
	MOV RBP, RSP
	PUSH R14
	PUSH R15
	PUSH R13
	SUB RBP, 8
	MOV R15, RDI ; COPIO *nodo
	MOV R14, RSI ; copio *p
	XOR RSI, RSI  ;vacio rsi para pasarle un char y buscarlo
	MOV RSI, [R14]
	call nodo_buscar
	CMP qword RAX, NULL
	JE .fin ;si no encuentra ni el primero es que no tiene prefijo
	ADD R14, 1
	CMP byte [R14], NULL
	JE .fin
	LEA RAX, [RAX + offset_hijos] ; si encontro el nodo voy bajando al hijo
	MOV RAX, [RAX + offset_sig]
	MOV RDI, RAX 
	.ciclo:
		XOR RSI, RSI 
		MOV SIL ,[R14]	
		CMP qword RAX, NULL
		JE .fin
		call nodo_buscar ;busco a partir del segundo caracter, el primero lo busco fuera del ciclo, si ingreso es q el primero esta
		CMP BYTE [R14 + 1], 0
		JNE .sigoGirando
		jmp .fin
	
		.sigoGirando:
			MOV R15,RDI
			LEA RAX, [RAX + offset_hijos]
			MOV RDI, RAX
			ADD R14, 1
			jmp .ciclo

.fin:
	ADD RBP, 8
	POP R13
	POP R15
	POP R14
	POP RBP
	RET


trie_construir:
;trie *trie_construir(char *nombre_archivo)
;en rdi tengo el puntero al archivo
	Push RBP,
	MOV RBP, RSP
	push r12 ; Pila Desalineada
	push r15 ; Pila Alineada
	
	mov r15, rdi ; archivo
	mov rdi, r15
	mov rsi, modoFOpenRead ; seteo el modo de abrir el arvhivo
	call fopen
	mov r15, rax ; Guardo el puntero al archivo abierto
	jmp .creoPuntero
.continuo:
	xor R13, r13
.ciclo:
	mov rdi, r15
	mov rsi, string1
	mov rdx, r12
	mov rax, 1
	call fscanf
	CMP BYTE [R12], 3ch
	JE .trieVacio
 	CMP byte [R12],10
	JE .eliminoPuntero
	jmp .agregarPalabra

	
.creoPuntero:
	MOV RDI, 1025
	Call malloc ;creo el puntero para las palabras
	MOV R12, RAX
	jmp .continuo

.trieVacio:
	call trie_crear
	jmp .eliminoPuntero

.agregarPalabra:
	cmp r13, NULL
	je .trie
.agrego:
	MOV RDI, R13 ; TRIE
	MOV RSI, r12
	Call buscar_palabra
	CMP qword RAX, FALSE
	JNE .terminarArchivo
	MOV RDI, R13
	MOV RSI, R12
	CALL trie_agregar_palabra
	jmp .ciclo

	.trie:
	call trie_crear
	MOV R13, RAX
	JMP .agrego

.eliminoPuntero:
	MOV RDI, R12
	CALL free

	.terminarArchivo:
	mov rdi, r15
	call fclose
	mov rax, r13
	pop r15
	pop r12
	pop rbp	
	ret
