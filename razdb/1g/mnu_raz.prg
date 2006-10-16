#include "\dev\fmk\kalk\kalk.ch"


/*
 * ----------------------------------------------------------------
 *                                     Copyright Sigma-com software 
 * ----------------------------------------------------------------
 */
 

/*! \file fmk/kalk/razdb/1g/mnu_raz.prg
 *  \brief Centralni meni opcija za prenos podataka KALK<->ostali moduli
 */


/*! \fn ModRazmjena()
 *  \brief Centralni meni opcija za prenos podataka KALK<->ostali moduli
 */

function ModRazmjena()
*{
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
AADD(opc,"5. iz KALK generisi TOPS dokumente")
AADD(opcexe, {|| Mnu_GenKaTOPS()} )

if IsPlanika()
	AADD(opc,"6. TOPS, skeniranje dokumenata u procesu")
	AADD(opcexe, {|| scan_dok_u_procesu() })
endif

if IsVindija()
	AADD(opc,"6. import txt")
	AADD(opcexe, {|| MnuImpTxt()} )
endif

AADD(opc,"-----------------------------------")
AADD(opcexe, nil )

AADD(opc,"V. kontiraj dokumente za period")
AADD(opcexe, {|| KontVise()} )

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
