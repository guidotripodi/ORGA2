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
extern double trie_pesar(trie *t, double (*funcion_pesaje)(char*));
extern listaP *palabras_con_prefijo(trie *t, char *prefijo);

int main(void) {
	// COMPLETAR AQUI EL CODIGO
	trie* t = trie_crear();
	//nodo* n = nodo_crear('a');
	char* nombre_archivo = "andaporfavor.txt";
	char* nombre_archivo1 = "andaporfavor1.txt";
	char* e1 = "hola";
	char* e2 = "casa";
	trie_agregar_palabra(t,e2);
	char* e = "casco";
	char* e3 = "cata";
	trie_agregar_palabra(t,e);
	trie_agregar_palabra(t,e3);
	
	/********************************
	trie_imprimir
	********************************/

	trie_imprimir(t,nombre_archivo);

	/*************************************
	busca_palabras: 
	**************************************/
	bool b = buscar_palabra(t,e1); 

	/*************************************
	construir: 
	**************************************/
	trie* t1 = trie_crear();
	t1 = trie_construir(nombre_archivo); 

	/*************************************
	palabra_prefijo: 
	**************************************/
	listaP* l2 = lista_crear();
	char* e4 = "c";
	listaP* l3 = lista_crear();
	char* e5 = "h";
	listaP* l4 = lista_crear();
	char* e6 = "cat";
	listaP* l5 = lista_crear();
	char* e7 = "ca";
	listaP* l6 = lista_crear();
	l2 = palabras_con_prefijo(t,e4);
	l3 = palabras_con_prefijo(t,e5);
	l4 = palabras_con_prefijo(t,e3);
	l5 = palabras_con_prefijo(t,e6);
	l6 = palabras_con_prefijo(t,e7);
	/*************************************
	trie_pesar: 
	**************************************/
	double peso = trie_pesar(t,&peso_palabra);
	double p;
	p = p + peso_palabra(e2);
	p = p + peso_palabra(e);
	p = p + peso_palabra(e3);
	double v = (double)p/3;
	if (v == peso)
	{
		printf("Bien!");
	}

	/*************************************
	predecir palabras: 
	**************************************/
	listaP* l1 = lista_crear();
	char* tecla = "2";
	l1 = predecir_palabras(t,tecla);



	printf("Valor: %d",b);
	

    return 0;
}
