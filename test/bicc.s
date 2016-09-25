! ========================================
!  $Id: bicc.s,v 1.1 2013/06/25 18:30:59 simon Exp $
!  $Source: /home/simon/CVS/src/cpu/sparc/test/bicc.s,v $
! ========================================
        .file "bicc.s"
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

        !!!!!!! BA !!!!!!!
        mov     0, %g6
        ba      .LBRANCH1
        inc     %g6

.LRETURN1:
        cmp     %g6,2
        bne     .LFAIL
        nop

        mov     0, %g6
        ba,a    .LBRANCH2
        inc     %g6
.LRETURN2:
        cmp     %g6,1
        bne     .LFAIL
        nop


        !!!!!!! BN !!!!!!!
        mov     0, %g6
        bn      .LBRANCH1
        inc     %g6

        cmp     %g6, 1
        bne     .LFAIL
        nop

        bn,a    .LBRANCH1
        inc     %g6

        cmp     %g6, 1
        bne     .LFAIL
        nop

        !!!!!!! BNE !!!!!!!
        mov     0, %g6
        SetCC (0x4, %l5, %l6, %l7)

        bne     .LFAIL
        add     %g6, 10, %g6

        cmp     %g6, 10
        bne     .LFAIL
        nop

        mov     0, %g6
        SetCC (0x4, %l5, %l6, %l7)

        bne,a   .LFAIL
        add     %g6, 10, %g6

        cmp     %g6, 0
        bne     .LFAIL
        nop

        mov     0, %g6
        SetCC (0x0, %l5, %l6, %l7)

        bne     .LBRANCH3
        add     %g6, 10, %g6

.LRETURN3:
        cmp     %g6, 11
        bne     .LFAIL
        nop

        mov     0, %g6
        SetCC (0x0, %l5, %l6, %l7)

        bne,a   .LBRANCH4
        add     %g6, 10, %g6

.LRETURN4:
        cmp     %g6, 11
        bne     .LFAIL
        nop

        !!!!!!! BE !!!!!!!
        mov     0, %g6
        SetCC (0x0, %l5, %l6, %l7)

        be      .LFAIL
        add     %g6, 10, %g6

        cmp     %g6, 10
        bne     .LFAIL
        nop

        mov     0, %g6
        SetCC (0x0, %l5, %l6, %l7)

        be,a    .LFAIL
        add     %g6, 10, %g6

        cmp     %g6, 0
        bne     .LFAIL
        nop

        mov     0, %g6
        SetCC (0x4, %l5, %l6, %l7)

        be      .LBRANCH5
        add     %g6, 10, %g6

.LRETURN5:
        cmp     %g6, 11
        bne     .LFAIL
        nop

        mov     0, %g6
        SetCC (0x4, %l5, %l6, %l7)

        be,a    .LBRANCH6
        add     %g6, 10, %g6

.LRETURN6:
        cmp     %g6, 11
        bne     .LFAIL
        nop

        !!!!!!! BCC !!!!!!!
        mov     0, %g6
        SetCC (0x1, %l5, %l6, %l7)

        bcc     .LFAIL
        add     %g6, 10, %g6

        cmp     %g6, 10
        bne     .LFAIL
        nop

        mov     0, %g6
        SetCC (0x1, %l5, %l6, %l7)

        bcc,a   .LFAIL
        add     %g6, 10, %g6

        cmp     %g6, 0
        bne     .LFAIL
        nop

        mov     0, %g6
        SetCC (0x0, %l5, %l6, %l7)

        bcc     .LBRANCH7
        add     %g6, 10, %g6

.LRETURN7:
        cmp     %g6, 11
        bne     .LFAIL
        nop

        mov     0, %g6
        SetCC (0x0, %l5, %l6, %l7)

        bcc,a   .LBRANCH8
        add     %g6, 10, %g6

.LRETURN8:
        cmp     %g6, 11
        bne     .LFAIL
        nop

        !!!!!!! BCS !!!!!!!
        mov     0, %g6
        SetCC (0x0, %l5, %l6, %l7)

        bcs     .LFAIL
        add     %g6, 10, %g6

        cmp     %g6, 10
        bne     .LFAIL
        nop

        mov     0, %g6
        SetCC (0x0, %l5, %l6, %l7)

        bcs,a   .LFAIL
        add     %g6, 10, %g6

        cmp     %g6, 0
        bne     .LFAIL
        nop

        mov     0, %g6
        SetCC (0x1, %l5, %l6, %l7)

        bcs     .LBRANCH9
        add     %g6, 10, %g6

.LRETURN9:
        cmp     %g6, 11
        bne     .LFAIL
        nop

        mov     0, %g6
        SetCC (0x1, %l5, %l6, %l7)

        bcs,a   .LBRANCH10
        add     %g6, 10, %g6

.LRETURN10:
        cmp     %g6, 11
        bne     .LFAIL
        nop

        !!!!!!! BVC !!!!!!!
        mov     0, %g6
        SetCC (0x2, %l5, %l6, %l7)

        bvc     .LFAIL
        add     %g6, 10, %g6

        cmp     %g6, 10
        bne     .LFAIL
        nop

        mov     0, %g6
        SetCC (0x2, %l5, %l6, %l7)

        bvc,a   .LFAIL
        add     %g6, 10, %g6

        cmp     %g6, 0
        bne     .LFAIL
        nop

        mov     0, %g6
        SetCC (0x0, %l5, %l6, %l7)

        bvc     .LBRANCH11
        add     %g6, 10, %g6

.LRETURN11:
        cmp     %g6, 11
        bne     .LFAIL
        nop

        mov     0, %g6
        SetCC (0x0, %l5, %l6, %l7)

        bvc,a   .LBRANCH12
        add     %g6, 10, %g6

.LRETURN12:
        cmp     %g6, 11
        bne     .LFAIL
        nop

        !!!!!!! BVS !!!!!!!
        mov     0, %g6
        SetCC (0x0, %l5, %l6, %l7)

        bvs     .LFAIL
        add     %g6, 10, %g6

        cmp     %g6, 10
        bne     .LFAIL
        nop

        mov     0, %g6
        SetCC (0x0, %l5, %l6, %l7)

        bvs,a   .LFAIL
        add     %g6, 10, %g6

        cmp     %g6, 0
        bne     .LFAIL
        nop

        mov     0, %g6
        SetCC (0x2, %l5, %l6, %l7)

        bvs     .LBRANCH13
        add     %g6, 10, %g6

.LRETURN13:
        cmp     %g6, 11
        bne     .LFAIL
        nop

        mov     0, %g6
        SetCC (0x2, %l5, %l6, %l7)

        bvs,a   .LBRANCH14
        add     %g6, 10, %g6

.LRETURN14:
        cmp     %g6, 11
        bne     .LFAIL
        nop

        !!!!!!! BPOS !!!!!!!
        mov     0, %g6
        SetCC (0x8, %l5, %l6, %l7)

        bpos    .LFAIL
        add     %g6, 10, %g6

        cmp     %g6, 10
        bne     .LFAIL
        nop

        mov     0, %g6
        SetCC (0x8, %l5, %l6, %l7)

        bpos,a  .LFAIL
        add     %g6, 10, %g6

        cmp     %g6, 0
        bne     .LFAIL
        nop

        mov     0, %g6
        SetCC (0x0, %l5, %l6, %l7)

        bpos    .LBRANCH15
        add     %g6, 10, %g6

.LRETURN15:
        cmp     %g6, 11
        bne     .LFAIL
        nop

        mov     0, %g6
        SetCC (0x0, %l5, %l6, %l7)

        bpos,a  .LBRANCH16
        add     %g6, 10, %g6

.LRETURN16:
        cmp     %g6, 11
        bne     .LFAIL
        nop

        !!!!!!! BNEG !!!!!!!
        mov     0, %g6
        SetCC (0x0, %l5, %l6, %l7)

        bneg    .LFAIL
        add     %g6, 10, %g6

        cmp     %g6, 10
        bne     .LFAIL
        nop

        mov     0, %g6
        SetCC (0x0, %l5, %l6, %l7)

        bneg,a  .LFAIL
        add     %g6, 10, %g6

        cmp     %g6, 0
        bne     .LFAIL
        nop

        mov     0, %g6
        SetCC (0x8, %l5, %l6, %l7)

        bneg    .LBRANCH17
        add     %g6, 10, %g6

.LRETURN17:
        cmp     %g6, 11
        bne     .LFAIL
        nop

        mov     0, %g6
        SetCC (0x8, %l5, %l6, %l7)

        bneg,a  .LBRANCH18
        add     %g6, 10, %g6

.LRETURN18:
        cmp     %g6, 11
        bne     .LFAIL
        nop

        !!!!!!! BG !!!!!!!
        mov     0, %g6
        mov     9, %g5
        cmp     %g5, 10

        bg      .LFAIL
        add     %g6, 10, %g6

        cmp     %g6, 10
        bne     .LFAIL
        nop

        mov     0, %g6
        mov     10, %g5
        cmp     %g5,10

        bg,a    .LFAIL
        add     %g6, 10, %g6

        cmp     %g6, 0
        bne     .LFAIL
        nop

        mov     0, %g6
        mov     11, %g5
        cmp     %g5, 10

        bg      .LBRANCH19
        add     %g6, 10, %g6

.LRETURN19:
        cmp     %g6, 11
        bne     .LFAIL
        nop

        mov     0, %g6
        mov     12, %g5
        cmp     %g5,10

        bg,a    .LBRANCH20
        add     %g6, 10, %g6

.LRETURN20:
        cmp     %g6, 11
        bne     .LFAIL
        nop

        !!!!!!! BLE !!!!!!!
        mov     0, %g6
        mov     12, %g5
        cmp     %g5, 10

        ble     .LFAIL
        add     %g6, 10, %g6

        cmp     %g6, 10
        bne     .LFAIL
        nop

        mov     0, %g6
        mov     11, %g5
        cmp     %g5, 10

        ble,a   .LFAIL
        add     %g6, 10, %g6

        cmp     %g6, 0
        bne     .LFAIL
        nop

        mov     0, %g6
        mov     10, %g5
        cmp     %g5, 10

        ble     .LBRANCH21
        add     %g6, 10, %g6

.LRETURN21:
        cmp     %g6, 11
        bne     .LFAIL
        nop

        mov     0, %g6
        mov     9, %g5
        cmp     %g5, 10

        ble,a   .LBRANCH22
        add     %g6, 10, %g6

.LRETURN22:
        cmp     %g6, 11
        bne     .LFAIL
        nop

        !!!!!!! BGE !!!!!!!
        mov     0, %g6
        mov     8, %g5
        cmp     %g5, 10

        bge     .LFAIL
        add     %g6, 10, %g6

        cmp     %g6, 10
        bne     .LFAIL
        nop

        mov     0, %g6
        mov     9, %g5
        cmp     %g5, 10

        bge,a   .LFAIL
        add     %g6, 10, %g6

        cmp     %g6, 0
        bne     .LFAIL
        nop

        mov     0, %g6
        mov     10, %g5
        cmp     %g5, 10

        bge     .LBRANCH23
        add     %g6, 10, %g6

.LRETURN23:
        cmp     %g6, 11
        bne     .LFAIL
        nop

        mov     0, %g6
        mov     11, %g5
        cmp     %g5, 10

        bge,a   .LBRANCH24
        add     %g6, 10, %g6

.LRETURN24:
        cmp     %g6, 11
        bne     .LFAIL
        nop

        !!!!!!! BL !!!!!!!
        mov     0, %g6
        mov     11, %g5
        cmp     %g5, 10

        bl      .LFAIL
        add     %g6, 10, %g6

        cmp     %g6, 10
        bne     .LFAIL
        nop

        mov     0, %g6
        mov     10, %g5
        cmp     %g5, 10

        bl,a    .LFAIL
        add     %g6, 10, %g6

        cmp     %g6, 0
        bne     .LFAIL
        nop

        mov     0, %g6
        mov     9, %g5
        cmp     %g5, 10

        bl      .LBRANCH25
        add     %g6, 10, %g6

.LRETURN25:
        cmp     %g6, 11
        bne     .LFAIL
        nop

        mov     0, %g6
        mov     8, %g5
        cmp     %g5, 10

        bl,a    .LBRANCH26
        add     %g6, 10, %g6

.LRETURN26:
        cmp     %g6, 11
        bne     .LFAIL
        nop

        !!!!!!! BGU !!!!!!!
        mov     0, %g6
        SetCC (0x1, %l5, %l6, %l7)

        bgu     .LFAIL
        add     %g6, 10, %g6

        cmp     %g6, 10
        bne     .LFAIL
        nop

        mov     0, %g6
        SetCC (0x4, %l5, %l6, %l7)

        bgu,a   .LFAIL
        add     %g6, 10, %g6

        cmp     %g6, 0
        bne     .LFAIL
        nop

        mov     0, %g6
        SetCC (0x0, %l5, %l6, %l7)

        bgu     .LBRANCH27
        add     %g6, 10, %g6

.LRETURN27:
        cmp     %g6, 11
        bne     .LFAIL
        nop

        mov     0, %g6
        SetCC (0x0, %l5, %l6, %l7)

        bgu,a   .LBRANCH28
        add     %g6, 10, %g6

.LRETURN28:
        cmp     %g6, 11
        bne     .LFAIL
        nop

        !!!!!!! BLEU !!!!!!!
        mov     0, %g6
        SetCC (0x0, %l5, %l6, %l7)

        bleu    .LFAIL
        add     %g6, 10, %g6

        cmp     %g6, 10
        bne     .LFAIL
        nop

        mov     0, %g6
        SetCC (0x0, %l5, %l6, %l7)

        bleu,a  .LFAIL
        add     %g6, 10, %g6

        cmp     %g6, 0
        bne     .LFAIL
        nop

        mov     0, %g6
        SetCC (0x1, %l5, %l6, %l7)

        bleu    .LBRANCH29
        add     %g6, 10, %g6

.LRETURN29:
        cmp     %g6, 11
        bne     .LFAIL
        nop

        mov     0, %g6
        SetCC (0x4, %l5, %l6, %l7)

        bleu,a  .LBRANCH30
        add     %g6, 10, %g6

.LRETURN30:
        cmp     %g6, 11
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

.LBRANCH1:
        ba      .LRETURN1
        inc     %g6

.LBRANCH2:
        inc     %g6
        ba      .LRETURN2
        nop

.LBRANCH3:
        ba      .LRETURN3
        inc     %g6

.LBRANCH4:
        ba      .LRETURN4
        inc     %g6

.LBRANCH5:
        ba      .LRETURN5
        inc     %g6

.LBRANCH6:
        ba      .LRETURN6
        inc     %g6

.LBRANCH7:
        ba      .LRETURN7
        inc     %g6

.LBRANCH8:
        ba      .LRETURN8
        inc     %g6

.LBRANCH9:
        ba      .LRETURN9
        inc     %g6

.LBRANCH10:
        ba      .LRETURN10
        inc     %g6

.LBRANCH11:
        ba      .LRETURN11
        inc     %g6

.LBRANCH12:
        ba      .LRETURN12
        inc     %g6

.LBRANCH13:
        ba      .LRETURN13
        inc     %g6

.LBRANCH14:
        ba      .LRETURN14
        inc     %g6

.LBRANCH15:
        ba      .LRETURN15
        inc     %g6

.LBRANCH16:
        ba      .LRETURN16
        inc     %g6

.LBRANCH17:
        ba      .LRETURN17
        inc     %g6

.LBRANCH18:
        ba      .LRETURN18
        inc     %g6

.LBRANCH19:
        ba      .LRETURN19
        inc     %g6

.LBRANCH20:
        ba      .LRETURN20
        inc     %g6

.LBRANCH21:
        ba      .LRETURN21
        inc     %g6

.LBRANCH22:
        ba      .LRETURN22
        inc     %g6

.LBRANCH23:
        ba      .LRETURN23
        inc     %g6

.LBRANCH24:
        ba      .LRETURN24
        inc     %g6

.LBRANCH25:
        ba      .LRETURN25
        inc     %g6

.LBRANCH26:
        ba      .LRETURN26
        inc     %g6

.LBRANCH27:
        ba      .LRETURN27
        inc     %g6

.LBRANCH28:
        ba      .LRETURN28
        inc     %g6

.LBRANCH29:
        ba      .LRETURN29
        inc     %g6

.LBRANCH30:
        ba      .LRETURN30
        inc     %g6

        .type   main, #function
        .size   main, (.-main)

