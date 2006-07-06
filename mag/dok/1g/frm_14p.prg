#include "\dev\fmk\kalk\kalk.ch"

/*
 * ----------------------------------------------------------------
 *                                     Copyright Sigma-com software 
 * ----------------------------------------------------------------
 */

/*! \fn Get1_14PDV()
 *  \brief Prva strana maske za unos dokumenta tipa 14
 */

function Get1_14PDV()
*{
pIzgSt:=.f.   // izgenerisane stavke jos ne postoje

set key K_ALT_K to KM2()

if nRbr==1 .and. fnovi
	_DatFaktP:=_datdok
endif

if nRbr==1 .or. !fnovi
	@ m_x+6,m_y+2   SAY "KUPAC:" get _IdPartner pict "@!" valid empty(_IdPartner) .or. P_Firma(@_IdPartner,6,18)
	@ m_x+7,m_y+2   SAY "Faktura Broj:" get _BrFaktP
 	@ m_x+7,col()+2 SAY "Datum:" get _DatFaktP   ;
    		valid {|| _DatKurs:=_DatFaktP,.t.}
 	_IdZaduz:=""
	_Idkonto:="1200"
 	private cNBrDok:=_brdok
 	@ m_x+9,m_y+2 SAY "Magacinski konto razduzuje"  GET _IdKonto2 ;
            valid ( empty(_IdKonto2) .or. P_Konto(@_IdKonto2,24) ) .and.;
                  MarkBrDok(fNovi)
 	if gNW<>"X"
  		@ m_x+9,m_y+40 SAY "Razduzuje:" GET _IdZaduz2   pict "@!"  valid empty(_idZaduz2) .or. P_Firma(@_IdZaduz2,24)
 	endif
else
	@ m_x+6,m_y+2   SAY "KUPAC: "; ?? _IdPartner
	@ m_x+7,m_y+2   SAY "Faktura Broj: "; ?? _BrFaktP
 	@ m_x+7,col()+2 SAY "Datum: "; ?? _DatFaktP
 	_IdZaduz:=""
 	_DatKurs:=_DatFaktP
 	_Idkonto:="1200"
 	@ m_x+9,m_y+2 SAY "Magacinski konto razduzuje "; ?? _IdKonto2
 	if gNW<>"X"
  		@ m_x+9,m_y+40 SAY "Razduzuje: "; ?? _IdZaduz2
 	endif
endif

@ m_x+10,m_y+66 SAY "Tarif.brÄ¿"

if lKoristitiBK
 	@ m_x+11,m_y+2   SAY "Artikal  " GET _IdRoba pict "@!S10" when {|| _IdRoba:=PADR(_idroba,VAL(gDuzSifIni)),.t.} valid  {|| P_Roba(@_IdRoba),Reci(11,23,trim(LEFT(roba->naz, 40))+" ("+ROBA->jmj+")",40),_IdTarifa:=iif(fnovi,ROBA->idtarifa,_IdTarifa),.t.}
else
 	@ m_x+11,m_y+2   SAY "Artikal  " GET _IdRoba pict "@!" valid  {|| P_Roba(@_IdRoba), Reci(11,23,trim(LEFT(roba->naz, 40))+" ("+ROBA->jmj+")",40), _IdTarifa:=iif(fnovi,ROBA->idtarifa, _IdTarifa),.t.}
endif

@ m_x+11,m_y+70 GET _IdTarifa when gPromTar=="N" valid P_Tarifa(@_IdTarifa)

IF !lPoNarudzbi
	@ m_x+12+IF(lPoNarudzbi,1,0),m_y+2   SAY "Kolicina " GET _Kolicina PICTURE PicKol valid _Kolicina<>0
ENDIF

IF IsDomZdr()
	@ m_x+13+IF(lPoNarudzbi,1,0),m_y+2   SAY "Tip sredstva (prazno-svi) " GET _Tip PICT "@!"
ENDIF

read
ESC_RETURN K_ESC

_MKonto:=_Idkonto2
 
if lKoristitiBK
	_idRoba:=Left(_idRoba, 10)
endif

select TARIFA
hseek _IdTarifa

select ROBA
HSEEK _IdRoba
select koncij
seek trim(_idkonto2)
select PRIPR  // napuni tarifu

if koncij->naz="P"
	_FCJ:=roba->PlC
endif

DatPosljK()
DuplRoba()

altd()


if fNovi
	select roba
  	_VPC:=KoncijVPC()
  	_NC:=NC

  	select pripr
endif

if gCijene="2" .and. fNovi

	/////// utvrdjivanje fakticke VPC
   	if gPDVMagNab == "N"
		faktVPC(@_VPC,_idfirma+_idkonto2+_idroba)
   	endif
	select pripr
endif

VtPorezi()

_GKolicina:=0

//////// kalkulacija nabavne cijene
//////// nKolZN:=kolicina koja je na stanju a porijeklo je od zadnje nabavke

nKolS:=0
nKolZN:=0
nc1:=0
nc2:=0
dDatNab:=ctod("")
lGenStavke:=.f.

if _TBankTr<>"X" .or. lPoNarudzbi   // ako je X onda su stavke vec izgenerisane
	if !empty(gMetodaNC) .or. lPoNarudzbi
   		if lPoNarudzbi
     			aNabavke:={}
     			IF !fNovi
       				AADD( aNabavke , {0,_nc,_kolicina,_idnar,_brojnar} )
     			ENDIF
     			KalkNab3m(_idfirma,_idroba,_idkonto2,aNabavke,@nKolS)
     			IF LEN(aNabavke)>1; lGenStavke:=.t.; ENDIF
     			IF LEN(aNabavke)>0
       				// - teku†a -
       				i:=LEN(aNabavke)
       				_nc := aNabavke[i,2]
       				_kolicina := aNabavke[i,3]
       				_idnar    := aNabavke[i,4]
       				_brojnar  := aNabavke[i,5]
       				// ----------
     			ENDIF
     			@ m_x+12+IF(lPoNarudzbi,1,0),m_y+2   SAY "Kolicina " GET _Kolicina PICTURE PicKol when .f.
     			@ row(),col()+2 SAY IspisPoNar(,,.t.)
   		else
     			MsgO("Racunam stanje na skladistu")
     			KalkNab(_idfirma,_idroba,_idkonto2,@nKolS,@nKolZN,@nc1,@nc2,@dDatNab,@_RokTr)
     			MsgC()
     			@ m_x+12+IF(lPoNarudzbi,1,0),m_y+30   SAY "Ukupno na stanju "
			@ m_x+12+IF(lPoNarudzbi,1,0),col()+2 SAY nkols pict pickol
   		endif
 	endif
 	IF !lPoNarudzbi
   		if dDatNab>_DatDok
			Beep(1)
			Msg("Datum nabavke je "+dtoc(dDatNab),4)
		endif
   		if _kolicina>=0
    			if gMetodaNC $ "13"
				_nc:=nc1
			elseif gMetodaNC=="2"
				_nc:=nc2
			endif
   		endif
 	ENDIF
endif
select PRIPR

altd()


@ m_x+13+IF(lPoNarudzbi,1,0),m_y+2    SAY "NAB.CJ   "  GET _NC  picture PicDEM      valid V_KolMag()

private _vpcsappp:=0

@ m_x+14+IF(lPoNarudzbi,1,0),m_y+2   SAY "PC BEZ PDV" get _VPC  valid {|| iif(gVarVP=="2" .and. (_vpc-_nc)>0,cisMarza:=(_vpc-_nc)/(1+tarifa->vpp),_vpc-_nc),.t.}  picture PicDEM

private cTRabat:="%"
@ m_x+15+IF(lPoNarudzbi,1,0),m_y+2    SAY "RABAT    " GET  _RABATV pict picdem
@ m_x+15+IF(lPoNarudzbi,1,0),col()+2  GET cTRabat  pict "@!" ;
     valid {|| PrerRab(), V_RabatV(), ctrabat $ "%AU" }

_PNAP:=0

if IsPdv()
	_MPC := tarifa->opp
endif

if gPDVMagNab == "D"
	@ m_x+16,m_y+2 SAY "PDV (%)  " + TRANSFORM(_MPC, "99.99")
else
	@ m_x+16,m_y+2 SAY "PDV (%)  " GET _MPC pict "99.99" when {|| iif(roba->tip $ "VKX",_mpc:=0,NIL),iif(roba->tip $ "VKX",pPDV14(.f.),.t.)} valid pPDV14(.t.)
endif

if gVarVP=="1"
	_VPCsaPP:=0
	@ m_x+19+IF(lPoNarudzbi,1,0),m_y+2  SAY "PC SA PDV "
 	@ m_x+19+IF(lPoNarudzbi,1,0),m_Y+50 GET _vpcSaPP picture picdem ;
      	when {|| _VPCSAPP:=iif(_VPC<>0,_VPC*(1-_RabatV/100)*(1+_MPC/100),0),ShowGets(),.t.} ;
      	valid {|| _vpcsappp:=iif(_VPCsap<>0,_vpcsap+_PNAP,_VPCSAPPP),.t.}

else  // preracunate stope

	_VPCsaPP:=0
	@ m_x+19+IF(lPoNarudzbi,1,0),m_y+2  SAY "PC SA PDV "
	@ m_x+19+IF(lPoNarudzbi,1,0),m_Y+50 GET _vpcSaPP picture picdem ;
      	when {|| _VPCSAPP:=iif(_VPC<>0,_VPC*(1-_RabatV/100)*(1+_MPC/100),0),ShowGets(),.t.} ;
      	valid {|| _vpcsappp:=iif(_VPCsap<>0,_vpcsap+_PNAP,_VPCSAPPP),.t.}
endif

read

nStrana:=2

if roba->tip="X"
	_marza:=_vpc-_mpcsapp/(1+_PORVT)*_PORVT-_nc
else
 	_mpcsapp:=0
 	_marza:=_vpc/(1+_PORVT)-_nc
endif

IF lPoNarudzbi
	_MKonto:=_Idkonto2
	_MU_I:="5"     // izlaz iz magacina
  	_PKonto:=""
	_PU_I:=""
  	if _idvd == "KO"
  		_MU_I:="4" // ne utice na stanje
  	endif
  	IF lGenStavke
    		pIzgSt:=.t.
    		// viçe od jedne stavke
    		FOR i:=1 TO LEN(aNabavke)-1
      		// generiçi sve izuzev posljednje
      			APPEND BLANK
      			_error    := IF(_error<>"1","0",_error)
      			_rbr      := RedniBroj(nRBr)
      			_nc       := aNabavke[i,2]
      			_kolicina := aNabavke[i,3]
      			_idnar    := aNabavke[i,4]
      			_brojnar  := aNabavke[i,5]
      			// _vpc      := _nc
      			Gather()
      			++nRBr
    		NEXT
    		// posljednja je teku†a
    		_nc       := aNabavke[i,2]
    		_kolicina := aNabavke[i,3]
    		_idnar    := aNabavke[i,4]
    		_brojnar  := aNabavke[i,5]
    		// _vpc      := _nc
  	ELSE
    		// jedna ili nijedna
    		IF LEN(aNabavke)>0
      			// jedna
      			_nc       := aNabavke[1,2]
      			_kolicina := aNabavke[1,3]
      			_idnar    := aNabavke[1,4]
      			_brojnar  := aNabavke[1,5]
      			// _vpc      := _nc
    		ELSE
      		// nije izabrana koliŸina -> kao da je prekinut unos tipkom Esc
      			RETURN (K_ESC)
    		ENDIF
  	ENDIF
ENDIF

_MKonto:=_Idkonto2;_MU_I:="5"     // izlaz iz magacina
_PKonto:=""; _PU_I:=""
if _idvd == "KO"
	_MU_I:="4" // ne utice na stanje
endif

if pIzgSt .and. _kolicina>0 .and. lastkey()<>K_ESC // izgenerisane stavke postoje
	private nRRec:=recno()
 	go top
 	do while !eof()  // nafiluj izgenerisane stavke
  		if kolicina==0
     			skip
     			private nRRec2:=recno()
     			skip -1
     			dbdelete2()
     			go nRRec2
     			loop
  		endif
  		if brdok==_brdok .and. idvd==_idvd .and. val(Rbr)==nRbr

    			nMarza:=_VPC/(1+_PORVT)*(1-_RabatV/100)-_NC  // ??????????
    			replace vpc with _vpc,;
          		rabatv with _rabatv,;
          		mkonto with _mkonto,;
          		tmarza  with _tmarza,;
          		mpc     with  _MPC,;
          		marza  with _vpc/(1+_PORVT)-pripr->nc,;   // mora se uzeti nc iz ove stavke
         	 	vpcsap with _VPC/(1+_PORVT)*(1-_RABATV/100)+iif(nMarza<0,0,nMarza)*TARIFA->VPP/100,;
          		mu_i with  _mu_i,;
          		pkonto with "",;
          		pu_i with  "",;
          		error with "0"
  		endif
  		skip
 	enddo
 	go nRRec
endif

set key K_ALT_K to
return lastkey()
*}




/*! \fn pPDV14(fret)
 *  \brief Prikaz PDV pri unosu 14-ke
 */

function pPDV14(fret)
*{
devpos(m_x+16+IF(lPoNarudzbi,1,0),m_y+41)
if roba->tip $ "VKX"
	// nista ppp
else
  	qqout("   PDV:",transform(_PNAP:=_VPC*(1-_RabatV/100)*_MPC/100,picdem) )
endif

_VPCSaP:=iif(_VPC<>0, _VPC*(1-_RABATV/100) + iif(nMarza<0,0,nMarza) * TARIFA->VPP/100,0)
return fret
*}


