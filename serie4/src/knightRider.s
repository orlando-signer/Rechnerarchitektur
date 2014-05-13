/* TODO: Task (b) Please fill in the following lines, then remove this line.
 *
 * author(s):   Dominik Bodenmann
				Orlando Signer
 * modified:    2014-04-29
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
	
	/* r15 stores the memory address for the LEDs
	 * r17 stores the active LED
	 * r18 the direction to move (0 -> downwards, 1 -> upwards)
	 * r19 stores the delay-time
	 * r20 and r21 are for temporary use
	 */
	
	/* Initialize first red LED (light up) */
	movia		r15, RED_LED_BASE		
	movi		r17, 0x1		# Bitmask for first LED
	movi		r18, 0x0		# Direction bit (will be inverted first)
	movia		r19, 0xC8		# Wait 0xC8 = 200 msecs
	
	
	CHECK_BORDER:
	movi		r20, 0x1					# Set value for lowest bit
	beq			r17, r20, INVERT_DIRECTION 	# If we are on the lowest bit, invert direciton
	movi		r20, 0x200					# Set value for highest bit
	beq			r17, r20, INVERT_DIRECTION 	# If we are on the highest bit, invert direction
	
	CHECK_DIRECTION:
	movi		r20, 0x1
	beq			r18, r20, MOVE_UP 			# Check the direction we move, MOVE_UP if the move-bit is 1
	br			MOVE_DOWN					# else MOVE_DOWN
	
	MOVE_UP:
	stwio		r17, 0(r15)					# Write LED-Bitmask to memory
	slli		r17, r17, 0x1				# left-shift the value by one
	br			DELAY						# Delay the next output
	
	MOVE_DOWN:
	stwio		r17, 0(r15)					# Write LED-Bitmask to memory
	srai		r17, r17, 0x1				# right-shift the value by one
	br			DELAY						# Delay the next output
	
	DELAY:
	movia		r20, TIME
	ldwio		r21, 0(r20)					# Get the Time from the Counter
	blt			r20, r19, DELAY				# Check if we waited more than (r19) steps (go to DELAY else)
	stwio		r0, 0(r20)					# Reset Time counter
	br			CHECK_BORDER				# Go to check the borders (--> start again)
	
	INVERT_DIRECTION:
	xori		r18, r18, 0x1				# Invert the direction
	br			CHECK_DIRECTION
	
	
	
	
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
