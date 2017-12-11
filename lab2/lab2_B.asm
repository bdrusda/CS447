.text

addi $v0, $zero, 40	#generate random seed
add $a0, $zero, $zero	#RNG ID to 0
addi $a1, $zero, 5	#random seed set to 5
syscall

addi $v0, $zero, 42	
syscall			

#generate between 0 and 30
addi $v0, $zero, 42	#code to gen random number
addi $a1, $zero, 31	#set the upper bound to 30
syscall			#generate number with given bounds
add $s0, $zero, $a0	#store number in s0

add $a0, $zero, $s0	#seems redundant but I think it's the safe thing to do
addi $v0, $zero, 1	#code to print an int
syscall			#print int

#generate between -10 and 10
addi $v0, $zero, 42	#code to gen random number
addi $a1, $zero, 21	#set the upper bound to 20
syscall			#generate number
add $s1, $zero, $a0	#store number in s1
add $s1, $s1, -10	#subtract 10 to make the lower bound -10

add $a0, $zero, $s1	#store the value back in $a0
addi $v0, $zero, 1	#code to print an int
syscall			#print it out
