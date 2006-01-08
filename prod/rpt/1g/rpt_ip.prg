#include "\dev\fmk\kalk\kalk.ch"


/*
 * ----------------------------------------------------------------
 *                                     Copyright Sigma-com software 
 * ----------------------------------------------------------------
 */
 

/*! \file fmk/kalk/prod/rpt/1g/rpt_ip.prg
 *  \brief Stampa dokumenta tipa IP
 */


/*! \fn StKalkIP(fZaTops)
 *  \brief Stampa dokumenta tipa IP
 *  \param fZaTops -
 */

function StKalkIP(fZaTops)
*{
local nCol1:=nCol2:=0,npom:=0

Private nPrevoz,nCarDaz,nZavTr,nBankTr,nSpedTr,nMarza,nMarza2,aPorezi
// iznosi troskova i marzi koji se izracunavaju u KTroskovi()
aPorezi:={}
nStr:=0
cIdPartner:=IdPartner
cBrFaktP:=BrFaktP
dDatFaktP:=DatFaktP
dDatKurs:=DatKurs
cIdKonto:=IdKonto
cIdKonto2:=IdKonto2

if fzatops==NIL
	fZaTops:=.f.
endif

if !fZaTops
	cSamoObraz:=Pitanje(,"Prikaz samo obrasca inventure (D-da,N-ne,S-sank lista) ?",,"DNS")
	if cSamoObraz=="S"
		StObrazSL()
		return
	endif
else
	cSamoObraz:="N"
endif

P_10CPI
select konto
hseek cidkonto
select pripr

?? "INVENTURA PRODAVNICA ",cidkonto,"-",konto->naz
IspisNaDan(10)
P_COND
?
? "DOKUMENT BR. :",cIdFirma+"-"+cIdVD+"-"+cBrDok, SPACE(2),"Datum:",DatDok
?
@ prow(),125 SAY "Str:"+str(++nStr,3)

select PRIPR

if (IsJerry())
	m:="--- -------------------------------------------- ------ ---------- ---------- ---------- --------- ----------- ----------- -----------"
	? m
	? "*R *                                            *      *  Popisana*  Knjizna *  Knjizna * Popisana *  Razlika * Cijena  *  +VISAK  *"
	? "*BR*               R O B A                      *Tarifa*  Kolicina*  Kolicina*vrijednost*vrijednost*  (kol)   *         *  -MANJAK *"
else
	m:="--- --------------------------------------- ---------- ---------- ---------- --------- ----------- ----------- -----------"
	? m
	? "*R * ROBA                                  *  Popisana*  Knjizna *  Knjizna * Popisana *  Razlika * Cijena  *  +VISAK  *"
	? "*BR* TARIFA                                *  Kolicina*  Kolicina*vrijednost*vrijednost*  (kol)   *         *  -MANJAK *"
endif

? m
nTot4:=0
nTot5:=0
nTot6:=0
nTot7:=0
nTot8:=0
nTot9:=0
nTota:=0
nTotb:=0
nTotc:=0
nTotd:=0
nTotKol:=0
nTotGKol:=0


private cIdd:=idpartner+brfaktp+idkonto+idkonto2

do while !eof() .and. cIdFirma==IdFirma .and.  cBrDok==BrDok .and. cIdVD==IdVD

	// !!!!!!!!!!!!!!!
	if idpartner+brfaktp+idkonto+idkonto2<>cidd
		Beep(2)
		Msg("Unutar kalkulacije se pojavilo vise dokumenata !",6)
	endif

	KTroskovi()

	select ROBA
	HSEEK PRIPR->IdRoba
	select TARIFA
	HSEEK PRIPR->IdTarifa
	select PRIPR

	if prow()-gPStranica>59
		FF
		@ prow(),125 SAY "Str:"+str(++nStr,3)
	endif

	SKol:=Kolicina

	@ prow()+1,0 SAY  Rbr PICTURE "XXX"
	@ prow(),4 SAY  ""

	if (IsJerry())
		?? idroba, LEFT(ROBA->naz,LEN(ROBA->naz)-13),"("+ROBA->jmj+")"
	else
		?? idroba, trim(ROBA->naz),"(",ROBA->jmj,")"
	endif

	if gRokTr=="D"
		?? space(4),"Rok Tr.:",RokTr
	endif

	if (IsJerry())
		nPosKol:=1
		@ prow(),pcol()+1 SAY IdTarifa
	else
		nPosKol:=30
		@ prow()+1,4 SAY IdTarifa+space(4)
	endif



	if cSamoObraz=="D"
		@ prow(),pcol()+nPosKol SAY Kolicina  PICTURE replicate("_",len(PicKol))
		@ prow(),pcol()+1 SAY GKolicina  PICTURE replicate(" ",len(PicKol))

	else
		@ prow(),pcol()+nPosKol SAY Kolicina  PICTURE PicKol
		@ prow(),pcol()+1 SAY GKolicina  PICTURE PicKol
	endif

	nC1:=pcol()

	if cSamoObraz=="D"
		@ prow(),pcol()+1 SAY fcj           PICTURE replicate(" ",len(PicDEM))
		@ prow(),pcol()+1 SAY kolicina*mpcsapp    PICTURE replicate("_",len(PicDEM))
		@ prow(),pcol()+1 SAY Kolicina-GKolicina  PICTURE replicate(" ",len(PicKol))
	else
		@ prow(),pcol()+1 SAY fcj           PICTURE Picdem // knjizna vrijednost
		@ prow(),pcol()+1 SAY kolicina*mpcsapp    PICTURE Picdem
		@ prow(),pcol()+1 SAY Kolicina-GKolicina  PICTURE PicKol
	endif

	@ prow(),pcol()+1 SAY MPCSAPP             PICTURE PicCDEM

	nTotb+=fcj
	nTotc+=kolicina*mpcsapp
	nTot4+= (nU4:= MPCSAPP*Kolicina-fcj)
	nTotKol+=kolicina
	nTotGKol+=gkolicina
	
	if cSamoObraz=="D"
		@ prow(),pcol()+1 SAY nU4  pict replicate(" ",len(PicDEM))
	else
		@ prow(),pcol()+1 SAY nU4  pict picdem
	endif

	skip 1

enddo


if prow()-gPStranica>58
	FF
	@ prow(),125 SAY "Str:"+str(++nStr,3)
endif

if cSamoObraz=="D"
	? m
	?
	?
	? space(80),"Clanovi komisije: 1. ___________________"
	? space(80),"                  2. ___________________"
	? space(80),"                  3. ___________________"
	return
endif

? m
@ prow()+1, 0 SAY "Ukupno:"
@ prow(),(pcol()*6)+2 SAY nTotKol pict pickol
@ prow(),pcol()+1 SAY nTotGKol pict pickol
@ prow(),pcol()+1 SAY nTotb pict picdem
@ prow(),pcol()+1 SAY nTotc pict picdem
@ prow(),pcol()+1 SAY 0 pict picdem
@ prow(),pcol()+1 SAY 0 pict picdem
@ prow(),pcol()+1 SAY nTot4  pict picdem
? m

// Visak
RekTarife(.t.)

// Manjak
RekTarife(.f.)

if !fZaTops
	?
	?
	? "Napomena: Ovaj dokument ima sljedeci efekat na karticama:"
	? "     1 - izlaz za kolicinu manjka"
	? "     2 - storno izlaza za kolicinu viska"
	?
endif
return
*}




/*! \fn StObrazSL()
 *  \brief Stampa forme obrasca sank liste
 */

function StObrazSL()
*{
local nCol1:=nCol2:=0,npom:=0

Private nPrevoz,nCarDaz,nZavTr,nBankTr,nSpedTr,nMarza,nMarza2
// iznosi troskova i marzi koji se izracunavaju u KTroskovi()

nStr:=0
cIdPartner:=IdPartner
cBrFaktP:=BrFaktP
dDatFaktP:=DatFaktP
dDatKurs:=DatKurs
cIdKonto:=IdKonto
cIdKonto2:=IdKonto2


P_10CPI
select konto; hseek cidkonto; select pripr
?? "INVENTURA PRODAVNICA ",cidkonto,"-",konto->naz
P_COND
?
? "DOKUMENT BR. :",cIdFirma+"-"+cIdVD+"-"+cBrDok, SPACE(2),"Datum:",DatDok
?
@ prow(),125 SAY "Str:"+str(++nStr,3)

select PRIPR

m:="--- -------------------------------------------- ------ ---------- ---------- ---------- --------- ----------- -----------"
? m
? "*R *                                            *      *  Pocetne * Primljena*  Zavrsna * Prodajna * Cijena  *   Iznos  *"
? "*BR*               R O B A                      *Tarifa*  zalihe  *  kolicina*  zaliha  * kolicina *         */realizac.*"
? m
nTot4:=nTot5:=nTot6:=nTot7:=nTot8:=nTot9:=nTota:=ntotb:=ntotc:=nTotd:=0

private cIdd:=idpartner+brfaktp+idkonto+idkonto2
do while !eof() .and. cIdFirma==IdFirma .and.  cBrDok==BrDok .and. cIdVD==IdVD

    // !!!!!!!!!!!!!!!
    if idpartner+brfaktp+idkonto+idkonto2<>cidd
    	Beep(2)
    	Msg("Unutar kalkulacije se pojavilo vise dokumenata !",6)
    endif

    KTroskovi()

    select ROBA; HSEEK PRIPR->IdRoba
    select TARIFA; HSEEK PRIPR->IdTarifa
    select PRIPR

    if prow()-gPStranica>59
    	FF
    	@ prow(),125 SAY "Str:"+str(++nStr,3)
    endif

    SKol:=Kolicina

    @ prow()+1,0 SAY  Rbr PICTURE "XXX"
    @ prow(),4 SAY  ""
    ?? idroba, LEFT(ROBA->naz,LEN(ROBA->naz)-13),"("+ROBA->jmj+")"
    nPosKol:=1
    @ prow(),pcol()+1 SAY IdTarifa
    if gcSLObrazac=="2"
	   @ prow(),pcol()+nPosKol SAY Kolicina  PICTURE PicKol
    else
	   @ prow(),pcol()+nPosKol SAY GKolicina  PICTURE PicKol
    endif
    @ prow(),pcol()+1 SAY 0  PICTURE replicate("_",len(PicKol))
    @ prow(),pcol()+1 SAY 0  PICTURE replicate("_",len(PicKol))
    @ prow(),pcol()+1 SAY 0  PICTURE replicate("_",len(PicKol))
    @ prow(),pcol()+1 SAY MPCSAPP             PICTURE PicCDEM
    nTotb+=fcj
    ntotc+=kolicina*mpcsapp
    nTot4+=  (nU4:= MPCSAPP*Kolicina-fcj)

    @ prow(),pcol()+1 SAY nU4  pict replicate("_",len(PicDEM))
    skip

enddo


if prow()-gPStranica>58
	FF
	@ prow(),125 SAY "Str:"+str(++nStr,3)
endif

? m
return
*}




