/* TODO: Task (b) Please fill in the following lines, then remove this line.
 *
 * author(s):   Dominik Bodenmann
				Orlando Signer
 * modified:    2014-05-09
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
	
	/* r16 holds the value for the blinking LED (the position of the ball) */
	/* r17 holds the current phase (1=Init 2=Playing 3=Finished) */
	/* r18 is used to keep track of the direction */
	/* r19, r20 are variables for free usage (no global usage) */
	/* r21 stores the amount of time we want to wait each step */
	
	/* Initialize first red LED (light up) */
	movia		r15, RED_LED_BASE		
	movi		r16, 0x1		# Code for first LED
	movi		r18, 0x0		# Direction bit (will be inverted first)
	movi		r17, 0x1
	movia		r21, 0x1F4		# How long to wait each step
	
	CHECK_PHASE:
	movi 		r19, 0x1
	beq			r17, r19, INIT
	
	/* Init phase: blinking LEDR4 and LEDR5 until both players press KEY1 and KEY3 */
	INIT:
	movi		r16, 0x10
	stwio		r16, 0(r15)
	br			DELAY
	
	DO_DISPLAY_1:
	movi		r19, 0x1
	beq			r16, r19, INVERT_DIRECTION 	# Check if we hit lower border
	movi		r19, 0x200
	beq			r16, r19, INVERT_DIRECTION 	# Check if we hit upper border
	
	DO_DISPLAY_2:
	movi		r19, 0x1
	beq			r18, r19, DO_DISPLAY_UP 	# Check if we are going upwards (jump to DISPLAY_UP, if we are)
	br			DO_DISPLAY_DOWN				# go To DISPLAY_DOWN if we're not going upwards
	
	DO_DISPLAY_UP:
	stwio		r16, 0(r15)					# Display current position
	slli		r16, r16, 0x1				# Shift the value to the left (next LED)
	br			DELAY						# Delay the next output
	
	DO_DISPLAY_DOWN:
	stwio		r16, 0(r15)					# Display current position
	srai		r16, r16, 0x1				# Shift the value to the right (previous LED)
	br			DELAY						# Delay the next output
	
	DELAY:
	movia		r19, TIME
	ldwio		r20, 0(r19)					# Get the Time from the Counter
	blt			r20, r21, DELAY				# Check if we already waited more than (r21) seconds
	stwio		r0, 0(r19)					# Reset Time counter
	br			CHECK_PHASE				# Go to display the next position
	
	INVERT_DIRECTION:
	xori		r18, r18, 0x1				# Invert the direction after we hit the border
	br			DO_DISPLAY_2
	
	
	
	
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
