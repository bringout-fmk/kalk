#include "\dev\fmk\kalk\kalk.ch"

// prenos tops->kalk 96 po normativima
function tops_nor_96()
*{
local cIdFirma:=gFirma
local cIdTipDok:=PADR("42;",20)
local cBrDok:=SPACE(8)
local cBrKalk:=SPACE(8)
local cIdZaduz2:=SPACE(6)
local cIdkonto2:=PADR("1310",7)
local cIdKonto:=PADR("",7)
local dDatKalk:=DATE()
local cTSifPath
local cTKumPath

O_PRIPR
O_KONCIJ
O_KALK
O_ROBA
O_KONTO
O_PARTN
O_TARIFA
O_SAST

if gBrojac=="D"
	select kalk
 	set order to 1
	seek cIdFirma + "96X"
 	skip -1
 	if idvd<>"96"
   		cBrKalk:=SPACE(8)
 	else
   		cBrKalk:=brdok
 	endif
endif

Box(,10,60)
	if gBrojac=="D"
		cBrKalk:=UBrojDok(VAL(LEFT(cBrKalk,5))+1,5,right(cBrKalk,3))
	endif
	
  	@ m_x+1,m_y+2 SAY "Broj kalkulacije 96 -" GET cBrKalk pict "@!"
	@ m_x+1,col()+2 SAY "Datum:" GET dDatKalk
  	@ m_x+3,m_y+2 SAY "Konto razduzuje :" GET cIdKonto2 pict "@!" valid P_Konto(@cIdKonto2)
  	@ m_x+4,m_y+2 SAY "Konto zaduzuje  :" GET cIdKonto pict "@!" valid P_Konto(@cIdKonto)

	cArtFilter := PADR("2;3;",20)
	cTopsKonto := PADR("1320",7)
  	dDatPOd:=DATE()
  	dDatPDo:=DATE()
  	
	@ m_x+6,m_y+2 SAY "Prodavnicki konto: " GET cTopsKonto PICT "@!" VALID P_Konto(@cTopsKonto)
  	@ m_x+7,m_y+2 SAY "period od" GET dDatPOd
  	@ m_x+7,col()+2 SAY "do" GET dDatPDo
  
	@ m_x+9,m_Y+2  SAY "Vrsta dokumenta kase     :" GET cIdTipDok
  	@ m_x+10,m_Y+2 SAY "Sifre artikala pocinju sa:" GET cArtFilter
  	read
BoxC()

if LastKey()==K_ESC
	return
endif
	
nRBr:=0

// uzmi iz koncija sve potrebne varijable
select koncij
set order to tag "ID"
hseek cTopsKonto
		
if !Found()
	MsgBeep("Ne postoji definisan prod.konto u KONCIJ-u")
	return
endif
		
cTKumPath:=TRIM(field->kumtops)
cIdPos:=field->idprodmjes

// provjeri prodajno mjesto, mora biti popunjeno
if EMPTY(cIdPos)
	MsgBeep("Ne postoji popunjeno prodajno mjesto !")
	return
endif

// provjeri putanju
if EMPTY(cTKumPath)
	MsgBeep("Nisu popunjeni parametri za prodavnicu")
	return
endif
	
AddBs(@cTKumPath)

// provjeri da li postoje fajloci na destinaciji
if (!FILE(cTKumPath+"POS.DBF") .or. !FILE(cTKumPath+"POS.CDX"))
	MsgBeep("Na zadatim lokacijama ne postoje tabele!")
	return
endif
	
// otvori pos
SELECT(249)
USE (cTKumPath+"POS") ALIAS xpos
SET ORDER TO TAG "1"

select xpos
go top
seek cIdPos

nCnt:=0

// box prenosa
Box(,3,60)
@ 1+m_x, 2+m_y SAY "Razbijam po normativima...."

do while !eof() .and. xpos->idpos == cIdPos
	if xpos->idvd $ ALLTRIM(cIdTipDok) .and. xpos->datum >= dDatPOd .and. xpos->datum <= dDatPDo 
		select ROBA
		hseek xpos->idroba
       				
		if !Found()
			select xpos
			skip
			loop
		endif
				
		if (!Empty(cArtFilter) .and. AT(LEFT(roba->id, 1), cArtFilter) == 0)
			select xpos
			skip
			loop
		endif
				
		if roba->tip = "P"  // proizvod je!
			select sast
          		hseek  xpos->idroba
          		do while !eof() .and. id==xpos->idroba 
				select roba
				hseek sast->id2
            			select pripr
            			locate for idroba==sast->id2
            			if found()
              				replace kolicina with kolicina + xpos->kolicina * sast->kolicina
            			else
              				select pripr
              				append blank
              				replace idfirma with gFirma
					replace rbr with str(++nRbr,3)
					replace idvd with "96"
					replace brdok with cBrKalk
					replace datdok with dDatKalk
					replace idtarifa with ROBA->idtarifa
					replace brfaktp with ""
					replace datfaktp with dDatKalk
					replace idkonto with cIdkonto
					replace idkonto2 with cIdkonto2
					replace idzaduz2 with cIdzaduz2
					replace datkurs with dDatKalk
					replace kolicina with xpos->kolicina * sast->kolicina
					replace idroba with sast->id2
					replace nc with ROBA->nc
					replace vpc with xpos->cijena
					//replace rabatv with xpos->ncijena
					//replace mpc with xpos->cijena
            			endif
				
            			@ 2+m_x, 2+m_y SAY "Obradio: " + ALLTRIM(STR(++nCnt))
				select sast
            			skip
          		enddo
		endif 
    	endif  
    	select xpos
    	skip
enddo

BoxC()

if nCnt > 0
	MsgBeep("Razmjena podatka izvrsena, dokument izgenerisan u pripremi!#Obradite ga!")
endif

closeret
return
*}

