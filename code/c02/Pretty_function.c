#include<stdio.h>
#include"Asm_volatile.h"
void Function_example()
{
    printf("the function name is %s\n", __FUNCTION__);
}

int main(int argc, char const *argv[])
{
    Example_Struct_Align Start_ESA;
    char *Start_ESA_Char = &Start_ESA.a;
    int *Start_ESA_Int = &Start_ESA.b;
    long *Start_ESA_Long = &Start_ESA.c;

    Example_Struct_Not_Align Start_ESNA;
    char *Start_ESNA_Char = &Start_ESNA.a;
    int *Start_ESNA_Int = &Start_ESNA.b;
    long *Start_ESNA_Long = &Start_ESNA.c;
 
    printf("ESA = %p - %p - %p, \nESNA = %p -%p - %p\t", 
            Start_ESA_Char, Start_ESA_Int, Start_ESA_Long, 
            Start_ESNA_Char, Start_ESNA_Int, Start_ESNA_Long);
    return 0;
}
