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
	MOV RDI, size_trie ; le paso el tamaño del trie 
	call malloc
	MOV [RAX], NULL
		
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
