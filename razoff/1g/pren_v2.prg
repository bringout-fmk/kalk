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

static __e_dbf_path
static __e_zip_name


// ---------------------------------------------------------
// prenos podataka na udaljene lokacije (ver.2)
// ova verzija se koristi za prenos u F18
// u ovoj varijanti koristimo sa export dokumenata
// ---------------------------------------------------------
function prenos_v2()
private opc := {}
private opcexe := {}
private izbor := 1

__e_dbf_path := "c:" + SLASH + "sigma" + SLASH + "export" + SLASH 
__e_zip_name := "kalk_exp.zip"

AADD(opc,"1. => export podataka               ")
AADD(opcexe, {|| _kalk_export() })

Menu_SC( "razmjena" )

close all
return


// ----------------------------------------
// export podataka modula KALK
// ----------------------------------------
static function _kalk_export()
local _exported
local _error
local _dat_od, _dat_do, _konta, _vrste_dok, _exp_sif

// uslovi exporta
if !_vars_export( @_dat_od, @_dat_do, @_konta, @_vrste_dok, @_exp_sif )
    return
endif

// pobrisi u folderu tmp fajlove ako postoje
del_exp_files( __e_dbf_path )

// exportuj podatake
_exported := __export( _dat_od, _dat_do, _konta, _vrste_dok, _exp_sif )

// zatvori sve tabele prije operacije pakovanja
close all

altd()

// arhiviraj podatke
if _exported > 0 
   
    // kompresuj ih u zip fajl za prenos
    _error := _compress()

    // sve u redu
    if _error == 0
        
        // pobrisi fajlove razmjene
        del_exp_files( __e_dbf_path )

        // otvori folder sa exportovanim podacima
        open_folder( __e_dbf_path )

    endif

endif

if ( _exported > 0 )
    MsgBeep( "Exportovao " + ALLTRIM(STR( _exported )) + " dokumenta." )
endif

close all
return



// -------------------------------------------
// uslovi exporta dokumenta
// -------------------------------------------
static function _vars_export( dat_od, dat_do, konta, vrste_dok, exp_sif )
local _ret := .f.
local _x := 1

dat_od := DATE() - 30
dat_do := DATE()
konta := PADR( "1320;", 200 )
vrste_dok := PADR( "10;11;", 200 )
exp_sif := "D"

Box(, 9, 70 )

    @ m_x + _x, m_y + 2 SAY "*** Uslovi exporta dokumenata"

    ++ _x
    ++ _x
        
    @ m_x + _x, m_y + 2 SAY "Vrste dokumenata:" GET vrste_dok PICT "@S40"
    
    ++ _x

    @ m_x + _x, m_y + 2 SAY "Datumski period od" GET dat_od
    @ m_x + _x, col() + 1 SAY "do" GET dat_do

    ++ _x
    ++ _x

    @ m_x + _x, m_y + 2 SAY "Uzeti u obzir sljedeca konta:" GET konta PICT "@S30"

    ++ _x
    ++ _x

    @ m_x + _x, m_y + 2 SAY "Eksportovati sifrarnike (D/N) ?" GET exp_sif PICT "@!" VALID exp_sif $ "DN"

    read

BoxC()

// snimi parametre
if LastKey() <> K_ESC

    _ret := .t.
   
endif

return _ret



// -------------------------------------------
// export podataka
// -------------------------------------------
static function __export( dat_od, dat_do, konta, vrste_dok, exp_sif )
local _ret := 0
local _id_firma, _id_vd, _br_dok
local _cnt := 0
local _dat_od, _dat_do, _konta, _vrste_dok, _export_sif
local _usl_mkonto, _usl_pkonto
local _id_partn, _p_konto, _m_konto
local _id_roba

// uslovi za export ce biti...
_dat_od := dat_od
_dat_do := dat_do
_konta := konta
_vrste_dok := vrste_dok
_export_sif := exp_sif

// ? postoji li direktorij
_dir := DIRECTORY( __e_dbf_path )
if LEN( _dir ) == 0
	//msgbeep("Nepostojeci direktorij: " + __e_dbf_path )
	//return 0
endif

// kreiraj tabele exporta
_cre_exp_tbls( __e_dbf_path )

// otvori export tabele za pisanje podataka
_o_exp_tables( __e_dbf_path )

// otvori lokalne tabele za prenos
_o_tables()

Box(, 2, 65 )

@ m_x + 1, m_y + 2 SAY "... export kalk dokumenata u toku"

select doks
set order to tag "1"
go top

do while !EOF()

    _id_firma := field->idfirma
    _id_vd := field->idvd
    _br_dok := field->brdok
    _id_partn := field->idpartner
    _p_konto := field->pkonto
    _m_konto := field->mkonto

    // provjeri uslove ?!??

    // lista konta...
    if !EMPTY( _konta )

        _usl_mkonto := Parsiraj( ALLTRIM(_konta), "mkonto" )
        _usl_pkonto := Parsiraj( ALLTRIM(_konta), "pkonto" )

        if !( &_usl_mkonto )
            if !( &_usl_pkonto )
                skip
                loop
            endif
        endif

    endif

    // lista dokumenata...
    if !EMPTY( _vrste_dok )
        if !( field->idvd $ _vrste_dok )
            skip
            loop
        endif
    endif

    // datumski uslov...
    //if DTOC( _dat_od ) <> ""
        if ( field->datdok < _dat_od )
            skip
            loop
        endif
    //endif

    //if DTOC( _dat_do ) <> ""
        if ( field->datdok > _dat_do )
            skip
            loop
        endif
    //endif

    // ako je sve zadovoljeno !
    // dodaj zapis u tabelu e_doks
    Scatter()
    select e_doks
    append blank
    Gather()

    ++ _cnt
    @ m_x + 2, m_y + 2 SAY PADR(  PADL( ALLTRIM(STR( _cnt )), 6 ) + ". " + "dokument: " + _id_firma + "-" + _id_vd + "-" + ALLTRIM( _br_dok ), 50 )

    // dodaj zapis i u tabelu e_kalk
    select kalk
    set order to tag "1"
    go top
    seek _id_firma + _id_vd + _br_dok

    do while !EOF() .and. field->idfirma == _id_firma .and. field->idvd == _id_vd .and. field->brdok == _br_dok

        // uzmi robu...
        _id_roba := field->idroba

        // upisi zapis u tabelu e_kalk
        Scatter()
        select e_kalk
        append blank
        Gather()

        // uzmi sada robu sa ove stavke pa je ubaci u e_roba
        select roba
        hseek _id_roba
        if FOUND() .and. _export_sif == "D"
            Scatter()
            select e_roba
            set order to tag "ID"
            seek _id_roba
            if !FOUND()
                append blank
                Gather()
            endif
        endif

        // idi dalje...
        select kalk
        skip

    enddo

    // e sada mozemo komotno ici na export partnera
    select partn
    hseek _id_partn 
    if FOUND() .and. _export_sif == "D"
        Scatter()
        select e_partn
        set order to tag "ID"
        seek _id_partn
        if !FOUND()
            append blank
            Gather()
        endif
    endif

    // i konta, naravno

    // prvo M_KONTO
    select konto
    hseek _m_konto 
    if FOUND() .and. _export_sif == "D"
        Scatter()
        select e_konto
        set order to tag "ID"
        seek _m_konto
        if !FOUND()
            append blank
            Gather()
        endif
    endif

    // zatim P_KONTO
    select konto
    hseek _p_konto 
    if FOUND() .and. _export_sif == "D"
        Scatter()
        select e_konto
        set order to tag "ID"
        seek _p_konto
        if !FOUND()
            append blank
            Gather()
        endif
    endif

    select doks
    skip

enddo

BoxC()

if ( _cnt > 0 )
    _ret := _cnt
endif

return _ret


// ----------------------------------------
// kreiranje tabela razmjene
// ----------------------------------------
static function _cre_exp_tbls( use_path )
local _cre 

if use_path == NIL
    use_path := PRIVPATH
endif

// tabela kalk
O_KALK
copy structure extended to ( PRIVPATH + "struct" )
use
create ( use_path + "e_kalk") from ( PRIVPATH + "struct")

// tabela doks
O_DOKS
copy structure extended to ( PRIVPATH + "struct" )
use
create ( use_path + "e_doks") from ( PRIVPATH + "struct")

// tabela roba
O_ROBA
copy structure extended to ( PRIVPATH + "struct" )
use
create ( use_path + "e_roba") from ( PRIVPATH + "struct")

// tabela partn
O_PARTN
copy structure extended to ( PRIVPATH + "struct" )
use
create ( use_path + "e_partn") from ( PRIVPATH + "struct")

// tabela partn
O_PARTN
copy structure extended to ( PRIVPATH + "struct" )
use
create ( use_path + "e_partn") from ( PRIVPATH + "struct")

// tabela konta
O_KONTO
copy structure extended to ( PRIVPATH + "struct" )
use
create ( use_path + "e_konto") from ( PRIVPATH + "struct")


return


// ----------------------------------------------------
// otvaranje potrebnih tabela za prenos
// ----------------------------------------------------
static function _o_tables()

O_KALK
O_DOKS
O_SIFK
O_SIFV
O_KONTO
O_PARTN
O_ROBA

return



// ----------------------------------------------------
// otvranje export tabela
// ----------------------------------------------------
static function _o_exp_tables( use_path )

if ( use_path == NIL )
    use_path := PRIVPATH
endif

// zatvori sve prije otvaranja ovih tabela
close all

// otvori kalk tabelu
select ( 240 )
use ( use_path + "e_kalk" ) alias "e_kalk"
index on ( idfirma + idvd + brdok ) tag "1"

// otvori doks tabelu
select ( 241 )
use ( use_path + "e_doks" ) alias "e_doks"
index on ( idfirma + idvd + brdok ) tag "1"

// otvori roba tabelu
select ( 242 )
use ( use_path + "e_roba" ) alias "e_roba"
index on ( id ) tag "ID"

// otvori partn tabelu
select ( 243 )
use ( use_path + "e_partn" ) alias "e_partn"
index on ( id ) tag "ID"

// otvori konto tabelu
select ( 244 )
use ( use_path + "e_konto" ) alias "e_konto"
index on ( id ) tag "ID"

return



// ----------------------------------------------------
// vraca listu fajlova koji se koriste kod prenosa
// ----------------------------------------------------
static function _file_list( use_path )
local _a_files := {} 

AADD( _a_files, use_path + "e_kalk.dbf" )
AADD( _a_files, use_path + "e_doks.dbf" )
AADD( _a_files, use_path + "e_roba.dbf" )
AADD( _a_files, use_path + "e_roba.fpt" )
AADD( _a_files, use_path + "e_partn.dbf" )
AADD( _a_files, use_path + "e_konto.dbf" )

_creListFile( _a_files )

return _a_files



// ---------------------------------------------------
// brise temp fajlove razmjene
// ---------------------------------------------------
static function del_exp_files( use_path )
local _files := _file_list( use_path )
local _i, _tmp, _file

MsgO( "Brisem tmp fajlove ..." )

for _i := 1 TO LEN( _files )
    _file := _files[ _i ]
    if FILE( _file )
        // pobrisi dbf fajl
        FERASE( _file )
        // cdx takodjer ?
        _tmp := STRTRAN( _file, ".dbf", ".cdx" )
        FERASE( _tmp )
        // fpt takodjer ?
        _tmp := STRTRAN( _file, ".dbf", ".fpt" )
        FERASE( _tmp )
    endif
next
MsgC()

return


// --------------------------------------------
// vraca naziv zip fajla
// --------------------------------------------
static function zip_name()
local _file 
local _ext := ".zip"
local _count := 1
local _exist := .t.

_file := __e_dbf_path + "kalk_e" + PADL( ALLTRIM(STR( _count )), 2, "0" ) + _ext 
if FILE( _file )
    
    // generisi nove nazive fajlova
    do while _exist 

        ++ _count
        _file := __e_dbf_path + "kalk_e" + PADL( ALLTRIM(STR( _count )), 2, "0" ) + _ext 

        if !FILE( _file )
            _exist := .f.
            exit
        endif

    enddo

endif

return _file



// ------------------------------------------
// kompresuj fajlove i vrati path 
// ------------------------------------------
static function _compress()
local _error := 0
local _zip_f
local _files
local _screen
private _cmd

_files := _file_list( __e_dbf_path )
_zip_f := zip_name()

_cmd := "zip " + _zip_f + " " + "@" + PRIVPATH + "zip_lst.txt & pause"

save screen to _screen

run &_cmd

restore screen from _screen

return _error



// ---------------------------------------------
// kreiranje list fajla za prenos
// ---------------------------------------------
static function _creListFile( a_files )
local nH, cFileName, i

cFileName := PRIVPATH + "zip_lst.txt"

// Kreiraj file
if ( nH := fcreate(cFileName)) == -1
   Beep(4)
   Msg( "Greska pri kreiranju fajla: " + cFileName + " !", 6 )
   return -1
endif

fclose( nH )

// Otvori file za upis
set printer to (cFileName)
set printer on
set console off

for i := 1 to LEN( a_files )
	? a_files[i]
next
   
// Zatvori file
set printer to
set printer off
set console on

return 0




