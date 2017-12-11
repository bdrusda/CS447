.data
intro: .asciiz "X*Y Calculator\n"
promptx: .asciiz "Please Enter X: "
prompty: .asciiz "Please Enter Y: "
errorX: .asciiz "Please enter a nonnegative X\n"
errorY: .asciiz "Please enter a nonnegative Y\n"
times: .asciiz " * "
equals: .asciiz " = "

.text
addi $v0, $zero, 4
la $a0, intro
syscall			#introduction

negCheck1:		#label to get a nonnegative X
la $a0, promptx
syscall
addi $v0, $zero, 5
syscall
add $s1, $zero, $v0	#store x in s1

slt $t0, $s1, $zero	#check if input was negative
beq $t0, 1, err1

negCheck2:		#label to get a nonnegative Y
addi $v0, $zero, 4
la $a0, prompty
syscall
addi $v0, $zero, 5
syscall
add $s2, $zero, $v0	#store y in s2

slt $t0, $s2, $zero	#check if input was negative
beq $t0, 1, err2

j continue

#skip if inputs are good#
err1:
addi $v0, $zero, 4
la $a0, errorX
syscall
j negCheck1

err2:
addi $v0, $zero, 4
la $a0, errorY
syscall
j negCheck2
#########################

continue:
	add $t0, $zero, $zero	#temp product value
	add $t1, $zero, $s2	#store y in t1
	add $t3, $zero, $zero	#counter starts at 0
loop:
	add $t2, $zero, $t1	#copy temp remainder of y to and 1
	andi $t2, $t2, 1
	bne $t2, 1, noteq	#if the value is 0 skip shift and addition
	sllv $t2, $s1, $t3	#perform partial multiplication		-	put in t2 the value of x shifted by the count
	add $t0, $t0, $t2	#add current product with new partial product
noteq:
	addi $t3, $t3, 1	#increment counter
	slti $t4, $t3, 32	#if we haven't gone through every bit, continue
	beq $t4, 0, result
	srl $t1, $t1, 1		#shift the temp y down to the next bit
	j loop

result:
	add $s3, $zero, $t0	#save the product
	
	addi $v0, $zero, 1
	add $a0, $zero, $s1
	syscall 		#print X
	addi $v0, $zero, 4
	la $a0, times
	syscall			#print *
	addi $v0, $zero, 1
	add $a0, $zero, $s2
	syscall			#print Y
	addi $v0, $zero, 4
	la $a0, equals
	syscall			#print =
	addi $v0, $zero, 1
	add $a0, $zero, $s3
	syscall			#print product

