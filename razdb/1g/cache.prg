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
AADD( aFld, { "z_nv", "N", 18, 8 } )
AADD( aFld, { "odst", "N", 18, 8 } )

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
local nZC_nv := 0

if !if_cache() .or. gCache == "N"
	return 0
endif

cC_Kto := PADR(cC_Kto, 7)
cC_Roba := PADR(cC_Roba, 10)

nC_ulaz := 0
nC_izlaz := 0
nC_stanje := 0
nC_nvu := 0
nC_nvi := 0
nC_nv := 0

O_CACHE
select cache
set order to tag "1"
go top

seek cC_Kto + cC_Roba

if FOUND() .and. ( cC_kto == field->idkonto .and. cC_roba == field->idroba )
	nC_Ulaz := field->ulaz
	nC_Izlaz := field->izlaz
	nC_Stanje := field->stanje
	nC_NVU := field->nvu
	nC_NVI := field->nvi
	nC_Nv := field->nv
	nZC_nv := field->z_nv
endif

// ako se koristi kontrola NC
if gNC_ctrl > 0 .and. nC_nv <> 0 .and. nZC_nv <> 0
	
	nTmp := ROUND( nC_nv, 4 ) - ROUND( nZC_nv, 4 )
	nOdst := ( nTmp / ROUND( nZC_nv, 4 )) * 100

	if ABS(nOdst) > gNC_ctrl
		
		Beep(4)
 		clear typeahead

		msgbeep("Odstupanje NC u odnosu na zadnji ulaz je#" + ;
			ALLTRIM(STR(ABS(nOdst))) + " %")
		
		//a_nc_ctrl( @aNC_ctrl, field->idroba, field->stanje, ;
		//	field->nv, field->z_nv )

		if Pitanje(,"Napraviti korekciju NC (D/N)?", "N") == "D"
			
			nTmp_n_stanje := ( nC_stanje - _kolicina )
			nTmp_n_nv := ( nTmp_n_stanje * nZC_nv )
			nTmp_s_nv := ( nC_stanje * nC_nv )
			
			nC_nv := ( ( nTmp_s_nv - nTmp_n_nv ) / _kolicina ) 

		endif

		if Pitanje(,"Upisati u CACHE novu NC (D/N)?", "D") == "D"
			
			replace field->nv with field->z_nv
			replace field->odst with 0
		
		endif

	endif
endif

select (nTArea)

return 1


// ---------------------------------------------------
// lista konta
// ---------------------------------------------------
static function _g_kto( cMList, cPList, dDatGen )
local GetList:={}
local nTArea := SELECT()

O_PARAMS
private cSection := "Q"
private cHistory := " "
private aHistory:={}

cMList := PADR("1310;13101;", 250)
cPList := PADR("1320;", 250)
dDatGen := DATE()

RPar("mk", @cMList)
RPar("pk", @cPList)

cMList := PADR( cMList, 250 )
cPList := PADR( cPList, 250 )

Box(,3,60)
	@ m_x + 1, m_y + 2 SAY "Mag. konta:" GET cMList PICT "@S40"
	@ m_x + 2, m_y + 2 SAY "Pro. konta:" GET cPList PICT "@S40"
	@ m_x + 3, m_y + 2 SAY "Datum do:" GET dDatGen
	read
BoxC()

if LastKey() == K_ESC
	select (nTArea)
	return 0
endif

WPar("mk", cMList)
WPar("pk", cPList)
WPar("dg", dDatGen)

select (nTArea)

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
local dDatGen
local GetList:={}
local i

// posljednje pozitivno stanje
local nKol_poz := 0
local nUVr_poz, nIVr_poz
local nUKol_poz, nIKol_poz
local nZadnjaNC := 0
local nOdstup := 0

if _g_kto( @cMKtoLst, @cPKtoLst, @dDatGen ) == 0
	return
endif

cre_cache()

O_CACHE
select cache
zap
__dbpack()

O_CACHE
O_KALK


Box(,1, 70)

aKto := TokToNiz( cMKtoLst, ";" )

for i := 1 to LEN( aKto )

  cIdKonto := PADR( aKto[i], 7 )

  if EMPTY(cIdKonto)
  	loop
  endif

  @ m_x + 1, m_y + 2 SAY "mag. konto: " + cIdKonto

  select kalk
  // mkonto
  set order to tag "3"
  go top

  seek cIdFirma + cIdKonto

  do while !EOF() .and. cIdFirma == field->idfirma ;
	.and. cIdKonto == field->mkonto 
	

	cIdRoba := field->idroba

 	nKolicina := 0
  	nIzlNV:=0   
  	// ukupna izlazna nabavna vrijednost
  	nUlNV:=0
  	nIzlKol:=0   
  	// ukupna izlazna kolicina
 	nUlKol:=0  
  	// ulazna kolicina

	nKol_poz := 0
	nZadnjaNC := 0
	nOdstup := 0

	@ m_x + 1, m_y + 20 SAY cIdRoba

	do while !EOF() .and. ((cIdFirma+cIdKonto+cIdRoba) == (idFirma+mkonto+idroba)) 

		// provjeri datum
		if field->datdok > dDatGen
			skip
			loop
		endif

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
    			
			// zadnja nabavna cijena ulaza
			if idvd $ "10#16#96"
				nZadnjaNC := field->nc
			endif
		  
		  else
         		
			nKolicina -= nKolNeto
         		nIzlKol += nKolNeto
         		nIzlNV += ( nKolNeto * field->nc )

    		  endif

		  // ako je stanje pozitivno zapamti ga
    		  if round(nKolicina, 8) > 0
        		nKol_poz := nKolicina

        		nUKol_poz := nUlKol
        		nIKol_poz := nIzlKol

        		nUVr_poz := nUlNv
        		nIVr_poz := nIzlNv
    		  endif
  		
		endif
  		
		skip
	
	enddo 
 
        // utvrdi srednju nabavnu cijenu na osnovu posljednjeg pozitivnog stanja
	if round(nKol_poz, 8) == 0
 		nSNc:=0
	else
 		// srednja nabavna cijena
 		nSNc:=(nUVr_poz - nIVr_poz) / nKol_poz
	endif

	nKolicina := round( nKolicina, 4 )
        
	if round(nKol_poz, 8) <> 0
	 
	 // upisi u cache
	 select cache
	 append blank

	 replace idkonto with cIdKonto
	 replace idroba with cIdRoba
	 replace ulaz with nUKol_poz
	 replace izlaz with nIKol_poz
	 replace stanje with nKol_poz
	 replace nvu with nUVr_poz
	 replace nvi with nIVr_poz
	 replace nv with nSnc
	 replace z_nv with nZadnjaNC
	 
	 if nSNC <> 0 .and. nZadnjaNC <> 0
	 	
		nTmp := ( ROUND(nSNC, 4) - ROUND(nZadnjaNC,4) )
		nOdst := ( nTmp / ROUND( nZadnjaNC, 4 ) ) * 100
		
		replace odst with ROUND( nOdst, 2 )
         else
	 	replace odst with 0
	 endif
	
	endif

	select kalk

  enddo

next

i := 1

// a sada prodavnice

aKto := TokToNiz( cPKtoLst, ";" )

for i := 1 to LEN( aKto )

  cIdKonto := PADR( aKto[i], 7 )

  if EMPTY(cIdKonto)
  	loop
  endif

  @ m_x + 1, m_y + 2 SAY "prod.konto: " + cIdKonto

  select kalk
  // pkonto
  set order to tag "4"
  go top

  seek cIdFirma + cIdKonto

  do while !EOF() .and. cIdFirma == field->idfirma ;
	.and. cIdKonto == field->pkonto 
	

	cIdRoba := field->idroba

 	nKolicina := 0
  	nIzlNV:=0   
  	// ukupna izlazna nabavna vrijednost
  	nUlNV:=0
  	nIzlKol:=0   
  	// ukupna izlazna kolicina
 	nUlKol:=0  
  	// ulazna kolicina

	@ m_x + 1, m_y + 20 SAY cIdRoba

	do while !EOF() .and. cIdFirma+cIdKonto+cIdRoba==idFirma+pkonto+idroba 

	  // provjeri datum
	  if field->datdok > dDatGen
		skip
		loop
	  endif

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
	
	if nKolicina <> 0
	
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
	 replace z_nv with 0
	
	endif

	select kalk

  enddo

next

BoxC()

return

// -------------------------------------------------------
// konvertuje numericko polje u karakterno za prikaz
// -------------------------------------------------------
static function s_num( nNum )
local cNum := STR( nNum, 12, 2 )
return cNum


// ----------------------------------------
// browsanje tabele cache
// ----------------------------------------
function brow_cache()
private ImeKol
private Kol

O_CACHE
set order to tag "1"

ImeKol:={{ PADR("Konto",15), {|| PADR( ALLTRIM(IdKonto) + ;
	"-" + ALLTRIM(IDROBA), 13 ) }, "IdKonto" } ,;
          { PADR("Stanje", 10 ), {|| s_num( Stanje ) }, "Stanje" } ,;
          { PADR("NC", 10 ), {|| s_num( NV ) }, "Nab.cijena" }, ;
	  { PADR("Z_NC", 10 ), {|| s_num( Z_NV ) }, "Zadnja NC" }, ;
	  { PADR("odst", 10 ), {|| s_num( ODST ) }, "Odstupanje" } }

Kol:={}

for i:=1 to LEN(ImeKol)
	AADD(Kol,i)
next

Box(,20,77)
@ m_x+17,m_y+2 SAY "<F2>  ispravka                     "
@ m_x+18,m_y+2 SAY "<F>   filter odstupanja"
@ m_x+19,m_y+2 SAY " "
@ m_x+20,m_y+2 SAY " "

ObjDbedit("CACHE",20,77,{|| key_handler()},"","pregled cache tabele", , , , ,4)

BoxC()

return


// ---------------------------------------
// handler key event
// ---------------------------------------
static function key_handler()
local nOdst := 0

do case
	case ch == K_F2
		if edit_item() == 1
			return DE_REFRESH
		else
			return DE_CONT
		endif
	case UPPER(CHR(ch)) == "F"
		
		cSign := ">="

		// filter
		Box(,1,22)
			@ m_x + 1, m_y + 2 SAY "Odstupanje" GET cSign ;
				PICT "@S2"
			@ m_x + 1, col() + 1 GET nOdst ;
				PICT "9999.99"
			read
		BoxC()

		if nOdst <> 0
			private cFilter := "odst " + ALLTRIM(cSign) ;
				+ cm2str( nOdst )
			set filter to &cFilter
			go top
			return DE_REFRESH
		endif

endcase

return DE_CONT


// -------------------------------------
// korekcija stavke
// -------------------------------------
static function edit_item()
local GetList := {}
local nTmp
local nOdst
local nL_nv
local nL_znv

Scatter()

// uzmi ovo radi daljnjeg analiziranja - postojece stanje
nL_nv := _nv
nL_znv := _z_nv

Box(,2,55)
	@ m_x + 1, m_y + 2 SAY "Srednja NC:" GET _nv
	@ m_x + 2, m_y + 2 SAY " Zadnja NC:" GET _z_nv
	read
BoxC()

if LastKey() == K_ESC
	return 0
endif

Gather()

// kalkulisi odstupanje automatski ako su cijene promjenjene

if ( nL_nv <> field->nv ) .or. ( nL_znv <> field->z_nv )

	nTmp := ROUND( field->nv, 4 ) - ROUND( field->z_nv, 4 )
	nOdst := ( nTmp / ROUND( field->z_nv, 4 )) * 100

	replace field->odst with ROUND( nOdst, 2 )

endif

return 1



