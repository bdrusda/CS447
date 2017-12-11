.data
prompt: .asciiz "Enter a null-terminated string\n"
thereare: .asciiz "There are "
charactersin: .asciiz " characters in the string\n"
input: .space 100

.text
la $a0, prompt		#print the prompt
addi $v0, $zero, 4
syscall

la $a0, input		#get input from user
li $a1, 100
addi $v0, $zero, 8
syscall

#pass parameters to function
la $a0, input
#---------------------------

jal _strLength		#get the length of the string

add $s0, $zero, $v0	#store the result of the function in $s0

j end			#output the result and end the program

#--------------------------------------------

_strLength:
##store parameters
add $t0, $zero, $a0	#string in t0
##----------------
add $t1, $zero, $zero	#index

str_loop:

add $t2, $t0, $t1	#get the current byte in the string
lbu $t3, 0($t2)		#store the current character in t4

addi $t1, $t1, 1	#increment the index
bne $t3, 0, str_loop	#if the byte is not 0, go back to the loop

add $t1, $t1, -2 #the null terminator is being read in as 10 followed by 0, length must be decremented by 2 to account for this


##return value to main
add $v0, $zero,$t1
##--------------------

jr $ra
#--------------------------------------------

#--------------------------------------------
end:
la $a0, thereare	#print there are
addi $v0, $zero, 4
syscall

add $a0, $zero, $s0	#print strlen
addi $v0, $zero, 1
syscall

la $a0, charactersin	#print characters in
addi $v0, $zero, 4
syscall

addi $v0, $zero, 10	#terminate program
syscall
#--------------------------------------------