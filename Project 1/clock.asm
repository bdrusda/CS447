.text
addi $t9, $zero, 1	#start in clock mode

main_loop:
beq $t9, $zero, unchanged
add $s7, $zero, $t9	#store t9's value if it is not zero
add $t9, $zero, $zero	#set t9 back to zero so it can receive the next input

unchanged:
	add $s4, $zero, $zero	#reset the stored time in the stopwatch to 0

clock_check:
	bne $s7, 1, stopwatch_check	#if t9 is 1
	addi $v0, $zero, 30
	syscall

	add $t0, $zero, $a0	#store time values in temporary registers
	add $t1, $zero, $a1

	divu  $t0, $t0, 1000	#store the lo value in t0

	add $t2, $zero, 1000000
	multu $t1, $t2		#shift hi value over
	mflo $t1		#put hi value in t1
	addu $t3, $t0, $t1	#store the time in seconds in t3

	divu $t3, $t3, 60	#left with total minutes
	mfhi $t4		#store current seconds in t4
	divu $t3, $t3, 60	#left with total hours
	mfhi $t5		#store current minute in t5
	divu $t3, $t3, 24	#left with days, not that it's important
	mfhi $t6		#store current hour in t6
	addi $t6, $t6, -4	#convert hours to est		
	slti $t7, $t6, 0	#make sure the time isn't negative
	beq $t7, 1, timeadjust	#if it is, add 24 to loop back around

	j clock_cont
	timeadjust:
		addi $t6, $t6, 24
	clock_cont:
		add $s0, $zero, $t6	#move time into one register (s0)
		sll $s0, $s0, 8
		add $s0, $s0, $t5
		sll $s0, $s0, 8
		add $s0, $s0, $t4
		add $t8, $zero, $s0	#move time into the time register all at once

stopwatch_check:
	bne $s7, 2, timer_check		#if t9 is 2
	add $t8, $zero, $zero		#display 00:00:00
	addi $s6, $zero, 0		#0 = stopwatch case
	
timer_check:
	bne $s7, 4, hour_check		#if t9 is 4
	add $t8, $zero, $zero		#display 00:00:00
	addi $s6, $zero, 1		#1 = timer case
	hms_checks:
		beq $t9, 8, hour_check
		beq $t9, 16, minute_check
		beq $t9, 32, second_check
		bne $t9, 0, loop_end		#might be able to just jump to hour_check
	j hms_checks
	
hour_check:
	bne $s7, 8, minute_check	#if t9 is 8
	add $t0, $zero, $t8 		#store a copy of hours
	srl $t0, $t0, 16		#shift down to hours slot
	addi $t0, $t0, 1		#add one to it
	slti $t1, $t0, 24		#check if we are past 23 hours
	beq $t1, 1, hour_cont		#if we have not past 23 hours, don't change anything
	subi $t0, $t0, 24		#if have have past 23 hours, move the clock down to 0
	#alternatively can just set it to 0
	hour_cont:
	sll $t0, $t0, 16		#shift it back
	#restore minutes and seconds
	add $t1, $zero, $t8		#store the time again
	sll $t1, $t1, 16		#erase the hours digits in the time	
	srl $t1, $t1, 16		#shift the time back in place
	or $t1, $t1, $t0		#put new hours back in place
	
	add $t8, $zero, $t1		#move the completed new time into t8
	add $t9, $zero, $zero	
	j hms_checks
	
minute_check:
	bne $s7, 16, second_check	#if t9 is 16
	add $t0, $zero, $t8 		#store a copy of minutes
	
	#remove hours
	sll $t0, $t0, 16		#remove hours from the time
	srl $t0, $t0, 16		#shift minutes and seconds back in place
	#remove seconds
	srl $t0, $t0, 8			#shift minute to the first byte

	addi $t0, $t0, 1		#add one to it
	slti $t1, $t0, 60		#check if we are past 23 hours
	beq $t1, 1, min_cont		#if we have not past 23 hours, don't change anything
	subi $t0, $t0, 60		#if have have past 23 hours, move the clock down to 0

	min_cont:
	sll $t0, $t0, 8		#shift it back
	#restore hours
	add $t1, $zero, $t8		#store the time again
	srl $t1, $t1, 16		#erase the minutes(and seconds) digits in the time	
	sll $t1, $t1, 16		#shift the time back in place
	or $t1, $t1, $t0		#hours and minutse are back in place
	#restore seconds
	add $t0, $zero, $t8		#store the time once more
	sll $t0, $t0, 24		#get just the seconds
	srl $t0, $t0, 24		#move the seconds back
	or $t1, $t1, $t0		#store the time in t1
	
	add $t8, $zero, $t1		#move the completed new time into t8
	add $t9, $zero, $zero	
	j hms_checks
	
second_check:
	bne $s7, 32, start_check	#if t9 is 32
	
	add $t0, $zero, $t8		#store time
	sll $t0, $t0, 24		#isolate seconds
	srl $t0, $t0, 24		#restore seconds to correct byte
	add $t0, $t0, 1			#increment seconds
	slti $t1, $t0, 60		#check if the seconds have gone over 59
	beq $t1, 1, sec_cont
	subi $t0, $t0, 60		#reset the clock
	sec_cont:
	
	add $t1, $zero, $t8		#get another copy of time
	srl $t1, $t1, 8			#remove the seconds
	sll $t1, $t1, 8			#store hours and minutes to correct bytes
	or $t1, $t1, $t0		#store time in t1
	
	
	add $t8, $zero, $t1		#store completed time in t8
	add $t9, $zero, $zero		
	j hms_checks
	
start_check:
	bne $s7, 64, stop_check		#if t9 is 64
	#Get the current seconds
	addi $v0, $zero, 30	#get time
	syscall
	add $t0, $zero, $a0	#store ms
	divu $t0, $t0, 1000	#convert to seconds
	add $s1, $zero, $t0	#store the start seconds
	add $t7, $zero, $t8	#store the current time in the case of the timer function
	
	#Get the time difference
	start_loop:
		addi $v0, $zero, 30	#get time again
		syscall
		add $t0, $zero, $a0	#we don't need the whole thing because we only care about having a reference point.  As long as it's consistent it will work
		divu $t0, $t0, 1000
		sub $s2, $t0, $s1	#store the time difference in s2
		#stopwatch instructions
		bne $s6, 0, case
			add $s2, $s2, $s4	#add the stored time in case stop was previously hit
			add $t0, $zero, $s2	#store the time difference in t0
			divu $t0, $t0, 60	
			mfhi $t1		#store seconds in t1
			divu $t0, $t0, 60
			mfhi $t2		#store minutes in t2
			divu $t0, $t0, 24
			mfhi $t3		#store hours in t3 
			
			add $s2, $zero, $t3	#store hours
			sll $s2, $s2, 8		#shift for minutes
			add $s2, $s2, $t2	#store minutes
			sll $s2, $s2, 8		#shift for seconds
			add $s2, $s2, $t1	#store seconds

			add $t8, $zero, $s2	#display time on clock
		
		case:
		#these are timer specific instructions
		bne $s6, 1, start_cont
			#convert timer time to seconds
			add $t0, $zero, $t7	#store timer time in t0
			sll $t1, $t0, 24	
			srl $t1, $t1, 24	#store seconds in t1
			sll $t2, $t0, 16
			srl $t2, $t2, 24	
			addi $t5, $zero, 60
			multu $t2, $t5
			mflo $t2		#store minutes in seconds in t2
			srl $t3, $t0, 16
			addi $t5, $zero, 3600
			multu $t3, $t5
			mflo $t3		#store hours in seconds in t3
			add $s3, $t1, $t2
			add $s3, $s3, $t3	#get total timer time in seconds
			
			#subtract time diff from timer time
			sub $t0, $s3, $s2	#store time remaining in t0
			slti $t1, $t0, 1	#if the time remaining is less than or equal to 0
			beq $t1, 1, reset	#reset
			#convert to HMS
			divu $t0, $t0, 60
			mfhi $t1		#store seconds remaining in t1
			divu $t0, $t0, 60
			mfhi $t2		#store minutes remaining in t2
			divu $t0, $t0, 24	
			mfhi $t3		#store hours remaining in t3 
			
			add $t5, $zero, $t3	#store hours
			sll $t5, $t5, 8		#shift for minutes
			add $t5, $t5, $t2	#store minutes
			sll $t5, $t5, 8		#shift for seconds
			add $t5, $t5, $t1	#store seconds

			add $t8, $zero, $t5	#display time on clock
		
			#check for and nullify HMS buttons
			beq $t9, 8, nullify_HMS	
			beq $t9, 16, nullify_HMS
			beq $t9, 32, nullify_HMS
			start_cont:
				#t9 checks
				beq $t9, 64, start_reset	#if t9 changes, but it's start again, continue
				bne $t9, $zero, main_loop	#if t9 changes to something new do checks
			start_reset:
				add $t9, $zero, $zero		#reset t9 to zero
	j start_loop
	
stop_check:
	bne $s7, 128, reset_check		#if t9 is 128
	add $s4, $zero, $t8			#store the time
	stop_loop:
		bne $t9, 64, stop_cont
			addi $s7, $zero, 64	#set s7 to 64 to go back into the stopwatch start loop
			j start_check
		bne $t9, 4, stop_cont
			addi $s7, $zero, 64	#set s7 to 4 to go back into the timer start loop
			j start_check
		bne $t9, 128, stop_cont
			add $t9, $zero, $zero
		stop_cont:
			bne $t9, 0, loop_end	
	j stop_loop
reset_check:
	bne $s7, 256, loop_end			#if t9 is 256
	reset:
		add $t8, $zero, $zero		#reset the display

loop_end:

j main_loop

nullify_HMS:
	add $t9, $zero, $zero			#ignore HMS buttons
	j start_cont