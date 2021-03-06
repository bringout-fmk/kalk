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
 * $Source: c:/cvsroot/cl/sigma/fmk/kalk/adm/1g/gen_9999.prg,v $
 * $Author: mirsad $ 
 * $Revision: 1.2 $
 * $Log: gen_9999.prg,v $
 * Revision 1.2  2002/06/18 14:02:38  mirsad
 * dokumentovanje (priprema za doxy)
 *
 *
 */

/*! \file fmk/kalk/adm/1g/gen_9999.prg
 *  \brief Generisanje zbirne baze dokumenata u specijalnoj sezoni 9999
 */

/*! \fn Gen9999()
 *  \brief Generisanje zbirne baze dokumenata u specijalnoj sezoni 9999
 */
 
function Gen9999()
*{  
  if !(gRadnoPodr=="9999")  // sezonsko kumulativno podrucje za zbirne izvještaje
  	MsgBeep("Ova operacija se radi u 9999 podrucju")
	return
  endif
  
  nG0:=nG1:=YEAR(DATE())
  Box("#Generacija zbirne baze dokumenata",5,75)
   @ m_x+2, m_y+2 SAY "Od sezone:" GET nG0 VALID nG0>0.and.nG1>=nG0 PICT "9999"
   @ m_x+3, m_y+2 SAY "do sezone:" GET nG1 VALID nG1>0.and.nG1>=nG0 PICT "9999"
   READ; ESC_BCR
  BoxC()

  // spaja se sve izuzev dokumenata 16 i 80 na dan 01.01.XX gdje XX oznacava
  // sve sezone izuzev pocetne
  // -----------------------------------------------------------------------

CLOSERET
*}
