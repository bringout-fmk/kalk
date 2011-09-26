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
 * $Source: c:/cvsroot/cl/sigma/fmk/kalk/prod/gendok/1g/pst.prg,v $
 * $Author: sasa $ 
 * $Revision: 1.5 $
 * $Log: pst.prg,v $
 * Revision 1.5  2003/01/03 15:52:47  sasa
 * ispravka pocetnog stanja
 *
 * Revision 1.4  2003/01/03 15:15:27  sasa
 * ispravka pocetnog stanja
 *
 * Revision 1.3  2003/01/03 11:06:34  sasa
 * Ispravka greske sa pocetnim stanjem gSezona->goModul:oDataBase:cSezona
 *
 * Revision 1.2  2002/06/21 09:24:55  mirsad
 * no message
 *
 *
 */
 

/*! \file fmk/kalk/prod/gendok/1g/pst.prg
 *  \brief Generisanje dokumenta pocetnog stanja prodavnice
 */


/*! \fn PocStProd()
 *  \brief Generisanje dokumenta pocetnog stanja prodavnice
 */

function PocStProd()
*{
LLP(.t.)
if !empty(goModul:oDataBase:cSezonDir) .and. Pitanje(,"Prebaciti dokument u radno podrucje","D")=="D"
	O_PRIPRRP
          O_PRIPR
          if reccount2()<>0
           select priprrp
           append from pripr
           select pripr; zap
           close all
           if Pitanje(,"Prebaciti se na rad sa radnim podrucjem ?","D")=="D"
               URadPodr()
           endif
          endif
endif
close all

return nil
*}





