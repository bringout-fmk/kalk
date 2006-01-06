/*
 * ----------------------------------------------------------------
 *                                     Copyright Sigma-com software 
 * ----------------------------------------------------------------
 */
 
#ifndef SC_DEFINED
	#include "sc.ch"
#endif

#define D_KA_VERZIJA "02.17"
#define D_KA_PERIOD  "11.94-06.01.06"


#ifndef FMK_DEFINED
	#include "\dev\fmk\af\cl-af\fmk.ch"
#endif

#include "\dev\fmk\kalk\cdx\kalk.ch"

#xcommand CLREZRET   =>  IspitajRezim(); CLOSERET

#define GSCTEMP "c:"+SLASH+"sctemp"+SLASH

#define I_ID 1
