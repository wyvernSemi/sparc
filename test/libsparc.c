/************************************************************************
   libsparc.c                                            Date: 2004/10/27

   $Id: libsparc.c,v 1.1 2013/06/25 18:30:56 simon Exp $
   $Source: /home/simon/CVS/src/cpu/sparc/test/libsparc.c,v $

 ************************************************************************/
#include "libsparc.h"

DItype __lshrdi3 (DItype u, word_type b)
{
  DIunion w;
  word_type bm;
  DIunion uu;

  if (b == 0)
    return u;

  uu.ll = u;

  bm = (sizeof (SItype) * BITS_PER_UNIT) - b;
  if (bm <= 0)
    {
      w.s.high = 0;
      w.s.low = (USItype)uu.s.high >> -bm;
    }
  else
    {
      USItype carries = (USItype)uu.s.high << bm;
      w.s.high = (USItype)uu.s.high >> b;
      w.s.low = ((USItype)uu.s.low >> b) | carries;
    }

  return w.ll;
}

void startup()
{
    return;
}

int fprintf (int stream, char *format, ...) 
{
    return 0;
}

void putc(int c, FILE *ofp)
{
    return;
}

int getc(FILE *ifp)
{
    return 0;
}

void BadTrap(void)
{
    exit(1);
}
