#include "kalk.ch"


// -----------------------------------------------------
// korekcija nc pomocu dokumenta 95 - nc iz sif.robe
// -----------------------------------------------------
function KorekNC2()
local nPom:=0
private cMagac := "1310   "
private dDok := DATE()

IF !SigmaSif("SIGMAPR2")
   return
endif

O_KONCIJ
O_KONTO

IF !VarEdit({ {"Magacinski konto","cMagac","P_Konto(@cMagac)",,},{"Datum dokumenta","dDok",,,} }, 12,5,16,74,;
               'DEFINISANJE MAGACINA NA KOME CE BITI IZVRSENE PROMJENE',;
               "B1")
	CLOSERET
ENDIF
O_ROBA
O_PRIPR
O_KALK

nTUlaz:=0
nTIzlaz:=0
nTVPVU:=0
nTVPVI:=0
nTNVU:=0
nTNVI:=0
nTRabat:=0

private nRbr:=0

select kalk

cBr95 := Sljedeci( gFirma, "95" )

select koncij
seek trim(cMagac)
select kalk
set order to 3
HSEEK gFirma+cMagac

do while !eof() .and. idfirma+mkonto=gFirma+cMagac

	cIdRoba:=Idroba
	nUlaz:=nIzlaz:=0
	nVPVU:=nVPVI:=nNVU:=nNVI:=0
	nRabat:=0
	select roba
	hseek cIdRoba
	select kalk

	if roba->tip $ "TU"
		skip
		loop
	endif

	cIdkonto:=mkonto
	do while !eof() .and. gFirma+cidkonto+cidroba==idFirma+mkonto+idroba

  		if roba->tip $ "TU"
			skip
			loop
		endif

  		if mu_i=="1"
    			if !(idvd $ "12#22#94")
     nUlaz+=kolicina-gkolicina-gkolicin2
     nVPVU+=vpc*(kolicina-gkolicina-gkolicin2)
     nNVU+=nc*(kolicina-gkolicina-gkolicin2)
   else
     nIzlaz-=kolicina
     nVPVI-=vpc*kolicina
     nNVI-=nc*kolicina
    endif
  elseif mu_i=="5"
    nIzlaz+=kolicina
    nVPVI+=vpc*kolicina
    nRabat+=vpc*rabatv/100*kolicina
    nNVI+=nc*kolicina
  elseif mu_i=="3"    // nivelacija
    nVPVU+=vpc*kolicina
  endif
  skip
enddo

  select pripr
  if round(nulaz-nizlaz,4)<>0
    if round(roba->nc-(nNVU-nNVI)/(nulaz-nizlaz),4) <> 0
      ++nRbr
      append blank
      replace idfirma with gFirma, idroba with cIdRoba, idkonto2 with cIdKonto,;
              datdok with dDok,;
              idtarifa with roba->idtarifa,;
              datfaktp with dDok,;
              datkurs with dDok,;
              kolicina with nulaz-nizlaz,;
              idvd with "95", brdok with cBr95 ,;
              rbr with STR(nRbr,3),;
              mkonto with cMagac,;
              mu_i with "5",;
              nc with (nNVU-nNVI)/(nulaz-nizlaz),;
              vpc with KoncijVPC(),;
              marza with KoncijVPC()-(nNVU-nNVI)/(nulaz-nizlaz)
      append blank
      replace idfirma with gFirma, idroba with cIdRoba, idkonto2 with cIdKonto,;
              datdok with dDok,;
              idtarifa with roba->idtarifa,;
              datfaktp with dDok,;
              datkurs with dDok,;
              kolicina with -(nulaz-nizlaz),;
              idvd with "95", brdok with left(cBr95,5)+"/2" ,;
              rbr with STR(nRbr,3),;
              mkonto with cMagac,;
              mu_i with "5",;
              nc with roba->nc,;
              vpc with KoncijVPC(),;
              marza with KoncijVPC()-roba->nc
    endif
  endif
  select kalk

enddo

CLOSERET
return
*}

