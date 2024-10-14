#include <stdio.h>
#include <stdint.h>

int16_t my_clz(uint32_t x){
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
static inline uint32_t fp16_to_fp32(uint16_t h) {
    if(h==0)return 0;
    const uint32_t w = (uint32_t) h << 16;
    
    const uint32_t sign = w & UINT32_C(0x80000000);
    
    const uint32_t nonsign = w & UINT32_C(0x7FFFFFFF);
    
    uint32_t renorm_shift = my_clz(nonsign);

    renorm_shift = renorm_shift > 5 ? renorm_shift - 5 : 0;

    const int32_t inf_nan_mask = ((int32_t)(nonsign + 0x04000000) >> 8) &
                                 INT32_C(0x7F800000);
    
//remove const int32_t zero_mask = (int32_t)(nonsign - 1) >> 31;
    
    return sign | ((((nonsign << renorm_shift >> 3) +
            ((0x70 - renorm_shift) << 23)) | inf_nan_mask));
}

int main(){
    int  test1 = 0x4BE0;//15.75: 0100 1011 1110 0000
    int  test2 = 0xC540;//-5.25: 1100 0101 0100 0000
    int  test3 = 0x0;
    test1 = fp16_to_fp32(test1);
    float *result1 = (float*)&test1;
    test2 = fp16_to_fp32(test2);
    float *result2 = (float*)&test2;
    test3 = fp16_to_fp32(test3);
    float *result3 = (float*)&test3;
    
    printf("1: %.2f\n" , *result1);//Output: 15.75
    printf("2: %.2f\n" , *result2);//Output: -5.25
    printf("3: %.2f\n" , *result3);//Output:  0.00

    return 0;
}