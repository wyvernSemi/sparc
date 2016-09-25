! ========================================
!  $Id: ticc.s,v 1.1 2013/06/25 18:31:02 simon Exp $
!  $Source: /home/simon/CVS/src/cpu/sparc/test/ticc.s,v $
! ========================================
        .file "ticc.s"
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

        !!!!!!! TA !!!!!!
        mov     -1, %g6

        ta      0

        cmp     %g6, -2
        bne     .LFAIL
        nop

        mov     -1, %g6

        !!!!!!! TN !!!!!!
        tn      1

        cmp     %g6, -1
        bne     .LFAIL
        nop

        !!!!!!! TNE !!!!!!
        mov     -1, %g6
        cmp     %g6, -1

        tne     2

        cmp     %g6, -1
        bne     .LFAIL
        nop

        mov     -1, %g6
        cmp     %g6, 1 

        tne     2

        cmp     %g6, 1
        bne     .LFAIL
        nop

        !!!!!!! TE !!!!!!
        mov     -1, %g6
        cmp     %g6, 1

        te      3

        cmp     %g6, -1
        bne     .LFAIL
        nop

        mov     -1, %g6
        cmp     %g6, -1 

        te      3

        cmp     %g6, 2
        bne     .LFAIL
        nop

        !!!!!!! TG !!!!!!
        mov     -1, %g6
        cmp     %g6, -1

        tg      2

        cmp     %g6, -1
        bne     .LFAIL
        nop

        mov     0, %g6
        cmp     %g6, -1

        tg      2

        cmp     %g6, 2
        bne     .LFAIL
        nop

        !!!!!!! TLE !!!!!!
        mov     -1, %g6
        cmp     %g6, -2

        tle     1

        cmp     %g6, -1
        bne     .LFAIL
        nop

        mov     -1, %g6
        cmp     %g6, -1

        tle     1

        cmp     %g6, 0
        bne     .LFAIL
        nop

        !!!!!!! TGU !!!!!!!
        mov     1, %g6
        cmp     %g6, -1

        tgu     3

        cmp     %g6, 1
        bne     .LFAIL
        nop

        mov     -1, %g6
        cmp     %g6, 1

        tgu     3

        cmp     %g6, 2
        bne     .LFAIL
        nop

        !!!!!!! TLEU !!!!!!!
        mov     -1, %g6
        cmp     %g6, 1

        tleu    3

        cmp     %g6, -1
        bne     .LFAIL
        nop

        mov     1, %g6
        cmp     %g6, -1

        tleu    3

        cmp     %g6, 4
        bne     .LFAIL
        nop

        !!!!!!! TCC !!!!!!!
        mov     15, %g6
        SetCC   (0x1, %l5, %l6, %l7)

        tcc     2

        cmp     %g6, 15
        bne     .LFAIL
        nop

        mov     15, %g6
        SetCC   (0x0, %l5, %l6, %l7)

        tcc     2

        cmp     %g6, 17
        bne     .LFAIL
        nop

        !!!!!!! TCS !!!!!!!
        mov     15, %g6
        SetCC   (0x0, %l5, %l6, %l7)

        tcs     2

        cmp     %g6, 15
        bne     .LFAIL
        nop

        mov     15, %g6
        SetCC   (0x1, %l5, %l6, %l7)

        tcs     2

        cmp     %g6, 17
        bne     .LFAIL
        nop

        !!!!!!! TPOS !!!!!!!
        mov     15, %g6
        SetCC   (0x8, %l5, %l6, %l7)

        tpos    2

        cmp     %g6, 15
        bne     .LFAIL
        nop

        mov     15, %g6
        SetCC   (0x0, %l5, %l6, %l7)

        tpos    2

        cmp     %g6, 17
        bne     .LFAIL
        nop

        !!!!!!! TNEG !!!!!!!
        mov     15, %g6
        SetCC   (0x0, %l5, %l6, %l7)

        tneg    2

        cmp     %g6, 15
        bne     .LFAIL
        nop

        mov     15, %g6
        SetCC   (0x8, %l5, %l6, %l7)

        tneg    2

        cmp     %g6, 17
        bne     .LFAIL
        nop

        !!!!!!! TVC !!!!!!!
        mov     15, %g6
        SetCC   (0x2, %l5, %l6, %l7)

        tvc     2

        cmp     %g6, 15
        bne     .LFAIL
        nop

        mov     15, %g6
        SetCC   (0x0, %l5, %l6, %l7)

        tvc     2

        cmp     %g6, 17
        bne     .LFAIL
        nop

        !!!!!!! TVS !!!!!!!
        mov     15, %g6
        SetCC   (0x0, %l5, %l6, %l7)

        tvs     2

        cmp     %g6, 15
        bne     .LFAIL
        nop

        mov     15, %g6
        SetCC   (0x2, %l5, %l6, %l7)

        tvs     2

        cmp     %g6, 17
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

