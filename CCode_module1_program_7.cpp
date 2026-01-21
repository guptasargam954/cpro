// c program to swap two numbers without using temperory variable


#include <stdio.h>

int main(){
	int a,b;
	
	printf("Enter number1 %d\n");
	scanf("%d", &a);
	
	printf("Enter number2 %d\n");
	scanf("%d", &b);
	
	a= a+b;
	b=a-b;
	a=a-b;
	
	printf("After swaping:\n");
	printf("a=%d\n",a);
	printf("b=%d\n",b);
	return 0;

