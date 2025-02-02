//=============================================================
//
// Date: 13th October 2004
//
// MIT License
//
// Copyright (c) 2004 - 2025 Simon Southwell
//
// Permission is hereby granted, free of charge, to any person obtaining a copy
// of this software and associated documentation files (the "Software"), to deal
// in the Software without restriction, including without limitation the rights
// to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
// copies of the Software, and to permit persons to whom the Software is
// furnished to do so, subject to the following conditions:
//
// The above copyright notice and this permission notice shall be included in all
// copies or substantial portions of the Software.
//
// THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
// IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
// FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
// AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
// LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
// OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE
// SOFTWARE.
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
extern void   RegisterDump (void);
#endif


