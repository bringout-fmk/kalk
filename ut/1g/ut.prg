#include "\dev\fmk\kalk\kalk.ch"

/*
 * ----------------------------------------------------------------
 *                                     Copyright Sigma-com software 
 * ----------------------------------------------------------------
 * $Source: c:/cvsroot/cl/sigma/fmk/kalk/ut/1g/ut.prg,v $
 * $Author: sasa $ 
 * $Revision: 1.3 $
 * $Log: ut.prg,v $
 * Revision 1.3  2002/06/26 11:59:48  sasa
 * no message
 *
 * Revision 1.2  2002/06/24 09:36:51  sasa
 * no message
 *
 *
 */


/*! \file fmk/kalk/ut/1g/ut.prg
 *  \brief Globalne funkcije modula Kalk
 */

/*! \fn OtkljucajBug()
 *  \brief Osposobljava koristenje menija
 */
 
function OtkljucajBug()
*{
//  if SigmaSif("BUG     ")
//    lPodBugom:=.f.
//    gaKeys:={}
//  endif
return
*}


/*! \fn Pripr9View()
 *  \brief Pregled smeca
 */
function Pripr9View()
*{

private aUslFirma := gFirma
private aUslDok := SPACE(50)
private dDat1 := CToD("")
private dDat2 := DATE()

Box(,10, 60)
	@ 1+m_x, 2+m_y SAY "Uslovi pregleda smeca:" COLOR "I"
	@ 3+m_x, 2+m_y SAY "Firma (prazno-sve)" GET aUslFirma PICT "@S40"
	@ 4+m_x, 2+m_y SAY "Vrste dokumenta (prazno-sve)" GET aUslDok PICT "@S20"
	@ 5+m_x, 2+m_y SAY "Datum od" GET dDat1 
	@ 5+m_x, 25+m_y SAY "do" GET dDat2 
	read
BoxC()

if LastKey()==K_ESC
	return
endif

// postavi filter
P9SetFilter(aUslFirma, aUslDok, dDat1, dDat2)

private gVarijanta:="2"

private PicV:="99999999.9"
ImeKol:={ ;
          { "F."        , {|| IdFirma                  }, "IdFirma"     } ,;
          { "VD"        , {|| IdVD                     }, "IdVD"        } ,;
          { "BrDok"     , {|| BrDok                    }, "BrDok"       } ,;
          { "Dat.Kalk"  , {|| DatDok                   }, "DatDok"      } ,;
          { "K.zad. "   , {|| IdKonto                  }, "IdKonto"     } ,;
          { "K.razd."   , {|| IdKonto2                 }, "IdKonto2"    } ,;
          { "Br.Fakt"   , {|| brfaktp                  }, "brfaktp"     }, ;
          { "Partner"   , {|| idpartner                }, "idpartner"   }, ;
          { "E"         , {|| error                    }, "error"       } ;
        }

Kol:={}
for i:=1 to LEN(ImeKol)
	AADD(Kol,i)
next

Box(,20,77)
@ m_x+17,m_y+2 SAY "<c-T>  Brisi stavku                              "
@ m_x+18,m_y+2 SAY "<c-F9> Brisi sve     "
@ m_x+19,m_y+2 SAY "<P> Povrat dokumenta u pripremu "
@ m_x+20,m_y+2 SAY "               "

if gCijene=="1" .and. gMetodaNC==" "
	Soboslikar({{m_x+17,m_y+1,m_x+20,m_y+77}},23,14)
endif

private lAutoAsist:=.f.

ObjDbedit("PRIPR9",20,77,{|| EdPr9()},"<P>-povrat dokumenta u pripremu","Pregled smeca...", , , , ,4)
BoxC()

//CLOSERET

return
*}


/*! \fn EdPr9()
 *  \brief Opcije pregleda smeca
 */
function EdPr9()
*{
do case
	case Ch==K_CTRL_T // brisanje dokumenta iz pripr9
		ErPripr9(idfirma, idvd, brdok)
      		return DE_REFRESH
	case Ch==K_CTRL_F9 // brisanje kompletnog pripr9
		ErP9All()
		return DE_REFRESH
	case chr(Ch) $ "pP" // povrat dokumenta u pripremu
		PovPr9()
		P9SetFilter(aUslFirma, aUslDok, dDat1, dDat2)
     		return DE_REFRESH
endcase
return DE_CONT

return
*}


/*! \fn PovPr9()
 *  \brief povrat dokumenta iz PRIPR9
 */
function PovPr9()
*{
local nArr
nArr:=SELECT()

Povrat9(idfirma, idvd, brdok)

select (nArr)

return DE_CONT
*}


/*! \fn P9SetFilter(aUslFirma, aUslDok, dDat1, dDat2)
 *  \brief Postavlja filter na tabeli PRIPR9
 */
static function P9SetFilter(aUslFirma, aUslDok, dDat1, dDat2)
*{
O_PRIPR9
set order to tag "1"

// obavezno postavi filter po rbr
cFilter:="rbr = '  1'"

if !Empty(aUslFirma)
	cFilter += " .and. idfirma='" + aUslFirma + "'"
endif

if !Empty(aUslDok)
	aUslDok := Parsiraj(aUslDok, "idvd")
	cFilter += " .and. " + aUslDok
endif

if !Empty(dDat1)
	cFilter += " .and. datdok >= " + Cm2Str(dDat1)
endif

if !Empty(dDat2)
	cFilter += " .and. datdok <= " + Cm2Str(dDat2)
endif

set filter to &cFilter

go top

return
*}


