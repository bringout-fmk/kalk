#include "\dev\fmk\kalk\kalk.ch"


/*! \fn MnuImpTxt()
 *  \brief Menij opcije import txt
 */
function MnuImpTxt()
*{
private izbor:=1
private opc:={}
private opcexe:={}

AADD(opc, "1. import vindija racun        ")
AADD(opcexe, {|| ImpTxtDok("R")})
AADD(opc, "2. import vindija partner      ")
AADD(opcexe, {|| ImpTxtDok("P")})

Menu_SC("itx")

return
*}

/*! \fn ImpTxtDok(cTip)
 *  \brief Import dokumenta
 *  \param cTip - tip importa
 */
function ImpTxtDok(cTip)
*{
private cExpPath
private cImpFile

// setuj varijablu putanje exportovanih fajlova
GetExpPath(@cExpPath)

cFFilt := cTip + "*." + cTip + "??"

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
if cTip == "R"
	SetTblDok(@aDbf)
	// setuj pravila upisa podataka u temp tabelu
	SetRuleDok(@aRules)
endif
if cTip == "P"
	SetTblPartn(@aDbf)
	// setuj pravila upisa podataka u temp tabelu
	SetRulePartn(@aRules)
endif

// prebaci iz txt => temp tbl
Txt2TTbl(aDbf, aRules, cImpFile)

if !CheckTbl(cTip)
	MsgBeep("Prekidamo operaciju !!!#Nepostojece sifre!!!")
	return
endif

if cTip == "R"
	if TTbl2Kalk() == 0
		MsgBeep("Operacija prekinuta!")
		return 
	endif
	MsgBeep("Dokumenti prebaceni u pripremu#Izvrsiti obradu asistentom...")
endif
if cTip == "P"
	if TTbl2Partn() == 0
		MsgBeep("Operacija prekinuta!")
		return
	endif
	MsgBeep("Novi partneri su dodati u sifrarnik!")
endif

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
AADD(aDbf,{"dindem", "C", 3, 0})
AADD(aDbf,{"zaokr", "N", 1, 0})
AADD(aDbf,{"rbr", "C", 3, 0})
AADD(aDbf,{"idroba", "C", 10, 0})
AADD(aDbf,{"kolicina", "N", 14, 5})
AADD(aDbf,{"cijena", "N", 14, 5})
AADD(aDbf,{"rabat", "N", 8, 5})
AADD(aDbf,{"porez", "N", 9, 5})

return
*}

/*! \fn SetTblPartner(aDbf)
 *  \brief Set polja tabele partner
 *  \param aDbf - matrica sa def.polja
 */
static function SetTblPartner(aDbf)
*{

AADD(aDbf,{"id", "C", 6, 0})
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
AADD(aRule, {"SUBSTR(cVar, 6, 9)"})
// datdok
AADD(aRule, {"CTOD(SUBSTR(cVar, 16, 10))"})
// idpartner 
AADD(aRule, {"SUBSTR(cVar, 27, 6)"})
// dindem
AADD(aRule, {"SUBSTR(cVar, 34, 3)"})
// zaokr
AADD(aRule, {"VAL(SUBSTR(cVar, 38, 1))"})
// rbr
AADD(aRule, {"STR(VAL(SUBSTR(cVar, 40, 3)),3)"})
// idroba
AADD(aRule, {"ALLTRIM(SUBSTR(cVar, 44, 5))"})
// kolicina
AADD(aRule, {"VAL(SUBSTR(cVar, 50, 16))"})
// cijena
AADD(aRule, {"VAL(SUBSTR(cVar, 67, 16))"})
// rabat
AADD(aRule, {"VAL(SUBSTR(cVar, 84, 14))"})
// porez
AADD(aRule, {"VAL(SUBSTR(cVar, 99, 14))"})

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
AADD(aRule, {"SUBSTR(cVar, 7, 25)"})
// ptt
AADD(aRule, {"SUBSTR(cVar, 35, 6)"})
// mjesto
AADD(aRule, {"SUBSTR(cVar, 42, 10)"})
// adresa 
AADD(aRule, {"SUBSTR(cVar, 27, 6)"})
// ziror
AADD(aRule, {"SUBSTR(cVar, 34, 3)"})
// telefon
AADD(aRule, {"SUBSTR(cVar, 38, 1)"})
// fax
AADD(aRule, {"SUBSTR(cVar, 40, 3)"})
// idops
AADD(aRule, {"SUBSTR(cVar, 44, 5)"})
// rokpl
AADD(aRule, {"SUBSTR(cVar, 50, 16)"})
// porbr
AADD(aRule, {"SUBSTR(cVar, 67, 16)"})
// idbroj
AADD(aRule, {"SUBSTR(cVar, 84, 14)"})
// ustn
AADD(aRule, {"SUBSTR(cVar, 99, 14)"})
// brupis
AADD(aRule, {"SUBSTR(cVar, 99, 14)"})
// brjes
AADD(aRule, {"SUBSTR(cVar, 99, 14)"})

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
do while .t.
	IzbF:=Menu("imp", OpcF, IzbF, .f.)
	if IzbF==0
        	exit
		return 0
        else
        	cImpFile:=Trim(cPath)+Trim(LEFT(OpcF[IzbF],15))
        	if Pitanje(,"Zelite li izvrsiti import fajla ?","D")=="D"
        		IzbF:=0
          	endif
        endif
enddo

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
		fname := FIELD(nCt)
		xVal := aRules[nCt, 1]
		replace &fname with &xVal
	next
next

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


/*! \fn CheckId()
 *  \brief Provjera da li postoje sifre u sifrarnicima
 */
function CheckTbl(cTip)
*{

if cTip == nil
	cTip := "R"
endif

aPomPart := ParExist()
aPomArt := {}

if cTip == "R"
	aPomArt := ArtExist()
endif

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


/*! \fn ParExist()
 *  \brief Provjera da li postoje sifre partnera u sifraniku FMK
 */
function ParExist()
*{
O_PARTN
select temp
go top

aRet:={}

do while !EOF()
	select partn
	go top
	seek temp->idpartner
	if !Found()
		AADD(aRet, {temp->idpartner})
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



/*! \fn TTbl2Kalk()
 *  \brief kopira podatke iz pomocne tabele u tabelu KALK->PRIPREMA
 */
function TTbl2Kalk()
*{
local dDatDok
local cBrojKalk
local cTipDok
local cIdKonto
local cIdKonto2
local cRazd

if GetKVars(@dDatDok, @cBrojKalk, @cTipDok, @cIdKonto, @cIdKonto2, @cRazd) == 0
	return 0
endif

O_PRIPR
O_DOKS
O_ROBA

select temp
go top

nRbr:=0

cPFakt := ALLTRIM(temp->brdok)

do while !EOF()

	cFakt := ALLTRIM(temp->brdok)
	if cRazd == "D"
		if cFakt <> cPFakt
			cBrojKalk:=GetNextKalkDoc(gFirma, cTipDok)
		endif
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
	replace idvd with cTipDok
	replace brdok with cBrojKalk
	replace datdok with dDatDok
	replace idpartner with temp->idpartner
	replace idtarifa with ROBA->idtarifa
	replace brfaktp with cFakt
	replace datfaktp with temp->datdok
	replace idkonto   with cIdKonto
	replace idkonto2  with cIdKonto2
	replace idzaduz2  with ""
	replace datkurs with temp->datdok
	replace kolicina with temp->kolicina
	replace idroba with roba->id
	replace nc with ROBA->nc
	replace vpc with temp->cijena
	replace rabatv with temp->rabat
	replace mpc with temp->porez
	
	cPFakt := cFakt
	
	select temp
	skip
enddo

return 1
*}


/*! \fn TTbl2Partn()
 *  \brief kopira podatke iz pomocne tabele u tabelu PARTN
 */
function TTbl2Partn()
*{

O_PARTN
O_SIFK
O_SIFV

select temp
go top

do while !EOF()

	// pronadji partnera
	select partn
	cTmpPar := ALLTRIM(temp->id)
	go top
	seek cTmpPar
	
	// ako si nasao preskoci
	if Found()
		select temp
		skip
		loop
	endif
	
	// dodaj zapis u partn
	select partn
	append blank
	replace id with temp->id
	replace naz with temp->naz
	replace ptt with temp->ptt
	replace mjesto with temp->mjesto
	replace adresa with temp->adresa
	replace ziror with temp->ziror
	replace telefon with temp->telefon
	replace fax with temp->fax
	replace idops with temp->idops
	replace rokpl with temp->rokpl
	replace porbr with temp->porbr
	replace idbroj with temp->idbroj
	replace ustn with temp->ustn
	replace brupis with temp->brupis
	replace brjes with temp->brjes
	
	select temp
	skip
enddo

return 1
*}



/*! \fn GetKVars()
 *  \brief Setuj parametre prenosa
 */
static function GetKVars(dDatDok, cBrKalk, cTipDok, cIdKonto, cIdKonto2, cRazd)
*{

dDatDok:=DATE()
cTipDok:="14"
cIdFirma:=gFirma
cIdKonto:=PADR("1200",7)
cIdKonto2:=PADR("1310",7)
cRazd:="D"
O_DOKS
cBrKalk:=GetNextKalkDoc(cIdFirma, cTipDok)

Box(,15,60)
	@ m_x+1,m_y+2   SAY "Broj kalkulacije 14-" GET cBrKalk pict "@!"
  	@ m_x+1,col()+2 SAY "Datum:" GET dDatDok
  	@ m_x+4,m_y+2   SAY "Konto razduzuje:" GET cIdKonto2 pict "@!" when !glBrojacPoKontima valid P_Konto(@cIdKonto2)
  	@ m_x+6,m_y+2   SAY "Razdvajati kalkulacije po broju faktura" GET cRazd pict "@!" valid cRazd$"DN"
	read
BoxC()

if lastkey()==K_ESC
	return 0
endif

return 1
*}
  


/*! \fn TxtErase(cTxtFile)
 *  \brief Brisanje fajla cTxtFile
 *  \param cTxtFile - fajl za brisanje
 */
function TxtErase(cTxtFile)
*{
if FErase(cTxtFile) == -1
	MsgBeep("Ne mogu izbrisati " + cTxtFile)
	ShowFError()
endif

return
*}

