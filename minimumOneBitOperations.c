#include <stdio.h>
#include <stdint.h>
uint16_t BinaryLen(uint32_t x)
{
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

    return (x & 0x7f);
}
int minimumOneBitOperations(int n){
    if(n == 0)return 0;
    int bits = BinaryLen(n);
    int flop = -1;
    int moves = (1<<(bits))-1;
    for(int i=bits-2 ; i>=0 ; i--){
        if(n>>i & 0b00000001){
            moves += flop * ((1<<(i + 1)) - 1);
            flop *= -1;
        }
    }
    return moves;
}
int main(){
    int test1 = 0;
    int test2 = 64;
    int test3 = 15;

    printf("test1 moves %d\n" , minimumOneBitOperations(test1));
    //output 0
    
    printf("test2 moves %d\n" , minimumOneBitOperations(test2));
    //output 127
    
    printf("test3 moves %d" , minimumOneBitOperations(test3));
    //output 10
    
    return 0;
}