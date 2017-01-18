
# COMPILER FLAGS
FC=gfortran
FFLAGS=-fPIC -Wno-tabs
OFLAGS=-O3
DIR=gcm_model
#Modules, src, lib, and obj directories 
#lib and obj will be created if necessary
MDIR:=$(DIR)/modules
SDIR:=$(DIR)/src
LDIR:=lib
ODIR:=$(DIR)/obj
IFLAGS:=-I$(LDIR)
LFLAGS:=-L$(LDIR)
PYVERSION:=35m
#set python to version 3.5
PLATFORM:=$(shell uname -s)
RRTMGLWVER:=rrtmg_lw_v4.85


#ARCHIVE NAME(S)
LIBNAME:=librrtmglw.so
ifeq ($(PLATFORM),Darwin) 
	PYLIB:=lw.cpython-$(PYVERSION)-$(shell echo $(PLATFORM) | tr A-Z a-z).so
endif
ifeq ($(PLATFORM),Linux)
	PYLIB:=lw.cpython-$(PYVERSION)-x86_64-$(shell echo $(PLATFORM) | tr A-Z a-z)-gnu.so
endif


## Describe objects to build, PROBABLY SHOULD NOT EDIT ## 
#requisite objects
RSRC:=$(wildcard $(MDIR)/*.f90)
RFILES:=$(notdir $(RSRC))
ROBJ:=$(addprefix $(ODIR)/, $(RFILES:.f90=.o))

#main objects rrtm*_init and rrtm*_rad
MAINS:=$(SDIR)/rrtmg_lw_init.f90 $(SDIR)/rrtmg_lw_rad.f90
MFILES:=$(notdir $(MAINS))
MOBJ:=$(addprefix $(ODIR)/, $(MFILES:.f90=.o))

#delay compilation of these exclude files, not needed for the build (McICA and NetCDF libraries)
EXCL:=$(wildcard $(SDIR)/*mc*) $(wildcard $(SDIR)/*nc*)

#source objects, excluding the ones that should not be compiled. MAINS will be compiled last
SRC:=$(filter-out $(MAINS) $(EXCL), $(wildcard $(SDIR)/*.f*))
SRCFILES:=$(basename $(notdir $(SRC)))
SOBJ:=$(addprefix $(ODIR)/, $(addsuffix .o, $(SRCFILES)))



#TARGET RULES

#make object files from f90 source
$(ROBJ) : $(RSRC)
	@if [ -f $(MDIR)/$(@F:.o=.f90) ] ; then \
	$(FC) $(OFLAGS) $(FFLAGS) -c $(MDIR)/$(@F:.o=.f90) $(IFLAGS) -o $@ -J$(LDIR) ; \
	echo "$(FC) $(OFLAGS) $(FFLAGS) -c $(MDIR)/$(@F:.o=.f90) $(IFLAGS) -o $@ -J$(LDIR)" ; \
	else \
	$(FC) $(OFLAGS) $(FFLAGS) -c $(MDIR)/$(@F:.o=.f) $(IFLAGS) -o $@ -J$(LDIR) ; \
	$(FC) $(OFLAGS) $(FFLAGS) -c $(MDIR)/$(@F:.o=.f) $(IFLAGS) -o $@ -J$(LDIR) ; \
	fi 
	
$(SOBJ) : $(SRC)  
	@if [ -f $(SDIR)/$(@F:.o=.f90) ] ; then \
	$(FC) $(OFLAGS) $(FFLAGS) -c $(SDIR)/$(@F:.o=.f90) $(IFLAGS) -o $@ -J$(LDIR) ; \
	echo "$(FC) $(OFLAGS) $(FFLAGS) -c $(SDIR)/$(@F:.o=.f90) $(IFLAGS) -o $@ -J$(LDIR)" ; \
	else \
	$(FC) $(OFLAGS) $(FFLAGS) -c $(SDIR)/$(@F:.o=.f) $(IFLAGS) -o $@ -J$(LDIR) ; \
	echo "$(FC) $(OFLAGS) $(FFLAGS) -c $(SDIR)/$(@F:.o=.f) $(IFLAGS) -o $@ -J$(LDIR)" ; \
	fi

$(MOBJ) :  $(MAINS)
	@if [ -f $(SDIR)/$(@F:.o=.f90) ] ; then \
	$(FC) $(OFLAGS) $(FFLAGS) -c $(SDIR)/$(@F:.o=.f90) $(IFLAGS) -o $@ -J$(LDIR) ; \
	echo "$(FC) $(OFLAGS) $(FFLAGS) -c $(SDIR)/$(@F:.o=.f90) $(IFLAGS) -o $@ -J$(LDIR)" ; \
	else \
	$(FC) $(OFLAGS) $(FFLAGS) -c $(SDIR)/$(@F:.o=.f) $(IFLAGS) -o $@ -J$(LDIR) ; \
	echo "$(FC) $(OFLAGS) $(FFLAGS) -c $(SDIR)/$(@F:.o=.f) $(IFLAGS) -o $@ -J$(LDIR)" ; \
	fi


$(ODIR) :
	mkdir  $@ 

$(LDIR) : 
	mkdir  $@
