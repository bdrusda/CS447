.data
types:	.asciiz	"bit", "nybble", "byte", "half", "word"
bits:	.asciiz	"one", "four", "eight", "sixteen", "thirty-two"
prompt:	.asciiz "Please enter a datatype:\n"
in:	.space 100
notfound:	.asciiz "Not found!"
numberofbits:	.asciiz "Number of bits: "

.text
#I feel that I was close to figuring this out, but I am well over 4 hours into writing the program and I have made little headway.
la $a0, prompt
addi $v0, $zero, 4
syscall			#prompt user

la $a0, in
add $a1, $zero, 100
addi $v0, $zero, 8
syscall			#get input
#-----------------------------------------------#
add $s0, $zero, $zero	#set index at 0
add $s1, $zero, $zero	#offset	
la $s2, types		#load in array address			
la $s3, ($a0)		#store input

loop:
	beq $s0, 5, noMatch
	#load the strings into memory to pass as parameters
	add $s1, $zero, $s0	#store index in offset
	sll $s1, $s1, 2		#convert offset into bytes
	add $a0, $s1, $s2	#add address to get address of current word

	add $a1, $zero, $s3	#address of the input
	
	#call checkType
	jal checkType
	#store return values
	add $t0, $zero, $v0
	add $t1, $zero, $v1
	
	#check success value
	beq $v1, $zero, nextword
#if it returns a 1 print out the size
	add $a0, $zero, $t0	#store the index
	la $s4, bits		#store the address of the array
	add $a1, $zero, $s4
	#add $s1, $zero, $s0
	#sll $s1, $s1, 2
	#add $s1, $s1, $s4
	#add $a1, #address of bits
	
	jal getValue
	
	add $s1, $zero, $v0	#store the returned size in s1
	addi $v0, $zero, 4	
	syscall			#print the size
	j end
	#iterate through bits array until we find the index-th word
	#print the word
#if it returns a 0 check what index we're at
	nextword:
	addi $s0, $s0, 1	#increment the index
	add $s2, $zero, $t0	#load next word's address into s2
	#if we have have checked everything, output that it could not be found
	#if we have not checked everything, increase the index and repeat
j loop

checkType:
#store s registers
	add $sp, $sp, -16	#create space for the index, offset(not necessary), array of words, and input
	sw $s0, 0($sp) 
	sw $s1, 4($sp)
	sw $s2, 8($sp)
	sw $s3, 12($sp)
#-----------------
#store passed values
	add $t0, $zero, $a0	#store current word in t0
	add $t1, $zero, $a1	#store input in t1

	#the strings have been successfully passed through
	add $t2, $zero, $zero	#store an index value for traversing the string
	add $t3, $zero, $zero	#store an offset value for traversing the string
	add $t4, $zero, $zero	#address of the current byte being traversed
	#compare the strings
	bytecomparison:
		add $t3, $zero, $t2	#load index into t3
		add $t4, $zero, $t3	#store this value for the guess word as well
		add $t4, $t3, $t1	#add the first value's address to get the value of the input word's current byte
		add $t3, $t3, $t0	#add the first value's address to get the value of the current byte

		lb $t5, ($t3)		#load the character stored in this address in input
		lb $t6, ($t4)		#load the character stored in this address in types
		
		bne $t5, $t6, notequal	#if the characters do not match
		
		beq $t6, 0, match	#if the words match and the null character is reached
		
		add $a0, $zero, $t3
		addi $v0, $zero, 11
		syscall

		addi $t2, $t2, 1	#increment index
	j bytecomparison	#continue the loop

	notequal:	#cycle through the byte address in types until the next word is reached
		beq $t5, 0, exit	
		add $t4, $zero, $t2	#add index to bit address
		add $t4, $t2, $t1	#get byte address to bit address
		lb $t5, ($t4)		#load the next byte until the null is reached
		
		add $a0, $zero, $t5
		addi $v0, $zero, 11
		syscall
		
		addi $t2, $t2, 1	#increment index
	j notequal
	
	exit:		#restore values stored in stack and return the address of the next word in types as well as the success value
		#restore values from stack
		lw $s0, 0($sp) 
		lw $s1, 4($sp)
		lw $s2, 8($sp)
		lw $s3, 12($sp)
		add $sp, $sp, 16	#restore memory to stack
		add $v0, $zero, $t4	#return the address of the next word in types array
		addi $v1, $zero, 0	#return that a match was not found
		jr $ra
	match:
		#restore values from stack
		lw $s0, 0($sp) 
		lw $s1, 4($sp)
		lw $s2, 8($sp)
		lw $s3, 12($sp)
		add $sp, $sp, 16	#restore memory to stack
		addi $v1, $zero, 1	#return that a match was not found
		jr $ra
#--------------------

getValue:
#store s registers
	addi $sp, $sp, -16	#create space for the index, offset(not necessary), array of words, and input
	sw $s0, 0($sp) 
	sw $s1, 4($sp)
	sw $s2, 8($sp)
	sw $s3, 12($sp)
#-----------------
#store passed values
	add $t0, $zero, $a0	#store index value
	add $t1, $zero, $a1	#store bits array
	
	
	

output:
	la $a0, numberofbits
	add $a0, $zero, $a0
	add $v0, $zero, 4
	syscall

noMatch:
	addi $v0, $zero, 4
	la $a0, notfound
	syscall
end:
	addi $v0, $zero, 10
	syscall