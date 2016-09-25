! ========================================
!  $Id: tsub.s,v 1.1 2013/06/25 18:31:01 simon Exp $
!  $Source: /home/simon/CVS/src/cpu/sparc/test/tsub.s,v $
! ========================================
        .file "tsub.s"
        .section ".text"

! ----------------------------------------
#define GOOD    0x900d
#define BAD     0xbad

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

        MOVW    (0x2004, %l0)
        MOVW    (0xffffe69c, %l1)
        MOVW    (0x3968, %l2)
        SetCC   (0x0, %l5, %l6, %l7)

        tsubcc  %l0, %l1, %l3

        cmp     %l3, %l2
        bne     .LFAIL
        nop
        bvs     .LFAIL
        nop

        MOVW    (0xfffffff0, %l0)
        MOVW    (0x7ffffff0, %l1)
        MOVW    (0x80000000, %l2)
        SetCC   (0x0, %l5, %l6, %l7)

        tsubcc  %l0, %l1, %l3

        cmp     %l3, %l2
        bne     .LFAIL
        nop

        MOVW    (0x2000, %l0)
        MOVW    (0xffffe69f, %l1)
        MOVW    (0x3961, %l2)
        SetCC   (0x0, %l5, %l6, %l7)

        tsubcc  %l0, %l1, %l3

        bvc     .LFAIL
        nop
        cmp     %l3, %l2
        bne     .LFAIL
        nop

        MOVW    (0x2002, %l0)
        MOVW    (0xffffe6a0, %l1)
        MOVW    (0x3962, %l2)
        SetCC   (0x0, %l5, %l6, %l7)

        tsubcc  %l0, %l1, %l3

        bvc     .LFAIL
        nop
        cmp     %l3, %l2
        bne     .LFAIL
        nop

        MOVW    (0x2000, %l0)
        MOVW    (0x0010, %l1)
        MOVW    (0x1ff0, %l2)
        mov     0, %g6
        SetCC   (0x0, %l5, %l6, %l7)

        tsubcctv  %l0, %l1, %l3

        cmp     %l3, %l2
        bne     .LFAIL
        nop
        cmp     %g6, 0
        bne     .LFAIL
        nop

        MOVW    (0x2001, %l0)
        MOVW    (0x0010, %l1)
        MOVW    (0, %l2)
        MOVW    (0, %l3)
        mov     0, %g6
        SetCC   (0x0, %l5, %l6, %l7)

        tsubcctv  %l0, %l1, %l3

        cmp     %l3, %l2
        bne     .LFAIL
        nop
        cmp     %g6, 10
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

