/* TODO: Task (b) Please fill in the following lines, then remove this line.
 *
 * author(s):   Dominik Bodenmann
				Orlando Signer
 * modified:    2014-05-09
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

	movia	r17, PUSHBUTTON_BASE
	ldwio		r20, 0xC(r17)			# read register with values of buttons
	stwio		r0, 0xC(r17)			# clear the interrupt

	movia		r17, 0b1000
	beq			r20, r17, SPEED_UP		# Check if KEY3 was pressed
	movia		r17, 0b100
	beq			r20, r17, SPEED_DEFAULT	# Check if KEY2 was pressed
	movia		r17, 0b10
	beq			r20, r17, SLOW_DOWN		# Check if KEY1 was pressed
	br			SPEED_DEFAULT			# Default (if everything is broken)

	SPEED_UP:
	subi		r21, r21, 0x50			# Subtract a fixed amount to the current waiting time
	ret
	
	SLOW_DOWN:
	addi		r21, r21, 0x50			# Add a fixed amount to the current waiting time
	ret
	
	SPEED_DEFAULT:
	movia		r21, 0x1F4				# Set the time back to default
	ret

.end
	
