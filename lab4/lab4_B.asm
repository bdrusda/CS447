.data
array1: .word 0,1,2,3,4,5,6,7,8,9
output: .asciiz "The sum is "

.text
la $t0, array1		#array
add $s0, $zero, $zero	#sum
add $t1, $zero, $zero	#index
add $t2, $zero, $zero	#offset
add $t3, $zero, $zero	#array address
add $t4, $zero, $zero	#array value


#add each element
loop:
add $t2, $zero, $t1	#set the offset equal to the index
sll $t2, $t2, 2		#multiply it four to get the next address

add $t3, $t0, $t2	#calculate the address - array address + offset

lw $t4, 0($t3)		#load in the next piece of the array
add $s0, $s0, $t4	#add it to the total

addi $t1, $t1, 1	#increment the index
bne $t1, 10, loop	#if we haven't hit the tenth item yet, reiterate

#Output segment
la $a0, output		#print the output
addi $v0, $zero, 4
syscall

add $a0, $zero, $s0	#print the sum
addi $v0, $zero, 1
syscall

addi $v0, $zero, 10	#exit
syscall
