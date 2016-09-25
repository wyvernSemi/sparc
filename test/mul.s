! ========================================
!  $Id: mul.s,v 1.1 2013/06/25 18:30:55 simon Exp $
!  $Source: /home/simon/CVS/src/cpu/sparc/test/mul.s,v $
! ========================================
        .file "mul.s"
        .section ".text"

! ----------------------------------------
#define GOOD    0x900d
#define BAD     0xbad

#define NUM1     0x00001964
#define NUM2     0x0000142c
#define NUM3     0x0000042c
#define BIGNUM1  0x88888888
#define BIGNUM2  0x99999999
#define RESULT1  0x02002d30
#define RESULT2  0x0069ed30
#define BIGRESHI 0x51eb851e
#define BIGRESLO 0x147ae148

#define RESULT3 0xffffcd38

#define CC_MASK  0x00f00000
#define ZV_MASK1 0x00400000
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

        !!!!!!! UMUL !!!!!!!
        sethi   %hi(BIGNUM1), %l1
        or      %l1, %lo(BIGNUM1), %l1
        sethi   %hi(BIGNUM2), %l2
        or      %l2, %lo(BIGNUM2), %l2
        sethi   %hi(BIGRESLO), %l4
        or      %l4, %lo(BIGRESLO), %l4

        umul    %l1, %l2, %l3

        ! Get high word
        rd      %y, %l5

        cmp     %l3, %l4
        bne     .LFAIL
        nop
        sethi   %hi(BIGRESHI), %l4
        or      %l4, %lo(BIGRESHI), %l4
        cmp     %l5, %l4
        bne     .LFAIL
        nop

        sethi   %hi(NUM1), %l1
        or      %l1, %lo(NUM1), %l1
        sethi   %hi(NUM2), %l2
        or      %l2, %lo(NUM2), %l2
        sethi   %hi(RESULT1), %l4
        or      %l4, %lo(RESULT1), %l4

        SetCC   (0xf,%l5,%l6,%l7)

        umul    %l1, %l2, %l3

        ! All CC flags should remain set
        bpos    .LFAIL
        nop
        bne     .LFAIL
        nop
        bvc     .LFAIL
        nop
        bcc     .LFAIL
        nop

        ! Check value
        cmp     %l3, %l4
        bne     .LFAIL
        nop

        !!!!!!! UMULcc !!!!!!!
        sethi   %hi(RESULT2), %l4
        or      %l4, %lo(RESULT2), %l4
        SetCC   (0xf,%l5,%l6,%l7)

        umulcc  %l1, NUM3, %l3

        ! All CC flags should be cleared
        be      .LFAIL
        nop
        bneg    .LFAIL
        nop
        bcs     .LFAIL
        nop
        bvs     .LFAIL
        nop

        ! Check value
        cmp     %l3, %l4
        bne     .LFAIL
        nop

        !!!!!!! SMUL !!!!!!!
        sethi   %hi(NUM1), %l1
        or      %l1, %lo(NUM1), %l1
        sethi   %hi(RESULT3), %l4
        or      %l4, %lo(RESULT3), %l4
        SetCC   (0x7,%l5,%l6,%l7)

        smul    %l1, -2, %l3

        ! Get high word
        rd      %y, %l5

        ! CC flags unchanged
        bneg    .LFAIL
        nop
        bne     .LFAIL
        nop
        bvc     .LFAIL
        nop
        bcc     .LFAIL
        nop


        ! Check value
        cmp     %l3, %l4
        bne     .LFAIL
        nop

        sethi   %hi(0xffffffff), %l4
        or      %l4, %lo(0xffffffff), %l4
        cmp     %l5,%l4
        bne     .LFAIL
        nop
        
        !!!!!!! SMULcc !!!!!!!
        sethi   %hi(RESULT3), %l4
        or      %l4, %lo(RESULT3), %l4
        mov     -2,%o0
        SetCC   (0x7,%l5,%l6,%l7)

        smulcc  %l1,%o0,%l3

        ! CC flags changed
        bpos    .LFAIL
        nop
        be      .LFAIL
        nop
        bvs     .LFAIL
        nop
        bcs     .LFAIL
        nop

        ! Check value
        cmp     %l3, %l4
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
.LTESTDATA1:
        .word 0xAAAAAAAA

