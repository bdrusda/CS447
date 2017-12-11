.data
tones: .space 100

.text
newGame:
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
	
	li $t2, 1		#load 1 in	
	sllv $t2, $t2, $a0	#left shift it by the generated number
	sb $t2, 0($t1)		#store the tone in the array
	
	addi $t1, $t1, 4	#move to the next place in the array
	addi $t0, $t0, 1	#increment counter
j setKey

start:
	add $s7, $zero, $t9	#store t9's value
	li $t9, 0		#reset t9's value
	startWait:		#wait for it to finish
		beq $t8, 0, startCont
	j startWait
	
	startCont:
	bne $s7, 16, start	#if start is hit, start the game	if not, jump back into loop
	
	li $t8, 16		#play start sound
	j mainLoop
j start

mainLoop:
	beq $s0, 100, win
	
	#Pass parameters to playSequence
	add $a0, $zero, $s0		#count
	la $a1, tones			#tones addr
	jal playSequence	
	
	#Pass parameters to userPlay
	add $a0, $zero, $s0		#count
	la $a1, tones			#tones addr
	jal userPlay
	
	add $t0, $zero, $v0		#get the result
	beq $t0, $zero, newGame		#if the user didn't input the right sequence of tones, end the game

	addi $s0, $s0, 1		#increment round count
j mainLoop

#		Play Sequence Function
#Inputs:	Count of round number($s0, $a0), address of tones(tones, $a1)
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
		beq $t1, $t0, exitPS	#if all the tones for this round have been played, break
		
		sll $t3, $t1, 2		#get the offset from the address
		add $t3, $t3, $t2	#add the base address
		lw $t3, 0($t3)		#load in the actual tone
		
		add $t8, $zero, $t3	#play the tone
		playTonesWait:		#wait for it to finish
			beq $t8, 0, contPT
		j playTonesWait
		
		contPT:
		addi $t1, $t1, 1	#increment loop count
	j playTones
	
	exitPS:
	#Restore variables
	lw $s0, 0($sp)
	addi $sp, $sp, 4
jr $ra

#		User Play Function
#Inputs:	Count of round number($s0, $a0), address of tones(tones, $a1)
#Outputs:	Result of inputs ($v0)
#Saved:		Count($s0)
userPlay:	nop	
	#save variables
	addi $sp, $sp, -4
	sw $s0, 0($sp)

	#Store parameters and initialize loop counter
	add $t0, $zero, $a0	#static count
	add $t1, $zero, $zero	#loop count
	add $t2, $zero, $a1	#tones first note 
	
	userIn:
		beq $t1, $t0, correctUP
		#load the current tone
		sll $t3, $t1, 2		#get the offset value
		add $t3, $t3, $t2	#add the base address
		lw $t3, 0($t3)		#this is the tone the user needs to match with
		
		#get the input
		getUI:
			bne $t9, 0, contUI	#once the user hits a button
		j getUI
		
		contUI:
		add $t4, $zero, $t9	#save the input value
		li $t9, 0		#reset $t9 to 0 for next input
			
		#play the input sound
		add $t8, $zero, $t4	#play the inputted tone
		inputWait:		#wait for it to finish
			beq $t8, 0, checkUI
		j inputWait
		
		checkUI:
		#check the input
		bne $t3, $t4, failUP	#if the inputs do not match, return 0
		
		addi $t1, $t1, 1	#increment loop count
	j userIn
	
	failUP:
		li $t8, 15		#play failure tone
	
		failWait:		#wait for it to finish
			beq $t8, 0, failCont
		j failWait
		failCont:
		li $v0, 0
	j exit
	correctUP:
		li $v0, 1
	#restore variables
	exit:
		lw $s0, 0($sp)
		addi $sp, $sp, 4
jr $ra

win:
	j newGame