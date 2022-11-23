https://powcoder.com
代写代考加微信 powcoder
Assignment Project Exam Help
Add WeChat powcoder

# Netid: your1

.include "hw4_helpers.asm"
.text

##########################################
#  Part #1 Functions
##########################################
initBoard:
    # insert code here
    lw $a0, fgcolor     # fg always red(base_add)
    lw $a1, darkcolor   # dark   (user_num)
    lw $a2, lightcolor  # light (user_num)
    jal initBoard
	
    addi $sp, $sp, -12
    sw $s3, 0($sp)
    sw $s4, 4($sp)
    sw $s5, 8($sp)
    
    # $a0 = base_address
    # $a1 = row_num
    # $a2 = coln_num
    # $a3 = char
    li $s4, 0 # j = 0
    li $t0, 8
    
    j_loop:
        bge $s4, 8, done_j_loop        # if j >= row_num, done_j_loop
        li $s5, 0  # i = 0
        
        i_loop:
            bge $s5, 8, done_i_loop    # if i >= col_num, done_i_loop
            
            mul $s3, $s5, $t0
            add $s3, $s3, $s4		

            add $s3, $s3, $a0		 # i * colu_num + j + base_address
            
            sb $a1, 0($s3)
            addi $s3, $s3, 1
            sb $a2, 0($s3)
            addi $s5, $s5, 1
            j i_loop
            
        done_i_loop:
            addi $s4, $s4, 1
            b j_loop
            
    done_j_loop:
	jr $ra


setSquare:
	# insert code here
	li $v0, 555
	jr $ra

initPieces:
	# insert code here
	jr $ra

mapChessMove:
	# insert code here
	li $v0, 2345  # replace this line
	jr $ra

loadGame:
	# insert code here
	li $v0, -1111 # replace this line
	li $v1, -1111 # replace this line
	jr $ra

##########################################
#  Part #2 Functions
##########################################

getChessPiece:
	# insert code here
	li $v0, -1111 # replace this line
	li $v1, -1111 # replace this line
	jr $ra

validBishopMove:
	# insert code here
	li $v0, 0xF0F0  # replace this line
	jr $ra

validRookMove:
	# insert code here
	li $v0, 0XAAA  # replace this line
	jr $ra

perform_move:
	li $v0, 0XDEAD  # replace this line
	jr $ra

##########################################
#  Part #3 Function
##########################################

check:
	li $v0, 0XBEEF  # replace this line
	jr $ra
