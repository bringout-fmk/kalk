#include "\dev\fmk\kalk\kalk.ch"


/*
 * ----------------------------------------------------------------
 *                                     Copyright Sigma-com software 
 * ----------------------------------------------------------------
 * $Source: c:/cvsroot/cl/sigma/fmk/kalk/prod/rpt/1g/rpt_llps.prg,v $
 * $Author: ernad $ 
 * $Revision: 1.5 $
 * $Log: rpt_llps.prg,v $
 * Revision 1.5  2003/07/02 07:36:44  ernad
 * Planika - llp, llps, dodatni uslov za artikal "NAZ $ &*"
 *
 * Revision 1.4  2003/06/06 14:38:10  sasa
 * dodat uslov Prikaz ERR, uvedena varijabla cERR
 *
 * Revision 1.3  2002/07/03 23:55:19  ernad
 *
 *
 * ciscenja planika (tragao za nepostojecim bug-om u prelgedu finansijskog obrta)
 *
 * Revision 1.2  2002/06/21 12:12:35  mirsad
 * dokumentovanje
 *
 *
 */
 

/*! \file fmk/kalk/prod/rpt/1g/rpt_llps.prg
 *  \brief Izvjestaj "lager lista sinteticki"
 */


/*! \fn LLPS()
 *  \brief Izvjestaj "lager lista sinteticki"
 */

function LLPS()
*{

PicCDem:=REPLICATE("9", VAL(gFPicCDem)) + gPicCDem
PicDem:=REPLICATE("9", VAL(gFPicDem)) + gPicDem

cIdFirma:=gFirma
qqKonto:=padr("132;",60)
if IzFMKIni("Svi","Sifk")=="D"
	O_SIFK
   	O_SIFV
endif
O_ROBA
O_KONTO
O_PARTN

dDatOd:=ctod("")
dDatDo:=date()
qqRoba:=SPACE(60)
qqTarifa:=SPACE(60)
qqidvd:=SPACE(60)
private cERR:="D"
private cPNab:="N"
private cNula:="D"
private cTU:="N"
private cPredhStanje:="N"

Box(,12,66)
	cGrupacija:=space(4)
	do while .t.
 		if gNW $ "DX"
   			@ m_x+1,m_y+2 SAY "Firma "
			?? gFirma,"-",gNFirma
 		else
  			@ m_x+1,m_y+2 SAY "Firma  " GET cIdFirma valid {|| P_Firma(@cIdFirma),cidfirma:=left(cidfirma,2),.t.}
 		endif
 		@ m_x+2,m_y+2 SAY "Prodavnice" GET qqKonto  pict "@!S50"
 		@ m_x+3,m_y+2 SAY "Artikli   " GET qqRoba pict "@!S50"
 		@ m_x+4,m_y+2 SAY "Tarife    " GET qqTarifa pict "@!S50"
 		@ m_x+5,m_y+2 SAY "Vrste dokumenata  " GET qqIDVD pict "@!S30"
 		@ m_x+6,m_y+2 SAY "Prikaz Nab.vrijednosti D/N" GET cPNab  valid cpnab $ "DN" pict "@!"
 		@ m_x+7,m_y+2 SAY "Prikaz stavki kojima je MPV 0 D/N" GET cNula  valid cNula $ "DN" pict "@!"
 		@ m_x+8,m_y+2 SAY "Prikaz ERR D/N" GET cERR  valid cERR $ "DN" pict "@!"
 		@ m_x+9,m_y+2 SAY "Datum od " GET dDatOd
 		@ m_x+9,col()+2 SAY "do" GET dDatDo
 		@ m_x+10,m_y+2 SAY "Prikaz robe tipa T/U  (D/N)" GET cTU valid cTU $ "DN" pict "@!"
 		@ m_x+12,m_y+2 SAY "Odabir grupacije (prazno-svi) GET" GET cGrupacija pict "@!"
 		read
		ESC_BCR
 
 		private aUsl1:=Parsiraj(qqRoba,"IdRoba")
 		private aUsl2:=Parsiraj(qqTarifa,"IdTarifa")
 		private aUsl3:=Parsiraj(qqIDVD,"idvd")
 		private aUsl4:=Parsiraj(qqkonto,"pkonto")
 		if aUsl1<>NIL
 			exit
 		endif
 		if aUsl2<>NIL
 			exit
 		endif
 		if aUsl3<>NIL
 			exit
 		endif
	enddo
BoxC()

O_KONCIJ
O_KALKREP

private cFilt1:=""
cFilt1:="!EMPTY(pu_i).and."+aUsl1+".and."+aUsl4
cFilt1:=STRTRAN(cFilt1,".t..and.","")
if !(cFilt1==".t.")
	set filter to &cFilt1
endif

select kalk
set order to 6
//CREATE_INDEX("6","idFirma+IdTarifa+idroba",KUMPATH+"KALK")
hseek cidfirma
EOF CRET

nLen:=1

aRptText:={}
AADD(aRptText, {5, "R.", "br."})
AADD(aRptText, {10, " Artikal"," 1 "})
AADD(aRptText, {20, " Naziv", " 2 "})
AADD(aRptText, {3, "jmj", " 3 "})
if lPoNarudzbi .and. cPKN=="D"
	AADD(aRptText, {10, " naru-", " cilac "})
endif
if cPredhStanje=="D"
	AADD(aRptText, {10, " Predh.st", " kol/MPV "})
endif
AADD(aRptText, {LEN(gPicKol), " ulaz", " 4 "})
AADD(aRptText, {LEN(gPicKol), " izlaz", " 5 "})
AADD(aRptText, {LEN(gPicKol), " STANJE", " 4-5 "})
AADD(aRptText, {LEN(PicDem), " MPV.Dug", " 6 "})
AADD(aRptText, {LEN(PicDem), " MPV.Pot", " 7 "})
AADD(aRptText, {LEN(PicDem), " MPV", " 6-7 "})
AADD(aRptText, {LEN(PicDem), " MPCSAPP", " 8 "})
if (lPoNarudzbi .and. cSredCij=="D")
	AADD(aRptText, {LEN(PicDem), " Sred.cij", " 9 "})
endif

private cLine:=SetRptLineAndText(aRptText, 0)
private cText1:=SetRptLineAndText(aRptText, 1, "*")
private cText2:=SetRptLineAndText(aRptText, 2, "*")


start print cret

select kalk

private nTStrana:=0

// koristilo se ZaglLLP(.t.)
private bZagl:={|| ZaglLLPS(.t.)}

nTUlaz:=nTIzlaz:=0
nTMPVU:=nTMPVI:=nTNVU:=nTNVI:=0
nTRabat:=0
nCol1:=nCol0:=50
nRbr:=0


private fSMark:=.f.
if right(trim(qqRoba),1)="*"
  fSMark:=.t.
endif


Eval(bZagl)
do while !eof() .and. cidfirma==idfirma .and.  IspitajPrekid()

cIdRoba:=Idroba
select roba
hseek cidroba
select kalk
nUlaz:=nIzlaz:=0
nMPVU:=nMPVI:=nNVU:=nNVI:=0
nRabat:=0


if fSMark .and. SkLoNMark("ROBA",cIdroba)
   skip
   loop
endif


if len(aUsl2)<>0
    if !Tacno(aUsl2)
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
do while !eof() .and. cidfirma+cidroba==idFirma+idroba .and.  IspitajPrekid()

  if !empty(cGrupacija)
    if cGrupacija<>roba->k1
      skip
      loop
    endif
  endif

if fSMark .and. SkLoNMark("ROBA",cIdroba)
   skip
   loop
endif


  if datdok<ddatod .or. datdok>ddatdo
     skip
     loop
  endif
  if cTU=="N" .and. roba->tip $ "TU"
  	skip
	loop
  endif

  if len(aUsl3)<>0
    if !Tacno(aUsl3)
       skip
       loop
    endif
  endif
  if pu_i=="1"
    SumirajKolicinu(field->kolicina,0, @nUlaz, 0)
    nCol1:=pcol()+1
    nMPVU+=mpcsapp*kolicina
    nNVU+=nc*(kolicina)
  elseif pu_i=="5"
    if idvd $ "12#13"
     SumirajKolicinu(-field->kolicina,0, @nUlaz, 0)
     nMPVU-=mpcsapp*kolicina
     nNVU-=nc*kolicina
    else
     
     SumirajKolicinu(0, field->kolicina, 0, @nIzlaz)
     nMPVI+=mpcsapp*kolicina
     nNVI+=nc*kolicina
    endif

  elseif pu_i=="3"    
    // nivelacija
    nMPVU+=mpcsapp*kolicina
  elseif pu_i=="I"
    SumirajKolicinu(0, field->gkolicin2, 0, @nIzlaz)
    nMPVI+=mpcsapp*gkolicin2
    nNVI+=nc*gkolicin2

  endif

  skip
enddo

NovaStrana(bZagl)
select roba
hseek cidroba
select kalk
aNaz:=Sjecistr(roba->naz,20)

? str(++nrbr,4)+".",cidroba
nCr:=pcol()+1
@ prow(),pcol()+1 SAY aNaz[1]
@ prow(),pcol()+1 SAY roba->jmj
nCol0:=pcol()+1
@ prow(),pcol()+1 SAY nUlaz pict gpickol
@ prow(),pcol()+1 SAY nIzlaz pict gpickol
@ prow(),pcol()+1 SAY nUlaz-nIzlaz pict gpickol

nCol1:=pcol()+1
@ prow(),pcol()+1 SAY nMPVU pict picdem
@ prow(),pcol()+1 SAY nMPVI pict picdem

@ prow(),pcol()+1 SAY nMPVU-NMPVI pict picdem

select roba
hseek cidroba
_mpc:=UzmiMPCSif()
select kalk

if round(nUlaz-nIzlaz,4)<>0
	@ prow(),pcol()+1 SAY (nMPVU-nMPVI)/(nUlaz-nIzlaz) pict piccdem
 	if round((nMPVU-nMPVI)/(nUlaz-nIzlaz),4)<>round(_mpc,4)
   		if (cERR=="D")
			?? " ERR"
		endif
 	endif
else
	@ prow(),pcol()+1 SAY 0 pict picdem
 	if round((nMPVU-nMPVI),4)<>0
   		?? " ERR"
 	endif
endif


@ prow()+1,0 SAY ""
if len(aNaz)==2
 @ prow(),nCR  SAY aNaz[2]
endif
if cPnab=="D"
 @ prow(),ncol0    SAY space(len(gpickol))
 @ prow(),pcol()+1 SAY space(len(gpickol))
 if round(nulaz-nizlaz,4)<>0
  @ prow(),pcol()+1 SAY (nNVU-nNVI)/(nUlaz-nIzlaz) pict picdem
 endif
 @ prow(),nCol1 SAY nNVU pict picdem
// @ prow(),pcol()+1 SAY space(len(gpicdem))
 @ prow(),pcol()+1 SAY nNVI pict picdem
 @ prow(),pcol()+1 SAY nNVU-nNVI pict picdem
 @ prow(),pcol()+1 SAY _MPC pict piccdem
endif
nTULaz+=nUlaz
nTIzlaz+=nIzlaz
nTMPVU+=nMPVU
nTMPVI+=nMPVI
nTNVU+=nNVU
nTNVI+=nNVI
nTRabat+=nRabat
enddo

NovaStrana(bZagl, 3)

// ? m
? cLine

? "UKUPNO:"
@ prow(),nCol0 SAY ntUlaz pict gpickol
@ prow(),pcol()+1 SAY ntIzlaz pict gpickol
@ prow(),pcol()+1 SAY ntUlaz-ntIzlaz pict gpickol
nCol1:=pcol()+1
@ prow(),pcol()+1 SAY ntMPVU pict picdem
@ prow(),pcol()+1 SAY ntMPVI pict picdem
@ prow(),pcol()+1 SAY ntMPVU-NtMPVI pict picdem

if cpnab=="D"
@ prow()+1,nCol1 SAY ntNVU pict picdem
@ prow(),pcol()+1 SAY ntNVI pict picdem
@ prow(),pcol()+1 SAY ntNVU-ntNVI pict picdem
endif
// ? m
? cLine

FF
end print

#ifdef CAX
if gKalks
 	select kalk
	use
endif
#endif
closeret
return
*}



function ZaglLLPS(fSint)
*{
if fsint==NIL
	fSint:=.f.
endif

Preduzece()

if IsPlNS()
	P_COND2
else
	P_COND
endif

?? "KALK: SINTETICKA LAGER LISTA PRODAVNICA ZA PERIOD",dDatOd,"-",dDatDo," NA DAN "
?? date(), space(12),"Str:",str(++nTStrana,3)

if lPoNarudzbi .and. !EMPTY(qqIdNar)
	?
  	? "Obuhvaceni sljedeci narucioci:",TRIM(qqIdNar)
  	?
endif
if !fSint .and. !EMPTY(qqIdPartn)
	? "Obugvaceni sljedeci partneri:", TRIM(qqIdPartn)
endif

if fsint
	? "Kriterij za prodavnice:",qqKonto
else
 	select konto
	hseek cidkonto
 	? "Prodavnica:", cIdKonto, "-", konto->naz
endif

if IsDomZdr() .and. !Empty(cKalkTip)
	PrikTipSredstva(cKalkTip)
endif

? cLine
? cText1
? cText2
? cLine


return
*}
