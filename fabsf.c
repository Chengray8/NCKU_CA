#include<stdio.h>
#include<stdint.h>

static inline float fabsf(float x) {
    uint32_t i = *(uint32_t *)&x;  // Read the bits of the float into an integer
    i &= 0x7FFFFFFF;               // Clear the sign bit to get the absolute value
    x = *(float *)&i;              // Write the modified bits back into the float
    return x;
}

int main(){
    float test1 = -5.125;
    float test2 = 1024.25;
    float test3 = 0;

    printf("test1: %f" , fabsf(test1));
    printf("\ntest2: %f" , fabsf(test2));
    printf("\ntest3: %f" , fabsf(test3));

    return 0;
}