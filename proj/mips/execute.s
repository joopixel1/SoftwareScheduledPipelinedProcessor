#
# First part of the Lab 3 test program
#

# data section
.data
array: .word 0, 0, 0, 0, 0, 0

# code/instruction section
.text
lui $1, 0x7fff # $1 - 0x7fff0000
sll $0, $0, 0
sll $0, $0, 0

addiu $2, $1, 0x7fff # $2 - 0x7fff7fff
sll $0, $0, 0
sll $0, $0, 0
addiu $2, $2, 0x7fff # $2 - 0x7ffffffe
sll $0, $0, 0
sll $0, $0, 0
addiu $3, $2, 0x7fff # $3 - 0x80007ffd
addiu $4, $1, 0x7fff # $4 - 0x7fff7fff
sll $0, $0, 0
addiu $5, $2, 0x7fff # $5 - 0x8007fffd

addu $6, $1, $2 # $6 - 0xfffefffe
addu $7, $1, $3 # $7 - 0xffff7ffd

addu $8, $1, $2 # $8 - 0xfffefffe
addu $9, $1, $3 # $9 - 0xffff7ffd

subu $10, $2, $3 # $10 - 0xffff8001
subu $11, $2, $3 # $11 - 0xffff8001

and $12, $1, $2 # $12 - 0x7fff0000
andi $13, $1, 0x0f0f # $13 - 0x00000000
andi $14, $1, 0xf0f0 # $14 - 0x00000000

xor $15, $1, $2      # $15 - 0x0000fffe
xori $16, $1, 0x0f0f # $16 - 0x7fff0f0f
xori $17, $1, 0xf0f0 # $17 - 0x7ffff0f0

or $18, $1, $2 # $18 - 0x7ffffffe
ori $19, $1, 0x0f0f # $19 - 0x7fff0f0f
ori $20, $1, 0xf0f0 # $20 - 0x7ffff0f0

nor $21, $1, $2 #$21 = 0x80000001

sll $2, $2, 0x0001 # $2 - 0xfffffffc
sll $3, $3, 0x0004 # $3 - 0x0007ffd0
sll $0, $0, 0

sra $2, $2, 0x0001 # $2 - 0xfffffffe
sra $3, $3, 0x0004 # $3 - 0x00007ffd
sll $0, $0, 0

srl $2, $2, 0x0001 # $2 - 0x0fffffff
srl $3, $3, 0x0004 # $3 - 0x000007ff
sll $0, $0, 0

addiu $10, $0, 8 # $10 - 0x00000008
addiu $11, $0, 16 # $11 - 0x00000010
sll $0, $0, 0

sllv $4, $4, $10 # $4 - 0xff7fff00
sllv $5, $5, $11 # $5 - 0x7ffd0000
sll $0, $0, 0

srav $4, $4, $10 # $4 - 0xffff7fff
srav $5, $5, $11 # $5 - 0x00007ffd
sll $0, $0, 0

srlv $4, $4, $10 # $4 - 0x00ff7fff
srlv $5, $5, $11 # $5 - 0x00000000


lasw $31, array
sll $0, $0, 0
sll $0, $0, 0
sw $19, 0($31)
sw $20, 4($31)
sw $21, 8($31)

lw $22, 0($31)
lw $23, 4($31)
lw $24, 8($31)

lbu $25, 0($31) 
lbu $26, 1($31) 
lbu $27, 2($31)
 
lhu $28, 0($31) 
lhu $29, 2($31) 
lhu $30, 4($31)

lb $25, 0($31) 
lb $26, 1($31) 
lb $27, 2($31)

lh $28, 0($31) 
lh $29, 2($31) 
lh $30, 4($31)


beq $16, $19, Lal
sll $0, $0, 0

Lal:
beq $16, $17, Te
sll $0, $0, 0

Te:
bne $16, $19, Un
sll $0, $0, 0

Un:
bne $16, $17, Jus
sll $0, $0, 0


Jus:
slti $6, $0, 0x00ff
slti $7, $0, 0x0ff0
 
j Ade
sll $0, $0, 0

Ade:
slt $8, $0, $20
slt $9, $0, $21
j T
sll $0, $0, 0

funct:
sll $0, $0, 0
jr $31
sll $0, $0, 0
 
T:
jal funct
sll $0, $0, 0

halt