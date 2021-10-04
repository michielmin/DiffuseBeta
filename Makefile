# makefile for OpacityTool (with comments!)
# MacOSX 10.10.1 gfortran gcc version 5.0.0 20141005
#

# compiler= FC, flags = FFlags
# linker= LINKER, flags= LDFLAGS, libraries=LIBS

FC	  = ifort
LINKER  = ifort

ifeq ($(gfort),true)
	FC	  = gfortran
	LINKER	  = gfortran
endif

# array boundary check
ifeq ($(debug),true)
  ifeq ($(gfort),true)
    DEBUGGING = -Wall -Wno-unused-variable -fbounds-check -fbacktrace -fcheck=all
  else	
    DEBUGGING = -check all -g -traceback -check bounds -check uninit -O0
  endif
endif

# Platform specific compilation options
ifeq ($(gfort),true)
  FLAG_ALL      = -O5 -finit-local-zero
  FLAG_LINUX    = -ffixed-line-length-132 -cpp
  FLAG_MAC      = -m64 -ffixed-line-length-132 -cpp
else
  FLAG_ALL      = -O3 -g -extend-source -zero -prec-div -assume buffered_io -fp-model strict -heap-arrays
  FLAG_LINUX    = -xHOST -fpp
  FLAG_MAC      = -xHOST -qopt-prefetch -static-intel -fpp -heap-arrays 
endif

ifeq ($(shell uname),Linux)
  FFLAGS   = $(FLAG_ALL) $(FLAG_LINUX) -diag-disable vec $(DEBUGGING) 
  LDFLAGS  = $(FLAG_ALL) $(FLAG_LINUX) -I$(HOME)/include $(DEBUGGING)
else
  FFLAGS  = $(FLAG_ALL) $(FLAG_MAC) $(DEBUGGING)  
  LDFLAGS = $(FLAG_ALL) $(FLAG_MAC) $(DEBUGGING) 
endif


# files to make
OBJS	= Main.o \
		DiffuseBeta.o \
		Lapack.o

# program name and install location
PROGRAM       = DiffuseBeta
DEST	      = ${HOME}/bin

# make actions 
all:		$(PROGRAM)
clean:;		rm -f $(OBJS) $(PROGRAM) *.mod *.i *.i90
install:	$(PROGRAM)
		mv $(PROGRAM) $(DEST)

# how to compile program 
.SUFFIXES : .o .f .f90 .F

.f.o:
	$(FC) $(LDFLAGS) -c $< -o $@ 

.f90.o:
	$(FC) $(LDFLAGS) -c $< -o $@ 

.F.o:
	$(FC) $(LDFLAGS) -c $< -o $@ 

$(PROGRAM):     $(OBJS)
		$(LINKER) $(LDFLAGS) $(OBJS) $(LIBS) -o $(PROGRAM)

