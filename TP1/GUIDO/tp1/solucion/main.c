#include <stdio.h>
#include "trie.h"
#include "trie_c.c"
extern void trie_imprimir(trie *t, char *nombre_archivo);

int main(void) {
	// COMPLETAR AQUI EL CODIGO
	trie* t;
	char* nombre_archivo = "pepito.txt";
	trie_imprimir(t,nombre_archivo);

	printf("compilo y corrioooooooooooooooooooo");
    return 0;
}

