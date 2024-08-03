########################################################################
# Project - Connect Four!
#
#
# Amrit Nandakishor
#
########################################################################


# Constant definitions.
# DO NOT CHANGE THESE DEFINITIONS

# MIPS doesn't have true/false by default
true  = 1
false = 0

# How many pieces we're trying to connect
CONNECT = 4

# The minimum and maximum board dimensions
MIN_BOARD_DIMENSION = 4
MAX_BOARD_WIDTH     = 9
MAX_BOARD_HEIGHT    = 16

# The three cell types
CELL_EMPTY  = '.'
CELL_RED    = 'R'
CELL_YELLOW = 'Y'

# The winner conditions
WINNER_NONE   = 0
WINNER_RED    = 1
WINNER_YELLOW = 2

# Whose turn is it?
TURN_RED    = 0
TURN_YELLOW = 1

########################################################################
# .DATA
# YOU DO NOT NEED TO CHANGE THE DATA SECTION
	.data

# char board[MAX_BOARD_HEIGHT][MAX_BOARD_WIDTH];
board:		.space  MAX_BOARD_HEIGHT * MAX_BOARD_WIDTH

# int board_width;
board_width:	.word 0

# int board_height;
board_height:	.word 0


enter_board_width_str:	.asciiz "Enter board width: "
enter_board_height_str: .asciiz "Enter board height: "
game_over_draw_str:	.asciiz "The game is a draw!\n"
game_over_red_str:	.asciiz "Game over, Red wins!\n"
game_over_yellow_str:	.asciiz "Game over, Yellow wins!\n"
board_too_small_str_1:	.asciiz "Board dimension too small (min "
board_too_small_str_2:	.asciiz ")\n"
board_too_large_str_1:	.asciiz "Board dimension too large (max "
board_too_large_str_2:	.asciiz ")\n"
red_str:		.asciiz "[RED] "
yellow_str:		.asciiz "[YELLOW] "
choose_column_str:	.asciiz "Choose a column: "
invalid_column_str:	.asciiz "Invalid column\n"
no_space_column_str:	.asciiz "No space in that column!\n"


############################################################
####                                                    ####
####   Your journey begins here, intrepid adventurer!   ####
####                                                    ####
############################################################


########################################################################
#
# Implement the following 7 functions,
# and check these boxes as you finish implementing each function
#
#  - [X] main
#  - [X] assert_board_dimension
#  - [X] initialise_board
#  - [X] play_game
#  - [X] play_turn
#  - [X] check_winner
#  - [X] check_line
#  - [X] is_board_full	(provided for you)
#  - [X] print_board	(provided for you)
#
########################################################################


########################################################################
# .TEXT <main>
	.text
main:
	# Args:     void
	# Returns:
	#   - $v0: int
	#
	# Frame:    [$ra]
	# Uses:     [$v0,$a0,$a1,$a2]
	# Clobbers: [$a0,$a1,$a2]
	#
	# Locals:
	#   	- label - board height
	#   	- label - board width 
	#
	# Structure:
	#   main
	#   	-> [prologue]
	#   	-> body
	#   	-> [epilogue]

main__prologue:
	begin						# begin a new stack frame
	push	$ra					# | $ra

main__body:
	
	la	$a0, enter_board_width_str
	li	$v0, 4
	syscall

	li	$v0, 5
	syscall
	
	sw 	$v0, board_width


	lw 	$a0, board_width
	li	$a1, MIN_BOARD_DIMENSION
	li	$a2, MAX_BOARD_WIDTH
	jal	assert_board_dimension


	la	$a0, enter_board_height_str		#printing string
	li	$v0, 4
	syscall

	li	$v0, 5					#scanf()
	syscall 
	
	sw 	$v0, board_height


	lw 	$a0, board_height
	li	$a1, MIN_BOARD_DIMENSION
	li	$a2, MAX_BOARD_HEIGHT
	jal	assert_board_dimension


	jal	initialise_board

	jal	print_board

	jal	play_game



main__epilogue:
	pop	$ra					# | $ra
	end						# ends the current stack frame

	li	$v0, 0
	jr	$ra					# return 0;


########################################################################
# .TEXT <assert_board_dimension>
	.text
assert_board_dimension:
	# Args:
	#   - $a0: int dimension
	#   - $a1: int min
	#   - $a2: int max
	# Returns:  void
	#
	# Frame:    [$ra]
	# Uses:     [$v0,$a0,$a1,$a2]
	# Clobbers: [...]
	#
	# Locals:
	#   - [...]
	#
	# Structure:
	#   	assert_board_dimension
	#   	-> [prologue]
	#   	-> body
	#   	-> [epilogue]

assert_board_dimension__prologue:

	begin						# begin a new stack frame
	push	$ra					# | $ra

assert_board_dimension__body:
	
	bge	$a0, $a1, dimension_min_cond

	la	$a0, board_too_small_str_1
	li	$v0, 4
	syscall

	move	$a0, $a1
	li	$v0, 1
	syscall

	la	$a0, board_too_small_str_2
	li	$v0, 4
	syscall

	li	$a0, 1
	li 	$v0, 17
	syscall
	

dimension_min_cond:

	ble	$a0, $a2, assert_board_dimension__epilogue 

	la	$a0, board_too_large_str_1
	li	$v0, 4
	syscall

	move	$a0, $a2
	li	$v0, 1
	syscall

	la	$a0, board_too_large_str_2
	li	$v0, 4
	syscall

	li	$a0, 1
	li 	$v0, 17
	syscall


assert_board_dimension__epilogue:
	pop	$ra					# | $ra
	end						# ends the current stack frame
	jr	$ra					# return;


########################################################################
# .TEXT <initialise_board>
	.text
initialise_board:
	# Args:     void
	# Returns:  void
	#
	# Frame:    [$ra,$s0]
	# Uses:     [$s0,$t0,$t1,$t2,$t3,$t4,$t5,$t6,$t7,$t8]
	# Clobbers: [$t0,$t1,$t2,$t3,$t4,$t5,$t6,$t7,$t8]
	#
	# Locals:
	#   	- 'row' in $t0
	#   	- 'col' in $t1
	#   	- 'board width' in $t2
	#   	- 'board height' in $t3
	#   	- 'board[0][0]' in $t4
	#  	- 'temporary row value' in $t5 
	#   	- 'row offset' in $t6
	#  	- 'temporary col value' in $t7
	#  	- 'column offset' in $t8
	#
	# Structure:
	#   	initialise_board
	#   	-> [prologue]
	#   	-> body
	#   	-> row_initialise_loop
	#   	-> col_initialise_loop
	#   	-> col_cond
	#   	-> [epilogue]

initialise_board__prologue:
	begin						# begin a new stack frame
	push	$ra					# | $ra
	push	$s0

initialise_board__body:

	li	$t0, 0					#row = 0
	lw	$t2, board_width
	lw	$t3, board_height

row_initialise_loop:

	bge	$t0, $t3, initialise_board__epilogue	#row < board_height

	li	$t1, 0					#col = 0

col_initialise_loop:
	bge	$t1, $t2, col_cond			#col < board_width

	la	$t4, board				#$t4 = board[0][0]

	mul	$t5, $t0, MAX_BOARD_WIDTH
	add	$t6, $t5, $t4				#offset to move down
	mul	$t7, $t1, 1
	add	$t8, $t7, $t6				#offsete to move across


	li	$s0, CELL_EMPTY
	sb	$s0, ($t8)				#storing cell empty in $t8

	addi	$t1, $t1, 1
	j	col_initialise_loop
col_cond:

	addi	$t0, $t0, 1
	j	row_initialise_loop
	


initialise_board__epilogue:
	pop	$s0
	pop	$ra					# | $ra
	end						# ends the current stack frame
	jr	$ra					# return;


########################################################################
# .TEXT <play_game>
	.text
play_game:
	# Args:     void
	# Returns:  void
	#
	# Frame:    [$ra,$s1,$s2]
	# Uses:     [$a0,$v0,$t1,$s1,$s2]
	# Clobbers: [$a0,$t1]
	#
	# Locals:
	#	- 'returned value of is_board_full' in $t1
	#
	# Structure:
	#   	play_game
	#   	-> [prologue]
	#   	-> body
	#   	-> do_loop
	#   	-> next_winner_or_boardfull
	#   	-> game_draw_cond
	#   	-> game_red_cond
	#   	-> [epilogue]

play_game__prologue:

	begin						#begin new stack frame
	push	$ra
	push 	$s1
	push	$s2
	


play_game__body:

	li	$s1, TURN_RED				#whose_turn = TURN_RED
	li	$s2, 0					#winner = 0
	

do_loop:

	move	$a0, $s1		
	jal	play_turn
	move	$s1, $v0				#moving returned value into whose_turn

	jal	print_board

	jal	check_winner
	move 	$s2, $v0				#moving returned value into winner


	jal	is_board_full				#moving returned value into $t1
	move 	$t1, $v0

	bne	$s2, WINNER_NONE, next_winner_or_boardfull 		#multiple condition if statement

	beq	$t1, false, do_loop			#multiple condition if statement 

	j	next_winner_or_boardfull

next_winner_or_boardfull:	

	bne	$s2, WINNER_NONE, game_draw_cond

	la	$a0, game_over_draw_str
	li	$v0, 4
	syscall

	b	play_game__epilogue

game_draw_cond:
	
	bne	$s2, WINNER_RED, game_red_cond

	la	$a0, game_over_red_str
	li	$v0, 4
	syscall

	b	play_game__epilogue

game_red_cond:

	la	$a0, game_over_yellow_str
	li	$v0, 4
	syscall	 

	b	play_game__epilogue


play_game__epilogue:
	
	pop	$s2
	pop	$s1
	pop	$ra
	end						#end stack frame
	jr	$ra					# return;


########################################################################
# .TEXT <play_turn>
	.text
play_turn:
	# Args:
	#   - $a0: int whose_turn
	# Returns:  void
	#
	# Frame:    [$ra,$s0,$s1,$s3,$s4]
	# Uses:     [$a0,$v0,$s0,$s1,$s3,$s4,$t0,$t1,$t2,$t3,$t4,$t5,$t6,$t7,$t8]
	# Clobbers: [$t0,$t1,$t2,$t3,$t4,$t5,$t6,$t7,$t8]
	#
	# Locals:
	#   	- 'target_col' in $t0
	#	- 'target_row' in $t1
	#	- 'board[0][0]' in $t2
	# 	- 'temporary row value' in $t3
	# 	- 'row offset' in $t4
	#	- 'temporary column value' in $t5
	# 	- 'column offset' in $t6
	#	- 'board[target_row][target_column]' in $t7
	#	- 'board_width' in $t8
	#
	# Structure:
	#   	play_turn
	#   	-> [prologue]
	#   	-> body
	#   	-> whose_turn_cond
	#   	-> choose_col
	#   	-> invalid_col_cond
	#   	-> target_row_cell_empty_cond
	#   	-> target_row_cell_empty_loop
	#   	-> red_yellow_turn
	#   	-> red_turn
	#   	-> [epilogue]

play_turn__prologue:

	begin						#begin stack
	push	$ra
	push	$s0
	push	$s1
	push 	$s3
	push 	$s4
	

play_turn__body:

	li	$s3, CELL_RED
	li	$s4, CELL_YELLOW
	lw	$t8, board_width
	li	$s0, CELL_EMPTY
	move 	$s1, $a0

	bne	$s1, TURN_RED, whose_turn_cond		#Whose_turn != TURN_RED

	la	$a0, red_str
	li	$v0, 4
	syscall

	b	choose_col

whose_turn_cond:
	la	$a0, yellow_str
	li	$v0, 4
	syscall

	b	choose_col
	
choose_col:
	la	$a0, choose_column_str
	li	$v0, 4
	syscall

	li	$t0, 0					#target_col = 0

	li	$v0, 5
	syscall
	move	$t0, $v0				#moving scanned value into target_col

	sub	$t0, $t0, 1				#target_col--

	blt	$t0, 0, invalid_col_cond
	lw	$t8, board_width
	bge 	$t0, $t8, invalid_col_cond 				
	b 	target_row_cell_empty_cond

invalid_col_cond: 

	la	$a0, invalid_column_str
	li	$v0, 4
	syscall

	move	$v0, $s1
	b 	play_turn__epilogue


target_row_cell_empty_cond:
	
	lw	$t8, board_height
	sub	$t1, $t8, 1				#target row

	

target_row_cell_empty_loop:

	la	$t2, board				#$t2 = board[0][0]
	
	mul	$t3, $t1, MAX_BOARD_WIDTH
	add	$t4, $t3, $t2				#offset to move down
	mul	$t5, $t0, 1
	add	$t6, $t5, $t4				#offset to move across

	lb	$t7, ($t6)				#loading board[target_row][target_column] in $t7

	blt	$t1, 0, red_yellow_turn
	beq	$t7, $s0, red_yellow_turn


	sub	$t1, $t1, 1				#target_row--

	bge	$t1, 0, target_row_cell_empty_loop

	la	$a0, no_space_column_str
	li	$v0, 4
	syscall

	move	$v0, $s1
	j 	play_turn__epilogue


	j	target_row_cell_empty_loop


red_yellow_turn:

	bne	$s1, TURN_RED, red_turn
	sb	$s3, ($t6)

	li	$v0, TURN_YELLOW
	j	play_turn__epilogue


red_turn:

	sb	$s4, ($t6)

	li	$v0, TURN_RED
	j	play_turn__epilogue


play_turn__epilogue:
	
	pop	$s4
	pop	$s3
	pop	$s1
	pop	$s0
	pop	$ra
	end						#end stack
	jr	$ra					# return;


########################################################################
# .TEXT <check_winner>
	.text
check_winner:
	# Args:	    void
	# Returns:
	#   - $v0: int
	#
	# Frame:    [$ra,$s0,$s1,$s5,$s6]
	# Uses:     [$v0,$a0,$a1,$a2,$a3,$t4,$s0,$s1,$s5,$s6]
	# Clobbers: [$a0,$a1,$a2,$a3,$t4]
	#
	# Locals:
	#   	- 'check' in $t4
	#
	# Structure:
	#   	check_winner
	#   	-> [prologue]
	#   	-> body
	#   	-> row_winner_loop
	#     	  -> col_winner_loop
	#      	  -> check_winner_cond1
	#     	  -> check_winner_cond2
	#     	  -> check_winner_cond3
	#     	  -> check_winner_cond4
	#     	  -> col_winner_cond
	#   	-> row_winner_cond
	#   	-> [epilogue]

check_winner__prologue:

	begin
	push	$ra
	push	$s5
	push	$s6
	push	$s0
	push 	$s1

check_winner__body:


	li	$s5, 0					#row = 0
	lw	$s0, board_height			#loading board_height into $s0
	lw 	$s1, board_width			#loading board_height into $s1
row_winner_loop:

	bge	$s5, $s0, row_winner_cond

	li	$s6, 0					#col = 0

col_winner_loop:

	bge	$s6, $s1, col_winner_cond

	li	$t4, 0					#check = 0

	move	$a0, $s5
	move	$a1, $s6
	li	$a2, 1
	li	$a3, 0
	jal	check_line
	move	$t4, $v0				#move returned value into check
	
	beq	$t4, WINNER_NONE, check_winner_cond1
	move	$v0, $t4
	j 	check_winner__epilogue


check_winner_cond1:
	
	move	$a0, $s5
	move	$a1, $s6
	li	$a2, 0
	li	$a3, 1
	jal	check_line
	move	$t4, $v0				#move returned value into check
	
	beq	$t4, WINNER_NONE, check_winner_cond2
	move	$v0, $t4
	j 	check_winner__epilogue

check_winner_cond2:

	move	$a0, $s5
	move	$a1, $s6
	li	$a2, 1
	li	$a3, 1
	jal	check_line
	move	$t4, $v0				#move returned value into check
	
	beq	$t4, WINNER_NONE, check_winner_cond3
	move	$v0, $t4
	j 	check_winner__epilogue


check_winner_cond3:

	move	$a0, $s5
	move	$a1, $s6
	li	$a2, 1
	li	$a3, -1
	jal	check_line
	move	$t4, $v0				#move returned value into check
	
	beq	$t4, WINNER_NONE, check_winner_cond4
	move	$v0, $t4
	j 	check_winner__epilogue

check_winner_cond4:

	addi	$s6, $s6, 1
	j 	col_winner_loop


col_winner_cond: 

	addi	$s5, $s5, 1
	j	row_winner_loop

row_winner_cond:
	
	li 	$v0, WINNER_NONE
	b	check_winner__epilogue

check_winner__epilogue:
	pop	$s1
	pop 	$s0
	pop	$s6
	pop 	$s5
	pop 	$ra
	end
	jr	$ra					# return;


########################################################################
# .TEXT <check_line>
	.text
check_line:
	# Args:
	#   - $a0: int start_row
	#   - $a1: int start_col
	#   - $a2: int offset_row
	#   - $a3: int offset_col
	# Returns:
	#   - $v0: int
	#
	# Frame:    [$ra,$s0,$s1,$s2,$s3,$s4,$s5,$s6,$s7,$s7]
	# Uses:     [$v0,$s0,$s1,$s2,$s3,$s4,$s5,$s6,$s7,$s7,$a0,$a1,$a2,$a3,$t0,$t1,$t2,$t3,$t4,$t5,$t6,$t7,$t8,$t9]
	# Clobbers: [$t1,$t2,$t3,$t4,$t5,$t6,$t7,$t8,$t9]
	#
	# Locals:
	#   	- 'offset_row' in $t0
	#	- 'offset_col' in $t1
	#	- 'board[0][0]' in $t2
	# 	- 'temporary row value' in $t3
	# 	- 'row offset' in $t4
	#	- 'temporary column value' in $t5
	# 	- 'column offset' in $t6
	#	- 'board[target_row][target_column]' in $t7
	#	- 'i' in $t8
	# 	- 'CONNECT' in $t9
	#
	# Structure:
	#   	check_line
	#   	-> [prologue]
	#   	-> body
	#   	-> check_line_cell_empty_cond
	#   	-> check_line_row_col_loop
	#   	  -> checking_if_winner_none1
	#   	  -> check_line_row_col_cond2
	#   	  -> checking_if_winner_none2
	#   	  -> check_line_cell_cond
	#   	  -> check_line_cell_winner_none_cond
	#   	-> check_line_row_col_cond1
	#   	-> winner_red_cond
	#   	-> [epilogue]

check_line__prologue:

	begin						# begin a new stack frame
	push	$ra					# | $ra
	push	$s5
	push	$s6
	push	$s0
	push	$s7
	push	$s1
	push	$s2
	push	$s3
	push	$s4
	

check_line__body:

	move	$s5, $a0				#moving parameter into start_row
	move	$s6, $a1				#moving parameter into start_col
	move	$t0, $a2				#moving parameter into offset_row
	move	$t1, $a3				#moving parameter into offset_col

	la	$t2, board				#$t2 = board[0][0]


	mul	$t3, $s5, MAX_BOARD_WIDTH
	add	$t4, $t3, $t2				#offset to move down
	mul	$t5, $s6, 1
	add	$t6, $t5, $t4				#offset to move across

	lb	$t7, ($t6)				#loading board[start_row][start_col] into $t7
					
	move	$s4, $t7				#$s4 = first_cell


	bne	$t7, CELL_EMPTY, check_line_cell_empty_cond

	li 	$v0, WINNER_NONE
	b 	check_line__epilogue


check_line_cell_empty_cond:

	add	$s7, $s5, $t0				#row = start_row + offset_row
	add	$s0, $s6, $t1 				#col = start_col + offset_col

	li 	$t8, 0 					#i = 0
	li	$t9, CONNECT				#$t9 = CONNECT
	sub	$s1, $t9, 1				#CONNECT - 1

check_line_row_col_loop:

	bge	$t8, $s1, check_line_row_col_cond1


	blt	$s7, 0, checking_if_winner_none1	#row < 0
	blt	$s0, 0, checking_if_winner_none1	#col < 0

	b	check_line_row_col_cond2


checking_if_winner_none1:

	li	$v0, WINNER_NONE
	b 	check_line__epilogue

check_line_row_col_cond2:

	lw	$s2, board_height			#loading board_height into $s2
	lw	$s3, board_width			#loading board_width inot $s3

	bge	$s7, $s2, checking_if_winner_none2
	bge	$s0, $s3, checking_if_winner_none2

	b 	check_line_cell_cond


checking_if_winner_none2:

	li	$v0, WINNER_NONE
	b 	check_line__epilogue



check_line_cell_cond:

	la	$t2, board				#$t2 = board[0][0]

	mul	$t3, $s7, MAX_BOARD_WIDTH
	add	$t4, $t3, $t2				#offset to move down
	mul	$t5, $s0, 1
	add	$t6, $t5, $t4				#offset to move up

	lb	$t7, ($t6)				#loading board[start_row][start_col] into $t7
							#char cell = $t7

	
	beq	$t7, $s4, check_line_cell_winner_none_cond

	li	$v0, WINNER_NONE
	b 	check_line__epilogue


check_line_cell_winner_none_cond:

	add	$s7, $s7, $t0				#row += offset_row
	add 	$s0, $s0, $t1				#col += offset_col



	addi 	$t8, $t8, 1
	j	check_line_row_col_loop


check_line_row_col_cond1:


	bne	$s4, CELL_RED, winner_red_cond

	li	$v0, WINNER_RED
	b 	check_line__epilogue


winner_red_cond:

	li 	$v0, WINNER_YELLOW
	b 	check_line__epilogue



check_line__epilogue:
	pop	$s4
	pop	$s3
	pop 	$s2
	pop 	$s1
	pop	$s7
	pop	$s0
	pop 	$s6
	pop	$s5
	pop	$ra					# | $ra
	end						# ends the current stack frame
	jr	$ra					# return;


########################################################################
# .TEXT <is_board_full>
# YOU DO NOT NEED TO CHANGE THE IS_BOARD_FULL FUNCTION
	.text
is_board_full:
	# Args:     void
	# Returns:
	#   - $v0: bool
	#
	# Frame:    []
	# Uses:     [$v0, $t0, $t1, $t2, $t3]
	# Clobbers: [$v0, $t0, $t1, $t2, $t3]
	#
	# Locals:
	#   - $t0: int row
	#   - $t1: int col
	#
	# Structure:
	#   is_board_full
	#   -> [prologue]
	#   -> body
	#   -> loop_row_init
	#   -> loop_row_cond
	#   -> loop_row_body
	#     -> loop_col_init
	#     -> loop_col_cond
	#     -> loop_col_body
	#     -> loop_col_step
	#     -> loop_col_end
	#   -> loop_row_step
	#   -> loop_row_end
	#   -> [epilogue]

is_board_full__prologue:
is_board_full__body:
	li	$v0, true

is_board_full__loop_row_init:
	li	$t0, 0						# int row = 0;

is_board_full__loop_row_cond:
	lw	$t2, board_height
	bge	$t0, $t2, is_board_full__epilogue		# if (row >= board_height) goto is_board_full__loop_row_end;

is_board_full__loop_row_body:
is_board_full__loop_col_init:
	li	$t1, 0						# int col = 0;

is_board_full__loop_col_cond:
	lw	$t2, board_width
	bge	$t1, $t2, is_board_full__loop_col_end		# if (col >= board_width) goto is_board_full__loop_col_end;

is_board_full__loop_col_body:
	mul	$t2, $t0, MAX_BOARD_WIDTH			# row * MAX_BOARD_WIDTH
	add	$t2, $t2, $t1					# row * MAX_BOARD_WIDTH + col
	lb	$t3, board($t2)					# board[row][col];
	bne	$t3, CELL_EMPTY, is_board_full__loop_col_step	# if (cell != CELL_EMPTY) goto is_board_full__loop_col_step;

	li	$v0, false
	b	is_board_full__epilogue				# return false;

is_board_full__loop_col_step:
	addi	$t1, $t1, 1					# col++;
	b	is_board_full__loop_col_cond			# goto is_board_full__loop_col_cond;

is_board_full__loop_col_end:
is_board_full__loop_row_step:
	addi	$t0, $t0, 1					# row++;
	b	is_board_full__loop_row_cond			# goto is_board_full__loop_row_cond;

is_board_full__loop_row_end:
is_board_full__epilogue:
	jr	$ra						# return;


########################################################################
# .TEXT <print_board>
# YOU DO NOT NEED TO CHANGE THE PRINT_BOARD FUNCTION
	.text
print_board:
	# Args:     void
	# Returns:  void
	#
	# Frame:    []
	# Uses:     [$v0, $a0, $t0, $t1, $t2]
	# Clobbers: [$v0, $a0, $t0, $t1, $t2]
	#
	# Locals:
	#   - `int col` in $t0
	#   - `int row` in $t0
	#   - `int col` in $t1
	#
	# Structure:
	#   print_board
	#   -> [prologue]
	#   -> body
	#   -> for_header_init
	#   -> for_header_cond
	#   -> for_header_body
	#   -> for_header_step
	#   -> for_header_post
	#   -> for_row_init
	#   -> for_row_cond
	#   -> for_row_body
	#     -> for_col_init
	#     -> for_col_cond
	#     -> for_col_body
	#     -> for_col_step
	#     -> for_col_post
	#   -> for_row_step
	#   -> for_row_post
	#   -> [epilogue]

print_board__prologue:
print_board__body:
	li	$v0, 11			# syscall 11: print_int
	la	$a0, '\n'
	syscall				# printf("\n");

print_board__for_header_init:
	li	$t0, 0			# int col = 0;

print_board__for_header_cond:
	lw	$t1, board_width
	blt	$t0, $t1, print_board__for_header_body	# col < board_width;
	b	print_board__for_header_post

print_board__for_header_body:
	li	$v0, 1			# syscall 1: print_int
	addiu	$a0, $t0, 1		#              col + 1
	syscall				# printf("%d", col + 1);

	li	$v0, 11			# syscall 11: print_character
	li	$a0, ' '
	syscall				# printf(" ");

print_board__for_header_step:
	addiu	$t0, 1			# col++
	b	print_board__for_header_cond

print_board__for_header_post:
	li	$v0, 11
	la	$a0, '\n'
	syscall				# printf("\n");

print_board__for_row_init:
	li	$t0, 0			# int row = 0;

print_board__for_row_cond:
	lw	$t1, board_height
	blt	$t0, $t1, print_board__for_row_body	# row < board_height
	b	print_board__for_row_post

print_board__for_row_body:
print_board__for_col_init:
	li	$t1, 0			# int col = 0;

print_board__for_col_cond:
	lw	$t2, board_width
	blt	$t1, $t2, print_board__for_col_body	# col < board_width
	b	print_board__for_col_post

print_board__for_col_body:
	mul	$t2, $t0, MAX_BOARD_WIDTH
	add	$t2, $t1
	lb	$a0, board($t2)		# board[row][col]

	li	$v0, 11			# syscall 11: print_character
	syscall				# printf("%c", board[row][col]);
	
	li	$v0, 11			# syscall 11: print_character
	li	$a0, ' '
	syscall				# printf(" ");

print_board__for_col_step:
	addiu	$t1, 1			# col++;
	b	print_board__for_col_cond

print_board__for_col_post:
	li	$v0, 11			# syscall 11: print_character
	li	$a0, '\n'
	syscall				# printf("\n");

print_board__for_row_step:
	addiu	$t0, 1
	b	print_board__for_row_cond

print_board__for_row_post:
print_board__epilogue:
	jr	$ra			# return;

