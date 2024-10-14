.data
test1:     .word  0x4BE0      # 15.75: 0100 1011 1110 0000
test2:     .word  0xc540      # -5.25: 1100 0101 0100 0000
test3:     .word  0           # 0
str1:      .string "test1: "
str2:      .string "\ntest2: "
str3:      .string "\ntest3: "
.text
main:
    # test1
    la   a0, str1             # Load the address of the str1
    li   a7, 4                # System call code for printing a string
    ecall                     # Print the string
    la   t0, test1            # Load address of test1
    lw   a0, 0(t0)            # Load the test1 into a0
    jal  ra, fp16to32         # Call fp16to32

    # test2
    la   a0, str2             # Load the address of the str2
    li   a7, 4                # System call code for printing a string
    ecall                     # Print the string
    la   t0, test2            # Load address of test2
    lw   a0, 0(t0)            # Load the test2 into a0
    jal  ra, fp16to32         # Call fp16to32
    
    # test3
    la   a0, str3             # Load the address of the str3
    li   a7, 4                # System call code for printing a string
    ecall                     # Print the string
    la   t0, test3            # Load address of test3
    lw   a0, 0(t0)            # Load the test3 into a0
    jal  ra, fp16to32         # Call fp16to32

    # Exit
    li   a0, 0                # Exit code 0
    li   a7, 93               # Syscall for exit
    ecall                     # Make the syscall

fp16to32:
    beqz a0, return0          # if a0 == 0, jump.
    sw   ra, -4(sp)            # a0 is unuseful after `slli t0, t1, 16`
                              # Thus, I didn't store to stack.
    slli t0, a0, 16           # w = (uint32_t) h << 16;
                              # t0: w
    li   s0, 0x80000000       # sign = w & UINT32_C(0x80000000);
    and  s1, t0, s0           # s1: sign

    li   t1, 0x7FFFFFFF       # nonsign = w & UINT32_C(0x7FFFFFFF);
    and  a0, t0, t1           # a0: nonsign
    addi t4, a0, 0            # t4: nonsign
    jal  ra, my_clz           # execute my_clz
    li   t2, 5
    addi t0, a0, 0            # renorm_shift = my_clz(nonsign);
                              # t0: renorm_shift
    blt  t0, t2, ZERO         # renorm_shift = renorm_shift > 5? renorm_shift - 5 : 0;
    addi t0, t0, -5           # t0: renorm_shift
continue:
    li   t3, 0x04000000       # inf_nan_mask = ((int32_t)(nonsign + 0x04000000) >> 8) &
    li   t2, 0x7F800000       #  INT32_C(0x7F800000);
    add  t1, t4, t3
    srli t1, t1,  8
    and  t1, t1, t2           # t1: inf_nan_mask

    sll  t4, t4, t0
    srli t4, t4,  3           # (nonsign << renorm_shift >> 3)
    addi t0, t0, 0b110010000  # Original: (0x70 - renorm_shift) << 23)
    xori t0, t0, 0b111111111  # First, calculate renorm_shift - 0x70, then take the two's complement.
    addi t0, t0,  1           # 2'complement of 0x70 is 110010000 in 9 bit.
    slli t0, t0, 23
    add  t0, t0, t4           # add: Both of above
    or   t0, t0, t1           # | inf_nan_mask
    or   a0, t0, s1
    li   a7, 2
    ecall
    lw   ra, -4(sp)           # load return address
    jr   x1

ZERO:
    li   t0, 0                # t0: renorm_shift = 0;
    j    continue

my_clz:
    mv   t0, a0
    srli t1, t0, 1            # x |= (x >> 1);
    or   t0, t0, t1
    srli t1, t0, 2            # x |= (x >> 2);
    or   t0, t0, t1
    srli t1, t0, 4            # x |= (x >> 4);
    or   t0, t0, t1
    srli t1, t0, 8            # x |= (x >> 8);
    or   t0, t0, t1
    srli t1, t0, 16           # x |= (x >> 16);
    or   t0, t0, t1

    li   t2, 0x55555555       
    srli t1, t0, 1            # x -= ((x >> 1) & 0x55555555);
    li   t3, 0xFFFFFFFF       
    and  t1, t1, t2           # t2: 0x55555555
    addi t0, t0, 1            # t0+xor(t1)+1 -> I calculate t0+1 first.
    xor  t1, t1, t3           # negative t1, 2' complement.(xor 0xFFFFFFFF)
    add  t0, t0, t1
    
    li   t3, 0x33333333
    srli t1, t0, 2            # x = ((x >> 2) & 0x33333333) + (x & 0x33333333);
    and  t2, t0, t3           # t3: 0x33333333
    and  t1, t1, t3
    add  t0, t1, t2

    li   t3, 0x0F0F0F0F
    srli t1, t0, 4            # x = ((x >> 4) + x) & 0x0f0f0f0f;
    add  t0, t1, t0
    and  t0, t0, t3           # t3: 0x0F0F0F0F

    srli t1, t0, 8            # x += (x >> 8);
    add  t0, t0, t1
    srli t1, t0, 16           # x += (x >> 16);
    add  t0, t0, t1

    andi t0, t0, 0x7F         #  return (32 - (x & 0x7f));
    xori t0, t0, 0x1F         
    addi a0, t0, 1
    jr   x1

return0:
    li   a7, 2
    ecall
    jr   x1
