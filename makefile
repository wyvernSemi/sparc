########################################################## 
#
# Makefile for 'sparc_iss' instruction set simulator
#
# Date: 13th October 2004
#
# MIT License
#
# Copyright (c) 2004 - 2025 Simon Southwell
#
# Permission is hereby granted, free of charge, to any person obtaining a copy
# of this software and associated documentation files (the "Software"), to deal
# in the Software without restriction, including without limitation the rights
# to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
# copies of the Software, and to permit persons to whom the Software is
# furnished to do so, subject to the following conditions:
#
# The above copyright notice and this permission notice shall be included in all
# copies or substantial portions of the Software.
#
# THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
# IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
# FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
# AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
# LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
# OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE
# SOFTWARE.
#
########################################################## 




# 
##########################################################

##########################################################
# Definitions
##########################################################

BASENAME   = sparc
TARGET     = $(BASENAME)_iss
OBJECTS    = $(BASENAME)_iss.o execute.o inst.o read_write.o elf.o dis.o

LCOVINFO   = sparc.info
COVLOGFILE = cov.log
COVDIR     = cov_html
COVEXCL    = dis.c sparc_iss.c

SRCDIR     = src
OBJDIR     = objs
TESTDIR=test

#ARCHOPT    = -m32
ARCHOPT    =

COVOPTS    = -coverage
OPTFLAGS   = -g

#CC         = cc
#COPTS      = -fast -xCC -I. -Isrc
CC         = gcc
COPTS      = $(ARCHOPT) $(OPTFLAGS) -I. -Isrc
#COPTS      = $(COVOPTS) $(OPTFLAGS) -I. -Isrc

##########################################################
# Dependency definitions
##########################################################

all : $(TARGET)

$(OBJDIR)/sparc_iss.o  : $(SRCDIR)/sparc_iss.c $(SRCDIR)/sparc_iss.h
$(OBJDIR)/execute.o    : $(SRCDIR)/inst.h $(SRCDIR)/execute.c $(SRCDIR)/sparc.h $(SRCDIR)/sparc_iss.h
$(OBJDIR)/inst.o       : $(SRCDIR)/sparc.h $(SRCDIR)/sparc_iss.h
$(OBJDIR)/read_write.o : $(SRCDIR)/read_write.c $(SRCDIR)/sparc.h $(SRCDIR)/sparc_iss.h
$(OBJDIR)/elf.o        : $(SRCDIR)/elf.c $(SRCDIR)/sparc.h $(SRCDIR)/elf.h $(SRCDIR)/sparc_iss.h
$(OBJDIR)/dis.o        : $(SRCDIR)/dis.c $(SRCDIR)/sparc.h $(SRCDIR)/elf.h $(SRCDIR)/sparc_iss.h

##########################################################
# Compilation rules
##########################################################

$(TARGET) : $(OBJDIR) $(OBJECTS:%=$(OBJDIR)/%)
	@$(CC) $(OBJECTS:%=$(OBJDIR)/%) $(ARCHOPT) $(COVOPTS) -o $(TARGET)

$(OBJDIR)/%.o : $(SRCDIR)/%.c
	@$(CC) $(COPTS) -c $< -o $@ 
    
# Rule to build object file temporary directory
$(OBJDIR):
	@mkdir $(OBJDIR)

##########################################################
# Microsoft Visual C++ 2010
##########################################################

MSVCDIR=./msvc
MSVCCONF="Release"

mscv_dummy:

MSVC:   mscv_dummy
	@MSBuild.exe $(MSVCDIR)/$(BASENAME).sln /nologo /v:q /p:Configuration=$(MSVCCONF) /p:OutDir='..\..\'
	@rm *.pdb

##########################################################
# coverage
##########################################################

coverage:
	@lcov -c -d $(OBJDIR) -o $(LCOVINFO) > $(COVLOGFILE)
	@lcov -r $(LCOVINFO) $(COVEXCL) -o $(LCOVINFO) >> $(COVLOGFILE)
	@genhtml -o $(COVDIR) $(LCOVINFO) >> $(COVLOGFILE)

##########################################################
# Test
##########################################################

test: run_test
run_test: $(TARGET)
	@cd test; sh runtests

##########################################################
# Clean up rules
##########################################################

clean:
	@/bin/rm -rf $(TARGET) $(OBJDIR) $(OBJDIR)/*.g* *.info $(TESTDIR)/*.o $(TESTDIR)/*.aout $(TESTDIR)/*.map $(TESTDIR)/*.sid

cleanmsvc:
	@/bin/rm -rf $(MSVCDIR)/*.sdf $(MSVCDIR)/*.suo $(MSVCDIR)/$(BASENAME)/*.vcxproj.user $(MSVCDIR)/Debug $(MSVCDIR)/Release $(MSVCDIR)/ipch $(MSVCDIR)/$(BASENAME)/Debug $(MSVCDIR)/$(BASENAME)/Release

sparkle: clean cleanmsvc
	@rm -f *.exe *.log
