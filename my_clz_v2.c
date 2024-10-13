#include <stdio.h>
#include <stdint.h>

int16_t my_clz(uint32_t x){
    if(x==0){
        printf("test is 0, Undefined\n");
        return -1;
    }
    x |= (x >> 1);
    x |= (x >> 2);
    x |= (x >> 4);
    x |= (x >> 8);
    x |= (x >> 16);

    x -= ((x >> 1) & 0x55555555);
    x = ((x >> 2) & 0x33333333) + (x & 0x33333333);
    x = ((x >> 4) + x) & 0x0f0f0f0f;
    x += (x >> 8);
    x += (x >> 16);

    return (32 - (x & 0x7f));
}

int main(){
    int test1 = 16;
    int test2 = 33;
    int test3 = 0;
    int result = 0;

    result = my_clz(test1);
    if(result>0)printf("test1: %d\n" , result);

    result = my_clz(test2);
    if(result>0)printf("test2: %d\n" , result);

    result = my_clz(test3);
    if(result>0)printf("test3: %d\n" , result);

    return 0;
}