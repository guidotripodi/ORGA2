// EJERCICIO para la clase
// ensamblamos y compilamos:
// -->    nasm -felf funcionAsm.asm
// -->    gcc -o funcion funcionMain.c funcionAsm.o
// -->    ./funcion
#include <stdio.h> 

extern void diagonalej1(short* matriz, short n, short* vector);
extern short* diagonalej2(short* matriz, short n);
extern short suma(short* vector, short n);


int main(int argc, char* argv[]){


    int v[5];
    int *puntero_v=v;
	
	short matriz[4][4];
	
	matriz[0][0] = 2;
	matriz[0][1] = 2;
	matriz[0][2] = 3;
	matriz[0][3] = 4;
	matriz[1][0] = 2;
	matriz[1][1] = 2;
	matriz[1][2] = 3;
	matriz[1][3] = 4;
	matriz[2][0] = 2;
	matriz[2][1] = 2;
	matriz[2][2] = 3;
	matriz[2][3] = 4;
	matriz[3][0] = 2;
	matriz[3][1] = 2;
	matriz[3][2] = 3;
	matriz[3][3] = 4;
	
	short* p_matriz = &(matriz[0][0]);
	
	short n = 4;
	short* vector;
	vector = diagonalej2(p_matriz, n);
	
	
	printf("vector: [" );
	int i =0;
	for(; i < n; i++){
		
		printf("%i ", vector[i]);
		}
	
	printf("] \n");
	
	short vector2[n];
	
	diagonalej1(p_matriz, n, vector2);
	 
	printf("vector2: [" );
	int j =0;
	for(; j < n; j++){
		
		printf("%i ", vector2[j]);
		}
	
	printf("] \n");
	
	
	
	short s = suma(vector, n);
	
	printf("suma: %i \n", s);
	
	
	return 0;
}
