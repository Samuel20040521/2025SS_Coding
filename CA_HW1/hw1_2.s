.data
# nums:   .word 4, 5, 1, 8, 3, 6, 9, 2    # input sequence
nums:   .word 4, 5, 1
# n:      .word 8                        # sequence length
n:      .word 3
# dp:     .word 0, 0, 0, 0, 0, 0, 0, 0    # dp array
dp:     .word 0, 0, 0
.text
.globl main

main:
    lw a0, n          # a0 = n
    la a1, nums       # a1 = &nums[0]
    la a2, dp         # a2 = &dp[0] 
      
    jal LIS         # Jump to LIS algorithm
    
    # 輸出 dp 陣列
    la a1, dp         # a1 = &dp[0]
    lw a0, n          # a0 = n
    jal print_dp      # 呼叫 print_dp 函數

    # Exit program
    li a7, 10
    ecall

LIS:
    # TODO #
    addi sp, sp, -40  # Allocate stack space
    sw ra, 0(sp)       # Save return address
    sw s0, 4(sp)       # Save s0 (n)
    sw s1, 8(sp)       # Save s1 (nums)
    sw s2, 12(sp)      # Save s2 (dp)
    sw s3, 16(sp)      # Save i
    sw s4, 20(sp)      # Save j
    sw s5, 24(sp)      # Save max
    sw s6, 28(sp)      # Save nums[i]
    sw s7, 32(sp)      # Save nums[j]
    sw t0, 36(sp)      # temp

    mv s0, a0         # s0 = n
    mv s1, a1         # s1 = nums
    mv s2, a2         # s2 = dp

    li s3, 0          # i = 0
LIS_LOOP_I:
    bge s3, s0, LIS_END_I # if i >= n, exit loop

    lw s6, 0(s1)      # s6 = nums[i]
    addi t0, s3, 0
    slli t0, t0, 2
    add t0, s2, t0
    addi t0, t0, 4
    sw t0, 0(sp)
    li t0, 1
    lw t1, 0(sp)
    sw t0, 0(t1)       # dp[i] = 1

    li s4, 0          # j = 0
LIS_LOOP_J:
    bge s4, s3, LIS_END_J # if j >= i, exit loop

    lw s7, 0(s1)      # s7 = nums[j]
    addi t0, s4, 0
    slli t0, t0, 2
    add t0, s2, t0
    lw t0, 0(t0)      # t0 = dp[j]

    blt s7, s6, LIS_IF_END # if nums[j] < nums[i], skip

    addi t0, t0, 1   # dp[j] + 1
    addi t2, s3, 0
    slli t2, t2, 2
    add t2, s2, t2
    lw t1, 0(t2) # t1 = dp[i]
    ble t0, t1, LIS_IF_END # if dp[j] + 1 <= dp[i], skip

    sw t0, 0(t2)      # dp[i] = dp[j] + 1

LIS_IF_END:
    addi s4, s4, 1    # j++
    addi s1, s1, 4    # nums++
    j LIS_LOOP_J

LIS_END_J:
    sub s1, s1, s3,
    li s11, 4
    sub s1, s1, s11

    addi s3, s3, 1    # i++
    addi s1, s1, 4    # nums++
    j LIS_LOOP_I

LIS_END_I:
    li s5, 0          # max = 0
    li s3, 0          # i = 0

LIS_MAX_LOOP:
    bge s3, s0, LIS_MAX_END

    addi t0, s3, 0
    slli t0, t0, 2
    add t0, s2, t0
    lw t0, 0(t0)      # t0 = dp[i]

    ble s5, t0, LIS_MAX_IF_END # if max <= dp[i], skip

    j LIS_MAX_INC

LIS_MAX_IF_END:
    mv s5, t0         # max = dp[i]

LIS_MAX_INC:
    addi s3, s3, 1    # i++
    j LIS_MAX_LOOP

LIS_MAX_END:
    mv a0, s5         # a0 = max

    lw ra, 0(sp)       # Restore return address
    lw s0, 4(sp)       # Restore s0
    lw s1, 8(sp)       # Restore s1
    lw s2, 12(sp)      # Restore s2
    lw s3, 16(sp)      # Restore s3
    lw s4, 20(sp)      # Restore s4
    lw s5, 24(sp)      # Restore s5
    lw s6, 28(sp)      # Restore s6
    lw s7, 32(sp)      # Restore s7
    addi sp, sp, 40  # Restore stack pointer
    ret

# 輸出 dp 陣列的函數
print_dp:
    addi sp, sp, -8  # Allocate stack space
    sw ra, 0(sp)       # Save return address
    sw s0, 4(sp)       # Save i

    li s0, 0          # i = 0
print_dp_loop:
    bge s0, a0, print_dp_end  # if i >= n, exit loop

    addi t0, s0, 0
    slli t0, t0, 2
    add t0, a1, t0
    lw a0, 0(t0)      # a0 = dp[i]

    li a7, 1          # print integer
    ecall

    la a0, newline    # load newline
    li a7, 4          # print string
    ecall

    addi s0, s0, 1    # i++
    j print_dp_loop

print_dp_end:
    lw ra, 0(sp)       # Restore return address
    lw s0, 4(sp)       # Restore i
    addi sp, sp, 8  # Restore stack pointer
    ret