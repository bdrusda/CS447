.data
tones: .space 100

.text
#Intialize variables
addi $s0, $zero, 1	#count of round number

#Set time as seed
li $v0, 30		#get the time
syscall
add $a1, $zero, $a0	#use the time as the seed
li $a0, 0
li $v0, 40		#set the seed
syscall

#Set bounds and prepare to generate numbers
li $a1, 4		#set the range for the buttons
li $a0, 0
li $v0, 42		#generate a random number
la $t1, tones

setKey:
	beq $t0, 100, start	#if we have generated all 100 tones, prepare to start the game
	syscall			#generate the number
	sll $t2, $a0, 1
	sb $t2, 0($t1)		#store the tone in the array
	addi $t1, $t1, 4	#move to the next place in the array
	addi $t0, $t0, 1	#increment counter
j setKey


											#all of the tones needed for a full game have successfully been generated at this point
start:
	add $s7, $zero, $t9	#store t9's value
	li $t9, 0		#reset t9's value
	beq $s7, 16, main_loop	#if start is hit, start the game
j start	#maybe the main loop should be inside of here, not too sure yet

main_loop:
	beq $s0, 100, win
	#pass params
	
	jal playSequence	
	#pass params

	jal userPlay

j main_loop
#the nop's make the label visible in the assembled version

#		Play Sequence Function
#Inputs:	Count of round number($s0), address of tones(tones)
#Outputs:	None
#Saved:		Count($s0)
playSequence:	nop	
	#Save variables
	addi $sp, $sp, -4
	sw $s0, 0($sp)
	#Store parameters and initialize loop counter
	add $t0, $zero, $a0	#static count
	add $t1, $zero, $zero	#loop count
	add $t2, $zero, $a1	#tones first note 
	
	playTones:
		beq $t2, $t0, exitPS	#if all the tones for this round have been played, break
		
	
	
	j playTones
	
	exitPS:
	#Restore variables
	lw $s0, 0($sp)
	addi $sp, $sp, 4

userPlay:	nop	
	#get the input

	#check the input

	#play the sound

	#increment count-- maybe do this outside of function -- probablys
gameover:
	#if user loses
j end
win:
	#if they win the game

end:
	li $v0, 10
	syscall