.data
prompt: .asciiz "Enter a nonnegative integer: "
invalid: .asciiz "Invalid integer. Try again\n"
out1: .asciiz "Feb("
out2: .asciiz ") = "

.text
inloop:
	la $a0, prompt
	addi $v0, $zero, 4
	syscall

	addi $v0, $zero, 5
	syscall

	add $s0, $zero, $v0	#store input in s0

	slti $t0, $s0, 0
	beq $t0, 1, error
	j cont
cont:
	la $a0, out1
	addi $v0, $zero, 4
	syscall			#output part 1
	
	add $a0, $zero, $s0
	addi $v0, $zero, 1
	syscall			#user inputted number
	
	la $a0, out2
	addi $v0, $zero, 4
	syscall			#output part 2
	
#actual work
	add $a0, $zero, $s0	#pass number given as parameter
	jal fib
	add $s1, $zero, $v0	#store result in s1
#-----------
	
	add $a0, $zero, $s1
	addi $v0, $zero, 1
	syscall			#fibonnaci number
	
	addi $v0, $zero 10
	syscall			#exit program
	
	#fib takes 1 paramter(index)
	#fib returns 1 value(x+2)	
fib:
	beq $a0, $zero, zero
	beq $a0, 1, one
	#store values
	addi $sp, $sp, -4
	sw $ra, 0($sp)
	#------------

	addi $a0, $a0, -1	#get n-1 
	jal fib			
	addi $a0, $a0, 1	
	
	lw $ra, 0($sp)		#restore address
	addi $sp, $sp, 4	#restore memory to stack
	
	addi $sp, $sp, -4	#take more memory from stack
	sw $v0, 0($sp)		#store value	
	addi $sp, $sp, -4
	sw $ra, 0($sp)	

	addi $a0, $a0, -2
	jal fib			#get n-2
	add $a0, $a0, 2
	
	lw $ra, 0($sp)
	addi $sp, $sp, 4
	
	lw $s0, 0($sp)
	addi $sp, $sp, 4
	
	add $v0, $v0, $s0
	jr $ra
		
	zero:
		addi $v0, $zero, 0
		jr $ra
	one:
		addi $v0, $zero, 1
		jr $ra

error:
	la $a0, invalid
	addi $v0, $zero, 4
	syscall
	j inloop