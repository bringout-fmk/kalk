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

external RIGHT

/*
 * ----------------------------------------------------------------
 *                          Copyright Sigma-com software 1994-2006 
 * ----------------------------------------------------------------
 */
 

/*! \file fmk/kalk/main/1g/e.prg
 *  \brief
 */


#ifdef LIB

/*! \fn Main(cKorisn,cSifra,p3,p4,p5,p6,p7)
 *  \brief
 */

function Main(cKorisn,cSifra,p3,p4,p5,p6,p7)
*{
	MainKalk(cKorisn,cSifra,p3,p4,p5,p6,p7)
return
*}

#endif



/*! \fn MainKALK(cKorisn,cSifra,p3,p4,p5,p6,p7)
 *  \brief
 */

function MainKALK(cKorisn,cSifra,p3,p4,p5,p6,p7)
*{
local oKalk

oKalk:=TKalkModNew()
cModul:="KALK"

PUBLIC goModul

goModul:=oKalk
oKalk:init(NIL, cModul, D_KA_VERZIJA, D_KA_PERIOD , cKorisn, cSifra, p3,p4,p5,p6,p7)

oKalk:run()

return 
*}

