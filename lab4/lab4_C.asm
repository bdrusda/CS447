.data
array1: .word 2,4,6,8,10,12,14,16,18,20
array2: .word -1,0,1,-2,0,2,-3,0,3,-4
thesumis: .asciiz "The sum is: "
space: .asciiz " "
newline: .asciiz "\n"

.text
la $s0, array1	#load in addresses
la $s1, array2

add $t1, $zero, $zero	#index
add $t2, $zero, $zero	#offset


add $t3, $zero, $zero	#array1 address
add $t4, $zero, $zero	#array2 address

#-------------------------------------------------------------------------------------------------------
la $a0, thesumis	#print the beginning of the output
addi $v0, $zero, 4
syscall

loop:
add $t2, $zero, $t1	#set the offset equal to the index
sll $t2, $t2, 2		#multiply it four to get the offset in bytes
add $t3, $s0, $t2	#store the address of the next element for array1	- to be passed in func
add $t4, $s1, $t2	#store the address of the next element for array2	- to be passed in func

##store values for function
add $a0, $zero, $t3	#store a1 address in array1
add $a1, $zero, $t4	#store a2 address in array2
##-------------------------

##save registers in stack
addi $sp, $sp, -4	#allocate room for index
sw $t1, 0($sp)		#store the index value
##-----------------------

jal _addition		#go to addition function

add $a0, $zero, $v0	#store the returned sum in a0
addi $v0, $zero, 1	#print the sum
syscall

la $a0, space		#print a space
add $v0, $zero, 4	
syscall


addi $t1, $t1, 1	#increment the index
bne $t1, 10, loop	#if we haven't hit the tenth item yet, reiterate
j end
#---------------
#-------------------------------------------------------------------------------------------------------

#-----------------------------------------------------------------------
_addition:
#store parameters
add $t0, $zero, $a0	#store address of array1
add $t1, $zero, $a1	#store address of array2
#---------------

lw $t2, 0($t0)		#get the value of the current element in array1
lw $t3, 0($t1)		#get the value of the current element in array2

add $t4, $t2, $t3	#add together the elements of the array
add $v0, $zero, $t4	#store the sum in v0 to return it

#restore values from stack
lw $t1, 0($sp)		#load index back into t1
addi $sp, $sp, 4	#free memory for stack
#-------------------------
jr $ra			#jump back to main loop
#-----------------------------------------------------------------------

end:
la $a0, newline		#print the newline character
addi $v0, $zero, 4
syscall

addi $v0, $zero, 10	#terminate the program
syscall