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
// $Id: read_write.c,v 1.3 2013-06-29 08:57:39 simon Exp $
// $Source: /home/simon/CVS/src/cpu/sparc/src/read_write.c,v $
//
//=============================================================

#include "sparc_iss.h"
#include "sparc.h"

extern FILE *ofp;

static uint32 Globals [9];              // Global[8] is a pseudo register used only for SWAP
static uint32 Locals  [NWINDOWS * 8];
static uint32 Outs    [NWINDOWS * 8];

uint32 Memory  [1 << (MEM_SIZE_BITS-2)];

uint32 *pSwapReg = &Globals[8];

//------------------------------------------------------------------------
//
static void DispReadReg (const uint32 reg_no, uint32 *value) 
{
    uint32  win;
   
    win = (GetPSR() & LOBITS4);
    Globals[0] = 0;

    switch ((reg_no >> 3) & LOBITS2) {
    case 0 : // Globals
        *value = Globals[reg_no & LOBITS3];
        break;
    case 1 : // Outs
        *value = Outs [(win << 3) | (reg_no & LOBITS3)];
        break;
    case 2 : // locals
        *value = Locals [(win << 3) | (reg_no & LOBITS3)];
        break;
    case 3 : // Ins
        win = (GetPSR() & LOBITS4) + 1;
        *value = Outs [(win << 3) | (reg_no & LOBITS3)];
        break;
    }
}

//------------------------------------------------------------------------
//
void RegisterDump (void) {

    uint32 a, b, c, d;

    ReadReg (OUTREG6, &a);
    fprintf(ofp, "Ma PC=%08x nPC=%08x PSR()=%08x (RegWin=%d N=%d Z=%d V=%d C=%d PIL=%x IRL=%x)\n",
             GetPC(), GetnPC(), GetPSR(), GetPSR() & LOBITS4,
             (GetPSR() >> PSR_CC_NEGATIVE) & LOBITS1,
             (GetPSR() >> PSR_CC_ZERO) & LOBITS1,
             (GetPSR() >> PSR_CC_OVERFLOW) & LOBITS1,
             (GetPSR() >> PSR_CC_CARRY) & LOBITS1, (GetPSR() >> PSR_INTERRUPT_LEVEL_0) & LOBITS4, GetIRL());
    fprintf(ofp, "Ma g0=(%08x) g1=(%08x) g2=(%08x) g3=(%08x)\n",
             Globals[0], Globals[1], Globals[2], Globals[3]);
    fprintf(ofp, "Ma g4=(%08x) g5=(%08x) g6=(%08x) g7=(%08x)\n",
             Globals[4], Globals[5], Globals[6], Globals[7]);
    DispReadReg (OUTREG0, &a);
    DispReadReg (OUTREG1, &b);
    DispReadReg (OUTREG2, &c);
    DispReadReg (OUTREG3, &d);
    fprintf(ofp, "Ma o0=(%08x) o1=(%08x) o2=(%08x) o3=(%08x)\n", a, b, c, d);
    DispReadReg (OUTREG4, &a);
    DispReadReg (OUTREG5, &b);
    DispReadReg (OUTREG6, &c);
    DispReadReg (OUTREG7, &d);
    fprintf(ofp, "Ma o4=(%08x) o5=(%08x) o6=(%08x) o7=(%08x)\n", a, b, c, d);
    DispReadReg (LOCALREG0, &a);
    DispReadReg (LOCALREG1, &b);
    DispReadReg (LOCALREG2, &c);
    DispReadReg (LOCALREG3, &d);
    fprintf(ofp, "Ma l0=(%08x) l1=(%08x) l2=(%08x) l3=(%08x)\n", a, b, c, d);
    DispReadReg (LOCALREG4, &a);
    DispReadReg (LOCALREG5, &b);
    DispReadReg (LOCALREG6, &c);
    DispReadReg (LOCALREG7, &d);
    fprintf(ofp, "Ma l4=(%08x) l5=(%08x) l6=(%08x) l7=(%08x)\n", a, b, c, d);
    DispReadReg (INREG0, &a);
    DispReadReg (INREG1, &b);
    DispReadReg (INREG2, &c);
    DispReadReg (INREG3, &d);
    fprintf(ofp, "Ma i0=(%08x) i1=(%08x) i2=(%08x) i3=(%08x)\n", a, b, c, d);
    DispReadReg (INREG4, &a);
    DispReadReg (INREG5, &b);
    DispReadReg (INREG6, &c);
    DispReadReg (INREG7, &d);
    fprintf(ofp, "Ma i4=(%08x) i5=(%08x) i6=(%08x) i7=(%08x)\n", a, b, c, d);
}

//------------------------------------------------------------------------
//
static void WriteRegAll (const int RegBase, const uint32 WriteValue) {
    switch ((RegBase >> 7) & 3) {
    case 0:
        Outs[RegBase & LOBITS7] = WriteValue;
        //if (Debug)
        //    fprintf(ofp, "          Read Outs[%0d]=%x\n", RegBase & LOBITS7, WriteValue); 
        break;
    case 1:
        Locals[RegBase & LOBITS7] = WriteValue;
        //if (Debug)
        //    fprintf(ofp, "          Read Locals[%0d]=%x\n", RegBase & LOBITS7, WriteValue); 
        break;
    case 2:
        Globals[RegBase & LOBITS4] = WriteValue;
        //if (Debug)
        //    fprintf(ofp, "          Read Globals[%0d]=%x\n", RegBase & LOBITS4, WriteValue); 
        break;
    case 3:
        fprintf(stderr, "*** WriteRegAll(): bad register address\n");
        exit(CODE_ERROR);
        break;
   }
}

//------------------------------------------------------------------------
//
static uint32 ReadRegsAll (const int reg_base) 
{
    switch ((reg_base >> 7) & LOBITS2) {
    case 0: return Outs[reg_base & LOBITS7]; break;
    case 1: return Locals[reg_base & LOBITS7]; break;
    case 2: return Globals[reg_base & LOBITS4]; break;
   }

   return 0;
}

//------------------------------------------------------------------------
//
static uint32 GetRegBase (const uint32 reg_no) 
{
    switch ((reg_no >> 3) & LOBITS2) {
    case 0 : // Globals
        return  (2 << 7) | (reg_no & LOBITS3);
        break;
    case 1 : // Outs
        return  ((GetPSR() & 0xf) << 3) | (reg_no & LOBITS3);
        break;
    case 2 : // locals
        return  (1 << 7) | ((GetPSR() & LOBITS4) << 3) | (reg_no & LOBITS3);
        break;
    case 3 : // Ins
        return   (((GetPSR()+1) & LOBITS4) << 3) | (reg_no & LOBITS3);
        break;
    }
    return 0;
}

//------------------------------------------------------------------------
//
void ReadReg (const uint32 reg_no, uint32 * const value) 
{
    int win;

    Globals[0] = 0;
    switch (reg_no >> 3) {
    case 0 : // Globals
        *value = Globals[reg_no & LOBITS3];
        break;
    case 1 : // Outs
        *value = Outs [((GetPSR() & LOBITS4) << 3) | (reg_no & LOBITS3)];
        break;
    case 2 : // locals
        *value = Locals [((GetPSR() & LOBITS4) << 3) | (reg_no & LOBITS3)];
        break;
    case 3 : // Ins
        win = ((GetPSR() & LOBITS4) + 1) & LOBITS4;
        *value = Outs [(win << 3) | (reg_no & LOBITS3)];
        break;
    }
}

//------------------------------------------------------------------------
//
void WriteReg (const uint32 value, const uint32 reg_no) 
{
   int win = 0;

   switch ((reg_no >>3) & LOBITS2) {
   case 0 : // Globals
      Globals[reg_no & LOBITS3] = value;
      Globals[0] = 0;
      break;
   case 1 : // Outs
      Outs [((GetPSR() & LOBITS4) << 3) | (reg_no & LOBITS3)] = value;
      break;
   case 2 : // locals
      Locals [((GetPSR() & LOBITS4) << 3) | (reg_no & LOBITS3)] = value;
      break;
   case 3 : // Ins
      win = ((GetPSR() & LOBITS4) + 1) & LOBITS4;
      Outs [(win << 3) | (reg_no & LOBITS3)] = value;
      break;
   }
}

//------------------------------------------------------------------------
//
void Ifetch (const uint64 physaddr, uint32 * const inst) 
{
    uint64 PA = physaddr & ADDR_MASK;
    int do_local_access = 1;

    if ((PA & (uint64)3) != 0) {
        fprintf(stderr, "Ifetch: Misaligned instruction fetch. PA=%llx\n", PA);
        RegisterDump();
        terminate = 1;
        return;
    }

    if (pMemCallback != NULL) 
        do_local_access = pMemCallback(physaddr, 4, inst, SPARC_MEM_CB_RD) == 0;

    if (do_local_access) {

        if ((PA & ~ADDR_MASK) != 0) {
            fprintf(stderr, "Ifetch : Trying to read instructions out of range! PA=%llx\n", PA);
            RegisterDump();
            terminate = 1;
            return;
        }

        *inst = Memory[PA >> (uint64)2];
    }
}

//------------------------------------------------------------------------
//
uint32 MemRead(const uint64 pa, const int bytes, const uint32 rd, const int signext) 
{
    uint32 value, value_ext, offset, reg_no;
    uint64 physaddr = pa;
    int do_local_access = 1;

    if (pMemCallback != NULL) 
        do_local_access = pMemCallback(pa, bytes, &value, SPARC_MEM_CB_RD) == 0;

    if (do_local_access) {
        physaddr = (physaddr & (((uint64)1 << MEM_SIZE_BITS)-(uint64)1));
        value = Memory[(physaddr & ~((uint64)3)) >> 2];
    }

    reg_no = GetRegBase(rd);

    switch (bytes) {
    case 1 :
        offset = (uint32)(physaddr & 3) * 8;
        value = ((value >> offset) & LOBITS8);
        value |= ((signext && (value & BIT7)) ? 0xffffff00 : 0);
        WriteRegAll(reg_no, value);
        break;
    case 2 : 
        offset = (uint32)(physaddr & 2) * 8;
        value = ((value >> offset) & LOBITS16);
        value |= ((signext && (value & BIT15)) ? 0xffff0000 : 0);
        WriteRegAll(reg_no, value);
        break;
    case 4 :
        WriteRegAll(reg_no, value);
        break;
    case 8 :
        value_ext = Memory[((physaddr & ~((uint64)3)) >> 2) + 1];
        WriteRegAll(reg_no, value);
        WriteRegAll(reg_no+1, value_ext);
        break;
    }

    return value;
}

//------------------------------------------------------------------------
//
void MemWrite(const uint64 pa, const int bytes, const uint32 rd) 
{
    uint32 value, mem_value, offset, reg_no;
    uint64 physaddr = pa;
    int do_local_access = 1;

    physaddr = (physaddr & (((uint64)1 << MEM_SIZE_BITS)-(uint64)1));

    if (rd == GLOBALREG8)
        reg_no = rd;
    else
        reg_no = GetRegBase(rd);
    value = ReadRegsAll(reg_no);

    if (pMemCallback != NULL) 
        do_local_access = pMemCallback(pa, bytes, &value, SPARC_MEM_CB_WR) == 0;

    if (do_local_access) {
        mem_value = Memory[(physaddr & ~((uint64)3)) >> (uint64)2];

        switch (bytes) {
        case 1 :
            offset = (uint32)(physaddr & LOBITS2) * 8;
            value = ((value & 0xff) << offset);
            mem_value = (mem_value & ~(0xff << offset)) | value;
            Memory[(physaddr & ~((uint64)3)) >> (uint64)2] = mem_value;
            break;
        case 2 : 
            offset = (uint32)(physaddr & LOBITS2) * 8;
            value = ((value & 0xffff) << offset);
            mem_value = (mem_value & ~(0xffff << offset)) | value;
            Memory[(physaddr & ~((uint64)3)) >> (uint64)2] = mem_value;
            break;
        case 4 :
            Memory[(physaddr & ~((uint64)3)) >> (uint64)2] = value;
            break;
        case 8 :
            Memory[(physaddr & ~((uint64)3)) >> (uint64)2] = value;
            value = ReadRegsAll(reg_no+1);
            Memory[((physaddr & ~((uint64)3)) >> (uint64)2)+(uint64)1] = value;
            break;
        }
    }
}

//------------------------------------------------------------------------
//
void LoadMemWord(const uint64 addr, const uint32 word)
{
    int do_local_access = 1;
    uint32 data = word;

    if (pMemCallback != NULL) 
        do_local_access = pMemCallback(addr, 4, &data, SPARC_MEM_CB_WR) == 0;

    if (do_local_access) {
        if (addr >= (1 << MEM_SIZE_BITS)) {
            fprintf(stderr, "*** LoadMemWord(): attempt to load text/data out of memory range\n");
            exit(USER_ERROR);
        }
        Memory[addr>>2] = word;
    }
}

