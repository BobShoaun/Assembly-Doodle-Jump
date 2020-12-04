#####################################################################
#
# CSC258H5S Fall 2020 Assembly Final Project
# University of Toronto, St. George
#
# Student: Ng Bob Shoaun, 1006568992
#
# Bitmap Display Configuration:
# - Unit width in pixels: 8
# - Unit height in pixels: 8
# - Display width in pixels: 256
# - Display height in pixels: 256
# - Base Address for Display: 0x10008000 ($gp)
#
# Which milestone is reached in this submission? 1
# (See the assignment handout for descriptions of the milestones)
# - Milestone 1/2/3/4/5 (choose the one the applies)
#
# Which approved additional features have been implemented?
# (See the assignment handout for the list of additional features)
# 1. Doodler jump animation
# 2. Platforms
# 3. (fill in the feature, if any)
# ... (add more if necessary)
#
# Any additional information that the TA needs to know:
# - (write here, if any)
#
#####################################################################
.data
	max: .word 4092
	sleepDuration: .word 100
	doodlerColor: .word 0x7FFF90
	bgColor: .word 0xFFDFA8
	platformColor: .word 0xFF8A33
	doodlerStartPos: .word 3648
.text
main:
	lw $t1, bgColor
	lw $t2, doodlerColor
	lw $t3, platformColor            
	
	jal drawBackground
	
	
	lw $a0, doodlerStartPos
	jal startJump
	
	gameLoop:
		li $a1, 2644
		jal drawPlatform
		li $a1, 2352
		jal drawPlatform
		li $a1, 3392
		jal drawPlatform
	
		move $a1, $v1
		
		move $a2, $t2
		jal drawDoodler
		
		jal updateJump
		jal sleep
		
		move $a2, $t1
		jal drawDoodler

		j gameLoop
		
	exitGameLoop:
	
	li $v0, 10 # terminate the program gracefully
	syscall

# $a0 start pos
startJump:
	addi $sp, $sp, -4
	sw $ra, ($sp)
	
	move $s0, $a0
	li $s1, -128 # direction
	li $s2, 0 # offset
	move $v1, $s0
	
	lw $ra, ($sp)
	addi $sp, $sp, 4
	jr $ra

# $v1 current pos
updateJump:
	addi $sp, $sp, -4
	sw $ra, ($sp)
	
	move $a0, $v1
	jal checkDoodlerCollision
	
	bne $t5, 1, cont2
	bne $s1, 128, cont2
	addi $a0, $v1, -128
	jal startJump
	
	cont2:
	bne $s2, -1152, cont # peak
	li $s1, 128
	
	cont:
	add $v1, $s2, $s0
	add $s2, $s2, $s1
	j end
	
	end:
	lw $ra, ($sp)
	addi $sp, $sp, 4
	jr $ra
	
# a0 doodler pos, t5 collided
checkDoodlerCollision:
	addi $sp, $sp, -12
	sw $ra, 0($sp)
	sw $s0, 4($sp)
	sw $s1, 8($sp)
	
	add $s0, $gp, $a0
	lw $s1, 384($s0)
	beq $s1, $t3, collided
	lw $s1, 392($s0)
	beq $s1, $t3, collided
	li $t5, 0
	j endC
	collided:
		li $t5, 1
	
	endC:
	lw $s1, 8($sp)
	lw $s0, 4($sp)
	lw $ra, 0($sp)
	addi $sp, $sp, 12
	jr $ra
	

# Draw doodler from $a1 pos and $a2 color
drawDoodler:
	addi $sp, $sp, -4
	sw $ra, ($sp)
	sw $s0, 4($sp)
	
	add $s0, $gp, $a1
	sw $a2, 4($s0)
	sw $a2, 128($s0)
	sw $a2, 132($s0)
	sw $a2, 136($s0)
	sw $a2, 256($s0)
	sw $a2, 264($s0)
	
	lw $s0, 4($sp)
	lw $ra, ($sp)
	addi $sp, $sp, 4
	jr $ra
	
drawPlatform:
	addi $sp, $sp, -4
	sw $ra, ($sp)
	sw $s0, 4($sp)
	
	add $s0, $gp, $a1
	sw $t3, ($s0)
	sw $t3, 4($s0)
	sw $t3, 8($s0)
	sw $t3, 12($s0)
	sw $t3, 16($s0)
	
	lw $s0, 4($sp)
	lw $ra, ($sp)
	addi $sp, $sp, 4
	jr $ra

drawBackground:
	sw $ra, ($sp)
	
	li $t4, 0
	bgDrawLoop:
		beq $t4, 4096, exitBgDrawLoop
		add $t5, $t4, $gp
		sw $t1, ($t5)
		addi $t4, $t4, 4
		j bgDrawLoop
	
	exitBgDrawLoop:
	
	lw $ra, ($sp)
	jr $ra
	
sleep:
	li $v0, 32
	lw $a0, sleepDuration
	syscall
	jr $ra
