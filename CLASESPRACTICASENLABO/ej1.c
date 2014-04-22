#include <stdio.h>

extern double suma(double a, double b);

void main(){
double a = 2.5;
double b = 3.1;
double c= suma(a,b);
printf("La suma es: 	%f \n", c);
}
