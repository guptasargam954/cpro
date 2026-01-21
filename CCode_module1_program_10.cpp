//write a C program that converts inches to centimeters


#include <stdio.h>

int main(){
	int a;
	
	printf("Enter a number in inches");
	scanf("%d", &a);
	
	int b=a*2.54;
	
	printf("Inches to centimeters is %d\n",b);
	}
