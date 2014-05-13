/* TODO: Task (b) Please fill in the following lines, then remove this line.
 *
 * author(s):   Dominik Bodenmann
				Orlando Signer
 * modified:    2014-04-29
 *
 */

.include "nios_macros.s"
.include "address_map.s"


/*****************************************************************************
 * Pushbutton - Interrupt Service Routine                                
 *                                                                          
******************************************************************************/
.global PUSHBUTTON_ISR
PUSHBUTTON_ISR:

	/*
	 * r19 stores the delay time
	 * r20 stores the button pressed values
	 * r21 is for temporary use
	 */

	movia		r21, PUSHBUTTON_BASE	# Memory address for pushed buttons
	ldwio		r20, 0xC(r21)			# read register with values of buttons
	stwio		r0, 0xC(r21)			# reset the pushed buttons

	movia		r21, 0b100
	beq			r20, r21, DEFAULT		# Check if KEY2 is pressed
	movia		r21, 0b1000
	beq			r20, r21, FASTER		# Check if KEY3 is pressed
	movia		r21, 0b10
	beq			r20, r21, SLOWER		# Check if KEY1 is pressed
	ret
	
	DEFAULT:
	movia		r19, 0xC8				# Set the default delay
	ret

	FASTER:
	subi		r19, r19, 0x32			# Subtract 0x32 (50) msecs to delay
	ret
	
	SLOWER:
	addi		r19, r19, 0x32			# Add 0x32 (50) msecs to delay
	ret

.end
	
