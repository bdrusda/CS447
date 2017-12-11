.data
prompt: .asciiz "Enter a floating-point number:"
answer1: .asciiz "The square root of "
answer2: .asciiz " is "
input: .space 100
before_groups: .space 100
.text
#s0 is the number of digits before the decimal
#s1 is the number of groups before the decimal

#get input
la $a0, prompt
li $v0, 4
syscall		#prompt the user for a number

la $a0, input
li $a1, 100
li $v0, 8
syscall		#get the number from the user in the form of a string

#divide input into groups
	#count number of digits before decimal
la $t0, input
li $t1, 0
li $s0, 0

#get the # of digits before and after the decimal
get_digits_before:
	add $t2, $t0, $t1	#load address + offset value
	lb $t2, 0($t2)		#load the actual character in the string
	beq $t2, 46, got_digits	#if it's the decimal, exit loop
	#if it's not the decimal
	addi $t1, $t1, 1	#increment t1
j get_digits_before

got_digits:
	add $s0, $zero, $t1	#store the number of digits before the decimal in s0
	add $t0, $t0, $t1	#save the starting point of the number after the decimal
	addi $t0, $t0, 1	#move to the digit after the decimal
	li $t1, 0		#reset the counter to 0

#calculate the # of groups
	li $t0, 2		#divide by two to get group #'s
	div $s1, $s0, $t0
	mfhi $t1
	beq $t1, 0, no_rem
	addi $s1, $s1, 1
	no_rem:
#create the groups
	la $t0, input
	la $t2, before_groups
	li $t4, 0	#number of groups done
	#load first group if it needs a zero before it
	beq $t2, 0, normal_load
	lb $t3, 0($t0)	#load the first digit
	add $t3, $t3, -48	#convert to actual value rather than ascii
	sb $t3, 0($t2)
	addi $t0, $t0, 1	#move to the next input
	addi $t2, $t2, 4	#move to the next group
	addi $t4, $t4, 1	#increment number of groups done
	beq $t4, $s1, got_groups#stop if we have all the groups
	#load other groups
	normal_load:
		lb $t3, 0($t0)	#load the next number
		add $t3, $t3, -48	#convert to actual value rather than ascii
		lb $t5, 1($t0) 	#load its corresponding number
		add $t5, $t5, -48	#convert to actual value rather than ascii
		li $t6, 10
		mult $t3, $t6	#multiply the first in the group by ten
		mflo $t3
		add $t3, $t3, $t5	#this is the final value for the group
		sb $t3, 0($t2)
		addi $t0, $t0, 2	#move to the next input pair
		addi $t2, $t2, 4	#move to the next group
		addi $t4, $t4, 1	#increment groups done
		beq $t4, $s1, got_groups
	j normal_load
got_groups:
#calculate
	li $s2, 0	#result
	li $s3, 0	#reference
	li $s4, 0	#remainder
	li $t0, 100	#100
	add $t1, $zero, $s1 	#number of groups
	la $t2, before_groups	#the groups before the decimal point
	li $t3, 0	#counter
	calculate:
	#calculate remainder
		#multiply by 100
		mult $s4, $t0
		mflo $s4
		#get n
		add $t6, $zero, $t3	#get offset #
		sll $t4, $t4, 2		#account for it being ints
		add $t4, $t4, $t2	#get the group
		lw $t4, 0($t4)
		#add n
		add $s4, $s4, $t4
	#calculate ref
		sll $s3, $s2, 1		#ref is result*2
	#find max value of x such that y = ((ref*10)*x) and y<=rem
		li $t5, 10
		mult $s3, $t5
		
		li $t6, 1	#t6 is x
		mflo $t7	#t7 is y
		
	#calculate result
		get_x:
			add $t8, $t7, $t6	#add ref*10 and x
			mult $t8, $t6		#multiply the two
			mflo $t8		#store the result
			slt $t9, $t8, $s4	#if the result if less than the remainder, store it
			beq $t9, 0, too_big
				add $s5, $zero, $t8	#store the best y value to date in s5
				addi $t6, $t6, 1	#try the next value of x
		j get_x
		too_big:
		mult $s2, $t5
		mflo $s2
		add $s2, $s2, $t6
		sub $s4, $s4, $s5
	
	beq $s4, 0, result	#if there is no remainder
	mfhi $t5
	bne $t5, 0, result	#if the product went over 32-bit
	
	j calculate
	
	
result:
	
	

output:
	la $a0, answer1
	li $v0, 4
	syscall		#part 1 of output
	la $a0, input
	li $v0, 4
	syscall		#input number
	la $a0, answer2
	li $v0, 4
	syscall		#part 2 of output
	add $a0, $zero, $s0
	li $v0, 1
	syscall		#output number
	li $v0, 10
	syscall		#exit