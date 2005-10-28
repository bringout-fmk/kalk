#include "\dev\fmk\kalk\kalk.ch"


/*! \fn MnuImpTxt()
 *  \brief Menij opcije import txt
 */
function MnuImpTxt()
*{
private izbor:=1
private opc:={}
private opcexe:={}

AADD(opc, "1. import vindija racun                 ")
AADD(opcexe, {|| ImpTxtDok()})
AADD(opc, "2. import vindija partner               ")
AADD(opcexe, {|| ImpTxtSif()})
AADD(opc, "3. popuna polja sifra dobavljaca ")
AADD(opcexe, {|| FillDobSifra()})
AADD(opc, "4. nastavak obrade dokumenata ... ")
AADD(opcexe, {|| RestoreObrada()})

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

CrePripTDbf()

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
	//MsgBeep("Prekidamo operaciju !!!#Dokumenti vec postoje azurirani!")
	//return
	MsgBeep("Obratite paznju na problematicne dokumente !!!")
endif

if TTbl2Kalk() == 0
	MsgBeep("Operacija prekinuta!")
	return 
endif

// obrada dokumenata iz pript tabele
MnuObrDok()

TxtErase(cImpFile, .t.)

return
*}


/*! \fn MnuObrDok()
 *  \brief Obrada dokumenata iz pomocne tabele
 */
static function MnuObrDok()
*{
if Pitanje(,"Obraditi dokumente iz pomocne tabele (D/N)?", "D") == "D"
	ObradiImport()
else
	MsgBeep("Dokumenti nisu obradjeni!#Obrada se moze uraditi i naknadno!")
	close all
endif

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
AADD(aDbf,{"rabatp", "N", 10, 5})
AADD(aDbf,{"datval", "D", 8, 0})

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
// procenat rabata
AADD(aRule, {"VAL(SUBSTR(cVar, 118, 14))"})
// datum valute
AADD(aRule, {"CTOD(SUBSTR(cVar, 133, 10))"})

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
O_TEMP

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
cTmpTbl := PRIVPATH + "TEMP"

if File(cTmpTbl + ".DBF") .and. FErase(cTmpTbl + ".DBF") == -1
	MsgBeep("Ne mogu izbrisati TEMP.DBF!")
    	ShowFError()
endif
if File(cTmpTbl + ".CDX") .and. FErase(cTmpTbl + ".CDX") == -1
	MsgBeep("Ne mogu izbrisati TEMP.CDX!")
    	ShowFError()
endif

DbCreate2(cTmpTbl, aDbf)

return
*}


/*! \fn CrePriprTDbf()
 *  \brief Kreiranje tabele PRIVPATH + PRIPT.DBF
 */
static function CrePripTDbf()
*{

FErase(PRIVPATH + "PRIPT.DBF")
FErase(PRIVPATH + "PRIPT.CDX")

O_PRIPR
select pripr

// napravi pript sa strukturom tabele PRIPR
copy structure to (PRIVPATH+"struct")
create (PRIVPATH + "pript") from (PRIVPATH + "struct")
create_index("1","idfirma+idvd+brdok", PRIVPATH+"pript")

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
	cTmpRoba := ALLTRIM(temp->idroba)
	
	select roba
	set order to tag "ID_VSD"
	
	go top
	seek cTmpRoba
	
	// ako nisi nasao dodaj robu u matricu
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
O_DOKS2
O_ROBA
O_PRIPT

select temp
go top

nRbr:=0
nUvecaj:=1
nCnt:=0

cPFakt := "XXXXXX"
cPPm := "XXX"

aPom := {}

do while !EOF()

	cFakt := ALLTRIM(temp->brdok)
	cTDok := GetKTipDok(ALLTRIM(temp->idtipdok), temp->idpm)
	cPm := temp->idpm

	altd()
	if cFakt <> cPFakt
		cBrojKalk := GetNextKalkDoc(gFirma, cTDok, ++nUvecaj)
		nRbr := 0
		AADD(aPom, {cTDok, cBrojKalk})
	else
		// ako su diskontna zaduzenja razgranici ih putem polja prodajno mjesto
		if cTDok == "11"
			if cPm <> cPPm
				cBrojKalk := GetNextKalkDoc(gFirma, cTDok, ++nUvecaj)
				nRbr := 0
				AADD(aPom, {cTDok, cBrojKalk})
			endif
		endif
	endif
	
	// pronadji robu
	select roba
	set order to tag "ID_VSD"
	cTmpArt := ALLTRIM(temp->idroba)
	go top
	seek cTmpArt
	
	// ovo ne kontam ali eto !!!!
	if cTDok == "14"
        	select doks2
		hseek gFirma + cTDok + cBrojKalk
        	if !Found()
           		append blank
           		replace idvd with "14" // izlazna faktura
                   	replace brdok with cBrojKalk
                   	replace idfirma with gfirma
        	endif
        	replace DatVal with temp->datval
        	
		//IF lVrsteP
          	//	replace k2 with cIdVrsteP
        	//ENDIF
	endif

	// dodaj zapis u pripr
	select pript
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
		if cTDok == "11"
			replace mpcsapp with roba->mpc2
		else
			replace mpcsapp with roba->mpc
		endif
	endif
	
	replace datkurs with temp->datdok
	replace kolicina with temp->kolicina
	replace idroba with roba->id
	replace nc with ROBA->nc
	replace vpc with temp->cijena
	replace rabatv with temp->rabatp
	replace mpc with temp->porez
	
	cPFakt := cFakt
	cPPm := cPm
	
	++ nCnt
	
	select temp
	skip
enddo

// izvjestaj o prebacenim dokumentima....
if nCnt > 0
	START PRINT CRET
	? "========================================"
	? "Generisani sljedeci dokumenti:          "
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


/*! \fn ObradiImport()
 *  \brief Obrada importovanih dokumenata
 */
function ObradiImport(nPocniOd)
*{
O_PRIPR
O_PRIPT

if nPocniOd == nil
	nPocniOd := 0
endif

lAutom := .f.
if Pitanje(,"Automatski asistent i azuriranje naloga (D/N)?", "D") == "D"
	lAutom := .t. 
endif


// iz pripr_temp prebaci u pripr jednu po jednu kalkulaciju
select pript

if nPocniOd == 0
	go top
else
	go nPocniOd
endif


//SetKey(K_F3,{|| SaveObrada(nPTRec)})

Box(,10, 70)
@ 1+m_x, 2+m_y SAY "Obrada dokumenata iz pomocne tabele:" COLOR "I"
@ 2+m_x, 2+m_y SAY "===================================="

do while !EOF()

	nPTRec:=RecNo()
	nPCRec:=nPTRec
	cBrDok := field->brdok
	cFirma := field->idfirma
	cIdVd  := field->idvd
	
	@ 3+m_x, 2+m_y SAY "Prebacujem: " + cFirma + "-" + cIdVd + "-" + cBrDok
	
	nStCnt := 0
	do while !EOF() .and. field->brdok = cBrDok .and. field->idfirma = cFirma .and. field->idvd = cIdVd
		
		// jedan po jedan row azuriraj u pripr
		select pripr
		append blank
		Scatter()
		select pript
		Scatter()
		select pripr
		Gather()
		
		select pript
		skip
		++ nStCnt
		
		nPTRec := RecNo()

		@ 5+m_x, 13+m_y SAY SPACE(5)
		@ 5+m_x, 2+m_y SAY "Broj stavki:" + ALLTRIM(STR(nStCnt))
	enddo
	
	// nakon sto smo prebacili dokument u pripremu obraditi ga
	if lAutom
		// snimi zapis u params da znas dokle si dosao
		SaveObrada(nPCRec)
		ObradiDokument(cIdVd)
		SaveObrada(nPTRec)
		O_PRIPT
	endif
	
	select pript
	go nPTRec
	
enddo

BoxC()

// snimi i da je obrada zavrsena
SaveObrada(0)

MsgBeep("Dokumenti obradjeni!")

return
*}

/*! \fn SaveObrada()
 *  \brief Snima momenat do kojeg je dosao pri obradi dokumenata
 */
static function SaveObrada(nPRec)
*{
local nArr
nArr := SELECT()

O_PARAMS
select params

private cSection:="K"
private cHistory:=" "
private aHistory:={}

Wpar("is", nPRec)

select (nArr)

return
*}

/*! \fn RestoreObrada()
 *  \brief Pokrece ponovo obradu od momenta do kojeg je stao
 */
static function RestoreObrada()
*{
O_PARAMS
select params
private cSection:="K"
private cHistory:=" "
private aHistory:={}
private nDosaoDo
Rpar("is", @nDosaoDo)

if nDosaoDo == nil
	MsgBeep("Nema nista zapisano u parametrima!#Prekidam operaciju!")
	return 	
endif

if nDosaoDo == 0
	MsgBeep("Nema zapisa o prekinutoj obradi!")
	return
endif

O_PRIPT
select pript
go nDosaoDo

if !EOF()
	MsgBeep("Nastavljam od dokumenta#" + field->idfirma + "-" + field->idvd + "-" + field->brdok)
else
	MsgBeep("Kraj tabele, nema nista za obradu!")
	return
endif

if Pitanje(,"Nastaviti sa obradom dokumenata", "D") == "N"
	MsgBeep("Operacija prekinuta!")
	return
endif

ObradiImport(nDosaoDo)

return
*}

/*! \fn ObradiDokument(cIdVd)
 *  \brief Obrada jednog dokumenta
 *  \param cIdVd - id vrsta dokumenta
 */
function ObradiDokument(cIdVd)
*{

// 1. pokreni asistenta
// 2. azuriraj kalk
// 3. azuriraj FIN

private lAsistRadi:=.f.
// pozovi asistenta
KUnos(.t.)
// odstampaj kalk
StKalk(nil,nil,.t.)
// azuriraj kalk
Azur(.t.)
OEdit()

// ako postoje zavisni dokumenti non stop ponavljaj proceduru obrade
altd()
private nRslt
do while (ChkKPripr(cIdVd, @nRslt) <> 0)
	// vezni dokument u pripremi je ok
	if nRslt == 1
		// otvori pripremu
		KUnos(.t.)
		StKalk(nil, nil, .t.)
		Azur(.t.)
		OEdit()
	endif

	// vezni dokument ne pripada azuriranom dokumentu 
	// sta sa njim
	if nRslt == 2
		MsgBeep("Dokument u pripremi ne pripada azuriranom#veznom dokumentu!!!")
		KUnos()
		OEdit()
	endif
enddo

return
*}

/*! \fn ChkKPripr(cIdVd, nRes)
 *  \brief Provjeri da li je priprema prazna
 *  \param cIdVd - id vrsta dokumenta
 */
function ChkKPripr(cIdVd, nRes)
*{
// provjeri da li je priprema prazna, ako je prazna vrati 0
select pripr
go top

if RecCount() == 0
	// idi dalje...
	nRes := 0
	return 0
endif

// provjeri koji je dokument u pripremi u odnosu na cIdVd
return nRes:=ChkTipDok(cIdVd)

return 0
*}

/*! \fn ChkTipDok(cIdVd)
 *  \brief Provjeri pripremu za tip dokumenta
 *  \param cIdVd - vrsta dokumenta
 */
static function ChkTipDok(cIdVd)
*{

nNrRec := RecCount()
nTmp := 0
cPrviDok := field->idvd
nPrviDok := VAL(cPrviDok)

do while !EOF()
	nTmp += VAL(field->idvd)
	skip
enddo

nUzorak := nPrviDok * nNrRec

if nUzorak <> nNrRec * nTmp
	// ako u pripremi ima vise dokumenata vrati 2
	return 3
endif

do case
	case cIdVd == "14"
		return ChkTD14(cPrviDok)
	case cIdVd == "41"
		return ChkTD41(cPrviDok)
	case cIdVd == "11"
		return ChkTD11(cPrviDok)
	case cIdVD == "95"
		return ChkTD95(cPrviDok)
endcase

return 0
*}


/*! \fn ChkTD14(cVezniDok)
 *  \brief Provjeri vezne dokumente za tip dokumenta 14
 *  \param cVezniDok - dokument iz pripreme
 *  \result vraca 1 ako je sve ok, ili 2 ako vezni dokument ne odgovara
 */
static function ChkTD14(cVezniDok)
*{
if cVezniDok $ "18#19#95#16#11"
	return 1
endif

return 2
*}

/*! \fn ChkTD41()
 *  \brief Provjeri vezne dokumente za tip dokumenta 41
 */
static function ChkTD41(cVezniDok)
*{
if cVezniDok $ "18#19#95#16#11"
	return 1
endif

return 2
*}

/*! \fn ChkTD11()
 *  \brief Provjeri vezne dokumente za tip dokumenta 11
 */
static function ChkTD11(cVezniDok)
*{
if cVezniDok $ "18#19#95#16#11"
	return 1
endif

return 2
*}

/*! \fn ChkTD95()
 *  \brief Provjeri vezne dokumente za tip dokumenta 95
 */
static function ChkTD95(cVezniDok)
*{
if cVezniDok $ "18#19#95#16#11"
	return 1
endif

return 2
*}


/*! \fn FillDobSifra()
 *  \brief Popunjavanje polja sifradob prema kljucu
 */
function FillDobSifra()
*{
if !SigmaSif("FILLDOB")
	MsgBeep("Nemate ovlastenja za ovu opciju!!!")
	return
endif

O_ROBA

select roba
set order to tag "ID"
go top

cSifra:=""
nCnt := 0
aRpt := {}
aSDob := {}

Box(,5, 60)
@ 1+m_x, 2+m_y SAY "Vrsim upis sifre dobavaljaca robe:"
@ 2+m_x, 2+m_y SAY "==================================="

do while !EOF()
	// ako je prazan zapis preskoci
	if Empty(field->id)
		skip
		loop
	endif

	cSStr := SUBSTR(field->id, 1, 1)
	
	// provjeri karakteristicnost robe
	if cSStr == "K" .or. cSStr == "P"
		// roba KOKA LEN 5 sifradob
		cSifra := SUBSTR(RTRIM(field->id), -5)
	elseif cSStr == "V"
		// ostala roba
		cSifra := SUBSTR(RTRIM(field->id), -4)
	else
		skip
		loop
	endif
	
	// upisi zapis
	Scatter()
	_sifradob := cSifra
	Gather()
	
	// potrazi sifru u matrici
	nRes := ASCAN(aSDob, {|aVal| aVal[1] == cSifra})
	if nRes == 0
		AADD(aSDob, {cSifra, field->id})
	else
		AADD(aRpt, {cSifra, aSDob[nRes, 2]})
		AADD(aRpt, {cSifra, field->id})
	endif
	
	++ nCnt
	
	@ 3+m_x, 2+m_y SAY "FMK sifra " + ALLTRIM(field->id) + " => sifra dob. " + cSifra
	@ 5+m_x, 2+m_y SAY " => ukupno " + ALLTRIM(STR(nCnt))

	skip
	
enddo

BoxC()

// ako je report matrica > 0 dakle postoje dupli zapisi
if LEN(aRpt) > 0
	START PRINT CRET
	? "KONTROLA DULIH SIFARA VINDIJA_FAKT:"
	? "==================================="
	? "Sifra Vindija_FAKT -> Sifra FMK  "
	? 
	
	for i:=1 to LEN(aRpt)
		? aRpt[i, 1] + " -> " + aRpt[i, 2]
	next
	
	?
	? "Provjerite navedene sifre..."
	?
	
	FF
	END PRINT
endif


return
*}


