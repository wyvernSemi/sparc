! ========================================
!  $Id: sethi.s,v 1.1 2013/06/25 18:31:03 simon Exp $
!  $Source: /home/simon/CVS/src/cpu/sparc/test/sethi.s,v $
! ========================================
        .file "sethi.s"
        .section ".text"

! ----------------------------------------
#define GOOD    0x900d
#define BAD     0xbad

#define NUM1    0x12345678
#define RESULT1 0x12345400

#define CC_MASK  0x00f00000
#define ZV_MASK1 0x00400000

        .global main
        .align 4

main:

        save    %sp, -96, %sp 

        mov     0, %g7

        !!!!!!! NOP !!!!!!!

        nop
        nop
        nop

        ! Check result
        cmp     %g0, 0
        bne     .LFAIL
        nop
        

        !!!!!!! SETHI !!!!!!!

        ! Load RESULT1 into %l2 (without using sethi)
        mov     (RESULT1>>24 & 0xff), %l2
        sll     %l2, 8, %l2
        or      %l2, (RESULT1>>16 & 0xff), %l2
        sll     %l2, 8, %l2
        or      %l2, (RESULT1>>8 & 0xff), %l2
        sll     %l2, 8, %l2

        ! Make sure test register is cleared
        mov     0, %l3

        sethi   %hi(NUM1),%l3

        ! Check result
        cmp     %l2, %l3
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

        .type   main,#function
        .size   main,(.-main)

