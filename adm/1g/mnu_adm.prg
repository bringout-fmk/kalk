#include "kalk.ch"


/*
 * ----------------------------------------------------------------
 *                                     Copyright Sigma-com software 
 * ----------------------------------------------------------------
 */
 
 
/*! \file fmk/kalk/adm/mnu_adm.prg
 *  \brief Meniji administrativnih opcija
 */


/*! \fn MAdminKALK()
 *  \brief Meni administrativnih opcija
 */
 
function MAdminKALK()
*{
private Opc:={}
private opcexe:={}
AADD(Opc,"1. instalacija db-a                               ")
AADD(opcexe, {|| goModul:oDatabase:install()})
AADD(opc,"2. security")
AADD(opcexe, {|| MnuSecMain()})
AADD(Opc,"3. markiraj polje roba/sez - sifk")
AADD(opcexe, {|| MPSifK()})
AADD(Opc,"4. ubaci partnera iz dokumenata u sifrarnik robe")
AADD(opcexe, {|| DobUSifK()})
AADD(opc,"5. sredjivanje kartica")
AADD(opcexe, {|| MenuSK() })
AADD(opc,"6. generacija kumulativne baze")
AADD(opcexe, {|| Gen9999()})
AADD(opc,"7. setmarza10")
AADD(opcexe, {|| SetMarza10()})
AADD(opc,"8. brisanje artikala koji se ne koriste")
AADD(opcexe, {|| Mnu_BrisiSifre()})
AADD(opc,"9. Set pdv cijene mpc/mpc2 u sifrarniku artikala")
AADD(opcexe, {|| SetPdvCijene()})
AADD(opc,"A. Pomnozi sa faktorom mpc/mpc2 u sifrarniku artikala")
AADD(opcexe, {|| SetPomnoziCijene()})


private Izbor:=1
Menu_SC("admk")
CLOSERET
*}


/*! \fn MenuSK()
 *  \brief Meni opcija za korekciju kartica artikala
 */

function MenuSK()
*{
PRIVATE Opc:={}
PRIVATE opcexe:={}
AADD(Opc,"1. korekcija prodajne cijene - nivelacija (VPC iz sifr.robe)    ")
AADD(opcexe, {|| KorekPC() })
AADD(Opc,"2. ispravka sifre artikla u dokumentima i sifrarniku")
AADD(opcexe, {|| RobaIdSredi() })
AADD(Opc,"3. korekcija nc storniranjem gresaka tipa NC=0   ")
AADD(opcexe, {|| KorekNC() })
AADD(Opc,"4. korekcija nc pomocu dok.95 (NC iz sifr.robe)")
AADD(opcexe, {|| KorekNC2() })
AADD(Opc,"5. korekcija prodajne cijene - nivelacija (MPC iz sifr.robe)")
AADD(opcexe, {|| KorekMPC() })
AADD(Opc,"6. postavljanje tarife u dokumentima na vrijednost iz sifrarnika")
AADD(opcexe, {|| KorekTar() })
AADD(Opc,"7. svodjenje artikala na primarno pakovanje")
AADD(opcexe, {|| NaPrimPak() })
private Izbor:=1
Menu_SC("kska")
CLOSERET
*}




