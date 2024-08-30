! ========================================
!  $Id: speedo.s,v 1.1 2013/06/25 18:31:00 simon Exp $
!  $Source: /home/simon/CVS/src/cpu/sparc/test/speedo.s,v $
! ========================================
        .file "speedo.s"
        .section ".text"

! ----------------------------------------
#define GOOD    0x900d
#define BAD     0xbad

#define NUM1HI  0x00001964
#define NUM1LO  0x25080500
#define NUM2    0x00002004
#define RESULT1 0xcb07c747

#define CC_MASK  0x00f00000
#define ZV_MASK1 0x00400000

#define MOVW(_NUM, _R1) \
        sethi   %hi(_NUM), _R1; \
        or      _R1, %lo(_NUM), _R1;

#define SetCC(_CC,_R1,_R2,_R3) \
        sethi   %hi(CC_MASK), _R1; \
        or      _R1, %lo(CC_MASK), _R1; \
        sethi   %hi(_CC<<20), _R2; \
        or      _R2, %lo(_CC<<20), _R2; \
        rd      %psr, _R3; \
        andn    _R3, _R1, _R3; \
        or      _R3, _R2, _R3; \
        wr      _R3, %psr
        
        .global main
        .align 4

main:

        save    %sp, -96, %sp 

        mov     0, %g7

        MOVW        (0x07ffffff, %g2)
.LOOP:

        mov        0x123, %l1
        mov        0xaaa, %l0
        xor        %l1, %l0, %l1
        cmp        %l1, 0xb89
        bne        .LFAIL
        nop

        MOVW    (.LTESTDATA, %l0)
        mov        1, %l1
        ldub        [%l0+%l1], %l2
        cmp        %l2, 0xaa
        bne        .LFAIL
        nop

        MOVW    (NUM1HI, %l1)
        wr      %l1,%y
        MOVW    (NUM1LO, %l1)
        MOVW    (NUM2, %l2)
        MOVW    (RESULT1, %l4)
        SetCC   (0x7, %l5, %l6,%l7)

        udiv    %l1, %l2, %l3

        ! All CC flags should remain unchanged
        bneg    .LFAIL
        nop
        bne     .LFAIL
        nop
        bvc     .LFAIL
        nop
        bcc     .LFAIL
        nop

        cmp     %l3, %l4
        bne     .LFAIL
        nop

        subcc        %g2, 1, %g2
        bne        .LOOP
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

        .type   main,#function
        .size   main,(.-main)

! ----------------------------------------
        .section ".rodata1"
        .align  8

.LTESTDATA:
        .word 0xAAAAAAAA

