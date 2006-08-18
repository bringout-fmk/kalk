#include "\dev\fmk\kalk\kalk.ch"


// meni opcije provjere integriteta
function mnu_kt_int1()
local dDatOd
local dDatDo
local cKonto
local cFirma

if get_vars(@dDatOd, @dDatDo, @cKonto, @cFirma) == 0
	return
endif

// kreiraj tabelu errors
cre_errors()
// brisi tabelu errors
BrisiError()

O_KALK
O_KONCIJ
O_KONTO
O_ROBA

// izvrsi provjeru...
k_t_integ(dDatOd, dDatDo, cKonto, cFirma)

return


// setovanje varijabli uslova testa
static function get_vars(dDatOd, dDatDo, cKonto, cFirma)

dDatOd := CToD("")
dDatDo := DATE()
cKonto := SPACE(7)
cFirma := gFirma

Box(,5,60)
	@ m_x+1, m_x+2 SAY "Firma:" GET cFirma 
	@ m_x+2, m_x+2 SAY "Datum od" GET dDatOd
	@ m_x+2, m_x+20 SAY "do" GET dDatDo 
	@ m_x+4, m_x+2 SAY "Prodavnicki konto:" GET cKonto VALID EMPTY(cKonto) .or. P_Konto(@cKonto)
	
	read
	ESC_RETURN 0
BoxC()

return 1


// kalk, tops integritet podataka
function k_t_integ(dDatOd, dDatDo, cPKonto, cFirma)
local cRoba
local nKStK
local nKStF
local nKPrK
local nKPrF
local nPStK
local nPStF
local nPPrK
local nPPrF
local cKonto
local cSeek

cSeek := cFirma
if !EMPTY(cPKonto)
	cSeek += cPKonto
endif

O_KALK
select kalk
set order to tag "4"
hseek cSeek

Box(,2,60)

@ 1+m_x, 2+m_y SAY SPACE(60)
@ 1+m_x, 2+m_y SAY "Provjera integriteta na osnovu KALK-a..."
	
do while !EOF() .and. kalk->idfirma == cFirma
	
	cKonto := kalk->pkonto
	
	O_KONCIJ
	select koncij
	set order to tag "ID"
	hseek cKonto

	cPosPm := koncij->idprodmjes
	cKPath := koncij->kumtops
	cKPath := ALLTRIM(cKPath)
	AddBS(@cKPath)

	select 0
	use (cKPath + "POS")

	select kalk
	set order to tag "4"
	
	do while !EOF() .and. kalk->(idfirma+pkonto) == cFirma+cKonto
	
		cRoba := kalk->idroba
	
		if !(field->pu_i $ "1#3#5#I") .or. Empty(ALLTRIM(cRoba))
			skip
			loop
		endif
	
		nKStK := 0
		nKStF := 0
		nKPrK := 0
 		nKPrF := 0

		nPStK := 0
		nPStF := 0
		nPPrK := 0
 		nPPrF := 0
	
		@ 2+m_x, 2+m_y SAY SPACE(60)
		@ 2+m_x, 2+m_y SAY cKonto + " - " + cRoba
	
		// prodji kroz KALK za cRoba
		scan_kalk(cFirma, cKonto, cRoba, dDatOd, dDatDo, @nKStK, @nKStF, @nKPrK, @nKPrF)	

		// prodji kroz POS za cRoba
		scan_pos(cPosPm, cRoba, dDatOd, dDatDo, @nPStK, @nPStF, @nPPrK, @nPPrF)	

		// kolicinsko stanje ne valja!
		if ROUND(nKStK, 3) <> ROUND(nPStK, 3)
			AddToErrors("C", cRoba, "","Konto: " + ALLTRIM(cKonto) + ", KALK->TOPS: kol.stanje, (KALK)=" + ALLTRIM(STR(ROUND(nKStK,3))) + " (TOPSK)=" + ALLTRIM(STR(ROUND(nPStK, 3))) )
		endif
		
		// finansijsko stanje ne valja!
		if ROUND(nKStF, 3) <> ROUND(nPStF, 3)
			AddToErrors("C", cRoba, "", "Konto: " + ALLTRIM(cKonto) + ", KALK->TOPS: fin.stanje, (KALK)=" + ALLTRIM(STR(ROUND(nKStF,3))) + " (TOPSK)=" + ALLTRIM(STR(ROUND(nPStF, 3))) )
		endif
		
		// prodaja kolicinska ne valja!
		if ROUND(nKPrK, 3) <> ROUND(nPPrK, 3)
			AddToErrors("C", cRoba, "", "Konto: " + ALLTRIM(cKonto) + ", KALK->TOPS: prodaja kol.stanje, (KALK)=" + ALLTRIM(STR(ROUND(nKPrK,3))) + " (TOPSK)=" + ALLTRIM(STR(ROUND(nPPrK, 3))) )
		endif
		
		// prodaja fin.stanje ne valja!
		if ROUND(nKPrF, 3) <> ROUND(nPPrF, 3)
			AddToErrors("C", cRoba, "", "Konto: " + ALLTRIM(cKonto) + ", KALK->TOPS: prodaja fin.stanje, (KALK)=" + ALLTRIM(STR(ROUND(nKPrF,3))) + " (TOPSK)=" + ALLTRIM(STR(ROUND(nPPrF, 3))) )
		endif
		
		select kalk
	enddo
	
	select pos
	use

	if !EMPTY(cPKonto)
		exit
	endif
	
	select kalk
enddo

BoxC()

// pokreni report
RptInteg()

return


// prodji kroz KALK za cRoba i napuni varijable...
static function scan_kalk(cFirma, cKonto, cRoba, dDatOd, dDatDo, nKStK, nKStF, nKPrK, nKPrF)	

do while !EOF() .and. kalk->(idfirma+pkonto+idroba) == cFirma+cKonto+cRoba
	
	if ( kalk->datdok > dDatDo ) .or. ( kalk->datdok < dDatOd )
		skip
		loop
	endif
		
	// ulazni dokumenti
	if kalk->pu_i == "1"
		nKStK += kalk->kolicina - kalk->gkolicina - kalk->gkolicin2
		nKStF += kalk->mpcsapp * (kalk->kolicina-kalk->gkolicina-kalk->gkolicin2)
	endif
		
	// izlazni dokumenti
	if kalk->pu_i == "5"
		// stanje
		nKStK -= kalk->kolicina
		nKStF -= kalk->kolicina * kalk->mpcsapp
		
		// prodaja
		if kalk->idvd <> "12"
			nKPrK += kalk->kolicina
			nKPrF += kalk->kolicina * kalk->mpcsapp
		endif
	endif
		
	if kalk->pu_i == "I"
		nKStK -= kalk->gkolicin2
		nKStF -= kalk->mpcsapp * kalk->gkolicin2
	endif

	// nivelacija
	if kalk->pu_i == "3"
		nKStF += kalk->mpcsapp * kalk->kolicina
	endif

	skip
enddo

return


// prodji kroz POS i napuni varijable....
static function scan_pos(cPosPm, cRoba, dDatOd,;
			dDatDo, nPStK, nPStF,;
			nPPrK, nPPrF)	

select pos
set order to tag "5"
hseek cPosPm + cRoba

do while !EOF() .and. pos->(idpos+idroba)==cPosPm+cRoba
	
	if ( pos->datum > dDatDo ) .or. ( pos->datum < dDatOd )
		skip
		loop
	endif
		
	// ulazni dokumenti
	if pos->idvd == "16"
		nPStK += pos->kolicina
		nPStF += pos->cijena * pos->kolicina
	endif
		
	// izlazni dokumenti
	if pos->idvd == "42"
		// stanje
		nPStK -= pos->kolicina
		nPStF -= pos->kolicina * pos->cijena
		// prodaja
		nPPrK += pos->kolicina
		nPPrF += pos->kolicina * pos->cijena
	endif
	
	// reklamacije
	if pos->idvd == "98"
		// stanje
		nPStK -= pos->kolicina
		nPStF -= pos->kolicina * pos->cijena
	endif

	// nivelacija
	if pos->idvd == "NI"
		nPStF += pos->kolicina * (pos->ncijena - pos->cijena)
	endif
	
	skip
enddo

return



