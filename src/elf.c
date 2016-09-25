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
// $Id: elf.c,v 1.3 2013-06-29 08:57:39 simon Exp $
// $Source: /home/simon/CVS/src/cpu/sparc/src/elf.c,v $
//
//=============================================================

#include "elf.h"

uint32 ReadElf (const char * const filename) 
{
    FILE *fp;
    int i, c;
    uint32 pcount, bytecount = 0;
    uint32 word;
    pElf32_Ehdr h;
    pElf32_Phdr *h2;
    char buf[sizeof(Elf32_Ehdr)];
    char buf2[sizeof(Elf32_Phdr)*4];
    char *ptr;
    uint32 text_count = 0;


    // Open program file ready for loading
    if ((fp = fopen(filename, "rb")) == NULL) {
        fprintf(stderr, "*** ReadElf(): Unable to open file %s for reading\n", filename);                       //LCOV_EXCL_LINE
        exit(USER_ERROR);                                                                                       //LCOV_EXCL_LINE
    }
    
    // Read elf header
    h = (pElf32_Ehdr) buf;
    for (i = 0; i < sizeof(Elf32_Ehdr); i++) {
        buf[i] = getc(fp);
        bytecount++;
        if (buf[i] == EOF) {
            fprintf(stderr, "*** ReadElf(): unexpected EOF\n");                                                 //LCOV_EXCL_LINE
            exit(USER_ERROR);                                                                                   //LCOV_EXCL_LINE
        } 
    }

    // Check some things
    // LCOV_EXCL_START
    ptr = ELF_IDENT;
    for (i = 0; i < 4; i++) {
        if (h->e_ident[i] != ptr[i]) {
            fprintf(stderr, "*** ReadElf(): not an ELF file\n");
            exit(USER_ERROR);
        }
    }

    if (SWAPHALF(h->e_type) != ET_EXEC) {
        fprintf(stderr, "*** ReadElf(): not an executable ELF file\n");
        exit(USER_ERROR);
    }

    if (SWAPHALF(h->e_machine) != EM_SPARC) {
        fprintf(stderr, "*** ReadElf(): not a SPARC ELF file\n");
        exit(USER_ERROR);
    }

    // Read program headers
    for (pcount=0 ; pcount < SWAPHALF(h->e_phnum); pcount++) {
        for (i = 0; i < sizeof(Elf32_Phdr); i++) {
            buf2[i+(pcount * sizeof(Elf32_Phdr))] = getc(fp);
            bytecount++;
            if (buf2[i] == EOF) {
                fprintf(stderr, "*** ReadElf(): unexpected EOF\n");
                exit(USER_ERROR);
            } 
        }
    }

    // Allocate some space for the program headers
    if ((h2 = (pElf32_Phdr *)malloc(SWAPHALF(h->e_phnum)*sizeof(Elf32_Phdr))) == NULL) {
        fprintf(stderr, "*** ReadElf(): memory allocation failure\n");
        exit(USER_ERROR);
    }
    // LCOV_EXCL_STOP

    // Load text/data segments
    for (pcount=0 ; pcount < SWAPHALF(h->e_phnum); pcount++) {
        h2[pcount] = (pElf32_Phdr) &buf2[pcount * sizeof(Elf32_Phdr)];

        // Gobble bytes until section start
        for (; bytecount < SWAP(h2[pcount]->p_offset); bytecount++) {
            if ((c = getc(fp)) == EOF) {
                fprintf(stderr, "*** ReadElf(): unexpected EOF\n");                                             //LCOV_EXCL_LINE
                exit(USER_ERROR);                                                                               //LCOV_EXCL_LINE
            }
        }

        // Check we can load the segment to memory
        if ((SWAP(h2[pcount]->p_vaddr) + SWAP(h2[pcount]->p_memsz)) >= (1 << MEM_SIZE_BITS)) {
            fprintf(stderr, "*** ReadElf(): segment memory footprint outside of internal memory range\n");      //LCOV_EXCL_LINE
            exit(USER_ERROR);                                                                                   //LCOV_EXCL_LINE
        }

        // For p_filesz bytes ...
        i = 0;
        word = 0;
        for (; bytecount < SWAP(h2[pcount]->p_offset) + SWAP(h2[pcount]->p_filesz); bytecount++) {
            if ((c = getc(fp)) == EOF) {
                fprintf(stderr, "*** ReadElf(): unexpected EOF\n");                                             //LCOV_EXCL_LINE
                exit(USER_ERROR);                                                                               //LCOV_EXCL_LINE
            }

            word |= (c << ((3-(bytecount&3)) * 8));
            if ((bytecount&3) == 3) {
                LoadMemWord(SWAP(h2[pcount]->p_vaddr) + i, word);
                i+=4;
                word = 0;
            }
        }

        if (pcount == 0)
            text_count = i;
    }

    free(h2);

    return text_count/4;

}

