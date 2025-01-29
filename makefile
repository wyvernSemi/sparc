##########################################################
# 
# Copyright (c) 2004 - 2024 Simon Southwell. All rights reserved.
#
# Date: 13th October 2004  
#
# Makefile for 'sparc_iss' instruction set simulator
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
