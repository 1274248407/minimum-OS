## boot.asm
```asm
    jmp $ (E9 FD FF)

    0xfffd = -3(dec)
        
    FF ----> E9
    
    times 510 - ($ - $$) db 0

    times = dup(0) == duplicate
    512b - 2b(0x55 and 0xaa) = 510b
    ($ - $$) program length

    dw 0xaa55
       0xaa<--------0x55

```
