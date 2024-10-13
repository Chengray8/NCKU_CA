.data
test1:     .word  16
test2:     .word  33
test3:     .word  0
str1:      .string "test1: "
str2:      .string "\ntest2: "
str3:      .string "\ntest3: "
str4:      .string "undefined"
.text
main:
    # test1
    la   a0, str1             # Load the address of the str1
    li   a7, 4                # System call code for printing a string
    ecall                     # Print the string
    la   t0, test1            # Load address of test1
    lw   a0, 0(t0)            # Load the test1 into a0
    jal  ra, my_clz           # Call my_clz

    # test2
    la   a0, str2             # Load the address of the str2
    li   a7, 4                # System call code for printing a string
    ecall                     # Print the string
    la   t0, test2            # Load address of test2
    lw   a0, 0(t0)            # Load the test2 into a0
    jal  ra, my_clz           # Call my_clz
    
    # test3
    la   a0, str3             # Load the address of the str3
    li   a7, 4                # System call code for printing a string
    ecall                     # Print the string
    la   t0, test3            # Load address of test3
    lw   a0, 0(t0)            # Load the test3 into a0
    jal  ra, my_clz           # Call my_clz

    # Exit
    li   a0, 0                # Exit code 0
    li   a7, 93               # Syscall for exit
    ecall                     # Make the syscall

my_clz:
    beqz a0, return0          # if a0 == 0, jump.
    li   t0, 1                # load 1 into t0
    li   t1, 31               # load 31 into t1
cal:
    sll  t2, t0, t1           # shift
    bgeu a0, t2, return       # input > t2, get numbers of shift.
    addi t1, t1, -1           # shift number - 1
    j    cal                  # loop

return:
    xori t0, t1, 0x1F         # 1' complement
    mv   a0, t0               # print value
    li   a7, 1                # Print the answer
    ecall
    jr   x1

return0:
    li   a0, -1               # return -1
    la   a0, str4             # Load the address of the str4
    li   a7, 4                # System call code for printing a string
    ecall
    jr   x1