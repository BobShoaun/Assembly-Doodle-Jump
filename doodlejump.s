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
	displayMaximum: .word 4096
	platformsArray: .space 36
	platformsArrayLength: .word 36
	sleepDuration: .word 50
	doodlerColor: .word 0x7FFF90
	backgroundColor: .word 0xFFDFA8
	platformColor: .word 0xFF8A33
	springColor: .word 0x7E7E7E
	doodlerInitialPosition: .word 64
	doodlerJumpDuration: .word 12	# jump duration in frames
	
.text
main:
	
	# paint background
	lw $a0, backgroundColor
	jal drawBackground
	
	jal spawnPlatforms
	
	lw $t0, doodlerInitialPosition  # doodler current position
	li $t1, 0 			# doodler velocity
	li $t2, 0			# jump timer
	lw $t3, displayMaximum

	gameLoop:
		# erase old platforms
		lw $a0, backgroundColor
		jal drawPlatforms
		
		# erase old doodler
		move $a0, $t0
		lw $a1, backgroundColor
		jal drawDoodler
		
		jal moveWorld
		
		# draw platforms
		lw $a0, platformColor
		jal drawPlatforms
		
		jal moveDoodler
		
		# draw doodler
		move $a0, $t0
		lw $a1, doodlerColor
		jal drawDoodler
		
		bgt $t0, $t3, endGameLoop	# doodler reaches bottom of screen
		
		jal sleep
		j gameLoop
		
	endGameLoop:
		li $v0, 10 # terminate the program gracefully
		syscall

moveWorld:
	addi $sp, $sp, -20
	sw $ra, ($sp)
	sw $s0, 4($sp)
	sw $s1, 8($sp)
	sw $s2, 12($sp)
	sw $s3, 16($sp)
	
	bge $t0, 1536, endMoveWorld
	addi $t0, $t0, 128
	
	lw $s3, platformsArrayLength
	li $s0, 0
	movePlatforms:
		beq $s0, $s3, endMoveWorld
		lw $s1, platformsArray($s0)
		addi $s1, $s1, 128
		sw $s1, platformsArray($s0)
		
		lw $s2, displayMaximum
		ble $s1, $s2, contMovePlatforms
		
		li $a0, 0
		move $a1, $s0
		jal spawnPlatform
			
		contMovePlatforms:
			addi $s0, $s0, 4
			j movePlatforms
	
	endMoveWorld:
		lw $s3, 16($sp)
		lw $s2, 12($sp)
		lw $s1, 8($sp)
		lw $s0, 4($sp)
		lw $ra, ($sp)
		addi $sp, $sp, 20
		jr $ra

moveDoodler:
	addi $sp, $sp, -4
	sw $ra, ($sp)
	
	li $t1, 0	# reset velocity
	jal checkKeyboardInput
	
	bne $t2, $zero, jumping
	addi $t1, $t1, 128	# apply gravity
	
	jal checkDoodlerCollision
	j endMoveDoodler
	
	jumping:
		addi $t1, $t1, -128
		addi $t2, $t2, -1
	
	endMoveDoodler:
		add $t0, $t0, $t1	# move doodler based on velocity
	
		lw $ra, ($sp)
		addi $sp, $sp, 4
		jr $ra
	
checkDoodlerCollision:
	addi $sp, $sp, -12
	sw $s0, ($sp)
	sw $s1, 4($sp)
	sw $s2, 8($sp)
	
	lw $s2, platformColor
	
	add $s0, $gp, $t0
	lw $s1, 384($s0)	# left foot
	beq $s1, $s2, collided  # left foot collided
	lw $s1, 392($s0)	# right foot
	beq $s1, $s2, collided  # right foot collided
	j endCollided
	
	collided:
		addi $t1, $t1, -128		# cancel gravity
		lw $t2, doodlerJumpDuration	# start/reset jump
	
	endCollided:
		sw $s2, 8($sp)
		lw $s1, 4($sp)
		lw $s0, ($sp)
		addi $sp, $sp, 12
		jr $ra


checkKeyboardInput:
	addi $sp, $sp, -8
	sw $s0, ($sp)
	sw $s1, 4($sp)
	
	lw $s0, 0xffff0000
	beq $s0, 1, inputDetected
	j endCKI
	
	inputDetected:
	 	lw $s1, 0xffff0004
		beq $s1, 0x6A, jPressed
		beq $s1, 0x6B, kPressed
		j endCKI
	
	jPressed:
		addi $t1, $t1, -8
		j endCKI
	
	kPressed:
		addi $t1, $t1, 8
	
	endCKI:
		lw $s1, 4($sp)
		lw $s0, ($sp)
		addi $sp, $sp, 8
		jr $ra
	

# Draw doodler at $a0 position with $a1 color
drawDoodler:
	addi $sp, $sp, -4
	sw $s0, ($sp)
	
	add $s0, $gp, $a0
	sw $a1, 4($s0)
	sw $a1, 128($s0)
	sw $a1, 132($s0)
	sw $a1, 136($s0)
	sw $a1, 256($s0)
	sw $a1, 264($s0)
	
	lw $s0, ($sp)
	addi $sp, $sp, 4
	jr $ra
	
spawnPlatforms:
	addi $sp, $sp, -16
	sw $ra, ($sp)
	sw $s0, 4($sp)
	sw $s1, 8($sp)
	sw $s2, 12($sp)
	
	lw $s2, platformsArrayLength
	li $s0, 0
	spawn:
		beq $s0, $s2, endSpawnPlatform
		
		# spawn indiv platform
		mul $a0, $s0, 128
		move $a1, $s0
		jal spawnPlatform
		
		addi $s0, $s0, 4
		j spawn
	
	endSpawnPlatform:
		lw $s2, 12($sp)
		lw $s1, 8($sp)
		lw $s0, 4($sp)
		lw $ra, ($sp)
		addi $sp, $sp, 16
		jr $ra

# Spawn platform at $a0 offset, $a1 index
spawnPlatform:
	addi $sp, $sp, -12
	sw $a0, ($sp)
	sw $a1, 4($sp)
	sw $s0, 8($sp)
	
	li $v0, 42
	li $a0, 0
	li $a1, 128
	syscall
	
	mul $s0, $a0, -4
	
	#li $v0, 42
	#li $a0, 0
	#li $a1, 1
	#syscall
	
	#beq $a0, $zero, spawnSpring
	
	
	lw $a0, ($sp)
	lw $a1, 4($sp)
	
	add $s0, $s0, $a0	# apply offset
	sw $s0, platformsArray($a1)
	
	lw $s0, 8($sp)
	addi $sp, $sp, 12
	jr $ra

# Draw platforms with $a0 color
drawPlatforms:	
	addi $sp, $sp, -12
	sw $s0, ($sp)
	sw $s1, 4($sp)
	sw $s2, 8($sp)
	
	lw $s2, platformsArrayLength
	li $s0, 0
	drawPlatform:
		beq $s0, $s2, endDrawPlatform
		lw $s1, platformsArray($s0)
		add $s1, $s1, $gp
		
		sw $a0, ($s1)
		sw $a0, 4($s1)
		sw $a0, 8($s1)
		sw $a0, 12($s1)
		sw $a0, 16($s1)
		
		addi $s0, $s0, 4
		j drawPlatform
	
	endDrawPlatform:
		lw $s2, 8($sp)
		lw $s1, 4($sp)
		lw $s0, ($sp)
		addi $sp, $sp, 12
		jr $ra

# Draw background with $a0 color
drawBackground:
	addi $sp, $sp, -8
	sw $s0, ($sp)
	sw $s1, 4($sp)
	
	li $s0, 0
	bgDrawLoop:
		beq $s0, 4096, endBgDraw
		add $s1, $s0, $gp
		sw $a0, ($s1)
		
		addi $s0, $s0, 4
		j bgDrawLoop
	
	endBgDraw:
		lw $s1, 4($sp)
		lw $s0, ($sp)
		addi $sp, $sp, 8
		jr $ra
		
sleep:	
	li $v0, 32
	lw $a0, sleepDuration
	syscall
	jr $ra
