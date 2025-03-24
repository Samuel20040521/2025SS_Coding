.data
nums:   .word 4, 5, 1, 8, 3, 6, 9 ,2    # input sequence
n:      .word 8                        # sequence length
dp:     .word 0, 0, 0, 0, 0, 0, 0, 0, 0   # dp array


.text
.globl main

# This is 1132 CA Homework 1 Problem 2
# Implement Longest Increasing Subsequence Algorithm
# Input: 
#       sequence length (n) store in a0
#       address of sequence store in a1
#       address of dp array with length n store in a2 (we can decide to use or not)        
# Output: Length of Longest Increasing Subsequenc in a0(x10)

# DO NOT MODIFY "main" FUNCTION !!!

main:

    lw a0, n          # a0 = n
    la a1, nums       # a1 = &nums[0]
    la a2, dp         # a2 = &dp[0] 
      
    jal LIS         # Jump to LIS algorithm
    
    # You should use ret or jalr x1 to jump back after algorithm complete
    # Exit program
    # System id for exit is 10 in Ripes, 93 in GEM5 
    li a7, 10
    ecall

LIS:
    # TODO #
    li t0, 0        # i = 0
    li t1, a0       # set the final i is a0

loop1:
    bge  t0, t1, end1 

    li t2, 0        # j = 0

loop2:
    bge t2, t1, end2   # j > 1 goto end2
    # compare a3 and a4
    li t4, 4
    mul t4, t4, t0  # get 4i
    lw a3, t4(a1)   # a3 = num[i]
    li t4, 4
    mul t4, t4, t2  # get 4j
    lw a4, t4(a1)   # a4 = num[j]
    
    slt t0, a4, a3     # t0 = (a4 < a3) ? 1 : 0
    beqz t0, pass     # 若 t0 == 0（a4 >= a3），跳到 pass
    
    # dp[i] = max(dp[i], dp[j] + 1);
    li t3, 4  
    mul t3, t2, t3 # 4 * j
    lw t5, t3(t5)   # t5 = dp[j]
    
    li t3 ,4
    mul t3, t0, t3
    lw t6 , t3(t6)

    addi t5, t5, 1 # t5 =  dp[j] + 1
    slt t4, t6, t5 # if dp[i] <  dp[j]+1
    beqz t4, pass  # if dp[i] >= dp[j]+1, goto pass
    
    sw t5, 0(t6)   # dp[i] = dp[j] + 1

pass:
    addi t2, t2, 1
    j loop2

end2:   

    addi t0, t0, 1
    j loop1

end1:

