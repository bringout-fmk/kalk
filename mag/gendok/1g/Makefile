VERZIJA=CDX
MODUL=ka_m1gd

include /sclib/Makefile_clipper

SRCDOSROOT=c:\\dev\\fmk\\kalk\\mag\\gendok\\1g\\

PRGS=gen_dok.prg gen_im.prg preknm.prg

CS=
ASMS=

OBJS=$(OBJPRGS) $(OBJCS) $(OBJASMS)

all: $(OBJS)
	rm -f $(MODUL).lib 
	$(LIBEXE) $(MODUL) $(LIBCMD) ,,
	cp $(MODUL).lib $(LIB_DEST)

clean:
	rm -f *~
	rm -f *.xref
	rm -f *.xrefs
	rm -f *.html
	rm -f *.OBJ *.obj
	rm -f xref_files
	rm -f $(OBJS) *.bak *.BAK


