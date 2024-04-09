main:
	ori $s0, $zero 0x1234
	j skip
	sll $0, $0, 0
	li $s0 0xffffffff
skip:
	ori $s1 $zero 0x1234
	sll $0, $0, 0
	sll $0, $0, 0
	beq $s0 $s1 skip2
	sll $0, $0, 0
	li $s0 0xffffffff
skip2:
	jal fun
	sll $0, $0, 0
	ori $s3 $zero 0x1234
	beq $s0, $zero exit
	sll $0, $0, 0
	ori $s4 $zero 0x1234
	j exit
	sll $0, $0, 0

fun:
	ori $s2 $zero 0x1234
	jr $ra
	sll $0, $0, 0
exit:
	halt

