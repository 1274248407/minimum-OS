;/***************************************************
;		版权声明
;
;	本操作系统名为：MINE
;	该操作系统未经授权不得以盈利或非盈利为目的进行开发，
;	只允许个人学习以及公开交流使用
;
;	代码最终所有权及解释权归田宇所有；
;
;	本模块作者：	田宇
;	EMail:		345538255@qq.com
;
;
;***************************************************/

	org	0x7c00	

BaseOfStack	equ	0x7c00

BaseOfLoader	equ	0x1000
OffsetOfLoader	equ	0x00
;RootDirSectors = (BPB_RootEntCnt * 32 + BPB_BytesPerSec - 1) / 
;BPB_BytesPerSec = (224 * 32 +  
RootDirSectors	equ	14
SectorNumOfRootDirStart	equ	19
SectorNumOfFAT1Start	equ	1
SectorBalance	equ	17	

	jmp	short Label_Start
	nop
	BS_OEMName	db	'MINEboot'
	BPB_BytesPerSec	dw	512
	BPB_SecPerClus	db	1
	BPB_RsvdSecCnt	dw	1
	BPB_NumFATs	db	2
	BPB_RootEntCnt	dw	224
	BPB_TotSec16	dw	2880
	BPB_Media	db	0xf0
	BPB_FATSz16	dw	9
	BPB_SecPerTrk	dw	18
	BPB_NumHeads	dw	2
	BPB_HiddSec	dd	0
	BPB_TotSec32	dd	0
	BS_DrvNum	db	0
	BS_Reserved1	db	0
	BS_BootSig	db	0x29
	BS_VolID	dd	0
	BS_VolLab	db	'boot loader'
	BS_FileSysType	db	'FAT12   '

Label_Start:

	mov	ax,	cs
	mov	ds,	ax
	mov	es,	ax
	mov	ss,	ax
	mov	sp,	BaseOfStack

;=======	clear screen

	mov	ax,	0600h
	mov	bx,	0700h
	mov	cx,	0
	mov	dx,	0184fh
	int	10h

;=======	set focus

	mov	ax,	0200h
	mov	bx,	0000h
	mov	dx,	0000h
	int	10h

;=======	display on screen : Start Booting......

	mov	ax,	1301h
	mov	bx,	000fh
	mov	dx,	0000h
	mov	cx,	10
	push	ax
	mov	ax,	ds
	mov	es,	ax
	pop	ax
	mov	bp,	StartBootMessage
	int	10h

;=======	reset floppy

	xor	ah,	ah
	xor	dl,	dl
	int	13h

;=======	search loader.bin
	mov	word	[SectorNo],	SectorNumOfRootDirStart
;SectorNo dw 0 ; SectorNumOfRootDirStart = 0x13
;sectorNo = 0x13
Lable_Search_In_Root_Dir_Begin:
	;RootDirSizeForLoop dw RootDirSectors = 0xe
	cmp	word	[RootDirSizeForLoop],	0; ZF == 1
	jz	Label_No_LoaderBin; RootDirSizeForLoop != 0
	dec	word	[RootDirSizeForLoop]
	; RootDirSectors - 1 = 0xd
	mov	ax,	00h
	mov	es,	ax
	mov	bx,	8000h
	mov	ax,	[SectorNo];0x13
	mov	cl,	1;amount of read
;input argument ax = 0x13, cl = 1, es:bx = 0:8000h
	call	Func_ReadOneSector
	;read disk sectors into memory (es:bx == 0:8000h) 
	mov	si,	LoaderFileName;"LOADER BIN", 0
	mov	di,	8000h
	cld; lower memory address to high memory address
	mov	dx,	10h
	;BPB_BytesPerSec / 32(bytes per sector) = 512 / 32 = 16 = 0x10
	;bytes all of sectors / bytes per sector = sector amount
	;0x10 = directory amount
Label_Search_For_LoaderBin:

	cmp	dx,	0;ZF == 1
	jz	Label_Goto_Next_Sector_In_Root_Dir 
	;dx != 0
	dec	dx
	mov	cx,	11;contain the lastest '0'

Label_Cmp_FileName:

	cmp	cx,	0
	jz	Label_FileName_Found
	dec	cx
	lodsb; Used to store the string byte into AL
	cmp	al,	byte	[es:di];0:8000h
	jz	Label_Go_On
	jmp	Label_Different

Label_Go_On:
	
	inc	di
	jmp	Label_Cmp_FileName

Label_Different:

	and	di,	0ffe0h;1111 1111 1110 0000
	add	di,	20h;dec == 32 == bytes per sector
	mov	si,	LoaderFileName
	jmp	Label_Search_For_LoaderBin

Label_Goto_Next_Sector_In_Root_Dir:
	
	add	word	[SectorNo],	1
	;[SectorNo] = SectorNumOfRootDirStart
	jmp	Lable_Search_In_Root_Dir_Begin
	
;=======	display on screen : ERROR:No LOADER Found

Label_No_LoaderBin:

	mov	ax,	1301h; function
	mov	bx,	008ch;color attribute
	mov	dx,	0100h
	mov	cx,	21
	push	ax
	mov	ax,	ds
	mov	es,	ax
	pop	ax
	mov	bp,	NoLoaderMessage
	int	10h
	jmp	$

;=======	found loader.bin name in root director struct

Label_FileName_Found:

	mov	ax,	RootDirSectors;0xe
	and	di,	0ffe0h;1111 1111 1110 0000
;"and 0ffre0h" for the 01ah + 8000h(0001 1010) last 5 digit  
	add	di,	01ah;DIR_FstClus; 8000h + 01ah = 801ah = 1000 0000 0001 1010
;1. Obtain the DIR_FstClus from 01ah(offset address)
	mov	cx,	word [es:di];0:801ah; CX = base address of 'loader.bin'
; Obtain number of first cluster ; use 'word' is that DIR_FstClus length = 2 
; bytes
	push cx
	add	cx,	ax
	add	cx,	SectorBalance;17
	mov	ax,	BaseOfLoader;1000h
	mov	es,	ax
	mov	bx,	OffsetOfLoader;0
;1. Configure ES:BX of the start address with "loader.bin"
;ES:BX = 1000:0h
	mov	ax,	cx
;1. calculate the sector number = 
;RootDirSectors(0xe) + 8000~8200h + 01ah + SectorBalance(0x11)
Label_Go_On_Loading_File:
	push	ax
	push	bx
	mov	ah,	0eh
	mov	al,	'.'
	mov	bl,	0fh
	int	10h
;2. Printing '.'
	pop	bx
	pop	ax

	mov	cl,	1;sector amount of read
	call	Func_ReadOneSector
;input argument:
; AX = LBA(logical Block Address) number of sector = 
; RootDirSectors(0xe) + 8000~8200h + 01ah + SectorBalance(0x11)
; CL = sector amount of read = 1
; ES:BX = start address of purpose buffer; 1000:0
	pop	ax; ax = mov cx, word [es:bx] 
	call	Func_GetFATEntry
; input arguments: ax = FAT table number 
	cmp	ax,	0fffh;1111 1111 1111; FAT table of one 
	jz	Label_File_Loaded; load completed
	push	ax
	mov	dx,	RootDirSectors;0xe
	add	ax,	dx;
	add	ax,	SectorBalance;0x11
	add	bx,	[BPB_BytesPerSec] ;512
	jmp	Label_Go_On_Loading_File;
; 3. 
Label_File_Loaded:
	
	jmp	$
;infinity loop
;=======	read one sector from floppy
;ax = LBA(logical Block Address) number of sector
;cl = sector amount of read
;es:bx = start address of purpose buffer
Func_ReadOneSector:
	
	push	bp
	mov	bp,	sp
	sub	esp,	2
	mov	byte	[bp - 2],	cl
	;store bp and cl
	push	bx
	mov	bl,	[BPB_SecPerTrk];bl = 18 intermedia
	div	bl;LBA number of sector / sector per trank
	inc	ah;reminder + 1. consult = ah

	mov	cl,	ah
	mov	dh,	al;dh
	shr	al,	1;signed number
	mov	ch,	al;ch = al >> 1
	and	dh,	1;dh = 1

	pop	bx
	mov	dl,	[BS_DrvNum];

Label_Go_On_Reading:
	mov	ah,	2;functional number
	mov	al,	byte	[bp - 2];al = cl 'sector amount of read'
	int	13h
	jc	Label_Go_On_Reading
	add	esp,	2
	pop	bp
	ret

;=======	get FAT Entry
;;input argument ah = FAT table number
Func_GetFATEntry:

	push	es
	push	bx

	push	ax
	mov	ax,	00
	mov	es,	ax
	pop	ax

	mov	byte	[Odd],	0
	mov	bx,	3
	mul	bx
	mov	bx,	2
	div	bx
;ah * 3 / 2 = ah * 1.5byte; 1.5byte = 00 0000
	cmp	dx,	0;reminder
	jz	Label_Even;even = 0; odd = 1 
	mov	byte	[Odd],	1
	;odd number = 1; even number = 2
Label_Even:

	xor	dx,	dx;dx = 0
	mov	bx,	[BPB_BytesPerSec];512
	div	bx; / 512
	push	dx
	;reminder = offset of FAT table in sector 
	mov	bx,	8000h
	add	ax,	SectorNumOfFAT1Start; + 1; 
	;ax = offset of setcor number
	mov	cl,	2
	;read two data of sector as consecutive 
	call	Func_ReadOneSector
	;ax, cl, es:bx
	pop	dx
	add	bx,	dx
	;8000h + offset of FAT table in sector
	mov	ax,	[es:bx]
	cmp	byte	[Odd],	1
	jnz	Label_Even_2;== even number
	shr	ax,	4;only odd number

Label_Even_2:
	and	ax,	0fffh;1111 1111 1111
	pop	bx
	pop	es
	ret

;=======	tmp variable

RootDirSizeForLoop	dw	RootDirSectors
SectorNo		dw	0
Odd			db	0

;=======	display messages

StartBootMessage:	db	"Start Boot"
NoLoaderMessage:	db	"ERROR:No LOADER Found"
LoaderFileName:		db	"LOADER  BIN",0

;=======	fill zero until whole sector

	times	510 - ($ - $$)	db	0
	dw	0xaa55

