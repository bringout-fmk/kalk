/* 
 * This file is part of the bring.out FMK, a free and open source 
 * accounting software suite,
 * Copyright (c) 1996-2011 by bring.out doo Sarajevo.
 * It is licensed to you under the Common Public Attribution License
 * version 1.0, the full text of which (including FMK specific Exhibits)
 * is available in the file LICENSE_CPAL_bring.out_FMK.md located at the 
 * root directory of this source code archive.
 * By using this software, you agree to be bound by its terms.
 */


#include "kalk.ch"

/*
 * ----------------------------------------------------------------
 *                                     Copyright Sigma-com software 
 * ----------------------------------------------------------------
 */
 
/*! \file fmk/kalk/sif/1g/sifre.prg
 *  \brief Sifrarnici
 */

/*! \fn Sifre()
 *  \brief Glavni menij za izbor sifrarnika
 */
 
function Sifre()
*{
PRIVATE PicDem
PicDem:=gPICDem
close all

private opc:={}
private opcexe:={}
AADD(opc,"1. opci sifrarnici                  ")
if (ImaPravoPristupa(goModul:oDataBase:cName,"SIF","OPCISIFOPEN"))
	AADD(opcexe, {|| SifFmkSvi()})
else
	AADD(opcexe, {|| MsgBeep(cZabrana)})
endif
AADD(opc,"2. robno-materijalno poslovanje")
if (ImaPravoPristupa(goModul:oDataBase:cName,"SIF","ROBMATSIFOPEN"))
	AADD(opcexe, {|| SifFmkRoba()})
else
	AADD(opcexe, {|| MsgBeep(cZabrana)})
endif

AADD(opc,"3. magacinski i prodajni objekti")
if (ImaPravoPristupa(goModul:oDataBase:cName,"SIF","PRODOBJSIFOPEN"))
	AADD(opcexe, {|| P_Objekti()})
else
	AADD(opcexe, {|| MsgBeep(cZabrana)})
endif

if IsPlanika()
	AADD(opc, "P. planika")
	if (ImaPravoPristupa(goModul:oDataBase:cName,"SIF","PLSIFOPEN"))
		AADD(opcexe, {|| KaSifPlanika() })
	else
		AADD(opcexe, {|| MsgBeep(cZabrana) })
	endif
endif
private Izbor:=1
Menu_SC("msif")
CLOSERET
return .f.
*}



/*! \fn ServFun()
 *  \brief Servisne funkcije 
 */
 
function ServFun()
*{
Msg("Nije u upotrebi")
closeret
return
*}


/*! \fn RobaBlock(Ch)
 *  \brief Obrada funkcija nad sifrarnikom robe
 *  \param Ch - Pritisnuti taster
 */
 
function RobaBlock(Ch)
*{
LOCAL cSif:=ROBA->id, cSif2:=""

if Ch==K_CTRL_T .and. gSKSif=="D"

 // provjerimo da li je sifra dupla
 PushWA()
 SET ORDER TO TAG "ID"
 SEEK cSif
 SKIP 1
 cSif2:=ROBA->id
 PopWA()
 IF !(cSif==cSif2)
   // ako nije dupla provjerimo da li postoji u kumulativu
   if ImaUKumul(cSif,"7")
     Beep(1)
     Msg("Stavka se ne moze brisati jer se vec nalazi u dokumentima!")
     return 7
   endif
 ENDIF

elseif Ch==K_ALT_M
   return  MpcIzVpc()

elseif Ch==K_F2 .and. gSKSif=="D"
 if ImaUKumul(cSif,"7")
   return 99
 endif

elseif Ch==K_F8  // cjenovnik
 
 PushWa()
 nRet:=CjenR()
 OSifBaze()
 SELECT ROBA
 PopWA()
 return nRet

elseif upper(Chr(Ch))=="O"
 if roba->(fieldpos("strings")) == 0
 	return 6
 endif
 TB:Stabilize()
 PushWa()
 m_strings(roba->strings, roba->id)
 select roba
 PopWa()
 return 7

elseif upper(Chr(Ch))=="S"

  TB:Stabilize()  // problem sa "S" - exlusive, htc
  PushWa()
  KalkStanje(roba->id)
  PopWa()
  return 6  // DE_CONT2

endif

return DE_CONT
*}


/*! \fn FSvaki2()
 *  \brief Ne radi ama bas nista!!!
 */
 
function FSvaki2()
*{
return
*}


/*! \fn IspisFirme(cIdRj)
 *  \brief Ispis firme na osnovu radne jedinice
 *  \param cIdRj - radna jedinica
 */
function IspisFirme(cIdRj)
*{
local nOArr

nOArr:=SELECT()
?? "Firma: "
B_ON
?? gNFirma
B_OFF
if !EMPTY(cIdrj)
  SELECT rj
  HSEEK cIdrj
  SELECT(nOArr)
  ?? "  RJ",rj->naz
endif
return
*}


/*! \fn OSifBaze()
 *  \brief Otvara sve tabele vezane za sifrarnike
 */
 
function OSifBaze()
*{
O_SIFK
O_SIFV
O_KONTO
O_KONCIJ
O_PARTN
O_TNAL
O_TDOK
O_TRFP
O_TRMP
O_VALUTE
O_TARIFA
O_ROBA
O_SAST
return
*}



function P_K1()
local nTArea
private ImeKol
private Kol

ImeKol := {}
Kol := {}

nTArea := SELECT()
O_K1

AADD(ImeKol, { "ID", {|| id}, "id" })
add_mcode(@ImeKol)
AADD(ImeKol, { "Naziv", {|| naz}, "naz" })

for i:=1 to LEN(ImeKol)
	AADD(Kol, i)
next

select (nTArea)
PostojiSifra(F_K1, I_ID, 10, 60, "Lista - K1")
return


function P_Objekti()
local nTArea
private ImeKol
private Kol

ImeKol := {}
Kol := {}

nTArea := SELECT()
O_OBJEKTI

AADD(ImeKol, { "ID", {|| id}, "id" })
add_mcode(@ImeKol)
AADD(ImeKol, { "Naziv", {|| naz}, "naz" })
AADD(ImeKol, { "IdObj", {|| idobj}, "idobj" })

for i:=1 to LEN(ImeKol)
	AADD(Kol, i)
next

select (nTArea)
PostojiSifra(F_OBJEKTI, 1, 10, 60, "Objekti")
return 


