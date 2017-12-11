.data
prompt: .asciiz "Enter a number of columns:"
#TODO array for column head loc's
#TODO array for column speed

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
li $t9, 0x4100FF00	#samples to test update color and letter
li $t8, 0xFFFF8000
sw $t9, 0($t8)

main:
#at first lets just make one column

#TODO loop for setting columns
#TODO set n number of columns in given array location (param a0)
jal set_column
add $s0, $zero, $v0


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
	li $v0, 42
	syscall			#generate a random column number
	add $t0, $zero, $a0	#store the column number
	#Set column speed
	
	#TODO setup column in random position, storing it in memory array
	#TODO setup column speed randomly, storing it in memory array 
	
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
   	
   #TODO need variable to check if the column should be updated on this iteration, it_num
   #TODO check if this iteration is one that the column should be updated on
	twenty_five_iterations:
		#bump down
		#fade and change letter
		#do this until the head loc is greater than 25 lines past the max bottom
			#slt b200 or whatever it was + 25*320
		
		
		#Func update position
		add $a0, $zero, $t8		#send the current position
		jal update_position
		add $t8, $zero, $v0		#save the updated position
		
		#Func update color and letter
		add $a0, $zero, $t9		#send the current data
		jal update_color_and_letter
		add $t9, $zero, $v0		#save the updated color and letter
		
		sw $t9, 0($t8)			#display it back on the terminal
		
		#Func clear previous
		add $a0, $zero, $t8
		jal clear_previous
		
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
	#save s registers
	addi $sp, $sp, -4
	sw $s0, 0($sp)
	
	add $s0, $zero, $a0	#save the passed value
	addi $s0, $s0, 320	#move it down a row
	#DEBGUG loop column
	bne $s0, 0xFFFFB200, debug2
	li $s0, 0xFFFF8000
	debug2:
	#DEBUG
	
	add $v0, $zero, $s0	#return the position
	
	#restore s registers
	lw $s0, 0($sp)
	addi $sp, $sp, 4
jr $ra

update_color_and_letter:
	#save s registers
	addi $sp, $sp, -4
	sw $s0, 0($sp)
	
	add $s0, $zero, $a0	#save the passed value
#Update letter
	#Get random letter 33-126
	li $a0, 13
	li $a1, 93
	li $v0, 42
	syscall			#generate a random column number
	add $t0, $zero, $a0	#store the number
	addi $t0, $t0, 33	#convert it to an ascii character
	
#Update color	
	#load previous color from params
	add $t1, $zero, $s0
	#subtract 10 from the current color
	sll $t1, $t1, 8
	srl $t1, $t1, 16 
	addi $t1, $t1, -10
	
	bne $t1, -5, debug
	li $t1, 255
	debug:
	
	#store the new data
	add $t3, $zero, $t0
	sll $t3, $t3, 16
	or $t3, $t3, $t1
	sll $t3, $t3, 8
	
	add $v0, $zero, $t3
	
	
	#restore s registers
	lw $s0, 0($sp)
	addi $sp, $sp, 4
jr $ra

clear_previous:
	#save s registers
	addi $sp, $sp, -4
	sw $s0, 0($sp)
	
	add $s0, $zero, $a0	#save the passed value
	add $s0, $s0, -320	#get the previous column
	bne $s0, 0xFFFF7EC0, not_bottom
	li $s0, 0xFFFFB200
	not_bottom:
	li $s1, 0x00000000
	sw $s1, 0($s0)	#clear the space in that spot

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
