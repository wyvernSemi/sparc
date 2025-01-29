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
//=============================================================

#include "sparc.h"

uint32 TrapType;
uint32 TBR;
uint32 WIM;

static uint32 Y;

extern FILE *ofp;

static char rs1buf[5];
static char rs2buf[5];
static char rdbuf[5];

#define CalcCC(_cc, _val, _PSR) {                                            \
    _cc &= ~(1 << CC_OVERFLOW);                                              \
    _cc &= ~(1 << CC_CARRY);                                                 \
    _cc = (_cc & ~(1 << CC_ZERO))     | (((_val == 0) ? 1 : 0) << CC_ZERO);  \
    _cc = (_cc & ~(1 << CC_NEGATIVE)) | (((_val >> 31) & 1) << CC_NEGATIVE); \
    _PSR = (_PSR & ~(LOBITS4 << PSR_CC_CARRY)) | (_cc << PSR_CC_CARRY);      \
}

/////////////////////////
// ALU instruction labels
static char * OpByte[32] = {
   "add     ", "and     ", "or      ", "xor     ",
   "sub     ", "andn    ", "orn     ", "xnor    ",
   "addx    ", "unip    ", "umul    ", "smul    ",
   "subx    ", "unip    ", "udiv    ", "sdiv    ",
   "addcc   ", "andcc   ", "orcc    ", "xorcc   ",
   "subcc   ", "andncc  ", "orncc   ", "xnorcc  ",
   "addxcc  ", "unipcc  ", "umulcc  ", "smulcc  ",
   "subxcc  ", "unipcc  ", "udivcc  ", "sdivcc  "};

static char * CondByte [16] = {
   "n      ", "e      ", "le     ", "l       ",
   "leu    ", "cs     ", "neg    ", "vs      ",
   "a      ", "ne     ", "g      ", "ge      ",
   "gu     ", "cc     ", "pos    ", "vc      "
};

static char * TrapStr [64] = {
    "Software Reset",
    "Instruction Access Exception",
    "Illegal Instruction",
    "Privileged Instruction",
    "FP Disabled",
    "Window Overflow",
    "Window Underflow",
    "Memory Address not Aligned",
    "FP Exception",
    "Data Access Exception",
    "Tag Overflow",
    "Watchpoint Detect",
    "NO TRAP", "NO TRAP", "NO TRAP", "NO TRAP",
    "NO TRAP", "NO TRAP", "NO TRAP", "NO TRAP",
    "NO TRAP", "NO TRAP", "NO TRAP", "NO TRAP",
    "NO TRAP", "NO TRAP", "NO TRAP", "NO TRAP",
    "NO TRAP", "NO TRAP", "NO TRAP", "NO TRAP",
    "R Register Access Error",
    "Instruction Access Error",
    "NO TRAP",
    "NO TRAP",
    "CP Disabled",
    "Unimplemented Flush",
    "NO TRAP",
    "NO TRAP",
    "CP Exception",
    "Data Access Error",
    "Divide by Zero",
    "Data Store Error",
    "Data Access MMU Miss",
    "NO TRAP",
    "NO TRAP",
    "NO TRAP",
    "NO TRAP", "NO TRAP", "NO TRAP", "NO TRAP",
    "NO TRAP", "NO TRAP", "NO TRAP", "NO TRAP",
    "NO TRAP", "NO TRAP", "NO TRAP", "NO TRAP",
    "Instruction Access MMU Miss", 
    "NO TRAP", "NO TRAP", "NO TRAP"
};

// ------------------------------------------------
// DispRegStr()
//
// Returns a formatted string representing the register indexed by regnum.
// USed in verbose output only.
//
static char * DispRegStr (const uint32 regnum, char *buf) 
{
    switch ((regnum >> 3) & LOBITS2) {
    case 0: 
        sprintf(buf, "%%g%0d", regnum & LOBITS3);
        break;
    case 1: 
        sprintf(buf, "%%o%0d", regnum & LOBITS3);
        break;
    case 2: 
        sprintf(buf, "%%l%0d", regnum & LOBITS3);
        break;
    case 3: 
        sprintf(buf, "%%i%0d", regnum & LOBITS3);
    }

    return buf;
}

// ------------------------------------------------

static int TestCC (pDecode_t d) {

    int cond; 

    cond = d->rd & LOBITS4;

    switch (cond & LOBITS3) {
    case 0 :
        return (cond >> 3) & LOBITS1;
        break;
    case 1 :
        return ((cond >> 3) ^ d->p->z);
        break;
    case 2 :
        return ((cond >> 3) ^ (d->p->z | (d->p->n ^ d->p->v)));
        break;
    case 3 :
        return ((cond >> 3) ^ (d->p->n ^ d->p->v));
        break;
    case 4 :
        return ((cond >> 3) ^ (d->p->c | d->p->z));
        break;
    case 5 :
        return ((cond >> 3) ^ d->p->c);
        break;
    case 6 :
        return ((cond >> 3) ^ d->p->n);
        break;
    case 7 :
        return ((cond >> 3) ^ d->p->v);
        break;
    default:
        fprintf(stderr, "*** TestCC(): fatal error\n");
        exit(CODE_ERROR);
    }

    return 0;
}

// ------------------------------------------------

static void Trap (pDecode_t d, uint32 trap_no) 
{
    int tn = trap_no & LOBITS8;
    uint32 npc = (TBR & ~(0xff0)) | ((tn & LOBITS8) << 4);;

    if (d->p->et == 0) {
         fprintf (stderr, "ERROR TRAP %x WHILE TRAPS DISABLED\n", trap_no);
         RegisterDump();
         terminate = d->opcode;
         return;
    }

    if (Verbose) {
        if (tn < 0x40)
            fprintf (ofp, "                   TRAP %s (0x%x) PC=%08x NPC=%08x\n", TrapStr[tn], tn, d->PC, npc);
        else if (tn >= 0x40 && tn < 0x60)
            fprintf (ofp, "                   TRAP NO TRAP (0x%x) PC=%08x NPC=%08x\n", tn, d->PC, npc);
        else if (tn >= 0x60 && tn < 0x80)
            fprintf (ofp, "                   TRAP Impl. Dep. (0x%x) PC=%08x NPC=%08x\n", tn, d->PC, npc);
        else 
            fprintf (ofp, "                   TRAP Ticc (0x%x) PC=%08x NPC=%08x\n", tn, d->PC, npc);
    }

    TrapType = (TrapType & ~(LOBITS8)) | tn;
}

// ------------------------------------------------

void UNIMP (pDecode_t d)
{
    if (d->opcode != TERMINATE_INST) {
        fprintf(stderr, "*** Error: Unimplemented instruction.\n");
        RegisterDump();
        terminate = d->opcode;
    } else {
        if (Verbose)
            fprintf(ofp, "%08x unimp : Program exited normally\n", d->PC);
        terminate = TERMINATE_NORM;
    }

}

// ------------------------------------------------

void CALL (pDecode_t d) 
{
    uint32 temp;

    if (Verbose) 
        fprintf (ofp, "%08x call     %08x to %08x\n", d->PC, d->imm_disp_rs2, d->PC + (4 * d->imm_disp_rs2));

    d->wb_type = WRITEBACKREG;
    d->value = d->PC;
    d->rd = OUTREG7;

    temp   = d->PC;
    d->PC  = d->nPC;
    d->nPC = temp + (4 * d->imm_disp_rs2);
}

// ------------------------------------------------

void BICC (pDecode_t d)
{
    int branch, annul, temp;

    if (Verbose) 
        fprintf(ofp,  "%08x b%s %d cc=%1x\n", d->PC, CondByte[d->rd & 0xf], (signed int)(sign_ext22(d->imm_disp_rs2*4)), (d->PSR >> PSR_CC_CARRY) & LOBITS4);

    branch = TestCC (d);
    annul = ((d->rd >> 4) & LOBITS1) && (((!branch) && ((d->rd & LOBITS3) != 0)) || ((d->rd & LOBITS3) == 0));

    temp = d->nPC;
    if (branch)
        d->nPC = d->PC + 4 * sign_ext22(d->imm_disp_rs2);
    else 
        d->nPC += 4;
    d->PC = temp;

    if (annul) {
        d->PC = d->nPC;
        d->nPC += 4;
    }
}

// ------------------------------------------------

void SETHI (pDecode_t d)
{
    uint32 temp;

    if (d->opcode == NOP) {
        if (Verbose) 
            fprintf(ofp, "%08x nop\n", d->PC);
    } else {
        temp = d->imm_disp_rs2 << 10;
        if (Verbose) 
            fprintf (ofp, "%08x sethi    Opcode %08x -> %s = %08x\n", d->PC, d->opcode, DispRegStr(d->rd, rdbuf), temp);
        d->wb_type = WRITEBACKREG;
        d->value = temp;
    }
    d->PC = d->nPC;
    d->nPC += 4;
}

// ------------------------------------------------

void SLL (pDecode_t d)
{
    d->wb_type = WRITEBACKREG;
    d->value = d->rs1_value << (d->ev & LOBITS5);

    if (Verbose) 
        fprintf (ofp, "%08x sll       %s %08x << %02x = %08x %s\n", d->PC, DispRegStr(d->rs1, rs1buf),
                 d->rs1_value, d->ev, d->value, DispRegStr(d->rd, rdbuf));

    d->PC = d->nPC;
    d->nPC += 4;
}

// ------------------------------------------------

void SRL (pDecode_t d)
{
    d->wb_type = WRITEBACKREG;
    d->value = d->rs1_value >> (d->ev & LOBITS5);

    if (Verbose) 
        fprintf (ofp, "%08x srl       %s %08x >> %08x = %08x %s\n", d->PC, DispRegStr(d->rs1, rs1buf),
                 d->rs1_value, d->ev, d->value, DispRegStr(d->rd, rdbuf));

    d->PC = d->nPC;
    d->nPC += 4;
}

// ------------------------------------------------

void SRA (pDecode_t d)
{
    d->wb_type = WRITEBACKREG;
    d->value = (d->rs1_value >> (d->ev & LOBITS5)) | (((d->rs1_value & BIT31) && d->ev) ? (0xffffffff << (32 - (d->ev & LOBITS5))) : 0);

    if (Verbose) 
        fprintf (ofp, "%08x sra       %s %08x >> %08x = %08x %s\n", d->PC, DispRegStr(d->rs1, rs1buf),
                 d->rs1_value, d->ev, d->value, DispRegStr(d->rd, rdbuf));

    d->PC = d->nPC;
    d->nPC += 4;
}

// ------------------------------------------------

void RDY (pDecode_t d)
{
    if (d->rs1 == 15 && d->rd == 0) {
        if (Verbose) 
            fprintf (ofp, "%08x stbar\n", d->PC);
    } else {
        if (d->rs1 == 0 && (d->op_2_3 & 0x2f) == 0x28) {
            if (Verbose) 
                fprintf (ofp, "%08x rdy      %s = %08x\n", d->PC, DispRegStr(d->rd, rdbuf), Y);
            d->wb_type = WRITEBACKREG;
            d->value = Y;
        } else 
           UNIMP(d);
    }
    d->PC = d->nPC;
    d->nPC += 4;
}

// ------------------------------------------------

void RDPSR (pDecode_t d)
{
    if (Verbose) 
        fprintf (ofp, "%08x rdpsr    %s = %08x\n", d->PC, DispRegStr(d->rd, rdbuf), d->PSR);

    if (d->p->s == 0) {
        Trap (d, SPARC_PRIVILEGED_INSTRUCTION);
    } else {
        d->wb_type = WRITEBACKREG;
        d->value = d->PSR;
        d->PC = d->nPC;
        d->nPC= d->nPC + 4;
    }
}

// ------------------------------------------------

void RDWIM (pDecode_t d)
{
    if (Verbose) 
        fprintf (ofp, "%08x rdwim    %s = %08x\n", d->PC, DispRegStr(d->rd, rdbuf), WIM);

    if (d->p->s == 0) {
        Trap (d, SPARC_PRIVILEGED_INSTRUCTION);
    } else {
        d->wb_type = WRITEBACKREG;
        d->value = WIM;
        d->PC = d->nPC;
        d->nPC += 4;
    }
}

// ------------------------------------------------

void RDTBR (pDecode_t d)
{

    if (Verbose) 
        fprintf (ofp, "%08x rdtbr    %s = %08x\n", d->PC, DispRegStr(d->rd, rdbuf), TBR);

    if (d->p->s == 0) {
        Trap (d, SPARC_PRIVILEGED_INSTRUCTION);
    } else {
        d->wb_type = WRITEBACKREG;
        d->value = TBR;
        d->PC = d->nPC;
        d->nPC += 4;
    }
}

// ------------------------------------------------

void WRY (pDecode_t d)
{
    if ((d->rd & LOBITS5) == 0) {
        Y = d->rs1_value ^ d->ev;
        if (Verbose) 
            fprintf (ofp, "%08x wry      = %08x\n", d->PC, Y);
    } else 
        UNIMP(d);

    d->PC = d->nPC;
    d->nPC += 4;
}

// ------------------------------------------------

void WRPSR (pDecode_t d)
{
    if (Verbose) 
        fprintf (ofp, "%08x wrpsr    = %08x\n", d->PC, d->rs1_value ^ d->ev);

    if (((d->rs1_value ^ d->ev) & LOBITS5) >= NWINDOWS) 
        Trap (d, SPARC_ILLEGAL_INSTRUCTION);
    else if (d->p->s == 0) 
        Trap (d, SPARC_PRIVILEGED_INSTRUCTION);
    else {
        d->PSR = d->rs1_value ^ d->ev;
        d->PC = d->nPC;
        d->nPC += 4;
    }
}

// ------------------------------------------------

void WRWIM (pDecode_t d)
{
    if (Verbose) 
        fprintf (ofp, "%08x wrwim    = %08x\n", d->PC, d->rs1_value ^ d->ev);

    if (d->p->s == 0)
        Trap (d, SPARC_PRIVILEGED_INSTRUCTION);
    else {
        WIM = d->rs1_value ^ d->ev;
        d->PC = d->nPC;
        d->nPC += 4;
    }
}

// ------------------------------------------------

void WRTBR (pDecode_t d)
{
    if (Verbose) 
        fprintf (ofp, "%08x wrtbr    = %08x\n", d->PC, d->rs1_value ^ d->ev);

    if (d->p->s == 0) 
        Trap (d, SPARC_PRIVILEGED_INSTRUCTION);
    else {
        TBR = d->rs1_value ^ d->ev;
        d->PC = d->nPC;
        d->nPC += 4;
    }
}

// ------------------------------------------------

void JMPL (pDecode_t d)
{
    uint32 temp;


    if (Verbose) 
        fprintf (ofp, "%08x jmpl     rs1 %08x + ev => nPC = %08x\n", d->PC, d->rs1_value, d->nPC);

    if (d->ev & LOBITS2) {
        Trap(d, SPARC_MEMORY_ADDR_NOT_ALIGNED);
    } else {
        d->wb_type = WRITEBACKREG;
        d->value = d->PC;
        temp = d->PC;
        d->PC = d->nPC;
        d->nPC = d->ev;
    }
}

// ------------------------------------------------

void RETT (pDecode_t d)
{
    uint32 temp, new_win;

    new_win = d->p->cwp + 1;

    if (Verbose) 
        fprintf (ofp, "%08x rett     rs1 %08x + ev => nPC = %08x\n", d->PC, d->rs1_value, d->ev & ~LOBITS2);

    if ( (d->p->et && !d->p->s) || (!d->p->et && !d->p->s))
        Trap (d, SPARC_PRIVILEGED_INSTRUCTION);
    else if (d->p->et && d->p->s)
        Trap (d, SPARC_ILLEGAL_INSTRUCTION);
    else if (d->ev & LOBITS2)
        Trap (d, SPARC_MEMORY_ADDR_NOT_ALIGNED);
    else if (((WIM >> new_win) & LOBITS1) != 0)
        Trap (d, SPARC_WINDOW_UNDERFLOW);
    else {
        temp = d->PC;
        d->PC = d->nPC;
        d->nPC = d->ev & ~LOBITS2;
        d->p->s = d->p->ps;
        d->p->et = 1;
        d->p->cwp = new_win;
    }

}

// ------------------------------------------------

void TICC (pDecode_t d)
{
    int tn = TrapType;

    if (TestCC(d)) {
        if (d->i) 
            tn = 128 + ((d->rs1_value + sign_ext7((d->opcode & LOBITS7))) & LOBITS7);
        else {
            tn = d->value;
            tn = 128 + ((tn +  d->rs1_value) & LOBITS7);
        }
        if (Verbose) 
            fprintf (ofp, "%08x t%s %08x op=%01x\n", d->PC, CondByte[d->rd & 0xf], tn, (d->rd & LOBITS4));
        Trap(d, tn);
    } else {
        if (Verbose) 
            fprintf (ofp, "%08x t%s %08x op=%01x\n", d->PC, CondByte[d->rd & 0xf], tn, (d->rd & LOBITS4));
        d->PC = d->nPC;
        d->nPC += 4;
    }
}

// ------------------------------------------------

void SAVE (pDecode_t d)
{
    uint32 new_win;

    new_win = (d->PSR & LOBITS4) - 1;
    if (Verbose) 
        fprintf (ofp, "%08x save     %08x, %08x\n", d->PC, d->rs1_value, d->ev);
    if (((WIM >> new_win) & LOBITS1) != 0)
        Trap (d, SPARC_WINDOW_OVERFLOW);
    else {
        d->PSR = (d->PSR & ~(LOBITS4)) | (new_win & LOBITS4);
        d->wb_type = WRITEBACKREG;
        d->value = d->ev;
        d->PC = d->nPC;
        d->nPC += 4;
    }
}

// ------------------------------------------------

void RESTORE (pDecode_t d)
{
    uint32 new_win;

    if (Verbose) 
        fprintf (ofp, "%08x restore\n", d->PC);

    new_win = (d->PSR & LOBITS4) + 1;
    if (((WIM >> new_win) & LOBITS1) != 0)
        Trap (d, SPARC_WINDOW_UNDERFLOW);
    else {
        d->PSR = (d->PSR & ~(LOBITS4)) | (new_win & LOBITS4);
        d->wb_type = WRITEBACKREG;
        d->value = d->ev;
        d->PC = d->nPC;
        d->nPC += 4;
    }
}

// ------------------------------------------------

void FLUSH (pDecode_t d)
{
    if (Verbose) {
        fprintf(ofp, "%08x flush    [%08x], %s\n", d->PC, d->ev, DispRegStr(d->rd, rdbuf));
    }
    d->PC = d->nPC;
    d->nPC += 4;
}

// ------------------------------------------------

void MULSCC (pDecode_t d)
{
    uint32 cc;
    uint32 x, y, z;
    uint32 xtop, ytop, ztop;

    cc = (d->PSR >> PSR_CC_CARRY) & LOBITS4;


    x = (d->rs1_value >> 1) | ((((cc >> CC_OVERFLOW) ^ (cc >> CC_NEGATIVE)) &1) << 31);
    y = (Y & 1) ? d->ev : 0;

    z = x + y;

    xtop = x >> 31;
    ytop = y >> 31;
    ztop = z >> 31;

    d->wb_type = WRITEBACKREG;
    d->value = z;

    cc = (cc & ~(1 << CC_OVERFLOW)) | (((((xtop & ytop & ~(ztop)) | (~(xtop) & ~(ytop) & ztop)) & LOBITS1)) << CC_OVERFLOW);
    cc = (cc & ~(1 << CC_CARRY)) | (((( (xtop & ytop) | (~ztop & (xtop | ytop)))) & LOBITS1) << CC_CARRY);
    cc = (cc & ~(1 << CC_ZERO))     | (((z == 0) ? 1 : 0) << CC_ZERO);
    cc = (cc & ~(1 << CC_NEGATIVE)) | (((z >> 31) & LOBITS1) << CC_NEGATIVE);

    d->PSR = (d->PSR & ~(LOBITS4 << PSR_CC_CARRY)) | (cc << PSR_CC_CARRY);

    Y = (Y >> 1) | ((d->rs1_value & 1) << 31);

    if (Verbose) 
        fprintf (ofp, "%08x mulscc   %s %08x, %s %08x -> %s = %08x cc=%1x\n",
                 d->PC,  
                 DispRegStr(d->rs1, rs1buf), 
                 x,
                 !d->i ? DispRegStr(d->opcode & LOBITS5, rs2buf) : "", 
                 y, 
                 DispRegStr(d->rd, rdbuf), 
                 z,
                 (d->PSR >> PSR_CC_CARRY) & LOBITS4);

    d->PC = d->nPC;
    d->nPC += 4;
}

/////////////////////
// Format31 functions

// ------------------------------------------------

void LD (pDecode_t d)
{
    if (Verbose) 
        fprintf (ofp, "%08x ld       [%08x], %s\n", d->PC, d->ev, DispRegStr(d->rd, rdbuf));

    if (d->ev & LOBITS2) {
        Trap(d, SPARC_MEMORY_ADDR_NOT_ALIGNED);
    } else {
        MemRead(d->ev, 4, d->rd, 0);
        d->PC = d->nPC;
        d->nPC += 4;
    }
}

// ------------------------------------------------

void LDUB (pDecode_t d)
{
    if (Verbose) 
        fprintf (ofp, "%08x ldub     [%08x], %s\n", d->PC, d->ev, DispRegStr(d->rd, rdbuf));

    MemRead(d->ev, 1, d->rd, 0);
    d->PC = d->nPC;
    d->nPC += 4;
}

// ------------------------------------------------

void LDUH (pDecode_t d)
{
    if (Verbose) 
        fprintf (ofp, "%08x lduh     [%08x], %s\n", d->PC, d->ev, DispRegStr(d->rd, rdbuf));

    if (d->ev & LOBITS1) {
        Trap(d, SPARC_MEMORY_ADDR_NOT_ALIGNED);
    } else {
        MemRead(d->ev, 2, d->rd, 0);
        d->PC = d->nPC;
        d->nPC += 4;
    }
}

// ------------------------------------------------

void LDD (pDecode_t d)
{
    if (Verbose) 
        fprintf (ofp, "%08x ldd      [%08x], %s\n", d->PC, d->ev, DispRegStr(d->rd, rdbuf));

    if (d->rd & LOBITS1) {
        Trap(d, SPARC_ILLEGAL_INSTRUCTION);
    } else if (d->ev & LOBITS3) {
        Trap(d, SPARC_MEMORY_ADDR_NOT_ALIGNED);
    } else {
        MemRead(d->ev, 8, d->rd & ~LOBITS1, 0);
        d->PC = d->nPC;
        d->nPC += 4;
    }
}

// ------------------------------------------------

void LDSB (pDecode_t d)
{
    if (Verbose) 
        fprintf (ofp, "%08x ldsb     [%08x], %s\n", d->PC, d->ev, DispRegStr(d->rd, rdbuf));

    MemRead(d->ev, 1, d->rd, 1);
    d->PC = d->nPC;
    d->nPC += 4;
}

// ------------------------------------------------

void LDSH (pDecode_t d)
{
    if (Verbose) 
        fprintf (ofp, "%08x ldsh     [%08x], %s\n", d->PC, d->ev, DispRegStr(d->rd, rdbuf));

    if (d->ev & LOBITS1) {
        Trap(d, SPARC_MEMORY_ADDR_NOT_ALIGNED);
    } else {
        MemRead(d->ev, 2, d->rd, 1);
        d->PC = d->nPC;
        d->nPC += 4;
    }
}

// ------------------------------------------------

void ST (pDecode_t d)
{
    if (Verbose) 
        fprintf (ofp, "%08x st       %s, [%08x] = %08x\n", d->PC, DispRegStr(d->rd, rdbuf), d->ev, d->value & LOWORDMASK);

    if (d->ev & LOBITS2) {
        Trap(d, SPARC_MEMORY_ADDR_NOT_ALIGNED);
    } else {
        MemWrite(d->ev, 4, d->rd);
        d->PC = d->nPC;
        d->nPC += 4;
    }
}

// ------------------------------------------------

void STB (pDecode_t d)
{
    if (Verbose) 
        fprintf (ofp, "%08x stb      %s, [%08x] = %08x\n", d->PC, DispRegStr(d->rd, rdbuf), d->ev, d->value & LOBITS8);

    MemWrite(d->ev, 1, d->rd);
    d->PC = d->nPC;
    d->nPC += 4;
}

// ------------------------------------------------

void STH (pDecode_t d)
{

    if (Verbose) 
        fprintf (ofp, "%08x sth      %s, [%08x] = %08x\n", d->PC, DispRegStr(d->rd, rdbuf), d->ev, d->value & LOHWORDMASK);

    if (d->ev & LOBITS1) {
        Trap(d, SPARC_MEMORY_ADDR_NOT_ALIGNED);
    } else {
        MemWrite(d->ev, 2, d->rd);
        d->PC = d->nPC;
        d->nPC += 4;
    }
}

// ------------------------------------------------

void STD (pDecode_t d)
{
    uint64 hold0;

    if (Verbose) {
        hold0 = ((uint64)d->value << (uint64)32);
        hold0 |= d->value1;
        fprintf (ofp, "%08x std      %s, [%08x] = %llx\n", d->PC, DispRegStr(d->rd, rdbuf), d->ev, (long long)hold0);
    }
    if (d->rd & LOBITS1) {
        Trap(d, SPARC_ILLEGAL_INSTRUCTION);
    } else if (d->ev & LOBITS3) {
        Trap(d, SPARC_MEMORY_ADDR_NOT_ALIGNED);
    } else {
        MemWrite(d->ev, 8, d->rd);
        d->rd &= ~LOBITS1;
        d->PC = d->nPC;
        d->nPC += 4;
    }
}

// ------------------------------------------------

void SWAP (pDecode_t d)
{
    uint32 hold0;

    if (Verbose)
        fprintf(ofp, "%08x swap     [%08x], %s = %08x\n", d->PC, d->ev, DispRegStr(d->rd, rdbuf), d->value );

    if (d->ev & LOBITS2)
        Trap(d, SPARC_MEMORY_ADDR_NOT_ALIGNED);
    else {
        // Copy data to swap register
        *pSwapReg = d->value;

        // Issue the read
        hold0 = MemRead(d->ev, 4, d->rd, 0);     

        // Write the data back
        MemWrite(d->ev, 4, GLOBALREG8);

        d->PC = d->nPC;
        d->nPC += 4;
    }
}

// ------------------------------------------------

void LDSTUB (pDecode_t d)
{
    uint32 value;

    if (Verbose) 
        fprintf (ofp, "%08x ldstub   [%08x], %s\n", d->PC, d->ev, DispRegStr(d->rd, rdbuf));

    value = MemRead(d->ev, 1, d->rd, 0);

    // Set memory byte to all 1s
    *pSwapReg = 0xff;
    MemWrite(d->ev, 1, GLOBALREG8);

    d->PC = d->nPC;
    d->nPC += 4;
}

// ------------------------------------------------

void MUL (pDecode_t d)
{
    uint64 x, y, z; 
    uint32 cc;

    cc = (d->PSR >> PSR_CC_CARRY) & LOBITS4;

    x = d->rs1_value;
    y = d->ev;

    if (d->op_2_3 & LOBITS1) {
        // Sign extend x and y
        x |= (x & 0x80000000) ? ((uint64)0xffffffff << (uint64)32) : 0;
        y |= (y & 0x80000000) ? ((uint64)0xffffffff << (uint64)32) : 0;

        // Calculate multiplication
        z = (int64)x * (int64)y;

        // Y = hi 32 bits
        Y = (uint32)(z >> 32);

        // z = lo 32 bits
        z &= 0xffffffff;
    } else {
        z = x * y;

        Y = (uint32)(z >> 32);
        z &= 0xffffffff;
    }

    // Modify icc bit set
    if (d->op_2_3 & BIT4) {
        cc = (cc & ~(1 << CC_ZERO))     | (((z == 0) ? 1 : 0) << CC_ZERO);
        cc = (cc & ~(1 << CC_NEGATIVE)) | (((uint32)(z >> 31) & 1) << CC_NEGATIVE);
        cc &= ~(1 << CC_OVERFLOW);
        cc &= ~(1 << CC_CARRY);

        d->PSR = (d->PSR & ~(0xf << PSR_CC_CARRY)) | (cc << PSR_CC_CARRY);
    }

    if (Verbose)
        fprintf (ofp, "%08x %s %s %08x, %s %08x -> %s = %08x %08x cc=%1x\n",
                 d->PC, 
                 OpByte[d->op_2_3], 
                 DispRegStr(d->rs1, rs1buf),
                 (uint32)x,
                 !d->i ? DispRegStr(d->opcode & LOBITS5, rs2buf) : "",
                 (uint32)y, 
                 DispRegStr(d->rd, rdbuf), 
                 Y, 
                 (uint32)z,
                 (d->PSR >> PSR_CC_CARRY) & LOBITS4);

    d->wb_type = WRITEBACKREG;
    d->value = (uint32)(z & 0xffffffff);

    d->PC = d->nPC;
    d->nPC += 4;
}

// ------------------------------------------------

void DIV (pDecode_t d)
{
    uint64 x, y, z;
    uint32 cc;

    cc = (d->PSR >> PSR_CC_CARRY) & LOBITS4;

    x = ((uint64)Y << 32) | (uint64)d->rs1_value;
    y = d->ev;

    if (Verbose)
        fprintf (ofp, "%08x %s %s %08x %08x, %s %08x -> %s = ",
                 d->PC, OpByte[d->op_2_3], DispRegStr(d->rs1, rs1buf), 
                 (uint32)(x>>32) & 0xffffffff, (uint32)x & 0xffffffff,
                 !d->i ? DispRegStr(d->opcode & LOBITS5, rs2buf) : "", (uint32)y & 0xffffffff, DispRegStr(d->rd, rdbuf));

    if (y == 0) {
        if (Verbose)
            fprintf(ofp, "??? cc=??\n");
        Trap (d, SPARC_DIVISION_BY_ZERO);
    } else {
        if (d->op_2_3 & LOBITS1) {
            y |= (y & 0x80000000) ? ((uint64)0xffffffff << (uint64)32) : 0;
            z = (int64)x / (int64)y;
            Y = (uint32)((int64)x % (int64)y);
        } else {
            z = x / y;
            Y = (uint32)(x % y);
        }

        // Modify icc bit set
        if (d->op_2_3 & BIT4) {
            cc = (cc & ~(1 << CC_ZERO))     | (((z == 0) ? 1 : 0) << CC_ZERO);
            cc = (cc & ~(1 << CC_NEGATIVE)) | (((uint32)(z >> 31) & 1) << CC_NEGATIVE);
            cc &= ~(1 << CC_OVERFLOW);
            cc &= ~(1 << CC_CARRY);

            d->PSR = (d->PSR & ~(LOBITS4 << PSR_CC_CARRY)) | (cc << PSR_CC_CARRY);
        }

        if (Verbose)
            fprintf (ofp, "%08x cc=%1x\n", (uint32)z & 0xffffffff,
                                 (d->PSR >> PSR_CC_CARRY) & LOBITS4);

        d->wb_type = WRITEBACKREG;
        d->value = (uint32)z &0xffffffff; 

        d->PC = d->nPC;
        d->nPC += 4;
    }
}

// ------------------------------------------------

void ADD (pDecode_t d)
{
    uint32 x, y, z, cc;
    uint32 xtop, ytop, ztop, carry;
    uint32 y_sign; 
    uint32 tag_inst, tag_overflow, tag_sub;
    char *tbyte;

    // Opcode is a tagged add/sub
    tag_inst = d->op_2_3 & BIT5;
    tag_sub = (tag_inst && (d->op_2_3 & LOBITS1)) ? 1 : 0;
    cc = (d->PSR >> PSR_CC_CARRY) & LOBITS4;

    x = d->rs1_value;
    y = d->ev;

    y_sign = ((d->op_2_3 & BIT2) || tag_sub) ? ~y : y;
    carry  = ((((d->op_2_3 >> 2) | tag_sub) ^ ((cc >> CC_CARRY) & (~tag_sub & (d->op_2_3 >> 3)))) & LOBITS1);
    xtop   = (x >> 31) & LOBITS1 ;
    ytop   = (y_sign >> 31) & LOBITS1;
 
    z = x + y_sign + carry ;

    ztop = (z >> 31) & LOBITS1 ;

    if (tag_inst) 
       tag_overflow = ((x & 0x3) || (y & 0x3)) ? 1 : 0;
    else 
       tag_overflow = 0;

    cc = (cc & ~(1 << CC_OVERFLOW)) | (((((xtop & ytop & ~(ztop)) | (~(xtop) & ~(ytop) & ztop)) & LOBITS1) | tag_overflow) << CC_OVERFLOW);
    cc = (cc & ~(1 << CC_CARRY))    | ((((d->op_2_3 >> 2) ^ ( (xtop & ytop) | (~ztop & (xtop | ytop)))) & LOBITS1) << CC_CARRY);
    cc = (cc & ~(1 << CC_ZERO))     | (((z == 0) ? 1 : 0) << CC_ZERO);
    cc = (cc & ~(1 << CC_NEGATIVE)) | (((z >> 31) & LOBITS1) << CC_NEGATIVE);

    if (Verbose) {
        tbyte = (d->op_2_3 & 1) ? ((d->op_2_3 & 2) ? "tsubcctv" : "tsubcc  ") :
                                  ((d->op_2_3 & 2) ? "taddcctv" : "taddcc  ");
   
        fprintf (ofp, "%08x %s %s %08x, %s %08x -> %s = %08x cc=%1x\n",
                 d->PC, 
                 tag_inst ? tbyte : OpByte[d->op_2_3],
                 DispRegStr(d->rs1, rs1buf), 
                 x,
                 !d->i ? DispRegStr(d->opcode & LOBITS5, rs2buf) : "", 
                 y, 
                 DispRegStr(d->rd, rdbuf), 
                 z,
                 ((d->op_2_3 & BIT4) || tag_inst) ? cc : (d->PSR >> PSR_CC_CARRY) & LOBITS4);
    }

    // TADDcTV or TSUBccTV trap on tagged overflow
    if (((d->op_2_3 & 0x22) == 0x22) && (cc & (1 << CC_OVERFLOW)))
        Trap(d, SPARC_TAG_OVERFLOW);
    else {
        // Modify icc bit set (or TADDcc/TSUBcc)
        if ((d->op_2_3 & BIT4) || tag_inst) 
            d->PSR = (d->PSR & ~(LOBITS4 << PSR_CC_CARRY)) | (cc << PSR_CC_CARRY);
        d->wb_type = WRITEBACKREG;
        d->value = z;

        d->PC = d->nPC;
        d->nPC += 4;
    }
}

// ------------------------------------------------

void AND (pDecode_t d)
{
    uint32 x, y, z, cc;
    uint32 y_sign;

    cc = (d->PSR >> PSR_CC_CARRY) & LOBITS4;

    x = d->rs1_value;
    y = d->ev;

    y_sign = (d->op_2_3 & BIT2) ? ~y : y;

    switch (d->op_2_3 & LOBITS2) {
    case 1:
        z = x & y_sign ;
        break;
    case 2:
        z = x | y_sign;
        break;
    case 3:
        z = x ^ y_sign;
        break;
    }

    // Modify icc bit set
    if (d->op_2_3 & BIT4) 
        CalcCC(cc, z, d->PSR);

    if (Verbose)
        fprintf (ofp, "%08x %s %s %08x, %s %08x -> %s = %08x cc=%1x\n",
                 d->PC, OpByte[d->op_2_3], DispRegStr(d->rs1, rs1buf), x,
                 !d->i ? DispRegStr(d->opcode & LOBITS5, rs2buf) : "", y, DispRegStr(d->rd, rdbuf), z,
                 (d->PSR >> PSR_CC_CARRY) & LOBITS4);

    d->wb_type = WRITEBACKREG;
    d->value = z;

    d->PC = d->nPC;
    d->nPC += 4;
}

