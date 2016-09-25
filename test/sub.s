! ========================================
!  $Id: sub.s,v 1.1 2013/06/25 18:30:55 simon Exp $
!  $Source: /home/simon/CVS/src/cpu/sparc/test/sub.s,v $
! ========================================
        .file "sub.s"
        .section ".text"

! ----------------------------------------
#define GOOD    0x900d
#define BAD     0xbad

#define NUM1    0x99999999
#define NUM2    0x12345678
#define RESULT1 0x87654321

#define RESULT2 0x87654320

#define CC_MASK  0x00f00000
#define ZV_MASK1 0x00c00000
#define ZV_MASK2 0x00700000

        .global main
        .align 4

main:

        save    %sp, -96, %sp 

        mov     0, %g7

        !!!!!!! SUB !!!!!!!
        
        sethi   %hi(NUM1), %l0
        or      %l0, %lo(NUM1), %l0
        sethi   %hi(NUM2), %l1
        or      %l1, %lo(NUM2), %l1
        sethi   %hi(RESULT1), %l2
        or      %l2, %lo(RESULT1), %l2

        ! Set CC to be 0x7 (N=0 and V,C,Z=1)
        sethi   %hi(CC_MASK), %l4
        or      %l4, %lo(CC_MASK), %l4
        sethi   %hi(ZV_MASK2), %l5
        or      %l5, %lo(ZV_MASK2), %l5
        rd      %psr, %g3
        andn    %g3, %l4, %g3
        or      %g3, %l5, %g3
        wr      %g3, %psr

        sub     %l0, %l1, %l3

        ! Instruction should not have cleared Z, V, C or set N
        bne     .LFAIL
        nop
        bvc     .LFAIL
        nop
        bcc     .LFAIL
        nop
        bneg    .LFAIL
        nop
        
        ! Check result
        cmp     %l2, %l3
        bne     .LFAIL
        nop

        !!!!!!! SUBcc !!!!!!!
        
        sethi   %hi(NUM1), %l0
        or      %l0, %lo(NUM1), %l0
        sethi   %hi(NUM2), %l1
        or      %l1, %lo(NUM2), %l1
        sethi   %hi(RESULT1), %l2
        or      %l2, %lo(RESULT1), %l2

        ! Set CC to be 0x5 (N=0,V=0 and Z=1, C=1)
        sethi   %hi(CC_MASK), %l4
        or      %l4, %lo(CC_MASK), %l4
        sethi   %hi(ZV_MASK2), %l5
        or      %l5, %lo(ZV_MASK2), %l5
        rd      %psr, %g3
        andn    %g3, %l4, %g3
        or      %g3, %l5, %g3
        wr      %g3, %psr

        subcc   %l0, %l1, %l3

        ! Instruction should have cleared Z, V, C and set N
        be      .LFAIL
        nop
        bvs     .LFAIL
        nop
        bcs     .LFAIL
        nop
        bpos    .LFAIL
        nop
        
        ! Check result
        cmp     %l2, %l3
        bne     .LFAIL
        nop

        ! Carry Overflow
        sethi   %hi(0x0fffffff), %l0
        or      %l0, %lo(0x0fffffff), %l0
        sethi   %hi(0x80000000), %l1
        or      %l1, %lo(0x80000000), %l1

        subcc   %l0, %l1, %l3

        bvc     .LFAIL
        nop
        bcc     .LFAIL
        nop

        !!!!!!! SUBX !!!!!!!
        
        sethi   %hi(NUM1), %l0
        or      %l0, %lo(NUM1), %l0
        sethi   %hi(NUM2), %l1
        or      %l1, %lo(NUM2), %l1
        sethi   %hi(RESULT2), %l2
        or      %l2, %lo(RESULT2), %l2

        ! Set CC to be 0x5 (N=0, V=0 and Z=1, C=1)
        sethi   %hi(CC_MASK), %l4
        or      %l4, %lo(CC_MASK), %l4
        sethi   %hi(ZV_MASK2), %l5
        or      %l5, %lo(ZV_MASK2), %l5
        rd      %psr, %g3
        andn    %g3, %l4, %g3
        or      %g3, %l5, %g3
        wr      %g3, %psr

        subx    %l0, %l1, %l3

        ! Instruction should not have cleared Z, C or set N
        bne     .LFAIL
        nop
        bcc     .LFAIL
        nop
        bneg    .LFAIL
        nop
        
        ! Check result
        cmp     %l2, %l3
        bne     .LFAIL
        nop

        !!!!!!! SUBXcc !!!!!!!
        
        sethi   %hi(NUM1), %l0
        or      %l0, %lo(NUM1), %l0
        sethi   %hi(NUM2), %l1
        or      %l1, %lo(NUM2), %l1
        sethi   %hi(RESULT2), %l2
        or      %l2, %lo(RESULT2), %l2

        ! Set CC to be 0x5 (N=0, V=0 and Z=1, C=1)
        sethi   %hi(CC_MASK), %l4
        or      %l4, %lo(CC_MASK), %l4
        sethi   %hi(ZV_MASK2), %l5
        or      %l5, %lo(ZV_MASK2), %l5
        rd      %psr, %g3
        andn    %g3, %l4, %g3
        or      %g3, %l5, %g3
        wr      %g3, %psr

        subxcc  %l0, %l1, %l3

        ! Instruction should have cleared Z, C and set N
        be      .LFAIL
        nop
        bcs     .LFAIL
        nop
        bpos    .LFAIL
        nop
        
        ! Check result
        cmp     %l2, %l3
        bne     .LFAIL
        nop

        ! Carry Overflow
        sethi   %hi(0x0fffffff), %l0
        or      %l0, %lo(0x0fffffff), %l0
        sethi   %hi(0x80000000), %l1
        or      %l1, %lo(0x80000000), %l1

        subxcc  %l0, %l1, %l3

        bvc     .LFAIL
        nop
        bcc     .LFAIL
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

