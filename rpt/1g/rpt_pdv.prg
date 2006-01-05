#include "\dev\fmk\kalk\kalk.ch"

static aHeader:={}
static aZaglLen:={4, 6, 4, 8, 14, 8, 8, 14}
static aZagl:={}
static cij_decimala:=2
static izn_decimala:=2

function rpt_uio(lAkciznaRoba, lZasticeneCijene)

cIdFirma := gFirma
cBrDok := SPACE(8)
cIdVd := "80"

dDate := CTOD("31.12.05")
Box(, 6, 60)
  @ m_x+1, m_y+2 SAY "Dokument "
  @ m_x+2, m_y+2 SAY gFirma + " - " + cIdVd + " " GET cBrDok 
  @ m_x+3, m_y+2 SAY dDate
  @ m_x+5, m_y+2 SAY "Broj decimala cijena " GET cij_decimala
  @ m_x+6, m_y+2 SAY "Broj decimala iznos  " GET izn_decimala
  
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
AADD(aHeader, { "Popis zaliha na dan :" +  DTOC(dDate) } )
AAAD(aHeader, { "" } )
AADD(aHeader, { "Prodavnica :" + konto->naz } )
AADD(aHeader, { "" } )

AADD(aZagl, { "R." , "jed" , "kol", "cijena", "zaduz", "#3Porez na promet proizvoda" } )
AADD(aZagl, { "br.", "mj", "", "", "(3 x 4)", "Prerac", "u cijeni", "Ukupno" })
AADD(aZagl, { ""   ,  "" , "", "", ""       , "stopa"      , ""        ,  "" } )
AADD(aZagl, { "(1)"  , "(2)" , "(3)", "(4)", "(5)", "(6)=(4x5)", "7", "8=(5x7)", "9=(8x4))" })


fill_uio(lAkciznaRoba, lZasticeneCijene)


/*! \fn get_uio_fields(aArr)
 *  \brief napuni matricu aArr sa specifikacijom polja tabele
 *  \param aArr - matrica
 */
function get_drn_fields(aArr)
*{
AADD(aArr, {"IdTarifa",   "C",  6, 0})
AADD(aArr, { "Tarifa",   "N",  10, 2})
AADD(aArr, {"IdRoba",   "C",  10, 0})
AADD(aArr, {"NazivR",   "C",  40, 0})
AADD(aArr, {"jmj",  "C",  3, 0})
AADD(aArr, {"kol",  "N",  15, 5})
AADD(aArr, {"cij_ppp",  "N",  15, 5})
AADD(aArr, {"zad_ppp", "N",  17, 2})
AADD(aArr, {"ppp_pstopa", "N", 8, 3})
AADD(aArr, {"ppp_ucj" , "N", 15, 5})
AADD(aArr, {"ukupno",  "N",  17, 3})
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

// provjeri da li postoji fajl DRN.DBF
if !FILE(PRIVPATH + cUioTbl)
	geget_drn_fields(@aArr)
        // kreiraj tabelu
	dbcreate2(PRIVPATH + cUioTbl, aArr)
endif

// kreiraj indexe
CREATE_INDEX("1", "idtarifa+idRoba", PRIVPATH +  cUioTbl)

return
*}



// napuni r_uio
function fill_uio( cIdFirma, cIdVd,  cBrDok, lAkciznaRoba, lZasticeneCijene)
*{

// + stavka preknjizenja = pdv
// - stavka = ppp

t_uio_create()


O_R_UIO


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

START PRINT CRET

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
       SELECT r_uio
       replace kol with ABS(kolicina),;
               cij_ppp with mpcsapp,;
	       zad_ppp with mpcsapp * ABS(kolicina)
       replace ppp_ucj with cij_ppp * ppp_stopa
       replace uk_ppp with kol * cij_ppp
       
endif

// pdv stavka
// 2 krug gledam samo pozitivne stavke
if (nKrug == 2)  .and. (kalk->kolicina > 0)
	SELECT r_uio
	replace cij_b_pdv WITH cij_ppp - ppp_ucj
	replace izn_pdv with cij_b_pdv * 0.17
	replace cij_pdv WITH cij_b_pdv * 1.17
	replace uk_pdv with kol * izn_pdv
	replace zad_pdv with kol * cij_sa_pdv
	replace razlika with zad_ppp - zad_pdv
endif


SELECT KALK
skip

enddo
// krugovi
next
MsgC()

return
*}


function show_r_uio(cIdVd, cIdFirma, cBrDok, lAkciznaRoba, lZasticenaRoba)
*{

O_R_UIO

START PRINT CRET

nRow := 0

uio_zagl()

SELECT r_uio
SET ORDER TO TAG "1"
go top
nRbr := 0

do while !eof()
  ? PADR(STR(nRbr, aZaglLen[1])) + " "
  ?? PADC(jmj, aZaglLen[2])
  ?? PADC(jmj, aZaglLen[3])
  
  // cijena ppp
  cPom:= ALLTRIM( STR(cij_ppp, 10, cij_decimala))
  ?? PADC(cPom,  aZaglLen[4])
  
  SKIP
enddo

END PRINT
return
*}

static function uio_zagl()

// header
for i:=1 to LEN(aHeader)
 ? aHeader[i]
next

r_linija()

for i:=1 to LEN(aZagl)
 ?
 for nCol:=1 to LEN(aZaglLen)
  	// mergirana kolona
 	if LEFT(aZagl[i, nCol],1) = "#" 
	  nMergirano := VAL( SUBSTR(aZagl[i, nCol], 2,1 ) )
	  cPom := SUBSTR(aZagl[i,nCol], 3)
	  nMrgWidth := 0
	  for nMrg:=1 to nMergirano 
	  	nMrgWidth += aZaglLen[nCol+nMrg-1] 
		nMrgWidth ++
	  next
	  ?? PADC(cPom), nMrgWidth
	  nCol += (nMergirano - 1)
	 else
 	  ?? PADC(aZagl[i, nCol], aZaglLen[nCol])
	 endif
 next
next
?

r_linija()

return

static function r_linija()
*{
?
for i=1 to LEN(aZaglLen)
   ?? PADR("-", aZaglLen[i])
   ?? " "
next

return
*}
