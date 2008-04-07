#include "..\..\kalk.ch"
/*
 * ----------------------------------------------------------------
 *                                     Copyright Sigma-com software 
 * ----------------------------------------------------------------
 *
 */


/*! \file fmk/kalk/main/2g/app.prg
 *  \brief
 */
 
 
/*! \fn TKalkModNew()
 *  \brief
 */

function TKalkModNew()
local oObj

oObj:=TKalkMod():new()

oObj:self:=oObj
return oObj


#ifdef CPP
/*! \class TKalkMod
 *  \brief KALK aplikacijski modul
 */

class TKalkMod: public TAppMod
{
	public:
	*void dummy();
	*void setGVars();
	*void mMenu();
	*void mMenuStandard();
	*void sRegg();
	*void initdb();
	*void srv();
	
#endif

#ifndef CPP
#include "class(y).ch"
CREATE CLASS TKalkMod INHERIT TAppMod
	EXPORTED:
	method dummy 
	method setGVars
	method mMenu
	method mMenuStandard
	method sRegg
	method initdb
	method srv
END CLASS
#endif


/*! \fn TKalkMod::dummy()
 *  \brief dummy
 */

*void TKalkMod::dummy()
*{
method dummy()
return
*}


*void TKalkMod::initdb()
*{
method initdb()

::oDatabase:=TDBKalkNew()

return nil
*}


/*! \fn *void TKalkMod::mMenu()
 *  \brief Osnovni meni KALK modula
 */
*void TKalkMod::mMenu()
*{
method mMenu()

private Izbor

say_fmk_ver()

SETKEY(K_SH_F1,{|| Calc()})
Izbor:=1

// provjeri da li je read only
CheckROnly(KUMPATH + "\KALK.DBF")

O_DOKS
select doks
TrebaRegistrovati(10)
gDuzKonto:=LEN(mkonto) 
select doks

// skeniranje prodavnica automatsko...
pl_scan_automatic()

use

#ifdef PROBA
	//KEYBOARD "213"
#endif

gRobaBlock:={|Ch| RobaBlock(Ch)}
//KalksInit()
@ 1,2 SAY padc(gTS+": "+gNFirma,50,"*")

::mMenuStandard()
::quit()

return nil
*}


*void TKalkMod::mMenuStandard()
*{
method mMenuStandard

private opc:={}
private opcexe:={}

#ifdef PROBA
//	KEYBOARD "2253"
#endif

AADD(opc,   "1. unos/ispravka dokumenata                ")
if (ImaPravoPristupa(goModul:oDataBase:cName,"DOK","UNOSDOK"))
	AADD(opcexe,{|| Knjiz()} )
else
	AADD(opcexe, {|| MsgBeep(cZabrana)})
endif
AADD(opc,   "2. izvjestaji")
AADD(opcexe, {|| MIzvjestaji()})
AADD(opc,   "3. pregled dokumenata")
AADD(opcexe, {|| MBrDoks()})
AADD(opc,   "4. generacija dokumenata")
if (ImaPravoPristupa(goModul:oDataBase:cName,"DOK","GENDOK"))
	AADD(opcexe,{|| MGenDoks()})
else
	AADD(opcexe, {|| MsgBeep(cZabrana)})
endif
AADD(opc,   "5. moduli - razmjena podataka ")
if (ImaPravoPristupa(goModul:oDataBase:cName,"RAZDB","MODULIRAZMJENA"))
	AADD(opcexe, {|| ModRazmjena()})
else
	AADD(opcexe, {|| MsgBeep(cZabrana)})
endif
AADD(opc,   "6. udaljene lokacije  - razmjena podataka")
if (ImaPravoPristupa(goModul:oDataBase:cName,"RAZDB","PRENOSDISKETE"))
	AADD(opcexe, {|| PrenosDiskete()})
else
	AADD(opcexe, {|| MsgBeep(cZabrana)})
endif
AADD(opc,   "7. ostale operacije nad dokumentima")
AADD(opcexe, {|| MAzurDoks()})
AADD(opc,"------------------------------------")
AADD(opcexe, nil)
AADD(opc,   "8. sifrarnici")
AADD(opcexe,{|| Sifre()})
AADD(opc,   "9. administriranje baze podataka") 
if (ImaPravoPristupa(goModul:oDataBase:cName,"MAIN","DBADMIN"))
	AADD(opcexe, {|| MAdminKalk()})
else
	AADD(opcexe, {|| MsgBeep(cZabrana)})
endif
AADD(opc,"------------------------------------")
AADD(opcexe, nil)

// najcesece koristenje opcije
AADD(opc,   "A. stampa azuriranog dokumenta")
AADD(opcexe, {|| Stkalk(.t.)})
AADD(opc,   "P. povrat dokumenta u pripremu") 
if (ImaPravoPristupa(goModul:oDataBase:cName,"DOK","POVRATDOK"))
	AADD(opcexe, {|| Povrat()})
else
	AADD(opcexe, {|| MsgBeep(cZabrana)})
endif
AADD(opc,"------------------------------------")
AADD(opcexe, nil)
AADD(opc,   "X. parametri")
if (ImaPravoPristupa(goModul:oDataBase:cName,"PARAM","PARAMETRI"))
	AADD(opcexe, {|| Params()})
else
	AADD(opcexe, {|| MsgBeep(cZabrana)})
endif
private Izbor:=1
Menu_SC("gkas", .t. , lPodBugom)

return
*}

*void TKalkMod::sRegg()
*{
method sRegg()
sreg("KALK.EXE","KALK")
return
*}


*void TKalkMod::srv()
*{
method srv()
? "Pokrecem KALK aplikacijski server"
if (MPar37("/KONVERT", goModul))
	if LEFT(self:cP5,3)=="/S="
		cKonvSez:=SUBSTR(self:cP5,4)
		? "Radim sezonu: " + cKonvSez
		if cKonvSez<>"RADP"
			// prebaci se u sezonu cKonvSez
			goModul:oDataBase:cSezonDir:=SLASH+cKonvSez
 			goModul:oDataBase:setDirKum(trim(goModul:oDataBase:cDirKum)+SLASH+cKonvSez)
 			goModul:oDataBase:setDirSif(trim(goModul:oDataBase:cDirSif)+SLASH+cKonvSez)
 			goModul:oDataBase:setDirPriv(trim(goModul:oDataBase:cDirPriv)+SLASH+cKonvSez)
		endif
	endif
	goModul:oDataBase:KonvZN()
	goModul:quit(.f.)
endif
return
*}


/*! \fn *void TKalkMod::setGVars()
 *  \brief opste funkcije KALK modula
 */
*void TKalkMod::setGVars()
*{
method setGVars()

local cPPSaMr 
local cBazniDir
local cMrRs
local cOdradjeno
local cSekcija
local cVar,cVal

::super:setTGVars()
SetFmkRGVars()
SetFmkSGVars()

PUBLIC KursLis:="1"
PUBLIC gMetodaNC:="2"
public gDefNiv:="D"
public gDecKol:=5
public gKalo:="2"
public gMagacin:="2"
public gPDVMagNab:="N"
if IsPDV()
	gPDVMagNab:="D"
endif
public gRCRP := "C"
public gTS:="Preduzece"
public gPotpis:="N"
public g10Porez:="N"
public gDirFin:=""
public gDirMat:=""
public gDirFiK:=""
public gDirMaK:=""
public gDirFakt:=""
public gDirFaKK:=""
public gBrojac:="D"
public gRokTr:="N"
public gVarVP:="1"
public gAFin:="D"
public gAMat:="0"
public gAFakt:="D"
public gVodiKalo:="N"
O_PARAMS
private cSection:="K",cHistory:=" "; aHistory:={}

public gNW:="X"  // new vawe
public gVarEv:="1"  // 1-sa cijenama   2-bez cijena
public gBaznaV:="D"
public c24T1:=padr("Tr 1",15)
public c24T2:=padr("Tr 2",15)
public c24T3:=padr("Tr 3",15)
public c24T4:=padr("Tr 4",15)
public c24T5:=padr("Tr 5",15)
public c24T6:=padr("Tr 6",15)
public c24T7:=padr("Tr 7",15)
public c24T8:=padr("Tr 8",15)

public c10T1:="PREVOZ.T"
public c10T2:="AKCIZE  "
public c10T3:="SPED.TR "
public c10T4:="CARIN.TR"
public c10T5:="ZAVIS.TR"

public cRNT1:="        "
public cRNT2:="R.SNAGA "
public cRNT3:="TROSK 3 "
public cRNT4:="TROSK 4 "
public cRNT5:="TROSK 5 "

public gTops:="0 "   // Koristim TOPS - 0 - ne prenosi se podaci,"1 " - prod mjes 1
public gFakt:="0 "   // Koristim FAKT - 0 - ne prenosi se podaci,"1 " - prod mjes 1
public gTopsDEST:=space(20)
public gSetForm:="1"

public c10Var:="2"  // 1-stara varijanta izvjestaja, nova varijanta izvj
public g80VRT:="1"
public gCijene:="2" // cijene iz sifrarnika, validnost
public gGen16:="1"
public gNiv14:="1"

public gModemVeza:="N"

public gPicNC := "999999.99999999"
public gKomFakt:="20"
public gKomKonto:="5611   "     // zakomision definisemo
                                      // konto i posebnu sifru firme u FAKT-u
public gVar13u11:="1"     // varijanta za otpremu u prodavnicu
public gPromTar:="N"
public gFunKon1:=PADR("SUBSTR(FINMAT->IDKONTO,4,2)",80)
public gFunKon2:=PADR("SUBSTR(FINMAT->IDKONTO2,4,2)",80)
public g11bezNC:="N"
public gMpcPomoc:="N"
public gKolicFakt:="N"
public gRobaTrosk:="N"
public gRobaTr1Tip:="%"
public gRobaTr2Tip:="%"
public gRobaTr3Tip:="%"
public gRobaTr4Tip:="%"
public gRobaTr5Tip:="%"

// dokument. koverzija valute
public gDokKVal := "N"

public lPoNarudzbi

// KALK: auto import
// print dokumenata pri auto importu
public gAImpPrint := "N"
// ravnoteza def.konto
public gAImpRKonto := PADR("1370", 7)

lPoNarudzbi:=.f.

RPar("11",@c10T1)
RPar("12",@c10T2)
RPar("13",@c10T3)
RPar("14",@c10T4)
RPar("15",@c10T5)
RPar("71",@cRNT1)
RPar("72",@cRNT2)
RPar("73",@cRNT3)
RPar("74",@cRNT4)
RPar("75",@cRNT5)


RPar("21",@c24T1)
RPar("22",@c24T2)
RPar("23",@c24T3)
RPar("24",@c24T4)
RPar("25",@c24T5)
RPar("26",@c24T6)
RPar("27",@c24T7)
RPar("28",@c24T8)
Rpar("Bv",@gBaznaV)
RPar("af",@gAFin)
RPar("am",@gAMat)
RPar("ax",@gAFakt)
Rpar("br",@gBrojac)
RPar("c1",@gMagacin)
if IsPDV()
	RPar("c2",@gPDVMagNab)
endif
RPar("ci",@gCijene)
RPar("d3",@gDirFIK)
RPar("d4",@gDirMaK)
RPar("d5",@gDirFakK)
RPar("df",@gDirFIN)
RPar("dm",@gDirMat)
RPar("dx",@gDirFakt)
Rpar("ts",@gTS)

RPar("fo", @gSetForm)   // set formula
RPar("g6",@gGen16)
Rpar("k1",@gKomFakt)
Rpar("k2",@gKomKonto)
Rpar("ka",@gKalo)
Rpar("vk",@gVodiKalo)
RPar("n4",@gNiv14)
Rpar("nc",@gMetodaNC)
Rpar("dk",@gDeckol)
Rpar("nI",@gDefNiv)
Rpar("nw",@gNW)
Rpar("ve",@gVarEv)
Rpar("p1",@gPicCDEM)
Rpar("p2",@gPicProc)
Rpar("p3",@gPicDEM)
Rpar("p4",@gPicKol)
Rpar("p5",@gPicNC)
Rpar("p6",@gFPicCDem)
Rpar("p7",@gFPicDem)
Rpar("p8",@gFPicKol)
RPar("po",@gPotpis)
RPar("rc",@gRCRP)
Rpar("rt",@gRokTr)

Rpar("rx",@gRobaTrosk)
Rpar("R1",@gRobaTr1Tip)
Rpar("R2",@gRobaTr2Tip)
Rpar("R3",@gRobaTr3Tip)
Rpar("R4",@gRobaTr4Tip)
Rpar("R5",@gRobaTr5Tip)

Rpar("KV",@gDokKVal)

Rpar("up",@g10Porez)
RPar("v1",@c10Var)
RPar("v2",@g11bezNC)
RPar("v3",@g80VRT)
RPar("vp",@gVarVP)
RPar("vo",@gVar13u11)

RPar("YT",@gTops)
RPar("YF",@gFakt)
RPar("YW",@gTopsDest)
RPar("Mv",@gModemVeza)
RPar("mP",@gMPCPomoc)
RPar("fK",@gKolicFakt)
RPar("pt",@gPromTar)
RPar("f1",@gFunKon1)
RPar("f2",@gFunKon2)

cOdradjeno:="D"
if file(EXEPATH+'scshell.ini')
        //cBrojLok:=R_IniRead ( 'TekucaLokacija','Broj',  "",EXEPATH+'scshell.INI' )
        cOdradjeno:=R_IniRead ( 'ShemePromjena',alltrim(strtran(strtran(cDirPriv,"\","_"),":","_")),  "N" ,EXEPATH+'scshell.INI' )
        R_IniWrite ( 'ShemePromjena',alltrim(strtran(strtran(cDirPriv,"\","_"),":","_")),  "D" ,EXEPATH+'scshell.INI' )
endif


if ( empty(gDirFin) .or. empty(gDirMat) .or. empty(gDirFiK) .or. empty(gDirMaK) .or. empty(gDirFaKt) .or. empty(gDirFakK) ) ;
   .or. cOdradjeno="N"
  gDirFin:=strtran(cDirPriv,"KALK","FIN")+SLASH
  gDirMat:=strtran(cDirPriv,"KALK","MAT")+SLASH
  gDirFiK:=strtran(cDirRad,"KALK","FIN")+SLASH
  gDirMaK:=strtran(cDirRad,"KALK","MAT")+SLASH
  gDirFakt:=strtran(cDirPriv,"KALK","FAKT")+SLASH
  gDirFakK:=strtran(cDirRad,"KALK","FAKT")+SLASH
  WPar("df",gDirFin)
  WPar("dm",gDirMat)
  WPar("d3",gDirFiK)
  WPar("d4",gDirMaK)
endif

gDirFin:=trim(gDirFin)
gDirMat:=trim(gDirMat)
gDirFiK:=trim(gDirFiK)
gDirMaK:=trim(gDirMaK)
gDirFakt:=trim(gDirFakt)
gDirFakK:=trim(gDirFakK)

// KALK: auto import
private cSection := "7"
RPar("ai", @gAImpPrint)
RPar("ak", @gAImpRKonto)

select (F_PARAMS)
use

cSekcija:="SifRoba"; cVar:="PitanjeOpis"
IzFmkIni (cSekcija,cVar, IzFMkIni(cSekcija,cVar,'D') , SIFPATH)
cSekcija:="SifRoba"; cVar:="ID_J"
IzFmkIni (cSekcija,cVar, IzFMkIni(cSekcija,cVar,'N') , SIFPATH)
cSekcija:="SifRoba"; cVar:="VPC2"
IzFmkIni (cSekcija,cVar, IzFMkIni(cSekcija,cVar,'D') , SIFPATH)
cSekcija:="SifRoba"; cVar:="MPC2"
IzFmkIni (cSekcija,cVar, IzFMkIni(cSekcija,cVar,'D') , SIFPATH)
cSekcija:="SifRoba"; cVar:="MPC3"
IzFmkIni (cSekcija,cVar, IzFMkIni(cSekcija,cVar,'D') , SIFPATH)
cSekcija:="SifRoba"; cVar:="PrikId"
IzFmkIni (cSekcija,cVar, IzFMkIni(cSekcija,cVar,'ID') , SIFPATH)
cSekcija:="SifRoba"; cVar:="DuzSifra"
IzFmkIni (cSekcija,cVar, IzFMkIni(cSekcija,cVar,'10') , SIFPATH)

cSekcija:="BarKod"; cVar:="Auto"
IzFmkIni (cSekcija,cVar, IzFMkIni(cSekcija,cVar,'N') , SIFPATH)
cSekcija:="BarKod"; cVar:="AutoFormula"
IzFmkIni (cSekcija,cVar, IzFMkIni(cSekcija,cVar,'ID') , SIFPATH)
cSekcija:="BarKod"; cVar:="Prefix"
IzFmkIni (cSekcija,cVar, IzFMkIni(cSekcija,cVar,'') , SIFPATH)
cSekcija:="BarKod"; cVar:="NazRTM"
IzFmkIni (cSekcija,cVar, IzFMkIni(cSekcija,cVar,'barkod') , SIFPATH)

//definisano u SC_CLIB-u
gGlBaza:="KALK.DBF"

public glEkonomat 

glEKonomat:= (IzFmkIni("KALK","VoditiSamoEkonomat","N",EXEPATH)=="D")
lPoNarudzbi := ( IzFMKINI("KALK","10PoNarudzbi","N",KUMPATH)=="D" )

public gKalks:=.f.

public lPodBugom:=.f.
IF IzFMKINI("ZASTITA","PodBugom","N",KUMPATH)=="D"
  lPodBugom:=.t.
  gaKeys := { { K_ALT_O , {|| OtkljucajBug()} } }
ELSE
  lPodBugom:=.f.
ENDIF

public gVodiSamoTarife
gVodiSamoTarife:=IzFmkIni("KALK","VodiSamoTarife","N",PRIVPATH)

public lSyncon47
lSyncon47:=(IzFMKINI("KALK","Synergicon47","N",KUMPATH)=="D")

public lKoristitiBK
lKoristitiBK:=(IzFmkIni('KALK','Barkod','N',KUMPATH)=="D")

public lPrikPRUC
lPrikPRUC:=(IzFMKINI("UGOSTITELJSTVO","PrikazKolonePRUC","N",KUMPATH)=="D")

cPom:=IzFMKINI("POREZI","PPUgostKaoPPU","-",KUMPATH)
if cPom<>"-"
	gUVarPP:=cPom
endif

if IsJerry()
	lPrikPRUC:=.f.
endif

public gDuzKonto
if !::oDatabase:lAdmin
	O_PRIPR
	gDuzKonto:=LEN(mkonto)
	use
else
	gDuzKonto:=7
endif

public glZabraniVisakIP
glZabraniVisakIP:=(IzFmkIni("OPRESA","ZabraniVisakIP","N",KUMPATH)=="D")

public glBrojacPoKontima
glBrojacPoKontima:=(IzFmkIni("KALK","BrojacPoKontima","N",KUMPATH)=="D")

public glEvidOtpis
glEvidOtpis:=(IzFmkIni("KALKSI","EvidentirajOtpis","N",KUMPATH)=="D")

public gcSLObrazac
gcSLObrazac:=IzFmkIni("KALK","SLObrazac","1",KUMPATH)

gRobaBlock:={|Ch| RobaBlock(Ch)}

return
*}
