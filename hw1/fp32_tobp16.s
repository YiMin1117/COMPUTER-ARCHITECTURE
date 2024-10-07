    .data
    .align 4                # 確保數據對齊
float_input:    .word 0x3f800000   # 輸入 float32 位模式 (例如 1.0f = 0x3f800000)
result:         .word 0            # 用於存儲 bfloat16 結果

    .text
    .globl main
main:
    # 加載 float32 輸入數據
    la      t0, float_input       # 加載 float_input 的地址到 t0
    lw      a0, 0(t0)            # 將 float_input 數據載入 a0

    # 調用 fp32_to_bf16 函數
    jal     fp32_to_bf16          # 跳轉到 fp32_to_bf16 函數並返回

    # 顯示結果
    la      t1, result            # 加載 result 的地址到 t1
    lw      t2, 0(t1)             # 將結果加載到 t2

    # 在模擬器中可以觀察 t2 寄存器的值作為結果

    # 結束程序
    jal     exit                  # 跳轉到 exit 函數

# fp32_to_bf16 函數
fp32_to_bf16:
    # 假設參數 float s 進入 a0 寄存器中

    # Step 1: 將 float32 轉換為 32-bit 無符號整數
    add     t0, a0, zero     # t0 = a0 (將 float32 的位模式複製到 t0)

    # Step 2: 檢查是否是 NaN
    li      t1, 0x7fffffff   # 加載 0x7fffffff 到 t1
    and     t2, t0, t1       # t2 = t0 & 0x7fffffff （取出符號位以外的部分）
    li      t1, 0x7f800000   # 加載 0x7f800000 到 t1 (IEEE 754 中 NaN 的最大值)
    blt     t2, t1, not_nan  # 如果 t2 小於 0x7f800000，則不是 NaN

# 是 NaN
    li      t1, 0x40         # 設置 64 作為 NaN 記號
    srli    t2, t0, 16       # 將 t0 右移 16 位，保留高位作為 bfloat16
    or      t2, t2, t1       # 強制設置為 quiet NaN
    jal     ra, ret          # 返回

not_nan:
    # Step 3: 進行四捨五入
    srli    t1, t0, 16       # 取出高 16 位
    lui     t3, 0x1          # 加載高 16 位的立即數到 t3（0x00010000）
    and     t3, t0, t3       # 取出第16位，用於進位判斷
    li      t4, 0x7fff       # 加載 0x7fff 到 t4
    add     t3, t3, t4       # t3 = (0x7fff + 第16位)
    add     t2, t0, t3       # t2 = t0 + (0x7fff + 第16位)
    srli    t2, t2, 16       # t2 右移 16 位，保留高 16 位作為 bfloat16

    # Step 4: 將結果存入寄存器，再寫回內存
    la      t3, result       # 加載 result 的地址到 t3
    sw      t2, 0(t3)        # 將結果寫回到內存中的 result 變量

ret:
    # 返回到調用者
    jr      ra

# 結束程序
exit:
    li      a7, 10           # ECALL 編號 10 = 程序結束
    ecall
