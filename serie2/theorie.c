#include <stdio.h>
#include <stdlib.h>
#include <string.h>

int main(int argc, const char * argv[]) {
	aufgabe1();
}

// Aufgabe 1

void callA(int a) {
	printf("A: %i\n", a);
}

void callB(int a) {
	printf("B: %i\n", a);
}

void callC(int a) {
	printf("C: %i\n", a);
}

void (*functionPointer[3])(int) = { &callA, &callB, &callC };

int aufgabe1() {
	printf("Aufgabe 1\n");
	functionPointer[0](10);
	functionPointer[1](11);
	functionPointer[2](12);
}