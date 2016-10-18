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
// $Id: sparc_iss.c,v 1.5 2016-10-18 05:53:31 simon Exp $
// $Source: /home/simon/CVS/src/cpu/sparc/src/sparc_iss.c,v $
//
//=============================================================

#if !defined(_WIN32) && !defined(_WIN64)
#include <getopt.h>
#else
extern char* optarg;
#endif
#include "sparc_iss.h"

int main(int argc, char **argv)
{
    char*  fname = "main.aout";
    int    PrintCount       = 0;
    int    Disassemble      = 0;
    int    terminate_reason = 0;
    uint32 UserBreakpoint   = NO_USER_BREAK;
    int    NumRunInst       = FOREVER;
    int    verbose          = 0;
    int    ProcNo           = 0;

    FILE   *fp;
    int    option;

    uint64 inst_count;

    fp = stdout;

    // Process the command line options 
    while ((option = getopt(argc, argv, "f:vdn:b:o:c")) != EOF)
        switch(option) {
        case 'o':
            if ((fp = fopen(optarg, "wb")) == NULL) {
                fprintf(stderr, "*** main(): Unable to open file %s for writing\n", optarg);
                exit(USER_ERROR);
            }
            break;
        case 'f':
            fname = optarg;
            break;
        case 'c':
            PrintCount = 1;
            break;
        case 'd':
            Disassemble = 1;
            break;
        case 'v':
            verbose = 1;
            break;
        case 'n':
            NumRunInst = strtol(optarg, NULL, 0);
            if (NumRunInst < FOREVER)
                NumRunInst = FOREVER;
            break;
        case 'b':
            UserBreakpoint = (uint32)strtol(optarg, NULL, 0);
            break;
        case 'h':
        case '?':
        default:
            fprintf(stderr, 
                    "Usage: %s [-v] [-d] [-n <num instructions>] [-b <breakpoint addr>] [-f <filename>] [-o <filename>] \n"
                    "\n"
                    "    -v Turn on Verbose display\n"
                    "    -d Disassemble mode\n"
                    "    -n Specify number of instructions to run (default: run until UNIMP)\n"
                    "    -b Specify address for breakpoint\n"
                    "    -f Specify executable ELF file (default main.out)\n"
                    "    -o Output file for Verbose data (default stdout)\n"
                    "\n"
                    , argv[0]);
            exit(NOERROR);
            break;
        }

    inst_count = Run(fname, NumRunInst, UserBreakpoint, Disassemble, verbose, fp, &terminate_reason);

    if (PrintCount)
        fprintf(fp, "Instruction count = %lld\n", inst_count);

    fclose(fp);

    return (terminate_reason > 0) ? terminate_reason : NOERROR;
}

