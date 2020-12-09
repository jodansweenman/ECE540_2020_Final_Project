/*
 * 	main.S for swervolf RISC-V core running on Nexys A7
 * 	FPGA target board
 *
 *
 * 	Created By:		Josiah Sweeney
 * 	Last Modified:	11-20-2020
 *
 * 	Description:
 *  ============
 *  This program demonstrate world of tank emulator.  It is used to control the rule of this game.
 *  Such as jumping to different screen, decide which tank is win, count how many times each tank has been
 *  hit and store the value for which is used for history.
 *
 *
 *  This program use keyboard to be input of user to control this game. It reads data from  register
 *
 *  PORT_KEYBOARD
 *
 *  either control the movement of the tank and shot bullets.
 *
 * Keyboard_w          - used to make tank1 go up
 * Keyboard_s          - used to make tank1 go down
 * Keyboard_a          - used to make tank1 go left
 * Keyboard_d          - used to make tank1 go right
 * Keyboard_i          - used to make tank2 go up
 * Keyboard_k          - used to make tank2 go down
 * Keyboard_j          - used to make tank2 go left
 * Keyboard_l          - used to make tank2 go right
 *
 */
# value of each key of the keyboard
Keyboard_w          = 0x1d
Keyboard_s          = 0x1b
Keyboard_a          = 0x1c
Keyboard_d          = 0x23
Keyboard_i          = 0x43
Keyboard_k          = 0x42
Keyboard_j          = 0x3b
Keyboard_l          = 0x4b
MSKORIENT           = 0x07

# ======================
# === Port Addresses ===
# ======================

# Nexys 4 board base I/O interface ports compatible with the Nexy$4 I/O interface
# Port Addresses
PORT_KEYBOARD 		= 0x80001600		# (i) pushbuttons inputs

PORT_BOTINFO		= 0x8000180c		# (i) Bot Info port
PORT_BOTCTRL		= 0x80001810		# (o) Bot Control port
PORT_BOTUPDT		= 0x80001814		# (i) Bot Update port (Poll)
PORT_INTACK			= 0x80001818		# (o) Bot Int Ack

PORT_BOTINFO_1		= 0x8000190c		# (i) Bot Info port
PORT_BOTCTRL_1		= 0x80001910		# (o) Bot Control port
PORT_BOTUPDT_1		= 0x80001914		# (i) Bot Update port (Poll)
PORT_INTACK_1		= 0x80001918		# (o) Bot Int Ack

.text
.globl main
main:

main_1:
                beq   zero, zero, Players_control	# check user input to control tank movement
				jal     loop
				nop
loop:
				beq   zero,zero,main_1				#	} end of the loop


#==================================================================================
Players_control:
				jal	  Keyboard						# call function to read value from keyboard
				li	  s2, 0x00ff					# mask lowest two bits
				and   a2, a4, s2					# just show lowest eight bits for using
				li 	  s2, Keyboard_w
				beq   a2, s2, Player_1				# if the player input is key w,go to check orientation
				li 	  s2, Keyboard_s
				beq	  a2, s2, Player_1				# if the player input is key s,go to check orientation
				li 	  s2, Keyboard_a
				beq	  a2, s2, Player_1				# if the player input is key a,go to check orientation
				li 	  s2, Keyboard_d
				beq	  a2, s2, Player_1				# if the player input is key d,go to check orientation
				li    a1, 0x00						# rather than, let tank stop
				beq   zero, zero, Player_1_next
Player_1:
				jal   expect_orient_1				# call function to generate which orientation user want tank to move
				jal   check_orient_1				# compare with current orientation, ture - go forward, false - turn left until they are same
Player_1_next:
				li 		t5, 	PORT_BOTCTRL		# give value to register to make tank move
				sw		a1,		0(t5)
				nop
#=============================================================================================
				jal	    Keyboard					# call function to read value from keyboard
				srl	    a4, a4, 8					# right shift highest eight bits to lowest
				li 	   s2, Keyboard_i				# if the player input is key i,go to check orientation
				beq    a4, s2, Player_2
				li 	   s2, Keyboard_k				# if the player input is key k,go to check orientation
				beq	   a4, s2, Player_2
				li 	   s2, Keyboard_j				# if the player input is key jal,go to check orientation
				beq	   a4, s2, Player_2
				li 	   s2, Keyboard_l				# if the player input is key l,go to check orientation
				beq	   a4, s2, Player_2
				li     a1, 0x00						# rather than, let tank stop
				beq    zero, zero, Player_2_next
				nop
Player_2:
				jal     expect_orient_2				# if the player input is key d,go to check orientation
				jal     check_orient_2				# compare with current orientation, ture - go forward, false - turn left until they are same
				nop
Player_2_next:
				li 		t5, 	PORT_BOTCTRL_1		# give value to register to make tank move
				sw		a1,		0(t5)
                beq     zero, zero, loop
				nop
# ==============================================================================================
# function used to load value from keyboard
# =================================================================================================
Keyboard:
				li		t5,		PORT_KEYBOARD
				lw		a4, 	0(t5)
				jr 		ra
				nop
#===================================================================================================
# function used to check which orientation user want the tank1 to be
#===============================================================================================
expect_orient_1:
				li 	   	s2, Keyboard_w				# if the player input is key w,go change expect orientation to north
				beq    	a2, s2, Up_1
				li 	   	s2, Keyboard_s				# if the player input is key s,go change expect orientation to south
				beq	   	a2, s2, Down_1
				li 	   	s2, Keyboard_a				# if the player input is key a,go change expect orientation to west
				beq	   	a2, s2, Left_1
				li 	   	s2, Keyboard_d				# if the player input is key d,go change expect orientation to east
				beq	   	a2, s2, Right_1
				jr 		ra
Up_1:
				li 	   	a0, 0x00					# value for orientation north
				jr 		ra
Down_1:
				li 	   	a0, 0x04					# value for orientation south
				jr 		ra
Left_1:
				li 	   	a0, 0x06					# value for orientation west
				jr 		ra
Right_1:
				li 	  	a0, 0x02					# value for orientation east
				jr 		ra
#===============================================================================================
# function used to check current orientation is same as expect orientation or not for tank 1
# ture, go forward
# false, turn left until it be ture
#===============================================================================================
check_orient_1:
				li    	t4, PORT_BOTINFO			# Load the BotInfo port address
				lw 	  	s1, 0(t4)					# Read the BotInfo Register
				and	  	s1,	s1, MSKORIENT		    # mask of the unused bits
				beq   	a0, s1, go_forward_1		# if the current orientation is same as expect orientation, tank go forward
				li 	   	a1, 0x45					# otherwise turn left 90 degree until they are same
				jr 		ra
go_forward_1:
				li 	   	a1, 0xff					# value for moving forward
				jr 		ra
#===============================================================================================
# function used to check which orientation user want the tank2 to be
#===============================================================================================
expect_orient_2:
				li 	   	s2, Keyboard_i				# if the player input is key i,go change expect orientation to north
				beq    	a4, s2, Up_2
				li 	   	s2, Keyboard_k				# if the player input is key k,go change expect orientation to south
				beq	   	a4, s2, Down_2
				li 	   	s2, Keyboard_j				# if the player input is key jal,go change expect orientation to west
				beq	   	a4, s2, Left_2
				li 	   	s2, Keyboard_l				# if the player input is key l,go change expect orientation to east
				beq	   	a4, s2, Right_2
				jr 		ra
Up_2:
				li 	    a0, 0x00					# value for orientation north
				jr 		ra
Down_2:
				li 	   	a0, 0x04					# value for orientation south
				jr 		ra
Left_2:
				li 	   	a0, 0x06					# value for orientation west
				jr 		ra
Right_2:
				li 	   	a0, 0x02					# value for orientation east
				jr 		ra
#===============================================================================================
# function used to check current orientation is same as expect orientation or not for tank 2
# ture, go forward
# false, turn left until it be ture
#===============================================================================================
check_orient_2:
				li    	t4, PORT_BOTINFO_1			# Load the BotInfo port address
				lw 	  	s1, 0(t4)					# Read the BotInfo Register
				and	  	s1,	s1, MSKORIENT		# mask of the unused bits
				beq   	a0, s1, go_forward_2		# if the current orientation is same as expect orientation, tank go forward
				li 	   	a1, 0x45					# otherwise turn left 90 degree until they are same
				jr 		ra
go_forward_2:
				li 	   	a1, 0xff					# value for moving forward
				jr 		ra