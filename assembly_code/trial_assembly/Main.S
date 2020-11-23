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
 * Keyboard_q          - used to make tank1 shot bullet
 * Keyboard_u          - used to make tank2 shot bullet
 *
 * and then give the data back to register
 *
 * PORT_BOTCTRL        - used to control tank1 movement
 * PORT_BOTCTRL_1      - used to control tank1 movement
 * PORT_BULLET         - used to control both tank shotting, 0x01 for tank1, 0x02 for tank2
 *
 * and it is used to control jump to different screen
 * Keyboard_enter      - used to jump screens
 *
 *Moveover, it will read data from register
 *
 *PORT_HIT - used to show which tank is hit and which tank's base is hit.
 * 	         PORT_HIT[3] - red tank base is hit.  PORT_HIT[2] - red tank is hit.
 *           PORT_HIT[1] - green tank base is hit.  PORT_HIT[0] - green tank is hit.
 *
 * to count how may tank is hit, check base is hit or not and then detect which tank is win.
 *
 *Also it will give register
 *PORT_FRAME - used to control which screen should be displayed
 *PORT_HISTORY - used to control which tank should be shown in history screen
 * 	         PORT_HISTORY[5:4] - third game history.
 *           PORT_HISTORY[3:2] - second game history.
 *           PORT_HISTORY[1:0] - first game history.
 *
 *by using
 *
 * Screen_loading		- value to display loading screen
 * Screen_play			- value to display play screen
 * Screen_green_win		- value to display green_win screen
 * Screen_red_win		- value to display red_win screen
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

; PORT_BULLET			= 0xbf800038		#(o) Shot bullet Control port
; PORT_HIT			= 0xbf80002c		#(i) Detecting which tank or base is hit port
; PORT_FRAME 			= 0xbf800030		#(o) Screen Control port
; PORT_HISTORY		= 0xbf800034 		#(o) Tank display control port for histroy screen

# Value to screen control port to display each screen
; Screen_loading		= 0x01
; Screen_play			= 0x02
; Screen_green_win	= 0x04
; Screen_red_win		= 0x08
; Screen_history		= 0x10
; .data
; .align 2    # Put next label on a word boundary


# stack for scrren control to store which screen should be displayed
SP_SCREEN:	.byte   0
# stack for stroing how many times the tank has been hit
SP_GREEN_HITTED: .byte  0
SP_RED_HITTED: .byte 0
# stack for storing flag of each time the tank has been hit
SP_GREEN_HITTED_TIME: .byte 0
SP_RED_HITTED_TIME: .byte 0
# stack for storing the which tank is win in history
SP_GAME_1: .byte 0
SP_GAME_2: .byte 0
SP_GAME_3: .byte 0


.text
.globl main
main:

				li	  a5, Screen_loading   			# first give the screen stroge stack value for loading scrren
			    sb    a5,  SP_SCREEN				# store the value to stack
main_1:
				lb    a5,  SP_SCREEN				# at the beginning of loop, load the value from stack to tell which screen it should be
				jal   Screen						# call function to store the value to register to control screen
				li    a4, Screen_loading
				beq   a5, a4, check_tab_1			# if it is in loading screen, go to check_tab_1 to read value from keyboard
				li    a4, Screen_play
				beq   a5, a4, play_screen			# if it is in play screen, go to play screen to read value from user to control tank
				li    a4, Screen_green_win
				beq   a5, a4, check_tab_2			# if it is in green win screen, go to check_tab_2 to read value from keyboard
				li    a4, Screen_red_win
				beq   a5, a4, check_tab_2			# if it is in red win screen, go to check_tab_2 to read value from keyboard
				li    a4, Screen_history
				beq   a5, a4, check_tab_3			# if it is in history screen, go to check_tab_3 to read value from keyboard
				jal     loop
				nop
check_tab_1:
				jal   Keyboard						# call function to read value from keyboard
				li	  s2, 0x00ff					# mask lowest two bits
				and   a2, a4, s2					# just show lowest two bits for using
				li    a5, Keyboard_1				# if the input value is key 1
				beq   a2, a5, j_screen_2			# go to play screen
				li    a5, Keyboard_2				# if the input value is key 2
				beq   a2, a5, j_screen_5			# go to history screen
				jal  	  loop						# if no any input, stay loading screen
				nop
check_tab_2:
				jal   Keyboard						# call function to read value from keyboard
				li	  s2, 0x00ff					# mask lowest two bits
				and   a2, a4, s2					# just show lowest two bits for using
				li    a5, Keyboard_space			# if the input value is key space
				beq   a2, a5, main					# go to loading screen
				jal  	  loop						# if no any input, stay either tank win screen
				nop
check_tab_3:
				jal   Keyboard						# call function to read value from keyboard
				li	  s2, 0x00ff					# mask lowest two bits
				and   a2, a4, s2					# just show lowest two bits for using
				li    a5, Keyboard_space			# if the input value is key space
				beq   a2, a5, main					# go to loading screen
				jal  	  loop						# if no any input, stay history screen
				nop
j_screen_1:
				li    t0, Screen_loading			# give the value for going to loading screen
				sb    t0, SP_SCREEN					# give this value to register to enable this screen
				jal     loop
				nop
j_screen_2:
				li    t0, Screen_play				# give the value for going to play screen
				sb    t0, SP_SCREEN					# give this value to register to enable this screen
				jal   loop
				nop
j_screen_5:
				li    t0, Screen_history			# give the value for going to history screen
				sb    t0, SP_SCREEN					# give this value to register to enable this screen
				lb    a5, SP_GAME_1					# load value from fisrt game history stack
				lb    a2, SP_GAME_2					# load value from second game history stack
				lb    a3, SP_GAME_3					# load value from third game history stack
				sll   a2, a2, 2
				or    a5, a5, a2
				sll   a3, a3, 4
				or    a5, a5, a3					# or this three value and shift them to correct bits
				li    t5, PORT_HISTORY				# load the PORT_HISTORY
				sw    a5, 0(t5)					    # store the value to this register to enable which tank should be display
				jal   loop
				nop
play_screen:
				li    a5,  0x1c						# give value for monsters shoting
				li 	  t5, PORT_BULLET				# load value for PORT_BULLET register
				sw	  a5, 0(t5)					    # give value to this regiser make monsters shotting automatically
				beq   zero, zero, Players_control	# check user input to control tank movement and shotting
Check_Hitted:
				beq   zero, zero, GREEN_HITTED		# check either tank or base is hit
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

				li      s2, Keyboard_q		        # check key left shift is pressed or not
				beq     a2, s2, shot_1				# if ture, shot bullet
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
				jal     check_orient_2				# compare with current orientation, ture - go forward, false - turn left until they are same
				nop
Player_2_next:
				li 		t5, 	PORT_BOTCTRL_1		# give value to register to make tank move
				sw		a1,		0(t5)

				li      s2, Keyboard_u	            # check key right shift is pressed or not
				beq     a4, s2, shot_2				# if ture, shot bullet
				li      a5, 0x00					# if false, don't shot
				beq     zero, zero,   shot_2_next
shot_2:			li		a5, 0x02
shot_2_next:
				li 		t5, 	PORT_BULLET			# store value to register to FPGA
				sw		a5,		0(t5)

				beq     zero, zero,   Check_Hitted	# go to check hit label to check either tank or base is hit
				nop
# ==============================================================================================
# function used to load value from keyboard
# =================================================================================================
Keyboard:
				li		t5,		PORT_KEYBOARD
				lw		a4, 	0(t5)
				jr 		$ra
				nop
#===================================================================================================
# function usd to give value to screen control port
#===================================================================================================
Screen:
				li	  	t5, PORT_FRAME
				sw    	a5, 0(t5)
				jr 		$ra
				nop
#=-=============================================================================================
# function used to load value from hit port register to indicate which tank or base is hit
#=-=============================================================================================
hit:
				li    	t5, PORT_HIT
				lw    	a4, 0(t5)
				jr 		$ra
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
				jr 		$ra
Up_1:
				li 	   	a0, 0x00					# value for orientation north
				jr 		$ra
Down_1:
				li 	   	a0, 0x04					# value for orientation south
				jr 		$ra
Left_1:
				li 	   	a0, 0x06					# value for orientation west
				jr 		$ra
Right_1:
				li 	  	a0, 0x02					# value for orientation east
				jr 		$ra
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
				jr 		$ra
go_forward_1:
				li 	   	a1, 0xff					# value for moving forward
				jr 		$ra
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
				jr 		$ra
Up_2:
				li 	    a0, 0x00					# value for orientation north
				jr 		$ra
Down_2:
				li 	   	a0, 0x04					# value for orientation south
				jr 		$ra
Left_2:
				li 	   	a0, 0x06					# value for orientation west
				jr 		$ra
Right_2:
				li 	   	a0, 0x02					# value for orientation east
				jr 		$ra
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
				jr 		$ra
go_forward_2:
				li 	   	a1, 0xff					# value for moving forward
				jr 		$ra
# ==================================================================================================
GREEN_HITTED:
				li    	s2, PORT_HIT
				lw    	t0, 0(s2)					# load value from register hit port to check tank 1 is hit
				li	  	t1, 0x01
				and   	t0, t1, t0
				beq   	t0, zero, ADD_GREEN_TIME		# if tank 1 is not hit, go and add tank 1 hit time
				li   	a4, 0x01
				sb   	a4, SP_GREEN_HITTED_TIME	# if tank 1 is hit, store true to hit flag
				beq  	zero, zero, GREEN_BASE_HITTED	# and add hit time until the hit signal to low
# ==================================================================================================
ADD_GREEN_TIME:
				lb   	t3, SP_GREEN_HITTED_TIME	# load value from hit flag
				beq  	t3, zero, GREEN_BASE_HITTED	# if the flag is flase, go check base is hit
				lb   	t1, SP_GREEN_HITTED			# if the flag is true, load from from tank 1 hit time stack
				addi 	t1, t1, 0x01				# add 1 more time
				sb   	t1, SP_GREEN_HITTED			# store the time number back to stack
				sb   	zero, SP_GREEN_HITTED_TIME	# clean up the flag stack
				li   	t2, 0x03					# if the hit time is equal to 3, say tank 2 is win
				beq  	t1, t2, win_red			# go to tank 2 win screen
				beq  	zero, zero, GREEN_BASE_HITTED	# if not, go check tank 1 base is hit or not
# ==================================================================================================
GREEN_BASE_HITTED:
				li    	s2, PORT_HIT				# load value from register hit port to check tank 1 base is hit
				lw    	t0, 0(s2)
				li	  	t1, 0x02
				and   	t0, t1, t0
				beq   	t0, t1, win_red				# if it is hit, go to red win screen
				beq  	zero, zero,RED_HITTED			# if not, go check tank 2 is hit or not
# ==================================================================================================
RED_HITTED:
				li    	s2, PORT_HIT				# load value from register hit port to check tank 2 is hit
				lw    	t0, 0(s2)
				li	  	t1, 0x04
				and   	t0, t1, t0
				beq   	t0, zero, ADD_RED_TIME		# if tank 2 is not hit, go and add tank 2 hit time
				li   	a4, 0x01
				sb   	a4, SP_RED_HITTED_TIME		# if tank 2 is hit, store true to hit flag
				beq  	zero, zero, RED_BASE_HITTED		# and add hit time until the hit signal to low
ADD_RED_TIME:
				lb   	t3, SP_RED_HITTED_TIME		# load value from hit flag
				beq  	t3, zero, RED_BASE_HITTED	# if the flag is flase, go check base is hit
				lb   	t1, SP_RED_HITTED			# if the flag is true, load from from tank 2 hit time stack
				addi 	t1, t1, 0x01				# add 1 more time
				sb   	t1, SP_RED_HITTED			# store the time number back to stack
				sb   	zero, SP_RED_HITTED_TIME		# clean up the flag stack
				li   	t2, 0x03					# if the hit time is equal to 3, say tank 1 is win
				beq  	t1, t2, win_green			# go to tank 1 win screen
				beq  	zero, zero, RED_BASE_HITTED		# if not, go check tank 2 base is hit or not
# ==================================================================================================
RED_BASE_HITTED:
				li    	s2, PORT_HIT				# load value from register hit port to check tank 2 base is hit
				lw    	t0, 0(s2)
				li	  	t1, 0x08
				and   	t0, t1, t0
				beq   	t0, t1, win_green			# if it is hit, go to green win screen
				beq  	zero, zero,loop					# if not, go back to loop to wait either one is hit
# ==================================================================================================
win_red:
				li    	a5, Screen_red_win			# give value to register to go to red win screen
				sb    	a5, SP_SCREEN
				lb    	a2, SP_GAME_1				# load value from first game results stack
				lb    	a3, SP_GAME_2				# load value from second game results stack
				sb 	  	a2, SP_GAME_2				# store value from first game results stack to second game results stack
				sb 	  	a3, SP_GAME_3				# store value from second game results stack to third game results stack
				li    	a2, 0x02					# give the value to show red tank is win
				sb    	a2, SP_GAME_1				# store value to first game results stack
				sb    	zero, SP_RED_HITTED			# clean up red tank hit time stack
				sb    	zero, SP_GREEN_HITTED			# clean up green tank hit time stack
			    beq  	zero, zero, loop
# ==================================================================================================
win_green:
				li    	a5, Screen_green_win		# give value to register to go to red win screen
				sb    	a5, SP_SCREEN
				lb    	a2, SP_GAME_1				# load value from first game results stack
				lb    	a3, SP_GAME_2				# load value from second game results stack
				sb 	  	a2, SP_GAME_2				# store value from first game results stack to second game results stack
				sb 	  	a3, SP_GAME_3				# store value from second game results stack to third game results stack
				li    	a2, 0x01					# give the value to show green tank is win
				sb    	a2, SP_GAME_1				# store value to first game results stack
				sb    	zero, SP_RED_HITTED			# clean up red tank hit time stack
				sb    	zero, SP_GREEN_HITTED			# clean up green tank hit time stack
			    beq 	zero, zero, loop
# ==================================================================================================