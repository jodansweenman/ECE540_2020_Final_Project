/*
 * 	main.S for swervolf RISC-V core running on Nexys A7
 * 	FPGA target board
 *
 *
 * 	Created By:		Josiah Sweeney
 * 	Last Modified:	12-08-2020
 *
 * 	Description:
 *  ============
 *  This program demonstrate world of tank emulator.  It is used to control the rule of this game.
 *  Such as jumping to different screen, decide which tank is winning, count how many times each tank has been
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
 * Keyboard_q          - used to make tank1 shot bullet
 * Keyboard_u          - used to make tank2 shot bullet
 *
 * and then give the data back to register
 *
 * PORT_BOTCTRL        - used to control tank1 movement
 * PORT_BOTCTRL_1      - used to control tank1 movement
 * PORT_BULLET         - used to control both tank shooting, 0x01 for tank1, 0x02 for tank2
 *
 * and it is used to control jump to different screen
 * Keyboard_enter      - used to jump screens
 *
 *Moveover, it will read data from register
 *
 *PORT_HIT - used to show which tank is hit and which tank's base is hit.
 * 	         PORT_HIT[1] - train is hit.
 *           PORT_HIT[0] - tank is hit.
 *
 * to count how may tank is hit, check base is hit or not and then detect which tank is win.
 *
 *Also it will give register
 *PORT_FRAME - used to control which screen should be displayed
 *
 *by using
 *
 * Screen_loading		- value to display loading screen
 * Screen_play			- value to display play screen
 * Screen_tank_win		- value to display green_win screen
 * Screen_train_win		- value to display red_win screen
 * Screen_history		- value to display history screen
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
Keyboard_q          = 0x15
Keyboard_u          = 0x3c
Keyboard_enter      = 0x5a
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

PORT_HIT			= 0x80001840		# (i) Detecting which tank or base is hit port
PORT_FRAME 			= 0x80001830		# (o) Screen Control port
PORT_BULLET			= 0x80001820		# (o) Shot bullet Control port

# Value to screen control port to display each screen
Screen_loading		= 0x01
Screen_play			= 0x02
Screen_tank_win		= 0x04
Screen_train_win	= 0x08



.text
.globl main
main:

				li	  a5, Screen_loading   			# first give the screen stroge stack value for loading screen
                la t6, SP_SCREEN                    # store the value to stack
                sb a5, 0(t6)
main_1:
				lb    a5,  SP_SCREEN				# at the beginning of loop, load the value from stack to tell which screen it should be
				jal   Screen						# call function to store the value to register to control screen
				li    a4, Screen_loading
				beq   a5, a4, check_tab_1			# if it is in loading screen, go to check_tab_1 to read value from keyboard
				li    a4, Screen_play
				beq   a5, a4, play_screen			# if it is in play screen, go to play screen to read value from user to control tank
                li    a4, Screen_tank_win
				beq   a5, a4, check_tab_2			# if it is in tank win screen, go to check_tab_2 to read value from keyboard
				li    a4, Screen_train_win
				beq   a5, a4, check_tab_2			# if it is in train win screen, go to check_tab_2 to read value from keyboard
				jal     loop
				nop
check_tab_1:
				jal   Keyboard						# call function to read value from keyboard
				li	  s2, 0x00ff					# mask lowest two bits
				and   a2, a4, s2					# just show lowest two bits for using
				li    a5, Keyboard_enter				# if the input value is key 1
				beq   a2, a5, j_screen_2			# go to play screen
				jal  	  loop						# if no any input, stay loading screen
				nop
check_tab_2:
				jal   Keyboard						# call function to read value from keyboard
				li	  s2, 0x00ff					# mask lowest two bits
				and   a2, a4, s2					# just show lowest two bits for using
				li    a5, Keyboard_enter			# if the input value is key space
				beq   a2, a5, main					# go to loading screen
				jal  	  loop						# if no any input, stay either tank win screen
				nop
j_screen_2:
				li    t0, Screen_play				# give the value for going to play screen
                la    t6, SP_SCREEN
                sb    t0, 0(t6)
				jal   loop
				nop
play_screen:
				beq   zero, zero, Players_control	# check user input to control tank movement and shooting
Check_Hits:
				beq   zero, zero, Tank_Hit		# check either tank or base is hit
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
				jal   check_orient_1				# compare with current orientation, true - go forward, false - turn left until they are same
Player_1_next:
				li 		t5, 	PORT_BOTCTRL		# give value to register to make tank move
				sw		a1,		0(t5)

				li      s2, Keyboard_q		        # check key left shift is pressed or not
				beq     a2, s2, shot_1				# if true, shot bullet
				li      a5, 0x00					# if false, don't shot
				beq     zero, zero,   shot_1_next
shot_1:			li		a5, 0x01
shot_1_next:
				li 		t5, 	PORT_BULLET			# store value to register to FPGA
				sw		a5,		0(t5)
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
				jal     check_orient_2				# compare with current orientation, true - go forward, false - turn left until they are same
				nop
Player_2_next:
				li 		t5, 	PORT_BOTCTRL_1		# give value to register to make tank move
				sw		a1,		0(t5)

				li      s2, Keyboard_u	            # check key right shift is pressed or not
				beq     a4, s2, shot_2				# if true, shot bullet
				li      a5, 0x00					# if false, don't shot
				beq     zero, zero,   shot_2_next
shot_2:			li		a5, 0x02
shot_2_next:
				li 		t5, 	PORT_BULLET			# store value to register to FPGA
				sw		a5,		0(t5)

				beq     zero, zero,   Check_Hits	# go to check hit label to check either tank or base is hit
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
# function usd to give value to screen control port
#===================================================================================================
Screen:
				li	  	t5, PORT_FRAME
				sw    	a5, 0(t5)
				jr 		ra
				nop
#===============================================================================================
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
# true, go forward
# false, turn left until it be true
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
# true, go forward
# false, turn left until it be true
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
# ==================================================================================================
Tank_Hit:
				li    	s2, PORT_HIT
				lw    	t0, 0(s2)					# load value from register hit port to check tank 1 is hit
				li	  	t1, 0x01
				and   	t0, t1, t0
				beq   	t0, zero, Add_Tank_Hit		# if tank 1 is not hit, go and add tank 1 hit time
				li   	a4, 0x01
				la      t6, SP_TANK_HIT_COUNT
                sb      a4, 0(t6)
				beq		zero, zero, Tank_Hit
# ==================================================================================================
Add_Tank_Hit:
				lb   	t3, SP_TANK_HIT_COUNT	# load value from hit flag
				lb   	t1, SP_TANK_HIT			# if the flag is true, load from from tank 1 hit time stack
				addi 	t1, t1, 0x01				# add 1 more time
				la      t6, SP_TANK_HIT
                sb      t1, 0(t6)
				la      t6, SP_TANK_HIT_COUNT
                sb      zero, 0(t6)
                li   	t2, 0x03					# if the hit time is equal to 3, say tank 2 is win
				beq  	t1, t2, win_train			# go to tank 2 win screen
				beq		zero, zero, Train_Hit
# ==================================================================================================
Train_Hit:
				li    	s2, PORT_HIT				# load value from register hit port to check tank 2 is hit
				lw    	t0, 0(s2)
				li	  	t1, 0x02
				and   	t0, t1, t0
				beq   	t0, zero, Add_Train_Hit		# if tank 2 is not hit, go and add tank 2 hit time
				li   	a4, 0x01
				la      t6, SP_TRAIN_HIT_COUNT
                sb      a4, 0(t6)
                beq  	zero, zero, loop		# and add hit time until the hit signal to low
Add_Train_Hit:
				lb   	t3, SP_TRAIN_HIT_COUNT		# load value from hit flag
				lb   	t1, SP_TRAIN_HIT			# if the flag is true, load from from tank 2 hit time stack
				addi 	t1, t1, 0x01				# add 1 more time
				la      t6, SP_TRAIN_HIT
                sb      t1, 0(t6)
				la      t6, SP_TRAIN_HIT_COUNT
                sb      zero, 0(t6)
                li   	t2, 0x03					# if the hit time is equal to 3, say tank 1 is win
				beq  	t1, t2, win_tank			# go to tank 1 win screen
				beq  	zero, zero, loop		# if not, go check tank 2 base is hit or not
# ==================================================================================================
win_train:
				li    	a5, Screen_train_win			# give value to register to go to train win screen
				la      t6, SP_SCREEN
                sb      a5, 0(t6)
				la      t6, SP_TRAIN_HIT
                sb      zero, 0(t6)
			    la      t6, SP_TANK_HIT
                sb      zero, 0(t6)
                beq  	zero, zero, loop
# ==================================================================================================
win_tank:
				li    	a5, Screen_tank_win		# give value to register to go to train win screen
				la      t6, SP_SCREEN
                sb      a5, 0(t6)
				la      t6, SP_TRAIN_HIT
                sb      zero, 0(t6)
			    la      t6, SP_TANK_HIT
                sb      zero, 0(t6)
                beq 	zero, zero, loop
# ==================================================================================================
.section .data
.align 2    # Put next label on a word boundary


# stack for scrren control to store which screen should be displayed
SP_SCREEN:	.byte   0
# stack for stroing how many times the tank has been hit
SP_TANK_HIT: .byte  0
SP_TRAIN_HIT: .byte 0
# stack for storing flag of each time the tank has been hit
SP_TANK_HIT_COUNT: .byte 0
SP_TRAIN_HIT_COUNT: .byte 0