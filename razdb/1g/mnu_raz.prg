#include "kalk.ch"


function ModRazmjena()
private Opc:={}
private opcexe:={}
AADD(opc,"1. generisi FIN,FAKT dokumente (kontiraj)      ")
AADD(opcexe,{|| Rekapk(.t.)})
AADD(opc,"2. iz FAKT generisi KALK dokumente")
AADD(opcexe, {|| Faktkalk()})
AADD(opc,"3. iz TOPS generisi KALK dokumente")
AADD(opcexe, {|| r_tops_kalk()})
AADD(opc,"4. sifrarnik KALK prebaci u TOPS")
AADD(opcexe, {|| SifKalkTOPS()} )
AADD(opc,"5. sifrarnik TOPS prebaci u KALK")
AADD(opcexe, {|| RobaFromTops()} )
AADD(opc,"6. iz KALK generisi TOPS dokumente")
AADD(opcexe, {|| Mnu_GenKaTOPS()} )

if IsPlanika()
	AADD(opc,"7. TOPS, skeniranje dokumenata u procesu")
	AADD(opcexe, {|| scan_dok_u_procesu() })
endif

if IsVindija()
	AADD(opc,"7. import txt")
	AADD(opcexe, {|| MnuImpTxt()} )
endif

AADD(opc,"8. import csv fajl ")
AADD(opcexe, {|| MnuImpCSV()} )

AADD(opc,"-----------------------------------")
AADD(opcexe, nil )

AADD(opc,"A. kontiraj dokumente za period")
AADD(opcexe, {|| KontVise()} )

AADD(opc,"B. kontiraj automatski kalkulacije za period")
AADD(opcexe, {|| kont_v_kalk()} )

private Izbor:=1
Menu_SC("rmod")

CLOSERET

return
*}


function r_tops_kalk()
*{
private Opc:={}
private opcexe:={}
private Izbor:=1

AADD(opc,"1. prenos tops->kalk                      ")
AADD(opcexe, {|| UzmiIzTOPSa()})
AADD(Opc,"2. tops->kalk 96 po normativima za period ")
AADD(opcexe,{|| tops_nor_96() })

Menu_SC("rpka")

return
*}
