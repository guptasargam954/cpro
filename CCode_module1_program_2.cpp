//write c program to calculate area of triangle 

#include <stdio.h>

int main(){


int b;
int h;
int Area_of_Triangle;


printf("Enter base of triangle:");
scanf("%d", &b);

printf("Enter height of triangle:");
scanf("%d", &h);

Area_of_Triangle=0.5*b*h;

printf("Area of an Triangle is %d\n",Area_of_Triangle);

return 0;
}
