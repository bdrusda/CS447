.data
prompt: .asciiz "Enter a number of columns:"

.text
#Prompt user for the number of columns
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

#MATRIX STUFF

#character and then color 	li $t0, 0x4100FF00
#address 			li $t1, 0xFFFF8000
#store character in address	sw $t0, 0($t1)

#Starts at 0xFFFF8000
#80 columns, 40 rows

main:
#at first lets just make one column
jal set_column
add $t0, $zero, $v0

jal update_column


j main

j end

#Func set column
set_column:
	#save s registers
	addi $sp, $sp, -4
	sw $s0, 0($sp)
	#Get random column number 1-80
	li $a0, 13
	li $a1, 80
	syscall			#generate a random column number
	add $t0, $zero, $a0	#store the column number
	#Set column speed
	
	add $v0, $zero, $t0	#return the column number
	
	#restore s registers
	lw $s0, 0($sp)
	addi $sp, $sp, 4
jr $ra

#Func update column
update_column:
	#save s registers and return address
	addi $sp, $sp, -8
	sw $s0, 0($sp)
	sw $ra, 4($sp)
   #for each letter in the column
   	li $s0, 0
	twenty_five_iterations:
		#Func update position
		jal update_position
		#Func update color
		jal update_color
		add $t1, $zero, $v0	#store the letter
		#Func update letter
		jal update_letter
		add $t2, $zero, $v0	#store the letter
		
		
		#move on to the next space (+4 in the address)
	
	addi $s0, $s0, 1
	beq $s0, 25, letters_done
	j twenty_five_iterations
	
	letters_done:
	#restore everything
	lw $ra, 4($sp)
	lw $s0, 0($sp)
	addi $sp, $sp, 8
jr $ra	

update_position:
#to be implemented
jr $ra

#Pass in previous color in a0
#
update_color:
	#save s registers
	addi $sp, $sp, -4
	sw $s0, 0($sp)
	
	#load previous color from params
	
	#subtract 10 from the current color
	addi $t0, $t0, -10
	add $v0, $zero, $t0
	
	#restore s registers
	lw $s0, 0($sp)
	addi $sp, $sp, 4
jr $ra

update_letter:
	#save s registers
	addi $sp, $sp, -4
	sw $s0, 0($sp)
	
	#Get random lettter 33-126
	li $a0, 13
	li $a1, 93
	syscall			#generate a random column number
	add $v0, $zero, $a0	#store the number
	addi $v0, $v0, 33	#convert it to an ascii character

	#restore s registers
	lw $s0, 0($sp)
	addi $sp, $sp, 4
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
