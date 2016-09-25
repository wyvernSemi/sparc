! ========================================
!  $Id: ld.s,v 1.1 2013/06/25 18:30:58 simon Exp $
!  $Source: /home/simon/CVS/src/cpu/sparc/test/ld.s,v $
! ========================================
        .file "ld.s"
        .section ".text"

! ----------------------------------------
#define GOOD    0x900d
#define BAD     0xbad

#define RESULT1  0xAAAAAAAA
#define RESULT2  0x0000BABE
#define RESULT3  0x0000CAFE
#define RESULT4  0x0000FEBA
#define RESULT5  0x00004321
#define RESULT6  0xffff8765
#define RESULT7  0x00000045
#define RESULT8  0x00000093
#define RESULT9  0x00000007
#define RESULT10 0x00000091
#define RESULT11 0xffffff93
#define RESULT12 0xffffff91
#define RESULT13 0xcafebabe
#define RESULT14 0x87654321
#define RESULT15 0x91079345

#define CC_MASK  0x00f00000
#define ZV_MASK1 0x00400000

        .global main
        .align 4

main:

        save    %sp, -96, %sp 

        mov     0, %g7

        !!!!!!! LD !!!!!!!

        sethi   %hi(RESULT1), %l1
        or      %l1, %lo(RESULT1), %l1
        sethi   %hi(.LTESTDATA), %l0
        or      %l0, %lo(.LTESTDATA), %l0
        mov     0, %l2

        ld      [%l0], %l2

        cmp     %l1, %l2
        bne     .LFAIL
        nop

        mov     0, %l2
        sub     %l0, 4, %l0

        ld      [%l0+4], %l2

        cmp     %l1, %l2
        bne     .LFAIL
        nop

        mov     0, %l2
        sub     %l0, 4, %l0
        mov     8, %l3

        ld      [%l0+%l3], %l2

        cmp     %l1, %l2
        bne     .LFAIL
        nop

        mov     0, %g6
        mov     0, %l2
        sub     %l0, 4, %l0
        mov     10, %l3

        ld      [%l0+%l3], %l2	! Misaligned trap

	cmp	%l2, 0
	bne	.LFAIL
	nop
	cmp	%g6, 7
	bne	.LFAIL
	nop

        !!!!!!! LDUH !!!!!!!

        sethi   %hi(RESULT2), %l1
        or      %l1, %lo(RESULT2), %l1
        sethi   %hi(.LTESTDATA), %l0
        or      %l0, %lo(.LTESTDATA), %l0
        mov     0, %l2
        mov     4, %l4

        lduh    [%l0+%l4], %l2

        cmp     %l1, %l2
        bne     .LFAIL
        nop

        sethi   %hi(RESULT3), %l1
        or      %l1,%lo(RESULT3), %l1

        lduh    [%l0+6], %l2

        cmp     %l1, %l2
        bne     .LFAIL
        nop

	mov	0, %l2
	mov	0, %g6

	lduh    [%l0+7], %l2	! misaligned trap

	cmp	%l2, 0
	bne 	.LFAIL
	nop
	cmp	%g6, 7
	bne 	.LFAIL
	nop

        !!!!!!! LDSH !!!!!!!

        sethi   %hi(RESULT5), %l1
        or      %l1, %lo(RESULT5), %l1
        sethi   %hi(.LTESTDATA), %l0
        or      %l0, %lo(.LTESTDATA), %l0
        mov     0, %l2
        mov     8, %l4

        ldsh    [%l0+%l4], %l2

        cmp     %l1, %l2
        bne     .LFAIL
        nop

        sethi   %hi(RESULT6), %l1
        or      %l1, %lo(RESULT6), %l1

        ldsh    [%l0+10], %l2

        cmp     %l1, %l2
        bne     .LFAIL
        nop

	mov	0, %l2
	mov	0, %g6

	ldsh    [%l0+11], %l2	! misaligned trap

	cmp	%l2, 0
	bne 	.LFAIL
	nop
	cmp	%g6, 7
	bne 	.LFAIL
	nop

        !!!!!!! LDUB !!!!!!!

        sethi   %hi(RESULT7), %l1
        or      %l1, %lo(RESULT7), %l1
        sethi   %hi(.LTESTDATA3), %l0
        or      %l0, %lo(.LTESTDATA3), %l0
        mov     0, %l2
        mov     1, %l4

        ldub    [%l0], %l2

        cmp     %l1, %l2
        bne     .LFAIL
        nop

        sethi   %hi(RESULT8), %l1
        or      %l1, %lo(RESULT8), %l1

        ldub    [%l0+%l4], %l2

        cmp     %l1, %l2
        bne     .LFAIL
        nop

        sethi   %hi(RESULT9), %l1
        or      %l1, %lo(RESULT9), %l1

        ldub    [%l0+2], %l2

        cmp     %l1, %l2
        bne     .LFAIL
        nop

        sethi   %hi(RESULT10), %l1
        or      %l1, %lo(RESULT10), %l1
        add     %l4, 2, %l4

        ldub    [%l0+%l4], %l2

        cmp     %l1, %l2
        bne     .LFAIL
        nop

        !!!!!!! LDSB !!!!!!!

        sethi   %hi(RESULT7), %l1
        or      %l1,%lo(RESULT7), %l1
        sethi   %hi(.LTESTDATA3), %l0
        or      %l0, %lo(.LTESTDATA3), %l0
        mov     0, %l2
        mov     1, %l4

        ldsb    [%l0], %l2

        cmp     %l1, %l2
        bne     .LFAIL
        nop

        sethi   %hi(RESULT11), %l1
        or      %l1, %lo(RESULT11), %l1

        ldsb    [%l0+%l4], %l2

        cmp     %l1, %l2
        bne     .LFAIL
        nop

        sethi   %hi(RESULT9), %l1
        or      %l1, %lo(RESULT9), %l1

        ldsb    [%l0+2], %l2

        cmp     %l1, %l2
        bne     .LFAIL
        nop

        sethi   %hi(RESULT12), %l1
        or      %l1, %lo(RESULT12), %l1
        add     %l4, 2, %l4

        ldsb    [%l0+%l4], %l2

        cmp     %l1, %l2
        bne     .LFAIL
        nop

        !!!!!!! LDD !!!!!!!
        sethi   %hi(RESULT1), %l1
        or      %l1, %lo(RESULT1), %l1
        sethi   %hi(.LTESTDATA), %l0
        or      %l0, %lo(.LTESTDATA), %l0
        mov     0, %l2
        mov     8, %l4

        ldd     [%l0], %l2

        cmp     %l1, %l2
        bne     .LFAIL
        nop
        sethi   %hi(RESULT13), %l1
        or      %l1, %lo(RESULT13), %l1
        cmp     %l1, %l3
        bne     .LFAIL
        nop

        sethi   %hi(RESULT14), %l1
        or      %l1, %lo(RESULT14), %l1

        ldd     [%l0+%l4], %l6

        cmp     %l6, %l1
        bne     .LFAIL
        nop
        sethi   %hi(RESULT15), %l1
        or      %l1, %lo(RESULT15), %l1
        cmp     %l7, %l1
        bne     .LFAIL
        nop

	mov	0, %l7
	mov	0, %l6
	mov	0, %g6

	ldd	[%l0+%l4], %l7	! illegal instruction trap

	cmp	%g6, 2
	bne	.LFAIL
	nop
	cmp	%l6, 0
	bne	.LFAIL
	nop
	cmp	%l7, 0
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

        .type   main,#function
        .size   main,(.-main)

! ----------------------------------------
        .section ".rodata1"
        .align  8

.LTESTDATA:
        .word 0xAAAAAAAA
.LTESTDATA1:
        .word 0xcafebabe
.LTESTDATA2:
        .word 0x87654321
.LTESTDATA3:
        .word 0x91079345

