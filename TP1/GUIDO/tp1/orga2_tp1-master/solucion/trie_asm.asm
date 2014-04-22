; parametros enteros o punteros: RDI, RSI, RDX, RCX, R8 Y R9 y pila
; parametros puntos flotantes: XMM0 ... XMM7

; Convencion C
; Preservar RBX, R12, R13, R14 y R15
; Retornar el resultado en RAX o XMM0

; Byte Registers: AL, BL, CL, DL, DIL, SIL, BPL, SPL, R8L - R15L
; Word Registers: AX, BX, CX, DX, DI, SI, BP, SP, R8W - R15W
; Doubleword Registers: EAX, EBX, ECX, EDX, EDI, ESI, EBP, ESP, R8D - R15D
; Quadword Registers: RAX, RBX, RCX, RDX, RDI, RSI, RBP, RSP, R8 - R15

; nasm -f elf64 -g -F dwarf -o trie_asm.o trie_asm.asm
; gcc -o main main.c trie_asm.o trie_c.c

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
global pesar_listap

extern lista_crear
extern lista_agregar
extern lista_borrar
extern lista_concatenar
extern malloc
extern free
extern fopen
extern fclose
extern fprintf
extern fscanf

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
modo_apertura: db "a", 0
modo_read: db "r", 0
format_string: db "%s", 0
espacio: db " ", 0
saltoDeLinea: db 10, 0
string1: DB '%s', 0
modoFOpenRead: db "r", 0
str_trie_vacio: db "<vacio>", 10, 0
modoFOpen: db "a", 0
trieVacio: db "<vacio>", 10, 0
section .text

; ------------------- FUNCIONES OBLIGATORIAS -------------------

trie_crear:
	push RBP
	mov RBP, RSP

	mov RDI, size_trie ; tamaño de trie para malloc
	call malloc

	mov qword [RAX], NULL

	pop RBP
	ret

trie_borrar: ; RDI -> trie t
	push RBP
	mov RBP, RSP
	push R12
	sub RSP, 8

	mov R12, RDI ; R12 = trie*
	cmp qword [R12 + offset_raiz], NULL ; if (t.raiz == NULL) fin
	je .vacioTrie
	mov RDI, [R12 + offset_raiz] ; sino borro el nodo raiz y todos sus sig e hijos
	call nodo_borrar

	.vacioTrie:
		mov RDI, R12
		call free
	add RSP, 8
	pop R12
	pop RBP
	ret


nodo_crear: 
	push RBP
	mov RBP, RSP
	push R12
	sub RSP, 8

	xor r12,r12
	mov byte R12b, DL ; RAX = char c
	mov RDI, size_nodo
	call malloc ; creo un puntero a nodo, RAX = &nodo
	mov qword [RAX + offset_sig], NULL ; nodo.sig = NULL
	mov qword [RAX + offset_hijos], NULL ; nodo.hijos = NULL
	jmp .validar
	.sigo:
	mov [RAX + offset_c], R12B ; nodo.c = R12b
	mov byte [RAX + offset_fin], FALSE ; nodo.fin = false
	jmp .fin

.validar: 
	cmp R12b, "A" ; if (c < 'A') no es mayuscula
	jl .noMayuscula
	; sino comparo con z
	cmp R12b, "Z" 
	jg .noMayuscula 
	; si es mayuscula lo paso a minuscula
	add R12b, 32 ;transformo a minuscula
	jmp .sigo

	.noMayuscula:
		cmp R12b, "0" ; if (c < '0') no es numero
		jl .noEsNumero
		; sino comparo con 9
		cmp R12b, "9" ; if (c > '9') no es numero
		jg .noEsNumero
		jmp .sigo ; si es numero salgo

	.noEsNumero:
		cmp R12b, "a" ; if (c < 'a') no es minuscula
		jl .invalido
		; sino comparo con z
		cmp R12b, "z" ; if (c > 'z') no es minuscula
		jg .invalido
		jmp .sigo ; si es minuscula salgo

	.invalido:
		mov R12b, 'a' ; c = 'a'
		jmp .sigo
	


	.fin:
	add RSP, 8
	pop R12
	pop RBP
	ret

insertar_nodo_en_nivel: ; RDI -> **nodo nivel, RSI -> char c
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

	xor RDI, RDI ; vacio la parte alta de rdi
	mov byte DL, R13b ; crea nodo con char c
	call nodo_crear
	
	mov R8, [R12] ; R8 = *nodo_nivel
	cmp R8, NULL ; if (*nodo_nivel != NULL) 
	jne .ciclo ; sigo en .ciclo
	mov [R12], RAX ; sino inserto nuevo_nodo como unico y primero
	jmp .fin 

	.ciclo:
		mov R10b, [RAX + offset_c] ; R10b =  nuevo_nodo.c
		cmp byte R10b, [R8 + offset_c] ; si es menor que el inicial va adelante y lo pongo como nuevo hijo
		jl .insertar_adelante
		mov R9, [R8 + offset_sig] ; R9 = nodo_nivel.sig
		cmp R9, NULL ; si recorro todo el nivel y sigue siendo mayor o no esta lo pongo en el final
		je .alFinal
		cmp byte R10b, [R9 + offset_c] ;si es mas grande que el "anterior" pero mas chico q el actual va al medio
		jle .enElMedio
		mov R8, R9 
		jmp .ciclo

	.insertar_adelante:
		mov [RAX + offset_sig], R8 
		mov [R12], RAX 
		jmp .fin
	.enElMedio:
		mov [R8 + offset_sig], RAX 
		mov [RAX + offset_sig], R9
		jmp .fin
	.alFinal:		
		mov [R8 + offset_sig], RAX 
		jmp .fin

	.fin:
	pop R13
	pop R12
	pop RBP
	ret

trie_agregar_palabra: ; RDI -> *trie t, RSI -> *char p
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

trie_construir: ; RDI -> char* nombre_archivo
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




	

trie_imprimir: ; RDI -> *trie, RSI -> *char nombre_archivo 

	push RBP
	mov RBP, RSP
	push R12
	push R13
	push R14
	push R15
	push RBX
	sub RSP, 8

	
	mov r12, rsi ; Archivo
	mov r15, rdi ; TRIE

	mov rdi, r12
	mov rsi, modoFOpen ; seteo el modo de abrir el arvhivo
	call fopen

	mov r12, rax ; Guardo el puntero al archivo abierto
	MOV R13, R15 ;con r15 voy a recorrer mi nivel 0 y r13 me guardo el trie para pasarselo a palabras_con_prefijo
	mov R15, [R15 + offset_raiz]
	cmp qword r15, NULL
	JNE .noEsVacia

.esVacia:

	mov rdi, r12
	mov rsi, trieVacio
	mov rax, 1
	call fprintf
	jmp .fin1

.noEsVacia:

	mov RDI, 2 ; malloc de 2 posiciones para crear la palabra de 1 caracter
	call malloc ; RAX = char * palabra_1_char
	mov RBX, RAX ; RBX = RAX = char * palabra_1_char

	call lista_crear
	MOV R14, RAX ;ME GUARDO LA LISTA CREADA Q SE VA A IMPRIMIR

.ciclo:
	CMP qword R15, NULL
	JE .imprimir_palabras

	MOV R8B, [R15+offset_c]
	mov byte [RBX], R8B ; primer letra asigno el char
	mov byte [RBX + 1], NULL ; segunda letra asgino el char nulo

	MOV RDI, R13 ;paso trie completo como primer parametro
	mov rsi, RBX ; asigno el puntero
	call palabras_con_prefijo
	
	MOV RDI, R14 ; paso putnero a la lista creada para imprimir
	MOV RSI, RAX ;LISTA DE palabras_con_prefijo
	call lista_concatenar
	MOV R15,[R15 +offset_sig]
	jmp .ciclo

	.imprimir_palabras:
		mov RDI, R12 ; primer parametro el *fp
		mov RSI, R14 ; segundo parametro la lista *ls
		call reccoroEImprimo
		jmp .fin
	.fin:
		mov RDI, R12 ; cierro archivo
		call fclose
		mov RDI, R14 ; borro la lista que ya no necesito
		call lista_borrar
		mov RDI, RBX ; borro el string creado
		call free
		add RSP, 8
		pop RBX
		pop R15
		pop R14
		pop R13
		pop R12
		pop RBP
		ret



		.fin1:
			mov RDI, R12 ; cierro archivo
			call fclose

			add RSP, 8
			pop RBX
			pop R15
			pop R14
			pop R13
			pop R12
			pop RBP
			ret


reccoroEImprimo: 
;en r12 me guardo el archivo abierto
;en r13 me guardo la lista
	push RBP
	mov RBP, RSP
	push R12
	push R13
	
	mov R12, RDI 
	mov R13, RSI 
	mov R13, [R13 + offset_prim] ; R14 = *ls.prim
	
	.recorroPalabrasEImprimo:
		cmp R13, NULL
		je .fin
		mov RDI, R12  
		mov RSI, string1 
		mov RDX, [R13 + offset_valor] ;esto me da un puntero a char imprimo el string 
		call fprintf
		mov RDI, R12 
		mov RSI, string1 
		mov RDX, espacio ;imprimo el espacio correspondiente
		call fprintf

		mov R13, [R13 + offset_sig_lnodo] ;paso al siguiente nodo y consulto si me quedo con un null en la vuelta
		jmp .recorroPalabrasEImprimo

		.fin:
		; imprimo salto de linea
		mov RDI, R12 
		mov RSI, string1 
		mov RDX, saltoDeLinea 
		call fprintf
		pop R13
		pop R12
		pop RBP
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

trie_pesar: ; RDI-> trie * t, RSI -> funcion pesar_palabra

	push RBP
	mov RBP, RSP
	push R12
	push R13
	push R14
	push R15
	push RBX
	sub RSP, 8

	
	mov r13, rsi ; funcion pesar
	mov r15, rdi ; TRIE

	MOV R12, R15 ;con r15 voy a recorrer mi nivel 0 y r13 me guardo el trie para pasarselo a palabras_con_prefijo
	mov R15, [R15 + offset_raiz]
	cmp qword r15, NULL
	JNE .noEsVacia

	.esVacia:

		xor R13, R13
		cvtsi2sd XMM0, R13
		jmp .fin1

	.noEsVacia:

		mov RDI, 2  
		call malloc 
		mov RBX, RAX 
		call lista_crear
		MOV R14, RAX ;ME GUARDO LA LISTA CREADA Q SE VA A IMPRIMIR

	.ciclo:
		CMP qword R15, NULL
		JE .aLaBalanza

		MOV R8B, [R15+offset_c]
		mov byte [RBX], R8B ; primer letra asigno el char
		mov byte [RBX + 1], NULL ; segunda letra asgino el char nulo

		MOV RDI, R12 
		mov rsi, RBX 
		call palabras_con_prefijo
		
		MOV RDI, R14 
		MOV RSI, RAX 
		call lista_concatenar
		MOV R15,[R15 +offset_sig]
		jmp .ciclo

		.aLaBalanza:
			mov RDI, R14 
			mov RSI, R13  
			call recorroYPeso
			jmp .fin

		.fin:
			mov RDI, R14 ; borro la lista que ya no necesito
			call lista_borrar
			mov RDI, RBX ; borro el string creado
			call free
			add RSP, 8
			pop RBX
			pop R15
			pop R14
			pop R13
			pop R12
			pop RBP
			ret

	.fin1:
		add RSP, 8
		pop RBX
		pop R15
		pop R14
		pop R13
		pop R12
		pop RBP
		ret

recorroYPeso: ; RDI -> listaP* ls, RSI -> funcion pesar
	push RBP
	mov RBP, RSP
	push R12
	push R13
	push R14
	push R15

	mov R12, RDI
	mov R13, RSI
	mov R12, [R12 + offset_prim]

	xor R15, R15
	xorpd xmm2, xmm2
	.sumando:
		; calculo el peso de la palabra
		mov RDI, [R12 + offset_valor]
		call R13
		addsd XMM2, XMM0 
		add R15D, 1 
		mov R12, [R12 + offset_sig_lnodo]
		cmp R12, NULL 
		jne .sumando
		jmp .promedio

	.promedio:
		movdqa XMM0, XMM2 ;suma total en xmm0 
		cvtsi2sd XMM2, R15 ; convierto de entero a double n
		divsd XMM0, XMM2 ; divido suma por n y el resultado queda en XMM0
	
	.fin:
	pop R15
	pop R14
	pop R13
	pop R12
	pop RBP
	ret

palabras_con_prefijo: ; RDI -> trie *t, RSI -> char *prefijo
	push RBP
	mov RBP, RSP
	push R12
	push R13
	push R14
	push R15

	mov R12, [RDI + offset_raiz] ; R12 = t.raiz
	mov R13, RSI ; R13 = char * prefijo
	mov R14, NULL ; R14 = nodo_prefijo = NULL
	call lista_crear
	mov R15, RAX ; creo una lista vacia para las palabras que son como el prefijo

	.ciclo:
		cmp R14, NULL ; if (nodo_prefijo != null) 
		jne .devolver_palabras ; devuelvo las palabras de los hijos del nodo_prefijo
		; sino sigo buscando el nodo_prefijo
		cmp R12, NULL ; if (n == null) devuelvo palabras 
		je .devolver_palabras
		mov RDI, R12 ; sino busco el nodo prefijo de n
		mov RSI, R13 ; segundo parametro prefijo
		call nodo_prefijo
		mov R14, RAX ; R14 = nodo_prefijo(n, prefijo)
		mov R12, [R12 + offset_sig] ; n = n.sig
		jmp .ciclo

	.devolver_palabras:
	cmp R14, NULL ; if (nodo_prefijo == null)
	je .fin

	; agrego las palabra que matchea excatamente con el prefijo
		cmp byte [R14 + offset_fin], TRUE ; si no es el fin de una palabra, fin
		jne .seguir
		; sino agrego la palabra a la lista
		mov RDI, R15 ; primer parametro lista
		mov RSI, R13 ; segundo parametro prefijo
		call lista_agregar
		.seguir:

	mov R14, [R14 + offset_hijos] ; R14 = nodo_prefijo.hijos

	.fin:
		mov RDI, R14 ; primer parametro nodo_prefijo.hijos
		mov RSI, R13 ; segundo parametro prefijo
		call dame_palabras ; RAX = palabras_de_nodo(nodo_prefijo.hijos, prefijo)
		mov RDI, R15 ; concateno la lista de palabras de 1 letra
		mov RSI, RAX ; concateno el resto de las palabras
		call lista_concatenar
		mov RAX, R15 ; devuelvo la lista

	pop R15
	pop R14
	pop R13
	pop R12
	pop RBP
	ret

nodo_buscar:
;nodo *nodo_buscar(nodo *n, char c)
	PUSH RBP
	MOV RBP, RSP
	PUSH R9
	SUB RSP,8
	MOV R9, RDI
	.seguimos:
		CMP byte R9, NULL
		JE .noEsta
		CMP byte [R9 + offset_c], SIL
		JE .esta
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
		ADD RSP,8
		POP R9
		POP RBP
		ret

nodo_prefijo: ; RDI -> *nodo_nivel, RSI-> char * prefijo
	mov R8, RDI ; R8 = nodo *nodo_nivel
	mov R9, RSI  ; R9 = char *prefijo
	mov byte R10b, [R9] ; R10b = primer_char(*prefijo)
	mov R11, NULL ; R11 = nodo_prefijo = NULL

	cmp byte [R8 + offset_c], R10b ; if (nodo_nivel.c != c) devolver nodo null
	jne .devolver_nodo_null
	mov R11, R8 ; nodo_prefijo = nodo_nivel
	mov R8, [R8 + offset_hijos] ; avanzo por hijos 
	lea R9, [R9 + 1] ; avanzo string
	mov byte R10b, [R9] ; R10b = siguiente_char(prefijo)
	cmp R10b, 0 ; if (fin_string) devolver_nodo
	je .devolver_nodo

	.ciclo:
		cmp R10b, 0 ; if (fin_string) devolver_nodo
		je .devolver_nodo
		cmp R8, NULL ; if (nodo_nivel == NULL) devolver nodo null
		je .devolver_nodo_null
		cmp byte [R8 + offset_c], R10b ; if (nodo_nivel.c != c) devolver nodo null
		jne .avanzar_siguiente
		mov R11, R8 ; nodo_prefijo = nodo_nivel
		mov R8, [R8 + offset_hijos] ; avanzo por hijos 
		lea R9, [R9 + 1] ; avanzo string
		mov byte R10b, [R9] ; R10b = siguiente_char(prefijo)
		jmp .ciclo
		.avanzar_siguiente:
		mov R8, [R8 + offset_sig] ; avanzo por siguiente
		jmp .ciclo

	.devolver_nodo_null:
		mov R11, NULL
	.devolver_nodo:
		mov RAX, R11
	ret
	
dame_palabras: ; RDI -> *nodo_nivel, RSI-> char * prefijo
; devuelve una listaP de palabras que terminan a partir de nodo nivel, siguiendo por sus hijos y siguientes,
; concatenadas con un prefijo pasado por parametro  
	push RBP
	mov RBP, RSP
	push R12
	push R13
	push R14
	push R15

	mov R12, RDI ; R12 = nodo* nodo_nivel
	mov R15, RSI ; R15 = char *prefijo

	mov RDI, 1024 ; creo un puntero para una palabra acotada
	call malloc
	mov R14, RAX ; R14 = char* palabra

	mov RDI, R14 ; copio el prefijo en R14
	mov RSI, R15 ; en el segundo parametro pongo el prefijo que quiero copiar
	call copiar_palabra; copiar_palabra(char *dest, const char *src)
	; ahora R14 es una copia de prefijo

	call lista_crear ; creo una lista vacia
	mov R13, RAX ; R13 = ls

	.ciclo:
		cmp R12, NULL
		je .fin
		mov RDI, R14 ; primer parametro char* palabra
		mov SIL, [R12 + offset_c] ; segundo parametro puntero al caracter que quiero concatenar
		call concatenar_caracter ; R14 = palabra = concatenar(palabra, n.c)
		cmp byte [R12 + offset_fin], TRUE ; 	if (!n.fin) seguir buscando la palabra por los hijos
		jne .concatenar_con_palabras_de_hijos
		; if (n.fin) agrego la palabra a la lista
		mov RDI, R13 ; primer parametro ls
		mov RSI, R14 ; segundo parametro char* palabra
		call lista_agregar
		.concatenar_con_palabras_de_hijos:
			mov R10, [R12 + offset_hijos]
			cmp R10, NULL ; if (n.hijos == null) avanzar sino llamo recursivamente a palabras_de_nodo con los hijos
			je .avanzar
			mov RDI, R10 ; primer parametro nodo_nivel.hijos
			mov RSI, R14 ; segundo parametro char* palabra
			call dame_palabras ; RAX = palabras_de_nodo(n.hijos, palabra)

			mov RDI, R13 ; primer parametro ls
			mov RSI, RAX ; segundo parametro palabras_de_nodo(n.hijos, palabra)
			call lista_concatenar

		.avanzar:
			mov RDI, R14 ; copio el prefijo en R14
			mov RSI, R15 ; en el segundo parametro pongo el prefijo que quiero copiar
			call copiar_palabra; copiar_palabra(char *dest, const char *src)
			; ahora R14 es una copia de prefijo
			mov R12, [R12 + offset_sig] ; R12 = nodo_nivel.sig
			jmp .ciclo

	.fin:
		mov RDI, R14 ; borro la palabra
		call free
		mov RAX, R13 ; retorno ls
	pop R15
	pop R14
	pop R13
	pop R12
	pop RBP
	ret
	; ls = lista_crear()
	; palabra = copiar(prefijo)
	; while (n != null) {
	; 	palabra = concatenar(palabra, n.c)
	; 	if (n.fin) {
	; 		lista_agregar(ls, palabra)
	; 	}
	; 	if (n.hijos != null) {
	; 		lista_concatenar(ls, palabras_de_nodo(n.hijos, palabra))
	; 	}
	;	palabra = copiar(prefijo)
	; 	n = n.sig
	; }
	; 
	; borrar(palabra)
	; return ls



nodo_borrar: ; RDI -> nodo* nodo
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


longitud_palabra: ; RDI -> char * palabra
	mov byte R8B, [RDI] ; R8b primer caracter de palabra
	xor R9, R9

	.ciclo:
		cmp R8B, NULL ; si es el caracter nulo, devolver contador
		je .salir
		add R9, 1 ; sumo contador
		mov byte R8B, [RDI + R9] ; avanzo string
		jmp .ciclo

	.salir:
	mov RAX, R9
	ret

copiar_palabra: ; RDI -> char *dest, RSI char *src
	xor R8, R8 ; R8 = 0
	mov R9B, [RSI] ; R9B = primera letra de src

	.ciclo:
		cmp R9B, NULL ; si es caracter nulo, salir
		je .salir
		mov byte [RDI + R8], R9B ; pongo en dest carcater de src
		add R8, 1
		mov R9B, [RSI + R8] ; avanzo string
		jmp .ciclo

	.salir:
		mov byte [RDI + R8], NULL ; pongo el caracter nulo al final del destino
	ret

concatenar_caracter: ; RDI -> char * palabra, RSI char caracter
	mov R8B, [RDI] ; R8B = primer letra de palabra
	xor R9, R9
	.ciclo:
		cmp R8B, NULL ; si es el caracter nulo, concatenar el caracter de parametro
		je .concatenar
		add R9, 1
		mov R8B, [RDI + R9] ; avanzo string
		jmp .ciclo

	.concatenar:
		mov byte [RDI + R9], SIL ; copio el caracter
		mov byte [RDI + R9 + 1], NULL ; pongo el caracter nulo al final
	ret