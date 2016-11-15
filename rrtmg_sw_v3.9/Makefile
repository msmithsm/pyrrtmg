include rrtmg_sw.mk

all: $(ODIR) $(LDIR) rrtmg_sw

mods: $(ROBJ) 
	
src: mods $(SOBJ) 

main: src $(MOBJ)

	
rrtmg_sw: main
ifeq ($(PLATFORM),Darwin)
	$(FC) $(OFLAGS) $(FFLAGS) -shared -o $(LDIR)/$(LIBNAME) $(MOBJ) $(ROBJ) $(SOBJ) -J$(LDIR) $(LFLAGS)
	f2py -c --f90flags="-Wno-tabs" -m sw rrtmg_sw.pyf rrtmg_sw_interface.f90 -lrrtmgsw -Ilib -Llib
	install_name_tool $(PYLIB) -change $(LDIR)/$(LIBNAME) $(realpath $(shell pwd)/$(LDIR)/$(LIBNAME))
	otool -L $(PYLIB)
	cd ../; ln -sf $(RRTMGSWVER)/$(PYLIB) 
else ($(PLATFORM),Linux)
	$(FC) $(OFLAGS) $(FFLAGS) -shared -o $(LDIR)/$(LIBNAME) $(MOBJ) $(ROBJ) $(SOBJ) -J$(LDIR) $(LFLAGS)
	f2py -c --f90flags="-Wno-tabs" -m sw rrtmg_sw.pyf rrtmg_sw_interface.f90 -lrrtmgsw -Ilib -Llib
	#patch the ELF file to add hard link to RRTM source shared object file. 
	patchelf --set-rpath $(realpath $(shell pwd)/$(LDIR)) $(PYLIB) 
	ldd $(PYLIB)
	cd ../; ln -sf $(RRTMGSWVER)/$(PYLIB)
endif

clean:
	rm -f *.mod *.o *.so 
	if [ -d $(ODIR) ] ; then rm -f $(ODIR)/*.o ; fi 
	if [ -d $(LDIR) ] ; then rm -f $(LDIR)/*.mod rm -f $(LDIR)/*.so ; fi
	cd ../; rm -f $(PYLIB) 

.PHONY: all, mods, src, main, rrtmg_sw, clean
