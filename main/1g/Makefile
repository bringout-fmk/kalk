VERZIJA=CDX
MODUL=ka_1ma

include /sclib/Makefile_clipper

SRCDOSROOT=c:\\dev\\fmk\\kalk\\main\\1g\\

PRGS=app_srv.prg

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


