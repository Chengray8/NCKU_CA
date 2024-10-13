.data
test1:     .word  0xC0A40000  # -5.125 in IEEE 754
test2:     .word  0x44800800  # 1024.25 in IEEE 754
test3:     .word  0x00000000  # 0 in IEEE 754
str1:      .string "test1: "
str2:      .string "\ntest2: "
str3:      .string "\ntest3: "
.text
main:
    #test1
    la a0, str1               # Load the address of the str1
    li a7, 4                  # System call code for printing a string
    ecall                     # Print the string
    la   t0, test1            # Load address of test1
    lw   a0, 0(t0)            # Load the 32-bit float into a0
    jal  ra, fabsf            # Call fabsf
    li a7, 2                  # Print the answer
    ecall

    #test2
    la a0, str2               # Load the address of the str2
    li a7, 4                  # System call code for printing a string
    ecall                     # Print the string
    la   t0, test2            # Load address of test2
    lw   a0, 0(t0)            # Load the 32-bit float into a0
    jal  ra, fabsf            # Call fabsf
    li a7, 2                  # Print the answer
    ecall

    #test3
    la a0, str3               # Load the address of the str3
    li a7, 4                  # System call code for printing a string
    ecall                     # Print the string
    la   t0, test3            # Load address of test3
    lw   a0, 0(t0)            # Load the 32-bit float into a0
    jal  ra, fabsf            # Call fabsf
    li a7, 2                  # Print the answer
    ecall

    #Exit
    li   a0, 0                # Exit code 0
    li   a7, 93               # Syscall for exit
    ecall                     # Make the syscall

fabsf:
    li   t0, 0X7FFFFFFF
    and  t1, a0, t0   # Clear the sign bit
    mv   a0, t1
    jr   x1