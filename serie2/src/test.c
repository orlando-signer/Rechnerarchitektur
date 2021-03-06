/* TODO: Task (b) Please fill in the following lines, then remove this line.
 *
 * author(s):   Dominik Bodenmann
 *              Orlando Signer
 * modified:    2010-01-07
 *
 */

#include <stdlib.h>
#include <stdio.h>
#include <assert.h>
#include "mips.h"

/* executes exactly the given instrution */
void test_execute(word instr) {
	word w;
	Instruction *instruction;
	
	/* Store the executable word  */
	storeWord(instr, pc);
	
	/* Fetch the next Instruction */
	w  = loadWordFrom(pc);
	instruction = (Instruction *) &w;
	pc += 4;
	
	/* Execute the fetched instruction*/
	operations[instruction->i.opcode].operation(instruction);
	assert(ZERO == 0);
}

/* ADD */
void test_add() {
	T1=1;
	T2=1;
	test_execute(create_rtype_hex(FC_ADD, 0x0000, I_T0, I_T1, I_T2, OC_ADD));
	assert(T0==2);
	
	T1=1;
	T2=-1;
	test_execute(create_rtype_hex(FC_ADD, 0x0000, I_T0, I_T1, I_T2, OC_ADD));
	assert(T0==0);
	
	T1=-1;
	T2=-1;
	test_execute(create_rtype_hex(FC_ADD, 0x0000, I_T0, I_T1, I_T2, OC_ADD));
	assert(T0==-2);
}

/* ADDI */
void test_addi() {
	test_execute(create_itype_hex(0xFFFF, I_T0, I_ZERO, OC_ADDI));
	assert(T0 == -1); 
	test_execute(create_itype_hex(1, I_T0, I_T0, OC_ADDI));
	assert(T0 ==  0);
	
	test_execute(create_itype_hex(0xFFFF, I_T0, I_ZERO, OC_ADDI));
	assert(T0 == -1); 
	test_execute(create_itype_hex(0xFFFF, I_T0, I_T0, OC_ADDI));
	assert(T0 == -2); 
	
	test_execute(create_itype_hex(3, I_T0, I_ZERO, OC_ADDI));
	assert(T0 ==  3);
	test_execute(create_itype_hex(1, I_T1, I_T0, OC_ADDI));
	assert(T0 ==  3);
	assert(T1 ==  4);
}

/* JAL */
void test_jal() {
    int pcSaved;
    word w;
    Instruction* instruction;

    pc = 0x00000000;
    pcSaved = pc;
	test_execute(create_jtype_hex(0x0001, OC_JAL));
	assert(RA == pcSaved + 4);
    assert(pc == 4);

    /* The following test is executed manually as the desired pc is outside the memory,
     * i.e. the test needs to bypass actually storing the instruction in the memory.
     */
	initialize();
    pc = 0xAF000000;
	pcSaved = pc;
    w = create_jtype_hex(0x0001, OC_JAL);
    instruction = (Instruction *) &w;
    pc += 4;
    operations[instruction->i.opcode].operation(instruction);
	assert(RA == pcSaved + 4);
    assert(pc == 0xA0000004);
}

/* LUI */
void test_lui() {
    test_execute(create_itype_hex(0xFFFF, I_T0, I_ZERO, OC_LUI));
    assert(T0 == 0xFFFF0000);
    
    test_execute(create_itype_hex(0x0001, I_T0, I_ZERO, OC_LUI));
    assert(T0 == 0x00010000);
}

/* LW */
void test_lw() {
    /* TODO: Task (d) add test for LW here */
    word location1 = 0x00001000;

    word w = 0x87654321;
    T1 = location1;

    storeWord(w, location1);
    test_execute(create_itype_hex(0x0000, I_T0, I_T1, OC_LW));
    assert(w == T0);
} 

/* ORI */
void test_ori() {
    /* TODO: Task (d) add test for ORI here */
    word w = 0xAAAAAAAA; /* 0b1010.... */
    T1 = w;
    
    test_execute(create_itype_hex(0x5555, I_T0, I_T1, OC_ORI)); /* 0x5555 0b0101... */
    assert(0xAAAAFFFF == T0);
    
    w = 0xFFFF0000;
    T1 = w;
    test_execute(create_itype_hex(0xFFFF, I_T0, I_T1, OC_ORI));
    assert(0xFFFFFFFF == T0);
}

/* SUB */
void test_sub() {
    /* TODO: Task (d) add test for SUB here */
    /* T0 = T2 -T1 */
    T1=1;
	T2=1;
	test_execute(create_rtype_hex(FC_SUB, 0x0000, I_T0, I_T1, I_T2, OC_SUB));
	assert(T0==0);
	
	T1=1;
	T2=-1;
	test_execute(create_rtype_hex(FC_SUB, 0x0000, I_T0, I_T1, I_T2, OC_SUB));
	assert(T0==-2);
    
	T1=-1;
	T2=1;
	test_execute(create_rtype_hex(FC_SUB, 0x0000, I_T0, I_T1, I_T2, OC_SUB));
	assert(T0==2);    
	
	T1=-1;
	T2=-1;
	test_execute(create_rtype_hex(FC_SUB, 0x0000, I_T0, I_T1, I_T2, OC_SUB));
	assert(T0==0);
}

/* SW */
void test_sw() {
    word location1 = 0x00001000;
    word location2 = 0x00001004;
	
    word w = 0xFFFFFFFF;
    T0 = w;
    T1 = location1;
    test_execute(create_itype_hex(0x0000, I_T0, I_T1, OC_SW));
    assert(loadWordFrom(location1) == w);
	
    w =0x12345678;
    T0 = w;
    T1 = location2;
    test_execute(create_itype_hex(0xFFFC, I_T0, I_T1, OC_SW));
    assert(loadWordFrom(location1) == w);
}

/* ============================================================================ */
/* make sure you've got a "fresh" environment for every test */
void execute_test(void (*test)(void)) {
    initialize();
    test();
}

/* executes all tests */
int main (int argc, const char * argv[]) {
	execute_test(&test_add);
	execute_test(&test_addi);
	execute_test(&test_jal);
	execute_test(&test_lui);
	execute_test(&test_lw);
	execute_test(&test_ori);
	execute_test(&test_sub);
	execute_test(&test_sw);
	return 0;
}
