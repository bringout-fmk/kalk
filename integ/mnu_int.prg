#include "\dev\fmk\kalk\kalk.ch"


// osnovni menij integriteta podataka
function m_integritet()
private opc:={}
private opcexe:={}
private izbor:=1

AADD(opc, "1. INTEG1: provjera prodaje i zalihe")
AADD(opcexe, {|| mnu_kt_int1() })

Menu_SC("int")

return



