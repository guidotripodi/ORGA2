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
	PUSH r14
	SUB RBP,8
	
	MOV DL, DIL ; COPIO EL CHAR
	MOV RDI, size_nodo ; paso tam del nodo
	Call malloc ; recibo en rax el puntero
	
	
	MOV qword [RAX], NULL ; el siguiente nodo a este es NULL
	MOV qword [RAX+offset_hijos], NULL ; como estoy creando un nodo no tengo hijo = NULL
	MOV [RAX + offset_c], DL, ;guardo el char
	MOV byte[RAX + offset_fin], FALSE; palabra no termina
		
	ADD RBP,8
	POP R14
	POP RBP
	RET

insertar_nodo_en_nivel:
;nodo *insertar_nodo_en_nivel(nodo **nivel, char c)
	PUSH rbp
	MOV rbp, rsp
	CALL nodo_buscar
	CMP qword [RAX], NULL
	JNE .fin
	call .agregarNodo
.fin:
	MOV RDI, RAX
	POP RBP
	RET

.agregarNodo:
	; en rdi tengo el puntero al nodo con a su ves el puntero a los hijos de este
	;en sil tengo el caracter del nodo q tengo q agregar
	PUSH R15
	PUSH R14
	PUSH R13
	MOV R15, RDI ; COPIO EL PUNTERO
	MOV DIL, SIL ; 
	CMP [R15 + offset_c], SIL
	JL nodo_crear
	MOV RDI, R15 ;copio el puntero por si me dirijo a arreglo puntero
	;MOV SIL, R14L
	CMP [RAX + offset_c], SIL ;si rax.c es SIL eso significa q me inserto el nuevo nodo
	JE .arregloPuntero
	MOV RDX, R15 ;copio la posicion futura "anterior" para dsp arreglar punteros si queda el nuevo nodo en el medio
	CMP qword[R15+offset_sig], NULL
	JNE .sigueGirando ;si no es null continuo la reccorida por el nivel
	MOV DIL, SIL ;si termino significa que el nodo q agrego es mayor a todos los q estan en el nivel y lo agrego al final
	call nodo_crear
	RET

.sigueGirando:
	lea r15, [r15 + offset_sig] 
	MOV RDI, R15
	call .agregarNodo
	ret

.arregloPuntero:

	CMP RDX, RDI
	JE .noHayAnterior
	
	Mov r13, rdi ; muevo el futuro siguiente al nuevo nodo agregado
	MOV r14, rdx; muevo el anterior
	
	MOV [RAX+offset_sig], R13
	MOV [RDX+offset_sig], RAX
	POP R13
	POP R14
	POP R15
	call .fin
	RET

.noHayAnterior:
	
	Mov r13, rdi ; muevo el siguiente
	MOV [RAX+offset_sig], R13
	POP R13
	POP R14
	POP R15
	CALL .fin
	RET



nodo_buscar:
;nodo *nodo_buscar(nodo *n, char c)
	PUSH R15
	PUSH R14
	PUSH R13
	MOV R15, RDI
	;MOV R14L, SIL
	CMP [R15 + offset_c], SIL
	JE .fin
	lea R13, [R15 + offset_sig]
	CMP qword[R13], NULL
	;JNE .sigueGirando
.fin:
	MOV RAX, R13 ;devuelvo null o el nodo
	POP R13
	POP R14
	POP R15
	ret
.sigueGirando:
	lea r15, [r15 + offset_sig] 
	MOV RDI, R15
	;MOV SIL, R14L
	call nodo_buscar
	ret



	
	
trie_agregar_palabra:
;void trie_agregar_palabra(trie *t, char *p)
	push rbp ; Pila des
	mov rbp, rsp
	;push r15
	;push r14
	MOV R15, RSI ; GUARDO EL PUNTERO A CHAR
	MOV R14, RDI ; GUARDO EL TRIE
	CMP qword[RDI], NULL
	je .PrimerNodo
	MOV RDI, RDI
	MOV SIL,[R15]
	call insertar_nodo_en_nivel
	CMP qword[R14 + offset_hijos], NULL
	JNE .sigoAgregando
	call .nuevosNiveles
.fin:
	pop r15
	pop r14
	pop rbp
	ret

.PrimerNodo:
	;en rdi traigo el TRIE y en rsi el PUNTERO A CHAR
	PUSH R15
	PUSH R14
	PUSH R13
	MOV R15, RDI
	MOV R14B, [RSI]
	MOV RDI, size_nodo
	call malloc

	Mov qword [rax +offset_sig], NULL
	MOV qword [rax +offset_hijos], NULL
	MOV [rax +offset_c], R14B
	MOV byte [rax + offset_fin], FALSE
	
	MOV RDI, R15
	MOV [RDI], RAX
	POP R13
	POP R14
	POP R15
	Pop rbp
	ret


.sigoAgregando:
	
	CMP byte [R15+1], 0
	JE .elUltimo
	LEA RDI, [RDI + offset_hijos]
	MOV SIl, [R15+1]
	call trie_agregar_palabra
	ret

.elUltimo:
	;rdi el trie
	;rsi el *char
	MOV R14, RDI
	MOV RDI, size_nodo ; le doy el tamaño al nodo
	CALL malloc
	
	MOV qword[Rax+offset_sig], NULL
	MOV qword [Rax+offset_hijos], NULL
	MOV [RAX+offset_c], sil
	MOV byte [RAX+offset_fin], TRUE
	
	MOV [R14+offset_hijos],RAX
	call .fin
	pop rbp
	ret
	
.nuevosNiveles:
	CMP byte [R15+1], 0
	JE .elUltimo
	MOV SIl, [R15+1]
	
	;rdi el trie
	;rsi el *char
	MOV R15, RDI
	MOV RDI, size_nodo ; le doy el tamaño al nodo
	CALL malloc
	
	MOV qword[Rax+offset_sig], NULL
	MOV qword [Rax+offset_hijos], NULL
	MOV [RAX+offset_c], SIl
	MOV byte [RAX+offset_fin], TRUE
	
	MOV [R14+offset_hijos],RAX
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



	

buscar_palabra:
;bool buscar_palabra(trie *t, char *p)
	PUSH RBP
	MOV RBP, RSP
	PUSH R15
.continuo:
	MOV R15B, [RSI]  ;paso el primer char
	MOV SIL, R15B ; se lo copio a la parte baja de rsi
	call nodo_buscar 
	CMP qword [RAX], NULL ;si no esta un nodo termino
	JE .noEsta
	LEA RAX, [RAX + offset_hijos] ; si encontro el nodo voy bajando al hijo
	MOV RDI, RAX 
	CMP byte [RSI +1], 0 ; si la palabra a buscar no termino sigo
	JE .siguePalabra
.siEsta:
	MOV qword RAX, TRUE
	;MOV DIL, TRUE
	POP R15
	POP RBP
	RET

.siguePalabra:
	CMP qword [RDI], NULL ;antes de continuar chequeo que queden hijos que puedan continuar la palabra
	JE .noEsta
	LEA RSI, [RSI+1]
	call .continuo
	ret

.noEsta:
	MOV qword RAX, FALSE
	;MOV DIL, FALSE
	POP R15
	POP RBP
	RET

trie_pesar:
	
palabras_con_prefijo:
	
