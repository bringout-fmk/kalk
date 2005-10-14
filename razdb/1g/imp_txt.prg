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

// daj mi pregled fajlova za import, te setuj varijablu cImpFile
if GetFList("R*.R??", cExpPath, @cImpFile)==0
	return
endif

MsgBeep(cImpFile)


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


/*! \fn ImpTxtSif()
 *  \brief Import sifrarnika
 */
function ImpTxtSif()
*{

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

// sortiraj po datumu
ASORT(aFiles,,,{|x,y| x[3]>y[3]})

AEVAL(aFiles,{|elem| AADD(OpcF, PADR(elem[1],15)+" "+dtos(elem[3]))},1)

// sortiraj listu po datumu
ASORT(OpcF,,,{|x,y| RIGHT(x,10)>RIGHT(y,10)})

h:=ARRAY(LEN(OpcF))
for i:=1 to LEN(h)
	h[i]:=""
next

if LEN(OpcF)==0
	MsgBeep("U direktoriju za prenos nema podataka")
	return 0
endif

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


return
*}

/*! \fn CheckId(cId)
 *  \brief Provjera da li postoje sifre u sifrarnicima
 *  \param cId - id sifre
 */
function CheckId(cId)
*{


return
*}

/*! \fn ParExist(cId)
 *  \brief Provjera da li postoje sifre partnera u sifraniku FMK
 *  \param cId - id sifre
 */
function ParExist(cId)
*{

return
*}

/*! \fn ArtExist(cId)
 *  \brief Provjera da li postoje sifre artikla u sifraniku FMK
 *  \param cId - id sifre
 */
function ArtExist(cId)
*{

return
*}

/*! \fn TTbl2Kalk()
 *  \brief kopira podatke iz pomocne tabele u tabelu KALK->PRIPREMA
 */
function TTbl2Kalk()
*{

return
*}


/*! \fn TTbl2Partn()
 *  \brief kopira podatke iz pomocne tabele u tabelu PARTN
 */
function TTbl2Partn()
*{

return
*}


/*! \fn TxtErase(cTxtFile)
 *  \brief Brisanje fajla cTxtFile
 *  \param cTxtFile - fajl za brisanje
 */
function TxtErase(cTxtFile)
*{


return
*}


function TestImpFile()
*{
nLin:=BrLinFajla(PRIVPATH+SLASH+"test.txt")
MsgBeep(STR(nLin))
nPocetak:=0
nPreskociRedova:=0
for i:=1 to nLin
	aPom:=SljedLin(PRIVPATH+SLASH+"test.txt",nPocetak)
      	nPocetak:=aPom[2]
      	cLin:=aPom[1]
	MsgBeep(cLin)
next


return
*}


