#include "\dev\fmk\kalk\kalk.ch"

// ================
// KONTA:
// ================
// KALK_14KR=1310
// KALK_14KZ=????

// KALK_11KZ=ovdje moramo imati konto prodavnice
// KALK_11KR=1310

// KALK_41KZ=13200 / diskont sarajevo
// KALK_41KR=1310

// KALK_95KR=1310
// KALK_96KZ=30041 // troskovi


/*! \fn MnuImpTxt()
 *  \brief Menij opcije import txt
 */
function MnuImpTxt()
*{
private izbor:=1
private opc:={}
private opcexe:={}

AADD(opc, "1. import vindija racun        ")
AADD(opcexe, {|| ImpTxtDok()})
AADD(opc, "2. import vindija partner      ")
AADD(opcexe, {|| ImpTxtSif()})

Menu_SC("itx")

return
*}

/*! \fn ImpTxtDok()
 *  \brief Import dokumenta
 */
function ImpTxtDok()
*{
private cExpPath
private cImpFile

// setuj varijablu putanje exportovanih fajlova
GetExpPath(@cExpPath)

cFFilt := "R*.R??"

// daj mi pregled fajlova za import, te setuj varijablu cImpFile
if GetFList(cFFilt, cExpPath, @cImpFile) == 0
	return
endif

// provjeri da li je fajl za import prazan
if CheckFile(cImpFile)==0
	MsgBeep("Odabrani fajl je prazan!#!!! Prekidam operaciju !!!")
	return
endif

private aDbf:={}
private aRules:={}
// setuj polja temp tabele u matricu aDbf
SetTblDok(@aDbf)
// setuj pravila upisa podataka u temp tabelu
SetRuleDok(@aRules)
// prebaci iz txt => temp tbl
Txt2TTbl(aDbf, aRules, cImpFile)

if !CheckDok()
	MsgBeep("Prekidamo operaciju !!!#Nepostojece sifre!!!")
	return
endif

if CheckBrFakt() == 0
	MsgBeep("Prekidamo operaciju !!!#Dokumenti vec postoje azurirani!")
	return
endif

if TTbl2Kalk() == 0
	MsgBeep("Operacija prekinuta!")
	return 
endif

MsgBeep("Dokumenti prebaceni u pripremu#Izvrsiti obradu asistentom...")

TxtErase(cImpFile, .t.)

return
*}


/*! \fn ImpTxtSif()
 *  \brief Import sifrarnika
 */
function ImpTxtSif()
*{
private cExpPath
private cImpFile

// setuj varijablu putanje exportovanih fajlova
GetExpPath(@cExpPath)

cFFilt := "P*.P??"

// daj mi pregled fajlova za import, te setuj varijablu cImpFile
if GetFList(cFFilt, cExpPath, @cImpFile) == 0
	return
endif

// provjeri da li je fajl za import prazan
if CheckFile(cImpFile)==0
	MsgBeep("Odabrani fajl je prazan!#!!! Prekidam operaciju !!!")
	return
endif

private aDbf:={}
private aRules:={}
// setuj polja temp tabele u matricu aDbf
SetTblPartn(@aDbf)
// setuj pravila upisa podataka u temp tabelu
SetRulePartn(@aRules)

// prebaci iz txt => temp tbl
Txt2TTbl(aDbf, aRules, cImpFile)

if CheckSif() > 0
	if Pitanje(,"Izvrsiti import partnera (D/N)?", "D") == "N"
		MsgBeep("Opcija prekinuta!")
		return 
	endif
else
	MsgBeep("Nema novih partnera za import !")
	return
endif

// ova opcija ipak i nije toliko dobra da se radi!
// 
//lEdit := Pitanje(,"Izvrsiti korekcije postojecih podataka (D/N)?", "N") == "D"
lEdit := .f.

if TTbl2Partn(lEdit) == 0
	MsgBeep("Operacija prekinuta!")
	return
endif

MsgBeep("Operacija zavrsena !")


TxtErase(cImpFile)

return
*}



/*! \fn SetTblDok(aDbf)
 *  \brief Setuj matricu sa poljima tabele dokumenata RACUN
 *  \param aDbf - matrica
 */
static function SetTblDok(aDbf)
*{

AADD(aDbf,{"idfirma", "C", 2, 0})
AADD(aDbf,{"idtipdok", "C", 2, 0})
AADD(aDbf,{"brdok", "C", 8, 0})
AADD(aDbf,{"datdok", "D", 8, 0})
AADD(aDbf,{"idpartner", "C", 6, 0})
AADD(aDbf,{"idpm", "C", 3, 0})
AADD(aDbf,{"dindem", "C", 3, 0})
AADD(aDbf,{"zaokr", "N", 1, 0})
AADD(aDbf,{"rbr", "C", 3, 0})
AADD(aDbf,{"idroba", "C", 10, 0})
AADD(aDbf,{"kolicina", "N", 14, 5})
AADD(aDbf,{"cijena", "N", 14, 5})
AADD(aDbf,{"rabat", "N", 10, 5})
AADD(aDbf,{"porez", "N", 10, 5})

return
*}

/*! \fn SetTblPartner(aDbf)
 *  \brief Set polja tabele partner
 *  \param aDbf - matrica sa def.polja
 */
static function SetTblPartner(aDbf)
*{

AADD(aDbf,{"idpartner", "C", 6, 0})
AADD(aDbf,{"naz", "C", 25, 0})
AADD(aDbf,{"ptt", "C", 5, 0})
AADD(aDbf,{"mjesto", "C", 16, 0})
AADD(aDbf,{"adresa", "C", 24, 0})
AADD(aDbf,{"ziror", "C", 22, 0})
AADD(aDbf,{"telefon", "C", 12, 0})
AADD(aDbf,{"fax", "C", 12, 0})
AADD(aDbf,{"idops", "C", 4, 0})
AADD(aDbf,{"rokpl", "N", 5, 0})
AADD(aDbf,{"porbr", "C", 16, 0})
AADD(aDbf,{"idbroj", "C", 16, 0})
AADD(aDbf,{"ustn", "C", 20, 0})
AADD(aDbf,{"brupis", "C", 20, 0})
AADD(aDbf,{"brjes", "C", 20, 0})

return
*}

/*! \fn SetRuleDok(aRule)
 *  \brief Setovanje pravila upisa zapisa u temp tabelu
 *  \param aRule - matrica pravila
 */
static function SetRuleDok(aRule)
*{
// idfirma
AADD(aRule, {"SUBSTR(cVar, 1, 2)"})
// idtipdok
AADD(aRule, {"SUBSTR(cVar, 4, 2)"})
// brdok
AADD(aRule, {"SUBSTR(cVar, 7, 8)"})
// datdok
AADD(aRule, {"CTOD(SUBSTR(cVar, 16, 10))"})
// idpartner 
AADD(aRule, {"SUBSTR(cVar, 27, 6)"})
// id pm
AADD(aRule, {"SUBSTR(cVar, 34, 3)"})
// dindem
AADD(aRule, {"SUBSTR(cVar, 38, 3)"})
// zaokr
AADD(aRule, {"VAL(SUBSTR(cVar, 42, 1))"})
// rbr
AADD(aRule, {"STR(VAL(SUBSTR(cVar, 44, 3)),3)"})
// idroba
AADD(aRule, {"ALLTRIM(SUBSTR(cVar, 48, 5))"})
// kolicina
AADD(aRule, {"VAL(SUBSTR(cVar, 54, 16))"})
// cijena
AADD(aRule, {"VAL(SUBSTR(cVar, 71, 16))"})
// rabat
AADD(aRule, {"VAL(SUBSTR(cVar, 88, 14))"})
// porez
AADD(aRule, {"VAL(SUBSTR(cVar, 103, 14))"})

return
*}


/*! \fn SetRulePartn(aRule)
 *  \brief Setovanje pravila upisa zapisa u temp tabelu
 *  \param aRule - matrica pravila
 */
static function SetRulePartn(aRule)
*{
// id
AADD(aRule, {"SUBSTR(cVar, 1, 6)"})
// naz
AADD(aRule, {"SUBSTR(cVar, 8, 25)"})
// ptt
AADD(aRule, {"SUBSTR(cVar, 34, 5)"})
// mjesto
AADD(aRule, {"SUBSTR(cVar, 40, 16)"})
// adresa 
AADD(aRule, {"SUBSTR(cVar, 57, 24)"})
// ziror
AADD(aRule, {"SUBSTR(cVar, 82, 22)"})
// telefon
AADD(aRule, {"SUBSTR(cVar, 105, 12)"})
// fax
AADD(aRule, {"SUBSTR(cVar, 118, 12)"})
// idops
AADD(aRule, {"SUBSTR(cVar, 131, 4)"})
// rokpl
AADD(aRule, {"VAL(SUBSTR(cVar, 136, 5))"})
// porbr
AADD(aRule, {"SUBSTR(cVar, 143, 16)"})
// idbroj
AADD(aRule, {"SUBSTR(cVar, 160, 16)"})
// ustn
AADD(aRule, {"SUBSTR(cVar, 177, 20)"})
// brupis
AADD(aRule, {"SUBSTR(cVar, 198, 20)"})
// brjes
AADD(aRule, {"SUBSTR(cVar, 219, 20)"})

return
*}


/*! \fn GetExpPath(cPath)
 *  \brief Vraca podesenje putanje do exportovanih fajlova
 *  \param cPath - putanja, zadaje se sa argumentom @ kao priv.varijabla
 */
static function GetExpPath(cPath)
*{
cPath:=IzFmkIni("KALK", "ImportPath", "c:\liste\", PRIVPATH)
if Empty(cPath) .or. cPath == nil
	cPath := "c:\liste\"
endif
return
*}


/*! \fn GetFList(cFilter, cPath, cImpFile)
 *  \brief Pregled liste exportovanih dokumenata te odabir zeljenog fajla za import
 *  \param cFilter - filter naziva dokumenta
 *  \param cPath - putanja do exportovanih dokumenata
 */
function GetFList(cFilter, cPath, cImpFile)
*{

OpcF:={}

// cFilter := "R*.R??" ili "P*.P??"
aFiles:=DIRECTORY(cPath + cFilter)

// da li postoje fajlovi
if LEN(aFiles)==0
	MsgBeep("U direktoriju za prenos nema podataka")
	return 0
endif

// sortiraj po datumu
ASORT(aFiles,,,{|x,y| x[3]>y[3]})
AEVAL(aFiles,{|elem| AADD(OpcF, PADR(elem[1],15)+" "+dtos(elem[3]))},1)
// sortiraj listu po datumu
ASORT(OpcF,,,{|x,y| RIGHT(x,10)>RIGHT(y,10)})

h:=ARRAY(LEN(OpcF))
for i:=1 to LEN(h)
	h[i]:=""
next

// selekcija fajla
IzbF:=1
lRet := .f.
do while .t. .and. LastKey()!=K_ESC
	IzbF:=Menu("imp", OpcF, IzbF, .f.)
	if IzbF == 0
        	exit
        else
        	cImpFile:=Trim(cPath)+Trim(LEFT(OpcF[IzbF],15))
        	if Pitanje(,"Zelite li izvrsiti import fajla ?","D")=="D"
        		IzbF:=0
			lRet:=.t.
		endif
        endif
enddo
if lRet
	return 1
else
	return 0
endif
return 1
*}


/*! \fn Txt2TTbl(aDbf, aRules, cTxtFile)
 *  \brief Kreiranje temp tabele, te prenos zapisa iz text fajla "cTextFile" u tabelu putem aRules pravila 
 *  \param aDbf - struktura tabele
 *  \param aRules - pravila upisivanja jednog zapisa u tabelu, princip uzimanja zapisa iz linije text fajla
 *  \param cTxtFile - txt fajl za import
 */
 */
function Txt2TTbl(aDbf, aRules, cTxtFile)
*{
// prvo kreiraj tabelu temp
close all
CreTemp(aDbf)

if !File(PRIVPATH + SLASH + "TEMP.DBF")
	MsgBeep("Ne mogu kreirati fajl TEMP.DBF!")
	return
endif

// zatim iscitaj fajl i ubaci podatke u tabelu

// broj linija fajla
nBrLin:=BrLinFajla(cTxtFile)
nStart:=0

// prodji kroz svaku liniju i insertuj zapise u temp.dbf
for i:=1 to nBrLin
	aFMat:=SljedLin(cTxtFile, nStart)
      	nStart:=aFMat[2]
	// uzmi u cText liniju fajla
	cVar:=aFMat[1]
	
	// selektuj temp tabelu
	select temp
	// dodaj novi zapis
	append blank
	
	for nCt:=1 to LEN(aRules)
		
		altd()
		
		fname := FIELD(nCt)
		xVal := aRules[nCt, 1]
		replace &fname with &xVal
	next
next

MsgBeep("Import txt => temp - OK")

return
*}

/*! \fn CheckFile(cTxtFile)
 *  \brief Provjerava da li je fajl prazan
 *  \param cTxtFile - txt fajl
 */
static function CheckFile(cTxtFile)
*{
nBrLin:=BrLinFajla(cTxtFile)
return nBrLin
*}


/*! \fn CreTemp(aDbf)
 *  \brief Kreira tabelu PRIVPATH\TEMP.DBF prema definiciji polja iz aDbf
 *  \param aDbf - def.polja
 */
static function CreTemp(aDbf)
*{
select 0

cTmpTbl:=PRIVPATH+"TEMP"

if File(cTmpTbl + ".DBF") .and. FErase(cTmpTbl + ".DBF") == -1
	MsgBeep("Ne mogu izbrisati TEMP.DBF!")
    	ShowFError()
endif
if File(cTmpTbl + ".CDX") .and. FErase(cTmpTbl + ".CDX") == -1
	MsgBeep("Ne mogu izbrisati TEMP.CDX!")
    	ShowFError()
endif

DbCreate2(cTmpTbl, aDbf)
USEX (cTmpTbl)

return
*}

/*! \fn CheckBrFakt()
 *  \brief Provjeri da li postoji broj fakture u azuriranim dokumentima
 */
function CheckBrFakt()
*{

aPomFakt := FaktExist()

if LEN(aPomFakt) > 0

	START PRINT CRET
	
	? "Kontrola azuriranih dokumenata:"
	? "-------------------------------"
	? "Broj fakture => kalkulacija"
	? "-------------------------------"
	? 
	
	for i:=1 to LEN(aPomFakt)
		? aPomFakt[i, 1] + " => " + aPomFakt[i, 2]
	next
	
	?
	? "Kontrolom azuriranih dokumenata, uoceno da se vec pojavljuju"
	? "navedeni brojevi faktura iz fajla za import !"
	?

	FF
	END PRINT

	return 0
	
endif

return 1
*}


/*! \fn CheckDok()
 *  \brief Provjera da li postoje sve sifre u sifrarnicima za dokumente
 */
function CheckDok()
*{

aPomPart := ParExist()
aPomArt  := ArtExist()

if (LEN(aPomPart) > 0 .or. LEN(aPomArt) > 0)
	
	START PRINT CRET
	
	if (LEN(aPomPart) > 0)
		? "Lista nepostojecih partnera:"
		? "----------------------------"
		? 
		for i:=1 to LEN(aPomPart)
			? aPomPart[i, 1]
		next
		?
	endif

	if (LEN(aPomArt) > 0)
		? "Lista nepostojecih artikala:"
		? "----------------------------"
		? 
		for ii:=1 to LEN(aPomArt)
			? aPomArt[ii, 1]
		next
		?
	endif
	
	FF
	END PRINT

	return .f.
endif

return .t.
*}

/*! \fn CheckSif()
 *  \Provjerava i daje listu nepostojecih partnera pri importu liste partnera
 */
function CheckSif()
*{

aPomPart := ParExist(.t.)

if (LEN(aPomPart) > 0)
	
	START PRINT CRET
	
	? "Lista nepostojecih partnera:"
	? "----------------------------"
	? 
	for i:=1 to LEN(aPomPart)
		? aPomPart[i, 1]
		?? " " + aPomPart[i, 2]
	next
	?

	FF
	END PRINT

endif

return LEN(aPomPart)
*}


/*! \fn ParExist()
 *  \brief Provjera da li postoje sifre partnera u sifraniku FMK
 */
function ParExist(lPartNaz)
*{
O_PARTN
select temp
go top

if lPartNaz == nil
	lPartNaz := .f.
endif

aRet:={}

do while !EOF()
	select partn
	go top
	seek temp->idpartner
	if !Found()
		if lPartNaz
			AADD(aRet, {temp->idpartner, temp->naz})
		else
			AADD(aRet, {temp->idpartner})
		endif
	endif
	select temp
	skip
enddo

return aRet
*}

/*! \fn ArtExist()
 *  \brief Provjera da li postoje sifre artikla u sifraniku FMK
 *  \param cId - id sifre
 */
function ArtExist()
*{
O_ROBA
select temp
go top

aRet:={}

do while !EOF()
	altd()	
	cTmpRoba := ALLTRIM(temp->idroba)
	
	select roba
	if LEN(cTmpRoba) == 4
		set order to tag "ID_V4"
	endif
	if LEN(cTmpRoba) == 5
		set order to tag "ID_V5"
	endif
	go top
	
	altd()	
	seek cTmpRoba
	
 	// ako ne nadjes napuni matricu
	if !Found()
		nRes := ASCAN(aRet, {|aVal| aVal[1] == cTmpRoba})
		if nRes == 0
			AADD(aRet, {cTmpRoba})
		endif
	endif
	
	select temp
	skip
enddo

return aRet
*}


/*! \fn GetKTipDok(cFaktTD)
 *  \brief Vraca kalk tip dokumenta na osnovu fakt tip dokumenta
 *  \param cFaktTD - fakt tip dokumenta
 */
static function GetKTipDok(cFaktTD, cPm)
*{
cRet:=""

if (cFaktTD == "" .or. cFaktTD == nil)
	return "XX" 
endif

do case
	// racuni VP
	// FAKT 10 -> KALK 14
	case cFaktTD == "10"
		cRet := "14"
		
	// diskont vindija
	// FAKT 11 -> KALK 41
	case (cFaktTD == "11" .and. cPm == "200")
		cRet := "41"
		
	// zaduzenje prodavnica
	// FAKT 13 -> KALK 11
	case (cFaktTD == "11" .and. cPm <> "200")
		cRet := "11"
		
	// kalo, rastur - otpis
	// radio se u kalku
	case cFaktTD $ "90#91#92"
		cRet := "95"
endcase

return cRet
*}

/*! \fn GetVPr(cProd)
 *  \brief Vrati konto za prodajno mjesto Vindijine prodavnice
 *  \param cProd - prodajno mjesto C(3), npr "200"
 */
static function GetVPr(cProd)
*{
if cProd == "XXX"
	return "XXXXX"
endif

if cProd == "" .or. cProd == nil
	return "XXXXX"
endif

cRet := IzFmkIni("VINDIJA", "VPR"+cProd, "xxxx", KUMPATH)

if cRet == "" .or. cRet == nil
	cRet := "XXXXX"
endif

return cRet
*}


/*! \fn GetTdKonto(cTipDok, cTip)
 *  \brief Vrati konto za odredjeni tipdokumenta
 *  \param cTipDok - tip dokumenta
 *  \param cTip - "Z" zaduzuje, "R" - razduzuje
 */
static function GetTdKonto(cTipDok, cTip)
*{

cRet := IzFmkIni("VINDIJA", "TD" + cTipDok + cTip, "xxxx", KUMPATH)

// primjer:
// TD14Z=1310
// TD14R=1200

if cRet == "" .or. cRet == nil
	cRet := "XXXXX"
endif

return cRet
*}



/*! \fn FaktExist()
 *  \brief vraca matricu sa parovima faktura -> pojavljuje se u azur.kalk
 */
function FaktExist()
*{
O_DOKS

select temp
go top

aRet:={}

altd()
cDok := "XXXXXX"
do while !EOF()

	cBrFakt := ALLTRIM(temp->brdok)
	
	if cBrFakt == cDok
		skip
		loop
	endif
	
	select doks
	set order to tag "V_BRF"
	go top
	seek cBrFakt
	
	if Found()
		AADD(aRet, {cBrFakt, doks->idfirma + "-" + doks->idvd + "-" + ALLTRIM(doks->brdok)})
	endif
	
	select temp
	skip
	
	cDok := cBrFakt
enddo

return aRet
*}


/*! \fn TTbl2Kalk()
 *  \brief kopira podatke iz pomocne tabele u tabelu KALK->PRIPREMA
 */
function TTbl2Kalk()
*{
local cBrojKalk
local cTipDok
local cIdKonto
local cIdKonto2

O_PRIPR
O_DOKS
O_ROBA

select temp
go top

nRbr:=0
nUvecaj:=1
nCnt:=0

cPFakt := "XXXXXX"
aPom := {}

do while !EOF()

	cFakt := ALLTRIM(temp->brdok)
	cTDok := GetKTipDok(ALLTRIM(temp->idtipdok), temp->idpm)
	
	if cFakt <> cPFakt
		cBrojKalk := GetNextKalkDoc(gFirma, cTDok, ++nUvecaj)
		nRbr := 0
		AADD(aPom, {cTDok, cBrojKalk})
	endif
	
	// pronadji robu
	select roba
	cTmpArt := ALLTRIM(temp->idroba)
	
	if LEN(cTmpArt) == 4
		set order to tag "ID_V4"
	endif
	
	if LEN(cTmpArt) == 5
		set order to tag "ID_V5"
	endif
	
	go top
	seek cTmpArt
	
	// dodaj zapis u pripr
	select pripr
	append blank
	
	replace idfirma with gFirma
	replace rbr with STR(++nRbr, 3)
	
	// uzmi pravilan tip dokumenta za kalk
	replace idvd with cTDok
	
	replace brdok with cBrojKalk
	replace datdok with temp->datdok
	replace idpartner with temp->idpartner
	replace idtarifa with ROBA->idtarifa
	replace brfaktp with cFakt
	replace datfaktp with temp->datdok
	
	// konta:
	// =====================
	// zaduzuje
	replace idkonto with GetKtKalk(cTDok, temp->idpm, "Z")
	// razduzuje
	replace idkonto2 with GetKtKalk(cTDok, temp->idpm, "R")
	replace idzaduz2 with ""
	
	// spec.za tip dok 11
	if cTDok $ "11#41"
		replace tmarza2 with "A"
		replace tprevoz with "A"
	endif
	
	replace datkurs with temp->datdok
	replace kolicina with temp->kolicina
	replace idroba with roba->id
	replace nc with ROBA->nc
	replace vpc with temp->cijena
	replace rabatv with temp->rabat
	replace mpc with temp->porez
	
	cPFakt := cFakt
	++ nCnt
	
	select temp
	skip
enddo

// izvjestaj o prebacenim dokumentima....
if nCnt > 0
	START PRINT CRET
	? "========================================"
	? "Sljedeci dokumenti prebaceni u pripremu:"
	? "========================================"
	? "Tip dok * Broj dokumenta * "
	? "-------------------------"
	
	for i:=1 to LEN(aPom)
		? aPom[i, 1] + " - " + aPom[i, 2]
	next
	
	?
	
	FF
	END PRINT
endif

return 1
*}


/*! \fn GetKtKalk(cTipDok, cPm, cTip)
 *  \brief Varaca konto za trazeni tip dokumenta i prodajno mjesto
 *  \param cTipDok - tip dokumenta
 *  \param cPm - prodajno mjesto
 *  \param cTip - tip "Z" zad. i "R" razd.
 */
static function GetKtKalk(cTipDok, cPm, cTip)
*{

do case
	case cTipDok == "14"
		cRet := GetTDKonto(cTipDok, cTip)
	case cTipDok == "11"
		if cTip == "R"
			cRet := GetTDKonto(cTipDok, cTip)
		else
			cRet := GetVPr(cPm)
		endif
	case cTipDok == "41"
		cRet := GetTDKonto(cTipDok, cTip)
	case cTipDok == "95"
		cRet := GetTDKonto(cTipDok, cTip)
endcase

return cRet
*}


/*! \fn TTbl2Partn(lEditOld)
 *  \brief kopira podatke iz pomocne tabele u tabelu PARTN
 *  \param lEditOld - ispraviti stare zapise
 */
function TTbl2Partn(lEditOld)
*{

O_PARTN
O_SIFK
O_SIFV

select temp
go top

lNovi := .f.

do while !EOF()

	// pronadji partnera
	select partn
	cTmpPar := ALLTRIM(temp->idpartner)
	go top
	seek cTmpPar
	
	// ako si nasao:
	//  1. ako je lEditOld .t. onda ispravi postojeci
	//  2. ako je lEditOld .f. onda preskoci
	if Found()
		if !lEditOld
			select temp
			skip
			loop
		endif
		lNovi := .f.
	else
		lNovi := .t.
	endif
	
	// dodaj zapis u partn
	select partn
	
	if lNovi
		append blank
	endif
	
	if !lNovi .and. !lEditOld
		select temp
		skip
		loop
	endif
	
	replace id with temp->idpartner
	cNaz := temp->naz
	replace naz with KonvZnWin(@cNaz, "8")
	replace ptt with temp->ptt
	cMjesto := temp->mjesto
	replace mjesto with KonvZnWin(@cMjesto, "8")
	cAdres := temp->adresa
	replace adresa with KonvZnWin(@cAdres, "8")
	replace ziror with temp->ziror
	replace telefon with temp->telefon
	replace fax with temp->fax
	replace idops with temp->idops
	// ubaci --vezane-- podatke i u sifK tabelu
	USifK("PARTN", "ROKP", temp->idpartner, temp->rokpl)
	USifK("PARTN", "PORB", temp->idpartner, temp->porbr)
	USifK("PARTN", "REGB", temp->idpartner, temp->idbroj)
	USifK("PARTN", "USTN", temp->idpartner, temp->ustn)
	USifK("PARTN", "BRUP", temp->idpartner, temp->brupis)
	USifK("PARTN", "BRJS", temp->idpartner, temp->brjes)
	
	select temp
	skip
enddo

return 1
*}



/*! \fn GetKVars(dDatDok, cBrKalk, cTipDok, cIdKonto, cIdKonto2, cRazd)
 *  \brief Setuj parametre prenosa TEMP->PRIPR(KALK)
 *  \param dDatDok - datum dokumenta
 *  \param cBrKalk - broj kalkulacije
 *  \param cTipDok - tip dokumenta
 *  \param cIdKonto - id konto zaduzuje
 *  \param cIdKonto2 - konto razduzuje
 *  \param cRazd - razdvajati dokumente po broju fakture (D ili N)
 */
static function GetKVars(dDatDok, cBrKalk, cTipDok, cIdKonto, cIdKonto2, cRazd)
*{
dDatDok:=DATE()
cTipDok:="14"
cIdFirma:=gFirma
cIdKonto:=PADR("1200",7)
cIdKonto2:=PADR("1310",7)
cRazd:="D"
O_KONTO
O_DOKS
cBrKalk:=GetNextKalkDoc(cIdFirma, cTipDok)

Box(,15,60)
	@ m_x+1,m_y+2   SAY "Broj kalkulacije 14-" GET cBrKalk pict "@!"
  	@ m_x+1,col()+2 SAY "Datum:" GET dDatDok
  	@ m_x+4,m_y+2   SAY "Konto razduzuje:" GET cIdKonto2 pict "@!" VALID P_Konto(@cIdKonto2)
  	@ m_x+6,m_y+2   SAY "Razdvajati kalkulacije po broju faktura" GET cRazd pict "@!" valid cRazd$"DN"
	read
BoxC()

if LastKey()==K_ESC
	return 0
endif

return 1
*}
  

/*! \fn TxtErase(cTxtFile, lErase)
 *  \brief Brisanje fajla cTxtFile
 *  \param cTxtFile - fajl za brisanje
 *  \param lErase - .t. ili .f. - brisati ili ne brisati fajl txt nakon importa
 */
function TxtErase(cTxtFile, lErase)
*{
if lErase == nil
	lErase := .f.
endif

// postavi pitanje za brisanje fajla
if lErase .and. Pitanje(,"Pobrisati txt fajl (D/N)?","D")=="N"
	return
endif

if FErase(cTxtFile) == -1
	MsgBeep("Ne mogu izbrisati " + cTxtFile)
	ShowFError()
endif

return
*}

