
.data
input: .word 7

.text
.global main

# This is 1132 CA Homework 1
# Implement fact(x) = 4*F(floor(n-1)/2) + 8n + 3 , where F(0)=4
# Input: n in a0(x10)
# Output: fact(n) in a0(x10)
# DO NOT MOTIFY "main" function

main:        
	# Load input into a0
	lw a0, input
	
	# Jump to fact   
	jal fact       

    # You should use ret or jalr x1 to jump back here after function complete
	# Exit program
    # System id for exit is 10 in Ripes, 93 in GEM5 !
    li a7, 10
    ecall

fact:
    # TODO #
    # Alocate stack frame
    addi sp, sp, -16
    sw ra, 8(sp)
    sw a0, 0(sp)
    
    # Base Case: n=0
    bne a0, zero, no_base
    # Base case: n = 0 -> return 4
    addi a0, zero, 4
    addi sp, sp, 16
    jr x1

no_base:
    # Recursive Case
    andi t0, a0, 1 # t0 = a0 & 1 (check last bit)
    bne t0, zero, odd 
    # even case
    addi a0, a0, -2

odd:
    li t1 , 1         
    srl a0, a0, t1
    jal ra, fact
    
    addi t2, a0, 0           # t2 = fact(old)
    lw a0, 0(sp)     
    lw ra, 8(sp)
    addi sp, sp, 16
    
    li t1, 4
    mul t2, t2, t1           # t2 = 4 * fact(old)
    li t1, 8
    mul t1, a0, t1           # t1 = 8 * n
    add t2, t1, t2           # t2 = 4 * fact(old) + 8 * n
    li t1, 3
    add a0, t2, t1           # a0 = 4 * fact(old) + 8 * n + 3
    ret
    
    
