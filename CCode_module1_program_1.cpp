//write a c program to find ellipse area


#include <stdio.h>

int main(){


int l;
int b;
float pi=3.14;
int Area_of_ellipse;


printf("Enter major axis length:");
scanf("%d", &l);

printf("Enter minor axis length:");
scanf("%d", &b);

Area_of_ellipse=pi*l*b;

printf("Area of an Ellipse is %d\n",Area_of_ellipse);

return 0;
}
