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
 * $Source: c:/cvsroot/cl/sigma/fmk/kalk/adm/1g/set_m10.prg,v $
 * $Author: mirsad $ 
 * $Revision: 1.2 $
 * $Log: set_m10.prg,v $
 * Revision 1.2  2002/06/18 14:02:38  mirsad
 * dokumentovanje (priprema za doxy)
 *
 *
 */

/*! \file fmk/kalk/adm/1g/set_m10.prg
 *  \brief Setovanje marze u dokumentu tipa 10 koji se nalazi u pripremi
 */

/*! \fn SetMarza10()
 *  \brief Setovanje marze u dokumentu tipa 10 koji se nalazi u pripremi
 */

function SetMarza10()
*{
if !SigmaSif("BERINA")
 return
endif

nMarza:=2

Box(,3,60)
	@ m_x+1,m_y+2 SAY "Iznos marze " GET nMarza pict "999999.99"
	read
BoxC()

O_PRIPR
go top 

if !(IDVD=="10")
  return
endif

nDif:=0
nVPC:=0

do while !eof()
	nVPC:=(pripr->NC+nMarza)
	nDif:=nVPC-ROUND(nVPC,0)
	replace TMarza with "A", Marza with nMarza-nDif, VPC with pripr->NC+nMarza-nDif
	skip
enddo

return
*}

