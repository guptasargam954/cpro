//c program to swap two numbers with using temperory variable



#include <stdio.h>

int main(){
	int a,b,temp;
	
	printf("Enter number1 %d\n");
	scanf("%d", &a);
	
	printf("Enter number2 %d\n");
	scanf("%d", &b);
	
	temp=a;
	a=b;
	b=temp;
	
	printf("After swaping:\n");
	printf("a=%d\n",a);
	printf("b=%d\n",b);
	return 0;
}
