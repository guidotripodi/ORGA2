#include <stdio.h>
#include "trie.h"
#include "trie_c.c"
extern void trie_imprimir(trie *t, char *nombre_archivo);
extern trie *trie_crear(void);
extern void trie_borrar(trie *t);

int main(void) {
	// COMPLETAR AQUI EL CODIGO
	trie* t = trie_crear();
	trie_borrar(t);
	char* nombre_archivo = "pepito.txt";
	trie_imprimir(t,nombre_archivo);

	printf("compilo y corrioooooooooooooooooooo /n/n");
    return 0;
}

