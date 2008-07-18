#include "kalk.ch"

/*
 * ----------------------------------------------------------------
 *                                     Copyright Sigma-com software 
 * ----------------------------------------------------------------
 */


/*! \file fmk/kalk/vt/1g/ut.prg
 *  \brief Visokotarifni artikli
 */

/*! \fn VtPorezi()
 *  \brief Porezi za visokotarifne artikle
 */
 
function VTPOREZI()
*{
public _ZPP:=0

public _OPP:=tarifa->opp/100
public _PPP:=tarifa->ppp/100
public _ZPP:=tarifa->zpp/100
public _PORVT:=0
public _MPP   := 0
public _DLRUC := 0

if !IsPdv()

if tarifa->(FIELDPOS("MPP")<>0)
	public _MPP   := tarifa->mpp/100
	public _DLRUC := tarifa->dlRuc/100
else
	public _MPP   := 0
	public _DLRUC := 0
endif

endif

return
*}


function SetStPor_()
*{
public _ZPP:=0

// ovo je stopa PDV-a
public _PDV:=tarifa->opp/100
// posebni porez na potrosnju
public _PP:=tarifa->zpp/100

//ovo dole se ne koristi ali ako negdje trazi ove stare varijable ostaviti
public _OPP:=tarifa->opp/100
public _PPP:=tarifa->ppp/100
public _ZPP:=tarifa->zpp/100
public _PORVT :=0
public _MPP   := 0
public _DLRUC := 0

return
*}


