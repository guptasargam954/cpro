//write c program to find square,log,ex


#include <stdio.h>
#include <math.h>
int main(){


int num;
int sq;



printf("Enter a number:");
scanf("%d", &num);

sq=sqrt(num);



printf("Square of the number is %d\n",sq);

int lg=log(num);

printf("log of the number is %d\n",lg);

int lg10=log10(num);

printf("log of the number with base 10 is %d\n",lg10);

int ex=exp(num);

printf("Exponent of the number is %d\n",ex);
return 0;
}
