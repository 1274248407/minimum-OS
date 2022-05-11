## FAT_Table value
ff0 = 1111 1111 0000 = FAT12


RootDirSectors = (BPB_RootEntCnt * 32 + BPB_BytesPerSec - 1) /
BPB_Bytespersec 
SectorNumOfRootDirStart = BPB_RsvdSecCnt + BPB_FATSz16 * BPB_NumFATs
SectorBalance = SectorNumOfRootDirStart - 2
------------------
## Func_ReadOneSector 
```asm
    push	bp
	mov	bp,	sp
	sub	esp,	2
	mov	byte	[bp - 2],	cl
```
start:    
    stack :     2[  ] 
                1[  ]
                0[? ] <-----sp
```asm
    push bp
```
stack :         2[  ] 
                1[bp] <-----sp
                0[? ] 

