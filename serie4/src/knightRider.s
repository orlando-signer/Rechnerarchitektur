/* TODO: Task (b) Please fill in the following lines, then remove this line.
 *
 * author(s):   FIRSTNAME LASTNAME 
 *              (FIRSTNAME2 LASTNAME2)
 * modified:    2010-01-13
 *
 */

.include "nios_macros.s"
.include "address_map.s"

/********************************************************************************
 * TEXT SECTION
 */
.text

/********************************************************************************
 * Entry point.
 */
.global _start
_start:
	/* set up sp and fp */
	movia 	sp, 0x007FFFFC			# stack starts from largest memory address 
	mov 		fp, sp

	/* This program exercises a few features of the DE1 basic computer. 
	 *
	 * It performs the following: 
	 *     1. displays a red light wandering from LEDR0 to LEDR9 and back again (and so on...)
	 *     2. speed of light can be increased by KEY3, decreased by KEY1 and initial value can be restored by KEY2
	 */	
		
	/* set up timer interval = 0x0000C350 steps * 1/(50 MHz) = 1 millisecond*/
	movia	r15, TIMER_COUNTER_LOW
	movui	r16, 0xC350
	sthio		r16, 0(r15)
	
	movia	r15, TIMER_COUNTER_HIGH
	movui	r16, 0x0000
	sthio		r16, 0(r15)
	
	/* start interval timer, enable its interrupts */
	movia	r15, TIMER_STOP_START_CONT_ITO
	movi		r16, 0b0111		# START = 1, CONT = 1, ITO = 1 
	sthio		r16, 0(r15)
	
	/* enable pushbutton interrupts */
	movia	r16, PUSHBUTTON_BASE
	movi		r15, 0b01110		# set all 3 interrupt mask bits to 1 (bit 0 is Nios II Reset) 
	stwio		r15, 8(r16)
	
	/* enable processor interrupts */
	movi		r16, 0b011			# enable interrupts for timer and pushbuttons 
	wrctl		ienable, r16
	movi		r16, 1
	wrctl		status, r16
	
	/* TODO: Task (c) implement wandering light here */
	
	
/********************************************************************************
 * DATA SECTION
 */
.data

/* to count how much time has passed*/
.global TIME
TIME:
	.word 0
/* TODO: Task (c) you may also want to add things here (but you don't need to) */
.end
