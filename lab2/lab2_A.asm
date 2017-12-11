.data
prompt1: .asciiz "Please enter your first number:"
prompt2: .asciiz "Please enter your second number:"
theSum: .asciiz "The sum of "
aand: .asciiz " and "
is: .asciiz " is "

.text

la $a0, prompt1
addi $v0, $zero, 4	#print string
syscall	

addi $v0, $zero, 5
syscall			#get input
add $s0, $zero, $v0	#s0 holds num 1

la $a0, prompt2
addi $v0, $zero, 4	#print string
syscall

addi $v0, $zero, 5
syscall			#get input
add $s1, $zero, $v0	#s1 holds num 2

la $a0, theSum
addi $v0, $zero, 4
syscall			#print first portion of string

add $a0, $zero, $s0
addi $v0, $zero, 1
syscall			#print first number

la $a0, aand
addi $v0, $zero, 4
syscall			#print and

add $a0, $zero, $s1
addi $v0, $zero, 1
syscall			#print second number

la $a0, is
addi $v0, $zero, 4
syscall			#print is

add $s2, $s0, $s1	#s3 holds the sum

add $a0, $zero, $s2
addi $v0, $zero, 1
syscall			#print the sum

addi $v0, $zero, 10
syscall