#include <stdio.h>
#include "trie.h"
#include "trie_c.c"
extern void trie_imprimir(trie *t, char *nombre_archivo);
extern trie *trie_crear(void);
extern void trie_borrar(trie *t);
extern nodo *nodo_crear(char c);
nodo *insertar_nodo_en_nivel(nodo **nivel, char c);

int main(void) {
	// COMPLETAR AQUI EL CODIGO
	trie* t = trie_crear();
	nodo* n = nodo_crear('a');
//	nodo* n2 = nodo_crear('b');
//	trie_borrar(t);
	nodo* m = insertar_nodo_en_nivel(&n ,'a');
	char* nombre_archivo = "andaporfavor.txt";
	trie_imprimir(t,nombre_archivo);

	printf("compilo y corrioooooooooooooooooooo /n/n");
    return 0;
}

