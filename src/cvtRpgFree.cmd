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
             CMD        PROMPT('CONVERT RPG/ILE TO FREE-FORM')

             PARM       KWD(FROMMBR) TYPE(*NAME) SPCVAL((*ALL)) MIN(1) +
                          PROMPT('FROM MEMBER')

             PARM       KWD(FROMFILE) TYPE(FRMFILE) PROMPT('FROM FILE')
 FRMFILE:    QUAL       TYPE(*NAME) DFT(QRPGLESRC) SPCVAL((QRPGLESRC)) +
                          EXPR(*YES)
             QUAL       TYPE(*NAME) DFT(*LIBL) SPCVAL((*CURLIB) (*LIBL)) +
                          EXPR(*YES) PROMPT('LIBRARY')

             PARM       KWD(TOFILE) TYPE(TOFILE) PROMPT('TO FILE')
 TOFILE:     QUAL       TYPE(*NAME) LEN(10) DFT(QRPGLESRC)
             QUAL       TYPE(*NAME) DFT(*FROMLIB) SPCVAL((*FROMLIB) +
                          (*CURLIB) (*LIBL)) PROMPT('LIBRARY')

             PARM       KWD(TOMBR) TYPE(*NAME) DFT(*FROMMBR) +
                          SPCVAL((*FROMMBR)) PROMPT('TO MEMBER')


             PARM       KWD(INDCMT) TYPE(*CHAR) LEN(1) RSTD(*YES) DFT(Y) +
                          VALUES(Y N) PMTCTL(*PMTRQS) PROMPT('INDENT +
                          COMMENTS')

             PARM       KWD(RETBLKCMT) TYPE(*CHAR) LEN(1) RSTD(*YES) +
                          DFT(N) VALUES(Y N) CASE(*MONO) PMTCTL(*PMTRQS) +
                          PROMPT('RETAIN BLANK COMMENT MARKERS')

             PARM       KWD(DIRECTIVES) TYPE(*CHAR) LEN(1) RSTD(*YES) +
                          DFT(N) VALUES(Y N) CASE(*MONO) PMTCTL(*PMTRQS) +
                          PROMPT('USE /FREE COMPILER DIRECTIVES')
