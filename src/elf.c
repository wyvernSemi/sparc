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

