#include <stdio.h>

// Declaro la aridad de la funcion de ASM
extern int suma2Enteros(int a, int b);

int main(){
	
	int suma;
	suma = suma2Enteros(1,41);
	
	printf("\nLa suma es %d\n\n",suma);
	
	return 0;
}
