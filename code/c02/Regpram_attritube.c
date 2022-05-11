int q = 0x5a;
int t1 = 1; 
int t2 = 2; 
int t3 = 3; 
int t4 = 4;

#define REGPARM_3 __attribute__((regparm(3)))
#define REGPARM_0 __attribute__((regparm(0)))

void REGPARM_3 p1(int a)
{
    q = a + 1;
}

void REGPARM_0 p2(int a, int b, int c, int d)
{
    q = a + b + c + d + 1;
}

int main(void)
{
    p1(t1);
    p2(t1, t2, t3, t4);
    return 0;
}   
