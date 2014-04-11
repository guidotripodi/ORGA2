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

;etiquetas para impresion 

modoFOpen: db "a", 0
abreLLave: db "{ ", 0
cierraLLave: db " }", 0
abreCorchete: db "[ ", 0
cierraCorchete: db" ]", 0
espacio: db " ", 0
stringVacio: db "", 0
trieVacio: db "<>", 0
saltoDeLinea: DB '%s', 10, 0
vacio: DB '', 0
llaveAbrir: DB '{ ', 0
llaveCerrar: DB ' }', 0
corcheteAbrir: DB '[ ', 0
corcheteCerrar: DB ' ]', 0




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
%define offset_sig_lnodo 0

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
	MOV r15, RAX
	
	
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
	PUSH RCX
	PUSH RDI
	
	MOV RCX, RDI ; COPIO EL CHAR
	MOV RDI, size_nodo ; paso tam del nodo
	Call malloc ; recibo en rax el puntero
	
	
	MOV qword [RAX], NULL ; el siguiente nodo a este es NULL
	MOV qword [RAX+offset_hijos], NULL ; como estoy creando un nodo no tengo hijo = NULL
	MOV [RAX + offset_c], CL, ;guardo el char
	MOV byte[RAX + offset_fin], FALSE; palabra no termina
	
	POP RDI
	POP RCX
	POP RBP
	RET
insertar_nodo_en_nivel:
	;RDI DIRECCION DEL 1er NODO de ese nivel; esto apunta a hijos del padre
	;RSI CHAR que tengo que agregar
	push RBP
	mov RBP, RSP
	push RBX
	push RDI
	push RSI
	push R13
	push R14
	push R15
	mov R13, RDI ; copio puntero del nodo
	mov R14, R13 
	mov RDI, RSI ;paso char a rdi para crear nodo
	cmp qword [R13], NULL
	je .nivelVacio ; en caso que mi trie inicie vacio o me pasen un puntero a hijos del padre null
	.ciclo:
		cmp [R14+offset_c], SIL ; lo comparo con el char que esta en RSI  
		jg .agregoPrimero ; si es menor va primero y no tengo anterior
		cmp [R14 + offset_sig], SIL; si es igual lo doy y temine
		je .noAgrego
		cmp qword [R14+offset_sig], NULL ; si el siguiente nodo esta vacio agrego al nuevo al final significando q es el mayor a todos
		je .agregoUltimo
		MOV R15, [R14+offset_sig] ; es el siguiente nodo
		cmp [R15+offset_c], SIL ; lo comparo con el sig nodo
		jg .agregoIntercalado
		mov R14, [R14+offset_sig]
		jmp .ciclo
		
	
	.noAgrego:
		mov RAX, [R14]
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
	.agregoIntercalado:
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
		pop RSI
		pop RDI
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
	push RSI ; pila al
	push RDI ;pila des
	Push R13 ;pila al
	mov R13, RSI ;copio el puntero a char de RSI a R10
	
	.agregoPalabra:
	mov byte SIL, [R13]
	call insertar_nodo_en_nivel ;RAX = el nodo de la letra agregada

	lea RDI, [RAX+offset_hijos] ; voy al nivel de abajo
	MOV RSI, R13
	lea R13, [RSI+1] ; voy a la siguiente letra a agregar
	XOR RSI, RSI
	MOV byte SIL, [R13]
	cmp byte SIL, NULL
	jne .agregoPalabra
	MOV QWORD [RAX+offset_fin], TRUE
	
	.fin:
	pop R13
	pop RDI
	pop RSI
	pop RBX
	pop RBP
	ret

trie_construir:
;trie *trie_construir(char *nombre_archivo)
	
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
	mov r13, [r15]

.esVacia:

	mov rdi, r12
	mov rsi, trieVacio
	mov rax, 1
	call fprintf

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

.noEsVacia:

	mov rdi, r15 ; Nodo
	mov rsi, r12 ; Puntero al archivo
	;call rama_imprimir ; Imprime al nodo con todos sus hijos
	
	cmp qword [r15 + offset_sig], NULL
	je .terminarArchivo
	mov rdi, r12
	mov rsi, espacio
	mov rax, 1
	call fprintf
	
	mov r15, [r15 + offset_sig]
	jmp .noEsVacia


rama_imprimir:

	push rbp ; Pila Alineada
	mov rbp, rsp
	push r12 ; Pila Desalineada
	push r15 ; Pila Alineada

	mov r12, rsi ; Archivo
	mov r15, rdi ; Nodo
	
	mov rdi, r12
	mov rsi, abreLLave
	mov rax, 1
	call fprintf

.imprimirDescendientes:

	mov rdi, r15
	mov rsi, r12
	call nodo_imprimir
	
	cmp qword [r15 + offset_hijos], NULL
	je .cerrar
	lea r15, [r15 + offset_hijos]
	call .imprimirDescendientes

.cerrar:

	mov rdi, r12
	mov rsi, cierraLLave
	mov rax, 1
	call fprintf

	pop r15
	pop r12
	pop rbp
	ret

nodo_imprimir:

	push rbp ; Pila Alineada
	mov rbp, rsp
	push r12 ; Pila Desalineada
	push r15 ; Pila Alineada

	mov r12, rsi ; Guardo el puntero al archivo
	mov r15, rdi ; Guardo el puntero al nodo
	
	mov rdi, r12
	mov rsi, abreCorchete
	mov rax, 1
	call fprintf

	mov rdi, r12
	lea r15, [r15 + offset_c]
	;mov rsi, [r15]
	mov rax, 1
	call fprintf

.cerrar:

	mov rdi, r12
	mov rsi, cierraCorchete
	mov rax, 1
	call fprintf

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
.continuo:
	MOV R15, RSI  ;COPIO EL PUNTERO
	XOR RSI, RSI ; LIMPIO RSI
	MOV byte SIL, [R15] ; se lo copio a la parte baja de rsi
	call nodo_buscar 
	CMP qword [RAX], NULL ;si no esta un nodo termino
	JE .noEsta
	MOV RAX, [RAX + offset_hijos] ; si encontro el nodo voy bajando al hijo
	MOV RDI, RAX 
	MOV R14, [R15+1]  ; voy a la siguiente letra a buscar
	MOV R15, R14
	XOR RSI, RSI
	MOV byte SIL, [R15]
	cmp byte SIL, NULL
	JNE .siguePalabra
.siEsta:
	MOV qword RAX, TRUE
	POP R14
	POP R15
	POP RBP
	RET

.siguePalabra:
	CMP qword [RDI], NULL ;antes de continuar chequeo que queden hijos que puedan continuar la palabra
	JE .noEsta
	MOV RSI, [R15+1]
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
	PUSH RDI
	PUSH RSI
	PUSH R15
	SUB RBP,8
	MOV R15, RDI
	CMP qword [RDI], NULL
	JE .fin
	.seguimos:
		CMP [RDI + offset_c], SIL
		JE .fin
		MOV RDI, [RDI + offset_sig]
		CMP qword [RDI], NULL
		JNE .seguimos
	.fin:
		MOV qword RAX, RDI ;devuelvo null o el nodo
		ADD RBP, 8
		POP R15
		POP RSI
		POP RDI
		POP RBP
		ret


trie_pesar:
	
palabras_con_prefijo:

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
	XOR RSI, RSI
	MOV SIL, [R14]
	call nodo_buscar
	CMP qword [RAX], NULL
	JE .fin ;si no encuentra ni el primero es que no tiene prefijo
	MOV RAX, [RAX + offset_hijos] ; si encontro el nodo voy bajando al hijo
	MOV RDI, RAX 
	ADD R14, 1
	CMP byte [R14], NULL
	JE .hastaElAnterior
	.ciclo:
		MOV SIL ,[R14]	
		call nodo_buscar ;busco el segundo caracter, el primero lo busco fuera del ciclo, si ingreso es q el primero esta
		CMP qword [RAX], NULL
		JE .fin ; si da null NO ES PREFIJO DE NADA, CONSULTARLO IGUAL
		CMP qword [RAX + offset_sig], NULL
		JNE .hastaElAnterior
		CMP BYTE [R14 + 1], NULL
		JNE .sigoGirando
		jmp .fin
		

		.sigoGirando:
			MOV R15,RDI
			MOV RAX, [RAX + offset_hijos]
			MOV RDI, RAX
			ADD R14, 1
			jmp .ciclo

	.hastaElAnterior:
		MOV RAX, R15
		jmp .fin






.fin:
	ADD RBP, 9
	POP R13
	POP R15
	POP R14
	POP RSP
	RET