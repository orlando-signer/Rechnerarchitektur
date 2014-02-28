#include <stdio.h>

/* A simple "Hello, world!"*/
int main(int argc, char **argv)
{
  int i;
  printf("%d\n", argc);
  for (i = 0;i < argc;i++)
    printf("Arg %d: %s\n", i, argv[i]);
  printf("Hello, world!\n");
  return 0;
}

