//=============================================================
// 
// Copyright (c) 2004 Simon Southwell
//
// Date: 13th October 2004
//
// This file is part of sparc_iss.
//
// sparc_iss is free software: you can redistribute it and/or modify
// it under the terms of the GNU General Public License as published by
// the Free Software Foundation, either version 3 of the License, or
// (at your option) any later version.
//
// sparc_iss is distributed in the hope that it will be useful,
// but WITHOUT ANY WARRANTY; without even the implied warranty of
// MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
// GNU General Public License for more details.
//
// You should have received a copy of the GNU General Public License
// along with sparc_iss. If not, see <http://www.gnu.org/licenses/>.
//
// $Id: sparc.h,v 1.3 2013-06-29 08:57:39 simon Exp $
// $Source: /home/simon/CVS/src/cpu/sparc/src/sparc.h,v $
//
//=============================================================

#ifndef _SPARC_H_
#define _SPARC_H_

#include <stdio.h>
#include "sparc_iss.h"

#define NWINDOWS                           16

#define SPARC_SOFTWARE_RESET               0x00
#define SPARC_INSTRUCTION_ACCESS_EXCEPTION 0x01
#define SPARC_ILLEGAL_INSTRUCTION          0x02
#define SPARC_PRIVILEGED_INSTRUCTION       0x03
#define SPARC_FP_DISABLED                  0x04
#define SPARC_WINDOW_OVERFLOW              0x05
#define SPARC_WINDOW_UNDERFLOW             0x06
#define SPARC_MEMORY_ADDR_NOT_ALIGNED      0x07
#define SPARC_FP_EXCEPTION                 0x08
#define SPARC_DATA_ACCESS_EXCEPTION        0x09
#define SPARC_TAG_OVERFLOW                 0x0a
#define SPARC_WATCHPOINT_DETECT            0x0b
#define SPARC_R_REGISTER_ACCESS_ERROR      0x20
#define SPARC_INSTRUCTION_ACCESS_ERROR     0x21
#define SPARC_CP_DISABLED                  0x24
#define SPARC_UNIMPLEMENTED_FLUSH          0x25
#define SPARC_CP_EXCEPTION                 0x28
#define SPARC_DATA_ACCESS_ERROR            0x29
#define SPARC_DIVISION_BY_ZERO             0x2A
#define SPARC_DATA_STORE_ERROR             0x2B
#define SPARC_DATA_ACCESS_MMU_MISS         0x2C
#define SPARC_INSTRUCTION_ACCESS_MMU_MISS  0x3C

#define SPARC_INTERRUPT                    0x10 
#define SPARC_TRAP_INSTRUCTION             0x80

#define CC_NEGATIVE                        3
#define CC_ZERO                            2
#define CC_OVERFLOW                        1
#define CC_CARRY                           0

#define PSR_ENABLE_TRAPS                   5
#define PSR_PREV_SUPER_MODE                6
#define PSR_SUPER_MODE                     7
#define PSR_INTERRUPT_LEVEL_0              8
#define PSR_INTERRUPT_LEVEL_3              11

#define PSR_CC_NEGATIVE                    23
#define PSR_CC_ZERO                        22
#define PSR_CC_OVERFLOW                    21
#define PSR_CC_CARRY                       20

#define INREG7             0x1f
#define INREG6             0x1e
#define INREG5             0x1d
#define INREG4             0x1c
#define INREG3             0x1b
#define INREG2             0x1a
#define INREG1             0x19
#define INREG0             0x18
#define LOCALREG7          0x17
#define LOCALREG6          0x16
#define LOCALREG5          0x15
#define LOCALREG4          0x14
#define LOCALREG3          0x13
#define LOCALREG2          0x12
#define LOCALREG1          0x11
#define LOCALREG0          0x10
#define OUTREG7            0x0f
#define OUTREG6            0x0e
#define OUTREG5            0x0d
#define OUTREG4            0x0c
#define OUTREG3            0x0b
#define OUTREG2            0x0a
#define OUTREG1            0x09
#define OUTREG0            0x08
#define GLOBALREG7         0x07
#define GLOBALREG6         0x06
#define GLOBALREG5         0x05
#define GLOBALREG4         0x04
#define GLOBALREG3         0x03
#define GLOBALREG2         0x02
#define GLOBALREG1         0x01
#define GLOBALREG0         0x00

#define MEM_SIZE_BITS      (uint64)23
#define ADDR_MASK          (((uint64)1 << MEM_SIZE_BITS)-(uint64)1)
#define LOBITS1            0x01
#define LOBITS2            0x03
#define LOBITS3            0x07
#define LOBITS4            0x0f
#define LOBITS5            0x1f
#define LOBITS6            0x3f
#define LOBITS7            0x7f
#define LOBITS8            0xff
#define LOBITS13           0x1fff
#define LOBITS16           0xffff
#define LOBITS22           0x3fffff
#define LOBITS30           0x3fffffff

#define LOWORDMASK         0xffffffff
#define LOHWORDMASK        0x0000ffff

#define BIT0               0x00000001
#define BIT1               0x00000002
#define BIT2               0x00000004
#define BIT3               0x00000008
#define BIT4               0x00000010
#define BIT5               0x00000020
#define BIT6               0x00000040
#define BIT7               0x00000080
#define BIT8               0x00000100
#define BIT9               0x00000200
#define BIT10              0x00000400
#define BIT11              0x00000800
#define BIT12              0x00001000
#define BIT13              0x00002000
#define BIT14              0x00004000
#define BIT15              0x00008000
#define BIT16              0x00010000
#define BIT17              0x00020000
#define BIT18              0x00040000
#define BIT19              0x00080000
#define BIT20              0x00100000
#define BIT21              0x00200000
#define BIT22              0x00400000
#define BIT23              0x00800000
#define BIT24              0x01000000
#define BIT25              0x02000000
#define BIT26              0x04000000
#define BIT27              0x08000000
#define BIT28              0x10000000
#define BIT29              0x20000000
#define BIT30              0x40000000
#define BIT31              0x80000000

#define FMTSTARTBIT        30
#define RDSTARTBIT         25
#define OP2STARTBIT        22
#define OP3STARTBIT        19
#define RS1STARTBIT        14
#define ISTARTBIT          13
#define RS2STARTBIT        0

#define TERMINATE_INST     0x00000000
#define NOP                0x01000000

#define GLOBALREG8         0x108

#define sign_ext22(_ARG) (_ARG | ((_ARG & (1 << 21)) ? 0xffc00000 : 0))
#define sign_ext13(_ARG) (_ARG | ((_ARG & (1 << 12)) ? 0xffffe000 : 0))
#define sign_ext7(_ARG)  (_ARG | ((_ARG & (1 << 6))  ? 0xffffff80 : 0))

// Map instructions to common functions
#define ANDCC              AND
#define ANDN               AND
#define ANDNCC             AND
#define OR                 AND
#define ORCC               AND
#define ORN                AND
#define ORNCC              AND
#define XOR                AND
#define XORCC              AND
#define XNOR               AND
#define XNORCC             AND
#define ADDCC              ADD
#define ADDX               ADD
#define ADDXCC             ADD
#define TADDCC             ADD
#define TADDCCTV           ADD
#define SUB                ADD
#define SUBCC              ADD
#define SUBX               ADD
#define SUBXCC             ADD
#define TSUBCC             ADD
#define TSUBCCTV           ADD
#define UMUL               MUL
#define UMULCC             MUL
#define SMUL               MUL
#define SMULCC             MUL
#define UDIV               DIV
#define SDIV               DIV
#define UDIVCC             DIV
#define SDIVCC             DIV

// Point all the unimplemented instructions to the UNIMP function
#define LDSBA              UNIMP
#define LDSHA              UNIMP
#define LDUBA              UNIMP
#define LDUHA              UNIMP
#define LDA                UNIMP
#define LDDA               UNIMP
#define STBA               UNIMP
#define STHA               UNIMP
#define STA                UNIMP
#define STDA               UNIMP
#define LDSTUBA            UNIMP
#define SWAPA              UNIMP
#define LDF                UNIMP
#define LDDF               UNIMP
#define LDFSR              UNIMP
#define STF                UNIMP
#define STDF               UNIMP
#define STFSR              UNIMP
#define STDFQ              UNIMP
#define FBFCC              UNIMP
#define FPOP1              UNIMP
#define FPOP2              UNIMP
#define LDC                UNIMP
#define LDDC               UNIMP
#define LDCSR              UNIMP
#define STC                UNIMP
#define STDC               UNIMP
#define STCSR              UNIMP
#define STDCQ              UNIMP
#define CBCCC              UNIMP
#define CPOP1              UNIMP
#define CPOP2              UNIMP

#define FIRST_RS1_EVAL_IDX 56
#define TICC_IDX           58
#define STORE_DBL_IDX      71

#define NO_WRITEBACK       0
#define WRITEBACKREG       1

// Defer structure definition
struct  DecodeStruct;

typedef struct DecodeStruct *pDecode_t;
typedef void (*p_func) (pDecode_t);

#if defined( __CYGWIN__) || defined(WIN32) || defined(__x86_64__) || defined(_M_X64) || defined(__i386) || defined(_M_IX86)
typedef struct {
    unsigned int cwp : 5;       // Current window pointer
    unsigned int et  : 1;       // Enable traps
    unsigned int ps  : 1;       // Previous supervisor mode
    unsigned int s   : 1;       // Supervisor mode
    unsigned int pil : 4;       // Proc interrupt level
    unsigned int ef  : 1;       // FPU enable
    unsigned int ec  : 1;       // Co-processor enable
    unsigned int rsv2: 2;       // Reserved
    unsigned int rsv1: 4;       // Reserved
    unsigned int c   : 1;       // Carry
    unsigned int v   : 1;       // Overflow
    unsigned int z   : 1;       // Zero
    unsigned int n   : 1;       // Negative 
    unsigned int ver : 4;       // Version
    unsigned int imp : 4;       // Implementation


} PSR_t, *pPSR_t;
#else
typedef struct {
    unsigned int imp : 4;       // Implementation
    unsigned int ver : 4;       // Version
    unsigned int n   : 1;       // Negative 
    unsigned int z   : 1;       // Zero
    unsigned int v   : 1;       // Overflow
    unsigned int c   : 1;       // Carry
    unsigned int rsv : 6;       // Reserved
    unsigned int ec  : 1;       // Co-processor enable
    unsigned int ef  : 1;       // FPU enable
    unsigned int pil : 4;       // Proc interrupt level
    unsigned int s   : 1;       // Supervisor mode
    unsigned int ps  : 1;       // Previous supervisor mode
    unsigned int et  : 1;       // Enable traps
    unsigned int cwp : 5;       // Current window pointer
} PSR_t, *pPSR_t;
#endif

struct DecodeStruct {
    uint32 opcode;              // Instruction opcode
    p_func function;            // Pointer to inst.c function
    uint32 rd;                  // rd register number
    uint32 rs1;                 // rs1 register number
    uint32 rs1_value;           // rs1 register value
    uint32 imm_disp_rs2;        // Immediate, displacement or rs2 
    uint32 ev;                  // Extended value (ev) = r[rs1] + (i ? sign_ext(imm) : r[rs2])
    uint32 op_2_3;              // op2 or op3 value
    uint32 i;                   // i, imm/rs2 indicator

    uint32 PC;                  // Current program counter value
    uint32 nPC;                 // Next program counter value
    uint32 PSR;                 // Program status register value
    pPSR_t p;                   // Pointer to structured version of PSR
    uint32 wb_type;             // Write back flag
    uint32 value;               // Write back value
    uint32 value1;              // Second (optional) write back value
};

extern int             Verbose;
extern int             Disassemble;
extern int             terminate;
extern uint32          BreakPoint;
extern uint32          *pSwapReg;
extern p_memcallback_t pMemCallback;

// Function prototypes

uint32 ReadElf       (const char *const);
uint64 disRun        (const uint32);
uint32 GetnPC        (void);
uint32 GetPSR        (void);
uint32 GetIRL        (void);

void   LoadMemWord   (const uint64, const uint32);
uint32 MemRead       (const uint64, const int, const uint32, const int);
void   MemWrite      (const uint64, const int, const uint32);
void   ReadReg       (const uint32, uint32 *const);
void   WriteReg      (const uint32, const uint32);
void   Ifetch        (const uint64, uint32 *const);
void   RegisterDump  (void);

#endif


