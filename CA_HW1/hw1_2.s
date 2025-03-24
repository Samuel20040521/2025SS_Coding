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
# TODO:
    li s0, 0          # Set i = 0 (outer loop index)
    li s2, 0          # Set max_dp = 0 (track maximum dp value)

outer_loop:
    bge s0, a0, end_outer  # Exit if i >= n
    slli t0, s0, 2    # t0 = 4*i (byte offset)
    add t1, a1, t0    # t1 = address of nums[i]
    lw t2, 0(t1)      # Load nums[i] into t2
    li t3, 1          # Set dp[i] = 1 (minimum length)
    li s1, 0          # Set j = 0 (inner loop index)

inner_loop:
    bge s1, s0, end_inner  # Exit if j >= i
    slli t4, s1, 2    # t4 = 4*j (byte offset)
    add t5, a1, t4    # t5 = address of nums[j]
    lw t6, 0(t5)      # Load nums[j] into t6
    bge t6, t2, skip_update  # Skip if nums[j] >= nums[i]
    add t5, a2, t4    # t5 = address of dp[j]
    lw t4, 0(t5)      # Load dp[j] into t4
    addi t4, t4, 1    # t4 = dp[j] + 1
    ble t4, t3, skip_update  # Skip if dp[j] + 1 <= dp[i]
    mv t3, t4         # Update dp[i] = dp[j] + 1

skip_update:
    addi s1, s1, 1    # Increment j
    j inner_loop      # Repeat inner loop

end_inner:
    add t1, a2, t0    # t1 = address of dp[i]
    sw t3, 0(t1)      # Store dp[i] in memory
    bge s2, t3, no_update_max  # Skip if max_dp >= dp[i]
    mv s2, t3         # Update max_dp = dp[i]

no_update_max:
    addi s0, s0, 1    # Increment i
    j outer_loop      # Repeat outer loop

end_outer:
    mv a0, s2         # Return max_dp in a0
    ret               # Return to caller
