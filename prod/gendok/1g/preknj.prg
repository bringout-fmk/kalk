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

if !SigmaSif("PREKNJ")
	MsgBeep("Opcija nedostupna!")
	return
endif

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

nUvecaj := 0
for nCnt:=1 to LEN(aProd)
	// daj broj kalkulacije
	cBrKalk:=GetNextKalkDok(gFirma, "80", nUvecaj)
	cPKonto:=aProd[nCnt, 1]
	
	@ 2+m_x, 2+m_y SAY "Prodavnica: " + ALLTRIM(cPKonto) + "   dokument: "+ gFirma + "-80-" + ALLTRIM(cBrKalk)
	
	GenPreknj(cPKonto, cPTarifa, dDateOd, dDateDo, cBrKalk)
	
	++ nUvecaj
next

BoxC()

// ovdje pozvati ... generisanje dokumenata

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


/*! \fn GenPreknj(cPKonto, cPrTarifa, dDatOd, dDatDo, cBrKalk)
 *  \brief Opcija generisanja dokumenta preknjizenja
 *  \param cPKonto - prodavnicki konto
 *  \param cPrTarifa - tarifa preknjizenja
 *  \param dDatOd - datum od kojeg se pravi preknjizenje
 *  \param dDatDo - datum do kojeg se pravi preknjizenje
 *  \param cBrKalk - broj kalkulacije
 */
function GenPreknj(cPKonto, cPrTarifa, dDatOd, dDatDo, cBrKalk)
*{
local cIdFirma

O_SIFK
O_SIFV
O_ROBA
O_KONTO
O_PARTN
O_KONCIJ
O_PRIPT // pomocna tabela pript

cIdFirma:=gFirma

private fSMark:=.f.
if right(trim(qqRoba),1)="*"
	fSMark:=.t.
endif

select KALK
set order to tag "4"
//"4","idFirma+Pkonto+idroba+dtos(datdok)+PU_I+IdVD","KALKS")
go top

hseek cIdfirma+cPKonto

select konto
hseek cPKonto
select KALK

nTUlaz:=0
nTIzlaz:=0
nTPKol:=0
nTMPVU:=0
nTMPVI:=0
nTNVU:=0
nTNVI:=0

do while !eof() .and. cIdFirma+cPKonto==idfirma+pkonto .and. IspitajPrekid()
	cIdRoba:=Idroba
	if fSMark .and. SkLoNMark("ROBA",cIdroba)
   		skip
   		loop
	endif
	
	select roba
	hseek cIdRoba
	
	select KALK
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
		if fSMark .and. SkLoNMark("ROBA",cIdroba)
     			skip
     			loop
  		endif
  		
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
    				SumirajKolicinu(kolicina, 0, @nUlaz, 0, fPocStanje)
    				nMPVU+=mpcsapp*kolicina
    				nNVU+=nc*(kolicina)
  			elseif field->pu_i=="5"
    				if idvd $ "12#13"
     					SumirajKolicinu(-kolicina, 0, @nUlaz, 0, fPocStanje)
     					nMPVU-=mpcsapp*kolicina
     					nNVU-=nc*kolicina
    				else
     					SumirajKolicinu(0, kolicina, 0, @nIzlaz, fPocStanje)
     					nMPVI+=mpcsapp*kolicina
     					nNVI+=nc*kolicina
    				endif

  			elseif field->pu_i=="3"    // nivelacija
    				nMPVU+=mpcsapp*kolicina
  			elseif field->pu_i=="I"
    				SumirajKolicinu(0, gkolicin2, 0, @nIzlaz, fPocStanje)
    				nMPVI+=mpcsapp*gkolicin2
    				nNVI+=nc*gkolicin2
			endif
  		endif
		skip
	enddo
	
	if Round(nMPVU-nMPVI+nPMPV,4)<>0 
  		select pript
  		if round(nUlaz-nIzlaz,4)<>0
     			append blank
     			replace idFirma with cIdfirma
			replace idroba with cIdRoba
			replace idkonto with cIdKonto
			replace datdok with dDatDo
			replace idTarifa with Tarifa(cIdKonto, cIdRoba, @aPorezi)
			replace datfaktp with dDatDo
			replace kolicina with nulaz-nizlaz
			replace idvd with "80"
			replace brdok with cBrKalk
			replace nc with (nNVU-nNVI+nPNV)/(nulaz-nizlaz+nPKol)
			replace mpcsapp with (nMPVU-nMPVI+nPMPV)/(nulaz-nizlaz+nPKol)
			replace TMarza2 with "A"
			if koncij->NAZ=="N1"
             			replace vpc with nc
     			endif
		endif
  		select kalk
	endif
	select kalk
	
enddo

return
*}

