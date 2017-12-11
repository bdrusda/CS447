.text
addi $s1, $zero, 1	#s1 or x = 1
add $s0, $zero, $zero	#s0 or result = 0
addi $t0, $zero, 1	#t0 serves as the conditional check
addi $t1, $zero, 101	#t1 serves as the upper bound of the loop

#check if x is less than 101

loop:
	slt $t0, $s0, $t1	#if s0(result) is < 101, set t0 to 1 otherwise set to 0
	bne $t0, 1, done	#if t0 != 1, jump to done 
	add $s0, $s0, $s1	#result+=x
	addi $s1, $s1, 1	#x++
	j loop			#go back to the top of the loop

done:				#when we're done
	addi $v0, $zero, 1	#print the result
	add $a0, $zero, $s0	
	syscall
	addi $v0, $zero, 10	#and terminate the program
	syscall
