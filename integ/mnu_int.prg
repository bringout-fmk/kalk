#include "\dev\fmk\kalk\kalk.ch"


// osnovni menij integriteta podataka
function m_integritet()
private opc:={}
private opcexe:={}
private izbor:=1

AADD(opc, "1. INTEG1: provjera prodaje, zalihe, robe ... ")
AADD(opcexe, {|| mnu_kt_int1() })
AADD(opc, "-------------------------------------")
AADD(opcexe, {|| nil})
AADD(opc, "R. prikaz rezultata posljednjeg testa ")
AADD(opcexe, {|| RptInteg(.t.)})
Menu_SC("int")

return



