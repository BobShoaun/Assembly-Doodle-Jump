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
	gameMatrix: .word 0:1536
	gameMatrixLength: .word 6144
	displayMaximum: .word 4096
	
	platformsArray: .space 48
	platformsArrayLength: .word 0
	spring: .word 0
	sleepDuration: .word 40
	doodlerColor: .word 0x7FFF90
	backgroundColor: .word 0xFFDFA8
	platformColor: .word 0xFF8A33
	springColor: .word 0x7E7E7E
	brokenPlatformColor: .word 0x490909
	cloudPlatformColor: .word 0xF0F0F0
	
	doodlerInitialPosition: .word 64
	doodlerJumpDuration: .word 13	# jump duration in frames
	springBoostDuration: .word 25	# spring boost duration in frames
	
	displayToMatrixOffset: .word 768
	
.text
main:
	
	lw $t0, doodlerInitialPosition  # doodler current position
	li $t1, 0 			# doodler velocity
	li $t2, 0			# jump timer
	#lw $t3, displayMaximum
	li $t4, 768			# scroll timer
	li $t5, 0			# difficulty / platform spacing	
	
	li $s0, 0
	startLoop:
		beq $s0, 32, gameLoop
		jal scrollWorld
		jal spawnNewPlatform
		jal drawWorld
		addi $s0, $s0, 1
		j startLoop

	gameLoop:
		
		bge $t0, 1536, skipScroll
		jal scrollWorld
		jal spawnNewPlatform
		addi $t0, $t0, 128	# also scroll player
		
		
		skipScroll:
		
		jal moveDoodler
		jal drawWorld
		
		
		# draw doodler
		move $a0, $t0
		lw $a1, doodlerColor
		jal drawDoodler
		
		bgt $t0, 4096, endGameLoop	# doodler reaches bottom of screen
		
		jal sleep
		j gameLoop
		
	endGameLoop:
		li $v0, 10 # terminate the program gracefully
		syscall

spawnCloudPlatform:
	addi $sp, $sp, -8
	sw $s0, ($sp)
	sw $s1, 4($sp)
	
	li $s1, 4	# 4 represents broken platform
	move $s0, $t4
	sw $s1, gameMatrix($s0) # spawn platform
	addi $s0, $s0, 4
	sw $s1, gameMatrix($s0)
	addi $s0, $s0, 4
	sw $s1, gameMatrix($s0)
	addi $s0, $s0, 4
	sw $s1, gameMatrix($s0)
	
	lw $s1, 4($sp)
	lw $s0, ($sp)
	addi $sp, $sp, 8
	jr $ra
	
spawnBrokenPlatform:	
	addi $sp, $sp, -8
	sw $s0, ($sp)
	sw $s1, 4($sp)
	
	li $s1, 3	# 3 represents broken platform
	move $s0, $t4
	sw $s1, gameMatrix($s0) # spawn platform
	addi $s0, $s0, 4
	sw $s1, gameMatrix($s0)
	addi $s0, $s0, 4
	sw $s1, gameMatrix($s0)
	addi $s0, $s0, 4
	sw $s1, gameMatrix($s0)
	
	lw $s1, 4($sp)
	lw $s0, ($sp)
	addi $sp, $sp, 8
	jr $ra

# $a0 random position on platform
spawnSpringPlatform:
	addi $sp, $sp, -8
	sw $s0, ($sp)
	sw $s1, 4($sp)
	
	mul $s0, $a0, 4		# multiply random num by 4 
	add $s0, $s0, $t4	# get coords of platform
	addi $s0, $s0, -128	# spawn above platform
	
	li $s1, 2	# 2 represents spring
	sw $s1, gameMatrix($s0)
	
	lw $s1, 4($sp)
	lw $s0, ($sp)
	addi $sp, $sp, 8
	jr $ra
	
# $t4 position
spawnStandardPlatform:
	addi $sp, $sp, -8
	sw $s0, ($sp)
	sw $s1, 4($sp)
	
	li $s1, 1	# 1 represents standard platform
	move $s0, $t4
	sw $s1, gameMatrix($s0) # spawn platform
	addi $s0, $s0, 4
	sw $s1, gameMatrix($s0)
	addi $s0, $s0, 4
	sw $s1, gameMatrix($s0)
	addi $s0, $s0, 4
	sw $s1, gameMatrix($s0)
	
	lw $s1, 4($sp)
	lw $s0, ($sp)
	addi $sp, $sp, 8
	jr $ra
	
# $a0 reference in game matrix coord
removePlatform:
	addi $sp, $sp, -16
	sw $s0, ($sp)
	sw $s1, 4($sp)
	sw $s2, 8($sp)
	sw $s3, 12($sp)
	
	lw $s0, gameMatrix($a0)	# load reference pixel to know which platform it is
	li $s1, -12	# iterate all possibilities of a 4 wide platform
	
	removeLoop:
		beq $s1, 16, finishRemove
		add $s3, $a0, $s1	# current coord we are looking at
		
		lw $s4, gameMatrix($s3)	# load contents of current pixel
		bne $s4, $s0, contRemoveLoop	# check if same as reference
		sw $zero, gameMatrix($s3)
	
	contRemoveLoop:
		addi $s1, $s1, 4
		j removeLoop
	
	finishRemove:
		lw $s3, 12($sp)
		lw $s2, 8($sp)
		lw $s1, 4($sp)
		lw $s0, ($sp)
		addi $sp, $sp, 16
		jr $ra
		
spawnNewPlatform:
	addi $sp, $sp, -8
	sw $ra, ($sp)
	sw $s0, 4($sp)
	
	bge $t4, 768, endSpawnNewPlat
	
	addi $t5, $t5, 4	# increase difficulty
	
	# RNG for type of obstacle
	li $v0, 42
	li $a0, 0
	li $a1, 50
	syscall
	
	blt $a0, 20, spawnNext1
	jal spawnStandardPlatform
	j endSpawn
	
	spawnNext1:
	blt $a0, 15, spawnNext2
	jal spawnBrokenPlatform
	j endSpawn
	
	spawnNext2:
	blt $a0, 4, spawnNext3
	jal spawnCloudPlatform
	j endSpawn
	
	spawnNext3:
	jal spawnStandardPlatform
	jal spawnSpringPlatform
	j endSpawn
	
	endSpawn:
	
	# RNG for next platform
	li $v0, 42
	li $a0, 0
	li $a1, 192
	syscall
	
	mul $a0, $a0, 4		# coord form
	addi $t4, $a0, 768	# apply offset for buffer
	add $t4, $t4, $t5	# apply general spacing
	
	endSpawnNewPlat:
		lw $s0, 4($sp)
		lw $ra, ($sp)
		addi $sp, $sp, 8
		jr $ra

scrollWorld:
	addi $sp, $sp, -20
	sw $ra, ($sp)
	sw $s0, 4($sp)
	sw $s1, 8($sp)
	sw $s2, 12($sp)
	sw $s3, 16($sp)
	

	addi $t4, $t4, -128 	# update scroll timer
	
	li $s0, 4864
	scroll:
		blt $s0, $zero, endScrollWorld
		lw $s1, gameMatrix($s0)
		addi $s2, $s0, 128	# scroll amount
		sw $s1, gameMatrix($s2)
		addi $s0, $s0, -4
		j scroll
		
	endScrollWorld:
		lw $s3, 16($sp)
		lw $s2, 12($sp)
		lw $s1, 8($sp)
		lw $s0, 4($sp)
		lw $ra, ($sp)
		addi $sp, $sp, 20
		jr $ra
		
drawWorld:
	addi $sp, $sp, -20
	sw $ra, ($sp)
	sw $s0, 4($sp)
	sw $s1, 8($sp)
	sw $s2, 12($sp)
	sw $s3, 16($sp)

	li $s0, 0
	drawLoop:
		beq $s0, 4096, endDrawWorld
		
		addi $s2, $s0, 768	# matrix coords by applying offset
		lw $s1, gameMatrix($s2)	# get value at coords
		add $s2, $s0, $gp	# get address at coords
		beq $s1, 0, dBackground
		beq $s1, 1, dPlatform
		beq $s1, 2, dSpring
		beq $s1, 3, dBrokenPlatform
		beq $s1, 4, dCloudPlatform
		j contDrawLoop
		
	dBackground:
		lw $s3, backgroundColor
		j contDrawLoop
		
	dPlatform:
		lw $s3, platformColor
		j contDrawLoop
		
	dSpring:
		lw $s3, springColor
		j contDrawLoop
	
	dBrokenPlatform:
		lw $s3, brokenPlatformColor
		j contDrawLoop
		
	dCloudPlatform:
		lw $s3, cloudPlatformColor
		j contDrawLoop
	
	contDrawLoop:
		sw $s3, ($s2)
		addi $s0, $s0, 4
		j drawLoop
		
	endDrawWorld:
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
	addi $sp, $sp, -20
	sw $s0, ($sp)
	sw $s1, 4($sp)
	sw $s2, 8($sp)
	sw $s3, 12($sp)
	sw $ra, 16($sp)

	addi $s0, $t0, 768 	# current pos in game matrix coords
	
	li $s3, 384	# check left, middle and right
	
	checkCollisions:
		beq $s3, 396, endCheckCollisions
		add $s1, $s0, $s3
		lw $s2, gameMatrix($s1)
		beq $s2, 1, standardPlatformCollision
		beq $s2, 2, springCollision
		beq $s2, 3, brokenPlatformCollision
		beq $s2, 4, cloudPlatformCollision

		addi $s3, $s3, 4	# increase iterator
		j checkCollisions
	
	standardPlatformCollision:
		addi $t1, $t1, -128		# cancel gravity
		lw $t2, doodlerJumpDuration	# start jump
		j endCheckCollisions
	
	springCollision:
		addi $t1, $t1, -128		# cancel gravity
		lw $t2, springBoostDuration	# start jump with higher duration
		j endCheckCollisions
		
	brokenPlatformCollision:
		# remove broken platform
		move $a0, $s1
		jal removePlatform
		j endCheckCollisions
	
	cloudPlatformCollision:
		addi $t1, $t1, -128		# cancel gravity
		lw $t2, doodlerJumpDuration	# start jump
		# remove cloud platform
		move $a0, $s1
		jal removePlatform
		j endCheckCollisions
	
	endCheckCollisions:
		lw $ra, 16($sp)
		lw $s3, 12($sp)
		lw $s2, 8($sp)
		lw $s1, 4($sp)
		lw $s0, ($sp)
		addi $sp, $sp, 20
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
