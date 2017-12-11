.data
types:	.asciiz	"bit", "nybble", "byte", "half", "word"
bits:	.asciiz	"one", "four", "eight", "sixteen", "thirty-two"
prompt:	.asciiz "Please enter a datatype:"
in:	.space 100
notfound:	.asciiz "Not found!"
numberofbits:	.asciiz "Number of bits: "

.text
loop:
#load the word in the array and the input as parameters
la $t0, bits		#address
add $t1, $zero, $zero	#offset
add $t2, $zero, $zero	#address+offset

add $t2, $zero, $t1	#add the offset
sll $t2, $t2, 2		#account for size of byte
add $t2, $t2, $t0	#add the value of the address

add $a0, $zero, $t2
addi $v0, $zero, 4 
syscall

addi $t1, $t1, 1
add $t2, $zero, $t1	#add the offset
sll $t2, $t2, 2		#account for size of byte
add $t2, $t2, $t0	#add the value of the address

add $a0, $zero, $t2
addi $v0, $zero, 4 
syscall

addi $t1, $t1, 1
add $t2, $zero, $t1	#add the offset
sll $t2, $t2, 2		#account for size of byte
add $t2, $t2, $t0	#add the value of the address

add $a0, $zero, $t2
addi $v0, $zero, 4 
syscall

addi $t1, $t1, 1
add $t2, $zero, $t1	#add the offset
sll $t2, $t2, 2		#account for size of byte
add $t2, $t2, $t0	#add the value of the address

add $a0, $zero, $t2
addi $v0, $zero, 4 
syscall

addi $t1, $t1, 1
add $t2, $zero, $t1	#add the offset
sll $t2, $t2, 2		#account for size of byte
add $t2, $t2, $t0	#add the value of the address

add $a0, $zero, $t2
addi $v0, $zero, 4 
syscall