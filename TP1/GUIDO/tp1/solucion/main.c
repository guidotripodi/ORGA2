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
	//trie_imprimir(t,nombre_archivo);
	char* nombre_archivo1 = "andaporfavor1.txt";
	char* e1 = "hola";
	char* e2 = "casa";
	trie_agregar_palabra(t,e2);
	char* e = "casco";
	char* e3 = "catador";
	char* e11 = "ala";
	char* e12 = "come";
	char* e13 = "comida";
	trie_agregar_palabra(t,e);
	trie_agregar_palabra(t,e3);
	trie_agregar_palabra(t,e11);
	trie_agregar_palabra(t,e12);
	trie_agregar_palabra(t,e13);
	trie_agregar_palabra(t,e1);
	//trie_agregar_palabra(t,e);

	
	/********************************
	trie_imprimir
	**********************************/

	trie_imprimir(t,nombre_archivo);
	//trie_borrar(t);

	/*char* e14 = "boludos";
	char* e15 = "gil";
	trie_agregar_palabra(t,e14);
	//trie_imprimir(t,nombre_archivo);
	trie_agregar_palabra(t,e15);
	trie_imprimir(t,nombre_archivo);

	char* e16= "bobobo";
	char* e17= "pepepe";
	char* e18= "nanann";
	char* e19= "sorete";
	char* e20= "kjdklf";
	char* e21= "bcfkjb";
	char* e22= "foidud";
	char* e23= "rioeuo";
	char* e24= "woiueq";
	char* e25= "riowur";
	char* e26= "kjdkjf";
	char* e27= "prorqr";
	trie_agregar_palabra(t,e16);
	trie_agregar_palabra(t,e17);
	trie_agregar_palabra(t,e18);
	//trie_imprimir(t,nombre_archivo);
	trie_agregar_palabra(t,e19);
	trie_agregar_palabra(t,e20);
	trie_agregar_palabra(t,e21);
	//trie_imprimir(t,nombre_archivo);
	trie_agregar_palabra(t,e22);
	trie_agregar_palabra(t,e23);
	//trie_imprimir(t,nombre_archivo);
	trie_agregar_palabra(t,e24);
	trie_agregar_palabra(t,e25);
	//trie_imprimir(t,nombre_archivo);
	trie_agregar_palabra(t,e26);
	trie_agregar_palabra(t,e27);
	//trie_imprimir(t,nombre_archivo);
	


	/*************************************
	busca_palabras: 
	**************************************
	char* e10 = "casas";
	bool b = buscar_palabra(t,e1); 
	bool b1 = buscar_palabra(t,e);
	bool b2 = buscar_palabra(t,e10);
	/************************************
	construir: 
	***************************************/
	trie* t1 = trie_crear();
	t1 = trie_construir(nombre_archivo); 


/*************************************
	trie_borrar: 
	**************************************/
	//trie_borrar(t1);

	/*************************************
	palabra_prefijo: 
	**************************************
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
	p = 0;
	p = p + peso_palabra(e2);
	p = p + peso_palabra(e3);
//	p = p + peso_palabra(e11);
	p = p + peso_palabra(e12);
	p = p + peso_palabra(e13);
	p = p + peso_palabra(e1);
	p = p + peso_palabra(e);

	double v = (double)p/(double)6;
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
	listaP* l7 = lista_crear();
	char* tecla1 = "22";
	//l7 = predecir_palabras(t,tecla1);
	listaP* l8 = lista_crear();
	char* tecla2 = "33";
	//l8= predecir_palabras(t,tecla2);
	listaP* l9 = lista_crear();
	char* tecla3 = "228";
	l9= predecir_palabras(t,tecla3);
	listaP* l10 = lista_crear();
	char* tecla4 = "2272";
	l10= predecir_palabras(t,tecla4);
	listaP* l11 = lista_crear();
	char* tecla5 = "2272";
	l11= predecir_palabras(t,tecla5);
	/*lista_borrar(l1);
	lista_borrar(l2);
	lista_borrar(l3);
	lista_borrar(l4);
	lista_borrar(l5);
	lista_borrar(l6);
	lista_borrar(l7);
	lista_borrar(l8);
	lista_borrar(l9);
	lista_borrar(l10);
	lista_borrar(l11);*/
	trie_borrar(t);

	printf("Valor: %d",1);
	

    return 0;
}
