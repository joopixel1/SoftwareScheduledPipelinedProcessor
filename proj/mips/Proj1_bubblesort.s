.data
arr: .word 1, 7, 3, 2, 5, 4, 6
n: .word 7

.text
.global main

# Main function
main:
    # Prepare arguments
    la $a0, arr            # arr
    lw $a1, n              # n

    # Call bubbleSort function
    jal bubbleSort

    # Exit program
    halt
    
    
# Bubble sort function
bubbleSort:
    li $t0, 0              # i = 0
outer_loop:
    li $t1, 0              # j = 0
inner_loop:
    # Calculate array indices
    sll $t2, $t0, 2      # i * 4
    add $t2, $a0, $t2      # &arr[i]
    lw $t4, 0($t2)          # arr[i]
    sll $t3, $t1, 2      # j * 4
    add $t3, $a0, $t3      # &arr[j]
    lw $t5, 0($t3)          # arr[j]

    # Compare arr[i] and arr[j]
    bge $t4, $t5, skip_swap # Branch if arr[j] <= arr[j+1]

    # Swap arr[j] and arr[j+1]
    sw $t5, ($t2)          # arr[(i+1) * n] = arr[i * n]
    sw $t4, ($t3)          # arr[i * n] = arr[(i+1) * n]

skip_swap:
    addi $t1, $t1, 1       # j++
    blt $t1, $a1, inner_loop # Loop through inner loop if j < n

    addi $t0, $t0, 1       # i++
    blt $t0, $a1, outer_loop # Loop through outer loop if i < n

    jr $ra                 # Return