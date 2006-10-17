#include "\dev\fmk\kalk\kalk.ch"

static cTblKontrola:=""
static aPorezi:={}

// lager lista prodavnice
function LLP()
parameters lPocStanje
// indikator gresaka
local lImaGresaka:=.f.  
local cKontrolnaTabela

cIdFirma:=gFirma
cIdKonto:=PadR("1320",gDuzKonto)
O_SIFK
O_SIFV
O_ROBA
O_KONTO
O_PARTN

cKontrolnaTabela:="N"

if (lPocStanje==nil)
	lPocStanje:=.f.
else
   	lPocStanje:=.t.
   	O_PRIPR
   	cBrPSt:="00001   "
   	Box(,2,60)
     		@ m_x+1,m_y+2 SAY "Generacija poc. stanja  - broj dokumenta 80 -" GET cBrPSt
     		read
   	BoxC()
endif

cNula:="D"
cK9:=SPACE(3)
dDatOd:=CToD("")
dDatDo:=Date()
qqRoba:=SPACE(60)
qqTarifa:=SPACE(60)
qqidvd:=SPACE(60)
qqIdPartn:=SPACE(60)
private cPNab:="N"
private cNula:="D"
private cTU:="N"
private cSredCij:="N"
private cPrikazDob:="N"
private cPlVrsta:=SPACE(1)
private cPrikK2:="N"

if IsDomZdr()
	private cKalkTip:=SPACE(1)
endif

Box(,18+IF(IsTvin(),1,0),68)

cGrupacija:=space(4)
cPredhStanje:="N"

do while .t.
	if gNW $ "DX"
   		@ m_x+1,m_y+2 SAY "Firma "
		?? gFirma,"-",gNFirma
 	else
  		@ m_x+1,m_y+2 SAY "Firma  " GET cIdFirma valid {|| P_Firma(@cIdFirma),cidfirma:=left(cidfirma,2),.t.}
 	endif
 	@ m_x+2,m_y+2 SAY "Konto   " GET cIdKonto valid P_Konto(@cIdKonto)
 	@ m_x+3,m_y+2 SAY "Artikli " GET qqRoba pict "@!S50"
 	@ m_x+4,m_y+2 SAY "Tarife  " GET qqTarifa pict "@!S50"
 	@ m_x+5,m_y+2 SAY "Partneri" GET qqIdPartn pict "@!S50"
 	@ m_x+6,m_y+2 SAY "Vrste dokumenata  " GET qqIDVD pict "@!S30"
 	@ m_x+7,m_y+2 SAY "Prikaz Nab.vrijednosti D/N" GET cPNab  valid cpnab $ "DN" pict "@!"
 	@ m_x+8,m_y+2 SAY "Prikaz stavki kojima je MPV 0 D/N" GET cNula  valid cNula $ "DN" pict "@!"
 	@ m_x+9,m_y+2 SAY "Datum od " GET dDatOd
 	@ m_x+9,col()+2 SAY "do" GET dDatDo
 	@ m_x+12,m_y+2 SAY "Prikaz robe tipa T/U  (D/N)" GET cTU valid cTU $ "DN" pict "@!"
 	@ m_x+12, COL()+2 SAY " generisati kontrolnu tabelu ? " GET cKontrolnaTabela VALID cKontrolnaTabela $ "DN" PICT "@!"
 	@ m_x+13,m_y+2 SAY "Odabir grupacije (prazno-svi) GET" GET cGrupacija pict "@!"
 	@ m_x+14,m_y+2 SAY "Prikaz prethodnog stanja" GET cPredhStanje pict "@!" valid cPredhStanje $ "DN"
 	if lPoNarudzbi
   		qqIdNar := SPACE(60)
   		cPKN    := "N"
   		@ row()+1,m_y+2 SAY "Uslov po sifri narucioca:" GET qqIdNar pict "@!S30"
   		@ row()+1,m_y+2 SAY "Prikazati kolonu 'narucilac' ? (D/N)" GET cPKN VALID cPKN$"DN" pict "@!"
 	endif
 	if IsTvin()
 		@ row()+1, m_y+2 SAY "Prikazati srednju cijenu (D/N) ?" GET cSredCij VALID cSredCij$"DN" PICT "@!"
 	endif
 
	if IsPlanika()
 		@ m_x+15,m_y+2 SAY "Prikaz dobavljaca (D/N) ?" GET cPrikazDob pict "@!" valid cPrikazDob $ "DN"
		@ m_x+16,m_y+2 SAY "Prikaz po K9 (uslov)" GET cK9 pict "@!"
		@ m_x+17,m_y+2 SAY "Prikaz po pl.vrsta (uslov)" GET cPlVrsta pict "@!"
		@ m_x+18,m_y+2 SAY "Prikazati K2 = 'X' (D/N)" GET cPrikK2 pict "@!" valid cPrikK2$"DN"
 	endif
	
	if IsDomZdr()	
 		@ m_x+15,m_y+2 SAY "Prikaz po tipu sredstva " GET cKalkTip PICT "@!"
	endif
  	
	if IsVindija()	
		cGr := SPACE(10)
		cPSPDN := "N"
 		@ m_x+16,m_y+2 SAY "Grupa " GET cGr
 		@ m_x+17,m_y+2 SAY "Pregled samo prodaje (D/N) " GET cPSPDN VALID !Empty(cPSPDN) .and. cPSPDN$"DN"  pict "@!"
	endif
  
	read
 	ESC_BCR
 	private aUsl1:=Parsiraj(qqRoba,"IdRoba")
 	private aUsl2:=Parsiraj(qqTarifa,"IdTarifa")
 	private aUsl3:=Parsiraj(qqIDVD,"idvd")
	private aUsl4:=Parsiraj(qqIdPartn, "IdPartner")
 	if aUsl1<>NIL .and. aUsl2<>NIL .and. aUsl3<>NIL 
   		exit
 	endif
	if aUsl4<>NIL
		exit
	endif
enddo
BoxC()

// skeniraj dokumente u procesu za konto
pl_scan_dok_u_procesu(cIdKonto)

CLOSE ALL

if (cKontrolnaTabela=="D")
	CreTblKontrola()
endif

if lPocStanje
	O_PRIPR
endif
lPrikK2 := .f.
if cPrikK2 == "D"
	lPrikK2 := .t.
endif

O_SIFK
O_SIFV
O_ROBA
O_KONTO
O_PARTN
O_KONCIJ
O_KALKREP

private lSMark:=.f.
if right(trim(qqRoba),1)="*"
	lSMark:=.t.
endif

private cFilter:=".t."

if aUsl1<>".t."
  	cFilter+=".and."+aUsl1   // roba
endif
if aUsl2<>".t."
  	cFilter+=".and."+aUsl2   // tarifa
endif
if aUsl3<>".t."
  	cFilter+=".and."+aUsl3   // idvd
endif
if aUsl4<>".t."
	cFilter+=".and."+aUsl4   // partner
endif
// po tipu sredstva
if IsDomZdr() .and. !Empty(cKalkTip)
	cFilter+=".and. tip="+Cm2Str(cKalkTip)
endif

select KALK

set order to 4

set filter to &cFilter
//"4","idFirma+Pkonto+idroba+dtos(datdok)+PU_I+IdVD","KALKS")

hseek cIdfirma+cIdkonto
EOF CRET

nLen:=1
m:="----- ---------- -------------------- ---"+" ---------- ---------- ---------- ---------- ---------- ---------- ----------"
if cPredhstanje=="D"
  	m+=" ----------"
endif
if cSredCij=="D"
	m+=" ----------"
endif

start print cret
?
select konto
hseek cIdKonto
select KALK

private nTStrana:=0

private bZagl:={|| ZaglLLP()}

nTUlaz:=0
nTIzlaz:=0
nTPKol:=0
nTMPVU:=0
nTMPVI:=0
nTNVU:=0
nTNVI:=0
// predhodna vrijednost
nTPMPV:=0
nTPNV:=0  
nTRabat:=0
nCol1:=50
nCol0:=50
nRbr:=0

Eval(bZagl)
do while !eof() .and. cIdFirma+cIdKonto==idfirma+pkonto .and. IspitajPrekid()
	cIdRoba:=Idroba
	if lSMark .and. SkLoNMark("ROBA",cIdroba)
   		skip
   		loop
	endif
	select roba
	hseek cIdRoba
	
	if IsVindija()
		if !EMPTY(cGr)
			if ALLTRIM(cGr) <> ALLTRIM(IzSifK("ROBA", "GR1", cIdRoba, .f.))
				select kalk
				skip
				loop
			endif
		endif
		
		if (cPSPDN == "D")
			select kalk
			if !(kalk->idvd $ "41#42#43") .and. !(kalk->pu_i == "5")
				skip
				loop
			endif
			select roba
		endif
	endif
	
	// uslov po K9
	if (IsPlanika() .and. !EMPTY(cK9) .and. roba->k9 <> cK9)
		select kalk
		skip
		loop
	endif

	// uslov po PL.VRSTA
	if (IsPlanika() .and. !EMPTY(cPlVrsta) .and. roba->vrsta <> cPlVrsta) 
		select kalk
		skip
		loop
	endif

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
	if cTU=="N" .and. roba->tip $ "TU"
		skip
		loop
	endif

	do while !eof() .and. cidfirma+cidkonto+cidroba==idFirma+pkonto+idroba .and. IspitajPrekid()
		if lSMark .and. SkLoNMark("ROBA",cIdroba)
     			skip
     			loop
  		endif
  		if cPredhStanje=="D"
    			if datdok<dDatOd
     				if pu_i=="1"
       					SumirajKolicinu(kolicina, 0, @nPKol, 0, lPocStanje, lPrikK2)
       					nPMPV+=mpcsapp*kolicina
       					nPNV+=nc*(kolicina)
     				elseif pu_i=="5"
       					SumirajKolicinu(-kolicina, 0, @nPKol, 0, lPocStanje, lPrikK2)
       					nPMPV-=mpcsapp*kolicina
       					nPNV-=nc*kolicina
     				elseif pu_i=="3"    
       					// nivelacija
       					nPMPV+=field->mpcsapp*field->kolicina
     				elseif pu_i=="I"
       					SumirajKolicinu(-gKolicin2, 0, @nPKol, 0, lPocStanje, lPrikK2)
       					nPMPV-=mpcsapp*gkolicin2
       					nPNV-=nc*gkolicin2
     				endif
    			endif
  		else
    			if field->datdok<ddatod .or. field->datdok>ddatdo
      				skip
      				loop
    			endif
  		endif 

  		if cTU=="N" .and. roba->tip $ "TU"
  			skip
			loop
  		endif
  		if !empty(cGrupacija)
    			if cGrupacija<>roba->k1
      				skip
      				loop
    			endif
  		endif
  		if DatDok>=dDatOd  // nisu predhodni podaci
  			if pu_i=="1"
    				SumirajKolicinu(kolicina, 0, @nUlaz, 0, lPocStanje, lPrikK2)
    				nCol1:=pcol()+1
    				nMPVU+=mpcsapp*kolicina
    				nNVU+=nc*(kolicina)
  			elseif pu_i=="5"
    				if idvd $ "12#13"
     					SumirajKolicinu(-kolicina, 0, @nUlaz, 0, lPocStanje, lPrikK2)
     					nMPVU-=mpcsapp*kolicina
     					nNVU-=nc*kolicina
    				else
     					SumirajKolicinu(0, kolicina, 0, @nIzlaz, lPocStanje, lPrikK2)
     					nMPVI+=mpcsapp*kolicina
     					nNVI+=nc*kolicina
    				endif

  			elseif pu_i=="3"    
			        // nivelacija
    				nMPVU+=mpcsapp*kolicina
  			elseif pu_i=="I"
    				SumirajKolicinu(0, gkolicin2, 0, @nIzlaz, lPocStanje, lPrikK2)
    				nMPVI+=mpcsapp*gkolicin2
    				nNVI+=nc*gkolicin2
			endif
  		endif
		skip
	enddo
	
	//ne prikazuj stavke 0
	if cNula=="D" .or. round(nMPVU-nMPVI+nPMPV,4)<>0 
		if PROW()>61+gPStranica
			FF
			eval(bZagl)
		endif
		select roba
		hseek cidroba
		select KALK
		aNaz:=Sjecistr(roba->naz,20)
		? str(++nRbr,4)+".",cIdRoba
		nCr:=pcol()+1
		@ prow(),pcol()+1 SAY aNaz[1]
		@ prow(),pcol()+1 SAY roba->jmj
		if lPoNarudzbi .and. cPKN=="D"
  			@ prow(),pcol()+1 SAY cIdNar
		endif
		nCol0:=pCol()+1
		if cPredhStanje=="D"
 			@ prow(),pcol()+1 SAY nPKol pict gpickol
		endif
		@ prow(),pcol()+1 SAY nUlaz pict gpickol
		@ prow(),pcol()+1 SAY nIzlaz pict gpickol
		@ prow(),pcol()+1 SAY nUlaz-nIzlaz+nPkol pict gpickol
		if lPocStanje
  			select pripr
  			if round(nUlaz-nIzlaz,4)<>0
     				append blank
     				replace idFirma with cIdfirma, idroba with cIdRoba, idkonto with cIdKonto, datdok with dDatDo+1, idTarifa with Tarifa(cIdKonto, cIdRoba, @aPorezi), datfaktp with dDatDo+1, kolicina with nulaz-nizlaz, idvd with "80", brdok with cBRPST, nc with (nNVU-nNVI+nPNV)/(nulaz-nizlaz+nPKol), mpcsapp with (nMPVU-nMPVI+nPMPV)/(nulaz-nizlaz+nPKol), TMarza2 with "A"
				if koncij->NAZ=="N1"
             				replace vpc with nc
     				endif
			endif
  			select KALK
		endif

		nCol1:=pcol()+1
		@ prow(),pcol()+1 SAY nMPVU pict gPicDem
		@ prow(),pcol()+1 SAY nMPVI pict gPicDem
		@ prow(),pcol()+1 SAY nMPVU-NMPVI+nPMPV pict gPicDem
		select koncij
		seek trim(cIdKonto)
		select roba
		hseek cidroba
		_mpc:=UzmiMPCSif()
		select KALK
		if round(nUlaz-nIzlaz+nPKOL,4)<>0
 			@ prow(),pcol()+1 SAY (nMPVU-nMPVI+nPMPV)/(nUlaz-nIzlaz+nPKol) pict gpiccdem
 			if round((nMPVU-nMPVI+nPMPV)/(nUlaz-nIzlaz+nPKol),4) <> round(_mpc,4)
   				?? " ERR"
 			endif
		else
 			@ prow(),pcol()+1 SAY 0 pict gpicdem
 			if round((nMPVU-nMPVI+nPMPV),4)<>0
   				?? " ERR"
   				lImaGresaka:=.t.
 			endif
		endif

		if cSredCij=="D"
			@ prow(), pcol()+1 SAY (nNVU-nNVI+nPNV+nMPVU-nMPVI+nPMPV)/(nUlaz-nIzlaz+nPKol)/2 PICT "9999999.99"
		endif

		if LEN(aNaz)>1 .or. cPredhStanje=="D" .or. cPNab=="D"
  			@ prow()+1,0 SAY ""
  			if len(aNaz)>1
    				@ prow(),nCR  SAY aNaz[2]
  			endif
  			@ prow(),nCol0-1 SAY ""
		endif
		if (cKontrolnaTabela=="D")
			AzurKontrolnaTabela(cIdRoba, nUlaz-nIzlaz+nPkol, nMpvU-nMpvI+nPMpv)
		endif

		if cPredhStanje=="D"
 			@ prow(),pcol()+1 SAY nPMPV pict gpicdem
		endif
		if cPNab=="D"
 			@ prow(),pcol()+1 SAY space(len(gpickol))
 			@ prow(),pcol()+1 SAY space(len(gpickol))
 			if round(nulaz-nizlaz+nPKol,4)<>0
  				@ prow(),pcol()+1 SAY (nNVU-nNVI+nPNV)/(nUlaz-nIzlaz+nPKol) pict gpicdem
 			else
  				@ prow(),pcol()+1 SAY space(len(gpicdem))
 			endif
 			@ prow(),nCol1 SAY nNVU pict gpicdem
 			//@ prow(),pcol()+1 SAY space(len(gpicdem))
 			@ prow(),pcol()+1 SAY nNVI pict gpicdem
 			@ prow(),pcol()+1 SAY nNVU-nNVI+nPNV pict gpicdem
 			@ prow(),pcol()+1 SAY _MPC pict gpiccdem
		endif
		nTULaz+=nUlaz
		nTIzlaz+=nIzlaz
		nTPKol+=nPKol
		nTMPVU+=nMPVU
		nTMPVI+=nMPVI
		nTNVU+=nNVU
		nTNVI+=nNVI
		nTRabat+=nRabat
		nTPMPV+=nPMPV
		nTPNV+=nPNV

		if (IsPlanika() .and. cPrikazDob=="D")
		   ? PrikaziDobavljaca(cIdRoba, 6) 
		endif

		if lKoristitiBK
		   ? SPACE(6) + roba->barkod
		endif
		
	endif 
enddo

? m
? "UKUPNO:"
@ prow(), nCol0-1 SAY ""
if cPredhStanje=="D"
	@ prow(),pcol()+1 SAY nTPMPV pict gpickol
endif
@ prow(),pcol()+1 SAY nTUlaz pict gpickol
@ prow(),pcol()+1 SAY nTIzlaz pict gpickol
@ prow(),pcol()+1 SAY nTUlaz-nTIzlaz+nTPKol pict gpickol
nCol1:=pcol()+1
@ prow(),pcol()+1 SAY nTMPVU pict gpicdem
@ prow(),pcol()+1 SAY nTMPVI pict gpicdem
@ prow(),pcol()+1 SAY nTMPVU-nTMPVI+nTPMPV pict gpicdem

if cPNab=="D"
	@ prow()+1,nCol0-1 SAY ""
	if cPredhStanje=="D"
 		@ prow(),pcol()+1 SAY nTPNV pict gpickol
	endif
	@ prow(),pcol()+1 SAY space(len(gpicdem))
	@ prow(),pcol()+1 SAY space(len(gpicdem))
	@ prow(),pcol()+1 SAY space(len(gpicdem))
	@ prow(),pcol()+1 SAY nTNVU pict gpicdem
	@ prow(),pcol()+1 SAY nTNVI pict gpicdem
	@ prow(),pcol()+1 SAY nTNVU-nTNVI+nTPNV pict gpicdem
endif

? m

FF
END PRINT

if lImaGresaka
	MsgBeep("Pogledajte artikle za koje je u izvjestaju stavljena oznaka ERR - GRESKA")
endif

if lPocStanje
	if lImaGresaka .and. Pitanje(,"Nulirati pripremu (radi ponavljanja procedure) ?","D")=="D"
   		select pripr
   		zap
 	else
   		RenumPripr(cBrPSt,"80")
 	endif
endif

closeret
return


// zaglavlje llp
function ZaglLLP(lSint)
*{
if lSint==NIL
	lSint:=.f.
endif

Preduzece()
P_COND
?? "KALK: LAGER LISTA  PRODAVNICA ZA PERIOD",dDatOd,"-",dDatDo," NA DAN "
?? date(), space(12),"Str:",str(++nTStrana,3)

if !lSint .and. !EMPTY(qqIdPartn)
	? "Obugvaceni sljedeci partneri:", TRIM(qqIdPartn)
endif

if lSint
	? "Kriterij za prodavnice:",qqKonto
else
 	select konto
	hseek cidkonto
 	? "Prodavnica:", cIdKonto, "-", konto->naz
endif

if IsDomZdr() .and. !Empty(cKalkTip)
	PrikTipSredstva(cKalkTip)
endif

cSC1:=""
cSC2:=""

select kalk
? m
if cPredhStanje=="D"
	if IsPDV()
		? " R.  * Artikal  *   Naziv            *jmj*"+" Predh.st *  ulaz       izlaz   * STANJE   *  PV.Dug. *  PV.Pot *    PV    * PC.SA PDV*"+cSC1
  	else
		? " R.  * Artikal  *   Naziv            *jmj*"+" Predh.st *  ulaz       izlaz   * STANJE   *  MPV.Dug.* MPV.Pot *   MPV    *  MPCSAPP *"+cSC1
	endif
	? " br. *          *                    *   *"+" Kol/MPV  *                     *          *          *         *          *          *"+cSC2
  	if cPNab=="D"
  		? "     *          *                    *   *"+"          *                     * SR.NAB.C *   NV.Dug.*  NV.Pot *    NV    *          *"+cSC2
  	endif
else
	if IsPDV()
		? " R.  * Artikal  *   Naziv            *jmj*  ulaz       izlaz   * STANJE   *  PV.Dug. *  PV.Pot *    PV    * PC.SA PDV*"+cSC1
  	else
		? " R.  * Artikal  *   Naziv            *jmj*  ulaz       izlaz   * STANJE   *  MPV.Dug.* MPV.Pot *   MPV    *  MPCSAPP *"+cSC1
	endif
	? " br. *          *                    *   *                     *          *          *         *          *          *"+cSC2
  	if cPNab=="D"
  		? "     *          *                    *   *                     * SR.NAB.C *   NV.Dug.*  NV.Pot *    NV    *          *"+cSC2
  	endif
endif

if cPredhStanje=="D"
	? "     *    1     *        2           * 3 *     4    *     5    *     6    *  5 - 6   *     7    *     8   *   7 - 8  *     9    *"+cSC2
  	? m
else
	? "     *    1     *        2           * 3 *     4    *     5    *  4 - 5   *     6    *     7   *   6 - 7  *     8    *"+cSC2
  	? m
endif

return


// kreiranje kontrolne tabele
static function CreTblKontrola()
local aDbf
local cCdx

aDbf:={}
cTblKontrola:=ToUnix("c:/sigma/kontrola.dbf")
cCdx:=ToUnix("c:/sigma/kontrola")
AADD(aDbf, { "ID", "C", 10, 0})
AADD(aDbf, { "kolicina", "N", 12, 2})
AADD(aDbf, { "Mpv", "N", 10, 2})
DBCREATE2( cTblKontrola , aDbf)
CREATE_INDEX("id","id", cCdx) 
return

// azuriranje kontrolne tabele
static function AzurKontrolnaTabela(cIdRoba, nStanje, nMpv)
local nArea

nArea:=SELECT()

SELECT (F_KONTROLA)

if !USED()
	USE (cTblKontrola)
endif

SELECT kontrola
APPEND BLANK
REPLACE id WITH cIdRoba
REPLACE kolicina WITH nStanje
REPLACE Mpv WITH nMpv

SELECT(nArea)
return

