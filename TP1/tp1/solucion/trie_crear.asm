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
	SUB RBP,8
	
	MOV rdi, size_trie
	CALL malloc
	MOV qword[rax], NULL
	MOV r15, RAX
	
	ADD RBP,8
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
	PUSH r14
	PUSH r13
	PUSH R15
	
	MOV R14, RDI ; COPIO EL CHAR
	MOV RDI, size_nodo ; paso tam del nodo
	Call malloc ; recibo en rax el puntero
	
	POP R15
	MOV qword [RAX], NULL ; el siguiente nodo a este es NULL
	MOV qword [RAX+offset_hijos], NULL ; como estoy creando un nodo no tengo hijo = NULL
	MOV [RAX + offset_c], r14, ;guardo el char
	MOV byte[RAX + offset_fin], FALSE; palabra no termina
	MOV R15, RAX
	
	POP R13
	POP R14
	POP RBP
	RET

insertar_nodo_en_nivel:
;nodo *insertar_nodo_en_nivel(nodo **nivel, char c)
	CALL nodo_buscar
	ret
nodo_buscar:
;nodo *nodo_buscar(nodo *n, char c)
	MOV R15, RDI
	MOV R14, RSI
	CMP [R15 + offset_c], R14 
	je .nodoSi
	CMP [R15 + offset_c], R14
	JL .agregarNodo
	Mov RDX, R15
	CMP qword[R15 + offset_sig], NULL; NO ENTIENDE EL NULL O LA MEMORIA NO TIENE NULL EN EL RESTO
	JNE .sigueGirando
	call .agregarNodo
	ret
	
.sigueGirando:
	lea r15, [r15 + offset_sig] 
	MOV RDI, R15
	MOV RSI, R14
	call nodo_buscar
	ret
.nodoSi:
	MOV RDI, R15 
	RET

.agregarNodo:
	; en rdi tengo el nodo siguiente
	;en rsi tengo el caracter del nodo q tengo q agregar
	; en rdx tengo el nodo anterior si es que hay anterior
	CMP RDX, RDI
	JE .noHayAnterior
	
	Mov r13, rdi ; muevo el siguiente
	MOV r14, rdx; muevo el anterior
	MOV R15, rsi; muevo el caracter
	MOV RDI, size_nodo ; le doy el tamaño al nodo
	CALL malloc
	
	MOV [RAX+offset_sig], R13
	MOV  qword [RAX+offset_hijos], NULL
	MOV [RAX+offset_c], R15
	MOV byte [RAX+offset_fin], FALSE
	
	MOV [RDX+offset_sig], RAX

	RET

.noHayAnterior:
	
	Mov r13, rdi ; muevo el siguiente
	MOV r14, rdx; muevo el anterior
	MOV R15, rsi; muevo el caracter
	MOV RDI, size_nodo ; le doy el tamaño al nodo
	CALL malloc
	
	MOV [RAX+offset_sig], R13
	MOV qword [RAX+offset_hijos], NULL
	MOV [RAX+offset_c], R15
	MOV byte [RAX+offset_fin], FALSE

	RET
	
	
trie_agregar_palabra:
;void trie_agregar_palabra(trie *t, char *p)
	push rbp ; Pila des
	mov rbp, rsp
	sub rbp,8; al
	MOV RDI,[RDI]; 
	MOV RSI, [RSI]
	call insertar_nodo_en_nivel
	CMP qword[RDI + offset_hijos], NULL
	JNE .sigoAgregando
	call .nuevosNiveles
	pop rbp
	add rbp,8
	ret
	
.sigoAgregando:
	
	CMP byte [RSI+1], 0
	JE .elUltimo
	LEA RDI, [RDI + offset_hijos]
	MOV RSI, [RSI+1]
	add rbp,8
	pop rbp
	call trie_agregar_palabra
	ret

.elUltimo:
	;rdi el trie
	;rsi el *char
	MOV R15, RDI
	MOV RDI, size_nodo ; le doy el tamaño al nodo
	CALL malloc
	
	MOV qword[Rax+offset_sig], NULL
	MOV qword [Rax+offset_hijos], NULL
	MOV [RAX+offset_c], RSI
	MOV byte [RAX+offset_fin], TRUE
	
	MOV [R15+offset_hijos],RAX
	add rbp,8
	pop rbp
	ret
	
.nuevosNiveles:
	CMP byte [RSI+1], 0
	JE .elUltimo
	MOV RSI, [RSI+1]
	
	;rdi el trie
	;rsi el *char
	MOV R15, RDI
	MOV RDI, size_nodo ; le doy el tamaño al nodo
	CALL malloc
	
	MOV qword[Rax+offset_sig], NULL
	MOV qword [Rax+offset_hijos], NULL
	MOV [RAX+offset_c], RSI
	MOV byte [RAX+offset_fin], TRUE
	
	MOV [R15+offset_hijos],RAX
	add rbp,8
	pop rbp
	ret

	
trie_construir:
;trie *trie_construir(char *nombre_archivo)
	
trie_imprimir:
;void trie_imprimir(trie *t, char *nombre_archivo)
	push rbp ; Pila Alineada
	mov rbp, rsp
	push r12 ; Pila Desalineada
	push r15 ; Pila Alineada
	sub rbp, 8
	
	mov r12, rsi ; Archivo
	mov r15, rdi ; TRIE

	mov rdi, r12
	mov rsi, modoFOpen ; seteo el modo de abrir el arvhivo
	call fopen

	mov r12, rax ; Guardo el puntero al archivo abierto
	
	cmp qword [r15 + offset_c], NULL
	JNE .noEsVacia

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

	ADD rbp,8
	pop r15
	pop r12
	pop rbp	
	ret

.noEsVacia:

	mov rdi, r15 ; Nodo
	mov rsi, r12 ; Puntero al archivo
	call rama_imprimir ; Imprime al nodo con todos sus hijos
	
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
	push r13 ; Pila Alineada

	mov r12, rsi ; Archivo
	mov r13, rdi ; Nodo
	
	mov rdi, r12
	mov rsi, abreLLave
	mov rax, 1
	call fprintf

.imprimirDescendientes:

	mov rdi, r13
	mov rsi, r12
	call nodo_imprimir
	
	cmp qword [r13 + offset_hijo], NULL
	je .cerrar
	mov r13, [r13 + offset_hijo]
	jmp .imprimirDescendientes

.cerrar:

	mov rdi, r12
	mov rsi, cierraLLave
	mov rax, 1
	call fprintf

	pop r13
	pop r12
	pop rbp
	ret

; ~ void nodo_imprimir(nodo_t *self, char *archivo)
nodo_imprimir:

	push rbp ; Pila Alineada
	mov rbp, rsp
	push r12 ; Pila Desalineada
	push r13 ; Pila Alineada

	mov r12, rsi ; Guardo el puntero al archivo
	mov r13, rdi ; Guardo el puntero al nodo
	
	mov rdi, r12
	mov rsi, abreCorchete
	mov rax, 1
	call fprintf

	mov rdi, r12
	mov rsi, printInt
	mov rdx, [r13 + offset_c]
	mov rax, 1
	call fprintf
	jmp .cerrar

.cerrar:

	mov rdi, r12
	mov rsi, cierraCorchete
	mov rax, 1
	call fprintf

	pop r13
	pop r12
	pop rbp
	ret





	
	
	
	
	
	
	
	
	
	
	
	
	

buscar_palabra:
	
trie_pesar:
	
palabras_con_prefijo:
	
