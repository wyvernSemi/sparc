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
//=============================================================

#ifndef _INST_H_
#define _INST_H_

extern uint32 TrapType;
extern uint32 TBR;
extern uint32 WIM;

extern void UNIMP   (pDecode_t d);
extern void CALL    (pDecode_t d);
extern void BICC    (pDecode_t d);
extern void SETHI   (pDecode_t d);
extern void SLL     (pDecode_t d);
extern void SRL     (pDecode_t d);
extern void SRA     (pDecode_t d);
extern void RDY     (pDecode_t d);
extern void RDPSR   (pDecode_t d);
extern void RDWIM   (pDecode_t d);
extern void RDTBR   (pDecode_t d);
extern void WRY     (pDecode_t d);
extern void WRPSR   (pDecode_t d);
extern void WRWIM   (pDecode_t d);
extern void WRTBR   (pDecode_t d);
extern void JMPL    (pDecode_t d);
extern void RETT    (pDecode_t d);
extern void TICC    (pDecode_t d);
extern void SAVE    (pDecode_t d);
extern void RESTORE (pDecode_t d);
extern void FLUSH   (pDecode_t d);
extern void MULSCC  (pDecode_t d);
extern void LD      (pDecode_t d);
extern void LDUB    (pDecode_t d);
extern void LDUH    (pDecode_t d);
extern void LDD     (pDecode_t d);
extern void LDSB    (pDecode_t d);
extern void LDSH    (pDecode_t d);
extern void ST      (pDecode_t d);
extern void STB     (pDecode_t d);
extern void STH     (pDecode_t d);
extern void STD     (pDecode_t d);
extern void SWAP    (pDecode_t d);
extern void LDSTUB  (pDecode_t d);
extern void MUL     (pDecode_t d);
extern void DIV     (pDecode_t d);
extern void ADD     (pDecode_t d);
extern void AND     (pDecode_t d);

#endif
