#include "kalk.ch"


// -----------------------------------------------------------------
// kontrola sastavnica
// 
// izvjestaj ce dati sljedece:
// 1) uzmi tekuci promet konta 1010 i ubaci u R_EXPORT
//     ulaz, izlaz, stanje, cijene...
// 2) zatim se zakaci na fakt i pos te napravi razduzenje za citavu
//    godinu po principu razduzenja sastavnica i te stavke stavi u 
//    tabelu...
// 3) kod povlacenja izvjestaja imamo znaci t.promet, novo stanje
//    napraviti cizu i usporedbu +/-
// -----------------------------------------------------------------
function r_ct_sast()
local cIdFirma
local cIdKonto
local dD_from
local dD_to
local cProdKto
local cArtfilter
local cSezona 

private nRslt := 0
private lAsistRadi := .t.

// uslovi izvjestaja
if g_vars( @dD_from, @dD_to, @cIdFirma, @cIdKonto, @cProdKto, ;
	@cArtfilter, @cSezona ) == 0
	return
endif

// kreiraj pomocnu tabelu
cre_r_tbl()

O_KALK
O_DOKS
O_ROBA
O_KONTO

// daj kalk tekuci promet
_g_kalk_tp( cIdFirma, cIdKonto, dD_from, dD_to )

// razduzi FAKT promet po sastavnicama
_g_fakt_pr( cIdKonto, dD_From, dD_to, cSezona )

// razduzi POS promet po sastavnicama
_g_pos_pr( cIdFirma, cIdKonto, dD_From, dD_to, cProdKto, cArtFilter, cSezona )

close all
O_ROBA
o_rxp()

// stampaj izvjestaj
pr_report()

return

// -----------------------------------------------------
// kreiranje tabele r_exp
// -----------------------------------------------------
static function cre_r_tbl()
local aDbf := {}

AADD(aDbf,{ "IDROBA", "C", 10, 0 })
AADD(aDbf,{ "IDKONTO", "C", 7, 0 })
AADD(aDbf,{ "TP_UL", "N", 15, 5 })
AADD(aDbf,{ "TP_IZ", "N", 15, 5 })
AADD(aDbf,{ "TP_ST", "N", 15, 5 })
AADD(aDbf,{ "TP_NVU", "N", 15, 5 })
AADD(aDbf,{ "TP_NVI", "N", 15, 5 })
AADD(aDbf,{ "TP_NVS", "N", 15, 5 })
AADD(aDbf,{ "TP_SNC", "N", 15, 5 })

// novo stanje
AADD(aDbf,{ "NP_UL", "N", 15, 5 })
AADD(aDbf,{ "NP_IZ", "N", 15, 5 })
AADD(aDbf,{ "NP_ST", "N", 15, 5 })
AADD(aDbf,{ "NP_NVU", "N", 15, 5 })
AADD(aDbf,{ "NP_NVI", "N", 15, 5 })
AADD(aDbf,{ "NP_NVS", "N", 15, 5 })


t_exp_create( aDbf )

o_rxp()

return

// ---------------------------------------
// open r_export
// ---------------------------------------
static function o_rxp()
O_R_EXP
index on idroba tag "1"
index on idkonto+idroba tag "2"
return




// --------------------------------------------------------------
// uslovi reporta
// --------------------------------------------------------------
static function g_vars( dD_from, dD_to, cIdFirma, cIdKonto, cProdKto, ;
	cArtfilter, cSezona )
local nX := 1
local nRet := 1

dD_from := CTOD( "01.01.09")
dD_to := CTOD( "31.12.09")
cIdFirma := gFirma
cIdKonto := PADR("1010;", 150)
cArtfilter := PADR("1;",100)
cProdKto := PADR( "1320", 7 )
cSezona := "RADP"

Box(,8, 65 )

	@ m_x + nX, m_y + 2 SAY "Datum od" GET dD_from
	@ m_x + nX, col()+1 SAY "do" GET dD_to

	++ nX

	@ m_x + nX, m_y + 2 SAY "Firma:" GET cIdFirma 
	@ m_x + nX, col() + 3 SAY "sast.iz sezone" GET cSezona

	++ nX

	@ m_x + nX, m_y + 2 SAY "Mag. konta:" GET cIdKonto PICT "@S40"
	
	++ nX
	++ nX

	@ m_x + nX, m_y + 2 SAY "(pos) konto prodavnice:" GET cProdKto VALID p_konto(@cProdKto)

	++ nX

	@ m_x + nX, m_y + 2 SAY "(pos) filter za artikle:" GET cArtfilter PICT "@S20"
	read
BoxC()

if LastKey() == K_ESC
	nRet := 0
endif

return nRet


// -------------------------------------------------------------------
// uzmi tekuce stanje artikala kalk-a sa lagera
// -------------------------------------------------------------------
static function _g_kalk_tp( cIdFirma, cKto_list, dD_from, dD_to )
local cIdKonto
local aKto
local i

private GetList:={}

Box(,1, 70)

aKto := TokToNiz( cKto_list, ";" )

for i := 1 to LEN( aKto )

  cIdKonto := PADR( aKto[i], 7 )

  if EMPTY( cIdKonto )
  	loop
  endif

  @ m_x + 1, m_y + 2 SAY "obradjujem mag. konto: " + cIdKonto

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

	@ m_x + 1, m_y + 20 SAY "roba ->" + cIdRoba

	do while !EOF() .and. ((cIdFirma+cIdKonto+cIdRoba) == (idFirma+mkonto+idroba)) 

		// provjeri datum
		if field->datdok > dD_to .or. field->datdok < dD_from
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
    		  
		  else
         		
			nKolicina -= nKolNeto
         		nIzlKol += nKolNeto
         		nIzlNV += ( nKolNeto * field->nc )

    		  endif

		endif
  		
		skip
	
	enddo 
 
	if round( nKolicina, 8 ) == 0
 		nSNc := 0
	else
 		// srednja nabavna cijena
 		nSNc := ( nUlNV - nIzlNV ) / nKolicina
	endif

	nKolicina := round( nKolicina, 4 )
        
	if round( nKolicina, 8 ) <> 0
	 
	 // upisi u r_exp
	 select r_export
	 append blank

	 replace idkonto with cIdkonto
	 replace idroba with cIdRoba
	 replace tp_ul with nUlKol
	 replace tp_iz with nIzlKol
	 replace tp_st with ( nUlKol - nIzlKol )
	 replace tp_nvu with nUlNV
	 replace tp_nvi with nIzlNV
	 replace tp_nvs with ( nUlNV - nIzlNv )
	 replace tp_snc with nSnc
        
	endif

	select kalk

  enddo

next

BoxC()

return


// -------------------------------------------------------------
// uzmi promet fakt-a za godinu dana... po sastavnicama
// -------------------------------------------------------------
static function _g_fakt_pr( cIdKonto, dD_From, dD_to, cSezona )
local nTArea := SELECT()
local cIdTipDok := PADR("10;11;12;", 20)
local cKto := STRTRAN( cIdKonto, ";", "" )
local cRobaUsl := ""
local cRobaIncl := "I"

cKto := PADR( ALLTRIM( cKto ), 7 )

msgo("generisem pomocnu datoteku razduzenja FAKT....")

// prenesi fakt->kalk
prenosNo( dD_from, dD_to, cKto, cIdTipDok, dD_to, cRobaUsl, ;
	cRobaIncl, cSezona )

//kunos(.t.)
//oedit()

msgc()

_pr_2_exp()

return


// ------------------------------------------------------------
// uzmi promet pos-a po sastavnicama za godinu
// ------------------------------------------------------------
static function _g_pos_pr( cIdFirma, cIdKonto, dD_From, dD_to, ;
	cProdKto, cArtFilter, cSezona )

local nTArea := SELECT()
local cIdTipDok := PADR("42;", 20)
local cKto := STRTRAN( cIdKonto, ";", "" )

cKto := PADR( ALLTRIM( cKto ), 7 )

msgo("generisem pomocnu datoteku razduzenja TOPS....")
// pokreni opciju tops po normativima
tops_nor_96( cIdFirma, "42;", "", cKto, "", ;
	dD_to, dD_from, dD_to, cArtfilter, cProdKto, cSezona )

//kunos(.t.)
//oedit()

msgc()

_pr_2_exp()

select (nTArea)
return


static function _pr_2_exp()

o_rxp()
select r_export
set order to tag "1"

msgo("filujem tabelu izvjestaja sa TOPS podacima...")
// dobit ces punu pripremu
select pripr
go top
do while !EOF()
	
	cIdRoba := field->idroba

	select r_export
	go top
	seek cIdRoba

	if !FOUND()
		append blank
	endif

	replace field->np_iz with ( field->np_iz + pripr->kolicina )
	
	replace field->np_st with ( field->tp_ul - ;
		field->np_iz )
	
	replace field->np_nvi with ( field->np_nvi + (pripr->nc * pripr->kolicina) )
	
	replace field->np_nvs with ( field->tp_nvu - ;
		field->np_nvi )

	select pripr

	skip
enddo

msgc()

// pobrisi na kraju pripremu
select pripr
zap

return



// -----------------------------------------------
// stampanje izvjestaja
// -----------------------------------------------
static function pr_report()
local nRbr := 0
local cLine
local nTp_ul := 0
local nTp_iz := 0
local nTp_st := 0
local nTp_nvu := 0
local nTp_nvi := 0
local nTp_nvs := 0
local nNp_ul := 0
local nNp_iz := 0
local nNp_st := 0
local nNp_nvu := 0
local nNp_nvi := 0
local nNp_nvs := 0
local nCol := 2

cLine := g_line()

START PRINT CRET
?

r_zagl( cLine )

select r_export
set order to tag "1"
go top

do while !EOF()
	
	? PADL( ALLTRIM( STR( ++nRbr )), 4 ) + ")"

	@ prow(), pcol() + 1 SAY PADR( "(" + ALLTRIM( field->idroba ) + ") " + ;
		r_naz( field->idroba ), 30 )
	
	// ulaz
	@ prow(), nCol := pcol()+1 SAY STR( field->tp_ul, 12, 2 )
	// tp. izlaz
	@ prow(), nCol2 := pcol()+1 SAY STR( field->tp_iz, 12, 2 )
	// tp. stanje
	@ prow(), pcol()+1 SAY STR( field->tp_st, 12, 2 )
	// +/- kolicine
	@ prow(), pcol()+1 SAY STR( field->tp_st - field->np_st, 12, 2 )
	// nv. ulaz
	@ prow(), pcol()+1 SAY STR( field->tp_nvu, 12, 2 )
	// tp. nv izlaz
	@ prow(), nCol3 := pcol()+1 SAY STR( field->tp_nvi, 12, 2 )
	// tp. nv stanje
	@ prow(), pcol()+1 SAY STR( field->tp_nvs, 12, 2 )
	// +/- stanja
	@ prow(), pcol()+1 SAY STR( field->tp_nvs - field->np_nvs, 12, 2 )

	? " "
	
	// np. izlaz
	@ prow(), nCol2 SAY STR( field->np_iz, 12, 2 )
	// np stanje
	@ prow(), pcol()+1 SAY STR( field->np_st, 12, 2 )
	// np nv izlaz
	@ prow(), nCol3 SAY STR( field->np_nvi, 12, 2 )
	// np nv stanje
	@ prow(), pcol()+1 SAY STR( field->np_nvs, 12, 2 )

	nTp_ul += field->tp_ul
	nTp_iz += field->tp_iz
	nTp_st += field->tp_st
	nTp_nvu += field->tp_nvu
	nTp_nvi += field->tp_nvi
	nTp_nvs += field->tp_nvs
	
	nNp_ul += field->np_ul
	nNp_iz += field->np_iz
	nNp_st += field->np_st
	nNp_nvu += field->np_nvu
	nNp_nvi += field->np_nvi
	nNp_nvs += field->np_nvs

	skip
enddo

? cLine

? "UKUPNO:"

@ prow(), nCol SAY STR( nTp_ul, 12, 2 )
@ prow(), nCol2 := pcol() + 1 SAY STR( nTp_iz, 12, 2 )
@ prow(), pcol() + 1 SAY STR( nTp_st, 12, 2 )
@ prow(), pcol() + 1 SAY STR( nTp_st - nNp_st , 12, 2)
@ prow(), pcol() + 1 SAY STR( nTp_nvu, 12, 2 )
@ prow(), nCol3 := pcol() + 1 SAY STR( nTp_nvi, 12, 2 )
@ prow(), pcol() + 1 SAY STR( nTp_nvs, 12, 2 )
@ prow(), pcol() + 1 SAY STR( nTp_nvs - nNp_nvs, 12, 2 )

? " "
@ prow(), nCol2 SAY STR( nNp_iz, 12, 2 )
@ prow(), pcol() + 1 SAY STR( nNp_st, 12, 2 )
@ prow(), nCol3 SAY STR( nNp_nvi, 12, 2 )
@ prow(), pcol() + 1 SAY STR( nNp_nvs, 12, 2 )

? cLine

FF
END PRINT

return

// ---------------------------------------------
// ---------------------------------------------
static function r_zagl( cLine )
local cTxt := ""

cTxt += PADR( "rbr", 5)
cTxt += SPACE(1)
cTxt += PADR("roba (id/naziv)", 30 )
cTxt += SPACE(1)
cTxt += PADR( "ulaz", 12 )
cTxt += SPACE(1)
cTxt += PADR( "tp/np izlaz", 12 )
cTxt += SPACE(1)
cTxt += PADR( "tp/np stanje", 12 )
cTxt += SPACE(1)
cTxt += PADR("+/-", 12)
cTxt += SPACE(1)
cTxt += PADR( "NV ulaza", 12 )
cTxt += SPACE(1)
cTxt += PADR( "tp/np NV iz.", 12 )
cTxt += SPACE(1)
cTxt += PADR( "tp/np NV st.", 12 )
cTxt += SPACE(1)
cTxt += PADR( "+/-", 12 )

? "Kontrola sastavnica - sta bi bilo kad bi bilo...."
? "   - tp = tekuci promet"
? "   - np = novi promet"
? "   - (+/-) pokazatelj greske"
?

P_COND

? cLine
? cTxt
? cLine

return


// ----------------------------------------
// vraca liniju
// ----------------------------------------
static function g_line()
local cTxt := ""

cTxt += REPLICATE( "-", 5)
cTxt += SPACE(1)
cTxt += REPLICATE("-", 30 )
cTxt += SPACE(1)
cTxt += REPLICATE( "-", 12 )
cTxt += SPACE(1)
cTxt += REPLICATE( "-", 12 )
cTxt += SPACE(1)
cTxt += REPLICATE( "-", 12 )
cTxt += SPACE(1)
cTxt += REPLICATE( "-", 12 )
cTxt += SPACE(1)
cTxt += REPLICATE( "-", 12 )
cTxt += SPACE(1)
cTxt += REPLICATE( "-", 12 )
cTxt += SPACE(1)
cTxt += REPLICATE( "-", 12 )
cTxt += SPACE(1)
cTxt += REPLICATE( "-", 12 )

return cTxt




// -----------------------------------------
// roba naziv - vraca
// -----------------------------------------
static function r_naz( id )
local nTArea := SELECT()
local cRet := ""
select roba
go top
seek id

cRet := ALLTRIM( field->naz )

select (nTArea)
return cRet




