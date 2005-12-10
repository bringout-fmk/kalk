#include "\dev\fmk\kalk\kalk.ch"

*array
static aPorezi:={}
*;


function GetPreknj()
*{
local aProd // matrica sa prodavnicama
local cProdKto // prodavnicki konto
local nUvecaj // uvecaj broj kalkulacije za
local cBrKalk // broj kalkulacije
local cPKonto
local nCnt

Box(,5, 65)
	O_KONTO
	O_TARIFA
	cProdKto := SPACE(7)
	dDateOd := CToD("")
	dDateDo := DATE()
	cPTarifa := SPACE(6)
	
	@ 1+m_x, 2+m_y SAY "Preknjizenje prodavnickih konta"
	@ 3+m_x, 2+m_y SAY "Datum od" GET dDateOd 
	@ 3+m_x, col()+m_y SAY "datum do" GET dDateDo 
	@ 4+m_x, 2+m_y SAY "Prodavnicki konto (prazno-svi):" GET cProdKto VALID Empty(cProdKto) .or. P_Konto(@cProdKto)
	@ 5+m_x, 2+m_y SAY "Preknjizenje na tarifu:" GET cPTarifa VALID !Empty(cPTarifa) .or. P_Tarifa(@cPTarifa)
	read
BoxC()
// prekini operaciju
if LastKey()==K_ESC
	return
endif

aProd:={}
if Empty(ALLTRIM(cProdKto))
	// napuni matricu sa prodavnckim kontima
	GetProdKto(@aProd)
else
	AADD(aProd, { cProdKto })
endif

// provjeri velicinu matrice
if LEN(aProd) == 0
	MsgBeep("Ne postoje definisane prodavnice u KONCIJ-u!")
	return
endif

// kreiraj tabelu PRIPT
CrePripTDbf()

// pokreni preknjizenje
Box(, 2, 65)
@ 1+m_x, 2+m_y SAY "Vrsim preknjizenje " + ALLTRIM(STR(LEN(aProd)))+ " prodavnice..."

O_DOKS

altd()

nUvecaj := 1
for nCnt:=1 to LEN(aProd)
	// daj broj kalkulacije
	cBrKalk:=GetNextKalkDok(gFirma, "80", nUvecaj)
	cPKonto:=aProd[nCnt, 1]
	
	@ 2+m_x, 2+m_y SAY "Prodavnica: " + ALLTRIM(cPKonto) + "   dokument: "+ gFirma + "-80-" + ALLTRIM(cBrKalk)
	
	GenPreknj(cPKonto, cPTarifa, dDateOd, dDateDo, cBrKalk, .f., DATE())
	
	++ nUvecaj
next

BoxC()

MsgBeep("Zavrseno filovanje pomocne tabele pokrecem obradu!")
// Automatska obrada dokumenata
ObradiImport(0)


return
*}


function GetPstPDV()
*{
local aProd // matrica sa prodavnicama
local cProdKto // prodavnicki konto
local nUvecaj // uvecaj broj kalkulacije za
local cBrKalk // broj kalkulacije
local cPKonto
local nCnt

if !IsPDV()
	MsgBeep("Opcija raspoloziva samo za PDV rezim rada !!!")
	return
endif

Box(,7, 65)
	O_KONTO
	O_TARIFA
	cProdKto := SPACE(7)
	dDateOd := CToD("")
	dDateDo := DATE()
	dDatPst := DATE()
	cPTarifa := SPACE(6)
	
	@ 1+m_x, 2+m_y SAY "Generacija pocetnog stanja..."
	@ 3+m_x, 2+m_y SAY "Datum od" GET dDateOd 
	@ 3+m_x, col()+m_y SAY "datum do" GET dDateDo 
	@ 5+m_x, 2+m_y SAY "Datum pocetnog stanja" GET dDatPst 
	@ 6+m_x, 2+m_y SAY "Prodavnicki konto (prazno-svi):" GET cProdKto VALID Empty(cProdKto) .or. P_Konto(@cProdKto)
	read
BoxC()
// prekini operaciju
if LastKey()==K_ESC
	return
endif

aProd:={}
if Empty(ALLTRIM(cProdKto))
	// napuni matricu sa prodavnckim kontima
	GetProdKto(@aProd)
else
	AADD(aProd, { cProdKto })
endif

// provjeri velicinu matrice
if LEN(aProd) == 0
	MsgBeep("Ne postoje definisane prodavnice u KONCIJ-u!")
	return
endif

// kreiraj tabelu PRIPT
CrePripTDbf()

// pokreni preknjizenje
Box(, 2, 65)
@ 1+m_x, 2+m_y SAY "Generisem pocetna stanja " + ALLTRIM(STR(LEN(aProd)))+ " prodavnice..."

O_DOKS

altd()

nUvecaj := 1
for nCnt:=1 to LEN(aProd)
	// daj broj kalkulacije
	cBrKalk:=GetNextKalkDok(gFirma, "80", nUvecaj)
	cPKonto:=aProd[nCnt, 1]
	
	@ 2+m_x, 2+m_y SAY "Prodavnica: " + ALLTRIM(cPKonto) + "   dokument: "+ gFirma + "-80-" + ALLTRIM(cBrKalk)
	// gen poc.st
	GenPreknj(cPKonto, cPTarifa, dDateOd, dDateDo, cBrKalk, .t., dDatPst)
	
	++ nUvecaj
next

BoxC()

MsgBeep("Zavrseno filovanje pomocne tabele pokrecem obradu!")
// Automatska obrada dokumenata
ObradiImport(0)


return
*}




/*! \fn GetProdKto(aProd)
 *  \brief Vrati matricu sa prodavnicama
 *  \param aProd
 */
function GetProdKto(aProd)
*{
local cTip
local cKPath

// KONCIJ polja za provjeru
// ============
// ID - konto
// NAZ - tip M1, M2
// KUMTOPS - lokacija kumulativa tops

O_KONCIJ
select koncij
go top
do while !EOF()
	cTip := ALLTRIM(field->naz)
	cTip := LEFT(cTip, 1) // daj samo prvi karakter "M" ili "V"
	cKPath := ALLTRIM(field->KUMTOPS)
	
	// ako je cTip M onda dodaj tu prodavnicu
	if (cTip == "M") .and. !Empty(cKPath)
		AADD(aProd, { field->id })
	endif
	
	skip
enddo

return
*}


/*! \fn GenPreknj(cPKonto, cPrTarifa, dDatOd, dDatDo, cBrKalk, lPst)
 *  \brief Opcija generisanja dokumenta preknjizenja
 *  \param cPKonto - prodavnicki konto
 *  \param cPrTarifa - tarifa preknjizenja
 *  \param dDatOd - datum od kojeg se pravi preknjizenje
 *  \param dDatDo - datum do kojeg se pravi preknjizenje
 *  \param cBrKalk - broj kalkulacije
 *  \param lPst - pocetno stanje
 */
function GenPreknj(cPKonto, cPrTarifa, dDatOd, dDatDo, cBrKalk, lPst, dDatPs)
*{
local cIdFirma
local nRbr
local fPocStanje:=.t.

O_ROBA
if lPst
	O_KALKSEZ
else
	O_KALK
endif
O_KONTO
O_KONCIJ
O_PRIPT // pomocna tabela pript

cIdFirma:=gFirma

if lPst
	select kalksez
else
	select kalk
endif

set order to tag "4"
//"4","idFirma+Pkonto+idroba+dtos(datdok)+PU_I+IdVD","KALKS")
go top

hseek cIdfirma+cPKonto

select konto
hseek cPKonto
if lPst
	select kalksez
else
	select kalk
endif

nTUlaz:=0
nTIzlaz:=0
nTPKol:=0
nTMPVU:=0
nTMPVI:=0
nTNVU:=0
nTNVI:=0
nRbr:=0

do while !eof() .and. cIdFirma+cPKonto==idfirma+pkonto .and. IspitajPrekid()
	cIdRoba:=Idroba
	
	select roba
	hseek cIdRoba
	
	if lPst
		select kalksez
	else
		select kalk
	endif
	
	nPKol:=0
	nPNV:=0
	nPMPV:=0
	nUlaz:=0
	nIzlaz:=0
	nMPVU:=0
	nMPVI:=0
	nNVU:=0
	nNVI:=0
	nRabat:=0
	// usluge
	if roba->tip $ "TU"
		skip
		loop
	endif

	do while !eof() .and. cIdFirma+cPKonto+cIdRoba==idFirma+pkonto+idroba .and. IspitajPrekid()
  		
		// provjeri datumski
		if (field->datdok < dDatOd) .or. (field->datdok > dDatDo)
      			skip
      			loop
    		endif

  		if roba->tip $ "TU"
  			skip
			loop
  		endif
		
  		if field->datdok >= dDatOd  // nisu predhodni podaci
  			if field->pu_i=="1"
    				SumirajKolicinu(kolicina, 0, @nUlaz, 0, .t.)
    				nMPVU+=mpcsapp*kolicina
    				nNVU+=nc*(kolicina)
  			elseif field->pu_i=="5"
    				if idvd $ "12#13"
     					SumirajKolicinu(-kolicina, 0, @nUlaz, 0, .t.)
     					nMPVU-=mpcsapp*kolicina
     					nNVU-=nc*kolicina
    				else
     					SumirajKolicinu(0, kolicina, 0, @nIzlaz, .t.)
     					nMPVI+=mpcsapp*kolicina
     					nNVI+=nc*kolicina
    				endif

  			elseif field->pu_i=="3"    // nivelacija
    				nMPVU+=mpcsapp*kolicina
  			elseif field->pu_i=="I"
    				SumirajKolicinu(0, gkolicin2, 0, @nIzlaz, .t.)
    				nMPVI+=mpcsapp*gkolicin2
    				nNVI+=nc*gkolicin2
			endif
  		endif
		skip
	enddo
	
	if Round(nMPVU-nMPVI+nPMPV,4)<>0 
  		select pript
  		if round(nUlaz-nIzlaz,4)<>0
     			if !lPst
				// prva stavka stara tarifa
				append blank
				++ nRbr
     				replace idFirma with cIdfirma
     				replace brfaktp with "PPP-PDV17"
				replace idroba with cIdRoba
				replace rbr with RedniBroj(nRbr)
				replace idkonto with cPKonto
				replace datdok with dDatDo
				replace idTarifa with Tarifa(cPKonto, cIdRoba, @aPorezi)
				replace datfaktp with dDatDo
				// promjeni predznak kolicine
				replace kolicina with -(nUlaz-nIzlaz)
				replace idvd with "80"
				replace brdok with cBrKalk
				replace nc with (nNVU-nNVI+nPNV)/(nUlaz-nIzlaz+nPKol)
				replace mpcsapp with (nMPVU-nMPVI+nPMPV)/(nUlaz-nIzlaz+nPKol)
				replace TMarza2 with "A"
				if koncij->NAZ=="N1"
             				replace vpc with nc
     				endif
			endif
			
			// kontra stavka PDV tarifa
			append blank
			++nRbr
     			replace idFirma with cIdfirma
			if lPst
     				replace brfaktp with "POC.ST"
			else
     				replace brfaktp with "PPP-PDV17"
			endif
			replace idroba with cIdRoba
			replace rbr with RedniBroj(nRbr)
			replace idkonto with cPKonto
			if lPst
				replace datdok with dDatPst
			else
				replace datdok with dDatDo
			endif
			if lPst
				replace idTarifa with "PDV17 "
			else
				replace idTarifa with cPrTarifa
			endif
			if lPst
				replace datfaktp with dDatPst
			else
				replace datfaktp with dDatDo
			endif
			replace kolicina with nUlaz-nIzlaz
			replace idvd with "80"
			replace brdok with cBrKalk
			replace nc with (nNVU-nNVI+nPNV)/(nUlaz-nIzlaz+nPKol)
			replace mpcsapp with (nMPVU-nMPVI+nPMPV)/(nUlaz-nIzlaz+nPKol)
			replace TMarza2 with "A"
			if koncij->NAZ=="N1"
             			replace vpc with nc
     			endif
		endif
  		if lPst
			select kalksez
		else
			select kalk
		endif
	endif
	
	if lPst
		select kalksez
	else
		select kalk
	endif
	
enddo

return
*}

