#include "kalk.ch"
/*
 * ----------------------------------------------------------------
 *                                     Copyright Sigma-com software 
 * ----------------------------------------------------------------
 *
 */


/*! \file fmk/kalk/rpt/1g/mnu_rpt.prg
 *  \brief Izvjestaji
 */

/*! \fn MIzvjestaji()
 *  \brief Glavni menij izvjestaja
 */
 
function MIzvjestaji()
private Opc:={}
private opcexe:={}

AADD(opc,"1. izvjestaji magacin             ")
AADD(opcexe, {|| IzvjM()})
AADD(opc,"2. izvjestaji prodavnica")
AADD(opcexe, {|| IzvjP()})
AADD(opc,"3. izvjestaji magacin+prodavnica")
AADD(opcexe, {|| IzvjMaPr() } )
AADD(opc,"4. proizvoljni izvjestaji")
AADD(opcexe, {|| Proizv()})
AADD(opc,"5. export dokumenata")
AADD(opcexe, {|| krpt_export()})
AADD(opc,"6. integritet podataka")
AADD(opcexe, {|| m_integritet() })

private Izbor:=1
Menu_SC("izvj")
CLOSERET
return

return


/*! \fn IzvjMaPr()
 *  \brief Izvjestaji magacin / prodavnica
 */
 
function IzvjMaPr()
*{
private opc:={}
private opcexe:={}

AADD(opc, "F. finansijski obrt za period mag+prod")
AADD(opcexe, {|| ObrtPoMjF()})
AADD(opc, "N. najprometniji artikli")
AADD(opcexe, {|| NPArtikli()})
AADD(opc, "O. stanje artikala po objektima ")
AADD(opcexe, {|| StanjePoObjektima()})

if IsPlanika()
	AADD(opc, "Z. pregled kretanja zaliha mag/prod     ")
	AADD(opcexe, {|| PreglKret()})
	AADD(opc, "M. mjesecni iskazi prodavnice/magacin")
	AADD(opcexe, {|| ObrazInv()})
endif

if IsVindija()
	AADD(opc, "V. pregled prodaje")
	AADD(opcexe, {|| PregProdaje()})
endif

close all
private Izbor:=1
Menu_SC("izmp")
return
*}




