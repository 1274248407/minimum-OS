# FAT_Table value
ff0 = 1111 1111 0000 = FAT12


RootDirSectors = (BPB_RootEntCnt * 32 + BPB_BytesPerSec - 1) / BPB_Bytespersec 

SectorNumOfRootDirStart = BPB_RsvdSecCnt + BPB_FATSz16 * BPB_NumFATs

SectorBalance = SectorNumOfRootDirStart - 2

------------------
## Lable_Search_In_Root_Dir_Begin:
```c
    
    for(Lable_Search_In_Root_Dir_Begin; RootDirSizeForLoop != 0; )
    {
        for (Label_Search_For_LoaderBin; )
            if (match "LOADER BIN") Label_Go_On;
            else Label_Different;

        Label_Goto_Next_Sector_In_Root_Dir;

    }


```

### purpose : search "loadber.bin" in root directory
1. store the sector number of the root directory start
2. read a data on one sector into the buffer area (root directory sectors != 0)
3. indeed the sector amount for search "LOADER BIN"
4. retrieve the directory into buffer area for search "LOADER BIN". 
-----
1. store the sector number of the root directory start
```
	mov	word	[SectorNo],	SectorNumOfRootDirStart
```
------
2. read a data on one sector into the buffer area (root directory sectors != 0)
```
Lable_Search_In_Root_Dir_Begin:
	cmp	word	[RootDirSizeForLoop],	0
	jz	Label_No_LoaderBin
	dec	word	[RootDirSizeForLoop]

	mov	ax,	00h
	mov	es,	ax
	mov	bx,	8000h
	mov	ax,	[SectorNo]
	mov	cl,	1
	call	Func_ReadOneSector
	mov	si,	LoaderFileName
	mov	di,	8000h
	cld
```
```
	cmp	word	[RootDirSizeForLoop],	0
	jz	Label_No_LoaderBin
```
+ ZF (Zero flag) == 1 
  + cmp a, b
  + a != b
+ ZF (Zero flag) == 0
  + cmp a, b
  + a == b
```
	mov	ax,	00h
	mov	es,	ax
	mov	bx,	8000h
	mov	ax,	[SectorNo]
	mov	cl,	1
	call	Func_ReadOneSector
	mov	si,	LoaderFileName
	mov	di,	8000h
	cld
```
input argument:
+ ax = LBA(logical Block Address) number of sector
+ cl = sector amount of read
+ es:bx = start address of purpose buff
---------
3. indeed the sector amount for search "LOADER BIN"
```
    mov	dx,	10h
```
BPB_BytesPerSec / 32(bytes per sector) = 512 / 32 = 16 = 0x10

all of sectors / bytes per sector = sector amount

0x10 = directory amount

---------
4. retrieve the directory into buffer area for search "LOADER BIN". 
```
Label_Search_For_LoaderBin:
	cmp	dx,	0
	jz	Label_Goto_Next_Sector_In_Root_Dir
	dec	dx
	mov	cx,	11

Label_Cmp_FileName:

	cmp	cx,	0
	jz	Label_FileName_Found
	dec	cx
	lodsb
	cmp	al,	byte	[es:di];0:8000h
	jz	Label_Go_On
	jmp	Label_Different

Label_Go_On:
	
	inc	di
	jmp	Label_Cmp_FileName

Label_Different:

	and	di,	0ffe0h
	add	di,	20h
	mov	si,	LoaderFileName
	jmp	Label_Search_For_LoaderBin

```
* Label_Go_On:(+ 1)

    8001h = 1000 0000 0000 000**1** 

    8011h = 1000 0000 000**1** 000**1**

* Label_Different:(+ 20h)

    8000h = 1000 0000 000**0** 0000
    
    8020h = 1000 0000 001**0** 0000

    8040h = 1000 0000 010**0** 0000

    8060h = 1000 0000 011**0** 0000

    8080h = 1000 0000 100**0** 0000

    8100h = 1000 0001 000**0** 0000

    8120h = 1000 0001 001**0** 0000

    8140h = 1000 0001 010**0** 0000

    8160h = 1000 0001 011**0** 0000

    8180h = 1000 0001 100**0** 0000

    81a0h = 1000 0001 101**0** 0000

    81c0h = 1000 0001 110**0** 0000

    81e0h = 1000 0001 111**0** 0000

    until to 

    8200(8000h + 10h[dx] * 20h[bytes per sector]) = 
    
    1000 00100 000**0** 0000

### sample:
8000h ~ 8020h: founded "LABCD BIN"
'L' match, "inc di" = 8001h

#### 8001h 

'A' unmatch 

+ 8001h 'and' ffe0h
``` 
    8001h = 1000 0000 0000 0001 
    ffe0h = 1111 1111 1110 0000
    = 8000h 
```
+ 8000h + 20h = 8020h, continue search
------------------------
## Label_No_LoaderBin:
1. preparing ax, bx, cx, dx, es:bp
2. calling INT 10h
3. loop
+ INT 10h / AH = 13h - write string.

input:

AL = write mode:
* bit 1: string contains attributes.

BH = page number.

BL = attribute if string contains only characters (bit 1 of AL is zero).

CX = number of characters in string (attributes are not counted).

DL,DH = column, row at which to start writing.

ES:BP points to string to be printed.

1. preparing ax, bx, cx, dx, es:bp
```
	mov	ax,	1301h
	mov	bx,	008ch
	mov	dx,	0100h
	mov	cx,	21
	push	ax
	mov	ax,	ds
	mov	es,	ax
	pop	ax
	mov	bp,	NoLoaderMessage
```
2. calling INT 10h
```
    int 10h
```
3. loop
```
    jmp $
```
machine code:  E9 FD FF
+ fffd = -3
+ e9 = jmp funtion
  
```
0x0 0x1  0x2  0x3   
[?] [E9] [FD] [FF] 
                ^
                |
    reading jump as current address -3
    jump to ?(0x2 - 3 = 0x0) 

    second data = 0xE9
```
---------
## Label_FileName_Found:
1. obtain the DIR_FstClus data from the offset address and calculation of corresponding sector number and configure the ES:BX of the start address with "loader.bin"
    + preserve the offset address(DI = 8000h) last 5 digit 
        ```
        and di, 0ffe0h
        ```
        0ffe0h = 1111 1111 1110 0000
    + obtain base address of 'loader.bin' and calculate the corresponding sector number. Store the calculate result to CX
        ```
        mov	cx,	word	[es:di]

        push cx
	    add	cx,	ax
	    add	cx,	SectorBalance
        ```
        use the 'word to transform ES:DI to cx since DIR_FstClus length is 2 bytes

        sector number = RootDirSectors(0xe) + 8000~8200h + 01ah + SectorBalance(0x11)
    + configure the loader address with the base address and offset address
       	```
        mov	ax,	BaseOfLoader;1000h
	    mov	es,	ax
	    mov	bx,	OffsetOfLoader
        ``` 
    + trans result to AX
### Label_Go_On_Loading_File:
2. use INT 10h AH=0eh interactive with display **'.'** (white)
3. ever reading the data of sector with calling Func_GetFATEntry to require second FAT table and loop with Label_Go_On_Loading_File until the Sector number(AX) is 0fffh so that jump to Label_File_Loaded
    + indeed sector amount of read and calling Func_ReadOneSector and Func_GetFATEntry
        ```
        mov	cl,	1
	    call Func_ReadOneSector
        pop	ax
	    call Func_GetFATEntry
    	```
        pop ax
        
        ax = mov cx, word [es:bx] 
    + if (ax == 0fffh) goto Label_File_Loaded
    + else
    + prepare ax += RootDirSectors + SectorBalance and bx += BPB_bytesPerSec
    + jump to Label_Go_On_Loading_File
### Label_File_Loaded:
    infinity loop
## Func_GetFATEntry (Get next FAT Table)
### input arguments: ax = FAT table number
1. store FAT table number(ax) and set odd/even available is zero
   
   + push ax, es:bx
   + set es = 0
   + set [odd] available = 0
 
2. FAT table number * 1.5 for judge with odd/even and the (result / bytes per sector), quotient is offset sector number and the reminder is offset position of sector(similar as CS:IP)
   
   + ax * 3 / 2
   + comparare reminder(dx) is zero. set [odd] available is 1 if the reminder(dx) != 0
   + set dx = 0. divide BPB_BytesPerSec
3. calling FUN_ReadOneSector for read two data of sector consecutive

    + store dx
    + set ax start from SectorNumOfFAT1Start and set cl is 2 and set es:bx
    + calling FUN_ReadOneSector
4. deal with odd/even malposition problem

    + set address(add offset position)
    + read to ax from es:bx
    + *if* ([Odd] == 1) [odd] >> 4 (use ax separated in FUN_ReadOneSector)
    + *else* ax & 0x0fffh(1111 1111 1111) {flag of load completed on Lable_FileName_Found}


   












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
                1[bp] <-----bp == sp
                0[? ] <-----esp == bp - 2
```asm
    mov byte [bp - 2],  cl
```
stack :         

                2[  ] 
                1[bp] <-----bp == sp
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




