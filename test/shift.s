! ========================================
!  $Id: shift.s,v 1.1 2013/06/25 18:30:56 simon Exp $
!  $Source: /home/simon/CVS/src/cpu/sparc/test/shift.s,v $
! ========================================
        .file "shift.s"
        .section ".text"

! ----------------------------------------
#define GOOD    0x900d
#define BAD     0xbad

#define NUM1    0x12345678
#define RESULT1 0x12345678
#define NUM2    0x87654321
#define RESULT2 0xff876543
#define MASK1   0xff000000

#define CC_MASK  0x00f00000
#define ZV_MASK1 0x00c00000
#define ZV_MASK2 0x00400000

        .global main
        .align 4

main:

        save    %sp, -96, %sp 

        mov     0, %g7

        !!!!!!! SLL !!!!!!!

        sethi   %hi(RESULT1), %l2
        or      %l2, %lo(RESULT1), %l2

        mov     (NUM1>>24 & 0xff), %l3
        sll     %l3, 8, %l3
        mov     (NUM1>>16 & 0xff), %l4
        or      %l3, %l4, %l3
        sll     %l3, 8, %l3
        mov     (NUM1>>8 & 0xff), %l4
        or      %l3, %l4, %l3
        mov     8, %l5
        sll     %l3, %l5, %l3
        mov     (NUM1 & 0xff), %l4
        or      %l3, %l4, %l3

        ! Check result
        cmp     %l2, %l3
        bne     .LFAIL
        nop

        sll     %l3, 0, %l3

        ! Check result
        cmp     %l2, %l3
        bne     .LFAIL
        nop

        ! Set CC to be 0xc (N=1 and Z=1)
        sethi   %hi(CC_MASK), %l4
        or      %l4, %lo(CC_MASK), %l4
        sethi   %hi(ZV_MASK1), %l5
        or      %l5, %lo(ZV_MASK1), %l5
        rd      %psr, %g3
        andn    %g3, %l4, %g3
        or      %g3, %l5, %g3
        wr      %g3, %psr

        sll     %l3, 1, %l3

        ! Instruction should not have cleared Z or N
        bne     .LFAIL
        nop
        bpos    .LFAIL
        nop
        
        !!!!!!! SRL !!!!!!!
        sethi   %hi((NUM1<<24 & 0xff000000)), %l3
        or      %l3, %lo(NUM1<<24 & 0xff000000), %l3
        srl     %l3, 8, %l3
        sethi   %hi((NUM1<<16 & 0xff000000)), %l4
        or      %l4, %lo(NUM1<<16 & 0xff000000), %l4
        or      %l3, %l4, %l3
        srl     %l3, 8, %l3
        sethi   %hi((NUM1<<8 & 0xff000000)), %l4
        or      %l4, %lo(NUM1<<8 & 0xff000000), %l4
        or      %l3, %l4, %l3
        mov     8, %l5
        srl     %l3, %l5, %l3
        sethi   %hi((NUM1 & 0xff000000)), %l4
        or      %l4, %lo(NUM1 & 0xff000000), %l4
        or      %l3, %l4, %l3

        ! Check result
        cmp     %l2, %l3
        bne     .LFAIL
        nop

        srl     %l3, 0, %l3

        ! Check result
        cmp     %l2, %l3
        bne     .LFAIL
        nop

        ! Set CC to be 0xc (N=1 and Z=1)
        sethi   %hi(CC_MASK), %l4
        or      %l4, %lo(CC_MASK), %l4
        sethi   %hi(ZV_MASK1), %l5
        or      %l5, %lo(ZV_MASK1), %l5
        rd      %psr, %g3
        andn    %g3, %l4, %g3
        or      %g3, %l5, %g3
        wr      %g3, %psr

        srl     %l3, 1, %l3

        ! Instruction should not have cleared Z or N
        bne     .LFAIL
        nop
        bpos    .LFAIL
        nop
        
        !!!!!!! SRA !!!!!!!
        sethi   %hi(RESULT2), %l2
        or      %l2, %lo(RESULT2), %l2
        sethi   %hi(NUM2), %l4
        or      %l4, %lo(NUM2), %l4
        sra     %l4, 8, %l3

        ! Check result
        cmp     %l2, %l3
        bne     .LFAIL
        nop

        sra     %l3, 0, %l3

        ! Check result
        cmp     %l2, %l3
        bne     .LFAIL
        nop

        ! Set CC to be 0x4 (N=0 and Z=1)
        sethi   %hi(CC_MASK), %l4
        or      %l4, %lo(CC_MASK), %l4
        sethi   %hi(ZV_MASK2), %l5
        or      %l5, %lo(ZV_MASK2), %l5
        rd      %psr, %g3
        andn    %g3, %l4, %g3
        or      %g3, %l5, %g3
        wr      %g3, %psr

        sra     %l3, 1, %l3

        ! Instruction should not have cleared Z or set N
        bne     .LFAIL
        nop
        bneg    .LFAIL
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

