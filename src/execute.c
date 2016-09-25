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
// $Id: execute.c,v 1.3 2013-06-29 08:57:39 simon Exp $
// $Source: /home/simon/CVS/src/cpu/sparc/src/execute.c,v $
//
//=============================================================

#include <stdio.h>
#include "sparc_iss.h"
#include "sparc.h"
#include "inst.h"

extern FILE *ofp;

int terminate = 0;
int Verbose   = 0;
uint32 BreakPoint;
FILE* ofp;

p_memcallback_t pMemCallback = NULL;

///////////////////////
// Major state of model
static uint32 PC;
static uint32 nPC;

static uint32 PSR;
static uint32 IRL;

//////////////////////////////////////
// Instruction function pointer tables

// Format 1 instruction
static p_func const format1 = CALL;

// Format 2 instructions
static const p_func format2[8] = {
    UNIMP    , UNIMP    , BICC     , UNIMP,
    SETHI    , UNIMP    , FBFCC    , CBCCC};

// Format 3 instructions 
static const p_func format3[128] = {
    ADD      , AND      , OR       , XOR      ,  // opcode[31:30] = 2
    SUB      , ANDN     , ORN      , XNOR     ,
    ADDX     , UNIMP    , UMUL     , SMUL     ,
    SUBX     , UNIMP    , UDIV     , SDIV     ,
    ADDCC    , ANDCC    , ORCC     , XORCC    ,
    SUBCC    , ANDNCC   , ORNCC    , XNORCC   ,
    ADDXCC   , UNIMP    , UMULCC   , SMULCC   ,
    SUBXCC   , UNIMP    , UDIVCC   , SDIVCC   ,
    TADDCC   , TSUBCC   , TADDCCTV , TSUBCCTV ,
    MULSCC   , SLL      , SRL      , SRA      ,
    RDY      , RDPSR    , RDWIM    , RDTBR    ,
    UNIMP    , UNIMP    , UNIMP    , UNIMP    ,
    WRY      , WRPSR    , WRWIM    , WRTBR    ,
    FPOP1    , FPOP2    , CPOP1    , CPOP2    ,
    JMPL     , RETT     , TICC     , FLUSH    ,
    SAVE     , RESTORE  , UNIMP    , UNIMP    ,
    LD       , LDUB     , LDUH     , LDD      ,  // opcode[31:30] = 3
    ST       , STB      , STH      , STD      ,
    UNIMP    , LDSB     , LDSH     , UNIMP    ,
    UNIMP    , LDSTUB   , UNIMP    , SWAP     ,
    LDA      , LDUBA    , LDUHA    , LDDA     ,
    STA      , STBA     , STHA     , STDA     ,
    UNIMP    , LDSBA    , LDSHA    , UNIMP    ,
    UNIMP    , LDSTUBA  , UNIMP    , SWAPA    ,
    LDF      , LDFSR    , UNIMP    , LDDF     ,
    STF      , STFSR    , STDFQ    , STDF     ,
    UNIMP    , UNIMP    , UNIMP    , UNIMP    ,
    UNIMP    , UNIMP    , UNIMP    , UNIMP    ,
    LDC      , LDCSR    , UNIMP    , LDDC     ,
    STC      , STCSR    , STDCQ    , STDC     ,
    UNIMP    , UNIMP    , UNIMP    , UNIMP    ,
    UNIMP    , UNIMP    , UNIMP    , UNIMP 
    };

//------------------------------------------------------------------------
// Major state data access routines
//
uint32 GetPC  (void) { return PC;  }
uint32 GetnPC (void) { return nPC; }
uint32 GetPSR (void) { return PSR; }
uint32 GetIRL (void) { return IRL; }

//------------------------------------------------------------------------
// Reset()
//
// Reset major state. Called when run from time 0.
//
static void Reset(void)
{
    PC  = 0;
    nPC = 4;

    //PSR = (1 << PSR_ENABLE_TRAPS) | (1 << PSR_SUPER_MODE);
    ((pPSR_t)&PSR)->et = 1;
    ((pPSR_t)&PSR)->s  = 1;
    IRL = 0;

    TrapType = 0;
    TBR = 0;
    WIM = 0;
}

//------------------------------------------------------------------------
// register_mem_callback()
//
// Register an external function to be a callback on all memory accesses.
//
void register_mem_callback (p_memcallback_t callback_func)
{
    pMemCallback = callback_func;
}

//------------------------------------------------------------------------
// Decode()
//
// Main instruction decode. Selects instc function and expands input data
//
static void Decode(pDecode_t d)
{
    uint32 fmt_bits = (d->opcode >> FMTSTARTBIT) & LOBITS2;
    uint32 op2      = (d->opcode >> OP2STARTBIT) & LOBITS3;
    uint32 op3      = (d->opcode >> OP3STARTBIT) & LOBITS6;
    uint32 I_idx, regvalue;

    if (Verbose) 
        fprintf(ofp, "%08x: ", d->opcode);

    // By default, no change to program counter and PSR, and
    // no writeback
    d->PC      = PC;
    d->nPC     = nPC;
    d->PSR     = PSR;
    d->wb_type = NO_WRITEBACK;

    switch (fmt_bits) {
    // CALL
    case 1:  
        d->function     = format1;                         
        d->imm_disp_rs2 = d->opcode & LOBITS30;
        break;

    // SETHI, Branches
    case 0:  
        d->function     = format2[op2];                     
        d->rd           = (d->opcode >> RDSTARTBIT) & LOBITS5;
        d->op_2_3       = (d->opcode >> OP2STARTBIT) & LOBITS3;
        d->imm_disp_rs2 = (d->opcode & LOBITS22);
        break;

    // Memory accesses, ALU etc.
    case 3:  
    case 2:  
        d->function     = format3[op3 + ((fmt_bits & 1) << 6)];
        d->rd           = (d->opcode >> RDSTARTBIT)  & LOBITS5;
        d->op_2_3       = (d->opcode >> OP3STARTBIT) & LOBITS6;
        d->rs1          = (d->opcode >> RS1STARTBIT) & LOBITS5;
        d->i            = (d->opcode >> ISTARTBIT)   & LOBITS1;
        d->imm_disp_rs2 = (d->opcode >> RS2STARTBIT) & LOBITS13;

        // All instructions need r[rs1] value
        ReadReg (d->rs1, &d->rs1_value);

        // ev = ((RD/WR/ALU/Logic instr) ? r[rs1] : 0) + (i ? sign_ext(imm) : r[rs2])
        I_idx = op3 + ((fmt_bits & 1) << 6);
        regvalue = (I_idx < FIRST_RS1_EVAL_IDX) ? 0 : d->rs1_value;

        if (d->i)
           d->ev = regvalue + sign_ext13(d->imm_disp_rs2);
        else {
           ReadReg(d->imm_disp_rs2 & LOBITS5, &d->ev);
           d->ev += regvalue;
        }

        // All format 3 instructions require at least one register read (rs1),
        // but a few require more...

        // A store double access requires two register reads
        // from, r[rd], r[rd+1].
        if (I_idx == STORE_DBL_IDX) {
            ReadReg (d->rd & ~LOBITS1, &d->value);
            ReadReg ((d->rd & ~LOBITS1)+1, &d->value1);

        // Ticc requires an r[rs2] read if i bit clear
        } else if (I_idx == TICC_IDX && !d->i)
            ReadReg (d->imm_disp_rs2 & LOBITS5, &d->value); 

        // Memory instructions need to read r[rd]
        else if (fmt_bits & 1)
            ReadReg (d->rd, &d->value);

        break;
   }
}

//------------------------------------------------------------------------
// WriteBack()
//
// Write back register values
//
static void WriteBack (const pDecode_t d)
{
    PC  = d->PC;
    nPC = d->nPC;
    PSR = d->PSR;

    if (d->wb_type == WRITEBACKREG) 
        WriteReg(d->value, d->rd);
}

//------------------------------------------------------------------------
// Run()
//
// Main processor execution loop, and main entry point for execution of
// code. Will run until some termination point, either user specified or
// an error condition.
//
uint64 Run(const char* fname, const uint32 ExecCount, const uint32 UserBreakpoint, const int Disassemble, const int UserVerbose, FILE* UserOfp, int* TerminateReason) 
{
    uint64 physaddr;
    uint64 count = 0;
    uint32 word_count;
    struct DecodeStruct Dec, *d=&Dec;
    pPSR_t p = (pPSR_t)&PSR;

    // Update internal configuration from user arguments
    BreakPoint = (UserBreakpoint & 0x3) ? NO_USER_BREAK : UserBreakpoint;
    Verbose = UserVerbose;
    ofp     = UserOfp;

    // Only run from the beginning if not single stepping
    if (UserBreakpoint != TERMINATE_STEP) {

        // Reset the device
        Reset();

        // Load some code
        word_count = ReadElf(fname);
    }

    if (Disassemble)
       return disRun(word_count);

    // Map the PSR structure to the decode PSR variable just once
    d->p = (pPSR_t) &(d->PSR);

    // Start executing program
    while (!terminate && (ExecCount == 0) ? 1 : (count < (uint64)ExecCount)) {

        count++;
        
        // Process interrupts
        if (TrapType == 0 && (p->et && IRL > p->pil)) {
            if (Verbose)
                fprintf (ofp, "INT  %x PC=%08x NPC=%08x\n", IRL, PC, nPC);

            TrapType = IRL + SPARC_INTERRUPT;
        }

        // Process Traps
        if (TrapType) {
            p->et = 0;
            p->ps = p->s;
            p->s = 1;
            p->cwp -= 1;
            WriteReg (PC,  LOCALREG1);
            WriteReg (nPC, LOCALREG2);
            
            TBR = (TBR & ~(0xff0)) | ((TrapType & LOBITS8) << 4);
            PC  = TBR;
            nPC = TBR + 4;
            TrapType &= ~(LOBITS8);
        }

        // No MMU translation in this model!
        physaddr = (uint64) PC;

        // Service breakpoints
        if (physaddr == (uint64)BreakPoint) {
            if (Verbose)
                fprintf(ofp, "Breakpoint at %08lx\n", (long unsigned)BreakPoint);
            terminate = TERMINATE_BREAK;
        } else if (UserBreakpoint == BREAK_SINGLE_STEP) {
            terminate = TERMINATE_STEP;
        }
            
        // Process instruction ...

        // ---- IFetch ----
        Ifetch(physaddr, &(d->opcode));

        // ---- Decode ----
        Decode (d);

        // ---- Execute ----
        d->function(d);

        // ---- Writeback ----
        WriteBack(d);
    }

    // Return reason we terminated
    *TerminateReason = terminate;

    return count;
}

