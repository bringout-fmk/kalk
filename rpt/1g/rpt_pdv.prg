#include "\dev\fmk\kalk\kalk.ch"

static aHeader:={}
static aZaglLen:={5, 50, 5, 12, 15, 15, 10, 10, 15}
static aZagl:={}
static cij_decimala:=2
static izn_decimala:=2
static kol_decimala:=3
static PDV_STOPA:=17

// tekuca linija reporta
static nCurrLine:=0

function rpt_uio()

local lAkciznaRoba := .f.
local lZasticeneCijene := .f.

cIdFirma := gFirma
cBrDok := PADR("00010", 8)
cIdVd := "80"
cLandscape := "D"

dDate := CTOD("31.12.05")
Box(, 7, 60)
  @ m_x+1, m_y+2 SAY "Dokument "
  @ m_x+2, m_y+2 SAY gFirma + " - " + cIdVd + " " GET cBrDok 
  @ m_x+3, m_y+2 SAY "Datum " GET dDate
  @ m_x+4, m_y+2 SAY PADR("-", 30, "-")
  @ m_x+5, m_y+2 SAY "Broj decimala cijena  " GET cij_decimala PICT "9"
  @ m_x+6, m_y+2 SAY "                iznos " GET izn_decimala PICT "9"
  @ m_x+6, m_y+2 SAY "             kolicina " GET kol_decimala PICT "9"
  @ m_x+7, m_y+2 SAY "Landscape format " GET cLandscape PICT "@!" VALID cLandscape $ "DN"

  
  READ
BoxC()

if LastKey()==K_ESC
	closeret
endif

O_KALK
SET ORDER TO TAG "1"
seek cIdFirma + cIdVd + cBrDok 

O_ROBA
O_KONTO
O_KONCIJ
O_TARIFA

SELECT KONTO
SEEK kalk->PKonto

aHeader := {}
AADD(aHeader, "Preduzece: " + gNFirma)
AADD(aHeader, "Popis zaliha na dan :" +  DTOC(dDate) + ", Prodavnica :" + konto->naz )

AADD(aZagl, { "R." , "Vrsta robe", "jed" , "kolic", "cijena", "zaduz", "#3Porez na promet proizvoda" } )
AADD(aZagl, { "br.", "", " mj", "", "", "(3 x 4)", "Prer.st", "u cijeni", "Ukupno" })
//AADD(aZagl, { ""   ,  "", "" , "", "", ""       , "stopa"      , ""        ,  "" } )
AADD(aZagl, { "(1)"  , "(2)" , "(3)", "(4)", "(5)", "(6)=(4x5)", "7", "8=(5x7)", "9=(8x4))" })


fill_uio(cIdFirma, cIdVd, cBrDok, lAkciznaRoba, lZasticeneCijene)
show_uio( (cLandscape=="D"), lAkciznaRoba, lZasticeneCijene )

close all
*}

/*! \fn get_uio_fields(aArr)
 *  \brief napuni matricu aArr sa specifikacijom polja tabele
 *  \param aArr - matrica
 */
static function get_uio_fields(aArr)
*{
AADD(aArr, {"IdTarifa",   "C",  6, 0})
AADD(aArr, {"Tarifa",   "N",  10, 2})
AADD(aArr, {"IdRoba",   "C",  10, 0})
AADD(aArr, {"NazivR",   "C",  40, 0})
AADD(aArr, {"jmj",  "C",  3, 0})
AADD(aArr, {"kol",  "N",  15, 5})
AADD(aArr, {"cij_ppp",  "N",  15, 5})
AADD(aArr, {"zad_ppp", "N",  17, 2})
AADD(aArr, {"ppp_pstopa", "N", 8, 3})
AADD(aArr, {"ppp_ucj" , "N", 15, 5})
AADD(aArr, {"uk_ppp",  "N",  17, 3})
AADD(aArr, {"cij_b_pdv", "N", 9, 3})
AADD(aArr, {"izn_pdv", "N", 9, 3})
AADD(aArr, {"cij_sa_pdv", "N", 9, 3})
AADD(aArr, {"uk_pdv", "N", 17, 3})
AADD(aArr, {"zad_pdv", "N", 17, 2})
AADD(aArr, {"razlika", "N", 17, 3})

return
*}

function t_uio_create()
*{
local cUioTbl := "R_UIO.DBF"
local aArr:={}

close all

ferase ( PRIVPATH + "R_UIO.CDX" )

get_uio_fields(@aArr)
// kreiraj tabelu
dbcreate2(PRIVPATH + cUioTbl, aArr)

// kreiraj indexe
CREATE_INDEX("1", "idtarifa+idRoba", PRIVPATH +  cUioTbl, .t.)

return
*}



// napuni r_uio
function fill_uio( cIdFirma, cIdVd,  cBrDok, lAkciznaRoba, lZasticeneCijene)
*{

// + stavka preknjizenja = pdv
// - stavka = ppp

t_uio_create()


O_R_UIO


SELECT (F_KALK)
if !used()
	O_KALK
endif

SELECT (F_ROBA)
if !used()
	O_ROBA
endif

SELECT (F_TARIFA)
if !used()
	O_TARIFA
endif


SELECT KALK
//"1","idFirma+IdVD+BrDok+RBr
SET ORDER TO TAG "1"

// prvo gledam ppp stavke - negativne stavke 
// u drugom krugu gledam pdv - pozitivne stavke

Box(,3, 60)


nCount := 0

for nKrug:=1 to 2

SEEK cIdFirma + cIdVd + cBrDok
do while !eof() .and. (IdFirma == cIdFirma) .and. (IdVd == cIdVd)  .and. (BrDok == cBrdok)

++nCount


cIdTarifa := idTarifa
cIdRoba := IdRoba

@ m_x+1, m_y+2 SAY "Krug " + STR(nKrug,1) + " " + STR(nCount, 6)
@ m_x+2, m_y+2 SAY cIdRoba + "/" + cIdTarifa
SELECT r_uio
SEEK cIdTarifa + cIdRoba
if !found()
	APPEND BLANK
	replace idtarifa with cIdTarifa, idRoba with cIdRoba
	SELECT roba
	SEEK cIdRoba
	SELECT tarifa
	SEEK cIdTarifa
	SELECT r_uio
	replace jmj WITH roba->jmj ,;
	        nazivR WITH roba->naz 
	replace ppp_pstopa WITH (1-1/(1+tarifa->opp/100))*100
endif

// stavka PPP
// 1 krug gledam samo negativne stavke
if (nKrug == 1) .and. (kalk->kolicina < 0)
       replace kol with ABS(kalk->kolicina),;
               cij_ppp with kalk->mpcsapp,;
	       zad_ppp with kalk->mpcsapp * ABS(kalk->kolicina)
       replace ppp_ucj with cij_ppp * ppp_pstopa
       replace uk_ppp with kol * cij_ppp
       
endif

// pdv stavka
// 2 krug gledam samo pozitivne stavke
if (nKrug == 2)  .and. (kalk->kolicina > 0)
	replace cij_b_pdv WITH cij_ppp - ppp_ucj
	replace izn_pdv with cij_b_pdv * PDV_STOPA / 100
	replace cij_sa_pdv WITH cij_b_pdv * PDV_STOPA / 100
	replace uk_pdv with kol * izn_pdv
	replace zad_pdv with kol * cij_sa_pdv
	replace razlika with zad_ppp - zad_pdv
endif


SELECT KALK
skip

enddo
// krugovi
next

BoxC()

return
*}


function show_uio(lLandscape, lAkciznaRoba, lZasticenaRoba)
*{

nCurrLine := 0

SELECT (F_R_UIO)

if !used()
	O_R_UIO
endif

SELECT (F_TARIFA)
if !used()
   O_TARIFA
endif

START PRINT CRET
P_COND2

if lLandscape
 nPageLimit := 40
  ?? "#%LANDS#"
else
 nPageLimit := 65
endif
nRow := 0

uio_zagl()

SELECT r_uio
SET ORDER TO TAG "1"
go top
nRbr := 0

do while !eof()
  
  cIdTarifa := idTarifa
  nT6:=0
  nT9:=0
  
  ++ nCurrLine
  ? "   Tarifni broj: "
  SELECT TARIFA
  seek cIdTarifa
  ?? cIdTarifa
  ?? " "
  ?? " stopa: " 
  ?? ALLTRIM(STR(tarifa->opp, 10)) + "%"
  SELECT r_uio
  
  r_linija()
  do while !eof() .and. (idTarifa == cIdTarifa)

   if nCurrLine > nPageLimit
   	FF
	nCurrLine:=0
   endif
   
   nRbr ++
   ?
   cPom := ALLTRIM( STR(nRbr,5) )
   ?? PADL(cPom, aZaglLen[1]) 
   ?? " "
   cPom := ALLTRIM( ALLTRIM(idroba) + "-" + NazivR  )
   ?? PADR( cPom , aZaglLen[2])
   ?? " "
   ?? PADR(jmj, aZaglLen[3])
   ?? " "
   cPom:= ALLTRIM( STR(kol, 10, kol_decimala) )
   ?? PADL(cPom, aZaglLen[4])
   ?? " "
   cPom:= ALLTRIM( STR(cij_ppp, 17, cij_decimala) )
   ?? PADL(cPom, aZaglLen[5])
   ?? " "

   cPom:=ALLTRIM( STR(zad_ppp, 17, izn_decimala) )
   ?? PADL( cPom, aZaglLen[6])
   ?? " "
  
   // preracunata stopa
   cPom:= ALLTRIM( STR(ppp_pstopa, 10, cij_decimala))
   ?? PADL(cPom,  aZaglLen[7])
   ?? " "
   
   cPom:= ALLTRIM( STR(ppp_ucj, 10, cij_decimala))
   ?? PADL(cPom,  aZaglLen[8])
   ?? " "

   cPom:= ALLTRIM( STR(uk_ppp, 15, izn_decimala))
   ?? PADL(cPom,  aZaglLen[9])
   ?? " "
  
   SKIP
  enddo

  if (nCurrLine+3) > nPageLimit 
  	FF
	nCurrLine:=0
  endif
  
  r_linija()
   
  // ukupno tarifa

   ?
   ?? PADL("", aZaglLen[1]) 
   ?? " "
   cPom := ""
   ?? PADR( cPom , aZaglLen[2])
   ?? " "
   ?? PADR("", aZaglLen[3])
   ?? " "
   ?? PADR("", aZaglLen[4])
   ?? " "
   cPom:= ""
   ?? PADL(cPom, aZaglLen[5])
   ?? " "
   cPom:=ALLTRIM( STR(nT6, 17, izn_decimala) )
   ?? PADL( cPom, aZaglLen[6])
   ?? " "
  
   // preracunata stopa
   cPom:= ""
   ?? PADL(cPom,  aZaglLen[7])
   ?? " "
   
   cPom:= ""
   ?? PADL(cPom,  aZaglLen[8])
   ?? " "

   cPom:= ALLTRIM( STR(nT9, 15, izn_decimala))
   ?? PADL(cPom,  aZaglLen[9])
   ?? " "
 
  
  // end ukupno tarifa
  
  r_linija()
  
  
enddo

FF
END PRINT
return
*}


static function uio_zagl()

// header
for i:=1 to LEN(aHeader)
 ? aHeader[i]
 ++nCurrLine
next

r_linija()

for i:=1 to LEN(aZagl)
 ++nCurrLine
 ?
 for nCol:=1 to LEN(aZaglLen)
  	// mergirana kolona ovako izgleda
	// "#3 Zauzimam tri kolone"
 	if LEFT(aZagl[i, nCol],1) = "#" 
	  
	  nMergirano := VAL( SUBSTR(aZagl[i, nCol], 2, 1 ) )
	  cPom := SUBSTR(aZagl[i,nCol], 3, LEN(aZagl[i,nCol])-2)
	  nMrgWidth := 0
	  for nMrg:=1 to nMergirano 
	  	nMrgWidth += aZaglLen[nCol+nMrg-1] 
		nMrgWidth ++
	  next
	  ?? PADC(cPom, nMrgWidth)
	  ?? " "
	  nCol += (nMergirano - 1)
	 else
 	  ?? PADC(aZagl[i, nCol], aZaglLen[nCol])
	  ?? " "
	 endif
 next
next
?

r_linija()

return

static function r_linija()
*{
++nCurrLine
?
for i=1 to LEN(aZaglLen)
   ?? PADR("-", aZaglLen[i], "-" )
   ?? " "
next

return
*}
