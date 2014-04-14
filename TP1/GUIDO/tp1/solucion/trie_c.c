#include "trie.h"
#include "listaP.h"

// Completar las funciones en C.

listaP *predecir_palabras(trie *t, char *teclas) {
	char* c = "            ";
	return recorro(t,teclas,0, c);
}

listaP *recorro(trie *t,char* teclas, int i,char* c){
	listaP* l1 = lista_crear();
	int j;
	int h;
	while(teclas[i] != 0)
	{
		h = 0;
		while((caracteres_de_tecla(teclas[i]))[h] != 0)
			{	
				j = 0;
				if (teclas[i+1] == 0)
				{	
					while((caracteres_de_tecla(teclas[i]))[j] != 0){
					c = (caracteres_de_tecla(teclas[i]))[j];
					printf("valor: %c",c);
					//l1 = palabras_con_prefijo(t,c);
					//lista_concatenar(l1,recorro(t,teclas,i+1,c));
					recorro(t,teclas,i+1,c);
					j++;
					}
				}
				else
				{
					c[i] = (caracteres_de_tecla(teclas[i]))[h];
					recorro(t,teclas,i+1,c);
				}
			}
	}

	return l1;
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



