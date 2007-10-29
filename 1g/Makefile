VERZIJA=CDX
MODUL=KALK

EOBJCOPY=echo nista za kopirati
PRGS=e.prg
CS=
ASMS=


FMK_LIBS=fmk_roba.lib fmk_rab.lib fmk_svi.lib fmk_pi.lib fmk_evn.lib fmk_sec.lib fmk_mes.lib fmk_lok.lib fmk_rule.lib fmk_exp.lib

SCLIB_LIBS=sc1g_arh.lib sc1g_ba.lib sc1g_cui.lib sc1g_db.lib sc1g_os.lib sc1g_ost.lib sc1g_par.lib sc1g_pr.lib sc1g_sif.lib sc1g_sql.lib sc1g_ut.lib sc2g_app.lib sc2g_db.lib sc1g_rpt.lib sc2g_cui.lib sc1g_key.lib sc_epl2.lib sc_gvp.lib

MODUL_LIBS=ka_1adm.lib ka_1db.lib ka_1dok.lib ka_1gd.lib ka_1ma.lib ka_1par.lib ka_1pr.lib ka_1prp.lib ka_1rdb.lib ka_1rof.lib ka_1rpt.lib ka_1si.lib ka_1sif.lib ka_1ut.lib ka_1vt.lib ka_2db.lib ka_2ma.lib ka_m1db.lib ka_m1dok.lib ka_m1gd.lib ka_m1ksg.lib ka_m1rdb.lib ka_m1rpt.lib ka_p1db.lib ka_p1dok.lib ka_p1gd.lib ka_p1rdb.lib ka_p1rpt.lib ka_s1is.lib ka_s1jer.lib ka_s1pf.lib ka_s1tv.lib ka_m2rpt.lib ka_s1vin.lib ka_1int.lib

EOBJCOPY=echo nista za kopirati
include $(SC_BUILD_HOME_DIR)/sclib/Makefile_clipper

LIBEXE:=@echo pokrenute make exe  !
CPLIB:=@echo pokrenuti make exe !
RMLIB:=@echo pokrenuti make exe !
e.obj : $(SC_BUILD_HOME_DIR)/sclib/sc.ch $(SC_BUILD_HOME_DIR)/sclib/std_cdx.ch ../kalk.ch


lib: exe
