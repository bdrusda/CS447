.text
addi $t9, $zero, 1	#start in clock mode
#addi $t9, $zero, 2	#temp to set up stopwatch mode

main_loop:

beq $t9, $zero, unchanged
add $s7, $zero, $t9	#store t9's value if it is not zero
add $t9, $zero, $zero	#set t9 back to zero so it can receive the next input
unchanged:

add $s3, $zero, $zero	#reset the stored time in the stopwatch to 0
#Check t9
clock_check:
	bne $s7, 1, stopwatch_check	#if t9 is 1
	##Get current time-----
	addi $v0, $zero, 30
	syscall

	add $t0, $zero, $a0	#store time values in temporary registers
	add $t1, $zero, $a1

	divu  $t0, $t0, 1000	#store the lo value in t0

	add $t2, $zero, 10000000
	multu $t1, $t2		#shift hi value over
	mflo $t1		#put hi value in t1
	addu $t3, $t0, $t1	#store the time in seconds in t3

	divu $t3, $t3, 60	#left with total minutes
	mfhi $t4		#store current seconds in t4
	divu $t3, $t3, 60	#left with total hours
	mfhi $t5		#store current minute in t5
	divu $t3, $t3, 24	#left with days, not that it's important
	mfhi $t6		#store current hour in t6
	addi $t6, $t6, 4	#convert hours to est						shouldn't this be -4? why does this work?
	slti $t7, $t6, 24	#DBG	#slti $t7, $t6, 0		#make sure the time isn't negative
	bne $t7, 1, timeadjust	#DBG	#beq $t7, 1, timeadjust	#if it is, add 24 to loop back around

	j clock_cont
	timeadjust:
		addi $t6, $t6, -24	#DBG	#addi $t6, $t6, 24
	clock_cont:
		add $s0, $zero, $t6	#move time into one register (s0)
		sll $s0, $s0, 8
		add $s0, $s0, $t5
		sll $s0, $s0, 8
		add $s0, $s0, $t4
		add $t8, $zero, $s0	#move time into the time register all at once
	##---------------------

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
		bne $t9, 0, loop_end
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
	
	#Get the time difference
	start_loop:
		add $t7, $zero, $t8	#store time in case this is the timer function
		addi $v0, $zero, 30	#get time again
		syscall
		add $t0, $zero, $a0	#we don't need the whole thing because we only care about having a reference point.  As long as it's consistent it will work
		divu $t0, $t0, 1000
		sub $s2, $t0, $s1	#store the time difference in s2
		add $s2, $s2, $s3	#add the stored time in case stop was previously hit
	#commonalities end around here?
		#stopwatch instructions are necessary in timer use as well
			add $t0, $zero, $s2	#store the time difference in t0
			divu $t0, $t0, 60	
			mfhi $t1		#store seconds in t1
			divu $t0, $t0, 60
			mfhi $t2		#store minutes in t2
			divu $t0, $t0, 24
			mfhi $t3		#store hours in t3 
		bne $s6, 1, cont_common		#if not in stimer mode, skip this
		#these are timer specific instructions
			add $t0, $zero, $t7	#store the timer time in t0
			sll $t4, $t0, 24
			srl $t4, $t4, 24	#store timer seconds in t4
			sll $t5, $t0, 16
			srl $t5, $t5, 24	#store timer minutes in t5
			srl $t6, $t0, 16	#store timer hours in t6
			
			sub $t3, $t6, $t3	#store remaining hours in t3
			sub $t2, $t5, $t2	#store remaining minutes in t2
			sub $t1, $t4, $t1	#store remaining seconds in t1
			
		
		
		
#these are commonalities between timer and stopwatch
		cont_common:
			add $s2, $zero, $t3	#store hours
			sll $s2, $s2, 8		#shift for minutes
			add $s2, $s2, $t2	#store minutes
			sll $s2, $s2, 8		#shift for seconds
			add $s2, $s2, $t1	#store seconds

			add $t8, $zero, $s2	#display time on clock

			beq $t8, $zero, reset
			#t9 checks
			beq $t9, 64, start_cont		#if t9 changes, but it's start again, continue
			bne $t9, $zero, main_loop	#if t9 changes to something new do checks
			start_cont:
				add $t9, $zero, $zero		#reset t9 to zero
	j start_loop
	
stop_check:
	bne $s7, 128, reset_check	#if t9 is 128
	add $s3, $zero, $t8		#store the time
	stop_loop:
		bne $t9, 64, stop_cont
		addi $s7, $zero, 64	#set t9 to 64 to go back into the stopwatch start loop
		j start_check
		bne $t9, 4, stop_cont
		addi $s7, $zero, 64	#set t9 to 4 to go back into the timer start loop
		j start_check
		stop_cont:
			bne $t9, 0, loop_end	
	j stop_loop
reset_check:
	bne $s7, 256, loop_end		#if t9 is 256
	reset:
		add $t8, $zero, $zero		#reset the display

loop_end:

j main_loop
