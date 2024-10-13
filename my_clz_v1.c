#include <stdio.h>
#include <stdint.h>

static inline int my_clz(uint32_t x){
    if(x==0){
        printf("Undefined");
        return -1;
    }
    int count = 0;
    for (int i = 31; i >= 0; --i) {
        if (x & (1U << i))
            break;
        count++;
    }
    return count;
}

int main(){
    int test1 = 16;
    int test2 = 33;
    int test3 = 0;
    int result=0;

    printf("test1: ");
    result = my_clz(test1);
    if(result>0)printf("%d" , result);

    printf("\ntest2: ");
    result = my_clz(test2);
    if(result>0)printf("%d" , result);

    printf("\ntest3: ");
    result = my_clz(test3);
    if(result>0)printf("%d\n" , result);

    return 0;
}