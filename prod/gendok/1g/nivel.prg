#include "\dev\fmk\kalk\kalk.ch"

*array
static aPorezi:={}
*;


function get_nivel_p()
*{
local aProd // matrica sa prodavnicama
local cProd // prodavnica
local cPKonto
local dDatDok

O_KONTO

Box(,4,70)
	cProd:=SPACE(7)
	dDatDok:=date()
	@ m_x+1,m_Y+2 SAY "Prodavnica (prazno-sve)" GET cProd VALID Empty(cProd) .or. P_Konto(@cProd)
	@ m_x+2,m_Y+2 SAY "Datum" GET dDatDok
	read
	ESC_BCR
BoxC() 

if Pitanje(,"Generisati nivelacije (D/N)?","D") == "N"
	return
endif

aProd:={}

if Empty(ALLTRIM(cProd))
	// napuni matricu sa prodavnckim kontima
	GetProdKto(@aProd)
else
	AADD(aProd, { cProd })
endif

// provjeri velicinu matrice
if LEN(aProd) == 0
	MsgBeep("Ne postoje definisane prodavnice u KONCIJ-u!")
	return
endif

// kreiraj tabelu PRIPT
CrePripTDbf()

// pokreni generisanje nivelacija
Box(, 2, 65)
@ 1+m_x, 2+m_y SAY "Vrsim generisanje nivelacije za " + ALLTRIM(STR(LEN(aProd)))+ " prodavnicu..."

O_DOKS

nUvecaj := 1
for nCnt:=1 to LEN(aProd)
	// daj broj kalkulacije
	cBrKalk:=GetNextKalkDok(gFirma, "19", nUvecaj)
	cPKonto:=aProd[nCnt, 1]
	
	@ 2+m_x, 2+m_y SAY STR(nCnt, 3) + " Prodavnica: " + ALLTRIM(cPKonto) + "   dokument: "+ gFirma + "-19-" + ALLTRIM(cBrKalk)
	
	gen_nivel_p(cPKonto, dDatDok, cBrKalk)
	
	++ nUvecaj
next

BoxC()

result_nivel_p()

return
*}


function gen_nivel_p(cPKonto, dDatDok, cBrKalk)
*{
local nRbr
local cIdFirma 
local cIdVd
local cIdRoba
local nNivCijena
local nStCijena

O_PRIPT
O_KALK
O_ROBA
O_KONTO
O_KONCIJ
O_TARIFA

nRbr:=0

cIdFirma := gFirma

select koncij
seek TRIM(cPKonto)

select roba
set order to tag "ID"
go top
altd()
do while !eof()

	// provjeri polje ROBA->ZANIVEL
	// ako je prazno preskoci
	if field->tip $ "UT"
		skip
		loop
	endif
	
	if Round(field->zanivel,4) == 0
		skip
		loop
	endif
	
	cIdRoba:=field->id
	nNivCijena:=field->zanivel
	nStCijena:=field->mpc

	nUlaz:=0
	nIzlaz:=0

	select kalk
	set order to 4
	//"KALKi4","idFirma+Pkonto+idroba+dtos(datdok)+PU_I+IdVD","KALK")
	
	seek cIdFirma + cPkonto + cIdRoba

	do while !EOF() .and. cIdFirma + cPKonto + cIdRoba == field->idFirma + field->pkonto + field->idroba
	
		if dDatDok < field->datdok  // preskoci
      			skip
			loop
  		endif

  		if pu_i=="1"
    			nUlaz+=kolicina-GKolicina-GKolicin2
		elseif pu_i=="5"  .and. !(idvd $ "12#13#22")
    			nIzlaz+=kolicina
		elseif pu_i=="5"  .and. (idvd $ "12#13#22")    // povrat
    			nUlaz-=kolicina
		elseif pu_i=="3"    // nivelacija
    			//nMPVU+=mpcsapp*kolicina
		elseif pu_i=="I"
    			nIzlaz+=gkolicin2
  		endif
		
		skip
	enddo // po orderu 4

	// ako je Stanje <> 0 preskoci
	if Round(nUlaz-nIzlaz,4) == 0
		select roba
		skip
		loop
	endif

	// upisi u pript
	select pript
 	//scatter()
 	//append ncnl
	append blank
	Scatter()
 	_idfirma := cIdFirma
	_idkonto := cPKonto
	_pkonto := cPKonto
	_pu_i := "3"
 	_idroba := cIdRoba
	_idtarifa := Tarifa(cPKonto, cIdRoba, @aPorezi, roba->idtarifa)
 	_idvd := "19"
	_brdok := cBrKalk
 	_tmarza2 := "A"
	_rbr := RedniBroj(++nRbr)
 	_kolicina := nUlaz-nIzlaz
 	_datdok := dDatDok
	_datfaktp := dDatDok
	_datkurs := dDatDok
	_MPCSaPP := nNivCijena - nStCijena
	_MPC := 0
	_fcj := nStCijena
	_mpc := MpcBezPor(nNivCijena, aPorezi, , _nc) - MpcBezPor(nStCijena, aPorezi, , _nc)
	
	_error := "0"
	
	//Gather2()
	Gather()

	select roba
	skip
enddo
 
return
*}


function result_nivel_p()
*{
local cVarijanta

if Pitanje(,"Izvrsiti uvid u rezultate nivelacija (D/N)?", "D") == "N"
	return
endif

Box(,5, 65)
	cVarijanta := "2"
	@ 1+m_x, 2+m_y SAY "Varijanta prikaza:"
	@ 2+m_x, 2+m_y SAY "  - sa detaljima (1)"
	@ 3+m_x, 2+m_y SAY "  - bez detalja  (2)" GET cVarijanta VALID !Empty(cVarijanta) .and. cVarijanta $ "12"
	read
	ESC_BCR
BoxC()

st_res_niv_p(cVarijanta)

return
*}


function obr_nivel_p()
*{
local nRecP
if Pitanje(,"Obraditi nivelaciju iz pomocne tabele (D/N)?", "N") == "N"
	return
endif

O_PRIPT
nRecP := RecCount()
if nRecP == 0
	MsgBeep("Nije generisana nivelacija, opcija 9. !")
	return
endif

// pokreni obradu pript bez asistenta
ObradiImport(0, .f.)

return
*}


function st_res_niv_p(cVar)
*{
local cIdFirma
local cIdVd
local cBrDok
local cIdRoba
local cRobaNaz
local nSMpcP // stara mpc sa por.
local nNMpcP // nova mpc sa por.
local nRMpcP // razlika mpc sa por.
local nRMpcBP // razlika mpc bez.por.
local nUSMpcP // ukupno stara mpc sa por.
local nUNMpcP // ukupno nova mpc sa por.
local nURMpcP // ukupno razlika mpc sa por.
local nURMpcBP // ukupno razlika mpc bez. por.
local cProd
local cPorez

O_PRIPT
O_ROBA
O_TARIFA

if IsPDV()
	cPorez := "PDV"	
else
	cPorez := "por"
endif

select pript
set order to tag "1"
go top

START PRINT CRET

? "Prikaz efekata nivelacije za sve prodavnice, na dan " + DToC(DATE())
?

P_COND

cLine := REPLICATE("-", 85)

? cLine

? PADR("Artikal", 10), ;
PADR("Naziv", 15), ;
PADR("S.MPC sa " + cPorez,14), ;
PADR("Razl.MPC",14), ;
PADR("Razl.MPC sa " + cPorez,14), ;
PADR("N.MPC sa " + cPorez,14) 
? cLine

do while !EOF()
	
	cIdFirma := field->idfirma
	cIdVd := field->idvd
	cBrDok := field->brdok
	nUSMpcP := 0
	nUNMpcP := 0
	nURMpcP := 0
	nURMpcBP := 0
	cProd := field->pkonto
	
	do while !EOF() .and. pript->(idfirma+idvd+brdok) == cIdFirma+cIdVd+cBrDok
		cIdRoba := field->idroba
		nSMpcP := field->fcj
		nNMpcP := field->mpc
		nRMpcP := field->mpcsapp
		nRMpcBP := field->mpcsapp + field->fcj
		
		if cVar == "1"
			select roba
			set order to tag "ID"
			hseek cIdRoba
			select pript
			
			// prikazi stavku
			? cIdRoba, PADR(roba->naz,15), ROUND(nSMpcP, 3), ROUND(nNMpcP, 3), ROUND(nRMpcP, 3), ROUND(nRMpcBP, 3)
		endif
	
		nUSMpcP += nSMpcP
		nUNMpcP += nNMpcP
		nURMpcP += nRMpcP
		nURMpcBP += nRMpcBP
	
		skip
	enddo
	
	if cVar == "1"
		? cLine
	endif 
	
	? PADR("PRODAVNICA " + ALLTRIM(cProd) + " UKUPNO:",26), ROUND(nUSMpcP, 3), ROUND(nUNMpcP, 3), ROUND(nURMpcP, 3), ROUND(nURMpcBP, 3)
	if cVar == "1"
		? cLine
	endif
enddo


FF

END PRINT

return
*}


