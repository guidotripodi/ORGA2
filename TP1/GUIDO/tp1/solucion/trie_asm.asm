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

%define size_nodo 0

%define offset_raiz 0

%define size_trie 0

%define offset_prim 0

%define offset_valor 0
%define offset_sig_lnodo 0

%define NULL 0

%define FALSE 0
%define TRUE 0

section .rodata

section .data

section .text

; FUNCIONES OBLIGATORIAS. PUEDEN CREAR LAS FUNCIONES AUXILIARES QUE CREAN CONVENIENTES

trie_crear(void):
	raiz = new Nodo; COMPLETAR AQUI EL CODIGO//pasr a asm

trie_borrar(trie *t):
	delete t->raiz;COMPLETAR AQUI EL CODIGO
	raiz = NULL;

*nodo_crear(char c):
	Nodo* nodo = raiz; // creo q el tipo es NODO o nodo_t 
	Nodo* temp;
	string::const_iterator it = c.begin(); //uso iterador en c q uso en asm?
	while(it < c.end()){
		int i = numero(*it);
		temp = nodo->elems[i];
		if(temp == NULL){
			temp = new Nodo;
			nodo->elems[i] = temp;
		}
		nodo = temp;
		it++;
	}
	nodo->c = c;
	nodo->fin = true;//chequear bien nombres y valores

insertar_nodo_en_nivel(nodo **nivel,char c)
	if(estaEnNivel(nivel,c))
	{ 
		Nodo* encontrado = nodo_buscar(nodo *n, char c);
	}
	else
	{
		;//HAY Q GUARDARLO EN EL NIVEL O DONDE LE CORRESPONDA?	
	}

; COMPLETAR AQUI EL CODIGO

trie_agregar_palabra:
	; COMPLETAR AQUI EL CODIGO

trie_construir:
	; COMPLETAR AQUI EL CODIGO

trie_imprimir:
	; COMPLETAR AQUI EL CODIGO

buscar_palabra:
	; COMPLETAR AQUI EL CODIGO

trie_pesar:
	; COMPLETAR AQUI EL CODIGO

palabras_con_prefijo:
	; COMPLETAR AQUI EL CODIGO

