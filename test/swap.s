! ========================================
!  $Id: swap.s,v 1.1 2013/06/25 18:31:02 simon Exp $
!  $Source: /home/simon/CVS/src/cpu/sparc/test/swap.s,v $
! ========================================
        .file "swap.s"
        .section ".text"

! ----------------------------------------
#define GOOD    0x900d
#define BAD     0xbad

#define NUM1    0xfedcba98
#define NUM2    0x76543210
#define NUM3    0x55555555
#define NUM4    0xAAAAAAAA

#define CC_MASK  0x00f00000
#define ZV_MASK1 0x00400000

        .global main
        .align 4

main:

        save    %sp, -96, %sp 

        mov     0, %g7

        sethi   %hi(NUM1), %l1
        or      %l1, %lo(NUM1), %l1
        sethi   %hi(NUM1), %l3
        or      %l3, %lo(NUM1), %l3
        sethi   %hi(NUM2), %l2
        or      %l2, %lo(NUM2), %l2
        sethi   %hi(.LTESTDATA), %l0
        or      %l0, %lo(.LTESTDATA), %l0

        swap    [%l0], %l3

        ld      [%l0], %l4

        cmp     %l3, %l2
        bne     .LFAIL
        nop
        cmp     %l4, %l1
        bne     .LFAIL
        nop

        sethi   %hi(NUM3), %l1
        or      %l1, %lo(NUM3), %l1
        sethi   %hi(NUM3), %l3
        or      %l3, %lo(NUM3), %l3
        sethi   %hi(NUM4), %l2
        or      %l2, %lo(NUM4), %l2
        sethi   %hi(.LTESTDATA), %l0
        or      %l0, %lo(.LTESTDATA), %l0
        mov     4, %l5

        swap    [%l0+%l5], %l3

        ld      [%l0+4], %l4

        cmp     %l3, %l2
        bne     .LFAIL
        nop
        cmp     %l4, %l1
        bne     .LFAIL
        nop

	mov	0, %g6
	inc	%l5
	mov	%l3, %l7

	swap    [%l0+%l5], %l3	! misaligned trap

	cmp	%g6, 7
	bne	.LFAIL
	nop
	cmp	%l7, %l3 
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

! ----------------------------------------
        .section ".data"
        .align  4

.LTESTDATA:
        .word 0x76543210
.LTESTDATA1:
        .word 0xAAAAAAAA

