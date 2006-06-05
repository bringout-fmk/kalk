#include "\dev\fmk\kalk\kalk.ch"

// stampa liste dokumenata koji se nalaze u pripremi
function StPripr()
*{
m:="-------------- -------- ----------"
O_PRIPR

START PRINT CRET

?? m
? "   Dokument     Datum  Broj stavki"
? m
do while !eof()
  cIdFirma:=IdFirma; cIdVd:=idvd; cBrDok:=BrDok
  dDatDok:=datdok
  nStavki:=0
  do while !eof() .and. cIdFirma==idfirma .and. cIdVd==idvd .and. cbrdok==brdok
    ++nStavki
    skip
  enddo
  ? cIdFirma+"-"+cIdVd+"-"+cBrDok, dDatDok, STR(nStavki,4), space(2), "__"
enddo
? m
END PRINT
closeret
return
*}

