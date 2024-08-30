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
