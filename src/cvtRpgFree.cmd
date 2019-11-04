/********************************************************************/
/*Z: CRTCMD CMD(CVTRPGFREE) PGM(CVTRPGFREC)                         */
/*==================================================================*/
/*H: PROGRAMMER: EWARWOOWAR                                         */
/*H: DATE      : 08/05/15                                           */
/*H:                                                                */
/*H: FUNCTION  : CONVERTS AN RPG/ILE FIXED-FORMAT SOURCE TO         */
/*H:             FREE-FORMAT.                                       */
/*H:                                                                */
/*H: CPP       : CVTRPGFREC                                         */
/*H:                                                                */
/********************************************************************/
             CMD        PROMPT('Convert rpg/ile to free-form')

             PARM       KWD(FROMMBR) TYPE(*NAME) SPCVAL((*ALL)) MIN(1) +
                          PROMPT('From member')

             PARM       KWD(FROMFILE) TYPE(FRMFILE) PROMPT('From file')
 FRMFILE:    QUAL       TYPE(*NAME) DFT(QRPGLESRC) SPCVAL((QRPGLESRC)) +
                          EXPR(*YES)
             QUAL       TYPE(*NAME) DFT(*LIBL) SPCVAL((*CURLIB) (*LIBL)) +
                          EXPR(*YES) PROMPT('Library')

             PARM       KWD(TOFILE) TYPE(TOFILE) PROMPT('To file')
 TOFILE:     QUAL       TYPE(*NAME) LEN(10) DFT(QRPGLESRC)
             QUAL       TYPE(*NAME) DFT(*FROMLIB) SPCVAL((*FROMLIB) +
                          (*CURLIB) (*LIBL)) PROMPT('Library')

             PARM       KWD(TOMBR) TYPE(*NAME) DFT(*FROMMBR) +
                          SPCVAL((*FROMMBR)) PROMPT('To member')


             PARM       KWD(INDCMT) TYPE(*CHAR) LEN(1) RSTD(*YES) DFT(Y) +
                          VALUES(Y N) PMTCTL(*PMTRQS) PROMPT('Indent +
                          comments')

             PARM       KWD(RETBLKCMT) TYPE(*CHAR) LEN(1) RSTD(*YES) +
                          DFT(N) VALUES(Y N) CASE(*MONO) PMTCTL(*PMTRQS) +
                          PROMPT('Retain blank comment markers')

             PARM       KWD(DIRECTIVES) TYPE(*CHAR) LEN(1) RSTD(*YES) +
                          DFT(N) VALUES(Y N) CASE(*MONO) PMTCTL(*PMTRQS) +
                          PROMPT('Use /free compiler directives')
