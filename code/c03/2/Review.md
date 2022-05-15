## FAT_Table value
ff0 = 1111 1111 0000 = FAT12


RootDirSectors = (BPB_RootEntCnt * 32 + BPB_BytesPerSec - 1) / BPB_Bytespersec 

SectorNumOfRootDirStart = BPB_RsvdSecCnt + BPB_FATSz16 * BPB_NumFATs

SectorBalance = SectorNumOfRootDirStart - 2

------------------
## Function_ReadOneSector 
### input arguments:
+ ax = LBA(logical Block Address) number of sector
+ cl = sector amount of read
+ es:bx = start address of purpose buffer

### registers argument in the interrupt server program : **INT 13h AH=02** 

+ al = sector amount of read (al = cl *in the Func_ReadOneSector*)

+ ch = trank number (trank >> 1)

+ cl = sector number (reminder on **LBA number of sector / sector per trank**)
+ dh = number of head (quotient of **LBA number of sector / sector per trank**)
+ dl = number of driver (trans from **BS_DrvNum**)

### step by step
1. Storeage *bp* and *cl*
2. Calculate **LBA number of sector / sector per trank**
3. Solve cl, dh, ch argument
4. Trans register argument(ah and al) and call the **INT 13h** in the **Carry Flag** = 0
5. Restore condition before calling(esp and bp)


+ storeage *bp* and *cl*
```asm
    push	bp
	mov	bp,	sp
	sub	esp,	2
	mov	byte	[bp - 2],	cl
```
stack:  *start* 

                2[  ] 
                1[  ]
                0[? ] <-----sp

```asm
    push bp
```
stack :        
                
                2[  ] 
                1[bp] <-----sp
                0[? ] 

```asm
    mov bp, sp
```
stack :         

                2[  ] 
                1[bp] <-----sp == bp
                0[? ] 
```asm
    sub esp, 2
```
stack :        

                2[  ] 
                1[bp] <-----bp
                0[? ] <-----esp == bp - 2
```asm
    mov byte [bp - 2],  cl
```
stack :         

                2[  ] 
                1[bp] <-----bp
                0[cl] <-----esp
----------
+ calculate **LBA number of sector / sector per trank**
```asmmeable
	push	bx
	mov	bl,	[BPB_SecPerTrk]; 18
	div	bl
	inc	ah
```
 **LBA number of sector / sector per trank** 
 = ax / bl 
 
  ah = reminder = start sector number = cl
 
  al = quotient = trank number = ch << 1

 + Solve cl, dh, ch argument

```asm
    mov cl, ah
    mov dh, al
    shr al, 1
    mov ch ,al
    mov dh, 1
    mov dl, [BS_DrvNum]

    pop bx
```
cl = ah = start sector numebr

ch = al >> 1 

dh = 1

dl = BS_DrvNum

+ Trans register argument(ah and al) and call the **INT 13h** in the **Carry Flag** = 0
```asm
    Label_Go_On_Reading:
        mov ah, 2
        mov byte al, [bp - 2]
        int 13h
        jc Label_Go_On_Reading
```
al = cl = sector amount of read

+ 5. Restore condition before calling(esp and bp)
```asm
    add esp, 2
    pop bp
    ret    
```
stack :         

                2[  ] 
                1[bp] <-----bp
                0[cl] <-----esp

## Search  loader.bin


