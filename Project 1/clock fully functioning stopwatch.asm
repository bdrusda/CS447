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

	j continue
	timeadjust:
		addi $t6, $t6, -24	#DBG	#addi $t6, $t6, 24
	continue:

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
	addi $s6, $zero, 0		#1 = stopwatch case
timer_check:
	bne $s7, 4, hour_check		#if t9 is 4
	add $t8, $zero, $zero		#display 00:00:00
	addi $s6, $zero, 1		#0 = timer case
hour_check:
	bne $s7, 8, minute_check	#if t9 is 8
minute_check:
	bne $s7, 16, second_check	#if t9 is 16
second_check:
	bne $s7, 32, start_check	#if t9 is 32
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
		addi $v0, $zero, 30	#get time again
		syscall
		add $t0, $zero, $a0	#we don't need the whole thing because we only care about having a reference point.  As long as it's consistent it will work
		divu $t0, $t0, 1000
		sub $s2, $t0, $s1	#store the time difference in s2
		add $s2, $s2, $s3	#add the stored time in case stop was previously hit
		
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
		add $s7, $zero, 64	#set t9 to 64 to go back into the start loop
		j start_check
		stop_cont:
		bne $t9, 0, loop_end	
	j stop_loop
reset_check:
	bne $s7, 256, loop_end		#if t9 is 256
	add $t8, $zero, $zero		#reset the display

loop_end:

j main_loop
