#include <stdio.h>
#include "trie.h"
//#include "trie_c.c"
//#include "listaP.h"
//#include "listaP.c"

extern void trie_imprimir(trie *t, char *nombre_archivo);
extern trie *trie_crear(void);
extern void trie_borrar(trie *t);
extern nodo *nodo_crear(char c);
extern nodo *insertar_nodo_en_nivel(nodo **nivel, char c);
extern void trie_agregar_palabra(trie *t, char *p);
extern bool buscar_palabra(trie *t, char *p);
extern nodo *nodo_buscar(nodo *n, char c);

int main(void) {
	// COMPLETAR AQUI EL CODIGO
	trie* t = trie_crear();
	//nodo* n = nodo_crear('a');
	char* e = "hola";
	trie_agregar_palabra(t,e);
	char* nombre_archivo = "andaporfavor.txt";
	char* e1 = "ala";
	//char* e2 = "alambre";
	trie_agregar_palabra(t,e1);
	//trie_agregar_palabra(t,e2);
	trie_imprimir(t,nombre_archivo);
	bool b = true;//buscar_palabra(t,e1);
		printf("Valor: %d",b);
	

    return 0;
}

