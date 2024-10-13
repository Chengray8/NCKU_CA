.data
test1:     .word  16
test2:     .word  33
test3:     .word  0
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
    jal  ra, MOBO             # Call MOBO

    # test2
    la   a0, str2             # Load the address of the str2
    li   a7, 4                # System call code for printing a string
    ecall                     # Print the string
    la   t0, test2            # Load address of test2
    lw   a0, 0(t0)            # Load the test2 into a0
    jal  ra, MOBO             # Call MOBO

    # test3
    la   a0, str3             # Load the address of the str3
    li   a7, 4                # System call code for printing a string
    ecall                     # Print the string
    la   t0, test3            # Load address of test3
    lw   a0, 0(t0)            # Load the test3 into a0
    jal  ra, MOBO             # Call MOBO

    # Exit
    li   a0, 0                # Exit code 0
    li   a7, 93               # Syscall for exit
    ecall                     # Make the syscall
MOBO:
    beqz a0, return0          # if a0 == 0, jump.
    addi sp, sp, -8           # MOBO can call BinaryLen
    sw   ra, 0(sp)
    sw   a0, 4(sp)
    
    jal  ra, BinaryLen        # a0 is already set, so directly use jal.
    addi t5, a0, 0            # set return value to t5. #bits = BinaryLen(n);
    li   t4, 1
    lw   a0, 4(sp)            # Restore the original parameters.
    
    li   t1,  1               # int flop = -1;
                              # Here, I set 1 to represent a negative number.
                              # set 0 to represent a positive number.
    sll  t2, t4, t5           # int moves = (1<<(bits))-1;
    addi t2, t2, -1

    addi t3, t5, -1           # i=bits-1
    li   t5, 0xFFFFFFFF       
loop:
    addi t3, t3, -1
    bltz t3, return
    srl  t0, a0, t3           # store n >> i in t0
    andi t6, t0,  1
    beqz t6, loop
    addi t0, t3,  1           # (i + 1)
    sll  t0, t4, t0           # (1<<(i + 1))
    addi t0, t0, -1           # (1<<(i + 1)) - 1
    beqz t1, addmove          # if flop is Positive, jump addmove
    xor  t0, t0, t5           # negative number
    addi t0, t0, 1            
addmove:
    add  t2, t2, t0           # moves + flop * ((1<<(i + 1)) - 1);
    xori t1, t1,  1
    j    loop

return:
    lw   ra, 0(sp)
    addi sp, sp, 8
    addi a0, t2, 0            # return moves;
    li   a7, 1
    ecall
    jr   x1
return0:
    li   a0, 0                # input = 0, return 0
    li   a7, 1
    ecall
    jr   x1

BinaryLen:
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

    andi a0, t0, 0x7F         #　return (32 - (x & 0x7f));
    jr   x1