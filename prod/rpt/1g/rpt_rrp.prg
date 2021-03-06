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

// realizovani porez prodavnice
function RekRPor()
local fSaberiKol
local nT1:=nT4:=nT5:=nT6:=nT7:=0
local nTT1:=nTT4:=nTT5:=nTT6:=nTT7:=0
local n1:=n4:=n5:=n6:=n7:=0
local nCol1:=0
local PicCDEM:=REPLICATE("9", VAL(gFPicCDem)) + gPicCDEM 
local PicProc:=gPicProc      
local PicDEM:=REPLICATE("9", VAL(gFPicDem)) + gPicDEM 
local Pickol:=gPicKol  
local i:=0
private aPorezi

lVoSaTa := ( IzFMKIni("KALK","VodiSamoTarife","N", PRIVPATH)=="D" )
dDat1:=dDat2:=ctod("")
cVDok:="99"
qqKonto:=padr("1320;",60)
qqTarifa:=padr("",60)
cTU:="2"
Box(,6,70)
 set cursor on
 do while .t.
  @ m_x+1,m_y+2 SAY "Konto prodavnice/magacina:" GET qqKonto pict "@!S30"
  @ m_x+2,m_y+2 SAY "Tarife                   :" GET qqTarifa pict "@!S30"

  @ m_x+3,m_y+2 SAY "Kalkulacije od datuma:" GET dDat1
  @ m_x+3,col()+1 SAY "do" GET dDat2
  if !lVoSaTa
    cPojed:="N"
    @ m_x+5,m_y+2  SAY "Prikaz: roba tipa T / dokumenti IP (1/2)" GET cTU  valid cTU $ "12"
  else
    cPojed:="D"
    @ m_x+5,m_y+2  SAY "Prikaz pojedinacnih uplata? (D/N)" GET cPojed  valid cPojed $ "DN" PICT "@!"
  endif
  read;ESC_BCR
  aUsl1:=Parsiraj(qqKonto,"PKonto")
  aUsl2:=Parsiraj(qqTarifa,"IdTarifa")
  if aUsl1<>NIL .and. aUsl2<>NIL; exit; endif
 enddo
BoxC()

set softseek off
O_SIFK
O_SIFV
O_ROBA
O_TARIFA
O_KALK

// "6":"idFirma+IDTarifa+idroba
set order to 6

IF lVoSaTa
	// kreirajmo pomocnu bazu
  	CrePom()
  	SELECT KALK
ENDIF

fSaberikol:=(IzFMKIni('Svi','SaberiKol','N')=='D')

if cVDOK=="99"
	cVDOK:="41#42#43#47#82#IP"
endif

private cFilt1:=""

if !empty(dDat1) .and. !empty(dDat2)
	cFilt1:=aUsl1+".and.(IDVD$"+cm2str(cVDOK)+").and.DATDOK>="+cm2str(dDat1)+".and.DATDOK<="+cm2str(dDat2)
else
 	cFilt1:=aUsl1+".and.(IDVD$"+cm2str(cVDOK)+")"
endif

if aUsl2<>".t."
	cFilt1+=".and."+aUsl2
endif

set filter to &cFilt1
go top   

EOF CRET

aRRP:={}
AADD(aRRP, {15, " TARIF", " BROJ"})
AADD(aRRP, {LEN(PicDem), " MPV", ""})
AADD(aRRP, {LEN(gPicProc), " PPP", " %"})
AADD(aRRP, {LEN(gPicProc), " PPU", " %"})
AADD(aRRP, {LEN(gPicProc), " PP", " %"})
AADD(aRRP, {LEN(PicDem), " PPP", ""})
AADD(aRRP, {LEN(PicDem), " PPU", ""})
AADD(aRRP, {LEN(PicDem), " PP", ""})
AADD(aRRP, {LEN(PicDem), " UKUPNO", " POREZ"})
AADD(aRRP, {LEN(PicDem), " Popust", ""})
AADD(aRRP, {LEN(PicDem), " MPV", " SA Por"})
cLine:=SetRptLineAndText(aRRP, 0)
cText1:=SetRptLineAndText(aRRP, 1, "*")
cText2:=SetRptLineAndText(aRRP, 2, "*")

START PRINT CRET
?

private nKI, nPRUC
nKI:=nPRUC:=0

n1:=n4:=n5:=n6:=n7:=n8:=0
DO WHILE !EOF() .and. IspitajPrekid()
  B:=0
  cIdFirma:=KALK->IdFirma

  IF !lVoSaTa
    Preduzece()
    P_12CPI
    ? "KALK:  PREGLED REALIZOVANOG POREZA (PRODAVNICE)"
    ? "       ZA PERIOD OD",dDat1,"DO",dDat2,"      NA DAN:",DATE()
    ?
    ? "Objekti: ",qqKonto
    ?
    if aUsl2<>".t."
      ?
      ? "Kriterij za tarife:",trim(qqTarifa)
      ?
    endif
    
    if VAL(gFPicDem) > 0
    	P_COND2
    else
   	P_COND
    endif
    
    ?
    ? cLine
    ? cText1
    ? cText2
    ? cLine
  
  ENDIF

  nT1:=nT4:=nT5:=nT6:=nT7:=nT8:=0
  nTP:=0
  cLastTarifa:=""
  
  
  aPorezi:={}
  DO WHILE !EOF() .AND. cIdFirma==KALK->IdFirma .and. IspitajPrekid()
	cIdKonto:=IdKonto
	cIdTarifa:=IdTarifa
	select roba
	hseek kalk->idroba
     	select tarifa
     	hseek cIdTarifa
     	select kalk
     	
	VtPorezi()

	cIdTarifa := Tarifa(pkonto, idroba, @aPorezi, cIdTarifa)
	
	nMPV:=0
     	nNv:=0
     	nPopust:=0
    	nMPVSaPP:=0
	 
     
     IF lVoSaTa  //ovo nema veze sa ugostiteljstvom
       SELECT POM
       FOR i:=1 TO 3
         IF LEN(cLastTarifa)<1 .or. cLastTarifa<>cIdTarifa .or. cPojed=="D" .and. i==2
		APPEND BLANK
		REPLACE ID WITH STR(i,1)
		REPLACE TARIFA WITH cIdTarifa
		REPLACE P_PPP WITH aPorezi[POR_PPP]
		REPLACE P_PPU WITH aPorezi[POR_PPU]
		REPLACE P_PP WITH aPorezi[POR_PP]
	   
		IF cPojed=="D" .and. i==2
			REPLACE DOKUM  WITH KALK->(IDVD+BRDOK)
			REPLACE DATDOK WITH KALK->DATDOK
		ENDIF
         ENDIF
       NEXT
       SELECT KALK
     ENDIF
     
     cPoDok:=IDVD+BRDOK
     cLastTarifa:=cIdTarifa
     nPRUC:=0
     DO WHILE !EOF() .AND. cIdFirma==IdFirma .and. cIdtarifa==IdTarifa .and. IF(cPojed=="D",cPoDok==IDVD+BRDOK,.t.) .and. IspitajPrekid()

        select roba
	hseek kalk->idroba 
        select KALK
	
        if lVoSaTa
          // vodi samo tarife
	  if ! (idvd $ "41#42")
          	skip 1
          	loop
          endif
          npMPV  := KOLICINA*MPC
          npMPVP := KOLICINA*MPCSAPP
          npPop  := KOLICINA*RABATV
          SELECT POM
          FOR i:=1 TO 3
            DO CASE
              CASE i==1 .and. KALK->idvd=="42" .and. KALK->kolicina>0
                SEEK STR(i,1)+cIdTarifa
                REPLACE mpv      WITH mpv      + npMPV              ,;
                        popust   WITH popust   + npPop              ,;
                        mpvsapor WITH mpvsapor + npMPVP

              CASE i==2
                SEEK STR(i,1)+cIdTarifa+IF(cPojed=="D",cPoDok,"")
                REPLACE mpv      WITH mpv      + npMPV              ,;
                        popust   WITH popust   + npPop              ,;
                        mpvsapor WITH mpvsapor + npMPVP

              CASE i==3 .and. (KALK->idvd=="42" .and. KALK->kolicina<0 .or.;
                               KALK->idvd=="41")
                SEEK STR(i,1)+cIdTarifa
                REPLACE mpv      WITH mpv      - npMPV              ,;
                        popust   WITH popust   - npPop              ,;
                        mpvsapor WITH mpvsapor - npMPVP

            ENDCASE
          NEXT
          SELECT KALK
        else

	  // vodi po artiklima
	  
	  // prikaz dokumenata IP, a ne robe tipa "T"
          if cTU=="2" .and.  roba->tip $ "UT"  
             skip 1
	     loop
          endif
          if cTU=="1" .and. idvd=="IP"
             skip 1
	     loop
          endif

	 
          if pu_i=="I"
	       	nKolicina:=gKolicin2
	  else
	    	nKolicina:=kolicina
	  endif

	  nMpc:=DokMpc(field->idvd,aPorezi)
	  altd()
	  aIPor:=RacPorezeMP(aPorezi,nMpc,field->mpcSaPP,field->nc)
	  nPor1:=aIPor[1]*nKolicina
	  nPor2:=aIPor[2]*nKolicina
	  nPor3:=aIPor[3]*nKolicina
	  nPRUC+=nPor2
	  nMPV+=nMpc*nKolicina
	  nMpvSaPP+=field->mpcSaPP*nKolicina
	  nNv+=field->nc*nKolicina
	  if fSaberikol .and. !( roba->K2 = 'X')
	  	nKI+=nKolicina
	  endif
	  if !pu_i=="I"	  
          	nPopust+=RabatV*nKolicina
	  endif

        endif
        skip 1

     ENDDO

     IF !lVoSaTa
     
	if prow()>61+gPStranica
		FF
	endif

	aIPor:=RacPorezeMP(aPorezi,nMpv,nMpvSaPP,nNv)
	nPorez:=aIPor[1]
	nPorez2:=aIPor[2]
	nPorez3:=aIPor[3]
	// Nap: za varijantu RMARZA_DLIMIT, ovdje je prisutan problem
	// neslaganja sume poreza sa porezom izracunatim na osnovu ukupnih
	// nMpv i nMpvSaPP jer se pojedinacno mozda koristi ponegdje limit
	// a ukupno se koristi uvijek ili ne koristi nikako
	
	@ prow()+1,0      SAY space(6)+cIdTarifa
	nCol1:=pcol()+4
	@ prow(),pcol()+4 SAY n1:=nMPV     PICT   PicDEM
       
	@ prow(),pcol()+1 SAY aPorezi[POR_PPP] PICT   PicProc
       	@ prow(),pcol()+1 SAY PrPPUMP()    PICT   PicProc
  	@ prow(),pcol()+1 SAY aPorezi[POR_PP] PICT PicProc
       
	@ prow(),pcol()+1 SAY n4:=nPorez   PICT   PicDEM
	@ prow(),pcol()+1 SAY n5:=nPorez2  PICT   PicDEM
	@ prow(),pcol()+1 SAY n6:=nPorez3  PICT   PicDEM
	@ prow(),pcol()+1 SAY n7:=nPorez+nPorez2+nPorez3  PICTURE   PicDEM
	@ prow(),pcol()+1 SAY nP:=nPopust PICTURE   PicDEM
	@ prow(),pcol()+1 SAY n8:=nMPVSAPP PICTURE   PicDEM
	
	nT1+=n1
	nT4+=n4
	nT5+=n5
	nT6+=n6
	nTP+=nP
	nT7+=n7
	nT8+=n8
     
     ENDIF
  ENDDO 

  
  IF !lVoSaTa
    // obracun po artiklima
    
    if prow()>60+gPStranica
    	FF
    endif
    ? cLine
    ? "UKUPNO:"
    @ prow(),nCol1     SAY  nT1     pict picdem
    @ prow(),pcol()+1  SAY  0        pict "@Z "+gpicproc
    @ prow(),pcol()+1  SAY  0        pict "@Z "+gpicproc
    @ prow(),pcol()+1  SAY  0        pict "@Z "+gpicproc
    @ prow(),pcol()+1  SAY  nT4     pict picdem
    @ prow(),pcol()+1  SAY  nT5     pict picdem
    @ prow(),pcol()+1  SAY  nT6     pict picdem
    @ prow(),pcol()+1  SAY  nT7     pict picdem
    @ prow(),pcol()+1  SAY  nTP     pict picdem
    @ prow(),pcol()+1  SAY  nT8     pict picdem
    ? cLine
    if fSaberikol
      ? "UKUPNO (KOLICINE):"
      @ prow(), ncol1 + (len(gPicDEM)+1)*9 SAY nKI pict gpickol
      ? cLine
    endif
  ENDIF
ENDDO 

set softseek on

IF !lVoSaTa
	?
  	FF
ELSE
	SELECT POM
  	GO TOP
  	DO WHILE !EOF() .and. IspitajPrekid()
    		REPLACE PPP  WITH MPV*P_PPP/100
    		REPLACE PPU  WITH (MPV+PPP)*P_PPU/100
    		IF gUVarPP=="D"
      			REPLACE PP   WITH (MPV+PPP)*P_PP/100
    		ELSE
      			REPLACE PP   WITH MPV*P_PP/100
    		ENDIF
    		REPLACE UPOR WITH PPP+PPU+PP
    		SKIP 1
  	ENDDO
  	GO TOP

  	FOR i:=1 TO 3
    		aKol := {}
    		nK   := 0
    		AADD( aKol, { "TARIFNI BROJ", {|| TARIFA   } , .f. , "C", 12, 0, 1,++nK} )
    		IF cPojed=="D".and.i==2
      AADD( aKol, { "DOKUMENT", {|| LEFT(dokum,2)+"-"+RIGHT(dokum,8) } , .f. , "C", 11, 0, 1,++nK} )
    ENDIF
    AADD( aKol, { "MPV"         , {|| MPV      } , .t. , "N", 12, 2, 1,++nK} )
    AADD( aKol, { "PPP(%)"      , {|| P_PPP    } , .f. , "N",  6, 2, 1,++nK} )
    AADD( aKol, { "PPU(%)"      , {|| P_PPU    } , .f. , "N",  6, 2, 1,++nK} )
    AADD( aKol, { "PP(%)"       , {|| P_PP     } , .f. , "N",  6, 2, 1,++nK} )
    AADD( aKol, { "PPP(" + gOznVal + ")"     , {|| PPP      } , .t. , "N", 10, 2, 1,++nK} )
    AADD( aKol, { "PPU(KM)"     , {|| PPU      } , .t. , "N", 10, 2, 1,++nK} )
    AADD( aKol, { "PP(KM)"      , {|| PP       } , .t. , "N", 10, 2, 1,++nK} )
    AADD( aKol, { "UK.POREZ"    , {|| UPOR     } , .t. , "N", 10, 2, 1,++nK} )
    AADD( aKol, { "POPUST"      , {|| POPUST   } , .t. , "N", 10, 2, 1,++nK} )
    AADD( aKol, { "MPV SA POR." , {|| MPVSAPOR } , .t. , "N", 12, 2, 1,++nK} )

    Preduzece()
    P_12CPI
    ? "KALK:  PREGLED REALIZOVANOG POREZA " + IF(i==1,"PO OBRACUNIMA",IF(i==2,"PO UPLATAMA","- SALDO"))
    ? "       ZA PERIOD OD",dDat1,"DO",dDat2,"      NA DAN:",DATE()
    ?
    ? "Objekti: ",qqKonto
    ?
    if aUsl2<>".t."
      ?
      ? "Kriterij za tarife:",trim(qqTarifa)
      ?
    endif

    cPom707 := STR(i,1)

    IF cPojed=="D".and.i==2
      SET ORDER TO TAG "2"
      SEEK cPom707
      PRIVATE cTarifa:="", lSubTot6:=.f., cSubTot6:=""
      StampaTabele( aKol , {|| .t.} , , 0 , {|| IdiDo1()} , .t. ,;
                    , {|| FFor6()} , -1 , .f. , .f. , {|| SubTot6()} , , , .f. , )
      SET ORDER TO TAG "1"
    ELSE
      SEEK cPom707
      StampaTabele( aKol , {|| .t.} , , 0 , {|| IdiDo1()} , .t. ,;
                    , {|| .t.} , -1 , .f. , .f. , , , , .f. , )
    ENDIF
    ?
    FF
  NEXT
ENDIF

END PRINT

closeret
return


// kreiranje i otvaranje pomocne baze POM.DBF
function CrePom()
  select 0      
  // idi na slobodno podrucje
  cPom:=PRIVPATH+"POM"
  IF FILE(cPom+".DBF") .and. ferase(PRIVPATH+"POM.DBF")==-1
    MsgBeep("Ne mogu izbrisati POM.DBF!")
    ShowFError()
  ENDIF
  IF FILE(cPom+".CDX") .and. ferase(PRIVPATH+"POM.CDX")==-1
    MsgBeep("Ne mogu izbrisati POM.CDX!")
    ShowFError()
  ENDIF
  // ferase(cPom+".CDX")
  aDbf := {}
  AADD(aDBf,{ 'ID'          , 'C' ,  1 ,  0 })
  AADD(aDBf,{ 'TARIFA'      , 'C' ,  6 ,  0 })
  AADD(aDBf,{ 'MPV'         , 'N' , 18 ,  8 })
  AADD(aDBf,{ 'P_PPP'       , 'N' ,  6 ,  2 })
  AADD(aDBf,{ 'P_PPU'       , 'N' ,  6 ,  2 })
  AADD(aDBf,{ 'P_PP'        , 'N' ,  6 ,  2 })
  AADD(aDBf,{ 'PPP'         , 'N' , 18 ,  8 })
  AADD(aDBf,{ 'PPU'         , 'N' , 18 ,  8 })
  AADD(aDBf,{ 'PP'          , 'N' , 18 ,  8 })
  AADD(aDBf,{ 'UPOR'        , 'N' , 18 ,  8 })
  AADD(aDBf,{ 'POPUST'      , 'N' , 18 ,  8 })
  AADD(aDBf,{ 'MPVSAPOR'    , 'N' , 18 ,  8 })
  AADD(aDBf,{ 'DOKUM'       , 'C' , 10 ,  0 })
  AADD(aDBf,{ 'DATDOK'      , 'D' ,  8 ,  0 })
  DBCREATE2 (cPom, aDbf)
  USEX (cPom)
  IF cPojed=="D"
    INDEX ON ID+TARIFA+DOKUM TAG "1"
    INDEX ON ID+TARIFA+DTOS(DATDOK)+DOKUM TAG "2"
  ELSE
    INDEX ON ID+TARIFA TAG "1"
  ENDIF
  SET ORDER TO TAG "1" 
  GO TOP

return .t.


// While uslov za f-ju StampaTabele() koju poziva RekRPor()
function IdiDo1()
return (POM->id==cPom707)


// For uslov za f-ju StampaTabele() koju poziva RekRPor()
function FFor6()
IF TARIFA <> cTarifa .and. LEN(cTarifa)>0
	lSubTot6:=.t.
   	cSubTot6:=cTarifa
ENDIF
cTarifa:=TARIFA
return .t.


// Uslov za subtotal za f-ju StampaTabele() koju poziva RekRPor()
function SubTot6()
LOCAL aVrati:={.f.,""}
IF lSubTot6 .or. EOF()
	aVrati := { .t. , "UKUPNO TARIFA "+IF(EOF(),cTarifa,cSubTot6) }
    	lSubTot6:=.f.
ENDIF
return aVrati


// nOsnPC - maloprodajna cijena sa porezima
// Racuna i vraca maloprodajnu cijenu bez poreza
static function IzbPorMP(nOsnPC)
local nVrati, nDLRUC, nMPP, nPP, nPPP
nDLRUC := TARIFA->DLRUC/100
nMPP   := TARIFA->MPP/100
nPP    := TARIFA->ZPP/100
nPPP   := TARIFA->OPP/100
if (gUVarPP=="J")
	nVrati := nOsnPC * ( 1+nDLRUC*(1-nPP)*(nPPP/(1+nPPP)-1)*nMPP/(1+nMPP)+(nPP-1)*nPPP/(1+nPPP)-nPP )
else
	nVrati := nOsnPC * ( 1 - ( nPP+nPPP/(1+nPPP)+nDLRUC*(1-nPP)*nMPP/(1+nMPP) ) )
endif
return nVrati


