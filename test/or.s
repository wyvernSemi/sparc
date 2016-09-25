! ========================================
!  $Id: or.s,v 1.1 2013/06/25 18:31:01 simon Exp $
!  $Source: /home/simon/CVS/src/cpu/sparc/test/or.s,v $
! ========================================
        .file "or.s"
        .section ".text"

! ----------------------------------------
#define GOOD    0x900d
#define BAD     0xbad

#define NUM1    0x80604020
#define MASK1   0x07050301
#define MASK2   0xf8fafcfe
#define MASK3   0x301
#define RESULT1 0x87654321
#define RESULT2 0x80604321

#define CC_MASK  0x00f00000
#define ZV_MASK1 0x00400000

        .global main
        .align 4

main:

        save    %sp, -96, %sp 

        mov     0, %g7

        !!!!!!! OR !!!!!!!

        ! Immediate
        sethi   %hi(NUM1), %l0
        or      %l0, %lo(NUM1), %l0
        sethi   %hi(RESULT2), %l2
        or      %l2, %lo(RESULT2), %l2

        or      %l0, MASK3, %l3

        ! Check result
        cmp     %l2, %l3
        bne     .LFAIL
        nop

        ! Register
        sethi   %hi(MASK1), %l1
        or      %l1, %lo(MASK1), %l1
        sethi   %hi(RESULT1), %l2
        or      %l2, %lo(RESULT1), %l2

        ! Set CC to be 4 (N=0 and Z=1)
        sethi   %hi(CC_MASK), %l4
        or      %l4, %lo(CC_MASK), %l4
        sethi   %hi(ZV_MASK1), %l5
        or      %l5, %lo(ZV_MASK1), %l5
        rd      %psr, %g3
        andn    %g3, %l4, %g3
        or      %g3, %l5, %g3
        wr      %g3, %psr
        
        or      %l0, %l1, %l3

        ! Instruction should not have cleared Z or set N
        bne     .LFAIL
        nop
        bneg    .LFAIL
        nop

        ! Check result
        cmp     %l2, %l3
        bne     .LFAIL
        nop

        !!!!!!! ORcc !!!!!!!
        ! reload CC bits with 4 (N=0 Z=1)
        wr      %g3, %psr
        
        orcc    %l0, %l1, %l3

        ! Instruction should have cleared Z and set N
        be      .LFAIL
        nop
        bpos    .LFAIL
        nop


        ! Check result
        cmp     %l2, %l3
        bne     .LFAIL
        nop

        !!!!!!! ORN !!!!!!!

        sethi   %hi(NUM1), %l0
        or      %l0, %lo(NUM1), %l0
        sethi   %hi(MASK2), %l1
        or      %l1, %lo(MASK2), %l1
        sethi   %hi(RESULT1), %l2
        or      %l2, %lo(RESULT1), %l2

        ! Set CC to be 4 (N=0 and Z=1)
        sethi   %hi(CC_MASK), %l4
        or      %l4, %lo(CC_MASK), %l4
        sethi   %hi(ZV_MASK1), %l5
        or      %l5, %lo(ZV_MASK1), %l5
        rd      %psr, %g3
        andn    %g3, %l4, %g3
        or      %g3, %l5, %g3
        wr      %g3, %psr
        
        orn     %l0, %l1, %l3

        ! Instruction should not have cleared Z or set N
        bne     .LFAIL
        nop
        bneg    .LFAIL
        nop

        ! Check result
        cmp     %l2, %l3
        bne     .LFAIL
        nop

        !!!!!!! ORNcc !!!!!!!

        ! reload CC bits with 4 (N=0 Z=1)
        wr      %g3, %psr
        
        orncc    %l0, %l1, %l3

        ! Instruction should have cleared Z and set N
        be      .LFAIL
        nop
        bpos    .LFAIL
        nop


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

