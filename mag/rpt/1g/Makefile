VERZIJA=CDX
MODUL=ka_m1rpt

include /sclib/Makefile_clipper

SRCDOSROOT=h:\\dev\\fmk\\kalk\\mag\\rpt\\1g\\

PRGS=frm_kart.prg frm_kmag.prg mnu_izvj.prg rpt_fllm.prg rpt_kmag.prg rpt_llm.prg rpt_pgp.prg rpt_pru.prg rpt_rdob.prg rpt_reap.prg rpt_rflm.prg rpt_rpp.prg rpt_rpt.prg 

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


