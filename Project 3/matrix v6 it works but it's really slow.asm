.data
head: .space 400	#array holding 100 columns worth of data
speed: .space 400
prompt: .asciiz "Enter a number of columns:"

.text
#User prompt and seed generation
li $v0, 4
la $a0, prompt
syscall			#prompt user

li $v0, 5
syscall			#get the number of columns

add $s0, $zero, $v0	#store the number of columns

li $v0, 30
syscall		#get time for random number generator
mflo $a1
li $a0, 13
li $v0, 40
syscall		#set seed

main:
#Column and speed array preparation
la $s1, head	#load address for heads
la $s2, speed	#load address for speeds
li $t0, 0	#counter
setup:		#set up n columns
	#pass head and speed as params
	add $a0, $zero, $s1	#head
	add $a1, $zero, $s2	#speed
	
	addi $sp, $sp, -4	#store counter
	sw $t0, 0($sp)
	jal set_column		#set the column information
	lw $t0, 0($sp)		#retrieve counter
	addi $sp, $sp, 4

	addi $t0, $t0, 1	#increment counter
	beq $t0, $s0, setup_done#if every user column has been setup, exit

	addi $s1, $s1, 4	#move to the next head address
	addi $s2, $s2, 4	#move to the next speed address
j setup		#set up column n+1
setup_done:

#Column maintenance
la $s1, head
la $s2, speed
li $t0, 0	#counter
update_columns:
	#pass head and speed as params
	add $a0, $zero, $s1	#head
	add $a1, $zero, $s2	#speed
	
	addi $sp, $sp, -4	#store counter
	sw $t0, 0($sp)	
	jal update_indiv
	lw $t0, 0($sp)		#retrieve counter
	addi $sp, $sp, 4

	addi $t0, $t0, 1	#increment counter
	bne $t0, $s0, cont	#if all of the columns have been updated, check the first one again
		la $s1, head		#reload initial head
		la $s2, speed		#reload initial speed
		li $t0, 0		#reset the counter
	j update_columns
	
	cont:
	addi $s1, $s1, 4	#move to the next head address
	addi $s2, $s2, 4	#move to the next speed address
j update_columns	#there shouldn't be a way out of this loop


j end

#Func set column
#param a0 - head memory
#param a1 - speed memory
#No return value
set_column:
	#save s registers
	addi $sp, $sp, -20
	sw $s0, 0($sp)
	sw $s1, 4($sp)
	sw $s2, 8($sp)
	sw $s3, 12($sp)
	sw $ra, 16($sp)
	
	
	add $t0, $zero, $a0	#store head address in t0
	add $t1, $zero, $a1	#store speed address in t1
	
#set starting location
	#Get random column number 0-79
	li $a0, 13
	li $a1, 80
	li $v0, 42
	syscall			#generate a random column number
	
	add $t2, $zero, $a0	#store the column number in t2
	sll $t2, $t2, 2		#align with boundary
	addi $t3, $zero, 0xffff8000	#start with base address in t3
	
	add $t3, $t3, $t2	#store the full first address in t3
	sw $t3, 0($t0)		#store the address in memory in the head address
	
#set column speed
	li $a0, 13
	li $a1, 10
	li $v0, 42
	syscall			#generate a random speed
	
	add $t2, $zero, $a0	#store the speed in t2
	sw $t2, 0($t1)		#store the speed in memory in the speed address

	#restore s registers
	lw $ra, 16($sp)
	lw $s3, 12($sp)
	lw $s2, 8($sp)
	lw $s1, 4($sp)
	lw $s0, 0($sp)
	addi $sp, $sp, 20
jr $ra

#Func update indiv
update_indiv:
	#save s registers and return address
	addi $sp, $sp, -16
	sw $s0, 0($sp)
	sw $s1, 4($sp)
	sw $s2, 8($sp)
	sw $ra, 12($sp)
   #for each letter in the column
   	
   	add $s0, $zero, $a0	#store head address in s0
   	add $s1, $zero, $a1	#store speed address in s1
   	li $t0, 0		#counter
   #TODO need variable to check if the column should be updated on this iteration, it_num
   	#TODO check if this iteration is one that the column should be updated on
   	
   	
	#Func update position
	add $a0, $zero, $s0		#send the current position
	
	jal update_position
	
	lw $s2, 0($s0)			#load the position data in the updated address
	li $s3, 255			#load the head color
	
	twenty_six_iterations:
		#s2 is the position of the current letter.  We will be storing updates here.
		#s3 is the color that is being given to the space
		
		#fade and change letter
		#do this until the head loc is greater than 25 lines past the max bottom
			#slt b200 or whatever it was + 25*320
		
		
		
		#this function updates the position and puts the result back in memory
		
		#Func update color and letter
		add $a0, $zero, $s2		#store the addrss in a0
		add $a1, $zero, $s3		#store color in a1
		
		addi $sp, $sp, -4		#store counter
		sw $t0, 0($sp)	
		jal update_color_and_letter
		lw $t0, 0($sp)			#retrieve counter
		addi $sp, $sp, 4
	
		addi $s2, $s2, -320		#move on to the row above
		addi $s3, $s3, -10		#fade the next color
		addi $t0, $t0, 1		#increment the counter

		beq $t0, 26, letters_done
	j twenty_six_iterations
	
	letters_done:
	li $t0, 0xFFFFB1F8	#take last address of last valid line - maybe B0C0
	slt $t1, $t0, $s2	#if the last printed is off screen, make a new column 
	
	beq $t1, 0, on_screen	#if it isn't off screen, proceed as usual
		#pass param head address (not pos)
		add $a0, $zero, $s0	#param curr head address
		add $a1, $zero, $s1	#param curr speed address
		
		jal set_column		#create a new column in its place with its own speed and column loc
		#set column with this address
	on_screen:
	
	#restore s registers
	lw $ra, 12($sp)
	lw $s1, 4($sp)
	lw $s2, 8($sp)
	lw $s0, 0($sp)
	addi $sp, $sp, 16
jr $ra	

#Param head address
#No return value
update_position:
	#save s registers
	addi $sp, $sp, -8
	sw $s0, 0($sp)
	sw $s1, 4($sp)
	
	add $s0, $zero, $a0	#save the passed address
	lw $s1, 0($s0)		#load the value in the address
	addi $s1, $s1, 320	#move it down a row
	sw $s1, 0($s0)		#store it back in data
	
	#restore s registers
	lw $s1, 4($sp)
	lw $s0, 0($sp)
	addi $sp, $sp, 8
jr $ra

#Param position
#Param color
#No return value
update_color_and_letter:
	#save s registers
	addi $sp, $sp, -16
	sw $s0, 0($sp)
	sw $s1, 4($sp)
	sw $s2, 8($sp)
	sw $s3, 12($sp)
	
	add $s0, $zero, $a0	#save the passed position
	add $s1, $zero, $a1	#save the color value to use

	#Get random letter 33-126
	li $a0, 13
	li $a1, 93
	li $v0, 42
	syscall			#generate a random column number
	add $t0, $zero, $a0	#store the number in t0
	addi $t0, $t0, 33	#convert it to an ascii character
	
	#store the new data
	add $t1, $zero, $t0
	sll $t1, $t1, 16
	or $t1, $t1, $s1
	sll $t1, $t1, 8		#the formatted color and letter data is in t1
	
	sw $t1, 0($s0)		#display it on the screen
	
	
	#restore s registers
	lw $s3, 12($sp)
	lw $s2, 8($sp)
	lw $s1, 4($sp)
	lw $s0, 0($sp)
	addi $sp, $sp, 16
jr $ra

#display that many columns of falling letters
	#letters change as they fall and they fade to black

#ensure 40 active columns


#ASCII	RED	GREEN	BLUE
#Generate letter SLL 16
#Generate color SLL 8

end:
li $v0, 10
syscall
