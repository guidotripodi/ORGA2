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
extern malloc
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
saltoLinea: DB '%s', 10, 0



; SE RECOMIENDA COMPLETAR LOS DEFINES CON LOS VALORES CORRECTOS
%define offset_sig 0
%define offset_hijos 8
%define offset_c 17
%define offset_fin 18

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
	PUSH r15
	PUSH r14
	MOV r15, rdi
	MOV rsi, size_nodo
	CALL malloc
	MOV r14, rax
	MOV qword[r14 + offset_sig], NULL
	MOV qword[r14 + offset_hijos], NULL
	MOV [r14 + offset_c], rdi
	MOV qword[r14 + offset_fin], FALSE
	POP r14
	POP r15
	POP rbp	
	ret

insertar_nodo_en_nivel:
;nodo *insertar_nodo_en_nivel(nodo **nivel, char c)
		PUSH RBP
	MOV RBP,RSP
	call nodo_buscar


;nodo *nodo_buscar(nodo *n, char c)
nodo_buscar:
	PUSH RBP
	MOV RBP,RSP
	PUSH R15
	PUSH R14
	MOV R15, RDI
	MOV R14, RSI
	CMP [R15 + offset_c], R14 
	je .nodoSi
	CMP dword [R15 + offset_sig], NULL
	je .nodoNo
	lea r15, [R15 + offset_sig]
	call nodo_buscar
	POP R15
	POP R14
	POP RBP
	RET
; ESTOS 3 ME PARECE Q ESTAN AL PEDO YA QUE NUNCA LLEGARIA ACA


.nodoSi:
	MOV RDI, [R15]
	POP R15
	POP R14
	RET
.nodoNo:
;COMPLETAR CODIDO PARA AGREGARLO LEXICOBLABLA
	POP R14
	POP R15	
	RET










trie_agregar_palabra:
;void trie_agregar_palabra(trie *t, char *p)
		PUSH RBP
	MOV RBP,RSP
	
	; COMPLETAR AQUI EL CODIGO

	RET
	
trie_construir:
;trie *trie_construir(char *nombre_archivo)
		PUSH RBP
	MOV RBP,RSP
	
	; COMPLETAR AQUI EL CODIGO

	POP RBP
	RET
	
trie_imprimir:
;void trie_imprimir(trie *t, char *nombre_archivo)
	push rbp ; Pila Alineada
	mov rbp, rsp
	push r12 ; Pila Desalineada
	push r13 ; Pila Alineada

	mov r12, rsi ; Archivo
	mov r13, rdi ; trie

	mov rdi, r12
	mov rsi, modoFOpen ; seteo el modo de abrir el arvhivo
	call fopen

	mov r12, rax ; Guardo el puntero al archivo abierto

	cmp qword [r13], NULL
	je .esVacia
	
.esVacia:

	mov rdi, r12
	mov rsi, trieVacio
	mov rax, 1
	call fprintf

.terminarArchivo:

	mov rdi, r12
	mov rsi, saltoLinea
	mov rdx, stringVacio
	mov rax, 1
	call fprintf

	mov rdi, r12
	call fclose

	pop r13
	pop r12
	pop rbp	
	ret

; ~ void rama_imprimir(nodo_t *self, char *archivo)
rama_imprimir:

	push rbp ; Pila Alineada
	mov rbp, rsp
	push r12 ; Pila Desalineada
	push r13 ; Pila Alineada

	mov r12, rsi ; Archivo
	mov r13, rdi ; Nodo
	
	mov rdi, r12
	mov rsi, abreLLave
	mov rax, 1
	call fprintf

.cerrar:

	mov rdi, r12
	mov rsi, cierraLLave
	mov rax, 1
	call fprintf

	pop r13
	pop r12
	pop rbp
	ret






buscar_palabra:
		PUSH RBP
	MOV RBP,RSP

	; COMPLETAR AQUI EL CODIGO
POP RBP
	RET
trie_pesar:
		PUSH RBP
	MOV RBP,RSP

	; COMPLETAR AQUI EL CODIGO
POP RBP
	RET
palabras_con_prefijo:
		PUSH RBP
	MOV RBP,RSP

	; COMPLETAR AQUI EL CODIGO
POP RBP
	RET
