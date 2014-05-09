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

	/* r19, r20 are variables for free usage (no global usage). */
	/* r23 stores the button presses (0b1000 k3 pressed, 0b0010 k1 pressed, 0b1010 both pressed) */


	movia		r19, PUSHBUTTON_BASE
	ldwio		r20, 0xC(r19)			# store pressed button in r24
	stwio		r0, 0xC(r19)			# clear the interrupt	
	xor			r23, r23, r20			# store currently pressed button to r23
	ret

.end
	
