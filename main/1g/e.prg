#include "\dev\fmk\kalk\kalk.ch"

/*! \defgroup ini Parametri rada programa - fmk.ini
 *  @{
 *  @}
 */
 
/*! \defgroup params Parametri rada programa - *param.dbf
 *  @{
 *  @}
 */

/*! \defgroup TblZnacenjePolja Tabele - znacenje pojedinih polja
 *  @{
 *  @}
 */


/*
 * ----------------------------------------------------------------
 *                                     Copyright Sigma-com software 
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

