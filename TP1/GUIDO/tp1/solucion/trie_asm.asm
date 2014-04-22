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
modo_apertura: db "a", 0
modo_read: db "r", 0
format_string: db "%s", 0
str_espacio: db " ", 0
str_salto_linea: db 10, 0
str_trie_vacio: db "<vacio>", 10, 0



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
%define longitud_max_palabra 1024
%define caracter_invalido 'a'


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
push RBP
	mov RBP, RSP
	push R12
	sub RSP, 8

	mov R12, RDI ; R12 = trie*
	cmp qword [R12 + offset_raiz], NULL ;si el trie esta vacio borro el trie unicamente
	je .fin
	mov RDI, [R12 + offset_raiz] ; sino borro el nodo raiz y todos sus sig e hijos
	call nodo_borrar

	.fin:
		mov RDI, R12
		call free
		add RSP, 8
		pop R12
		pop RBP
		ret

nodo_borrar:
	push RBP
	mov RBP, RSP
	push R12
	sub RSP, 8

	mov R12, RDI ; R12 = *nodo
	cmp qword R12, NULL ; if (nodo = NULL) fin
	je .fin
	cmp qword [R12 + offset_hijos], NULL ; if (nodo.hijos == null) borrar siguientes
	je .borrar_siguientes
	mov RDI, [R12 + offset_hijos] ; sino borro los hijos
	call nodo_borrar

		.borrar_siguientes:
			cmp qword [R12 + offset_sig], NULL ; if (nodo.sig == null) fin
			je .fin
			mov RDI, [R12 + offset_sig] ; sino borro los siguientes
			call nodo_borrar
	.fin:
		mov RDI, R12 ; borro el nodo
		call free
		add RSP, 8
		pop R12
		pop RBP
		ret





nodo_crear:
;nodo *nodo_crear(char c)
	push RBP
	mov RBP, RSP
	push R12
	sub RSP, 8

	call validar_caracter
	mov byte R12b, AL ; RAX = char c
	mov RDI, size_nodo
	call malloc ; creo un puntero a nodo, RAX = &nodo
	mov qword [RAX + offset_sig], NULL ; nodo.sig = NULL
	mov qword [RAX + offset_hijos], NULL ; nodo.hijos = NULL
	mov [RAX + offset_c], R12B ; nodo.c = R12b
	mov byte [RAX + offset_fin], FALSE ; nodo.fin = false

	add RSP, 8
	pop R12
	pop RBP
	ret



validar_caracter: ; RDI -> char c
	cmp DL, "A" ; if (c < 'A') no es mayuscula
	jl .no_es_mayuscula
	; sino comparo con z
	cmp DL, "Z" ; if (c > 'Z') no es mayuscula
	jg .no_es_mayuscula 
	; si es mayuscula lo paso a minuscula
	add DL, 32 ; c = c + 32 que es la transformacion a minuscula
	jmp .fin

	.no_es_mayuscula:
		cmp DL, "0" ; if (c < '0') no es numero
		jl .no_es_numero
		; sino comparo con 9
		cmp DL, "9" ; if (c > '9') no es numero
		jg .no_es_numero
		jmp .fin ; si es numero salgo

	.no_es_numero:
		cmp DL, "a" ; if (c < 'a') no es minuscula
		jl .no_es_minuscula
		; sino comparo con z
		cmp DL, "z" ; if (c > 'z') no es minuscula
		jg .no_es_minuscula
		jmp .fin ; si es minuscula salgo

	.no_es_minuscula:
		mov DL, 'a' 

	.fin:
	mov AL, DL ; pongo en RAX el resultado
	ret

insertar_nodo_en_nivel:
	push RBP
	mov RBP, RSP
	push R12
	push R13

	mov R12, RDI ; R12 = **nodo nivel
	mov byte R13b, SIL; RSI ; R13b = char c
	mov RDI, [R12] ; RDI = *nodo nivel
	call nodo_buscar 
	cmp RAX, NULL ; if (nodo_buscar(c) != NULL) fin
	jne .fin
	xor rdi, rdi
	mov rdi, R13 ; crea nodo con char c
	call nodo_crear
	
	mov R8, [R12] ; R8 = *nodo_nivel
	cmp R8, NULL ; if (*nodo_nivel != NULL) 
	jne .ciclo ; sigo en .ciclo
	mov [R12], RAX ; sino inserto nuevo_nodo como unico y primero
	jmp .fin 

	.ciclo:
		mov R10b, [RAX + offset_c] ; R10b =  nuevo_nodo.c
		cmp byte R10b, [R8 + offset_c] ; if (nuevo_nodo.c < nodo_nivel.c) insertar adelante
		jl .insertar_adelante
		mov R9, [R8 + offset_sig] ; R9 = nodo_nivel.sig
		cmp R9, NULL ; else if (nodo_nivel.sig = NULL) insertar a lo ultimo
		je .insetar_ultimo
		cmp byte R10b, [R9 + offset_c] ; else if (nuevo_nodo.c < nodo_nivel.sig.c) insertar en medio
		jle .insertar_en_medio
		mov R8, R9 ; R8 = nodo_nivel.sig y avanzo
		jmp .ciclo

	.insertar_adelante:
		mov [RAX + offset_sig], R8 ; nuevo_nodo.sig = nodo_nivel
		mov [R12], RAX ; pongo el nuevo nodo creado como primero en el nivel
		jmp .fin
	.insertar_en_medio:
		mov [R8 + offset_sig], RAX ; nodo_nivel.sig = nuevo_nodo
		mov [RAX + offset_sig], R9 ; nuevo_nodo.sig = nodo_nivel.sig
		jmp .fin
	.insetar_ultimo:		
		mov [R8 + offset_sig], RAX ; nodo_nivel.sig = nuevo_nodo	
		jmp .fin

	.fin:
	pop R13
	pop R12
	pop RBP
	ret

trie_agregar_palabra:
	push RBP
	mov RBP, RSP
	push R12
	push R13
	push R14
	sub RSP, 8

	mov R12, RDI ; R12 = *trie t
	mov R13, RSI ; R13 = *char p
	lea R14, [R12 + offset_raiz]

	.ciclo:
		cmp byte [R13], 0 ; si termino de recorrer el string, fin
		je .fin
		mov RDI, R14 ; llamo a insertar_nodo_en_nivel con la direccion de hijos del nodo
		mov RSI, [R13] ; y el char
		call insertar_nodo_en_nivel
		lea R14, [RAX + offset_hijos] ; R14 = nodo.hijos
		lea R13, [R13 + 1] ; avanzo sobre el string
		jmp .ciclo

	.fin:
	mov byte [RAX + offset_fin], TRUE ; indico que es fin de palabra
	add RSP, 8
	pop R14
	pop R13
	pop R12
	pop RBP
	ret


trie_imprimir:
;void trie_imprimir(trie *t, char *nombre_archivo)
	push rbp ; Pila Alineada
	mov rbp, rsp
	push r12 ; Pila Desalineada
	push r15 ; Pila Alineada
	push r14
	push r13

	
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

	pop r13
	pop r14
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

	pop r13
	pop r14
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
	MOV R9, RDI
	CMP qword R9, NULL
	JE .fin
	CMP byte RSI, NULL
	JE .noHayChar
	.seguimos:
		CMP [R9 + offset_c], SIL
		JE .esta
		CMP byte [R9 + offset_sig], NULL
		JE .noEsta
		MOV R9, [r9 + offset_sig]
		jmp .seguimos

	.noHayChar:
		mov RAX, NULL
		jmp .fin

	.noEsta:
		MOV RAX, NULL
		jmp .fin
	.esta:
		MOV RAX, R9 ;devuelvo null o el nodo
	.fin:
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


trie_construir: ; RDI -> char* nombre_archivo
	push RBP
	mov RBP, RSP
	push R12
	push R13
	push R14
	push R15

	mov RSI, modo_read ; asigno segundo parametro; modo de apertura read
	call fopen
	mov R12, RAX ; R12 = *fp pongo en R12 el puntero al archivo
	mov RDI, longitud_max_palabra ; creo un puntero para una palabra acotada
	call malloc
	mov R13, RAX ; R13 = char* palabra
	call trie_crear
	mov R14, RAX ; R14 = trie_crear()

	.ciclo:
		mov RDI, R12 ; primer parametro fp*
		mov RSI, format_string ; formato '%s'
		mov RDX, R13 ; palabra
		call fscanf
		cmp EAX, NULL ; if (fscanf = NULL) salgo
		jle .fin
		; sino agrego palabra
		mov RDI, R14 ; primer parametro trie
		mov RSI, R13 ; segundo parametro palabra para agregar
		call trie_agregar_palabra
		jmp .ciclo

	.fin:
		mov RDI, R13 ; borro el string creado
		call free
		mov RDI, R12 ; cierro el archivo
		call fclose
		mov RAX, R14 ; devuelvo el trie
	pop R15
	pop R14
	pop R13
	pop R12
	pop RBP	
	ret