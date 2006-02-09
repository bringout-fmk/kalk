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
AADD(opc,"1. generisi FIN,FAKT dokumente (kontiraj) ")
AADD(opcexe,{|| Rekapk(.t.)})
AADD(opc,"2. iz FAKT generisi KALK dokumente")
AADD(opcexe, {|| Faktkalk()})
AADD(opc,"3. iz TOPS generisi KALK dokumente")
AADD(opcexe, {|| UzmiIzTOPSa()})
AADD(opc,"4. sifrarnik KALK prebaci u TOPS")
AADD(opcexe, {|| SifKalkTOPS()} )
AADD(opc,"5. iz KALK generisi TOPS dokumente")
AADD(opcexe, {|| Mnu_GenKaTOPS()} )
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
