.text

li $s1, 5	#x is 1
li $s2, 11	#y is 2
li $s3, -8	#z is 3
add $s1, $s1, $s3	#x=x+z
add $s2, $s2, $s1	#y=y+x

li $v0, 1		#print num
move $a0, $s2		#num to print is y
syscall			#print it

li $v0, 10		#exit call
syscall			#exit it
