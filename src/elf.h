//=============================================================
//                                                                         
// Copyright (c) 2004 Simon Southwell. All rights reserved.
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
// $Id: elf.h,v 1.2 2013/06/25 18:28:11 simon Exp $
// $Source: /home/simon/CVS/src/cpu/sparc/src/elf.h,v $
//
//=============================================================

#ifndef _ELF_H_
#define _ELF_H_

#include <stdio.h>

#include "sparc.h"

#define EI_NIDENT       16

#define ET_NONE         0
#define ET_REL          1
#define ET_EXEC         2
#define ET_DYN          3
#define ET_CORE         4
#define ET_LOPROC       0xff00
#define ET_HIPROC       0xffff

#define EM_NONE         0
#define EM_M32          1
#define EM_SPARC        2
#define EM_386          3
#define EM_68K          4
#define EM_88K          5
#define EM_860          7
#define EM_MIPS         8

#define ELF_IDENT       "\177ELF"

#if defined( __CYGWIN__) || defined(WIN32) || defined(__x86_64__) || defined(_M_X64) || defined(__i386) || defined(_M_IX86)
#define SWAP(_ARG) (((_ARG >> 24)&0xff) | ((_ARG >> 8)&0xff00) | ((_ARG << 8)&0xff0000) | ((_ARG << 24)&0xff000000))
#define SWAPHALF(_ARG) (uint32)(((_ARG>>8)&0xff) | ((_ARG<<8)&0xff))
#else
#define SWAP(_ARG) _ARG
#define SWAPHALF(_ARG) _ARG
#endif

typedef unsigned int   Elf32_Addr;
typedef unsigned int   Elf32_Word;
typedef unsigned int   Elf32_Sword;
typedef unsigned int   Elf32_Off;
typedef unsigned short Elf32_Half;

typedef struct {
    unsigned char e_ident[EI_NIDENT] ;
    Elf32_Half e_type ;        
    Elf32_Half e_machine ;    
    Elf32_Word e_version ;
    Elf32_Addr e_entry ;
    Elf32_Off  e_phoff ;
    Elf32_Off  e_shoff;
    Elf32_Word e_flags ;
    Elf32_Half e_ehsize ;
    Elf32_Half e_phentsize ;
    Elf32_Half e_phnum ;
    Elf32_Half e_shentsize ;
    Elf32_Half e_shnum ;
    Elf32_Half e_shstrndx ;
} Elf32_Ehdr, *pElf32_Ehdr ;

typedef struct {
    Elf32_Word p_type;
    Elf32_Off  p_offset;
    Elf32_Addr p_vaddr;
    Elf32_Addr p_paddr;
    Elf32_Word p_filesz;
    Elf32_Word p_memsz;
    Elf32_Word p_flags;
    Elf32_Word p_align;
} Elf32_Phdr, *pElf32_Phdr;

typedef struct {
    Elf32_Word  sh_name;        /* section name */
    Elf32_Word  sh_type;        /* SHT_... */
    Elf32_Word  sh_flags;       /* SHF_... */
    Elf32_Addr  sh_addr;        /* virtual address */
    Elf32_Off   sh_offset;      /* file offset */
    Elf32_Word  sh_size;        /* section size */
    Elf32_Word  sh_link;        /* misc info */
    Elf32_Word  sh_info;        /* misc info */
    Elf32_Word  sh_addralign;   /* memory alignment */
    Elf32_Word  sh_entsize;     /* entry size if table */
} Elf32_Shdr, *pElf32_Shdr;

#define PrintPhdr(_P) {\
    fprintf(stderr, " p_type = %x\n p_offset = %x\n p_vaddr = %x\n p_paddr = %x\n p_filesz = %x\n p_memsz = %x\n p_flags = %x\n p_align = %x\n\n", \
                    SWAP(_P->p_type), SWAP(_P->p_offset),  SWAP(_P->p_vaddr), SWAP(_P->p_paddr),  SWAP(_P->p_filesz), SWAP(_P->p_memsz),  SWAP(_P->p_flags), SWAP(_P->p_align)); }

#endif
