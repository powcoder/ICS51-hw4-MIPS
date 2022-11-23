https://powcoder.com
代写代考加微信 powcoder
Assignment Project Exam Help
Add WeChat powcoder
.include "hw4_your1.asm"

.data
welcome: .asciiz "===============================\nWelcome to the ICS51 Chess Game\n===============================\n"
game_str: .asciiz "\nWould you like to play a (N)ew Game or (L)oad a Game? "
lightcolor_str: .asciiz "\nEnter a number [1-14] for the light board square: "
darkcolor_str: .asciiz "\nEnter a number [1-14] for the dark board square: "
main_filename_str: .asciiz "\nEnter the name of the file (max 47 chars): "
main_filename_error: .asciiz "Error opening file! Try again."
p1_turn_str: .asciiz "\n===================\nPlayer 1's turn"
p2_turn_str: .asciiz "\n===================\nPlayer 2's turn"
enter_from_move: .asciiz "\nEnter the Chess square to move from (eg. A5):"
enter_to_move: .asciiz "\nEnter the Chess square to move to (eg. H8):"
invalid_move_str: .asciiz "\nInvalid move!"
piece_captured_str: .asciiz "\nYou captured a "
check_str: .asciiz "\nPlayer calls \"CHECK\"\n"
game_won_str: .asciiz "\nKing Captured! Player Won!!!!\nGAME OVER"
nopieces_str: .asciiz "\nOne of the players does not have any pieces!!!\n"
nopieces_won_str: .asciiz "\nPlayer Won!!!! \nGAME OVER"
lightcolor: .word 0
darkcolor: .word 0
fgcolor: .word 0x0E
kingpos: .word 0x0704, 0x0004  # [0] p1 init king position, [1] p2 init

.text 
.globl main

main:
	li $v0, 4
	la $a0, welcome
	syscall

main_lightcolor:
	li $v0, 4
	la $a0, lightcolor_str
	syscall
	
	li $v0, 5
	syscall
	
	blt $v0, 1, main_lightcolor
	bge $v0, 15, main_lightcolor
	sw $v0, lightcolor

main_darkcolor:
	li $v0, 4
	la $a0, darkcolor_str
	syscall
	
	li $v0, 5
	syscall
	
	blt $v0, 1, main_darkcolor
	bge $v0, 15, main_darkcolor
	sw $v0, darkcolor
	
main_restart_board:
	lw $a0, fgcolor  # fg always red
	lw $a1, darkcolor  #dark
	lw $a2, lightcolor	# light
	jal initBoard

main_game_start:
	li $v0, 4
	la $a0, game_str
	syscall

	li $v0, 12
	syscall
	beq $v0, 'N', main_newgame
	beq $v0, 'L', main_loadgame
	j main_game_start

main_newgame:
	jal initPieces
	li $s6, 16 # num pieces for p1
	li $s7, 16 # num pieces for p2	
	j main_playgame

main_loadgame:
	addi $sp, $sp, -48
	li $v0, 4
	la $a0, main_filename_str 
	syscall
	move $a0, $sp
	li $a1, 48
	li $v0, 8
	syscall
	move $a0, $sp # replace '\n' with '\0'
	jal replaceNewline
	move $a0, $sp
	jal loadGame

	bgtz $v0, main_set_pieces
	li $v0, 4
	la $a0, main_filename_error
	syscall
	j main_loadgame
main_nopieces:
	li $v0, 4
	la $a0, nopieces_str
	syscall
	j main_restart_board

main_set_pieces:
	move $s6, $v0 # num pieces for p1
    move $s7, $v1 # num pieces for p2
	blez $s6, main_nopieces
	blez $s7, main_nopieces

main_playgame:
	jal findKings  # find the kings
	la $t0, kingpos
	sw $v0, 0($t0)  # save the kings
	sw $v1, 4($t0)

	addi $sp, $sp, 48	# put space back for filename
	addi $sp, $sp, -12	# create space for Chess Moves
	li $s0, 1#current player #

main_player_move:
	#player move
	li $v0, 4
	beq $s0, 2, main_p2
		la $a0, p1_turn_str
		j main_print_move
main_p2:
		la $a0, p2_turn_str
main_print_move:
	syscall

main_enter_from_move:
	li $v0, 4
	la $a0, enter_from_move
	syscall	
	
	li $v0, 8 
	addi $a0, $sp, 4  # from at 4($sp)
	li $a1, 3
	syscall
	
	lb $a0, 4($sp) # load char from 4($sp) - letter
	lb $a1, 5($sp) # load char from 5($sp) - num
	jal mapChessMove
	
	li $t1, 0xFFFF
	beq $v0, $t1, main_enter_from_move  # invalid move
	move $s1, $v0	# save the from move
	move $a0, $v0
	jal getChessPiece
	la $ra, main_enter_from_move
	bne $v1, $s0, main_player_invalidmove		# move does not have a piece	
main_enter_to_move:
	li $v0, 4
	la $a0, enter_to_move
	syscall	
	
	li $v0, 8 
	addi $a0, $sp, 8  # from at 8($sp)
	li $a1, 3
	syscall
	
	lb $a0, 8($sp) # load char from 8($sp) - letter
	lb $a1, 9($sp) # load char from 9($sp) - num
	jal mapChessMove

	li $t1, 0xFFFF
	beq $v0, $t1, main_enter_to_move  # invalid move

	move $a0, $s0   # current player
	move $a1, $s1	# from position
	move $a2, $v0	# to postion
	lw   $a3, fgcolor  # fg color
	la $t0, kingpos		# put address of p1 king pos
	beq $s0, 1, main_perform_move
	addi $t0, $t0, 4  # put address of p2 king pos
main_perform_move:
	sw $t0, 0($sp)  # put king pos on the stack	  
	jal perform_move
	bltz $v0, main_player_invalidmove  # invalid movement (-2 or -1 then bad move try again)
	bnez $v0, main_pieceCaptured 

main_perform_check:
	move $a0, $s0  # current player
	la $a1, kingpos
	bne $a0, 1, main_call_check
	addi $a1, $a1, 4 
main_call_check:
	lw $a1, 0($a1)
	jal check

	bnez $v0, main_swap_players
	# in check!
	li $v0, 4
	la $a0, check_str
	syscall


main_swap_players:
	# swap players
	sll $s0, $s0, 1
	bgt $s0, 2, main_makep1
	j main_player_move
main_makep1:
	addi $s0, $0, 1	 # p1 turn
	j main_player_move

main_pieceCaptured:
	bne $v1, 'K', main_pieceCaptured_notKing
	li $v0, 4
	la $a0, game_won_str
	syscall

	li $v0, 10  #Exit game
	syscall
	
main_pieceCaptured_notKing:
	#print out that a piece was captured!!!
	li $v0, 4
	la $a0, piece_captured_str
	syscall

	li $v0, 11
	move $a0, $v1
	syscall

	li $v0, 11
	li $a0, '\n'
	syscall

	# Reduce the number of pieces for the player who was captured
	beq $s0, 1, main_captured_P2
	addi $s6, $s6, -1  # reduce P1 piece count
	beqz $s6, main_game_over
	j main_done_captured
main_captured_P2:
	addi $s7, $s7, -1  # reduce P2 piece count
	beqz $s7, main_game_over
main_done_captured:
	j main_perform_check

main_player_invalidmove:
	li $v0, 4
	la $a0, invalid_move_str
	syscall
	j main_enter_from_move

main_game_over:
	li $v0, 4
	la $a0, nopieces_won_str
	syscall
	
	li $v0, 10  #Exit game
	syscall
	

#(short p1pos, short p2pos) findKings(void)
findKings:
	addi $sp, $sp, -16
	sw $ra, 0($sp)
	sw $s0, 4($sp)
	sw $s1, 8($sp)   # p1 king
	sw $s2, 12($sp)  # p2 king
	li $s1, -1  # neither king found
	li $s2, -1  # neither king found

	li $s0, 0 # (0,0)
findKings_start:
	beq $s0, 0x0707, findKings_done
	move $a0, $s0
	jal getChessPiece
	beq $v0, 'K', findKings_found
	j findKings_notDone

findKings_found:
	beq $v1, 1, findKings_p1
	move $s2, $s0   # King p2 found  
	beq $s1, -1, findKings_notDone 
	j findKings_found_done  # both kings found, stop
findKings_p1:
	move $s1, $s0   # King p1 found
	beq $s2, -1, findKings_notDone
	j findKings_found_done

findKings_notDone:
	andi $t0, $s0, 0x00000007  #mask out all bits expect bottom 3   
	beq  $t0, 7, findKing_nextrow
	addi $s0, $s0, 1
	j findKings_start

findKing_nextrow:
	andi $s0, $s0, 0xFF00 # mask out the col
	addi $s0, $s0, 0x0100 # add to the row	
	j findKings_start

findKings_found_done:
findKings_done:
	move $v0, $s1
	move $v1, $s2
	lw $ra, 0($sp)
	lw $s0, 4($sp)
	lw $s1, 8($sp)   
	lw $s2, 12($sp)
	addi $sp, $sp, 16
	jr $ra

# $a0: address of string
replaceNewline:
	lb $t0, 0($a0)
	beqz $t0, replaceNewline_done
	beq $t0, '\n', replaceNewline_found
	addi $a0, $a0, 1
	j replaceNewline
replaceNewline_found:
	sb $0, 0($a0)
replaceNewline_done:
	jr $ra
