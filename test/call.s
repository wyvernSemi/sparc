! ========================================
!  $Id: call.s,v 1.1 2013/06/25 18:30:58 simon Exp $
!  $Source: /home/simon/CVS/src/cpu/sparc/test/call.s,v $
! ========================================
        .file "call.s"
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

.LCALLOPADDR:
        call    calltarget
        mov     0, %g6

        cmp     %g6, 1
        bne     .LFAIL
        nop

        cmp     %l0, %g4
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

        .local calltarget
        .align 4

calltarget:
        save    %sp, -96, %sp 
        mov     %i7, %g4
        inc     %g6
        ret     
        restore

        .type   calltarget, #function
        .size   calltarget, (.-main)

