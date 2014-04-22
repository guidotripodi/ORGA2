#include "trie.h"
#include "listaP.h"
#include <string.h>
#include <stdlib.h>
// Completar las funciones en C.

listaP* recorrer(trie* t, char *teclas, int i, char *paraPrefijo, listaP* listaFinal){
	//while (i < strlen((teclas)))
	//{	
		char* teclasrepresentadas = caracteres_de_tecla(teclas[i]);
		if (i + 1 == strlen(teclas))
		{
			int j = 0;
			while (j < strlen(teclasrepresentadas))
				{
					paraPrefijo[i] = teclasrepresentadas[j];
					//listaP* l1 = lista_crear();
					listaP* l1 = palabras_con_prefijo(t,paraPrefijo);
					lista_concatenar(listaFinal, l1);
					//lista_borrar(l1);
					//printf("%s\n", paraPrefijo);
					j++;

				}
		}
		if(i + 1 < strlen((teclas)))
		{	
			int j = 0;
			while (j < strlen(teclasrepresentadas))
				{
					paraPrefijo[i] = teclasrepresentadas[j];
					recorrer(t,teclas,i+1,paraPrefijo,listaFinal);
					j++;
				}
		}
	//	i++;
	//}
	return listaFinal;
}

listaP *predecir_palabras(trie *t, char *teclas) { 
	int i = 0;
	listaP* listaFinal = lista_crear();
	char paraPrefijo[1024];
	//pongo nulls en el paraprefijo
	int h =0;
	while(h < 1024){
		paraPrefijo[h] = NULL;
		h++;
	}
	//listaP*  listaConPalabrasFinal = lista_crear();
	//listaConPalabrasFinal = recorrer(t, teclas, i, paraPrefijo, listaFinal);
	//lista_borrar(listaFinal);
	return recorrer(t, teclas, i, paraPrefijo, listaFinal);
}

/*
listaP *concatenar_combinacion(char *valor, char *caracteres) {
	listaP * lista = lista_crear();

	int len_caracteres = strlen(caracteres);
	int len_valor = strlen(valor);
	int i = 0;
	char palabra[len_valor + 2];

	while(i < len_caracteres) {
		strcpy(palabra, valor);
		palabra[len_valor] = caracteres[i];
		palabra[len_valor + 1] = 0;
		lista_agregar(lista, palabra);
		i++;
	}

	return lista;
}

void crear_primeras_combinaciones(listaP* lista, char * caracteres) {
	int len_caracteres = strlen(caracteres);
	int i = 0;
	char palabra[2];

	while(i < len_caracteres) {
		palabra[0] = caracteres[i];
		palabra[1] = 0;
		lista_agregar(lista, palabra);
		i++;
	}
}

listaP *agregar_combinaciones(listaP* combinaciones, char* caracteres) {
	lsnodo * nodo_lista = combinaciones->prim;
	if (nodo_lista == 0) {
		crear_primeras_combinaciones(combinaciones, caracteres);
	} else {
		listaP* nuevas_combinaciones = lista_crear();
		while (nodo_lista != 0) {
			lista_concatenar(nuevas_combinaciones, concatenar_combinacion(nodo_lista->valor, caracteres));
			nodo_lista = nodo_lista->sig;
		}
		lista_borrar(combinaciones); // borro las combinaciones viejas
		combinaciones = nuevas_combinaciones;
	}

	return combinaciones;
}
*/
void print_listap(listaP* lista) {
	lsnodo * nodo_lista = lista->prim;

	while (nodo_lista != 0) {
		printf("%s ", nodo_lista->valor);
		nodo_lista = nodo_lista->sig;
	}
}
/*
listaP *predecir_palabras(trie *t, char *teclas) {
	listaP * prediccion = lista_crear();
	listaP * combinaciones = lista_crear();
	int len_teclas = strlen(teclas);
	int i = 0;

	while (i < len_teclas) {
		combinaciones = agregar_combinaciones(combinaciones, caracteres_de_tecla(teclas[i]));
		i++;
	}

	// print_listap(combinaciones);
	lsnodo * nodo_combinacion = combinaciones->prim;

	while (nodo_combinacion != 0) {
		lista_concatenar(prediccion, palabras_con_prefijo(t, nodo_combinacion->valor));
		nodo_combinacion = nodo_combinacion->sig;
	}

	lista_borrar(combinaciones);

	return prediccion;
}
*/
double peso_palabra(char *palabra) {
	int i = 0;
	int x = 0;
	while(!(palabra[i] == 0)){
		x = x + palabra[i];
		i++;
	}
	double v = (double)x/i;
	 return v;
}

char* caracteres_de_tecla(char tecla) {
	if (tecla == '1') {
		return "1";
	} else if (tecla == '2') {
		return "2abc";
	} else if (tecla == '3') {
		return "3def";
	} else if (tecla == '4') {
		return "4ghi";
	} else if (tecla == '5') {
		return "5jkl";
	} else if (tecla == '6') {
		return "6mno";
	} else if (tecla == '7') {
		return "7pqrs";
	} else if (tecla == '8') {
		return "8tuv";
	} else if (tecla == '9') {
		return "9wxyz";
	} else if(tecla == '0'){
		return "0";
	}
}