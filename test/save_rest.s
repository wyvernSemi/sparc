! ========================================
!  $Id: save_rest.s,v 1.1 2013/06/25 18:30:54 simon Exp $
!  $Source: /home/simon/CVS/src/cpu/sparc/test/save_rest.s,v $
! ========================================
        .file "save_rest.s"
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

        mov     0x123, %l0
        MOVW    (0x2004, %l1)
        rd      %psr, %g4
        and     %g4, 0xf, %g4

        save    %l1, 0x10, %l1

        MOVW    (0x2014, %l2)
        cmp     %l1, %l2
        bne,a   .LFAIL
        restore

        rd      %psr, %l0
        and     %l0, 0xf, %l0
        subcc   %g4, %l0, %l0
        cmp     %l0, 1
        bne,a   .LFAIL
        restore


        restore

        MOVW    (0x2004, %l2)
        cmp     %l1, %l2
        bne,a   .LFAIL
        nop
        cmp     %l0, 0x123
        bne     .LFAIL
        nop

        rd      %psr, %l0
        and     %l0, 0xf, %l0
        cmp     %l0, %g4
        bne     .LFAIL
        nop

        mov     0x10, %l4
        mov     0x123, %l0
        MOVW    (0x2004, %l1)
        rd      %psr, %g4
        and     %g4, 0xf, %g4

        save    %l1, %l4, %l1

        MOVW    (0x2014, %l2)
        cmp     %l1, %l2
        bne,a   .LFAIL
        restore

        rd      %psr, %l0
        and     %l0, 0xf, %l0
        subcc   %g4, %l0, %l0
        cmp     %l0, 1
        bne,a   .LFAIL
        restore


        restore

        MOVW    (0x2004, %l2)
        cmp     %l1, %l2
        bne,a   .LFAIL
        nop
        cmp     %l0, 0x123
        bne     .LFAIL
        nop

        rd      %psr, %l0
        and     %l0, 0xf, %l0
        cmp     %l0, %g4
        bne     .LFAIL
        nop

	rd	%wim, %g2
	rd	%psr, %g4
        MOVW	(0x0004000, %g3)
	or	%g2, %g3, %g3
	wr	%g3, %wim
	mov	0x1f, %g5
	not	%g5, %g5
	and	%g4, %g5, %g5
	or	%g5, 15, %g5
	wr	%g5, %psr
	mov	0, %g6

	save	%sp, 0, %sp	! window overflow trap

	cmp	%g6, 5
	bne	.LFAIL
	nop

	wr	%g2, %wim
	wr	%g4, %psr

	rd	%wim, %g2
	rd	%psr, %g4
        MOVW	(0x0004000, %g3)
	or	%g2, %g3, %g3
	wr	%g3, %wim
	mov	0x1f, %g5
	not	%g5, %g5
	and	%g4, %g5, %g5
	or	%g5, 13, %g5
	wr	%g5, %psr
	mov	0, %g6

	restore			! window underflow trap

	cmp	%g6, 6
	bne	.LFAIL
	nop

	wr	%g2, %wim
	wr	%g4, %psr

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

