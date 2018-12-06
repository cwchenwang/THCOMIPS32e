   .org 0x0
   .set noat
   .set noreorder
   .set nomacro
   .global _start

# Expected: $1: 0x1234 -> 0 -> 0x1234 -> 0x89ab
_start:
    # Inintialization preamble
    nop

    # Write-read ROM
    lui $1, 0x803f
    sw $0, 0xff($1)
    lw $0, 0xff($1)
    nop
    nop

    # Write-read RAM
    lui $1, 0x807e
    sw $0, 0xff($1)
    lw $0, 0xff($1)
    nop
    nop

    # Main part
    lui $3, 0x8030
    ori $1, $0, 0x1234  # $1 = 0x00001234
    sw  $1, 0x0($3)     # [0x80300000] = 0x00001234

    ori $2, $0, 0x1234  # $2 = 0x00001234
    ori $1, $0, 0x0     # $1 = 0x0
    lw  $1, 0x0($3)     # $1 = 0x00001234
    beq $1, $2, Label     
    nop

    ori $1, $0, 0x4567    
    nop

Label:
    ori $1, $0, 0x89ab    # $1 = 0x000089ab    
    nop            

_loop:
    j _loop
    nop
