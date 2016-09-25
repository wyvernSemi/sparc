! ========================================
!  $Id: mulscc.s,v 1.1 2013/06/25 18:31:03 simon Exp $
!  $Source: /home/simon/CVS/src/cpu/sparc/test/mulscc.s,v $
! ========================================
        .file "mulscc.s"
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

        MOVW    (0x00012345, %l1)
        MOVW    (0x00002004, %l2)
        MOVW    (0x246d2d14, %l3)
        MOVW    (0x0000ffff, %l4)
        MOVW    (0x8000b1a6, %g1)
        SetCC   (0x7, %l5, %l6, %l7)
        wr      %l4, %y

        mulscc  %l1, %l2, %l5

        bpos    .LFAIL
        nop
        bvs     .LFAIL
        nop
        bcs     .LFAIL
        nop
        be      .LFAIL
        nop

        cmp     %g1, %l5
        bne     .LFAIL
        nop

        MOVW    (0x00012345, %l1)
        MOVW    (0x00002004, %l2)
        MOVW    (0x246d2d14, %l3)
        MOVW    (0x0000ffff, %l4)
        MOVW    (0x8000b1a6, %g1)
        SetCC   (0x8, %l5, %l6, %l7)
        wr      %l4, %y

        mulscc  %l1, %l2, %l5

        cmp     %g1, %l5
        bne     .LFAIL
        nop

        MOVW    (0x00012345, %l1)
        MOVW    (0x00002004, %l2)
        MOVW    (0x246d2d14, %l3)
        MOVW    (0x0000ffff, %l4)
        MOVW    (0x0000b1a6, %g1)
        SetCC   (0x0, %l5, %l6, %l7)
        wr      %l4, %y

        mulscc  %l1, %l2, %l5

        cmp     %g1, %l5
        bne     .LFAIL
        nop

        MOVW    (0x00012345, %l1)
        MOVW    (0x00002004, %l2)
        MOVW    (0x246d2d14, %l3)
        MOVW    (0x0000ffff, %l4)
        MOVW    (0x0000b1a6, %g1)
        SetCC   (0xa, %l5, %l6, %l7)
        wr      %l4, %y

        mulscc  %l1, %l2, %l5

        cmp     %g1, %l5
        bne     .LFAIL
        nop

        MOVW    (0x00012345, %l1)
        MOVW    (0x00002004, %l2)
        MOVW    (0x246d2d14, %l3)
        MOVW    (0x0000fffe, %l4)
        MOVW    (0x00002004, %g1)
        SetCC   (0xa, %l5, %l6, %l7)
        wr      %l4, %y

        mulscc  %l1, %l2, %l5

        cmp     %g1, %l5
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

