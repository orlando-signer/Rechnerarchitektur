#include <stdlib.h>
#include <stdio.h>
#include <string.h>

int main(int argc, const char * argv[]) {
	aufgabe1();
	aufgabe2();
	aufgabe3();
	
	return 0;
}

// Aufgabe 1
int aufgabe1() {
	char *str = "Test";
	printf("Aufgabe 1:\n");
	printf("length: %d\n\n", strlen(str));
	return 0;
}

// Aufgabe 2
double a[10];
int b[10];
short c[10];

double getAtDouble(int i) {
	return a[i];
}

double getAtDouble1(double *a, int i) {
	return *(a+i);
}

int getAtInt(int i) {
	return b[i];
}
int getAtInt1(int *a, int i) {
	return *(a+i);
}

short getAtShort(int i) {
	return c[i];
}

short getAtShort1(short *a, int i){
	return *(a+i);
}

int aufgabe2() {
	int i;
	printf("Aufgabe 2:\n");
	for(i = 0;i<10;i++) {
		a[i] = i;
		b[i] = i;
		c[i] = i;
	}
	
	printf("1: %f\n", getAtDouble(1));
	printf("2: %f\n", getAtDouble1(a, 2));
	
	printf("1: %d\n", getAtInt(3));
	printf("2: %d\n", getAtInt1(b, 4));
	
	printf("1: %d\n", getAtShort(5));
	printf("2: %d\n", getAtShort1(c, 6));
	return 0;
}

int aufgabe3() {
	long a = 1234567890;
	long b = 987654321;
	
	void *p = &b;
	printf("Aufgabe 3:\n");
	printf("%x\n", p);
	printf("%x\n", *(long*)p++);
	printf("%x\n", *(char*)p++);
	printf("%x\n", *(unsigned char*)p++);
	printf("%x\n", p);
}

