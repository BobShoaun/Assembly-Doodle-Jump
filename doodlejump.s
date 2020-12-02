# Demo for painting
#
# Bitmap Display Configuration:
# - Unit width in pixels: 8
# - Unit height in pixels: 8
# - Display width in pixels: 256
# - Display height in pixels: 256
# - Base Address for Display: 0x10008000 ($gp)
#
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
	
	li $a1, 2624
	jal drawPlatform
	li $a1, 2088
	jal drawPlatform
	
	lw $t0, doodlerStartPos
	li $s0, 0
	
	gameLoop:
		add $s1, $s0, $t0
		move $a1, $s1
		move $a2, $t2
		jal drawDoodler
		
		beq $s0, -640, down
		addi $s0, $s0, -128
		j endif
		down:
			addi $s0, $s0, 128
		
		endif:
		jal sleep
		
		move $a2, $t1
		jal drawDoodler
		
		j gameLoop
		
	exitGameLoop:
	
	li $v0, 10 # terminate the program gracefully
	syscall
	

# Draw doodler from $a1 coords and $a2 color
drawDoodler:
	addi $sp, $sp, -4
	sw $ra, ($sp)
	
	add $t6, $gp, $a1
	sw $a2, 4($t6)
	sw $a2, 128($t6)
	sw $a2, 132($t6)
	sw $a2, 136($t6)
	sw $a2, 256($t6)
	sw $a2, 264($t6)
	
	lw $ra, ($sp)
	addi $sp, $sp, 4
	jr $ra
	
drawPlatform:
	addi $sp, $sp, -4
	sw $ra, ($sp)
	
	add $t4, $gp, $a1
	sw $t3, ($t4)
	sw $t3, 4($t4)
	sw $t3, 8($t4)
	sw $t3, 12($t4)
	sw $t3, 16($t4)
	
	lw $ra, ($sp)
	addi $sp, $sp, 4
	jr $ra

drawBackground:
	addi $sp, $sp, -4
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
	addi $sp, $sp, 4
	jr $ra
	
sleep:
	li $v0, 32
	lw $a0, sleepDuration
	syscall
	jr $ra