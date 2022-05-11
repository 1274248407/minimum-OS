#include<stdlib.h>
#define nop() __asm__ __volatile__ ("nop    \n\t")
struct s
{
    int n;
    long d[0];
};

int m = 2;

#define pr_debug(fmt, arg...) \
        printf(fmt, ##arg)
    
unsigned  char data[1024] = 
{
    [0] = 19, 
    [10 ... 20] = 39,
};
struct file_operations 
{
    int open;
    int close;
    struct s read;
};
const int ex2_open = 2;
struct file_operations ext2_file_operations = 
{
    open:ex2_open, 
    close:ex2_open,
    .read = ex2_open,
};


#define ATTRIBUTE_NORETURN __attribute__((noreturn))
#define ATTRIBUTE_PACKED __attribute__((packed))

void Do_Exit(long error_code) ATTRIBUTE_NORETURN;

//__asm__ __volatile__("sgdt %0\n\t":"=m"(__gdt_addr)::);
typedef struct Example_Struct_Align
{
    char a;
    int b;
    long c;
} ATTRIBUTE_PACKED Example_Struct_Align;

typedef struct Example_Struct_Not_Align
{
    char a;
    int b;
    long c;
} Example_Struct_Not_Align;




//__asm__ __volatile__("mov %0, %%cr0\n\t"::"eax"(cr0));