/*
 * ----------------------------------------------------------------
 *                           Copyright Sigma-com software 1998-2006 
 * ----------------------------------------------------------------
 */
 
#ifndef SC_DEFINED
	#include "sc.ch"
#endif

#define D_KA_VERZIJA "02.75"
#define D_KA_PERIOD  "11.94-15.09.06"


#ifndef FMK_DEFINED
	#include "\dev\fmk\af\cl-af\fmk.ch"
#endif

#include "\dev\fmk\kalk\cdx\kalk.ch"

#xcommand CLREZRET   =>  IspitajRezim(); CLOSERET

#define GSCTEMP "c:"+SLASH+"sctemp"+SLASH

#define I_ID 1
