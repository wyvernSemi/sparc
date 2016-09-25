! ========================================
!  $Id: trap_table.s,v 1.1 2013/06/25 18:30:54 simon Exp $
!  $Source: /home/simon/CVS/src/cpu/sparc/test/trap_table.s,v $
! ========================================

#define ENTRY(x) .section  ".text"; \
                 .align 4; \
                 .global x; \
x:

#define STACK_ALIGN     8
#define SA(X)           (((X) + (STACK_ALIGN-1)) & ~(STACK_ALIGN-1))
#define WINDOWSIZE      (16*4)
#define ARGPUSHSIZE     (6*4)
#define MINFRAME        SA(WINDOWSIZE+ARGPUSHSIZE+4)  

#define PSR_CWP         0x0000001F      /* current window pointer */
#define PSR_ET          0x00000020      /* enable traps */
#define PSR_PS          0x00000040      /* previous supervisor mode */
#define PSR_S           0x00000080      /* supervisor mode */
#define PSR_PIL         0x00000F00      /* processor interrupt level */
#define PSR_EF          0x00001000      /* enable floating point unit */
#define PSR_EC          0x00002000      /* enable coprocessor */
#define PSR_RSV         0x000FC000      /* reserved */
#define PSR_ICC         0x00F00000      /* integer condition codes */
#define PSR_C           0x00100000      /* carry bit */
#define PSR_V           0x00200000      /* overflow bit */
#define PSR_Z           0x00400000      /* zero bit */
#define PSR_N           0x00800000      /* negative bit */
#define PSR_VER         0x0F000000      /* mask version */
#define PSR_IMPL        0xF0000000      /* implementation */

        .section        ".data"
        .align          64
        .global kernel_stack_base
kernel_stack_base:      
        .skip           8192
        .global kernel_stack_top
kernel_stack_top:

/*
 * Macros for the trap table.
 */

#define TRAP(sym)          \
        rd      %psr, %l0; \
        rd      %tbr, %l3; \
        ba      sym;       \
        mov     %fp, %sp

#define BAD_TRAP TRAP(.LBADEXIT)

/*
 * Trap table
 */

        ENTRY(__trap_table)
        .type   __trap_table, #function
        .global _start;
_start: 
        TRAP            (__reset)               /*  0 SPARC_SOFTWARE_RESET */
        TRAP            (__trap1)               /*  1 SPARC_INSTRUCTION_ACCESS_EXCEPTION */
        TRAP            (__trap2)               /*  2 SPARC_ILLEGAL_INSTRUCTION */
        TRAP            (__trap3)               /*  3 SPARC_PRIVILEGED_INSTRUCTION */
        TRAP            (__trap4)               /*  4 SPARC_FP_DISABLED */
        TRAP            (__trap5)               /*  5 SPARC_WINDOW_OVERFLOW */
        TRAP            (__trap6)               /*  6 SPARC_WINDOW_UNDERFLOW */
        TRAP            (__trap7)               /*  7 SPARC_MEMORY_ADDR_NOT_ALIGNED */
        TRAP            (__trap8)               /*  8 SPARC_FP_EXCEPTION */
        TRAP            (__trap9)               /*  9 SPARC_DATA_ACCESS_EXCEPTION */
        TRAP            (__trap10)              /* 10 SPARC_TAG_OVERFLOW */
        TRAP            (__trap11)              /* 11 SPARC_WATCHPOINT_DETECT */
        BAD_TRAP; BAD_TRAP; BAD_TRAP; BAD_TRAP  /* 13-15 */

        BAD_TRAP; BAD_TRAP; BAD_TRAP; BAD_TRAP  /* 16-31 External interrupt request */
        BAD_TRAP; BAD_TRAP; BAD_TRAP; BAD_TRAP
        BAD_TRAP; BAD_TRAP; BAD_TRAP; BAD_TRAP
        BAD_TRAP; BAD_TRAP; BAD_TRAP; BAD_TRAP

        BAD_TRAP                                /* 32 SPARC_R_REGISTER_ACCESS_ERROR */
        BAD_TRAP                                /* 33 SPARC_INSTRUCTION_ACCESS_ERROR */
        BAD_TRAP                                /* 34 */
        BAD_TRAP                                /* 35 */
        BAD_TRAP                                /* 36 SPARC_CP_DISABLED */
        BAD_TRAP                                /* 37 SPARC_UNIMPLEMENTED_FLUSH */
        BAD_TRAP                                /* 38 */
        BAD_TRAP                                /* 39 */
        BAD_TRAP                                /* 40 SPARC_CP_EXCEPTION */
        BAD_TRAP                                /* 41 SPARC_DATA_ACCESS_ERROR */
        TRAP            (__trap42)              /* 42 SPARC_DIVISION_BY_ZERO */
        BAD_TRAP                                /* 43 SPARC_DATA_STORE_ERROR */
        BAD_TRAP                                /* 44 SPARC_DATA_ACCESS_MMU_MISS */
        BAD_TRAP                                /* 45 */
        BAD_TRAP                                /* 46 */
        BAD_TRAP                                /* 48 */
        
        BAD_TRAP; BAD_TRAP; BAD_TRAP; BAD_TRAP  /* 48-59 */
        BAD_TRAP; BAD_TRAP; BAD_TRAP; BAD_TRAP
        BAD_TRAP; BAD_TRAP; BAD_TRAP; BAD_TRAP
        BAD_TRAP                                /* 60 SPARC_INSTRUCTION_ACCESS_MMU_MISS */
        BAD_TRAP                                /* 61 */
        BAD_TRAP                                /* 62 */
        BAD_TRAP                                /* 63 */
        BAD_TRAP; BAD_TRAP; BAD_TRAP; BAD_TRAP  /* 64-95 */
        BAD_TRAP; BAD_TRAP; BAD_TRAP; BAD_TRAP
        BAD_TRAP; BAD_TRAP; BAD_TRAP; BAD_TRAP
        BAD_TRAP; BAD_TRAP; BAD_TRAP; BAD_TRAP
        BAD_TRAP; BAD_TRAP; BAD_TRAP; BAD_TRAP
        BAD_TRAP; BAD_TRAP; BAD_TRAP; BAD_TRAP
        BAD_TRAP; BAD_TRAP; BAD_TRAP; BAD_TRAP
        BAD_TRAP; BAD_TRAP; BAD_TRAP; BAD_TRAP

        BAD_TRAP; BAD_TRAP; BAD_TRAP; BAD_TRAP  /* 96-127 impl. dependent */
        BAD_TRAP; BAD_TRAP; BAD_TRAP; BAD_TRAP
        BAD_TRAP; BAD_TRAP; BAD_TRAP; BAD_TRAP
        BAD_TRAP; BAD_TRAP; BAD_TRAP; BAD_TRAP
        BAD_TRAP; BAD_TRAP; BAD_TRAP; BAD_TRAP
        BAD_TRAP; BAD_TRAP; BAD_TRAP; BAD_TRAP
        BAD_TRAP; BAD_TRAP; BAD_TRAP; BAD_TRAP
        BAD_TRAP; BAD_TRAP; BAD_TRAP; BAD_TRAP

sparc_ticc_traps:                               /* 128-256 software traps */
        TRAP (__trap128)
        TRAP (__trap129)
        TRAP (__trap130)
        TRAP (__trap131)
        BAD_TRAP; BAD_TRAP; BAD_TRAP; BAD_TRAP
        BAD_TRAP; BAD_TRAP; BAD_TRAP; BAD_TRAP
        BAD_TRAP; BAD_TRAP; BAD_TRAP; BAD_TRAP
        BAD_TRAP; BAD_TRAP; BAD_TRAP; BAD_TRAP
        BAD_TRAP; BAD_TRAP; BAD_TRAP; BAD_TRAP
        BAD_TRAP; BAD_TRAP; BAD_TRAP; BAD_TRAP
        BAD_TRAP; BAD_TRAP; BAD_TRAP; BAD_TRAP
        BAD_TRAP; BAD_TRAP; BAD_TRAP; BAD_TRAP
        BAD_TRAP; BAD_TRAP; BAD_TRAP; BAD_TRAP
        BAD_TRAP; BAD_TRAP; BAD_TRAP; BAD_TRAP
        BAD_TRAP; BAD_TRAP; BAD_TRAP; BAD_TRAP
        BAD_TRAP; BAD_TRAP; BAD_TRAP; BAD_TRAP
        BAD_TRAP; BAD_TRAP; BAD_TRAP; BAD_TRAP
        BAD_TRAP; BAD_TRAP; BAD_TRAP; BAD_TRAP
        BAD_TRAP; BAD_TRAP; BAD_TRAP; BAD_TRAP
        BAD_TRAP; BAD_TRAP; BAD_TRAP; BAD_TRAP
        BAD_TRAP; BAD_TRAP; BAD_TRAP; BAD_TRAP
        BAD_TRAP; BAD_TRAP; BAD_TRAP; BAD_TRAP
        BAD_TRAP; BAD_TRAP; BAD_TRAP; BAD_TRAP
        BAD_TRAP; BAD_TRAP; BAD_TRAP; BAD_TRAP
        BAD_TRAP; BAD_TRAP; BAD_TRAP; BAD_TRAP
        BAD_TRAP; BAD_TRAP; BAD_TRAP; BAD_TRAP
        BAD_TRAP; BAD_TRAP; BAD_TRAP; BAD_TRAP
        BAD_TRAP; BAD_TRAP; BAD_TRAP; BAD_TRAP
        BAD_TRAP; BAD_TRAP; BAD_TRAP; BAD_TRAP
        BAD_TRAP; BAD_TRAP; BAD_TRAP; BAD_TRAP
        BAD_TRAP; BAD_TRAP; BAD_TRAP; BAD_TRAP
        BAD_TRAP; BAD_TRAP; BAD_TRAP; BAD_TRAP
        BAD_TRAP; BAD_TRAP; BAD_TRAP; BAD_TRAP
        BAD_TRAP; BAD_TRAP; BAD_TRAP; BAD_TRAP
        BAD_TRAP; BAD_TRAP; BAD_TRAP; BAD_TRAP
        
__reset:
        ! set the initial WIN
        mov     0x02, %wim

        ! set the initial PSR
        set     PSR_S|PSR_PIL|PSR_ET, %g1
        mov     %g1, %psr                       ! initialise psr - supervisor, splmax

        ! set the trap base register
        set     __trap_table, %g1
        mov     %g1, %tbr

        ! now running in real virtual address space
        ! so setup the stack and call C startup
        set     kernel_stack_top, %sp
        sub     %sp, SA(MINFRAME), %sp

        call    startup
        nop

        ! now call main program
        call    main
        nop

        ! run the scheduler if it ever returns
        call    exit
        nop

__trap1:
        inc     %g6
        jmpl    %r18,%r0
        rett    %r18+4
        nop

__trap2:
        add     %g6, 2, %g6
        jmpl    %r18,%r0
        rett    %r18+4
        nop

__trap3:
        add     %g6, 3, %g6
        jmpl    %r18,%r0
        rett    %r18+4
        nop

__trap4:
        add     %g6, 4, %g6
        jmpl    %r18,%r0
        rett    %r18+4
        nop

__trap5:
        add     %g6, 5, %g6
        jmpl    %r18,%r0
        rett    %r18+4
        nop

__trap6:
        add     %g6, 6, %g6
        jmpl    %r18,%r0
        rett    %r18+4
        nop

__trap7:
        add     %g6, 7, %g6
        jmpl    %r18,%r0
        rett    %r18+4
        nop

__trap8:
        add     %g6, 8, %g6
        jmpl    %r18,%r0
        rett    %r18+4
        nop

__trap9:
        add     %g6, 9, %g6
        jmpl    %r18,%r0
        rett    %r18+4
        nop

__trap10:
        add     %g6, 10, %g6
        jmpl    %r18,%r0
        rett    %r18+4
        nop

__trap11:
        add     %g6, 11, %g6
        jmpl    %r18,%r0
        rett    %r18+4
        nop

__trap42:
        add     %g6, 42, %g6
        jmpl    %r18,%r0
        rett    %r18+4
        nop

__trap128:
        sub     %g6, 1, %g6
        jmpl    %r18,%r0
        rett    %r18+4
        nop

__trap129:
        inc     %g6
        jmpl    %r18,%r0
        rett    %r18+4
        nop

__trap130:
        add     %g6, 2, %g6
        jmpl    %r18,%r0
        rett    %r18+4
        nop

__trap131:
        add     %g6, 3, %g6
        jmpl    %r18,%r0
        rett    %r18+4
        nop

        .global exit
        .align 4

exit:
        mov   0xbad,%g2
        cmp   %g2,%g7
        be    .LBADEXIT
        nop
        .word 0x00000000
.LBADEXIT:
        .word 0x00000bad

