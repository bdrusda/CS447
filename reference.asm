.data
array1: .word 0,1,2,3,4,5,6,7,8,9


.text
la $t1, array1		#array
add $s0, $zero, $zero	#sum

#add the first element
lw $t2, 0($t1)
add $s0, $s0, $t2

lw $t2, 4($t1)
add $s0, $s0, $t2

lw $t2, 8($t1)
add $s0, $s0, $t2

lw $t2, 12($t1)
add $s0, $s0, $t2

lw $t2, 16($t1)
add $s0, $s0, $t2

lw $t2, 20($t1)
add $s0, $s0, $t2

lw $t2, 24($t1)
add $s0, $s0, $t2

lw $t2, 28($t1)
add $s0, $s0, $t2

lw $t2, 32($t1)
add $s0, $s0, $t2

lw $t2, 36($t1)
add $s0, $s0, $t2

lw $t2, 40($t1)
add $s0, $s0, $t2