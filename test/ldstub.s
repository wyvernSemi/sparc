! ========================================
!  $Id: ldstub.s,v 1.1 2013/06/25 18:31:01 simon Exp $
!  $Source: /home/simon/CVS/src/cpu/sparc/test/ldstub.s,v $
! ========================================
        .file "ldstub.s"
        .section ".text"

! ----------------------------------------
#define GOOD    0x900d
#define BAD     0xbad

#define NUM1    0x032
#define NUM2    0x7654ff10
#define NUM3    0x76
#define NUM4    0xff54ff10

#define CC_MASK  0x00f00000
#define ZV_MASK1 0x00400000

        .global main
        .align 4

main:

        save    %sp, -96, %sp 

        mov     0, %g7

        sethi   %hi(NUM1), %l1
        or      %l1, %lo(NUM1), %l1
        sethi   %hi(NUM2), %l3
        or      %l3, %lo(NUM2), %l3
        sethi   %hi(.LTESTDATA), %l0
        or      %l0, %lo(.LTESTDATA), %l0

        ldstub  [%l0+2], %l2

        cmp     %l1, %l2
        bne     .LFAIL
        nop
        ld      [%l0], %l2
        cmp     %l3, %l2
        bne     .LFAIL
        nop

        sethi   %hi(NUM3), %l1
        or      %l1, %lo(NUM3), %l1
        sethi   %hi(NUM4), %l3
        or      %l3, %lo(NUM4), %l3
        mov     0, %l5

        ldstub  [%l0+%l5], %l2

        cmp     %l1, %l2
        bne     .LFAIL
        nop
        ld      [%l0], %l2
        cmp     %l3, %l2
        bne     .LFAIL
        nop

.LPASS:
        sethi   %hi(GOOD), %g7
        or      %g7, %lo(GOOD), %g7
        ba      .LFINISH
        nop

.LFAIL:
        mov     BAD, %g7
.LFINISH:
        ret
        restore 

        .type   main, #function
        .size   main, (.-main)

! ----------------------------------------
        .section ".data"
        .align  4

.LTESTDATA:
        .word 0x76543210

