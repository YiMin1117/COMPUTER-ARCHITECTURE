    .data
points1        # Test data points1
    .word 0x3f8ccccd, 0x400ccccd    # (1.1, 2.2)
    .word 0x40400000, 0x40400000    # (3.0, 3.0)
    .word 0x40b00000, 0x3f8ccccd    # (5.5, 1.1)
    .word 0x3e4ccccd, 0x3f4ccccd    # (0.2, 0.8)
    .word 0x408ccccd, 0x40666666    # (4.4, 3.3)

k1 .word 3        # k value for points1

# 預期結果
expected_result
    .word 0x3e4ccccd, 0x3f4ccccd    # (0.2, 0.8) 最近點
    .word 0x3f8ccccd, 0x400ccccd    # (1.1, 2.2)
    .word 0x40400000, 0x40400000    # (3.0, 3.0)

result .space 36  # Result buffer for K closest points (3 points max for testing)

    .text
    .globl main
main
    # 初始化
    la      a2, points1       # 加載points1的地址
    lw      a1, k1            # 加載k1的值
    li      a0, 5             # points1 有 5 個點
    la      a3, result        # 加載結果的地址

    # 調用kClosestPoints函數
    jal     ra, kClosestPoints

    # 調用內部驗證函數，檢查結果是否正確
    la      a4, expected_result   # 預期結果的地址
    jal     ra, checkResult       # 調用結果檢查函數

    # 結束程序
    li      a7, 10                # ECALL編號10表示程序結束
    ecall

# kClosestPoints 函數
kClosestPoints
    # 初始化循環計數器
    li      t0, 0             # 迭代計數器 (遍歷每個點)
loop
    # 加載每個點的x和y坐標
    lw      t1, 0(a2)         # 加載x
    lw      t2, 4(a2)         # 加載y

    # 計算距離 (略去細節，這裡只做基礎範例)
    mul     t3, t1, t1        # x^2
    mul     t4, t2, t2        # y^2
    add     t5, t3, t4        # x^2 + y^2

    # 保存計算結果到結果緩衝區
    sw      t1, 0(a3)         # 保存x
    sw      t2, 4(a3)         # 保存y

    # 更新指針和迭代器
    addi    a2, a2, 8         # 移到下一個點
    addi    a3, a3, 8         # 移到結果的下一個存儲區
    addi    t0, t0, 1         # 增加迭代計數器

    # 檢查是否處理完所有點
    blt     t0, a0, loop      # 如果還有點，繼續循環

    # 返回主程序
    jr      ra

# 檢查結果的函數，對比結果與預期值
checkResult
    li      t0, 0             # 初始化計數器
validate_loop
    lw      t1, 0(a3)         # 從結果中讀取x
    lw      t2, 4(a3)         # 從結果中讀取y
    lw      t3, 0(a4)         # 從預期結果中讀取x
    lw      t4, 4(a4)         # 從預期結果中讀取y

    # 比較x
    bne     t1, t3, validation_failed
    # 比較y
    bne     t2, t4, validation_failed

    # 如果x和y都相等，則繼續
    addi    a3, a3, 8         # 更新結果指針
    addi    a4, a4, 8         # 更新預期結果指針
    addi    t0, t0, 1         # 更新計數器
    li      t1, 3             # 預期結果有3個點
    blt     t0, t1, validate_loop  # 檢查是否檢查完所有點

    # 如果結果正確
    li      a0, 1             # 1 表示成功
    jr      ra

validation_failed
    # 結果不匹配
    li      a0, 0             # 0 表示失敗
    jr      ra
