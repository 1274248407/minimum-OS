;============register initalization
    org 0x7c00

Base_Of_Stack equ 0x7c00

Base_Of_Loader equ 0x1000
Offset_Of_Loader equ 0x0
;0x1000 << 4 + 0x0 = 0x10000
RootDirSectors equ 0xe
SectorNumOfRootDirStart equ 0x13
SectorNumOfFAT1Start equ 0x1
SectorBalance equ 0x11
;bootloader sector archive 
    jmp short Label_Start
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
    mov ax, cs
    mov es, ax
    mov ds, ax
    mov ss, ax
    mov sp, Base_Of_Stack
;===========clear screen
    mov ax, 0600h
    mov cx, 0
    mov dx, 184fh
    mov bx, 0700h

    int 10h
;===============set force
    mov ax, 0200h
    mov dx, 0
    mov bx, 0
     
    int 10h
;================display on screen : Hello, world
    mov ax, 1301h
    mov cx, 13
    mov dx, 0
    push ax
    mov ax, ds
    mov es, ax
    mov bp, Start_Boot_Message
    pop ax
    mov bx, 000fh

    int 10h
;========reset floppy
    xor ax, ax
    xor dx, dx

    int 13h

;========search "LOADER BIN"
    mov word [SectorNo], SectorNumOfRootDirStart

Lable_Search_In_Root_Dir_Begin:
    cmp word [RootDirSizeForLoop], 0
    jz Label_No_LoaderBin
    dec word [RootDirSizeForLoop]

    mov ax, 0
    mov es, ax
    mov bx, 8000h
    mov ax, [SectorNo]
    mov cl, 1
    call Function_Read_One_Sector

    mov si, Loader_File_Name
    mov di, 8000h
    cld

    mov dx, 10h

Label_Search_For_LoaderBin:
    cmp dx, 0
    jz Label_Goto_Next_Sector_In_Root_Dir
    dec dx
    mov cx, 11

Label_Cmp_FileName:
    cmp cx, 0
    jz Label_FileName_Found
    dec cx

    lodsb 
    cmp al, byte [es:di]
    jz Label_Go_On
    jmp Label_Different

Label_Go_On:
    inc di
    jmp Label_Cmp_FileName

Label_Different:
    and di, 0ffe0h
    add di, 20h
    mov si, Loader_File_Name
    jmp  Label_Search_For_LoaderBin

Label_No_LoaderBin:
    mov ax, 1301h
    mov bx, 008ch
    mov dx, 0100h
    mov cx, 22
    push ax
    mov ax, ds
    mov es, ax
    pop ax
    mov bp, No_Loader_Message

    int 10h
    
    jmp $
Label_Goto_Next_Sector_In_Root_Dir:
    add word [SectorNo], 1
    jmp Lable_Search_In_Root_Dir_Begin
;===========Found 'loader.bin' in root directory struct
Label_FileName_Found:
    mov ax, RootDirSectors
    and di, 0ffe0h
    add di, 01ah

    mov cx, word [es:bx]
    push cx
    add cx, ax
    add cx, SectorBalance

    mov ax, Base_Of_Loader
    mov es, ax
    mov bx, Offset_Of_Loader

    mov ax, cx

Label_Go_On_Loading_File:
    push ax
    push bx
    mov ah, 0eh
    mov al, '.'
    mov bl, 0fh
    int 10h
    pop bx
    pop ax

    mov cl, 1
    call Function_Read_One_Sector
    pop ax
    call Function_Get_FAT_Entry
    
    cmp ax, 0fffh
    jz Label_File_Loaded
    mov dx, RootDirSectors
    add ax, dx
    add bx, [BPB_SecPerTrk]
    jmp Label_Go_On_Loading_File

Label_File_Loaded:
    jmp Base_Of_Loader:OffsetOfLoader
;==============function read one sector from floppy
Function_Read_One_Sector:
    push bp
    mov bp, sp
    sub esp, 2
    mov byte [bp - 2], cl

    push bx
    mov bl, [BPB_SecPerTrk]
    div bl
    inc ah

    mov cl, ah
    mov dh, al
    shr al, 1
    mov ch ,al
    mov dh, 1
    mov dl, [BS_DrvNum]

    pop bx

Label_Go_On_Reading:
    mov ah, 2
    mov byte al, [bp - 2]
    int 13h
    jc Label_Go_On_Reading

    add esp, 2
    pop bp
    ret

;======= Get FAT Entry
Function_Get_FAT_Entry:
    push es
    push bx
    
    push ax
    mov ax, 0
    mov es, ax
    pop ax

    mov byte [Odd], 0
;step 1
    mov bx, 3
    mul bx
    mov bx, 2
    div bx

    cmp dx, 0
    jz Label_Even
    mov byte [Odd], 1
Label_Even:
    mov dx, 0
    mov bx, [BPB_BytesPerSec]
    div bx
;step 2
    push dx

    mov bx, 8000h
    add ax, SectorNumOfFAT1Start
    mov cl, 2

    call Function_Read_One_Sector

    pop dx
;step 3
    add bx, dx

    mov ax, [es:bx]

    cmp byte [Odd], 1
    jnz Label_Even_2
    shr ax, 4
Label_Even_2:
    and ax, 0fffh
;step 4
    pop bx
    pop es
    ret
;=======temp available
SectorNo dw 0
RootDirSizeForLoop dw RootDirSectors
Odd db 0
;============display messages
Start_Boot_Message: db "Hello, world!"
Loader_File_Name db "LOADER BIN", 0
No_Loader_Message db "ERROR: No LOADER Found"
;========= fill zero until whole sector
times 510 - ($ - $$) db 0
    dw 0xaa55
