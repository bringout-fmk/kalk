#include "kalk.ch"


// ----------------------------------------
// ----------------------------------------
function cre_cache()
local aFld := {}
local cTbl := PRIVPATH + SLASH + "CACHE.DBF"

AADD( aFld, { "idkonto", "C", 7, 0 } )
AADD( aFld, { "idroba", "C", 10, 0 } )
AADD( aFld, { "ulaz", "N", 18, 8 } )
AADD( aFld, { "izlaz", "N", 18, 8 } )
AADD( aFld, { "stanje", "N", 18, 8 } )
AADD( aFld, { "nvu", "N", 18, 8 } )
AADD( aFld, { "nvi", "N", 18, 8 } )
AADD( aFld, { "nv", "N", 18, 8 } )

if !if_cache()
	DBCreate2( cTbl, aFld )
	create_index("1","idkonto+idroba", cTbl )
endif

return 


// -------------------------------
// ima li cache tabele
// -------------------------------
function if_cache()
local lRet := .f.

if FILE(PRIVPATH + SLASH + "CACHE.DBF")
	lRet := .t.
endif

return lRet




// -------------------------------------------
// vrati informacije iz cache tabele
// -------------------------------------------
function knab_cache( cC_Kto, cC_Roba, nC_Ulaz, nC_Izlaz, ;
	nC_Stanje, nC_NVU, nC_NVI, nC_NV )

local nTArea := SELECT()

nC_ulaz := 0
nC_izlaz := 0
nC_stanje := 0
nC_nvu := 0
nC_nvi := 0
nC_nv := 0

O_CACHE
select cache
set order to tag "1"

seek cC_Kto + cC_Roba

if FOUND()
	nC_Ulaz := field->ulaz
	nC_Izlaz := field->izlaz
	nC_Stanje := field->stanje
	nC_NVU := field->nvu
	nC_NVI := field->nvi
	nC_Nv := field->nv
endif

select (nTArea)

return


// ---------------------------------------------------
// lista konta
// ---------------------------------------------------
static function _g_kto( cMList, cPList )
local GetList:={}

cMList := PADR("1310;13101;", 200)
cPList := PADR("1320;", 200)

Box(,2,60)
	@ m_x + 1, m_y + 2 SAY "Mag. konta:" GET cMList PICT "@S40"
	@ m_x + 2, m_y + 2 SAY "Pro. konta:" GET cPList PICT "@S40"
	read
BoxC()

if LastKey() == K_ESC
	return 0
endif

return 1



// --------------------------------------------------
// generisi cache tabelu
// --------------------------------------------------
function gen_cache()

local nIzlNV
local nIzlKol
local nUlNV
local nUlKol
local nKolNeto
local cIdKonto
local cIdFirma := gFirma
local cIdRoba
local cMKtoLst
local cPKtoLst
local GetList:={}
local i

if _g_kto( @cMKtoLst, @cPKtoLst ) == 0
	return
endif

cre_cache()

O_CACHE
select cache
zapp()

O_CACHE
O_KALK


Box(,1, 70)

aKto := TokToNiz( cMKtoLst, ";" )

for i := 1 to LEN( aKto )

  cIdKonto := PADR( aKto[i], 7 )

  @ m_x + 1, m_y + 2 SAY "mag. konto: " + cIdKonto

  select kalk
  set order to tag "3"
  go top

  seek cIdFirma + cIdKonto

  do while !EOF() .and. cIdFirma == idfirma ;
	.and. cIdKonto == mkonto 
	
	cIdRoba := field->idroba

 	nKolicina := 0
  	nIzlNV:=0   
  	// ukupna izlazna nabavna vrijednost
  	nUlNV:=0
  	nIzlKol:=0   
  	// ukupna izlazna kolicina
 	nUlKol:=0  
  	// ulazna kolicina

	@ m_x + 1, col() + 1 SAY cIdRoba

	do while !EOF() .and. cIdFirma+cIdKonto+cIdRoba==idFirma+mkonto+idroba 

  		if field->mu_i == "1" .or. field->mu_i == "5"
    		  
		  if idvd == "10"
      			nKolNeto := abs(kolicina-gkolicina-gkolicin2)
    		  else
      			nKolNeto := abs(kolicina)
    		  endif

    		  if ( field->mu_i == "1" .and. field->kolicina > 0 ) ;
		  	.or. ( field->mu_i == "5" .and. field->kolicina < 0 )
         		
			nKolicina += nKolNeto    
         		nUlKol += nKolNeto    
         		nUlNV += ( nKolNeto * field->nc )      
    		  
		  else
         		
			nKolicina -= nKolNeto
         		nIzlKol += nKolNeto
         		nIzlNV += ( nKolNeto * field->nc )

    		  endif
  		
		endif
  		
		skip
	
	enddo 

	if round( nKolicina, 5 ) == 0
 		nSNC := 0
	else
 		nSNC := ( nUlNV - nIzlNV ) / nKolicina
	endif

	nKolicina := round( nKolicina, 4 )
	
	// upisi u cache
	select cache
	append blank

	replace idkonto with cIdKonto
	replace idroba with cIdRoba
	replace ulaz with nUlKol
	replace izlaz with nIzlkol
	replace stanje with nKolicina
	replace nvu with nUlNv
	replace nvi with nIzlNv
	replace nv with nSnc

	select kalk

  enddo

next

i := 1

// a sada prodavnice

aKto := TokToNiz( cPKtoLst, ";" )

for i := 1 to LEN( aKto )

  cIdKonto := PADR( aKto[i], 7 )

  @ m_x + 1, m_y + 2 SAY "prod.konto: " + cIdKonto

  select kalk
  set order to tag "3"
  go top

  seek cIdFirma + cIdKonto

  do while !EOF() .and. cIdFirma == idfirma ;
	.and. cIdKonto == mkonto 
	
	cIdRoba := field->idroba

 	nKolicina := 0
  	nIzlNV:=0   
  	// ukupna izlazna nabavna vrijednost
  	nUlNV:=0
  	nIzlKol:=0   
  	// ukupna izlazna kolicina
 	nUlKol:=0  
  	// ulazna kolicina

	@ m_x + 1, col() + 1 SAY cIdRoba

	do while !EOF() .and. cIdFirma+cIdKonto+cIdRoba==idFirma+mkonto+idroba 

	  if field->pu_i == "1" .or. field->pu_i == "5"
    	    if ( field->pu_i == "1" .and. field->kolicina > 0 ) ;
	    	.or. ( field->pu_i == "5" .and. field->kolicina < 0 )
      		nKolicina += abs(field->kolicina)       
      		nUlKol    += abs(field->kolicina)       
      		nUlNV     += (abs(field->kolicina)*field->nc)  
    	    else
      		nKolicina -= abs(field->kolicina)
      		nIzlKol   += abs(field->kolicina)
      		nIzlNV    += (abs(field->kolicina)*field->nc)
    	    endif
  	  elseif field->pu_i=="I"
     		nKolicina-=field->gkolicin2
     		nIzlKol+=field->gkolicin2
     		nIzlNV+=field->nc*field->gkolicin2
  	  endif
  	  skip

  	enddo 

	if round( nKolicina, 5 ) == 0
 		nSNC := 0
	else
 		nSNC := ( nUlNV - nIzlNV ) / nKolicina
	endif

	nKolicina := round( nKolicina, 4 )
	
	// upisi u cache
	select cache
	append blank

	replace idkonto with cIdKonto
	replace idroba with cIdRoba
	replace ulaz with nUlKol
	replace izlaz with nIzlkol
	replace stanje with nKolicina
	replace nvu with nUlNv
	replace nvi with nIzlNv
	replace nv with nSnc

	select kalk

  enddo

next

BoxC()

return



