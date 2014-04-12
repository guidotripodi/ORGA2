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
extern trie *trie_construir(char *nombre_archivo);


int main(void) {
	// COMPLETAR AQUI EL CODIGO
	trie* t = trie_crear();
	//nodo* n = nodo_crear('a');
	char* nombre_archivo = "andaporfavor.txt";
	char* e1 = "hola";
	char* e2 = "casa";
	trie_agregar_palabra(t,e1);
	char* e = "casco";
	char* e3 = "apa";
	trie_agregar_palabra(t,e);
	trie_agregar_palabra(t,e2);
	trie_agregar_palabra(t,e3);
	trie_imprimir(t,nombre_archivo);
	bool b = buscar_palabra(t,e1); 
	trie_construir(nombre_archivo);


	char buffer[1025];
 	FILE *fp;
 	fp = fopen ( "andaporfavor.txt", "r" );
  	fscanf(fp, "%s" ,buffer);
 	printf("%s",buffer);
 	fscanf(fp, "%s" ,buffer);
 	printf("%s",buffer);
  	fclose ( fp );
	


	printf("Valor: %d",b);
	

    return 0;
}

