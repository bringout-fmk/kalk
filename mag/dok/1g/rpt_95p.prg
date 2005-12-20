#include "\dev\fmk\kalk\kalk.ch"


/*
 * ----------------------------------------------------------------
 *                                     Copyright Sigma-com software 
 * ----------------------------------------------------------------
 */
 
/*! \fn StKalk95_1()
 *  \brief Stampa kalkulacije tipa 95, varijanta samo po nabavnim cijenama
 */

function StKalk95_PDV()
*{
local nCol1:=0
local nCol2:=0
local nPom:=0

private nPrevoz,nCarDaz,nZavTr,nBankTr,nSpedTr,nMarza,nMarza2

nStr:=0
cIdPartner:=IdPartner
cBrFaktP:=BrFaktP
dDatFaktP:=DatFaktP
dDatKurs:=DatKurs
cIdKonto:=IdKonto
cIdKonto2:=IdKonto2

P_COND2

?? "KALK: KALKULACIJA BR:",  cIdFirma+"-"+cIdVD+"-"+cBrDok,SPACE(2),P_TipDok(cIdVD,-2), SPACE(2),"Datum:",DatDok

@ prow(),125 SAY "Str:"+str(++nStr,3)

if cidvd=="16"  // doprema robe
	select konto; hseek cidkonto
 	?
 	? "PRIJEM U MAGACIN (INTERNI DOKUMENT)"
 	?
elseif cidvd=="96"
 	?
 	? "OTPREMA IZ MAGACINA (INTERNI DOKUMENT):"
 	?
elseif cidvd=="97"
 	?
 	? "PREBACIVANJE IZ MAGACINA U MAGACIN (INTERNI DOKUMENT):"
 	?
elseif cidvd=="95"
 	?
 	? "OTPIS MAGACIN"
 	?
endif

select KONTO
HSEEK cIdKonto

select PRIPR

m:="--- ---------- ---------- ---------- ---------- ---------- ---------- ----------"
? m
? "*R * ROBA     * KOLICINA *   NC     *  MARZA   * PROD.CIJ.*   PDV%   * PROD.CIJ.*"
? "*BR* TARIFA   *          *          *          * BEZ.PDV  *   PDV    * SA PDV   *"
? "*  * KONTO    *    �     *    �     *    �     *    �     *    �     *     �    *"
? m

nTot:=nTot1:=nTot2:=nTot3:=nTot4:=nTot5:=nTot6:=nTot7:=nTot8:=nTot9:=nTotA:=0
nTotB:=nTotP:=nTotM:=0

select pripr

private cIdd:=idpartner+brfaktp+idkonto+idkonto2

do while !eof() .and. cIdFirma==IdFirma .and.  cBrDok==BrDok .and. cIdVD==IdVD
	ViseDokUPripremi(cIdd)
    	RptSeekRT()
    	KTroskovi()
	DokNovaStrana(125, @nStr, 2)
	if gKalo=="1"
        	SKol:=Kolicina-GKolicina-GKolicin2
    	else
        	SKol:=Kolicina
    	endif

        nPDVStopa := tarifa->opp
	nPDV := MPCsaPP * (tarifa->opp/100)

       	nTot1+= (nU1:=round(NC*(GKolicina+GKolicin2),gZaokr))
	nTot8+= (nU8:=round(NC *    (Kolicina-Gkolicina-GKolicin2),gZaokr) )
    	nTot9+= (nU9:=round(nMarza* (Kolicina-Gkolicina-GKolicin2),gZaokr) )
    	nTotA+= (nUA:=round(VPC   * (Kolicina-Gkolicina-GKolicin2),gZaokr) )

    	if gVarVP=="1"
      		nTotB+= round(nU9*tarifa->vpp/100 ,gZaokr) // porez na razliku u cijeni
    	else
      		private cistaMar:=round(nU9/(1+tarifa->vpp/100) ,gZaokr)
      		nTotB+=round( cistaMar*tarifa->vpp/100,gZaokr)  // porez na razliku u cijeni
    	endif
    	// total porez
	nTotP+=(nUP:=nPDV * kolicina)
    	// total mpcsapp
	nTotM+=(nUM:=MPCsaPP * kolicina)
   
    	// 1. PRVI RED
	@ prow()+1,0 SAY  Rbr PICTURE "999"
    	@ prow(),4 SAY  ""
	?? trim(ROBA->naz),"(",ROBA->jmj,")"
    	@ prow()+1,4 SAY IdRoba
    	nCol1:=pcol()+1
    	@ prow(),pcol()+1 SAY Kolicina             PICTURE PicKol
    	@ prow(),pcol()+1 SAY NC                    PICTURE PicCDEM
    	@ prow(),pcol()+1 SAY nMarza/NC*100         PICTURE PicProc
    	@ prow(),pcol()+1 SAY VPC                   PICTURE PicCDEM
    	@ prow(),pcol()+1 SAY nPDVStopa         PICTURE PicProc
    	@ prow(),pcol()+1 SAY MPCsaPP           PICTURE PicCDEM

	// 2. DRUGI RED
    	@ prow()+1,4 SAY IdTarifa
    	@ prow(),pcol()+27 SAY nMarza               PICTURE PicCDEM
    	@ prow(),pcol()+1 SAY 0  		   PICTURE PicCDEM
    	@ prow(),pcol()+1 SAY nPDV  		   PICTURE PicCDEM

	// 3. TRECI RED
    	@ prow()+1,4 SAY idkonto
	@ prow()+1,nCol1   SAY nU1         picture         PICDEM
    	@ prow(),pcol()+1  SAY nU8         picture         PICDEM
    	@ prow(),pcol()+1  SAY nU9         picture         PICDEM
    	@ prow(),pcol()+1  SAY nUA         picture         PICDEM
    	@ prow(),pcol()+1  SAY nUP         picture         PICDEM
    	@ prow(),pcol()+1  SAY nUM         picture         PICDEM

  	skip
enddo

DokNovaStrana(125, @nStr, 5)
? m

@ prow() + 1,0 SAY "Ukupno:"
@ prow(),nCol1     SAY nTot1         picture         PICDEM
@ prow(),pcol()+1  SAY nTot8         picture         PICDEM
@ prow(),pcol()+1  SAY nTot9         picture         PICDEM
@ prow(),pcol()+1  SAY nTotA         picture         PICDEM
@ prow(),pcol()+1  SAY nTotP         picture         PICDEM
@ prow(),pcol()+1  SAY nTotM         picture         PICDEM

? m
if cIdVD == "16"
	? "Magacin se zaduzuje po nabavnoj vrijednosti " + ALLTRIM(TRANSFORM(nTot8,picdem))
else
	? "Magacin se razduzuje po nabavnoj vrijednosti " + ALLTRIM(TRANSFORM(nTot8,picdem))
endif
? m

return
*}

