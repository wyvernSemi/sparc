#ifndef _LIBSPARC_H_
#define _LIBSPARC_H_

#define stdin   0
#define stdout  1
#define stderr  2

#define BITS_PER_UNIT 8

#define EOF		    -1

typedef unsigned int FILE;
typedef int          DItype    __attribute__ ((mode (DI)));
typedef int          word_type __attribute__ ((mode (__word__)));
typedef int          SItype    __attribute__ ((mode (SI)));
typedef unsigned int USItype   __attribute__ ((mode (SI)));

#if LIBGCC2_WORDS_BIG_ENDIAN
  struct DIstruct {SItype high, low;};
#else
  struct DIstruct {SItype low, high;};
#endif

typedef union
{
  struct DIstruct s;
  DItype ll;
} DIunion;

DItype __lshrdi3 (DItype u, word_type b);
void startup();
int fprintf (int stream, char *format, ...);
void exit (int status);

#endif
