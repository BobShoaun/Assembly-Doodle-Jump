.data
	message: .asciiz "is this runnning? "

.text
	main:
		li $v0, 4
		la $a0, message
		syscall
	
		exit:
			li $v0, 10 # terminate the program gracefully
			syscall
	
			li $v0, 4
			la $a0, message
			syscall
			