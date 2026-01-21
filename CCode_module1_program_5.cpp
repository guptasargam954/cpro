
//c program to convert seconds into hours,minutes,seconds


#include <stdio.h>

int main()
{
    int seconds, hours, minutes, sec;

    printf("Enter total seconds: ");
    scanf("%d", &seconds);

    hours = seconds / 3600;
    minutes = (seconds - hours * 3600) / 60;
    sec = seconds - (hours * 3600) - (minutes * 60);

    printf("Hours = %d\n", hours);
    printf("Minutes = %d\n", minutes);
    printf("Seconds = %d\n", sec);

    return 0;
}
