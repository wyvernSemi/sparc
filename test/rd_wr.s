! ========================================
!  $Id: rd_wr.s,v 1.1 2013/06/25 18:30:58 simon Exp $
!  $Source: /home/simon/CVS/src/cpu/sparc/test/rd_wr.s,v $
! ========================================
        .file "rd_wr.s"
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

        !!!!!!! RDY, WRY !!!!!!!
        mov     0x567, %g6
        mov     0xfff, %g7

        wr      %g6, %g7, %y
        rd      %y, %g5

        cmp     %g5, 0xa98
        bne     .LFAIL
        nop

        MOVW    (0xb89efcd2, %g5)
        MOVW    (0x12345678, %g6)
        MOVW    (0xAAAAAAAA, %g7)

        wr      %g6, %g7, %y
        rd      %y, %g4

        cmp     %g4, %g5
        bne     .LFAIL
        nop

        !!!!!!! RDPSR, WRPSR !!!!!!!
        rd      %psr, %g3
        MOVW    (0x567000e7, %g2)
        MOVW    (0xa98fff18, %g6)
        MOVW    (0xffffffff, %g7)

        wr      %g6, %g7, %psr
        rd      %psr, %g5

        cmp     %g5, %g2
        bne     .LFAIL
        nop

        MOVW    (0x567000e7, %g5)
        MOVW    (0xfcdaaa4d, %g6)
        MOVW    (0xAAAAAAAA, %g7)

        wr      %g6, %g7, %psr
        rd      %psr, %g4

        cmp     %g4, %g5
        bne     .LFAIL
        nop

        wr      %g3, 0, %psr

        !!!!!!! RDTBR, WRTBR !!!!!!!
        rd      %tbr, %g3
        mov     0x567, %g6
        mov     0xfff, %g7

        wr      %g6, %g7, %tbr
        rd      %tbr, %g5

        cmp     %g5, 0xa98
        bne     .LFAIL
        nop

        MOVW    (0xb89efcd2, %g5)
        MOVW    (0x12345678, %g6)
        MOVW    (0xAAAAAAAA, %g7)

        wr      %g6, %g7, %tbr
        rd      %tbr, %g4

        cmp     %g4, %g5
        bne     .LFAIL
        nop

        wr      %g3, 0, %tbr

        !!!!!!! RDWIM, WRWIM !!!!!!!
        rd      %wim, %g3
        mov     0x567, %g6
        mov     0xfff, %g7

        wr      %g6, %g7, %wim
        rd      %wim, %g5

        cmp     %g5, 0xa98
        bne     .LFAIL
        nop

        MOVW    (0xb89efcd2, %g5)
        MOVW    (0x12345678, %g6)
        MOVW    (0xAAAAAAAA, %g7)

        wr      %g6, %g7, %wim
        rd      %wim, %g4

        cmp     %g4, %g5
        bne     .LFAIL
        nop

        wr      %g3, 0, %wim

        rd	%psr, %g4
	mov	0x1f, %g5
	not	%g5, %g5
	and	%g4, %g5, %g4
	or	%g4, 17, %g4
	mov	0, %g6

	wr	%g4, %psr

	cmp	%g6, 2
	bne	.LFAIL
	nop

	! Go to user mode
        rd	%psr, %g4
	mov	0x80, %g5
	not	%g5, %g5
	and	%g4, %g5, %g4
	wr	%g4, %psr

	mov	0, %g6
	rd	%psr, %g0
	cmp	%g6, 3
	bne	.LFAIL
	nop

	mov	0, %g6
	rd	%wim, %g0
	cmp	%g6, 3
	bne	.LFAIL
	nop

	mov	0, %g6
	rd	%tbr, %g0
	cmp	%g6, 3
	bne	.LFAIL
	nop

	mov	0, %g6
	wr	%g0, %psr
	cmp	%g6, 3
	bne	.LFAIL
	nop

	mov	0, %g6
	wr	%g0, %wim
	cmp	%g6, 3
	bne	.LFAIL
	nop

	mov	0, %g6
	wr	%g0, %tbr
	cmp	%g6, 3
	bne	.LFAIL
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

