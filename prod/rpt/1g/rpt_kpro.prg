/* 
 * This file is part of the bring.out FMK, a free and open source 
 * accounting software suite,
 * Copyright (c) 1996-2011 by bring.out doo Sarajevo.
 * It is licensed to you under the Common Public Attribution License
 * version 1.0, the full text of which (including FMK specific Exhibits)
 * is available in the file LICENSE_CPAL_bring.out_FMK.md located at the 
 * root directory of this source code archive.
 * By using this software, you agree to be bound by its terms.
 */


#include "kalk.ch"

static __line
static __txt1
static __txt2
static __txt3

// ------------------------------------
// kartica prodavnice
// ------------------------------------
function KarticaP()
parameters cIdFirma,cIdRoba,cIdKonto

local cLine
local cTxt1
local cTxt2
local cTxt3

private PicCDEM:=REPLICATE("9", VAL(gFPicCDem)) + gPicCDEM 
private PicProc:=gPicProc
private PicDEM:= REPLICATE("9", VAL(gFPicDem)) + gPicDem
private Pickol:="@Z " + REPLICATE("9", VAL(gFPicKol)) + gPickol

O_TARIFA
O_SIFK
O_SIFV
O_ROBA
O_KONTO

cPredh:="N"
dDatOd:=ctod("")
dDatDo:=date()
cPKN := "N"

if IsDomZdr()
	private cKalkTip:=SPACE(1)
endif

if PCount()==0
	O_PARTN
 	cIdFirma:=gFirma
 	cIdRoba:=space(10)
 	cIdKonto:=padr("1320",7)
 	cPredh:="N"
 	cPrikazDob:="N"
	if IsPlanika()
		cK9:=SPACE(3)
 	endif
	O_PARAMS
 	cBrFDa:="N"
 	Private cSection:="4",cHistory:=" ",aHistory:={}
 	Params1()
 	RPar("c1",@cIdRoba)
	RPar("c2",@cIdKonto)
	RPar("c3",@cPredh)
 	RPar("d1",@dDatOd)
	RPar("d2",@dDatDo)
 	RPar("c4",@cBrFDa)

 Box(,8+IF(lPoNarudzbi,2,0),60)
  DO WHILE .t.
    if gNW $ "DX"
     @ m_x+1,m_y+2 SAY "Firma "; ?? gFirma,"-",gNFirma
    else
     @ m_x+1,m_y+2 SAY "Firma: " GET cIdFirma valid {|| P_Firma(@cIdFirma),cidfirma:=left(cidfirma,2),.t.}
    endif
    @ m_x+2,m_y+2 SAY "Konto " GET cIdKonto VALID P_Konto(@cIdKonto)
    if lKoristitiBK
    	@ m_x+3,m_y+2 SAY "Roba  " GET cIdRoba  WHEN {|| cIdRoba:=PADR(cIdRoba,VAL(gDuzSifIni)),.t.} VALID {|| Empty(cIdRoba), cIdRoba:=iif(LEN(TRIM(cIdRoba))<=10,Left(cIdRoba,10),cIdRoba), P_Roba(@cIdRoba)} PICT "@!"
    else
    	@ m_x+3,m_y+2 SAY "Roba  " GET cIdRoba  VALID EMPTY(cidroba) .or. P_Roba(@cIdRoba) PICT "@!"
    endif
    @ m_x+5,m_y+2 SAY "Datum od " GET dDatOd
    @ m_x+5,col()+2 SAY "do" GET dDatDo
    @ m_x+6,m_y+2 SAY "sa prethodnim prometom (D/N)" GET cPredh pict "@!" valid cpredh $ "DN"

    IF lPoNarudzbi
      qqIdNar := SPACE(60)
      cPKN    := "N"
      @ row()+1,m_y+2 SAY "Uslov po sifri narucioca:" GET qqIdNar pict "@!S30"
      @ row()+1,m_y+2 SAY "Prikazati kolone 'narucilac' i 'br.narudzbe' ? (D/N)" GET cPKN VALID cPKN$"DN" pict "@!"
    ENDIF
    
    if IsPlanika()
    	@ m_x+7,m_y+2 SAY "Prikaz dobavljaca (D/N) ?" GET cPrikazDob pict "@!" valid cPrikazDob $ "DN"
    	@ m_x+8,m_y+2 SAY "Prikaz po K9 " GET cK9 pict "@!"
    endif	
    if IsDomZdr()
    	@ m_x+7,m_y+2 SAY "Prikaz po tipu sredstva " GET cKalkTip PICT "@!"
    endif

    read
    ESC_BCR

    IF lPoNarudzbi
     aUslN:=Parsiraj(qqIdNar,"idnar")
    ENDIF

    if (!lPoNarudzbi.or.aUslN<>NIL)
      exit
    endif
  ENDDO
 BoxC()

 // skeniraj dokumente u procesu za konto
 pl_scan_dok_u_procesu(cIdKonto)

 if empty(cIdRoba) .or. cIdroba=="SIGMAXXXXX"
    if pitanje(,"Niste zadali sifru artikla, izlistati sve kartice ?","N")=="N"
       closeret
    else
       if !empty(cidroba)
           if Pitanje(,"Korekcija nabavnih cijena ???","N")=="D"
              fKNabC:=.t.
           endif
       endif
       cIdr:=""
    endif
 else
    cIdr:=cidroba
 endif

 if Params2()
  O_PARAMS
  WPar("c1",cIdRoba)
  WPar("c2",cIdkonto)
  WPar("c3",cPredh)
  WPar("d1",dDatOd)
  WPar("d2",dDatDo)
  WPar("c4",@cBrFDa)
 endif
 select params
 use

else
  	cIdR:=cIdRoba
	cPrikazDob:="N"
endif

O_KALK
nKolicina:=0
select kalk
set order to 4
// hseek cidfirma+cidkonto+cidroba

private cFilt:=".t."

IF lPoNarudzbi .and. aUslN<>".t."
  cFilt+=".and."+aUslN
ENDIF
if IsDomZdr() .and. !Empty(cKalkTip)
	cFilt+=".and. tip=" + Cm2Str(cKalkTip)
endif

IF !(cFilt==".t.")
	set filter to &cFilt
ENDIF

hseek cIdFirma+cIdKonto+cIdR
EOF CRET

gaZagFix:={7+IF(lPoNarudzbi.and.!EMPTY(qqIdNar),3,0),3}
start print cret
?

nLen:=1

if IsPDV()

	_set_zagl(@cLine, @cTxt1, ;
			lPoNarudzbi, cPKN )

	__line := cLine
	__txt1 := cTxt1
	
else
	
	m:="-------- ----------- ------ ------ "+IF(lPoNarudzbi.and.cPKN=="D","------ ---------- ","")+"---------- ---------- ---------- ---------- ---------- ---------- ----------"
	__line := m
	
endif

nTStrana:=0

Zagl()

nCol1:=10
nUlaz:=nIzlaz:=0
nMPV:=nNV:=0
fPrviProl:=.t.

do while !eof() .and. idfirma+pkonto+idroba=cIdFirma+cIdKonto+cIdR
	cIdRoba:=idroba
	select roba
	hseek cIdRoba
	
	// uslov po K9, planika
	if (IsPlanika() .and. EMPTY(cIdR) .and. !EMPTY(cK9) .and. roba->k9 <> cK9)
		select kalk
		skip
		loop
	endif
	
	select tarifa
	hseek roba->idtarifa
	? __line
	? "Artikal:",cIdRoba,"-",Trim(LEFT(roba->naz,40))+iif(lKoristitiBK," BK:"+roba->barkod,"")+" ("+roba->jmj+")"

	if (IsPlanika() .and. cPrikazDob=="D")
		?? PrikaziDobavljaca(cIdRoba, 3)
	endif

	? __line
	select kalk

	nCol1:=10
	nUlaz:=nIzlaz:=0
	nNV:=nMPV:=0
	fPrviProl:=.t.
	nRabat:=0                
	nColDok:=9                
	nColFCJ2:=68           

	do while !eof() .and. cidfirma+cidkonto+cidroba==idFirma+pkonto+idroba

  	if datdok<ddatod .and. cPredh=="N"
     		skip
		loop
  	endif
  	if datdok>ddatdo
     		skip
		loop
  	endif

  if cPredh=="D" .and. datdok>=dDatod .and. fPrviProl
        // ispis predhodnog stanja
        fPrviprol:=.f.
        ? "Stanje do ",ddatod

        @ prow(),35+IF(lPoNarudzbi.and.cPKN=="D",18,0)    SAY nulaz        pict pickol
        @ prow(),pcol()+1 SAY nizlaz       pict pickol
        @ prow(),pcol()+1 SAY nUlaz-nIzlaz pict pickol
        if round(nulaz-nizlaz,4)<>0
            @ prow(),pcol()+1 SAY nNV/(nulaz-nizlaz) pict piccdem
            @ prow(),pcol()+1 SAY 0            pict pickol
            @ prow(),pcol()+1 SAY nMPV/(nulaz-nizlaz) pict piccdem
        elseif round(nmpv,3)<>0
           @ prow(),pcol()+1 SAY 0            pict pickol
           @ prow(),pcol()+1 SAY 0            pict pickol
           @ prow(),pcol()+1 SAY PADC("ERR",len(piccdem))
        else
           @ prow(),pcol()+1 SAY 0            pict pickol
        endif
   endif

  if prow()-gPStranica>62
  	FF
	Zagl()
  endif
  
  if pu_i=="1"
    nUlaz+=kolicina-GKolicina-GKolicin2
    if datdok>=ddatod
     ? datdok,idvd+"-"+brdok,idtarifa,idpartner
     IF lPoNarudzbi .and. cPKN=="D"
       ?? "", idnar, brojnar
     ENDIF
     nCol1:=pcol()+1
     @ prow(),pcol()+1 SAY kolicina        pict pickol
     @ prow(),pcol()+1 SAY 0               pict pickol
     @ prow(),pcol()+1 SAY nUlaz-nIzlaz    pict pickol
     @ prow(),pcol()+1 SAY nc              pict piccdem
     @ prow(),pcol()+1 SAY vpc             pict piccdem
     @ prow(),pcol()+1 SAY mpcsapp         pict piccdem
    endif
    nMPV+=mpcsapp*kolicina
    nNV+=nc*kolicina
    if datdok>=ddatod
     @ prow(),pcol()+1 SAY nmpv         pict picdem
    endif

  elseif pu_i=="5"  .and. !(idvd $ "12#13#22")
    nIzlaz+=kolicina
    if datdok>=ddatod
     ? datdok,idvd+"-"+brdok,idtarifa,idpartner
     IF lPoNarudzbi .and. cPKN=="D"
       ?? "", idnar, brojnar
     ENDIF
     nCol1:=pcol()+1
     @ prow(),pcol()+1 SAY 0         pict pickol
     @ prow(),pcol()+1 SAY kolicina  pict pickol
     @ prow(),pcol()+1 SAY nUlaz-nIzlaz    pict pickol
     @ prow(),pcol()+1 SAY nc        pict piccdem
     @ prow(),pcol()+1 SAY vpc*(1-rabatv/100)  pict piccdem
     @ prow(),pcol()+1 SAY mpcsapp   pict piccdem
    endif
    nMPV-=mpcsapp*kolicina
    nNV-=nc*kolicina
    if datdok>=ddatod
     @ prow(),pcol()+1 SAY nmpv         pict picdem
    endif

  elseif pu_i=="I"
    nIzlaz+=gkolicin2
    if datdok>=ddatod
     ? datdok,idvd+"-"+brdok,idtarifa,idpartner
     IF lPoNarudzbi .and. cPKN=="D"
       ?? "", idnar, brojnar
     ENDIF
     nCol1:=pcol()+1
     @ prow(),pcol()+1 SAY 0         pict pickol
     @ prow(),pcol()+1 SAY gkolicin2  pict pickol
     @ prow(),pcol()+1 SAY nUlaz-nIzlaz    pict pickol
     @ prow(),pcol()+1 SAY nc        pict piccdem
     @ prow(),pcol()+1 SAY 0  pict piccdem
     @ prow(),pcol()+1 SAY mpcsapp   pict piccdem
    endif
    nMPV-=mpcsapp*gkolicin2
    nNV-=nc*gkolicin2
    if datdok>=ddatod
     @ prow(),pcol()+1 SAY nmpv         pict picdem
    endif
  elseif pu_i=="5"  .and. (idvd $ "12#13#22")    // povrat
    nUlaz-=kolicina
    if datdok>=ddatod
     ? datdok,idvd+"-"+brdok,idtarifa,idpartner
     IF lPoNarudzbi .and. cPKN=="D"
       ?? "", idnar, brojnar
     ENDIF
     nCol1:=pcol()+1
     @ prow(),pcol()+1 SAY -kolicina  pict pickol
     @ prow(),pcol()+1 SAY 0          pict pickol
     @ prow(),pcol()+1 SAY nUlaz-nIzlaz    pict pickol
     @ prow(),pcol()+1 SAY nc        pict piccdem
     @ prow(),pcol()+1 SAY vpc       pict piccdem
     @ prow(),pcol()+1 SAY mpcsapp   pict piccdem
    endif

    nMPV-=mpcsapp*kolicina
    nNV-=nc*kolicina
    if datdok>=ddatod
     @ prow(),pcol()+1 SAY nmpv         pict picdem
    endif

  elseif pu_i=="3"    
     // nivelacija
    if datdok>=ddatod
     ? datdok,idvd+"-"+brdok,idtarifa,idpartner
     IF lPoNarudzbi .and. cPKN=="D"
       ?? "", idnar, brojnar
     ENDIF
     nCol1:=pcol()+1
     @ prow(),pcol()+1 SAY kolicina  pict pickol
     @ prow(),pcol()+1 SAY 0         pict pickol
     @ prow(),pcol()+1 SAY nUlaz-nIzlaz    pict pickol
     @ prow(),pcol()+1 SAY fcj           pict piccdem  // kod ove kalk to predstavlja staru vpc
     @ prow(),pcol()+1 SAY mpcsapp       pict piccdem
     @ prow(),pcol()+1 SAY fcj+mpcsapp   pict piccdem
    endif
    nMPV+=mpcsapp*kolicina
    if datdok>=ddatod
     @ prow(),pcol()+1 SAY nmpv         pict picdem
    endif
  endif

  skip    
enddo

? __line
? "Ukupno:"
@ prow(),nCol1    SAY nulaz        pict pickol
@ prow(),pcol()+1 SAY nizlaz       pict pickol
@ prow(),pcol()+1 SAY nUlaz-nIzlaz pict pickol
if round(nulaz-nizlaz,4)<>0
    @ prow(),pcol()+1 SAY nNV/(nulaz-nizlaz) pict piccdem
    @ prow(),pcol()+1 SAY 0            pict pickol
    @ prow(),pcol()+1 SAY nMPV/(nulaz-nizlaz) pict piccdem
elseif round(nmpv,3)<>0
   @ prow(),pcol()+1 SAY 0            pict pickol
   @ prow(),pcol()+1 SAY 0            pict pickol
   @ prow(),pcol()+1 SAY PADC("ERR",len(piccdem))
else
   @ prow(),pcol()+1 SAY 0            pict pickol
endif
@ prow(),pcol()+1 SAY nmpv         pict picdem
? __line

?
?
enddo
FF
end print
closeret
return



// ---------------------------------------------------------
// setovanje zaglavlja
// ---------------------------------------------------------
static function _set_zagl( cLine, cTxt1, ;
			lPoNarudzbi, cPKN )
local aKProd := {}
local nPom

nPom := 8
AADD(aKProd, {nPom, PADC("Datum", nPom) })
nPom := 11
AADD(aKProd, {nPom, PADC("Dokument", nPom) })
nPom := 6
AADD(aKProd, {nPom, PADC("Tarifa", nPom) })
nPom := 6
AADD(aKProd, {nPom, PADC("Partn", nPom) })

if lPoNarudzbi .and. cPKN == "D"
	
	nPom := 6
	AADD(aKProd, {nPom, PADC("Naruc.", nPom) })
	nPom := 10
	AADD(aKProd, {nPom, PADC("Broj nar.", nPom) })

endif

nPom := LEN(gPicKol)
AADD(aKProd, {nPom, PADC("Ulaz", nPom) })
AADD(aKProd, {nPom, PADC("Izlaz", nPom) })
AADD(aKProd, {nPom, PADC("Stanje", nPom) })

nPom := LEN(gPicCDem)
AADD(aKProd, {nPom, PADC("NC", nPom) })
AADD(aKProd, {nPom, PADC("PC", nPom) })
AADD(aKProd, {nPom, PADC("PC sa PDV", nPom) })
AADD(aKProd, {nPom, PADC("PV", nPom) })

cLine := SetRptLineAndText(aKProd, 0)
cTxt1 := SetRptLineAndText(aKProd, 1, "*")

return


function Test(cIdRoba)
if LEN(Trim(cIdRoba))<=10
	cIdRoba:=Left(cIdRoba,10)
else
	cIdRoba:=cIdRoba
endif
return cIdRoba



// --------------------------------------
// zaglavlje kartice
// --------------------------------------
static function Zagl()
select konto
hseek cIdKonto

Preduzece()
P_12CPI
?? "KARTICA PRODAVNICA za period",ddatod,"-",ddatdo,space(10),"Str:",str(++nTStrana,3)
IspisNaDan(10)
IF lPoNarudzbi .and. !EMPTY(qqIdNar)
  ?
  ? "Obuhvaceni sljedeci narucioci:",TRIM(qqIdNar)
  ?
ENDIF

if IsDomZdr() .and. !Empty(cKalkTip)
	PrikTipSredstva(cKalkTip)
endif

? "Konto: ",cidkonto,"-",konto->naz
// select roba; hseek cidroba
// select tarifa; hseek roba->idtarifa
// ? "Artikal:",cidroba,"-",trim(roba->naz)+" ("+roba->jmj+")"
select kalk
IF lPoNarudzbi .and. cPKN=="D"
  P_COND2
ELSE
  P_COND
ENDIF
? __line
if IsPDV()
	? __txt1
else
	? " Datum     Dokument  Tarifa  Partn "+IF(lPoNarudzbi.and.cPKN=="D","Naruc.  Broj nar. ","")+"    Ulaz      Izlaz     Stanje      NC         VPC       MPCSAPP        MPV"
endif
? __line
return


// izvjestaj najprometniji artikli
function NPArtikli()
 local PicDEM:= gPicDem
 local Pickol:= "@Z "+gpickol
  qqKonto := "132;"
  qqRoba  := ""
  cSta    := "O"
  dDat0   := DATE()
  dDat1   := DATE()
  nTop    := 20
  if IsPlanika()
  	cPrikazDob:="N"
  	cPrikOnlyPar:="D"
  endif
  aNiz := {   { "Uslov za prodavnice (prazno-sve)"         , "qqKonto" ,              , "@!S30" , } }
  AADD (aNiz, { "Uslov za robu/artikle (prazno-sve)"       , "qqRoba"  ,              , "@!S30" , })
  AADD (aNiz, { "Pregled po Iznosu/Kolicini/Oboje (I/K/O)" , "cSta"    , "cSta$'IKO'" , "@!"    , })
  AADD (aNiz, { "Izvjestaj se pravi od datuma"             , "dDat0"   ,              ,         , })
  AADD (aNiz, { "                   do datuma"             , "dDat1"   ,              ,         , })
  AADD (aNiz, { "Koliko artikala ispisati?"                , "nTop"    , "nTop > 0"   , "999"   , })

  if IsPlanika()
  	AADD (aNiz, { "Prikazati dobavljaca (D/N) ?"             , "cPrikazDob", "cPrikazDob$'DN'" , "@!", })
  	AADD (aNiz, { "Prikaz samo artikala sa JMJ='PAR' (D/N) ?"             , "cPrikOnlyPar", "cPrikOnlyPar$'DN'" , "@!", })
  endif

  O_PARAMS
  Private cSection:="F",cHistory:=" ",aHistory:={}
  Params1()
  RPar("c2",@qqKonto)
  RPar("c5",@qqRoba )
  RPar("d1",@dDat0); RPar("d2",@dDat1)

  qqKonto := PADR(qqKonto,60)
  qqRoba  := PADR(qqRoba ,60)

  DO WHILE .t.
    IF !VarEdit(aNiz, 9,1,19,78,;
                'USLOVI ZA IZVJESTAJ "NAJPROMETNIJI ARTIKLI"',;
                "B1")
      CLOSERET
    ENDIF
    aUsl1 := Parsiraj( qqRoba  , "IDROBA" , "C" )
    aUsl2 := Parsiraj( qqKonto , "PKONTO" , "C" )
    if aUsl1<>NIL .and. aUsl2<>NIL .and. dDat0<=dDat1
      exit
    elseif aUsl2==NIL
      Msg("Kriterij za prodavnice nije korektno postavljen!")
    elseif aUsl1==NIL
      Msg("Kriterij za robu nije korektno postavljen!")
    else
      Msg("'Datum do' ne smije biti stariji nego 'datum od'!")
    endif
  ENDDO 

  if Params2()
   WPar("c2",qqKonto)
   WPar("c5",qqRoba )
   WPar("d1",dDat0)
   WPar("d2",dDat1)
  endif
  select params
  use

  O_KALK

  cFilt := aUsl1 + " .and. " + aUsl2 + " .and. DATDOK>=" + cm2str(dDat0) + ;
                                       " .and. DATDOK<=" + cm2str(dDat1) + ;
                                       ' .and. PU_I=="5"' +;
                                       ' .and. !(IDVD $ "12#13#22")'

  SET ORDER TO TAG "7"   
  SET FILTER TO &cFilt

  nMinI:=999999999999
  nMinK:=999999999999
  aTopI:={}
  aTopK:={}

  MsgO("Priprema izvjestaja...")

  GO TOP
  DO WHILE !EOF()
    cIdRoba   := IDROBA
    nKolicina := 0
    nIznos    := 0
    DO WHILE !EOF() .and. IDROBA==cIdRoba
      nKolicina += kolicina
      nIznos    += kolicina*mpcsapp
      SKIP 1
    ENDDO
    IF LEN(aTopI) < nTop
      AADD( aTopI , { cIdRoba , nIznos } )
      nMinI := MIN( nIznos , nMinI )
    ELSEIF nIznos > nMinI
      nPom := ASCAN( aTopI , { |x| x[2]<=nMinI } )
      IF nPom<1 .or. nPom>LEN(aTopI)
        MsgBeep("nPom="+STR(nPom)+" ?!")
      ENDIF
      aTopI[nPom] := { cIdRoba , nIznos }
      nMinI := nIznos
      AEVAL( aTopI , { |x| nMinI := MIN( nMinI , x[2] ) } )
    ENDIF
    IF LEN(aTopK) < nTop
      AADD( aTopK , { cIdRoba , nKolicina } )
      nMinK := MIN( nKolicina , nMinK )
    ELSEIF nKolicina > nMinK
      nPom := ASCAN( aTopK , { |x| x[2] <= nMinK } )
      IF nPom<1 .or. nPom>LEN(aTopK)
        MsgBeep("nPom="+STR(nPom)+" ?!")
      ENDIF
      aTopK[nPom] := { cIdRoba , nKolicina }
      nMinK := nKolicina
      AEVAL( aTopK , { |x| nMinK := MIN( nMinK , x[2] ) } )
    ENDIF
  ENDDO

  MsgC()

  ASORT( aTopI ,,, { |x,y| x[2] > y[2] } )
  ASORT( aTopK ,,, { |x,y| x[2] > y[2] } )

  O_ROBA
  SELECT ROBA

  START PRINT CRET
  ?
    // zaglavlje
    Preduzece()
    ?? "Najprometniji artikli za period",ddat0,"-",ddat1
    ? "Obuhvacene prodavnice:",IF(EMPTY(qqKonto),"SVE","'"+TRIM(qqKonto)+"'")
    ? "Obuhvaceni artikli   :",IF(EMPTY(qqRoba ),"SVI","'"+TRIM(qqRoba )+"'")
    if IsPlanika() .and. cPrikOnlyPAR=="D"
    	? "Prikaz samo artikala kod kojih je JMJ='PAR'"
    endif
    ?

    // top lista po iznosima
    IF cSta$"IO"
      m:=ALLTRIM(STR(MIN(nTop,LEN(aTopI))))+" NAJPROMETNIJIH ARTIKALA POSMATRANO PO IZNOSIMA:"
      ? __line
      ? REPL("-",LEN(m))
      ?
      ? PADC("SIFRA",LEN(id))+" "+PADC("NAZIV",LEN(naz))+" "+PADC("IZNOS",20)
      if (IsPlanika() .and. cPrikazDob=="D")
      	  ?? "    DOBAVLJAC  "
      endif	
      ? REPL("-",LEN(id))+" "+REPL("-",LEN(naz))+" "+REPL("-",20)
      if (IsPlanika() .and. cPrikazDob=="D")
      	?? SPACE(2) + REPL("-",15)		
      endif	
      FOR i:=1 TO LEN(aTopI)
        cIdRoba := aTopI[i,1]
        SEEK cIdRoba
        if IsPlanika() .and. cPrikOnlyPar=="D" .and. roba->jmj<>"PAR"
		LOOP	
	endif
	? cIdRoba, LEFT(ROBA->naz, 40), PADC(TRANSFORM(aTopI[i,2],picdem),20)
        if (IsPlanika() .and. cPrikazDob=="D")
      	    ?? PrikaziDobavljaca(cIdRoba, 2, .f.)		
        endif	
       
      NEXT
      ? REPL("-",LEN(id))+" "+REPL("-",LEN(naz))+" "+REPL("-",20)
      if (IsPlanika() .and. cPrikazDob=="D")
      	?? SPACE(2) + REPL("-",15)		
      endif	

    ENDIF

    // top lista po kolicinama
    IF cSta$"KO"
      IF cSta=="O"
         ?
	 ?
	 ?
      ENDIF
      m:=ALLTRIM(STR(MIN(nTop,LEN(aTopK))))+" NAJPROMETNIJIH ARTIKALA POSMATRANO PO KOLICINAMA:"
      ? __line
      ? REPL("-",LEN(m))
      ?
      ? PADC("SIFRA",LEN(id))+" "+PADC("NAZIV",LEN(naz))+" "+PADC("KOLICINA",20)
      if (IsPlanika() .and. cPrikazDob=="D")
      	  ?? "    DOBAVLJAC  "
      endif	
      ? REPL("-",LEN(id))+" "+REPL("-",LEN(naz))+" "+REPL("-",20)
      if (IsPlanika() .and. cPrikazDob=="D")
      	?? SPACE(2) + REPL("-",15)		
      endif	

      FOR i:=1 TO LEN(aTopK)
        cIdRoba := aTopK[i,1]
        SEEK cIdRoba
	if IsPlanika() .and. cPrikOnlyPar=="D" .and. roba->jmj<>"PAR"
		LOOP
	endif
        ? cIdRoba, LEFT(ROBA->naz, 40), PADC(TRANSFORM(aTopK[i,2],pickol),20)
        if (IsPlanika() .and. cPrikazDob=="D")
      	    ?? PrikaziDobavljaca(cIdRoba, 2, .f.)		
        endif	

      NEXT
      ? REPL("-",LEN(id))+" "+REPL("-",LEN(naz))+" "+REPL("-",20)
      if (IsPlanika() .and. cPrikazDob=="D")
      	?? SPACE(2) + REPL("-",15)		
      endif	

    ENDIF

    FF

  END PRINT

CLOSERET
return



