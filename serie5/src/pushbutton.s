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

	/* r17 holds the current phase (1=Init 2=Playing 3=Finished) */
	/* r19, r20 are variables for free usage (no global usage). */
	/* We use r20 to store the pressed buttons */

	movia		r19, PUSHBUTTON_BASE
	ldwio		r20, 0xC(r19)			# store pressed buttons in r20
	stwio		r0, 0xC(r19)			# clear the interrupt

	movi		r19, 0x1
	beq			r17, r19, INIT_CHECK	# If we're in Phase 1, perform INIT_CHECK
	
	/* Init check. If both K1 and K3 are pressed, start the game. else simply return */
	INIT_CHECK:
	/* TODO start when k1 AND k3 are pressed, not only k3 */
	movi	r19, 0x8
	beq		r20, r19, START_GAME		# if only K1 and K3 are pressed, start the game
	ret									# else just return
	
	START_GAME:
	movia		r17, 0x2
	ret

	SPEED_UP:
	subi		r21, r21, 0x5			# Subtract a fixed amount to the current waiting time
	ret
	
	SPEED_DEFAULT:
	movia		r21, 0x1F4				# Set the time back to default
	ret

.end
	
