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
// $Id: sparc_iss.h,v 1.1 2013/06/25 18:28:11 simon Exp $
// $Source: /home/simon/CVS/src/cpu/sparc/src/sparc_iss.h,v $
//
//=============================================================

#ifndef _SPARC_ISS_H_
#define _SPARC_ISS_H_

#include <stdio.h>
#include <stdlib.h>

#ifdef WIN32

#include <windows.h>

extern int getopt(int, char * const *, const char *);
typedef UINT64             uint64;
typedef INT64              int64;
typedef UINT32             uint32;

#else

#include <stdint.h>

typedef uint64_t           uint64;
typedef int64_t            int64;
typedef uint32_t           uint32;

#endif

#define FOREVER            0
#define ONCE               1

#define NOERROR            0
#define USER_ERROR         1
#define UNIMP_ERROR        2
#define RUNTIME_ERROR      3
#define CODE_ERROR         4

#define NO_USER_BREAK      0xffffffff
#define BREAK_SINGLE_STEP  0xfffffffe

#define SPARC_MEM_CB_RD    0
#define SPARC_MEM_CB_WR    1

#define TERMINATE_NORM     -1
#define TERMINATE_BREAK     1
#define TERMINATE_STEP      2

typedef int   (*p_memcallback_t) (const uint64 ByteAddr, const int NumBytes, uint32 *Data, int Type);

// Function prototypes

extern uint64 Run (const char*  ElfFileName, 
                   const uint32 ExecCount, 
                   const uint32 UserBreakpoint, 
                   const int    Disassemble, 
                   const int    Verbose, 
                   FILE*        Ofp, 
                   int*         TerminateReason);

extern void   register_mem_callback (p_memcallback_t cbFunc);
extern uint32 GetPC        (void);

#endif


