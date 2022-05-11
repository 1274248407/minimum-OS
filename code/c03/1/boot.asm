;============register initalization
    org 0x7c00

Base_Of_Stack equ 0x7c00

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

Start_Boot_Message: db "Hello, world!"
;========= fill zero until whole sector
times 510 - ($ - $$) db 0
    dw 0xaa55
