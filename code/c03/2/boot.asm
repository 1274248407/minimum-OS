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

    jmp $

;==============function read one sector from floppy
Functiion_Read_One_Sector:
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

Start_Boot_Message: db "Hello, world!"
;========= fill zero until whole sector
times 510 - ($ - $$) db 0
    dw 0xaa55
