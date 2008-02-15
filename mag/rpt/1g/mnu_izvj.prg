#include "\dev\fmk\kalk\kalk.ch"


function IzvjM()
private Opc:={}
private opcexe:={}
AADD(Opc,"1. kartica - magacin                        ")
AADD(opcexe,{|| KarticaM()})
AADD(Opc,"2. lager lista - magacin")
AADD(opcexe,{|| LLM()})
AADD(Opc,"3. lager lista - proizvoljni sort")
AADD(opcexe,{|| KaLagM()})

AADD(Opc,"4. finansijsko stanje magacina")
AADD(opcexe, {|| FLLM()})
AADD(Opc,"5. realizacija po partnerima")
AADD(opcexe,{||  RealPartn()})
AADD(Opc,"6. promet grupe partnera")
AADD(opcexe,{|| PrometGP()})
AADD(opc,"7. pregled robe za dobavljaca")
AADD(opcexe, {|| ProbDob()})

AADD(Opc,"----------------------------------")
AADD(opcexe, nil)
AADD(Opc,"8. porezi")
AADD(opcexe,{|| MPoreziMag()})
AADD(Opc,"----------------------------------")
AADD(opcexe, nil)
AADD(Opc,"S. pregledi za vise objekata")
AADD(opcexe, {|| MRekMag() })
AADD(Opc,"T. lista trebovanja po sastavnicama")
AADD(opcexe, {|| g_sast_list() })
AADD(Opc,"U. specifikacija izlaza po sastavnicama")
AADD(opcexe, {|| rpt_prspec() })
private Izbor:=1
Menu_SC("imag")
CLOSERET
return





/*! \fn MPoreziMag()
 *  \brief Meni izvjestaja o porezima
 */

function MPoreziMag()
*{
private Opc:={}
private opcexe:={}
AADD(Opc,"1. realizacija - veleprodaja po tarifama")
AADD(opcexe,{|| RekPorMag()})
AADD(Opc,"2. porez na promet ")
AADD(opcexe,{|| RekPorNap()})
AADD(Opc,"3. rekapitulacija po tarifama")
AADD(opcexe,{|| RekmagTar()})
private Izbor:=1
Menu_SC("porm")
CLOSERET
return
*}




/*! \fn MRekMag()
 *  \brief Meni izvjestaja za vise objekata(konta)
 */
 
function MRekMag()
*{
private Opc:={}
private opcexe:={}
AADD(Opc,"1. rekapitulacija finansijskog stanja")
AADD(opcexe, {|| RFLLM() } )
private Izbor:=1
Menu_SC("rmag")
CLOSERET
return
*}




