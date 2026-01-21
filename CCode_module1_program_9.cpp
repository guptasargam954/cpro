//write c program to read three integer numbers and display their average

#include <stdio.h>

int main(){
	int a,b,c,average;
	
	printf("Enter number1 %d\n");
	scanf("%d", &a);
	
	printf("Enter number2 %d\n");
	scanf("%d", &b);
	
	printf("Enter number2 %d\n");
	scanf("%d", &c);
	
	average=(a+b+c)/3;
	
	printf("Average of the number is %d\n", average);
	
    return 0;

}
