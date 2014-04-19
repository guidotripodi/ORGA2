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
extern lista_borrar

;etiquetas para impresion 

modoFOpen: db "a", 0
modoFOpenRead: db "r", 0
espacio: db " ", 0
stringVacio: db "", 0
string: DB '%c', 0
string1: DB '%s', 0
trieVacio: db "<>", 0
saltoDeLinea: DB '%s', 10, 0
fin: DB "", 03,0
vacio: DB '', 0
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
	jmp .borrarTrieNoVacio

.borrarTrieVacio:
	mov rdi, r12
	call free
	add rsp, 8
	pop r12
	pop rbp
	ret

; ~ void borrarTrieNoVacio(nodo_t *self) si no esta vacio el trie voy nodo por nodo
.borrarTrieNoVacio:
	mov r12, rdi
	cmp qword [r12 + offset_sig], NULL
	je .borrarRama
	mov rdi, [r12 + offset_sig]
	jmp .borrarTrieNoVacio

.borrarRama:
	mov rdi, r12
	call borroConHijos
	
	ret

borroConHijos:
	push rbp ; Pila Alineada
	mov rbp, rsp
	push r12 ; Pila Desalineada
	sub rsp, 8 ; Pila Alineada

	mov r12, rdi
	cmp qword [r12 + offset_hijos], NULL
	je .borrarActual
	
	mov rdi, [r12 + offset_hijos]
	jmp borroConHijos

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
	;MOV qword [R12],NULL
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
	jmp .caracterValido
.sigo:
	MOV [RAX + offset_c], BL, ;guardo el char
	MOV byte[RAX + offset_fin], FALSE; palabra no termina
	jmp .fin


	.caracterValido:
	CMP byte BL, 61h
	JL .veoSiEsNumero
	CMP byte BL, 7Ah
	JL .sigo
	XOR RBX, RBX
	MOV byte BL, "a"
	jmp .sigo

.veoSiEsNumero:
	CMP byte BL, 39h
	JLE .veoSiEsNumero
	XOR RBX, RBX
	MOV byte BL, "a"
	jmp .sigo

.veoSiEsNumero1:
	CMP byte BL, 30h
	JGE .sigo
	XOR RBX, RBX
	MOV byte BL, "a"
	jmp .sigo

	.fin:
	POP RBP
	RET


insertar_nodo_en_nivel:
	;RDI DIRECCION DEL 1er NODO de ese nivel; esto apunta a hijos del padre
	;RSI CHAR que tengo que agregar
	push RBP
	mov RBP, RSP
	push R13
	push R14
	push R15
	sub rsp, 8
	mov R13, RDI ; copio puntero del nodo
	mov R14, R13 
	mov RDI, RSI ;paso char a rdi para crear nodo
	cmp qword [R13], NULL
	je .nivelVacio ; en caso que mi trie inicie vacio o me pasen un puntero a hijos del padre null
	mov R14, [R14+offset_sig]
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
		mov [RAX+offset_sig], R14
		;Mov [R13 + offset_hijos], RAX
		;LEA R13, [RAX + offset_sig]
		MOV [R13], rax
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
		add rsp,8
		pop R15
		pop R14
		pop R13
		pop RBP
		ret
	

trie_agregar_palabra:
	PUSH RBP
	MOV RBP, RSP
	PUSH R12
	PUSH R13

	
	MOV R12, RDI								; guardo en R12 trie*
	MOV R13, RSI								; guardo en R13 char*
	XOR RSI, RSI
	MOV byte SIL, [R13]								; guardo en SIL el primer char
	CMP byte SIL, NULL								; veo si me pasaron string vacio
	JE .fin
			CMP qword[R12 + offset_raiz], NULL		; veo si el trie esta vacio
			JNE .trie_no_vacio
			XOR RDI, RDI						; limpio RDI
			MOV DIL, SIL						; pongo en DIL el char para nodo_crear
			CALL nodo_crear
			MOV [R12 + offset_raiz], RAX		; pongo el nuevo nodo como raiz del trie
			LEA RDI, [RAX  + offset_hijos]		; R8: n (nodo*) a raiz
			JMP .agregoHijos
	.trie_no_vacio:
			CALL insertar_nodo_en_nivel
			LEA RDI, [RAX + offset_hijos]							
	.agregoHijos:
			ADD r13, 1
			XOR RSI, RSI
			MOV SIL, [R13]
			CALL insertar_nodo_en_nivel
			LEA RDI, [RAX + offset_hijos]
			CMP byte[R13 + 1], 0			
			JNE .agregoHijos
			MOV byte[RAX + offset_fin] , TRUE		
	
.fin:
	POP R13
	POP R12
	POP RBP
	RET


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
	jmp .terminarArchivo1

.noEsVacia:
	call lista_crear
	MOV R14, RAX ;ME GUARDO LA LISTA CREADA Q SE VA A IMPRIMIR
	MOV R13, RAX; ME GUARDO EL PUNTERO PARA ELIMINARLO
	MOV R15, [R15+offset_sig]
.ciclo:
	XOR RSI, RSI
	LEA RSI, [R15+offset_c]
	MOV RDI, R15
	call palabras_con_prefijo
	MOV RDI, R14 ; paso putnero a la lista creada para imprimir
	MOV RSI, RAX ;LISTA DE palabras_con_prefijo
	call lista_concatenar
	MOV RDI, RAX ;vuelo la lista q me dio palabras_con_prefijo xq ya la concate 
	CALL free
	MOV RDI, R15
	CMP qword[R15 + offset_sig], NULL
	JE .recorroParaImprimir
	MOV R15,[R15 +offset_sig]
	jmp .ciclo

				.recorroParaImprimir:
					MOV R14,[R14 +offset_prim] 
					XOR r15,r15
					mov rdi, r12
					mov rsi, string1
					mov rdx, [r14 + offset_valor]
					mov rax, 1
					call fprintf
				.sigoEnLaLista:
					mov rdi, r12
					mov rsi, espacio
					mov rax, 1
					call fprintf
					CMP qword [r14 +offset_sig_lnodo], NULL 
					je .terminarArchivo
					LEA R14,[R14 +offset_sig_lnodo] 
					jmp .recorroParaImprimir

										
	.terminarArchivo:

	mov rdi, r12
	mov rsi, saltoDeLinea
	mov rdx, stringVacio
	mov rax, 1
	call fprintf


	mov rdi, r12
	call fclose

	MOV RDI, R13
	CALL lista_borrar

	pop r15
	pop r12
	pop rbp	
	ret

.terminarArchivo1:

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
	SUB RSP, 8
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
	cmp byte [r15+1], NULL
	JNE .siguePalabra
.siEsta:
	MOV qword RAX, TRUE
	ADD RSP,8
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
	ADD RSP,8
	POP R15
	POP RBP
	RET

nodo_buscar:
;nodo *nodo_buscar(nodo *n, char c)
	PUSH RBP
	MOV RBP,RSP
	PUSH R15
	SUB RSP,8
	MOV R15, RDI
	CMP qword R15, NULL
	JE .fin
	CMP byte RSI, NULL
	JE .noHayChar
	.seguimos:
		CMP [R15 + offset_c], SIL
		JE .fin
		CMP byte [R15 + offset_sig], NULL
		JE .noEsta
		MOV R15, [r15 + offset_sig]
		jmp .seguimos

	.noHayChar:
		mov r15, NULL
		jmp .fin

	.noEsta:
		MOV R15, [R15 + offset_sig]
		jmp .fin
	.fin:
		MOV RAX, r15 ;devuelvo null o el nodo
		ADD RSP, 8
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
	JE .terminarArchivo1
	call lista_crear
	MOV R14, RAX ;ME GUARDO LA LISTA CREADA Q SE VA A IMPRIMIR
	MOV RBX, RAX ;ME GUARDO ESTE REGISTRO PARA VOLAR LA LISTA CUANDO TERMINO
	MOV R12,RAX
	MOV R15, [R15+offset_sig]
	XOR R12, R12
	xorpd xmm0, xmm0
	xorpd xmm2, xmm2
.ciclo:
	XOR RSI, RSI
	LEA RSI, [R15+offset_c]
	MOV RDI, R15
	call palabras_con_prefijo
	MOV RDI, R14 ; paso putnero a la lista creada para imprimir
	MOV RSI, RAX ;LISTA DE palabras_con_prefijo
	call lista_concatenar
	MOV RDI, R15
	CMP qword[R15 + offset_sig], NULL
	JE .aLaBalansa
	MOV R15,[R15 +offset_sig]
	jmp .ciclo

				.aLaBalansa:
					MOV R14,[R14 +offset_prim] 
					jmp .sacarPesoYSumar
					.sigoEnLaLista:
					CMP qword [r14 +offset_sig_lnodo], NULL 
					je .promedio
					LEA R14,[R14 +offset_sig_lnodo] 
					jmp .aLaBalansa

						.sacarPesoYSumar:
							xorpd xmm1, xmm1
							mov rdi, [R14 + offset_valor]
							call R13
							movq XMM1, RAX
							addpd XMM2, XMM1
							add R12, 1
							Jmp .sigoEnLaLista

					.promedio:
						xorpd xmm3, xmm3
						movq XMM3, R12
						CVTDQ2PD XMM1, XMM3
						divpd xmm2, xmm1
										


.terminarArchivo:

	movq xmm0, XMM2

	MOV RDI, RBX
	call lista_borrar

	pop r13
	pop r15
	pop rbp	
	ret


.terminarArchivo1:
	
	xorpd xmm3, xmm3
	xor r10,R10
	MOV R10, 0
	movq XMM3, R10
	CVTDQ2PD XMM1, XMM3
	movq xmm0, xmm1			

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
	PUSH RBX
	;SUB RSP,8

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
	MOV RDI, 1024
	CALL malloc
	MOV R14, RAX
	MOV R12, RAX
	jmp .recorroPrefijo
.sigo:
	MOV RDI, R13
	MOV RSI, RBX
	MOV RDX, R12
	CALL dame_palabras
	;MOV RAX, RSI

	MOV RDI, R12
	CALL free
	MOV qword [R12] , NULL				; libero la memo de 1024 que use para el prefijo
	mov rax, RBX
	jmp .fin

.recorroPrefijo:
		XOR r11,r11
		MOV r11, [R15]
		MOV [R14], r11
		LEA r14,[R14 +1] 
		CMP byte [R15+1], 0 ; si termina me quedo con el prefijo para ir juntando las palabras mas facil
		JE .sigo
		ADD R15, 1
		jmp .recorroPrefijo

.fin:	
	;ADD RSP, 8
	POP RBX
	POP R11
	POP R12
	POP R13
	POP R14
	POP R15
	POP RBP
	RET



	.listaVacia:
	call lista_crear 
	MOV RBX, RAX ;GUARDO EL PUNTERO A LA LISTA CREADA
	jmp .fin




	dame_palabras:
; PARAMETROS RECIBIDOS
	; RDI: nodo* (ultimo)
	; RSI: listaP* (lista)	
	; RDX: char* (pref)		; para agregar como prefijo de cada palabra que encuentre
	PUSH RBP
	MOV RBP, RSP
	PUSH R12
	PUSH R13
	PUSH R14
	PUSH R15
	
	MOV R12, RDI						; R12: ultimo
	MOV R13, RDX						; R13: pref
	;tamanio_prefijo
	MOV RDI, R13
	XOR RCX, RCX
	NOT RCX
	XOR AL, AL
	CLD
	REPNE SCASB
	NOT RCX
	DEC RCX					
	MOV R15, RCX						; R15: tamanio de prefijo
	MOV R14, RSI						; R14: lista
	;if (ultimo != NULL){
	CMP R12, NULL
	JE .fin
		;nodo* actual = ultimo->hijos;
		MOV R12, [R12 + offset_hijos]	; R12: actual
		;if (actual != NULL){
		CMP R12, NULL
		JE .fin
			;if (actual->fin == 1){
			CMP byte[R12 + offset_fin], 1
			JNE .buscar_actual
				;lista_agregar(lista, concatenate(pref, actual->c));}
						;concatenate(pref, actual->c)					
						XOR RSI, RSI
						MOV SIL, byte[R12 + offset_c]					
						MOV byte[R13 + R15], SIL
						MOV byte[R13 + R15 + 1], 0
					
					MOV RDI, R14
					MOV RSI, R13
					CALL lista_agregar
					
			.buscar_actual:
			;buscar_palabras(actual, lista, concatenate(pref, actual->c));
			;R8 = concatenate(pref, actual->c)
				XOR RSI, RSI
				MOV SIL, byte[R12 + offset_c]					
				MOV byte[R13 + R15], SIL
				MOV byte[R13 + R15 + 1], 0
			MOV RDI, R12
			MOV RSI, R14
			MOV RDX, R13
			CALL dame_palabras
			
			;if (actual->sig != NULL){
			CMP qword[R12 + offset_sig], NULL
			JE .fin
				;buscar_palabras(actual->sig, lista, concatenate(pref, actual->sig->c));}}}}
					;R8 = concatenate(pref, actual->sig->c)
					MOV RDI, [R12 + offset_sig]			; RDI: actual->sig
					XOR RSI, RSI
					MOV SIL, byte[RDI + offset_c]					
					MOV byte[R13 + R15], SIL
					MOV byte[R13 + R15 + 1], 0
				MOV RSI, R14
				MOV RDX, R13
				CALL dame_palabras
				
.fin:
	POP R15
	POP R14
	POP R13
	POP R12
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
	SUB RSP, 8
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
		CMP qword RAX, NULL
		JE .fin
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
	ADD RSP, 8
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
 	CMP EAX,NULL
	JLE .eliminoPuntero
	jmp .agregarPalabra

	
.creoPuntero:
	MOV RDI, 1024
	Call malloc ;creo el puntero para las palabras
	MOV R12, RAX
	MOV R14, RAX
	jmp .continuo

.trieVacio:
	call trie_crear
	jmp .eliminoPuntero

.agregarPalabra:
	cmp r13, NULL
	je .trie
.agrego:
	MOV RDI, R13
	MOV RSI, R12
	CALL trie_agregar_palabra
	jmp .ciclo

	.trie:
	call trie_crear
	MOV R13, RAX
	JMP .agrego

.eliminoPuntero:
	MOV RDI, R14
	CALL free
	MOV qword [R14], NULL
	

	.terminarArchivo:
	mov rdi, r15
	call fclose
	mov rax, r13
	pop r15
	pop r12
	pop rbp	
	ret
