.data
prompt: .asciiz "Please enter your integer: "
answer: .asciiz "Here is the output: "

.text
add $v0, $zero, 4
la $a0, prompt
syscall			#prompt user for input

add $v0, $zero, 5
syscall			#get input

add $a0, $zero, $v0	#store input in a0	
srl $t1, $a0, 8		#ABCD EFGH IJKL MNOP QRST UVWY -> ABCD EFGH IJKL MNOP	shift specified bytes to first pos 
and $t1, $t1, 0xF	#ABCD EFGH IJKL MNOP -> MNOP remove all bytes not specified

add $v0, $zero, 4	
la $a0, answer
syscall			#print answer prompt

add $v0, $zero, 1
add $a0, $zero, $t1
syscall			#and the integer
