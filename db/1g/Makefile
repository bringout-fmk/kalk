VERZIJA=CDX
MODUL=ka_1db

include /sclib/Makefile_clipper

SRCDOSROOT=c:\\dev\\fmk\\kalk\\db\\1g\\

PRGS=azur.prg box_st.prg ut.prg db_cre.prg
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


