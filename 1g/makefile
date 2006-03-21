VERZIJA=CDX
MODUL=KALK

PRGS=/dev/fmk/kalk/main/1g/e.prg
CS=
ASMS=

include /sclib/Makefile_clipper

FMK_LIBS=fmk_roba.lib fmk_rab.lib fmk_svi.lib fmk_pi.lib fmk_evn.lib fmk_sec.lib fmk_mes.lib fmk_lok.lib

SCLIB_LIBS=sc1g_arh.lib sc1g_ba.lib sc1g_cui.lib sc1g_db.lib sc1g_os.lib sc1g_ost.lib sc1g_par.lib sc1g_pr.lib sc1g_sif.lib sc1g_sql.lib sc1g_ut.lib sc2g_app.lib sc2g_db.lib sc1g_rpt.lib sc2g_cui.lib sc1g_key.lib 

MODUL_LIBS=ka_1adm.lib ka_1bk.lib ka_1db.lib ka_1dok.lib ka_1gd.lib ka_1ks.lib ka_1ma.lib ka_1par.lib ka_1pr.lib ka_1prp.lib ka_1rdb.lib ka_1rof.lib ka_1rpt.lib ka_1si.lib ka_1sif.lib ka_1sql.lib ka_1ut.lib ka_1vt.lib ka_2db.lib ka_2ma.lib ka_m1db.lib ka_m1dok.lib ka_m1gd.lib ka_m1ksg.lib ka_m1rdb.lib ka_m1rpt.lib ka_p1db.lib ka_p1dok.lib ka_p1gd.lib ka_p1rdb.lib ka_p1rpt.lib ka_s1is.lib ka_s1jer.lib ka_s1opt.lib ka_s1oz.lib ka_s1pf.lib ka_s1tv.lib ka_m2rpt.lib ka_s1vin.lib 

PREF2=lib $(LIB_DOS_DEST)
FMKLIBCMD=$(addprefix $(PREF2), $(SCLIB_LIBS) $(FMK_LIBS) $(MODUL_LIBS) )


OBJS=$(OBJPRGS) $(OBJCS) $(OBJASMS)

all:    cleaneobj mod 

cleaneobj:
	rm -f /dev/fmk/kalk/main/1g/e.obj
	
mod: $(OBJS)
	echo Prilikom kompilacije obj se napravi u tekucem direktoriju
	echo a blinker opet trazi obj fajl u orig direktoriju
	cp e.obj /dev/fmk/kalk/main/1g/
	/sclib/form_blinker_lnk.sh $(LINKCMD)
	/sclib/form_blinker_lnk_2.sh $(FMKLIBCMD)
	$(LINKEREXE) @_bl_.lnk   @_bl_2_.lnk $(DEBUGLINK) @H:\\CLIPPER\\$(VERZIJA)\\BL.LNK output e.exe
	cp e.exe $(EXEDEST)/$(MODUL).EXE

zip:
	/sclib/zip.sh h:\\cs\\FMK\\binary\\$(MODUL).zip ..\\chs\\\*.chs \\dev\\fmk\\AF\\cl_AF\\svi\\\*.chs \\dev\\fmk\\AF\\cl-AF\\roba\\\*.chs $(EXEDOSDEST)\\$(MODUL).EXE

commit:
	/sclib/commit.sh $(MODUL) h:\\cs\\FMK\\binary\\$(MODUL).zip
	/sclib/commit.sh $(MODUL) h:\\cs\\FMK\\binary\\sfx\\$(MODUL).exe
	
clean:
	rm -f *.obj *.OBJ
	rm -f $(OBJS) I$(MODULH).OBJ *.bak *.BAK

7exe:
	/sclib/7exe.sh h:\\cs\\fmk\\binary\\sfx\\$(MODUL).exe ..\\chs\\\*.chs \\dev\\fmk\\af\\cl-af\\svi\\\*.chs ..\\template\\\*.txt $(EXEDOSDEST)\\$(MODUL).EXE 

