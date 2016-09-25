! ========================================
!  $Id: div.s,v 1.1 2013/06/25 18:30:57 simon Exp $
!  $Source: /home/simon/CVS/src/cpu/sparc/test/div.s,v $
! ========================================
        .file "div.s"
        .section ".text"

! ----------------------------------------
#define GOOD    0x900d
#define BAD     0xbad

#define NUM1HI  0x00001964
#define NUM1LO  0x25080500
#define NUM2    0x00002004
#define NUM3    0xFFFFDFFC
#define RESULT1 0xcb07c747
#define RESULT2 0x34f838b9

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

        !!!!!!! UDIV !!!!!!!
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

	mov	0, %g6
	mov	0, %l2
	mov	77, %l3

	udiv    %l1, %l2, %l3	! divide by 0 trap

        cmp     %g6, 42
        bne     .LFAIL
        nop
        cmp     %l3, 77
        bne     .LFAIL
        nop
	

        !!!!!!! UDIVcc !!!!!!!!

        MOVW    (NUM1HI, %l1)
        wr      %l1,%y
        MOVW    (NUM1LO, %l1)
        MOVW    (NUM2, %l2)
        MOVW    (RESULT1, %l4)
        SetCC   (0x7, %l5, %l6,%l7)

        udivcc  %l1, %l2, %l3

        ! All CC flags should be changed
        bpos    .LFAIL
        nop
        be      .LFAIL
        nop
        bvs     .LFAIL
        nop
        bcs     .LFAIL
        nop

        cmp     %l3, %l4
        bne     .LFAIL
        nop

	mov	0, %g6
	mov	0, %l2
	mov	77, %l3

	udivcc  %l1, %l2, %l3	! divide by 0 trap

        cmp     %g6, 42
        bne     .LFAIL
        nop
        cmp     %l3, 77
        bne     .LFAIL
        nop
	
        !!!!!!! SDIV !!!!!!!

        MOVW    (NUM1HI, %l1)
        wr      %l1,%y
        MOVW    (NUM1LO, %l1)
        MOVW    (NUM3, %l2)
        MOVW    (RESULT2, %l4)
        SetCC   (0xf, %l5, %l6,%l7)

        sdiv    %l1, %l2, %l3

        ! All CC flags should be unchanged
        bpos    .LFAIL
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

	mov	0, %g6
	mov	0, %l2
	mov	77, %l3

	sdiv    %l1, %l2, %l3	! divide by 0 trap

        cmp     %g6, 42
        bne     .LFAIL
        nop
        cmp     %l3, 77
        bne     .LFAIL
        nop
	
        !!!!!!! SDIVcc !!!!!!!

        MOVW    (NUM1HI, %l1)
        wr      %l1,%y
        MOVW    (NUM1LO, %l1)
        MOVW    (NUM3, %l2)
        MOVW    (RESULT2, %l4)
        SetCC   (0xf, %l5, %l6,%l7)

        sdivcc  %l1, %l2, %l3

        ! All CC flags should be changed
        bneg    .LFAIL
        nop
        be      .LFAIL
        nop
        bvs     .LFAIL
        nop
        bcs     .LFAIL
        nop

        cmp     %l3, %l4
        bne     .LFAIL
        nop

	mov	0, %g6
	mov	0, %l2
	mov	77, %l3

	sdivcc  %l1, %l2, %l3	! divide by 0 trap

        cmp     %g6, 42
        bne     .LFAIL
        nop
        cmp     %l3, 77
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

