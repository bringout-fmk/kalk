#include "kalk.ch"



// -----------------------------------------
// kontiranje vise naloga od jednom
// -----------------------------------------
function kont_v_kalk()
local dD_f := DATE()-30
local dD_t := DATE()
local cId_td := PADR("14;", 100)

// uslovi...
Box( , 2, 65 )
	
	@ m_x + 1, m_y + 2 SAY "Datum od:" GET dD_f
	@ m_x + 1, col() + 1 SAY "do:" GET dD_t

	@ m_x + 2, m_y + 2 SAY "tipovi dok. (prazno-svi):" GET cId_td ;
		PICT "@S20"
	
	read
BoxC()

if LastKey() == K_ESC
	return
endif

_kont_doks( dD_f, dD_t, cId_td )

return

// -----------------------------------------------------
// kontiraj dokumente po uslovima
// -----------------------------------------------------
static function _kont_doks( dD_f, dD_t, cId_td )
local nCount := 0
local nTNRec

// prvo u doks-u nadji dokumente i prema njima onda idi
O_DOKS

cId_td := ALLTRIM( cId_td )

select doks
go top


altd()

do while !EOF()

	if ( field->datdok < dD_f .or. field->datdok > dD_t )
		skip
		loop
	endif

	if !EMPTY( cId_td ) 
		if field->idvd $ cId_td
			// idi dalje...
		else
			skip
			loop
		endif
	endif

	nTNRec := RECNO()
	cD_firma := field->idfirma
	cD_tipd := field->idvd
	cD_brdok := field->brdok

	// napuni FINMAT
	RekapK( .t., cD_firma, cD_tipd, cD_brdok, .t. )
	// kontiraj
	KontNal( .t., .t., .f. )
	// azuriraj nalog
	p_fin( .t. )

	++ nCount

	O_DOKS
	select doks
	go (nTNRec)
	skip
enddo

if nCount > 0
	msgbeep( "Kontirao " + ALLTRIM(STR(nCount)) + " dokumenata !" )
endif


return

