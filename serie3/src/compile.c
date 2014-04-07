/* TODO: Task (b) Please fill in the following lines, then remove this line.
 *
 * author(s):   Dominik Bodenmann
 *              Orlando Signer
 * modified:    2010-01-07
 *
 */

#include <stdlib.h>
#include <stdio.h>
#include "memory.h"
#include "mips.h"
#include "compiler.h"
 
int main ( int argc, char** argv ) {
    /* TODO: Task (c) implement main */
	if (argc != 3) {
		printf("usage: <%s> expression filename\n", argv[0]);
		return EXIT_FAILURE;
	}
	char * expression = argv[1];
	char * filename = argv[2];
	compiler(expression, filename);
	return EXIT_SUCCESS;
}

