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
 * $Source: c:/cvsroot/cl/sigma/fmk/kalk/gendok/1g/storno.prg,v $
 * $Author: mirsad $ 
 * $Revision: 1.3 $
 * $Log: storno.prg,v $
 * Revision 1.3  2002/06/19 13:57:53  mirsad
 * no message
 *
 *
 */


/*! \file fmk/kalk/gendok/1g/storno.prg
 *  \brief Generisanje storna dokumenta
 */


/*! \fn StornoDok()
 *  \brief Generisanje storna dokumenta promjenom predznaka na kolicini
 */

function StornoDok()
*{
  OEdit()
  cIdFirma := gFirma
  cIdVdU   := "  "
  cBrDokU  := SPACE(LEN(PRIPR->brdok))
  dDatDok    := CTOD("")

  Box(,6,75)
    @ m_x+0, m_y+5 SAY "STORNO DOKUMENTA PROMJENOM PREDZNAKA NA KOLICINI"
    @ m_x+2, m_y+2 SAY "Dokument: "+cIdFirma+"-"
    @ row(),col() GET cIdVdU
    @ row(),col() SAY "-" GET cBrDokU VALID ImaDok(cIdFirma+cIdVdU+cBrDokU)
    @ m_x+4, m_y+2 SAY "Datum dokumenta koji se formira" GET dDatDok VALID !EMPTY(dDatDok)
    READ; ESC_BCR
  BoxC()

  // utvrdimo broj nove kalkulacije
  SELECT DOKS; SEEK cIdFirma+cIdVdU+CHR(255); SKIP -1
  IF cIdFirma+cIdVdU == IDFIRMA+IDVD
     cBrDokI := brdok
  ELSE
     cBrDokI := space(8)
  ENDIF
  cBrDokI := UBrojDok(val(left(cBrDokI,5))+1,5,right(cBrDokI,3))

  // pocnimo sa generacijom dokumenta
  SELECT KALK
  SEEK cIdFirma+cIdVDU+cBrDokU
  DO WHILE !EOF() .and. cIdFirma+cIdVDU+cBrDokU == IDFIRMA+IDVD+BRDOK
    PushWA()
    Scatter()
    SELECT PRIPR; APPEND BLANK
      _brdok     := cBrDokI
      _datdok    := dDatDok
      _brfaktp   := TRIM(_BrFaktP)+"/STORNO"
      _datkurs   := dDatDok
      _kolicina  := -_kolicina
      _error     := "0"
    Gather()
    SELECT KALK; PopWA()
    SKIP 1
  ENDDO

CLOSERET
return
*}



/*! \fn ImaDok(cDok)
 *  \brief Ispituje postojanje zadanog dokumenta medju azuriranim
 */

function ImaDok(cDok)
*{
LOCAL lVrati:=.f., nArr:=SELECT()
  SELECT DOKS
  HSEEK cDok
  IF FOUND()
    lVrati:=.t.
  ELSE
    MsgBeep("Dokument pod brojem koji ste unijeli ne postoji!")
  ENDIF
  SELECT (nArr)
return lVrati
*}
