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
    int    DumpRegs         = 0;
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
    while ((option = getopt(argc, argv, "f:vdn:b:o:cr")) != EOF)
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
            PrintCount  = 1;
            break;
        case 'r':
            DumpRegs    = 1;
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
        fprintf(fp, "Instruction count = %lld\n", (long long)inst_count);

    if (DumpRegs)
        RegisterDump();

    fclose(fp);

    return (terminate_reason > 0) ? terminate_reason : NOERROR;
}

