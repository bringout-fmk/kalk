VERZIJA=CDX
MODUL=ka_1rdb

include /sclib/Makefile_clipper

SRCDOSROOT=c:\\dev\\fmk\\kalk\\razdb\\1g\\

PRGS=fak_kal.prg fin.prg gen_fakt.prg ka_ka.prg kont_dok.prg tops.prg tops_ka.prg mnu_raz.prg

CS=
ASMS=

OBJS=$(OBJPRGS) $(OBJCS) $(OBJASMS)

all: $(OBJS)
	rm -f $(MODUL).lib 
	$(LIBEXE) $(MODUL) $(LIBCMD) ,,
	cp $(MODUL).lib $(CLIPPERROOT)$(DEBUGDIR)/$(VERZIJA)/

	
clean:
	rm -f *~
	rm -f *.xref
	rm -f *.xrefs
	rm -f *.html
	rm -f *.OBJ *.obj
	rm -f xref_files
	rm -f $(OBJS) *.bak *.BAK


