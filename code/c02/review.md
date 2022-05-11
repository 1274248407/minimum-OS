# 2.3.2 
----
## 7 27
packed attribute: align optimize
```c
    __attribute__((packed))
```
```c
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
```


```assembly
0000000000001143 <p2>:
    1143:       f3 0f 1e fa             endbr64
    1147:       55                      push   %rbp
    114b:       89 7d fc                mov    %edi,-0x4(%rbp)     
    114e:       89 75 f8                mov    %esi,-0x8(%rbp)     
    1151:       89 55 f4                mov    %edx,-0xc(%rbp)     
    1154:       89 4d f0                mov    %ecx,-0x10(%rbp)    
    1157:       8b 55 fc                mov    -0x4(%rbp),%edx     
    115a:       8b 45 f8                mov    -0x8(%rbp),%eax     
    115d:       01 c2                   add    %eax,%edx
    115f:       8b 45 f4                mov    -0xc(%rbp),%eax     
    1162:       01 c2                   add    %eax,%edx
    1164:       8b 45 f0                mov    -0x10(%rbp),%eax    
    1167:       01 d0                   add    %edx,%eax
    1169:       83 c0 01                add    $0x1,%eax
    116c:       89 05 9e 2e 00 00       mov    %eax,0x2e9e(%rip)   
     # 4010 <q>
    1172:       90                      nop
    1173:       5d                      pop    %rbp
    1174:       c3                      retq
                        /*explain*/

                                                int t1 = 1, int t2 = 2, int t3 = 3, int t4 = 4;
                                                p2(t1, t2, t3, t4);
                                                void REGPARM_0 p2(int a, int b, int c, int d)

    mov    %edi,-0x4(%rbp)                      int a
    mov    %esi,-0x8(%rbp)                      int b
    mov    %edx,-0xc(%rbp)                      int c
    mov    %ecx,-0x10(%rbp)                     int d

                   0x4------0x7   0x8-------0xb  0xb------0xf   0x10------0x13
    rbp register : 01 00 00 00    02 00 00 00    03 00 00 00    04 00 00 00
    save value :   edi register   esi register   edx register   ecx register
    save variables: t1 = 1(edi)    t2 = 2(esi)     t3 = 3(edx)     t4 = 4(ecx)

    'regparm' has invaild in the x64 architecture

                                            q = a + b + c + d + 1;
    
    mov    -0x4(%rbp),%edx                  edx = edi = a = t1 = 0x1;
    mov    -0x8(%rbp),%eax                  eax = esi = b = t2 = 0x2;

    add    %eax,%edx                        eax = eax + edx = a + b = t1 + t2 = 0x1 + 0x2 = 0x3;
    mov    -0xc(%rbp),%eax                  eax = edx = c = t3 = 0x3;
    add    %eax,%edx                        eax = eax + edx = (a + b) + c = (t1 + t2) + t3= (0x1 + 0x2) + 0x3 = 0x6;
    mov    -0x10(%rbp),%eax                 eax = ecx = d = t4 = 0x4;
    add    %edx,%eax                        eax = eax + edx = (a + b + c) + d = (t1 + t2 + t3) + t4 = (0x1 + 0x2 + 0x3) + 0x4 = 0x10;
    add    $0x1,%eax                        eax = 0x3 + 0x1;

int main(void)
{
    p1(t1);
    p2(t1, t2, t3, t4);
    return 0;
}   

0000000000001175 <main>:
    117d:       8b 05 91 2e 00 00       mov    0x2e91(%rip),%eax               eax = t1 = 0x1;
     # 4014 <t1>
    1183:       89 c7                   mov    %eax,%edi
    1185:       e8 9f ff ff ff          callq  1129 <p1>
    118a:       8b 0d 90 2e 00 00       mov    0x2e90(%rip),%ecx   
     # 4020 <t4>
    1190:       8b 15 86 2e 00 00       mov    0x2e86(%rip),%edx   
     # 401c <t3>
    1196:       8b 35 7c 2e 00 00       mov    0x2e7c(%rip),%esi   
     # 4018 <t2>
    119c:       8b 05 72 2e 00 00       mov    0x2e72(%rip),%eax   
     # 4014 <t1>
    11a2:       89 c7                   mov    %eax,%edi
    11a4:       e8 9a ff ff ff          callq  1143 <p2>
    11a9:       b8 00 00 00 00          mov    $0x0,%eax

    0x :           2e72---2e7b    2e7c---2e7f    2e86---2e89    2e90---2e93
    rip register : 01 00 00 00    02 00 00 00    03 00 00 00    04 00 00 00
    save value :   edi register   esi register   edx register   ecx register
    save variables: t1 = 1(edi)    t2 = 2(esi)     t3 = 3(edx)  t4 = 4(ecx)
                    (mov %eax %edi)
    'regparm
    11a9:       b8 00 00 00 00          mov    $0x0,%eax  ; return 0;


```