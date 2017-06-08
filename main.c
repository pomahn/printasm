#include <stdio.h>

extern void printfd();

int main()
{
    printfd("I love %x %d%c %s\n", 3802, 100, '%', "!GIgii");
	printfd("I made %d link\n", 1);
    return 0;
}
