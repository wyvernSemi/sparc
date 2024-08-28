! ========================================
!  $Id: st.s,v 1.1 2013/06/25 18:31:00 simon Exp $
!  $Source: /home/simon/CVS/src/cpu/sparc/test/st.s,v $
! ========================================
        .file "st.s"
        .section ".text"

! ----------------------------------------
#define GOOD    0x900d
#define BAD     0xbad

#define VALUE1   0x71077345
#define VALUE2   0x0000beef
#define VALUE3   0x000000de
#define VALUE4   0x000000ad
#define VALUE5   0x000000be
#define VALUE6   0x000000ef
#define VALUE7   0xfedcba98
#define VALUE8   0x76543210
#define RESULT1  0xbeef7345
#define RESULT2  0xdeef7345
#define RESULT3  0xdead7345
#define RESULT4  0xdeadbe45
#define RESULT5  0xdeadbeef

#define CC_MASK  0x00f00000
#define ZV_MASK1 0x00400000

        .global main
        .align 4

main:

        save    %sp, -96, %sp 

        mov     0, %g7

        !!!!!!! ST !!!!!!!!

        sethi   %hi(VALUE1), %l1
        or      %l1, %lo(VALUE1), %l1
        sethi   %hi(.LTESTDATA), %l0
        or      %l0, %lo(.LTESTDATA), %l0
        mov     0, %l2
        flush   %l0

        st      %l1, [%l0]

        ! Check result
        ld      [%l0], %l2
        cmp     %l1, %l2
        bne     .LFAIL
        stbar

	mov	0, %g6

	st      %l1, [%l0+1]	! misaligned trap

	cmp	%g6, 7
	bne	.LFAIL
	nop

        !!!!!!! STH !!!!!!!
        sethi   %hi(VALUE2), %l1
        or      %l1, %lo(VALUE2), %l1
        sethi   %hi(.LTESTDATA-4), %l0
        or      %l0, %lo(.LTESTDATA-4), %l0
        mov     0, %l2

        sth     %l1, [%l0+4]

        ! Check result
        sethi   %hi(RESULT1), %l1
        or      %l1, %lo(RESULT1), %l1
        ld      [%l0+4], %l2
        cmp     %l1, %l2
        bne     .LFAIL

	mov	0, %g6

	sth     %l1, [%l0+7]	! misaligned trap

	cmp	%g6, 7
	bne	.LFAIL
	nop


        !!!!!!! STB !!!!!!!

        sethi   %hi(VALUE3), %l1
        or      %l1, %lo(VALUE3), %l1
        sethi   %hi(.LTESTDATA), %l0
        or      %l0, %lo(.LTESTDATA), %l0
        mov     0, %l4
        mov     0, %l2

        stb     %l1, [%l0+%l4]

        ! Check result

        sethi   %hi(RESULT2), %l1
        or      %l1, %lo(RESULT2), %l1
        ld      [%l0], %l2
        cmp     %l1, %l2
        bne     .LFAIL
        nop

        sethi   %hi(VALUE4), %l1
        or      %l1, %lo(VALUE4), %l1
        sethi   %hi(.LTESTDATA), %l0
        or      %l0, %lo(.LTESTDATA), %l0
        inc     %l4
        mov     0, %l2

        stb     %l1, [%l0+%l4]

        ! Check result

        sethi   %hi(RESULT3), %l1
        or      %l1, %lo(RESULT3), %l1
        ld      [%l0], %l2
        cmp     %l1, %l2
        bne     .LFAIL
        nop

        sethi   %hi(VALUE5), %l1
        or      %l1, %lo(VALUE5), %l1
        sethi   %hi(.LTESTDATA), %l0
        or      %l0, %lo(.LTESTDATA), %l0
        dec     %l4
        mov     0, %l2

        stb     %l1, [%l0+2]

        ! Check result

        sethi   %hi(RESULT4), %l1
        or      %l1, %lo(RESULT4), %l1
        ld      [%l0], %l2
        cmp     %l1, %l2
        bne     .LFAIL
        nop

        sethi   %hi(VALUE6), %l1
        or      %l1, %lo(VALUE6), %l1
        sethi   %hi(.LTESTDATA), %l0
        or      %l0, %lo(.LTESTDATA), %l0
        mov     0, %l2

        stb     %l1, [%l0+3]

        ! Check result

        sethi   %hi(RESULT5), %l1
        or      %l1, %lo(RESULT5), %l1
        ld      [%l0], %l2
        cmp     %l1, %l2
        bne     .LFAIL
        nop

        !!!!!!! STD !!!!!!!

        sethi   %hi(VALUE7), %l4
        or      %l1, %lo(VALUE7), %l4
        sethi   %hi(VALUE8), %l5
        or      %l1, %lo(VALUE8), %l5
        sethi   %hi(.LTESTDATA), %l0
        or      %l0, %lo(.LTESTDATA), %l0
        mov     0, %l2

        std     %l4, [%l0]

        ld      [%l0], %l2
        cmp     %l2, %l4
        bne     .LFAIL
        nop

        ld      [%l0+4], %l2
        cmp     %l2, %l5
        bne     .LFAIL
        nop

	mov 	0, %g6
	mov 	0, %l6
	mov 	0, %l7

        std     %l7, [%l0]	! illegal instruction

	cmp	%g6, 2
	bne	.LFAIL
	nop
        ld      [%l0], %l2
        cmp     %l2, %l4
        bne     .LFAIL
        nop
        ld      [%l0+4], %l2
        cmp     %l2, %l5
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
        .section ".data", #write
        .align  8

.LTESTDATA:
        .word 0x00000000
        .word 0x00000000

