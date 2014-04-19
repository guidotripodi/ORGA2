#include "trie.h"
#include "listaP.h"
#include <string.h>
#include <stdlib.h>

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
	//char aux[1024];
	listaP*  listaConPalabrasFinal = lista_crear();
	listaConPalabrasFinal = recorrer(t, teclas, i, paraPrefijo, listaFinal);
		
	return listaConPalabrasFinal;
}



	listaP* recorrer(trie* t, char *teclas, int i, char *paraPrefijo, listaP* listaFinal){
	while (i < strlen((teclas)))
	{	
		char* teclasrepresentadas = caracteres_de_tecla(teclas[i]);
		if (i + 1 == strlen(teclas))
		{
			int j = 0;
			while (j < strlen(teclasrepresentadas))
				{
					paraPrefijo[i] = teclasrepresentadas[j];
					listaP* l1 = lista_crear();
					l1 = palabras_con_prefijo(t,paraPrefijo);
					lista_concatenar(listaFinal, l1);
					//printf("%s\n", paraPrefijo);
					j++;

				}
		}
		else
		{	
			int j = 0;
			while (j < strlen(teclasrepresentadas))
				{
					paraPrefijo[i] = teclasrepresentadas[j];
					recorrer(t,teclas,i+1,paraPrefijo,listaFinal);
					j++;
				}
		}
		i++;
	}
	return listaFinal;
}


const char *caracteres_de_tecla(char tecla){
	char* c;
	if (tecla == '1')
	{
		c = "1";
	}
	if (tecla == '2')
	{
		c = "2abc";
	}
	if (tecla == '3')
	{
		c = "3def";
	}
	if (tecla == '4')
	{
		c = "4ghi";
	}
	if (tecla == '5')
	{
		c = "5jkl";
	}
	if (tecla == '6')
	{
		c = "6mno";
	}
	if (tecla == '7')
	{
		c = "7pqrs";
	}
	if (tecla == '8')
	{
		c = "8tuv";
	}
	if (tecla == '9')
	{
		c = "9wxyz";
	}
	if (tecla == '0')
	{
		c = "0";
	}
return c;


}

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



