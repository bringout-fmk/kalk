#include "\dev\fmk\kalk\kalk.ch"


/*
 * ----------------------------------------------------------------
 *                                     Copyright Sigma-com software 
 * ----------------------------------------------------------------
 */
 

/*! \file fmk/kalk/prod/rpt/1g/rpt_all.prg
 *  \brief Ove funkcije koristi vise izvjestaja (primjer RekTarife)
 */




// porez na promet proizvoda
function RekTarPPP()
*{
local aPKonta
local nIznPRuc
private aPorezi

IF prow()>55+gPStranica
	FF
	@ prow(),123 SAY "Str:"+str(++nStr,3)
endif
nRec:=recno()
select pripr
set order to 2
seek cIdFirma+cIdVd+cBrDok
m:="------ ---------- ---------- ---------- ---------- ---------- ---------- ---------- ----------"
? m
?  "* Tar.*  PPP%    *   PPU%   *    PP%   *    MPV   *    PPP   *   PPU    *    PP    * MPVSAPP *"
? m

aPKonta:=PKontoCnt(cIdFirma+cIdvd+cBrDok)
nCntKonto:=len(aPKonta)

aPorezi:={}

for i:=1 to nCntKonto
	seek cIdFirma+cIdVd+cBrdok

	nTot1:=nTot2:=nTot2b:=nTot3:=nTot4:=0
	nTot5:=nTot6:=nTot7:=0
	do while !eof() .and. cIdFirma+cIdVd+cBrDok==idfirma+idvd+brdok
  		if aPKonta[i]<>field->PKONTO
    			skip
    			loop
  		endif

  		cIdtarifa:=idtarifa
  		// mpv
		nU1:=0
		// ppp
		nU2:=0
		// ppu
		nU3:=0
		// pp
		nU4:=0
		// mpv sa porezom
		nU5:=0
		
	  	select tarifa
		hseek cIdtarifa
	  	select pripr
  		do while !eof() .and. cIdfirma+cIdvd+cBrDok==idfirma+idvd+brdok .and. idTarifa==cIdTarifa

	    		if aPKonta[i]<>field->PKONTO
      				skip
      				loop
	    		endif
    	
			select roba
			hseek pripr->idroba
	
			Tarifa(pripr->pkonto, pripr->idRoba, @aPorezi, cIdTarifa)
			select pripr
		
    			VtPorezi()

			nMpc:=DokMpc(field->idvd,aPorezi)
			if field->idvd=="19"
    				// nova cijena
    				nMpcSaPP1:=field->mpcSaPP+field->fcj
    				nMpc1:=MpcBezPor(nMpcSaPP1,aPorezi,,field->nc)
    				aIPor1:=RacPorezeMP(aPorezi,nMpc1,nMpcSaPP1,field->nc)
    
    				// stara cijena
    				nMpcSaPP2:=field->fcj
    				nMpc2:=MpcBezPor(nMpcSaPP2,aPorezi,,field->nc)
    				aIPor2:=RacPorezeMP(aPorezi,nMpc2,nMpcSaPP2,field->nc)
				aIPor:={0,0,0}
				aIPor[1]:=aIPor1[1]-aIPor2[1]
				aIPor[2]:=aIPor1[2]-aIPor2[2]
				aIPor[3]:=aIPor1[3]-aIPor2[3]
			else
				aIPor:=RacPorezeMP(aPorezi,nMpc,field->mpcSaPP,field->nc)
			endif
			nKolicina:=DokKolicina(field->idvd)
			nU1+=nMpc*nKolicina
			nU2+=aIPor[1]*nKolicina
			nU3+=aIPor[2]*nKolicina
			nU4+=aIPor[3]*nKolicina
    			nU5+=field->mpcSaPP*nKolicina
			// ukupna bruto marza
			nTot6+=(nMpc-pripr->nc)*nKolicina
    			skip 1
	  	enddo
		nTot1+=nU1
		nTot2+=nU2
		nTot3+=nU3
		nTot4+=nU4
		nTot5+=nU5
  
		//nTot6+=(mpc-nc)*nKolicina
		? cIdTarifa
  
		@ prow(),pcol()+1   SAY aPorezi[POR_PPP] pict picproc
		@ prow(),pcol()+1   SAY PrPPUMP() pict picproc
		@ prow(),pcol()+1   SAY aPorezi[POR_PP] pict picproc
  
		nCol1:=pcol()+1
		@ prow(),pcol()+1   SAY nU1 pict picdem
		@ prow(),pcol()+1   SAY nU2 pict picdem
		@ prow(),pcol()+1   SAY nU3 pict picdem
		@ prow(),pcol()+1   SAY nU4 pict picdem
		@ prow(),pcol()+1   SAY nU5 pict picdem
	enddo

	if prow()>56+gPStranica
		FF
		@ prow(),123 SAY "Str:"+str(++nStr,3)
	endif
	
	? m
	? "UKUPNO "+aPKonta[i]
	@ prow(),nCol1      SAY nTot1 pict picdem
	@ prow(),pcol()+1   SAY nTot2 pict picdem
	@ prow(),pcol()+1   SAY nTot3 pict picdem
	@ prow(),pcol()+1   SAY nTot4 pict picdem
	@ prow(),pcol()+1   SAY nTot5 pict picdem
	? m
next

set order to 1
go nRec
return
*}

