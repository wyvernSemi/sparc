! ========================================
!  $Id: jmpl.s,v 1.1 2013/06/25 18:31:02 simon Exp $
!  $Source: /home/simon/CVS/src/cpu/sparc/test/jmpl.s,v $
! ========================================
        .file "jmpl.s"
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

        mov     10, %g6
        MOVW    (.LCALLOPADDR, %l0)
        MOVW    (calltarget, %l2)
        sub     %l2, 12, %l2

.LCALLOPADDR:
        jmpl    %l2+12, %o4
        mov     0, %g6

        cmp     %g6, 1
        bne     .LFAIL
        nop

        cmp     %l0, %o4
        bne     .LFAIL
        nop

        mov     10, %g6
        MOVW    (.LCALLOPADDR1, %l0)
        MOVW    (calltarget-12, %l2)
        mov     12, %l3

.LCALLOPADDR1:
        jmpl    %l2+%l3, %o4
        mov     0, %g6

        cmp     %g6, 1
        bne     .LFAIL
        nop

        cmp     %l0, %o4
        bne     .LFAIL
        nop

	inc	%l3
	mov	0, %g6

	jmpl    %l2+%l3, %o4
	nop

	cmp	%g6, 7
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

        .local calltarget
        .align 4

calltarget:
        save    %sp, -96, %sp 
        inc     %g6
        mov     %i4, %i7
        ret     
        restore

        .type   calltarget, #function
        .size   calltarget, (.-main)

