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
	/* r17 holds the current phase (1=Init 3=Play game 4=Finished) */
	/* r18 is used to keep track of the direction (if 1, go up, else down)*/
	/* r19, r20 are variables for free usage (no global usage) */
	/* r21 stores the amount of time we want to wait each step (speed of the ball) */
	/* r22 stores the points for player 1 and 2 (bit 0 to 3 for player 1, bit 4 to 7 for player 2) */
	/* r23 stores the button presses (0b1000 k3 pressed, 0b0010 k1 pressed, 0b1010 both pressed) */
	
	/* Initialize first red LED (light up) */
	INIT:
	movia		r15, RED_LED_BASE		
	movi		r16, 0x1		# Code for first LED
	movi		r18, 0x0		# Direction bit (will be inverted first)
	movi		r17, 0x1		# Set init phase
	movi		r21, 0x1F4		# How long to wait each step (0x1F4 = 500)
	movi		r22, 0x0		# reset score
	br			SHOW_SCORE
	
	CHECK_PHASE:
	mov			r24, r0			# reset pressed buttons
	movi 		r19, 0x1
	beq			r17, r19, INIT_GAME
	movi		r19, 0x3
	beq			r17, r19, PLAY_GAME
	movi		r19, 0x4
	beq			r17, r19, FINISHED_GAME
	br			INIT					# if something is messed up, go back to init phase
	
	/* Init phase: blinking LEDR4 and LEDR5 until both players press KEY1 and KEY3 */
	INIT_GAME:
	movi		r19, 0b1010
	beq			r23, r19, START_GAME		# if k1 and k3 are pressed, start the game
	movi		r19, 0x10					# Store value for L4
	beq			r16, r19, SHOW_L5			# Check if only L4 is active. SHOW_L5 if true
	br			SHOW_L4						# Else jump to SHOW_L4
	
	SHOW_L4:
	movi		r16, 0x10					# Store value for L4
	stwio		r16, 0(r15)					# Display LEDs
	br			DELAY						# Jump to delay
	
	SHOW_L5:
	movi		r16, 0x20					# Store value for L5
	stwio		r16, 0(r15)					# Display LEDs
	br			DELAY						# Jump to delay
	
	/* Start the game */
	START_GAME:
	movi		r21, 0x1F4					# Reset game speed
	movia		r19, TIME
	ldwio		r20, 0(r19)					# Get the Time from the Counter
	andi		r18, r20, 0x1				# Set the direction
	movi		r16, 0x10					# set the ball to the 4th led
	movi		r17, 0x3					# Set phase 3
	movi		r23, 0x0					# reset pressed buttons
	br			SHOW_SCORE

	PLAY_GAME:
	br			DO_DISPLAY_1	
	
	DO_DISPLAY_1:
	movi		r19, 0x1
	beq			r16, r19, LOWER_BORDER 		# Check if we hit lower border
	movi		r19, 0x200
	beq			r16, r19, UPPER_BORDER	 	# Check if we hit upper border
	movi		r19, 0b10
	beq			r19, r23, PLAYER_1_FAIL		# No border, but player 1 pressed button
	movi		r19, 0b1000
	beq			r19, r23, PLAYER_2_FAIL		# No border, but player 2 pressed button
	movi		r23, 0x0					# reset pressed buttons
	
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
	br			CHECK_PHASE					# Go to display the next position
	
	LOWER_BORDER:
	andi		r19, r23, 0b0010			# check if k1 has pressed
	movi		r20, 0b0010
	beq			r19, r20, INVERT_DIRECTION	# player pressed button -> invert direction
	br			PLAYER_1_FAIL				# player didnt press button
	
	UPPER_BORDER:
	andi		r19, r23, 0b1000			# check if k1 has pressed
	movi		r20, 0b1000
	beq			r19, r20, INVERT_DIRECTION	# player pressed button -> invert direction
	br			PLAYER_2_FAIL				# player didnt press button	
	
	INVERT_DIRECTION:
	subi		r21, r21, 0x5				# Subtract a fixed amount to the current waiting time
	xori		r18, r18, 0x1				# Invert the direction after we hit the border
	br			DO_DISPLAY_2
	
	PLAYER_1_FAIL:
	mov			r20, r22					# get score
	andi		r20, r20, 0xF0				# get score from player 2
	srli		r20, r20, 0x4				# shift right by 4 to get correct score
	movi		r19, 0xA					# max score 10
	bge			r20, r19, PLAYER_2_WIN		# if p2 reached 10 poins, he wins
	addi		r22, r22, 0x10				# else add one point
	br			START_GAME					# start the game

	PLAYER_2_FAIL:
	mov			r20, r22					# get score
	andi		r20, r20, 0x0F				# get score from player 1
	movi		r19, 0xA					# max score 10
	bge			r20, r19, PLAYER_1_WIN		# if p1 reached 10 poins, he wins
	addi		r22, r22, 0x01				# else add one point
	br			START_GAME					# start the game
	
	PLAYER_1_WIN:
	movi		r17, 0x4					# set phase 4
	movi		r16, 0b1111
	stwio		r16, 0(r15)					# Display 4 leds for p1
	br			DELAY
	
	
	PLAYER_2_WIN:
	movi		r17, 0x4					# set phase 4
	movi		r16, 0b1111000000
	stwio		r16, 0(r15)					# Display 4 leds for p2
	br			DELAY
	
	FINISHED_GAME:
	andi		r19, r23, 0b0100			# check if k2 pressed
	bgt			r19, r0, INIT				# init if k2 is pressed
	br 			DELAY
	
	SHOW_SCORE:
	andi		r20, r22, 0xF0				# get score from player 2
	srli		r20, r20, 0x4				# shift right by 4 to get correct score
	call 		LED_NUMBER
	mov			r19, r10
	slli		r19, r19, 24				# shift the number to the left
		
	andi		r20, r22, 0x0F				# get score from player 1
	call		LED_NUMBER
	or			r19, r19, r10				# combine the 2 LED-numbers
	movia 		r20, HEX3_HEX0_BASE			# stores the hex base addres
	stwio 		r19, 0(r20)					# store the numbers to the LEDs
	br 			DELAY	
	
	
	/* Gets the number from r20 and converts it into a LED-number and stores it in r10 */
	LED_NUMBER:
	movi		r10, 0b00111111 			#Display value for 0
	movi		r11, 0x0
	beq			r20, r11, RETURN 			#Check if score is 0
	
	movi		r10, 0b00000110 			#Display value for 1
	movi		r11, 0x1
	beq			r20, r11, RETURN 			#Check if score is 1

	movi		r10, 0b01011011 			#Display value for 2
	movi		r11, 0x2
	beq			r20, r11, RETURN 			#Check if score is 2

	movi		r10, 0b01001111 			#Display value for 3
	movi		r11, 0x3
	beq			r20, r11, RETURN 			#Check if score is 3

	movi		r10, 0b01100110 			#Display value for 4
	movi		r11, 0x4
	beq			r20, r11, RETURN 			#Check if score is 4

	movi		r10, 0b01101101 			#Display value for 5
	movi		r11, 0x5
	beq			r20, r11, RETURN 			#Check if score is 5

	movi		r10, 0b01111101 			#Display value for 6
	movi		r11, 0x6
	beq			r20, r11, RETURN 			#Check if score is 6

	movi		r10, 0b00000111 			#Display value for 7
	movi		r11, 0x7
	beq			r20, r11, RETURN 			#Check if score is 7

	movi		r10, 0b01111111 			#Display value for 8
	movi		r11, 0x8
	beq			r20, r11, RETURN 			#Check if score is 8

	movi		r10, 0b01101111 			#Display value for 9
	movi		r11, 0x9
	beq			r20, r11, RETURN 			#Check if score is 9
	
	RETURN:
	ret
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
