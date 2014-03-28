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
extern fopen
fileName db "exportado1.txt",10
fileMode db "a",10

; SE RECOMIENDA COMPLETAR LOS DEFINES CON LOS VALORES CORRECTOS
%define offset_sig 0
%define offset_hijos 0
%define offset_c 0
%define offset_fin 0

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
	PUSH RBP
	MOV RBP,RSP
	xor RAX, RAX ; limpio rax
	MOV RDI, [size_trie] ; le paso el tamaño del trie 
	call malloc
	MOV Dword [RAX], NULL ; puntero a null
	MOV RSI, RAX
	POP RBP
	RET
trie_borrar:
	PUSH RBP
	MOV RBP,RSP
	PUSH RBX
	PUSH R12
	PUSH R13
	PUSH R14
	PUSH R15
	; COMPLETAR AQUI EL CODIGO
	POP R15
	POP R14
	POP R13
	POP R12
	POP RBX
	POP RBP
	RET
nodo_crear:
		PUSH RBP
		PUSH RDI
	MOV RBP,RSP
	xor RAX, RAX ; limpio rax
	MOV RDI, [size_nodo] ; le paso el tamaño del NODO 
	call malloc
	MOV RSI, RAX
	POP RDI
	MOV DWORD [RSI], NULL
	MOV DWORD [RSI+8], NULL
	MOV [RSI+16], RDI
	MOV BYTE [RSI+17], FALSE ; puntero a null
	POP RBP
	RET
insertar_nodo_en_nivel:
		PUSH RBP
	MOV RBP,RSP
	PUSH RBX
	PUSH R12
	PUSH R13
	PUSH R14
	PUSH R15
	; COMPLETAR AQUI EL CODIGO
	POP R15
	POP R14
	POP R13
	POP R12
	POP RBX
	POP RBP
	RET
trie_agregar_palabra:
		PUSH RBP
	MOV RBP,RSP
	PUSH RBX
	PUSH R12
	PUSH R13
	PUSH R14
	PUSH R15
	; COMPLETAR AQUI EL CODIGO
	POP R15
	POP R14
	POP R13
	POP R12
	POP RBX
	POP RBP
	RET
trie_construir:
		PUSH RBP
	MOV RBP,RSP
	PUSH RBX
	PUSH R12
	PUSH R13
	PUSH R14
	PUSH R15
	; COMPLETAR AQUI EL CODIGO
	POP R15
	POP R14
	POP R13
	POP R12
	POP RBX
	POP RBP
	RET
trie_imprimir:
	;PUSH RBP
	;MOV RBP,RSP
	;MOV R8, RDI
	;MOV RDI, RSI
	;MOV RDX, [tipo]
	;CALL fopen
	
	 mov rax, fileMode
    push rax
    mov rax, rsi
    push rax
    call fopen                
    mov rbx, rax ;store file pointer

	
	
	;POP RBP
	RET
buscar_palabra:
		PUSH RBP
	MOV RBP,RSP
	PUSH RBX
	PUSH R12
	PUSH R13
	PUSH R14
	PUSH R15
	; COMPLETAR AQUI EL CODIGO
	POP R15
	POP R14
	POP R13
	POP R12
	POP RBX
	POP RBP
	RET
trie_pesar:
		PUSH RBP
	MOV RBP,RSP
	PUSH RBX
	PUSH R12
	PUSH R13
	PUSH R14
	PUSH R15
	; COMPLETAR AQUI EL CODIGO
	POP R15
	POP R14
	POP R13
	POP R12
	POP RBX
	POP RBP
	RET
palabras_con_prefijo:
		PUSH RBP
	MOV RBP,RSP
	PUSH RBX
	PUSH R12
	PUSH R13
	PUSH R14
	PUSH R15
	; COMPLETAR AQUI EL CODIGO
	POP R15
	POP R14
	POP R13
	POP R12
	POP RBX
	POP RBP
	RET
