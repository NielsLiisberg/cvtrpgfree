*FREE
       Ctl-Opt Debug
               DftActGrp( *No ) ActGrp( *Caller )
               Option( *ShowCpy: *SrcStmt: *NoDebugIO );

       //-------------------------------------------------------------------------------------------
       // Program Name. . . . . : CVTRPGFREE
       // Program Description . : Convert RPGILE Source Member to Free-form
       // Date Created. . . . . : 30/04/2015
       // Programmer. . . . . . : Ewarwoowar
       //-------------------------------------------------------------------------------------------
       // SYNOPSIS :
       // - Reads through an RPGILE source member and reformats the contents.
       //-------------------------------------------------------------------------------------------
      /Eject
       //-------------------------------------------------------------------------------------------
       // F I L E S
       //-------------------------------------------------------------------------------------------
       Dcl-F QRPGLESRC              EXTMBR(ØpFromMbr)
                                    EXTFILE('QTEMP/QRPGLESRC')
                                    RENAME(QRPGLESRC:SRCREC)
                                    USROPN;

       Dcl-F QRPGLESRC2             Usage(*OUTPUT) EXTMBR(ØpToMbr)
                                    EXTFILE('QTEMP/QRPGLESRC2')
                                    RENAME(QRPGLESRC2:OUTREC)
                                    USROPN;

       Dcl-F CVTRPGFRP1     PRINTER USROPN
                                    OFLIND(overFlow);

       //-------------------------------------------------------------------------------------------
       // P R O C E D U R E   I N T E R F A C E
       //-------------------------------------------------------------------------------------------

       Dcl-PR CVTRPGFREE               EXTPGM('CVTRPGFREE');
          ØpShutDown               Char(1) CONST;
          ØpFromFile               Char(10) CONST;
          ØpFromLib                Char(10) CONST;
          ØpFromMember             Char(10) CONST;
          ØpToFile                 Char(10) CONST;

          ØpToLib                  Char(10) CONST;
          ØpToMbr                  Char(10) CONST;
          ØpIndComment             Char(1) CONST;
          ØpRetBlnkCmt             Char(1) CONST;
          ØpDirectives             Char(1) CONST;
       End-PR;

       Dcl-PI CVTRPGFREE;
          ØpShutDown               Char(1) CONST;
          ØpFromFile               Char(10) CONST;
          ØpFromLib                Char(10) CONST;
          ØpFromMbr                Char(10) CONST;
          ØpToFile                 Char(10) CONST;
          ØpToLib                  Char(10) CONST;
          ØpToMbr                  Char(10) CONST;
          ØpIndComment             Char(1) CONST;
          ØpRetBlnkCmt             Char(1) CONST;
          ØpDirectives             Char(1) CONST;
       End-PI;

       //-------------------------------------------------------------------------------------------
       // P R O T O T Y P E   I N T E R F A C E S
       //-------------------------------------------------------------------------------------------
       Dcl-PR GetDeclarationType;
          ØpDeclType               Char( 2 );
          ØpSavedName              Char( 80 );
          ØpDeclLine                        Like(SRCSEQ);
       End-PR;

       //-------------------------------------------------------------------------------------------
       // N A M E D   C O N S T A N T S
       //-------------------------------------------------------------------------------------------
       Dcl-C LO                        'abcdefghijklmnopqrstuvwxyz';
       Dcl-C UP                        'ABCDEFGHIJKLMNOPQRSTUVWXYZ';
       Dcl-C VALIDSPECS                'HFDCP';

       //-------------------------------------------------------------------------------------------
       // D A T A   S T R U C T U R E S
       //-------------------------------------------------------------------------------------------

       Dcl-DS SourceData;
          SRCDTA                   Char(100);
          prefix                   Char(5) OVERLAY(SRCDTA:1);
          lineType                 Char(1) OVERLAY(SRCDTA:6);
          directive                Char(10) OVERLAY(SRCDTA:7);
          codeLine                 Char(93) OVERLAY(SRCDTA:8);
          fullLine                 Char(94) OVERLAY(SRCDTA:7);

          condNot                  Char(1) OVERLAY(SRCDTA:9);
          condInd                  Char(2) OVERLAY(SRCDTA:10);
          factor1                  Char(14) OVERLAY(SRCDTA:12);
          opCode                   Char(10) OVERLAY(SRCDTA:26);
          factor2                  Char(14) OVERLAY(SRCDTA:36);
          result                   Char(14) OVERLAY(SRCDTA:50);
          len                      Char(5) OVERLAY(SRCDTA:64);
          dec                      Char(2) OVERLAY(SRCDTA:69);
          hi                       Char(2) OVERLAY(SRCDTA:71);
          lw                       Char(2) OVERLAY(SRCDTA:73);
          eq                       Char(2) OVERLAY(SRCDTA:75);
          comment                  Char(20) OVERLAY(SRCDTA:81);

          extFactor2               Char(45) OVERLAY(SRCDTA:36);

          nonPrefix                Char(95) OVERLAY(SRCDTA:6);

          procType                 Char(1) OVERLAY(SRCDTA:24);
          procKeyWords             Char(37) OVERLAY(SRCDTA:44);

          declName                 Char(15) OVERLAY(SRCDTA:7);
          declExt                  Char(1) OVERLAY(SRCDTA:22);
          declPrefix               Char(1) OVERLAY(SRCDTA:23);
          declType                 Char(2) OVERLAY(SRCDTA:24);
          declSuffix               Char(1) OVERLAY(SRCDTA:26);
          declFrom                 Char(7) OVERLAY(SRCDTA:26);
          declLen                  Char(7) Overlay(SRCDTA:33);
          declAttr                 Char(1) Overlay(SRCDTA:40);
          declScale                Char(3) Overlay(SRCDTA:41);
          declKeyWords             Char(37) OVERLAY(SRCDTA:44);
          declOptions              Char(73) Overlay(SRCDTA:7);

          FileSpec                 Char(100) Overlay(SRCDTA:1);
          fileName                 Char(10) Overlay(FileSpec:7);
          fileUsage                Char(1) Overlay(FileSpec:17);
          fileDesig                Char(1) Overlay(FileSpec:18);
          fileAdd                  Char(1) Overlay(FileSpec:20);
          fileExternal             Char(1) Overlay(FileSpec:22);
          fileKeyed                Char(1) Overlay(FileSpec:34);
          fileDevice               Char(7) Overlay(FileSpec:36);
          fileKeywords             Char(37) Overlay(FileSpec:44);
       End-DS;

       // Display file indicators ------------------------------------------------------------------
       Dcl-DS IndicatorDS;
        // 01-30: Function keys
        // 31-59: Conditioning indicators (error)
        // 60-89: Conditioning indicators (non-error)
        // 90-99: General indicators
       // Report file indicators -------------------------------------------------------------------
        // 01-79: Conditioning indicators (non-error)
          cndIndicators             Ind Pos(01) DIM(79);
        // 80-89: Report control
          overFlow                  Ind Pos(80);
        // 90-99: General indicators
          errorInd                  Ind Pos(99) INZ(*OFF);                  // Global error
       End-DS;

       Dcl-DS DCLPR                    QUALIFIED;
          decl                     Char(7) INZ('Dcl-PR ');
          procName                 Char(16);
          type                     Char(9);
          definition               Char(37);
          comment                  Char(23);
          fieldName                Char(23) Pos(4);
       End-DS;

       Dcl-DS DCLP                     QUALIFIED;                           // Test comment
          decl                     Char(9) INZ('Dcl-Proc ');
          definition               Char(61);
          comment                  Char(23);
       End-DS;

       Dcl-DS DCLS                     QUALIFIED;
          decl                     Char(6) INZ('Dcl-S ');
          fieldName                Char(17);
          type                     Char(9);
          definition               Char(37);
          comment                  Char(23);
       End-DS;

       Dcl-DS DCLF                     QUALIFIED;
          decl                     Char(6) INZ('Dcl-F ');
          fileName                 Char(15);
          device                   Char(8);
          definition               Char(44);
          comment                  Char(23) Pos(70);
       End-DS;

       Dcl-DS DCLH                     QUALIFIED;
          decl                     Char(8) INZ('Ctl-Opt ');
          options                  Char(62);
          comment                  Char(23);
       End-DS;

       //-------------------------------------------------------------------------------------------
       // S T A N D - A L O N E   V A R I A B L E S
       //-------------------------------------------------------------------------------------------
       // Template variables (required - do not alter).
       Dcl-S cfgCommitControl                                               // Test comment
                                   Char(7) INZ('*SLAVE ');                  // *MASTER/*SLAVE
       Dcl-S cfgCloseDown          Char(1) INZ('N');                        // Close down program?
       Dcl-S initialCall           Char(1) INZ(*Blank);

       // End of Template variables (required - do not alter).
       //-------------------------------------------------------------------------------------------
       Dcl-S ØopCodeUP             Char(10) DIM(66) PERRCD(1) CTDATA;
       Dcl-S ØopCodeLO             Char(10) DIM(66) ALT(ØopCodeUP);
       Dcl-S ØdeclUP               Char(10) DIM(12) PERRCD(1) CTDATA;
       Dcl-S ØdeclLO               Char(10) DIM(12) ALT(ØdeclUP);
       Dcl-S Øcomments             Char(92) DIM(3) CTDATA;
       Dcl-S x                   Packed(3:0);
       Dcl-S y                   Packed(3:0);
       Dcl-S i                   Packed(3:0);
       Dcl-S j                   Packed(3:0);
       Dcl-S blanks                Char(30) INZ(*Blanks);
       Dcl-S maxIndent           Packed(3:0) INZ(15);
       Dcl-S movedDefs                 LIKE(result) DIM(999);
       Dcl-S moveDef                Ind INZ(*Off);

       Dcl-S fromFileLib           Char(21);
       Dcl-S toFileLib             Char(21);

       Dcl-S operator              Char(10);
       Dcl-S operatorEnd         Packed(3:0);
       Dcl-S newOperator        VarChar(10);
       Dcl-S nonConvRsn                LIKE(codeLine);

       Dcl-S inCode                 Ind INZ(*Off);
       Dcl-S inArrayData            Ind INZ(*Off);
       Dcl-S inComment              Ind INZ(*Off);
       Dcl-S inDeclaration          Ind INZ(*Off);
       Dcl-S inPrototype            Ind INZ(*Off);
       Dcl-S inInterface            Ind INZ(*Off);
       Dcl-S inDatastructure
                                    Ind INZ(*Off);
       Dcl-S inExtProc              Ind INZ(*Off);
       Dcl-S endDS                  Ind INZ(*Off);
       Dcl-S inDirective            Ind INZ(*Off);
       Dcl-S inFreeFormat           Ind INZ(*On);
       Dcl-S inDeclProc             Ind INZ(*Off);
       Dcl-S indent                 Ind INZ(*Off);
       Dcl-S inSpan                 Ind INZ(*Off);
       Dcl-S inCase                 Ind INZ(*Off);
       Dcl-S convert                Ind INZ(*Off);
       Dcl-S unindent               Ind INZ(*Off);
       Dcl-S defsMoved              Ind INZ(*Off);
       Dcl-S dropLine               Ind INZ(*Off);
       Dcl-S codeStart                 LIKE(SRCSEQ) INZ(0);
       Dcl-S endLine                   LIKE(SRCSEQ) INZ(0);                 // Close struct here.
       Dcl-S endFound               Ind;
       Dcl-S endDeclType           Char(2);

       Dcl-S savedLineType         Char(1);

       Dcl-S increment           Packed(1:0) INZ(0);
       Dcl-S indentCount         Packed(3:0) INZ(0);
       Dcl-S indentSize          Packed(1:0) INZ(3);
       Dcl-S indentOffset        Packed(3:0) INZ(0);
       Dcl-S prevOffset          Packed(3:0) INZ(0);
       Dcl-S currOffset          Packed(3:0) INZ(0);
       Dcl-S lineEnd             Packed(3:0) INZ(0);
       Dcl-S mainlineIndent      Packed(3:0) INZ(1);

       Dcl-S savedSRCDTA               LIKE(SRCDTA);
       Dcl-S sourceLine            Char(93);
       Dcl-S overflowLine       VarChar(92);
       Dcl-S workDirective         Char(10);
       Dcl-S workLineType          Char(1);
       Dcl-S workDeclType          Char(2);
       Dcl-S workDeclAttr          Char(1);
       Dcl-S workDeclName          Char(50);
       Dcl-S workDeclLine              LIKE(SRCSEQ);
       Dcl-S workDeclKeywords   VarChar(92);

       Dcl-S tempDeclType          Char(2);
       Dcl-S tempDeclLine              LIKE(SRCSEQ);
       Dcl-S tempSavedName         Char(80);

       Dcl-S workFileUsage         Char(1);
       Dcl-S workFileDesig         Char(1);
       Dcl-S workFileAdd           Char(1);
       Dcl-S workFileKeyed         Char(1);
       Dcl-S workFileDevice        Char(7);
       Dcl-S checkLength         Packed(3:0);
       Dcl-S workLength          Packed(7:0);

       Dcl-S savedComment          Char(20);
       Dcl-S savedName             Char(80);

       Dcl-S padResult              Ind INZ(*Off);
       Dcl-S padTarget                 LIKE(result);

       Dcl-S scanString                LIKE(factor1);
       Dcl-S scanBase                  LIKE(factor2);
       Dcl-S scanLength            Char(10);
       Dcl-S scanStart             Char(10);
       Dcl-S scanNoResult           Ind INZ(*Off);

       Dcl-S substLen              Char(10);
       Dcl-S substStart            Char(10);

       Dcl-S setOff                 Ind INZ(*Off);
       Dcl-S setOffInd1            Char(2);
       Dcl-S setOffInd2            Char(2);
       Dcl-S setOffInd3            Char(2);

       Dcl-S setOn                  Ind INZ(*Off);
       Dcl-S setOnInd1             Char(2);
       Dcl-S setOnInd2             Char(2);
       Dcl-S setOnInd3             Char(2);

       Dcl-S xlateFrom                 LIKE(factor1);
       Dcl-S xlateTo                   LIKE(factor1);
       Dcl-S xlateBase                 LIKE(factor2);
       Dcl-S xlateStart            Char(10);

       Dcl-S caseSubRoutine        Char(10);
       Dcl-S caseOperator          Char(4);

       Dcl-S catFactor1                LIKE(factor1);
       Dcl-S catFactor2                LIKE(factor2);
       Dcl-S catCount            Packed(3:0) INZ(0);
       Dcl-S catBlanks                 LIKE(factor2);

       Dcl-S durDuration               LIKE(factor2);
       Dcl-S durCode                   LIKE(factor2);
       Dcl-S durNewDate             Ind INZ(*Off);

       Dcl-S inEval                 Ind INZ(*Off);
       Dcl-S evalOperator              Like(opCode);
       Dcl-S evalOffset          Packed(3:0);

       Dcl-S inCallP                Ind INZ(*Off);
       Dcl-S callPOperator             Like(opCode);
       Dcl-S callPOffset         Packed(3:0);

       Dcl-S inDo                   Ind INZ(*Off);
       Dcl-S doOperator                Like(opCode);
       Dcl-S doCompare             Char(2);

       Dcl-S inIf                   Ind INZ(*Off);
       Dcl-S ifOperator                Like(opCode);
       Dcl-S ifCompare             Char(2);

       Dcl-S inWhen                 Ind INZ(*Off);
       Dcl-S whenOperator              Like(opCode);
       Dcl-S whenCompare           Char(2);

       Dcl-S inSQL                  Ind INZ(*Off);

       Dcl-S forCount            Packed(3:0) INZ(0);
       Dcl-S forLevel            Packed(3:0) DIM(99);                          // Allow for 99
       Dcl-S forFactor1                LIKE(factor1);
       Dcl-S forFactor2                LIKE(factor2);

       Dcl-S doCount             Packed(3:0) INZ(0);
       Dcl-S doLevel             Packed(3:0) DIM(99);                          // Allow for 99

       Dcl-S slCount             Packed(3:0) INZ(0);
       Dcl-S slLevel             Packed(3:0) DIM(99);                          // Allow for 99

       Dcl-S divFactor1                LIKE(factor1);
       Dcl-S divFactor2                LIKE(factor2);

       Dcl-S ERRCheck               Ind INZ(*Off);
       Dcl-S ERRInd                Char(2);

       Dcl-S foundCheck             Ind INZ(*Off);
       Dcl-S foundInd              Char(2);

       Dcl-S NRFCheck               Ind INZ(*Off);
       Dcl-S NRFInd                Char(2);
       Dcl-S NRFFile                   LIKE(factor2);

       Dcl-S EOFCheck               Ind INZ(*Off);
       Dcl-S EOFInd                Char(2);
       Dcl-S EOFFile                   LIKE(factor2);

       Dcl-S HICheck                Ind INZ(*Off);
       Dcl-S HIInd                 Char(2);
       Dcl-S HiFactor1                 LIKE(factor1);
       Dcl-S HiFactor2                 LIKE(factor2);

       Dcl-S LWCheck                Ind INZ(*Off);
       Dcl-S LWInd                 Char(2);
       Dcl-S LWFactor1                 LIKE(factor1);
       Dcl-S LWFactor2                 LIKE(factor2);

       Dcl-S EQCheck                Ind INZ(*Off);
       Dcl-S EQInd                 Char(2);
       Dcl-S EQFactor1                 LIKE(factor1);
       Dcl-S EQFactor2                 LIKE(factor2);

       Dcl-S equalCheck             Ind INZ(*Off);
       Dcl-S equalInd              Char(2);

       Dcl-S countSource         Packed(7:0) INZ(0);
       Dcl-S countTarget         Packed(7:0) INZ(0);
       Dcl-S countEligible       Packed(7:0) INZ(0);
       Dcl-S countConv           Packed(7:0) INZ(0);
       Dcl-S countNotConv        Packed(7:0) INZ(0);
       Dcl-S countMoved          Packed(7:0) INZ(0);

       //Dcl-S testb                   BinDec(2:0);
      /Eject
       //-------------------------------------------------------------------------------------------
       // Main Procedure
       //-------------------------------------------------------------------------------------------
          // Initialize
          Exsr subInitialise;

          // Perform required function
          Exsr subUserFunction;

          // Terminate the program.
          Exsr subExitProgram;
       //-------------------------------------------------------------------------------------------

      /Eject
       //-------------------------------------------------------------------------------------------
       // USER: Perform required function.
       //-------------------------------------------------------------------------------------------
       BegSr subUserFunction;

          // ** Code the necessary processing here.
          // >>>>> Start of User-Point >>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>

          // Read through the source member.
          Read SRCREC;

          DoW not %eof(QRPGLESRC);
             countSource += 1;

             Exsr subUserReformatLine;

             Exsr subUserSetIndicators;

             // Old-style SCAN without a result field.
             If scanNoResult;
                Clear nonPrefix;

                codeLine = '// Old-style SCAN without a result!';
                Exsr subUserReformatLine;
                codeLine = 'EndIf;';
                Exsr subUserReformatLine;

                scanNoResult = *Off;
             EndIf;

             // If in a CAS statement, record the subroutine to call.
             If inCase and caseSubroutine <> *Blanks;
                codeLine = 'ExSr ' + %trim(caseSubRoutine) + ';';
                Exsr subUserReformatLine;
                caseSubRoutine = *Blanks;
             EndIf;

             Read SRCREC;
          EndDo;

          // Handle overflow.
          If overFlow;

             // Print page headings.
             Z1ÅPAG += 1;
             Write Z1PAGHDG;

             ZTFRFL = fromFileLib;
             ZTTOFL = toFileLib;

             Write Z1TOPPAG;

             overFlow = *Off;
          EndIf;

          Z1FRMB = ØpFromMbr;
          Z1TOMB = ØpToMbr;
          Z1CTSC = countSource;
          Z1CTTG = countTarget;
          Z1CTEL = countEligible;
          Z1CTCV = countConv;
          Z1CTNV = countNotConv;
          Z1CTMV = countMoved;
          If countEligible = 0;
             Z1CNVR = 0;
          Else;
             Z1CNVR = countConv * 100 / countEligible;
          EndIf;

          // Print detail format.
          Write Z1DETAIL;

          // <<<<< End of User-Point   <<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<

       EndSr;
       //-------------------------------------------------------------------------------------------

      /Eject
       //-------------------------------------------------------------------------------------------
       // Perform conversion/reformatting on the current line.
       //-------------------------------------------------------------------------------------------
       BegSr subUserReformatLine;

          inDirective = *Off;
          inComment = *Off;
          increment = 0;

          workDirective = %xlate(lo:up:directive);
          workLineType = %xlate(lo:up:lineType);

          convert = *Off;
          nonConvRsn = *Blanks;

          sourceLine = codeLine;     // Start with what is already there.

          // Array data reached?
          If %subst(prefix:1:3) = '** '
          or %subst(SRCDTA:1:8) = '**CTDATA';
             inCode = *Off;
             inDeclaration = *Off;
             inArrayData = *On;
          EndIf;

          If not inArrayData;
             //----------------------------------------------------------------------------------
             // Determine Line Type
             If workLineType = 'C';                  // C-Spec
                inCode = *On;
                //         ElseIf workLineType = 'P'               // P-Spec
                //             or %len(%trim(codeLine)) >= 4
                //            and %xlate(lo:up:%subst(%trim(codeLine):1:4)) = 'DCL-';
                //            inCode = *Off;
                //            defsMoved = *Off;
             ElseIf workLineType = 'P';              // P-Spec
                inCode = *Off;
                defsMoved = *Off;
             ElseIf workLineType = 'D';              // Declaration.
                inCode = *Off;
             ElseIf workLineType = 'H';              // Header spec.
                inCode = *Off;
             ElseIf workLineType = 'F';              // File spec.
                inCode = *Off;
             ElseIf workLineType = 'O';              // O-Spec
                inCode = *Off;
             ElseIf workLineType = 'I';              // I-Spec
                inCode = *On;
             ElseIf %check(validSpecs:workLineType) <> 0;    // Invalid spec type.
                workLineType = *Blanks;
                lineType = *Blank;                           // Clear it!
             EndIf;

             If %trim(workDirective) = '/FREE';
                // In a free-format directive, so we must be in code too.
                If not inFreeFormat;
                   inDirective = *On;
                   inCode = *On;
                   inFreeFormat = *On;
                   lineType = ' ';
                   workLineType = ' ';
                   If ØpDirectives = 'Y';
                      directive = '/Free';
                   Else;
                      dropLine = *On;
                   EndIf;
                Else;
                   dropLine = *On;   // Not needed.
                EndIf;
             ElseIf %trim(workDirective) = '/END-FREE';
                // At the end of a directive, so we can't be in free format any more.
                //inDirective = *On;
                //directive = '/End-Free';
                //inFreeFormat = *Off;
                dropLine = *On;
             ElseIf %trim(workDirective) = '/EJECT';
                inDirective = *On;
                lineType = ' ';
                workLineType = ' ';
             ElseIf %subst(workDirective:1:5) = '/COPY';
                inDirective = *On;
                lineType = ' ';
                workLineType = ' ';
             ElseIf %subst(workDirective:1:3) = '/IF';
                inDirective = *On;
                lineType = ' ';
                workLineType = ' ';
             ElseIf %subst(workDirective:1:6) = '/ENDIF';
                inDirective = *On;
                lineType = ' ';
                workLineType = ' ';
             ElseIf %subst(workDirective:1:7) = '/DEFINE';
                inDirective = *On;
                lineType = ' ';
                workLineType = ' ';
             ElseIf %subst(workDirective:1:6) = '/SPACE';
                inDirective = *On;
                lineType = ' ';
                workLineType = ' ';
             ElseIf %subst(workDirective:1:6) = '/TITLE';
                inDirective = *On;
                lineType = ' ';
                workLineType = ' ';
             ElseIf (%subst(workDirective:1:1) = '*'
                or %subst(workDirective:1:2) = '//')
                and (lineType = *Blank or inCode);
                //            and inCode;
                // This is a comment line.
                If ØpIndComment <> 'Y' or workLineType = 'C';
                   inComment = *On;
                EndIf;
                If %subst(workDirective:1:2) = '//';
                   %subst(directive:1:2) = '  ';
                Else;
                   %subst(directive:1:1) = ' ';
                EndIf;
                If workLineType = 'C' or workLineType = 'D';
                   lineType = ' ';
                   workLineType = ' ';
                EndIf;
                // Retain blank comment markers?
                If ØpRetBlnkCmt = 'N' and %len(%trim(codeLine)) = 0;
                   // Leave the line blank, devoid of any marker.
                Else;
                   codeLine = '//' + codeLine;
                EndIf;
             ElseIf %subst(workDirective:1:1) = '*';
                //            and workLineType = 'O';
                // Leave the line as it is.
                inComment = *On;
             ElseIf %len(%trim(codeLine)) = 0;
                // Just a 'spacer' line - keep it but drop the line type.
                lineType = ' ';
                workLineType = ' ';
             ElseIf %len(%trim(codeLine)) >= 2
                and %subst(%trim(codeLine):1:2) = '//'
                and (workLineType = *Blank or inCode);
                // This is a comment line.
                If ØpIndComment <> 'Y' or workLineType = 'C';
                   inComment = *On;
                EndIf;
                // Retain blank comment markers?
                If ØpRetBlnkCmt = 'N' and %len(%trim(%subst(codeLine:3)))
                                                  = 0;
                   // Leave the line blank, devoid of any marker.
                   codeLine = *Blanks;
                EndIf;
             ElseIf comment <> *Blanks
                and %len(%trim(%subst(codeLine:1:73))) = 0;
                // This is a blank line with a comment section.
                %subst(codeLine:71:2) = '//';
                inComment = *On;
             EndIf;

             //----------------------------------------------------------------------------------
             // Convert fixed-format to free-format?
             If not inComment
             and not inDirective;

                If workLineType = 'C';
                   countEligible += 1;
                   countNotConv += 1;
                   operator = %xlate(lo:up:opCode);
                   savedComment = comment;

                   Exsr subUserConvertC_Spec;

                   If not inComment and not convert
                   and not dropLine and nonConvRsn = *Blanks;
                      nonConvRsn = 'Conversion not currently supported.';
                   EndIf;

                ElseIf workLineType = 'P';     // Procedure start/end.
                   countEligible += 1;
                   countNotConv += 1;
                   operator = *Blanks;
                   savedComment = comment;

                   Exsr subUserConvertP_Spec;

                   If not inComment and not convert
                   and not dropLine and nonConvRsn = *Blanks;
                      nonConvRsn = 'Conversion not currently supported.';
                   EndIf;

                ElseIf workLineType = 'D';     // Declaration.
                   countEligible += 1;
                   countNotConv += 1;
                   savedComment = comment;

                   Exsr subUserConvertD_Spec;

                   If not inComment and not convert
                   and not dropLine and nonConvRsn = *Blanks;
                      //nonConvRsn = 'Conversion not currently supported.';
                   EndIf;

                ElseIf workLineType = 'F';     // File.
                   countEligible += 1;
                   countNotConv += 1;
                   savedComment = comment;

                   Exsr subUserConvertF_Spec;

                   If not inComment and not convert
                   and not dropLine and nonConvRsn = *Blanks;
                      //nonConvRsn = 'Conversion not currently supported.';
                   EndIf;

                ElseIf workLineType = 'H';     // Header.
                   countEligible += 1;
                   countNotConv += 1;
                   savedComment = comment;

                   Exsr subUserConvertH_Spec;

                   If not inComment and not convert
                   and not dropLine and nonConvRsn = *Blanks;
                      //nonConvRsn = 'Conversion not currently supported.';
                   EndIf;

                ElseIf workLineType = 'O';     // Output spec
                   sourceLine = fullLine;

                ElseIf workLineType = 'I';     // Input spec
                   sourceLine = fullLine;

                ElseIf workLineType = ' ' and inCode;
                   inFreeFormat = *On;
                   // When in an IF we usually want subsequent lines to be pulled back to be
                   // in line with the 'If', but only if those lines start with either 'and'
                   // or 'or'.  Otherwise we retain the existing indentation by turning on
                   // inSpan.
                   If inIf and %len(%trim(codeLine)) >= 3
                   and %xlate(lo:up:%subst(%trim(codeLine):1:3)) <> 'AND'
                   and %xlate(lo:up:%subst(%trim(codeLine):1:3)) <> 'OR ';
                      inSpan = *On;
                   EndIf;
                   If inSpan;
                      currOffset = %check(' ':codeLine);  // Offset of the continuation line.
                   Else;
                      prevOffset = %check(' ':codeLine);  // Offset of the parent line.
                   EndIf;
                   sourceLine = %trim(codeLine);         // Free-format already, so trim it.
                Else;
                   inFreeFormat = *On;
                   sourceLine = %trimr(codeLine);        // None of the above, use the raw source
                EndIf;

                // Converted?
                If convert;
                   countConv += 1;
                   countNotConv -= 1;
                   // Switch to free-format?
                   If not inFreeFormat and not inDeclaration;
                      If ØpDirectives = 'Y';
                         savedSRCDTA = SRCDTA;
                         Clear SRCDTA;
                         directive = '/Free';
                         Exsr subUserWriteLine;
                         SRCDTA = savedSRCDTA;
                      EndIf;
                      inFreeFormat = *On;
                      directive = *Blanks;
                   EndIf;
                EndIf;

                // Revert to fixed-format?
                If not convert and (lineType <> *Blanks
                or %subst(workDirective:1:5) = '/COPY');
                   //                or  %subst(prefix:1:3) = '** ');        // Array data reached
                   If inFreeFormat and not inDeclaration;
                      If ØpDirectives = 'Y';
                         savedSRCDTA = SRCDTA;
                         Clear SRCDTA;
                         directive = '/End-Free';
                         Exsr subUserWriteLine;
                         SRCDTA = savedSRCDTA;
                      EndIf;
                      inFreeFormat = *Off;
                      If not inDirective;
                         directive = *Blanks;
                      EndIf;
                   EndIf;
                   // Record the reason for not converting?
                   If nonConvRsn <> *Blanks;
                      savedSRCDTA = SRCDTA;
                      Clear SRCDTA;
                      codeLine = '// >>>>> Not converted: ' + nonConvRsn;
                      Exsr subUserWriteLine;
                      SRCDTA = savedSRCDTA;
                   EndIf;
                   inSpan = *Off;
                EndIf;
             Else;
                // Use source exactly as is.
                sourceLine = codeLine;
             EndIf;

             //----------------------------------------------------------------------------------
             // If we are in a code section, check if indent is affected at all.
             //         If not inDeclaration
             //         and not inDirective
             If not inDirective
             and not inComment
             and not dropLine;
                // Isolate the operator to check indentation against.
                //sourceLine = %trimr(codeLine);
                If inFreeFormat;
                   If %subst(sourceLine:1:2) = '//';            // Comment - no operator.
                      operator = *Blanks;
                   ElseIf inSQL;                                // Embedded SQL - no operator.
                      operator = *Blanks;
                   Else;
                      // Isolate the 'operator' (first word really).
                      operator = %trim(sourceLine);
                      operatorEnd = %scan(' ':%trim(operator)); // Look for end of first 'word'.
                      If operatorEnd = 0;
                         operatorEnd = %scan(';':operator);  // Only one word - is it an operator
                         If operatorEnd = 0;
                            operatorEnd = %scan('(':operator);  // Shouldn't match!
                         EndIf;
                      EndIf;
                      // If we have an operator, remove any attached extender code.
                      If operatorEnd > 0;
                         operator = %subst(operator:1:operatorEnd - 1);
                         // Exec SQL?
                         If %xlate(lo:up:operator) = 'EXEC';
                            If %scan('SQL':%xlate(lo:up:%trim(sourceLine)):6)
                                     > 0;
                               operator = 'Exec SQL';
                               inSQL = *On;
                            EndIf;
                         EndIf;
                         operatorEnd = %scan('(':operator);
                         If operatorEnd > 1;
                            operator = %subst(operator:1:operatorEnd - 1);
                         EndIf;
                      EndIf;

                      If %lookup(%xlate(lo:up:operator):ØopCodeUP) > 0
                      and not inDeclaration;
                         inCode = *On;
                      Else;
                         If %lookup(%xlate(lo:up:operator):ØdeclUP) > 0;
                            // Declaration!
                         Else;
                            // Not an operator!
                            operator = *Blanks;
                            x = %scan('=':sourceLine);
                            If x > 0;   // Looks like an assignment.
                               operator = '=';
                               inCode = *On;
                               If workLineType = *Blank;
                                  sourceLine = %trim(sourceLine);
                               EndIf;
                            EndIf;
                         EndIf;
                      EndIf;
                   EndIf;
                Else;
                   If %subst(sourceLine:1:2) = '//';            // Comment - no operator.
                      operator = *Blanks;
                   Else;
                      operator = %xlate(lo:up:opCode);
                      If %subst(operator:1:4) <> 'EVAL'
                      and operator <> *Blanks;
                         // Strip out in-line definitions.
                         len = *Blanks;
                         dec = *Blanks;
                      EndIf;
                   EndIf;
                EndIf;

                // Convert to upper case for check.
                operator = %xlate(lo:up:operator);

                // Check for indentation level change.
                Select;
                   When workDirective = '/EXEC SQL';
                      increment = 1;
                      inSQL = *On;
                   When workDirective = '/END-EXEC';
                      unindent = *On;
                      increment = -1;
                      dropLine = *On;
                   When inSQL;
                      // Do nothing.
                   When %subst(operator:1:2) = 'IF';
                      increment = 1;
                      inIf = *On;
                   When %subst(operator:1:2) = 'DO';
                      increment = 1;
                      inDo = *On;
                      doCount += 1;
                      doLevel(doCount) = indentCount;
                   When operator = 'FOR';
                      increment = 1;
                      forCount += 1;
                      forLevel(forCount) = indentCount;
                   When operator = 'SELECT';
                      increment = 2;
                      slCount += 1;
                      slLevel(slCount) = indentCount;
                   When operator = 'BEGSR';
                      increment = 1;
                      mainlineIndent = 0;
                      indentCount = mainlineIndent;
                   When %subst(operator:1:4) = 'DCL-';
                      increment = 0;
                      mainlineIndent = 1;
                      indentCount = mainlineIndent;
                      defsMoved = *Off;
                   When %subst(operator:1:4) = 'END-';
                      increment = 0;
                      indentCount = mainlineIndent;
                   When operator = 'MONITOR';
                      increment = 1;
                   When operator = 'ENDSL';
                      unindent = *On;
                      increment = -2;
                      slCount -= 1;
                   When operator = 'ENDCS';
                      Operator = 'ENDIF';
                      unindent = *On;
                      increment = -1;
                   When operator = 'ENDDO';
                      unindent = *On;
                      increment = -1;
                      doCount -= 1;
                   When operator = 'ENDFOR';
                      unindent = *On;
                      increment = -1;
                      forCount -= 1;
                   When %subst(operator:1:3) = 'END';
                      unindent = *On;
                      increment = -1;
                   When %subst(operator:1:4) = 'ELSE'; // Unindent ELSE
                      unindent = *On;
                      indent = *On;
                      increment = -1;
                   When %subst(operator:1:2) = 'OR';   // Unindent OR
                      unindent = *On;
                      indent = *On;
                      increment = -1;
                   When %subst(operator:1:3) = 'AND';  // Unindent AND
                      unindent = *On;
                      indent = *On;
                      increment = -1;
                   When operator = 'ON-ERROR';         // Unindent On-Error
                      unindent = *On;
                      indent = *On;
                      increment = -1;
                   When %subst(operator:1:4) = 'WHEN' or inWhen;
                      unindent = *On;
                      indent = *On;
                      increment = -1;
                      inWhen = *On;
                   When inIF or inDo;                  // Keep conditions in line.
                      unindent = *On;
                      indent = *On;
                      increment = -1;
                   When operator = 'OTHER';             // Unindent Other
                      unindent = *On;
                      indent = *On;
                      increment = -1;
                   Other;
                      increment = 0;
                EndSl;
             ElseIf inDeclaration;
             EndIf;

             //----------------------------------------------------------------------------------
             // Start of code?  If so, pause here and move all field definitions to D-specs.
             If inCode and not defsMoved;
                Exsr subUserMoveDefs;
             EndIf;

             //----------------------------------------------------------------------------------
             // If we need to temporarily unindent, do so to the requested increment.
             If unindent;
                indentCount += increment;
                increment = 0;
                unindent = *Off;
             EndIf;

             //----------------------------------------------------------------------------------
             // If we are in a code section and in free-format, perform reformatting.
             //If inCode and inFreeFormat and not inDirective
             If inFreeFormat
             and not inDirective
             and sourceLine <> *Blanks
             and not inComment
             and not dropLine;       //  and not inSpan
                // Derive reformatted opcode (if any)
                x = %lookup(operator:ØopCodeUP);
                If x > 0;
                   newOperator = %trim(ØopCodeLO(x));
                Else;
                   x = %lookup(operator:ØdeclUP);
                   If x > 0;
                      newOperator = %trim(ØdeclLO(x));
                   Else;
                      // Not a valid operator, check if this is a comment.
                      x = %scan('//':%trim(sourceLine));
                      If x = 1;
                         inComment = *On;
                         newOperator = '';
                         operator = *Blanks;
                      Else;
                         newOperator = '';
                      EndIf;
                   EndIf;
                EndIf;

                // Use new opcode if it exists.
                If %len(newOperator) > 0;
                   If %len(%trim(sourceLine)) > %len(newOperator);
                      sourceLine = %trim(%subst(%trim(sourceLine)
                                       :%len(newOperator) + 1));
                   Else;
                      //                  sourceLine = %trim(%subst(%trim(sourceLine)
                      //                                   :%len(newOperator)));
                      sourceLine = *Blanks;
                   EndIf;
                   // Insert a spcace after operator if it's not the end of the line
                   // and there's no operation extender.
                   If %subst(sourceLine:1:1) <> ';'
                   and (%subst(sourceLine:1:1) <> '('
                     or %subst(sourceLine:1:1) = '('
                    and %subst(sourceLine:3:1) <> ')'
                    and %subst(sourceLine:4:1) <> ')');
                      sourceLine = ' ' + sourceLine;
                   EndIf;
                   sourceLine = newOperator + sourceLine;
                EndIf;

                If inCode;
                   // Padding required?
                   If padResult;
                      savedSRCDTA = SRCDTA;
                      Clear codeLine;
                      %subst(codeLine:indentOffset)
                            = %trim(padTarget) + ' = *Blanks;';
                      Exsr subUserWriteLine;
                      SRCDTA = savedSRCDTA;
                      padResult = *Off;
                   EndIf;

                   // Determine the indentation to use.
                   If indentCount > maxIndent;
                      indentOffset = maxIndent * indentSize + 1;
                   Else;
                      indentOffset = indentCount * indentSize + 1;
                   EndIf;

                   // Adjust for continuation lines.
                   If inCallP and (%subst(operator:1:5) <> 'CALLP');
                      indentOffset += callPOffset;
                   ElseIf inEval and (%subst(operator:1:4) <> 'EVAL');
                      indentOffset += evalOffset;
                   ElseIf inSpan;
                      indentOffset = currOffset + (indentOffset - prevOffset);
                   EndIf;

                   // Avoid losing code off of the right hand side (comments mainly).
                   If %len(%trimr(sourceLine)) + indentOffset > 93;
                      indentOffset = 93 - %len(%trim(sourceLine));
                   EndIf;

                   // For code lines, check for overflow, and unindent accordingly if it does,
                   If not inComment;
                      lineEnd = %scan(';':%trimr(sourceLine));
                      If lineEnd = 0;   // Code already spans to next line.
                         lineEnd = %scan('//':sourceLine);
                         If lineEnd > 0;
                            lineEnd
                              = %len(%trimr(%subst(sourceLine:1:lineEnd-1)));
                         Else;
                            lineEnd = %len(%trimr(sourceLine));
                         EndIf;
                         If not inIf and not inDo and not inWhen;
                            inSpan = *On;
                         EndIf;
                      EndIf;
                   EndIf;

                   // Cater for commented out code that extends into comments.
                   If indentOffset + lineEnd > 74;
                      //Exsr subUserWrapLine;
                      indentOffset -= ((indentOffset + lineEnd) - 74);
                   EndIf;

                   // Ensure that we don't go back too far!
                   If indentOffset < 1;
                      indentOffset = 1;
                   EndIf;

                   savedSRCDTA = SRCDTA;
                   Clear codeLine;
                   %subst(codeLine:indentOffset) = %trimr(sourceLine);
                   // Append an in-line comment?
                   If (convert or setOn or setOff)
                   and savedComment <> *Blanks;
                      %subst(codeLine:71) = '// ' + savedComment;
                      savedComment = *Blanks;
                   EndIf;
                   sourceLine = codeLine;
                   SRCDTA = savedSRCDTA;
                   EndIf;   // inCode
                EndIf;
             EndIf;

             //----------------------------------------------------------------------------------
             // Output the formatted line (and any overflows that have occurred.
             If not dropLine;
                If convert;
                   Clear nonPrefix;
                EndIf;
                If inCode or inArrayData
                or lineType = *Blank or %subst(directive:1:1) = '*';
                   codeLine = %trimr(sourceLine);
                Else;
                   fullLine = %trimr(sourceLine);
                EndIf;
                Exsr subUserWriteLine;

                // Overflow line?
                If overFlowLine <> *Blanks;
                   Clear codeLine;
                   %subst(codeLine:indentOffset) = %trimr(overflowLine);
                   overflowLine = *Blanks;
                   Exsr subUserWriteLine;
                EndIf;
             Else;
                dropLine = *Off;
             EndIf;

             indentCount += increment;

             // Following a WHEN or ON-ERROR or ELSE, code should be indented again.
             If indent;
                indentCount += 1;
                indent = *Off;
                // Following ENDSR, we should revert to mainline indentation.
             ElseIf operator = 'ENDSR';
                indentCount = mainlineIndent;
                inCode = *Off;
             EndIf;

             // If spanning a line, check if the current line ends the span.
             If (inSpan or inIf or inDo or inWhen or inCallP or inEval
             or inSQL or inDeclaration)
             and not inComment;
                lineEnd = %scan(';':%trim(sourceLine));
                If lineEnd <> 0;
                   inSpan = *Off;
                   inIf = *Off;
                   inDo = *Off;
                   inWhen = *Off;
                   inCallP = *Off;
                   inEval = *Off;
                   inSQL = *Off;
                   inDeclaration = *Off;
                EndIf;
             EndIf;

             //----------------------------------------------------------------------------------
             // Close off Prototype/Interface/Datastructure?
             If (inPrototype or inInterface or inDatastructure)
             and SRCSEQ = endLine;
                If not inDatastructure
                or inDatastructure and endDS;
                   savedSRCDTA = SRCDTA;
                   Clear SRCDTA;
                   codeLine = 'End-' + endDeclType + ';';
                   Exsr subUserWriteLine;
                   SRCDTA = savedSRCDTA;
                EndIf;
                inPrototype = *Off;
                inExtProc = *Off;
                inInterface = *Off;
                inDatastructure = *Off;
                inSpan = *Off;
                inDeclaration = *Off;
                inExtProc = *Off;
                workDeclName = *Blanks;
             EndIf;

          EndSr;
       //-------------------------------------------------------------------------------------------

      /Eject
       //-------------------------------------------------------------------------------------------
       // Convert the line to free-format?
       //-------------------------------------------------------------------------------------------
       BegSr subUserConvertC_Spec;

          Select;
                // Keep blank lines.
             When codeLine = *Blanks;
                sourceLine = *Blanks;
                convert = *On;

               //----------------------------------------------------------------------------------
                // EXEC SQL
             When workDirective = '/EXEC SQL' or inSQL;
                Exsr subUserCvt_EXEC_SQL;

               //----------------------------------------------------------------------------------
                // END-EXEC
             When workDirective = '/END-EXEC';
                convert = *On;

               //----------------------------------------------------------------------------------
                // Conditioning indicators
             When condInd <> *Blanks;
                nonConvRsn = 'Conditioning indicators are not currently '
                           + 'supported.';

               //----------------------------------------------------------------------------------
                // ACQ.
             When %subst(operator:1:3) = 'ACQ';
                Exsr subUserCvt_ACQ;

               //----------------------------------------------------------------------------------
                // ADDDUR.
             When %subst(operator:1:6) = 'ADDDUR';
                Exsr subUserCvt_ADDDUR;

               //----------------------------------------------------------------------------------
                // ADD.
             When %subst(operator:1:3) = 'ADD';
                Exsr subUserCvt_ADD;

               //----------------------------------------------------------------------------------
                // ALLOC.
             When %subst(operator:1:5) = 'ALLOC';
                Exsr subUserCvt_ALLOC;

               //----------------------------------------------------------------------------------
                // BEGSR
             When operator = 'BEGSR';
                Exsr subUserCvt_BEGSR;

               //----------------------------------------------------------------------------------
                // CALLP
             When %subst(operator:1:5) = 'CALLP' or inCallP;
                Exsr subUserCvt_CALLP;

               //----------------------------------------------------------------------------------
                // CASxx
             When %subst(operator:1:3) = 'CAS';
                Exsr subUserCvt_CASxx;

               //----------------------------------------------------------------------------------
                // CAT
             When %subst(operator:1:3) = 'CAT';
                Exsr subUserCvt_CAT;

               //----------------------------------------------------------------------------------
                // CHAIN
             When %subst(operator:1:5) = 'CHAIN';
                Exsr subUserCvt_CHAIN;

               //----------------------------------------------------------------------------------
                // CHECK
             When %subst(operator:1:5) = 'CHECK';
                Exsr subUserCvt_CHECKx;

               //----------------------------------------------------------------------------------
                // CLEAR
             When %subst(operator:1:5) = 'CLEAR';
                Exsr subUserCvt_CLEAR;

               //----------------------------------------------------------------------------------
                // CLOSE
             When %subst(operator:1:5) = 'CLOSE';
                Exsr subUserCvt_CLOSE;

               //----------------------------------------------------------------------------------
                // COMMIT
             When %subst(operator:1:6) = 'COMMIT';
                Exsr subUserCvt_COMMIT;

               //----------------------------------------------------------------------------------
                // COMP
             When operator = 'COMP';
                Exsr subUserCvt_COMP;

               //----------------------------------------------------------------------------------
                // DEALLOC.
             When %subst(operator:1:7) = 'DEALLOC';
                Exsr subUserCvt_DEALLOC;

               //----------------------------------------------------------------------------------
                // DEFINE
             When operator = 'DEFINE';
                dropLine = *On;

               //----------------------------------------------------------------------------------
                // DELETE
             When %subst(operator:1:6) = 'DELETE';
                Exsr subUserCvt_DELETE;

               //----------------------------------------------------------------------------------
                // DIV
             When %subst(operator:1:3) = 'DIV';
                Exsr subUserCvt_DIV;

               //----------------------------------------------------------------------------------
                // DOxxx
             When %subst(operator:1:2) = 'DO'
             and (%subst(operator:3:3) = 'WEQ'
             or %subst(operator:3:2) = 'W '
             or %subst(operator:3:3) = 'WGT'
             or %subst(operator:3:3) = 'WLT'
             or %subst(operator:3:3) = 'WNE'
             or %subst(operator:3:3) = 'WGE'
             or %subst(operator:3:3) = 'WLE'
             or %subst(operator:3:2) = 'U '
             or %subst(operator:3:3) = 'UEQ'
             or %subst(operator:3:3) = 'UGT'
             or %subst(operator:3:3) = 'ULT'
             or %subst(operator:3:3) = 'UNE'
             or %subst(operator:3:3) = 'UGE'
             or %subst(operator:3:3) = 'ULE'
             or %subst(operator:3:3) = '   ')
             or inDo;
                Exsr subUserCvt_DO;

               //----------------------------------------------------------------------------------
                // DSPLY
             When %subst(operator:1:5) = 'DSPLY';
                Exsr subUserCvt_DSPLY;

               //----------------------------------------------------------------------------------
                // DUMP
             When %subst(operator:1:4) = 'DUMP';
                Exsr subUserCvt_DUMP;

               //----------------------------------------------------------------------------------
                // ELSE
             When operator = 'ELSE';
                Exsr subUserCvt_ELSE;

               //----------------------------------------------------------------------------------
                // ELSEIF
             When operator = 'ELSEIF';
                Exsr subUserCvt_ELSEIF;

               //----------------------------------------------------------------------------------
                // ENDxx
             When %subst(operator:1:3) = 'END';
                Exsr subUserCvt_ENDxx;

               //----------------------------------------------------------------------------------
                // EVALx
             When %subst(operator:1:4) = 'EVAL' or inEval;
                Exsr subUserCvt_EVALx;

               //----------------------------------------------------------------------------------
                // EXCEPT
             When operator = 'EXCEPT';
                Exsr subUserCvt_EXCEPT;

               //----------------------------------------------------------------------------------
                // EXFMT
             When %subst(operator:1:5) = 'EXFMT';
                Exsr subUserCvt_EXFMT;

               //----------------------------------------------------------------------------------
                // EXSR
             When operator = 'EXSR';
                Exsr subUserCvt_EXSR;

               //----------------------------------------------------------------------------------
                // EXTRCT
             When %subst(operator:1:6) = 'EXTRCT';
                Exsr subUserCvt_EXTRCT;

               //----------------------------------------------------------------------------------
                // FEOD
             When %subst(operator:1:4) = 'FEOD';
                Exsr subUserCvt_FEOD;

               //----------------------------------------------------------------------------------
                // FOR
             When operator = 'FOR';
                Exsr subUserCvt_FOR;

               //----------------------------------------------------------------------------------
                // FORCE
             When operator = 'FORCE';
                Exsr subUserCvt_FORCE;

               //----------------------------------------------------------------------------------
                // IFxx
             When %subst(operator:1:2) = 'IF' or inIf;
                Exsr subUserCvt_IF;

               //----------------------------------------------------------------------------------
                // IN
             When %subst(operator:1:2) = 'IN';
                Exsr subUserCvt_IN;

               //----------------------------------------------------------------------------------
                // ITER
             When operator = 'ITER';
                Exsr subUserCvt_ITER;

               //----------------------------------------------------------------------------------
                // LEAVExx;
             When %subst(operator:1:5) = 'LEAVE';
                Exsr subUserCvt_LEAVE;

               //----------------------------------------------------------------------------------
                // LOOKUP
             When operator = 'LOOKUP';
                Exsr subUserCvt_LOOKUP;

               //----------------------------------------------------------------------------------
                // MOVEA
             When %subst(operator:1:5) = 'MOVEA';
                Exsr subUserCvt_MOVEA;
                LeaveSr;

               //----------------------------------------------------------------------------------
                // MOVE/MOVEL
             When operator = 'MONITOR';
                Exsr subUserCvt_MONITOR;

               //----------------------------------------------------------------------------------
                // MOVE/MOVEL
             When %subst(operator:1:4) = 'MOVE';
                Exsr subUserCvt_MOVE;

               //----------------------------------------------------------------------------------
                // MULT.
             When %subst(operator:1:4) = 'MULT';
                Exsr subUserCvt_MULT;

               //----------------------------------------------------------------------------------
                // MVR
             When operator = 'MVR';
                Exsr subUserCvt_MVR;

               //----------------------------------------------------------------------------------
                // OCCUR (but not both set and get).
             When %subst(operator:1:5) = 'OCCUR';
                Exsr subUserCvt_OCCUR;

               //----------------------------------------------------------------------------------
                // ON-ERROR
             When operator = 'ON-ERROR';
                Exsr subUserCvt_ON_ERROR;

               //----------------------------------------------------------------------------------
                // OPEN
             When %subst(operator:1:4) = 'OPEN';
                Exsr subUserCvt_OPEN;

               //----------------------------------------------------------------------------------
                // OTHER
             When operator = 'OTHER';
                Exsr subUserCvt_OTHER;

               //----------------------------------------------------------------------------------
                // OUT
             When %subst(operator:1:3) = 'OUT';
                Exsr subUserCvt_OUT;

               //----------------------------------------------------------------------------------
                // POST
             When %subst(operator:1:4) = 'POST';
                Exsr subUserCvt_POST;

               //----------------------------------------------------------------------------------
                // READ
             When %subst(operator:1:4) = 'READ';
                Exsr subUserCvt_READ;

               //----------------------------------------------------------------------------------
                // REL
             When %subst(operator:1:3) = 'REL';
                Exsr subUserCvt_REL;

               //----------------------------------------------------------------------------------
                // RESET
             When %subst(operator:1:5) = 'RESET';
                Exsr subUserCvt_RESET;

               //----------------------------------------------------------------------------------
                // RETURN
             When %subst(operator:1:6) = 'RETURN';
                Exsr subUserCvt_RETURN;

               //----------------------------------------------------------------------------------
                // ROLBK
             When %subst(operator:1:5) = 'ROLBK';
                Exsr subUserCvt_ROLBK;

               //----------------------------------------------------------------------------------
                // SCAN
             When operator = 'SCAN';
                Exsr subUserCvt_SCAN;

               //----------------------------------------------------------------------------------
                // SELECT
             When operator = 'SELECT';
                Exsr subUserCvt_SELECT;

               //----------------------------------------------------------------------------------
                // SETLL / SETGT
             When %subst(operator:1:5) = 'SETLL'
             or %subst(operator:1:5) = 'SETGT';
                Exsr subUserCvt_SETxx;

               //----------------------------------------------------------------------------------
                // SETOFF
             When operator = 'SETOFF';
                Exsr subUserCvt_SETOFF;

               //----------------------------------------------------------------------------------
                // SETON
             When operator = 'SETON';
                Exsr subUserCvt_SETON;

               //----------------------------------------------------------------------------------
                // SHTDN
             When operator = 'SHTDN';
                Exsr subUserCvt_SHTDN;

               //----------------------------------------------------------------------------------
                // SORTA.
             When %subst(operator:1:5) = 'SORTA';
                Exsr subUserCvt_SORTA;

               //----------------------------------------------------------------------------------
                // SUBDUR.
             When %subst(operator:1:6) = 'SUBDUR';
                Exsr subUserCvt_SUBDUR;

               //----------------------------------------------------------------------------------
                // SUBST.
             When %subst(operator:1:5) = 'SUBST';
                Exsr subUserCvt_SUBST;

               //----------------------------------------------------------------------------------
                // SUB
             When %subst(operator:1:3) = 'SUB';
                Exsr subUserCvt_SUB;

               //----------------------------------------------------------------------------------
                // TESTB
             When operator = 'TESTB';

               //----------------------------------------------------------------------------------
                // TESTN
             When operator = 'TESTN';

               //----------------------------------------------------------------------------------
                // TESTZ
             When operator = 'TESTZ';

               //----------------------------------------------------------------------------------
                // TEST
             When %subst(operator:1:4) = 'TEST';
                Exsr subUserCvt_TEST;

               //----------------------------------------------------------------------------------
                // TIME
             When operator = 'TIME';
                Exsr subUserCvt_TIME;

               //----------------------------------------------------------------------------------
                // UPDATE
             When %subst(operator:1:6) = 'UPDATE';
                Exsr subUserCvt_UPDATE;

               //----------------------------------------------------------------------------------
                // UNLOCK
             When %subst(operator:1:6) = 'UNLOCK';
                Exsr subUserCvt_UNLOCK;

               //----------------------------------------------------------------------------------
                // WHENxx
             When %subst(operator:1:4) = 'WHEN' or inWhen;
                Exsr subUserCvt_WHEN;

               //----------------------------------------------------------------------------------
                // WRITE
             When %subst(operator:1:5) = 'WRITE';
                Exsr subUserCvt_WRITE;

               //----------------------------------------------------------------------------------
                // XLATE
             When %subst(operator:1:5) = 'XLATE';
                Exsr subUserCvt_XLATE;

               //----------------------------------------------------------------------------------
                // Z-ADD (half-adjust not converted).
             When %subst(operator:1:5) = 'Z-ADD';
                Exsr subUserCvt_Z_ADD;

               //----------------------------------------------------------------------------------
                // Z-SUB (half-adjust not converted).
             When %subst(operator:1:5) = 'Z-SUB';
                Exsr subUserCvt_Z_SUB;
          EndSl;

       EndSr;
       //-------------------------------------------------------------------------------------------

      /Eject
       //-------------------------------------------------------------------------------------------
       // Convert declaration to free-format.
       //-------------------------------------------------------------------------------------------
       BegSr subUserConvertD_Spec;

          // Keep blank lines.
          If codeLine = *Blanks;
             sourceLine = *Blanks;
             convert = *On;
             LeaveSr;
          EndIf;

          sourceLine = fullLine;

          //      declType = %xlate(lo:up:declType);
          workDeclAttr = %xlate(lo:up:declAttr);
          workDeclKeywords = declKeywords;       // Use longer work field to cater for expansion.

          Exsr subUserCheckSpan;  // Does this line span more than one line?

          //If not inDeclaration;
          If not inDeclaration or declName = *Blanks;
             If not inDeclaration;
                //Exsr subUserGetDeclarationType;
                GetDeclarationType(workDeclType:savedName:workDeclLine);
             EndIf;

             //-------------------------------------------------------------------------
             // Stand-alone Field Definition.
             //-------------------------------------------------------------------------
             If workDeclType = 'S';      // Stand-alone field.
                inDeclaration = *On;

                Clear DCLS;

                // FROMFILE is not allowed.
                If %scan('FROMFILE':%xlate(lo:up:workDeclKeywords)) > 0;
                   inDeclaration = *Off;
                   nonConvRsn = 'FROMFILE not allowed in Free-Form';
                   convert = *Off;
                   LeaveSr;
                EndIf;

                If savedName <> *Blanks;
                   DCLS.decl = 'Dcl-S ';
                   %subst(DCLS:7) = savedName;
                EndIf;

                // Type.
                If workDeclAttr = *Blanks
                and DCLS.type = *Blanks;
                   If declLen = *Blanks;
                      // No definition (probably in keywords - e.g. LIKE()).
                   ElseIf declScale = *Blanks;
                      workDeclAttr = 'A';
                   Else;
                      If inDatastructure;
                         workDeclAttr = 'S';
                      Else;
                         workDeclAttr = 'P';
                      EndIf;
                   EndIf;
                EndIf;

                If workDeclAttr = *Blanks;
                   // No definition (probably in keywords - e.g. LIKE()).
                ElseIf workDeclAttr = 'A';
                   x = %scan('VARYING':%xlate(lo:up:workDeclKeywords));
                   If x > 0;
                      DCLS.type = '  VarChar';
                      If x = 1;
                         workDeclKeywords = %subst(workDeclKeywords:x+7);
                      Else;
                         workDeclKeywords = %subst(workDeclKeywords:1:x-1)
                                      + %subst(workDeclKeywords:x+7);
                      EndIf;
                   Else;
                      DCLS.type = '     Char';
                   EndIf;
                ElseIf workDeclAttr = 'P';
                   DCLS.type = '   Packed';
                ElseIf workDeclAttr = 'D';
                   DCLS.type = '     Date';
                   x = %scan('DATFMT':%xlate(lo:up:workDeclKeywords));
                   If x > 0;
                      x = %scan('(':workDeclKeywords:x);
                      y = %scan(')':workDeclKeywords:x);
                      DCLS.definition = '('
                                + %subst(workDeclKeywords:x+1:y-x-1)
                                + ')';
                      workDeclKeywords = %subst(workDeclKeywords:y+1);
                   EndIf;
                ElseIf workDeclAttr = 'T';
                   DCLS.type = '     Time';
                   x = %scan('TIMFMT':%xlate(lo:up:workDeclKeywords));
                   If x > 0;
                      x = %scan('(':workDeclKeywords:x);
                      y = %scan(')':workDeclKeywords:x);
                      DCLS.definition = '('
                                + %subst(workDeclKeywords:x+1:y-x-1)
                                + ')';
                      workDeclKeywords = %subst(workDeclKeywords:y+1);
                   EndIf;
                ElseIf workDeclAttr = 'Z';
                   DCLS.type = 'TimeStamp';
                ElseIf workDeclAttr = 'I';
                   DCLS.type = '      Int';
                ElseIf workDeclAttr = 'S';
                   DCLS.type = '    Zoned';
                ElseIf workDeclAttr = 'N';
                   DCLS.type = '      Ind';
                ElseIf workDeclAttr = '*';
                   DCLS.type = '  Pointer';
                ElseIf workDeclAttr = 'B';
                   DCLS.type = '   BinDec';
                ElseIf workDeclAttr = 'G';
                   x = %scan('VARYING':%xlate(lo:up:workDeclKeywords));
                   If x > 0;
                      DCLS.type = ' VarGraph';
                      workDeclKeywords = %subst(workDeclKeywords:x+7);
                   Else;
                      DCLS.type = '    Graph';
                   EndIf;
                Else;
                   inDeclaration = *Off;
                   convert = *Off;
                   LeaveSr;
                EndIf;

                // Attributes.
                If workDeclAttr <> '*'
                and workDeclAttr <> 'N'
                and workDeclAttr <> 'D'
                and workDeclAttr <> 'T'
                and workDeclAttr <> 'Z'
                and workDeclAttr <> *Blank
                and DCLS.type <> *Blanks;
                   DCLS.definition = '(' + %trim(declLen);
                   If declScale <> *Blanks;
                      DCLS.definition = %trimr(DCLS.definition)
                                      + ':' + %trim(declScale);
                   EndIf;
                   DCLS.definition = %trimr(DCLS.definition) + ')';
                EndIf;

                // Keywords.

                // Expand DTAARA?
                x = %scan('DTAARA(':%xlate(lo:up:workDeclKeywords));
                If x > 0;
                   i = %scan(')':workDeclKeywords:x+1);
                   If i > 0;
                      If %scan('''':%subst(workDeclKeywords:x+7:i-x-7)) = 0;
                         workDeclKeywords = %subst(workDeclKeywords:1:x+6)
                            + ''''
                       + %xlate(lo:up:%trim(%subst(workDeclKeywords:x+7:i-x-7)))
                            + ''''
                            + %subst(workDeclKeywords:i);
                      EndIf;
                   EndIf;
                EndIf;

                // Terminate the line?
                If not inSpan;
                   If workDeclKeyWords = *Blanks;
                      DCLS.definition = %trimr(DCLS.definition) + ';';
                   Else;
                      workDeclKeywords = %trimr(workDeclKeywords) + ';';
                   EndIf;
                   inDeclaration = *Off;
                Else;
                   inSpan = *Off;
                EndIf;

                // Have we encroached on the comments?
                x = %len(%trimr(DCLS.definition)) + %len(workDeclKeywords);
                If x >= 37;
                   x = x - %len(%trimr(DCLS.definition));
                   SplitLine(workDeclKeywords:overflowLine:x);
                   indentOffset = 37;
                EndIf;

                If DCLS.definition = *Blanks and DCLS.type = *Blanks;
                   DCLS.definition = %trim(workDeclKeywords);
                Else;
                   DCLS.definition = %trimr(DCLS.definition) + ' '
                                   + %trim(workDeclKeywords);
                EndIf;

                // Comment.
                If comment <> *Blanks;
                   If %subst(%trim(comment) + ' ':1:2) = '//';
                      DCLS.comment = '   ' + comment;
                   Else;
                      DCLS.comment = '// ' + comment;
                   EndIf;
                EndIf;

                // Converted line...
                sourceLine = DCLS;
                If not inSpan;
                   savedName = *Blanks;
                EndIf;

                //-------------------------------------------------------------------------
                // Constant Definition.
                //-------------------------------------------------------------------------
             ElseIf workDeclType = 'C';
                inDeclaration = *On;

                Clear DCLS;
                If savedName <> *Blanks;
                   DCLS.decl = 'Dcl-C ';
                   %subst(DCLS:7) = %xlate(lo:up:savedName);
                EndIf;

                // Keywords.
                If workDeclKeywords <> *Blanks;
                   If DCLS.definition = *Blanks;
                      DCLS.definition = %trim(workDeclKeywords);
                   Else;
                      DCLS.definition = %trimr(DCLS.definition) + ' '
                                      + %trim(workDeclKeywords);
                   EndIf;
                EndIf;

                // Comment.
                If comment <> *Blanks;
                   If %subst(%trim(comment) + ' ':1:2) = '//';
                      DCLS.comment = '   ' + comment;
                   Else;
                      DCLS.comment = '// ' + comment;
                   EndIf;
                EndIf;

                If not inSpan;
                   DCLS.definition = %trimr(DCLS.definition) + ';';
                   inDeclaration = *Off;
                Else;
                   inSpan = *Off;
                EndIf;

                // Continuation of constant must start at left margin.
                If DCLS.decl = *Blanks;
                   DCLS = DCLS.definition;
                EndIf;

                // Converted line...
                sourceLine = DCLS;
                If not inSpan;
                   savedName = *Blanks;
                EndIf;

                //-------------------------------------------------------------------------
                // Prototype/Interface/Datastructure Definition.
                //-------------------------------------------------------------------------
             ElseIf workDeclType = 'PR'
                 or inPrototype
                 or workDeclType = 'PI'
                 or inInterface
                 or workDeclType = 'DS'
                 or inDatastructure;
                inDeclaration = *On;
                Clear DCLPR;

                // Determine where to end the structure.
                If not inPrototype
                and not inInterface
                and not inDatastructure;
                   Exsr subUserGetEndLine;
                   If workDeclType = 'PR';
                      inPrototype = *On;
                   ElseIf workDeclType = 'PI';
                      inInterface = *On;
                   ElseIf workDeclType = 'DS';
                      inDatastructure = *On;
                      endDS = *On;
                   EndIf;
                   DCLPR.decl = 'Dcl-' + workDeclType;
                   If savedName = *Blanks;
                      savedName = '*N';
                   EndIf;
                   %subst(DCLPR:8) = savedName;
                   //DCLPR.procName = savedName;
                   endDeclType = workDeclType;
                   workDeclName = savedName;
                   If %scan('...':sourceLine) > 0;  // Long name!
                      workDeclAttr = *Blanks;
                   EndIf;
                Else;
                   If inPrototype
                   and savedName = *Blanks
                   and declType = *Blanks
                   and not inExtProc
                   and not inSpan;
                      savedName = '*N';
                   EndIf;

                   If savedName <> '**';
                      DCLPR.fieldName = savedName;
                   EndIf;
                EndIf;

                // Type.
                If workDeclAttr = *Blanks
                and DCLPR.type = *Blanks;
                   If declLen = *Blanks;
                      // No definition (probably in keywords - e.g. LIKE()).
                   ElseIf declScale = *Blanks;
                      workDeclAttr = 'A';
                   Else;
                      If inDatastructure;
                         workDeclAttr = 'S';
                      Else;
                         workDeclAttr = 'P';
                      EndIf;
                   EndIf;
                EndIf;

                If workDeclAttr = *Blanks;
                   // No definition (probably in keywords - e.g. LIKE()).
                ElseIf workDeclAttr = 'A';
                   If DCLPR.decl = 'Dcl-DS';
                      If declLen <> *Blanks;
                         DCLPR.type = '      Len';
                      EndIf;
                   Else;
                      x = %scan('VARYING':%xlate(lo:up:workDeclKeywords));
                      If x > 0;
                         DCLPR.type = '  VarChar';
                         If x = 1;
                            workDeclKeywords = %subst(workDeclKeywords:x+7);
                         Else;
                            workDeclKeywords = %subst(workDeclKeywords:1:x-1)
                                         + %subst(workDeclKeywords:x+7);
                         EndIf;
                      Else;
                         DCLPR.type = '     Char';
                      EndIf;
                   EndIf;
                ElseIf workDeclAttr = 'P';
                   DCLPR.type = '   Packed';
                ElseIf workDeclAttr = 'D';
                   DCLPR.type = '     Date';
                   x = %scan('DATFMT':%xlate(lo:up:workDeclKeywords));
                   If x > 0;
                      x = %scan('(':workDeclKeywords:x);
                      y = %scan(')':workDeclKeywords:x);
                      DCLPR.definition = '('
                                + %subst(workDeclKeywords:x+1:y-x-1)
                                + ')';
                      workDeclKeywords = %subst(workDeclKeywords:y+1);
                   EndIf;
                ElseIf workDeclAttr = 'T';
                   DCLPR.type = '     Time';
                   x = %scan('TIMFMT':%xlate(lo:up:workDeclKeywords));
                   If x > 0;
                      x = %scan('(':workDeclKeywords:x);
                      y = %scan(')':workDeclKeywords:x);
                      DCLPR.definition = '('
                                + %subst(workDeclKeywords:x+1:y-x-1)
                                + ')';
                      workDeclKeywords = %subst(workDeclKeywords:y+1);
                   EndIf;
                ElseIf workDeclAttr = 'Z';
                   DCLPR.type = 'TimeStamp';
                ElseIf workDeclAttr = 'I';
                   DCLPR.type = '      Int';
                ElseIf workDeclAttr = 'S';
                   DCLPR.type = '    Zoned';
                ElseIf workDeclAttr = 'N';
                   DCLPR.type = '      Ind';
                ElseIf workDeclAttr = '*';
                   DCLPR.type = '  Pointer';
                ElseIf workDeclAttr = 'B';
                   DCLPR.type = '   BinDec';
                ElseIf workDeclAttr = 'G';
                   x = %scan('VARYING':%xlate(lo:up:workDeclKeywords));
                   If x > 0;
                      DCLPR.type = ' VarGraph';
                      workDeclKeywords = %subst(workDeclKeywords:x+7);
                   Else;
                      DCLPR.type = '    Graph';
                   EndIf;
                Else;
                   inDeclaration = *Off;
                   convert = *Off;
                   LeaveSr;
                EndIf;

                // Attributes.
                If workDeclAttr <> '*'
                and workDeclAttr <> 'N'
                and workDeclAttr <> 'D'
                and workDeclAttr <> 'T'
                and workDeclAttr <> 'Z'
                and workDeclAttr <> *Blank
                and DCLPR.type <> *Blanks;
                   DCLPR.definition = '(';
                   If inDatastructure and declFrom <> *Blanks;
                      workLength = %dec(%trim(declLen):7:0)
                                 - %dec(%trim(declFrom):7:0) + 1;
                      If workDeclAttr = 'B';
                         workLength = workLength * 2;
                      ElseIf workDeclAttr = 'P';
                         workLength = (workLength * 2) - 1;
                      EndIf;
                      AdjustArrayLength(workLength);
                      DCLPR.definition = %trim(DCLPR.definition)
                                       + %char(workLength);
                   Else;
                      DCLPR.definition = %trim(DCLPR.definition)
                                       + %trim(declLen);
                   EndIf;

                   If declScale <> *Blanks;
                      DCLPR.definition = %trimr(DCLPR.definition)
                                      + ':' + %trim(declScale);
                   EndIf;
                   DCLPR.definition = %trimr(DCLPR.definition) + ')';
                EndIf;

                // From specified?
                If inDatastructure;
                   If declFrom <> *Blanks
                   and %scan('...':declOptions) = 0;
                      If %subst(declFrom:1:1) = '*';
                         workDeclKeywords = %trim(declFrom) + ' ';
                      Else;
                      workDeclKeywords = 'Pos(' + %trim(declFrom) + ') '
                                   + workDeclKeywords;
                      EndIf;
                   Else;
                      // Overlay specified using the base datastructure name?
                      // This is not permitted in free-form, so convert it to 'POS'.
                      x = %scan('OVERLAY(':%xlate(lo:up:workDeclKeywords));
                      If x > 0;
                         i = %scan(':':workDeclKeywords:x);
                         If i > 0;
                            If %trim(%xlate(lo:up
                                    :%subst(workDeclKeywords:x+8:i-x-8))) =
                               %xlate(lo:up:workDeclName);
                               j = %scan(')':workDeclKeywords:i);
                               If j > 0;
                                  If x = 1;
                                     workDeclKeywords
                                      = 'Pos('
                                     + %trim(%subst(workDeclKeywords:i+1:j-i-1))
                                     + %subst(workDeclKeywords:j);
                                  Else;
                                     workDeclKeywords
                                       = %trim(%subst(workDeclKeywords:1:x-1))
                                       + ' Pos('
                                     + %trim(%subst(workDeclKeywords:i+1:j-i-1))
                                     + %subst(workDeclKeywords:j);
                                  EndIf;
                               EndIf;
                            EndIf;
                         EndIf;
                      EndIf;
                   EndIf;
                   // Require End-DS?
                   x = %scan('LIKEDS(':%xlate(lo:up:workDeclKeywords));
                   If x = 0;
                      x = %scan('LIKEREC(':%xlate(lo:up:workDeclKeywords));
                   EndIf;
                   If x > 0;
                      // Nope.
                      endDS = *Off;
                   EndIf;

                   // Datastructure type?
                   If declPrefix = 'S';       // Program Status
                      workDeclKeywords = 'PSDS ' + workDeclKeywords;
                      If savedName = DCLPR.procName;
                         %subst(savedName:16:1) = *Blank;
                      EndIf;
                      %subst(DCLPR.procName:16:1) = *Blank;

                   ElseIf declPrefix = 'U';   // Dataarea
                      // If not already defined as a data area, do it now.
                      If %scan('DTAARA':%xlate(lo:up:workDeclKeywords)) = 0;
                         If declName = *Blanks;
                            workDeclKeywords = 'DTAARA(*AUTO) '
                                                         + workDeclKeywords;
                         Else;
                            workDeclKeywords = 'DTAARA ' + workDeclKeywords;
                         EndIf;
                      EndIf;
                      %subst(DCLPR.procName:16:1) = *Blank;
                   EndIf;
                EndIf;

                // Keywords.
                If workDeclKeywords <> *Blanks;
                   // ExtProc name has extended to a second line.
                   If inExtProc;
                      // Continuation of name must start at left margin.
                      DCLPR = workDeclKeywords;
                      workDeclKeywords = *Blanks;
                      inExtProc = *Off;
                   EndIf;

                   // Expand EXTNAME?
                   x = %scan('EXTNAME(':%xlate(lo:up:workDeclKeywords));
                   If x > 0;
                      i = %scan(')':workDeclKeywords:x+1);
                      If i > 0;
                         If %scan('''':%subst(workDeclKeywords:x+8:i-x-8)) = 0;
                            workDeclKeywords = %subst(workDeclKeywords:1:x+7)
                               + ''''
                       + %xlate(lo:up:%trim(%subst(workDeclKeywords:x+8:i-x-8)))
                               + ''''
                               + %subst(workDeclKeywords:i);
                         EndIf;
                      EndIf;
                   EndIf;

                   // Expand DTAARA?
                   x = %scan('DTAARA(':%xlate(lo:up:workDeclKeywords));
                   If x > 0;
                      i = %scan(')':workDeclKeywords:x+1);
                      If i > 0;
                         If %scan('''':%subst(workDeclKeywords:x+7:i-x-7)) = 0;
                            workDeclKeywords = %subst(workDeclKeywords:1:x+6)
                               + ''''
                       + %xlate(lo:up:%trim(%subst(workDeclKeywords:x+7:i-x-7)))
                               + ''''
                               + %subst(workDeclKeywords:i);
                         EndIf;
                      EndIf;
                   EndIf;

                   // EXTPROC?
                   x = %scan('EXTPROC(':%xlate(lo:up:workDeclKeywords));
                   If x > 0;
                      i = %scan(')':workDeclKeywords:x+1);
                      If i = 0;
                         // Name extends onto next line.
                         inExtProc = *On;
                      EndIf;
                   EndIf;
                EndIf;

                // Terminate the line?
                If not inSpan;
                   If workDeclKeywords = *Blanks and DCLPR.type = *Blanks;
                      DCLPR.procName = %trimr(DCLPR.procName) + ';';
                   ElseIf workDeclKeywords = *Blanks;
                      DCLPR.definition = %trimr(DCLPR.definition) + ';';
                   Else;
                      workDeclKeywords = %trimr(workDeclKeywords) + ';';
                   EndIf;
                   inDeclaration = *Off;
                   savedName = *Blanks;
                Else;
                   inSpan = *Off;
                EndIf;

                // Have we encroached on the comments?
                x = %len(%trimr(DCLPR.definition)) + %len(workDeclKeywords);
                If x >= 37;
                   x = x - %len(%trimr(DCLPR.definition));
                   SplitLine(workDeclKeywords:overflowLine:x);
                   indentOffset = 37;
                EndIf;

                If DCLPR.definition = *Blanks and DCLPR.type = *Blanks;
                   DCLPR.definition = %trim(workDeclKeywords);
                Else;
                   DCLPR.definition = %trimr(DCLPR.definition) + ' '
                                   + %trim(workDeclKeywords);
                EndIf;

                // Comment.
                If comment <> *Blanks;
                   If %subst(%trim(comment) + ' ':1:2) = '//';
                      DCLPR.comment = '   ' + comment;
                   Else;
                      DCLPR.comment = '// ' + comment;
                   EndIf;
                EndIf;

                // Converted line...
                sourceLine = DCLPR;
                If not inSpan and savedName <> *Blanks;
                   savedName = '**';
                EndIf;

                //-------------------------------------------------------------------------
                // Unsupported.
                //-------------------------------------------------------------------------
             Else;
                inDeclaration = *Off;
                convert = *Off;
                LeaveSr;
             EndIf;

             //-------------------------------------------------------------------------
             // Second+ line of declaration.
             //-------------------------------------------------------------------------
          Else;
             Clear DCLS;
             DCLS.definition = %trim(workDeclKeywords);
             If not inSpan;
                DCLS.definition = %trim(DCLS.definition) + ';';
             EndIf;
             sourceLine = DCLS;
             inSpan = *Off;
          EndIf;

          convert = *On;

       EndSr;
       //-------------------------------------------------------------------------------------------

      /Eject
       //-------------------------------------------------------------------------------------------
       // Convert file spec to free-format.
       //-------------------------------------------------------------------------------------------
       BegSr subUserConvertF_Spec;

          // Keep blank lines.
          If codeLine = *Blanks;
             sourceLine = *Blanks;
             convert = *On;
             LeaveSr;
          EndIf;

          sourceLine = fullLine;

          workFileUsage  = %xlate(lo:up:fileUsage);
          workFileDesig  = %xlate(lo:up:fileDesig);
          workFileAdd    = %xlate(lo:up:fileAdd);
          workFileDevice = %xlate(lo:up:fileDevice);
          workFileKeyed  = %xlate(lo:up:fileKeyed);

          Exsr subUserCheckSpan;  // Does this line span more than one line?

          If not inDeclaration;

             // Validate whether this can be converted.
             If workFileUsage = 'I'
             and (workFileDesig = 'P'
             or workFileDesig = 'S'
             or workFileUsage = 'T')

             or workFileUsage = 'O'
             and workFileAdd = 'A'

             or workFileUsage = 'U'
             and (workFileDesig = 'P'
             or workFileDesig = 'S')

             or workFileUsage = 'C'
             and workFileDesig = 'T';

                // Not supported in free-form.
                inDeclaration = *Off;
                convert = *Off;
                nonConvRsn = 'File usage not supported in free-form';
                LeaveSr;
             EndIf;

             savedName = %trim(fileName);

             If %xlate(lo:up:fileExternal) = 'E';       // Externally-described file.
                inDeclaration = *On;

                Clear DCLF;
                DCLF.decl = 'Dcl-F ';
                %subst(DCLF:7) = %xlate(lo:up:savedName);

                // Set device type.
                If workFileDevice <> 'DISK';
                   DCLF.device = workFileDevice;
                EndIf;

                // Set usage.
                If workFileUsage = 'I';
                   If workFileAdd = ' ';
                      If workFileDevice <> 'DISK'
                      and workFileDevice <> 'SEQ'
                      and workFileDevice <> 'SPECIAL';
                         DCLF.definition = '*INPUT';
                      EndIf;
                   Else;
                      DCLF.definition = '*INPUT:*OUTPUT';
                   EndIf;
                ElseIf workFileUsage = 'U';
                   If workFileAdd = ' ';
                      DCLF.definition = '*UPDATE:*DELETE';
                   Else;
                      DCLF.definition = '*UPDATE:*DELETE:*OUTPUT';
                   EndIf;
                ElseIf workFileUsage = 'O';
                   If workFileDevice <> 'PRINTER';
                      DCLF.definition = '*OUTPUT';
                   EndIf;
                ElseIf workFileUsage = 'C';
                   If workFileDevice <> 'WORKSTN';
                      DCLF.definition = '*INPUT:*OUTPUT';
                   EndIf;
                EndIf;

                // Pad out usage.
                If DCLF.definition <> *Blanks;
                   DCLF.definition = 'Usage(' + %trim(DCLF.definition) + ')';
                EndIf;

                // Keyed file?
                If workFileKeyed = 'K';
                   DCLF.definition = %trim(%trim(DCLF.definition)
                                           + ' ' + 'Keyed');
                EndIf;

                If comment <> *Blanks;
                   If %subst(%trim(comment):1:2) = '//';
                      DCLF.comment = '   ' + comment;
                   Else;
                      DCLF.comment = '// ' + comment;
                   EndIf;
                EndIf;

                // Keywords.
                If fileKeyWords <> *Blanks;
                   // Do we have room to insert the keywords here?
                   checkLength = %len(%trim(%trim(DCLF.definition)
                                           + ' ' + %trim(fileKeyWords))) + 1;

                   If comment <> *Blanks;
                      checkLength += 3;
                   EndIf;

                   If checkLength > %len(DCLF.definition);
                      // Not enoungh room for the keywords, so output the current line.
                      savedSRCDTA = SRCDTA;
                      lineType = *Blank;
                      directive = *Blanks;
                      codeLine = DCLF;
                      Exsr subUserWriteLine;
                      SRCDTA = savedSRCDTA;
                      // ...and move the keywords to their own line.
                      Clear DCLF;
                      DCLF.definition = fileKeywords;
                      savedComment = *Blanks;
                   Else;
                      DCLF.definition = %trim(%trim(DCLF.definition)
                                              + ' ' + %trim(fileKeyWords));
                   EndIf;
                EndIf;

                If not inSpan;
                   DCLF.definition = %trimr(DCLF.definition) + ';';
                   inDeclaration = *Off;
                Else;
                   inSpan = *Off;
                EndIf;

                // Converted line...
                sourceLine = DCLF;

             Else;
                inDeclaration = *Off;
                convert = *Off;
                nonConvRsn = 'File not externally-described';
                LeaveSr;
             EndIf;

          Else;                   // Second+ line of declaration
             Clear DCLF;
             DCLF.definition = %trim(fileKeyWords);
             If not inSpan;
                DCLF.definition = %trim(DCLF.definition) + ';';
             EndIf;
             sourceLine = DCLF;
             inSpan = *Off;
          EndIf;

          convert = *On;

       EndSr;
       //-------------------------------------------------------------------------------------------

      /Eject
       //-------------------------------------------------------------------------------------------
       // Convert Header spec to free-format.
       //-------------------------------------------------------------------------------------------
       BegSr subUserConvertH_Spec;

          // Keep blank lines.
          If codeLine = *Blanks;
             sourceLine = *Blanks;
             convert = *On;
             LeaveSr;
          EndIf;

          sourceLine = codeLine;

          Exsr subUserCheckSpan;  // Does this line span more than one line?

          If not inDeclaration;
             inDeclaration = *On;

             Clear DCLH;
             DCLH.decl = 'Ctl-Opt ';
             DCLH.options = %trim(declOptions);

             If comment <> *Blanks;
                If %subst(%trim(comment):1:2) = '//';
                   DCLH.comment = '   ' + comment;
                Else;
                   DCLH.comment = '// ' + comment;
                EndIf;
             EndIf;

             If not inSpan;
                DCLH.options = %trimr(DCLH.options) + ';';
                inDeclaration = *Off;
             Else;
                inSpan = *Off;
             EndIf;

             // Converted line...
             sourceLine = DCLH;

          Else;                   // Second+ line of declaration
             Clear DCLH;
             DCLH.options = %trim(declOptions);
             If not inSpan;
                DCLH.options = %trim(DCLH.options) + ';';
             EndIf;
             sourceLine = DCLH;
             inSpan = *Off;
          EndIf;

          convert = *On;

       EndSr;
       //-------------------------------------------------------------------------------------------

      /Eject
       //-------------------------------------------------------------------------------------------
       // Convert procedure declaration to free-format?
       //-------------------------------------------------------------------------------------------
       BegSr subUserConvertP_Spec;

          // Keep blank lines.
          If codeLine = *Blanks;
             sourceLine = *Blanks;
             convert = *On;
             LeaveSr;
          EndIf;

          sourceLine = fullLine;

          Exsr subUserCheckSpan;  // Does this line span more than one line?

          If not inDeclaration;   // First line of procedure start/end.
             If not inDeclaration;
                //Exsr subUserGetDeclarationType;
                GetDeclarationType(workDeclType:savedName:workDeclLine);
             EndIf;

             If workDeclType = 'B'       // Begin.
             or workDeclType = 'E'       // End.
             or declName <> *Blanks;
                inDeclaration = *On;

                Clear DCLP;
                //            If savedName <> *Blanks;
                If workDeclType = 'B';
                   DCLP.decl = 'Dcl-Proc ';
                Else;
                   DCLP.decl = 'End-Proc ';
                EndIf;
                DCLP.definition = savedName;
                //            EndIf;

                If procKeyWords <> *Blanks;
                   DCLP.definition = %trimr(DCLP.definition)
                                   + ' ' + %trim(procKeyWords);
                EndIf;

                If comment <> *Blanks;
                   If %subst(%trim(comment):1:2) = '//';
                      DCLP.comment = '   ' + comment;
                   Else;
                      DCLP.comment = '// ' + comment;
                   EndIf;
                EndIf;

                If not inSpan;
                   DCLP.definition = %trimr(DCLP.definition) + ';';
                   inDeclaration = *Off;
                Else;
                   inSpan = *Off;
                EndIf;

                // Converted line...
                sourceLine = DCLP;
                savedName = *Blanks;

             Else;
                inDeclaration = *Off;
                convert = *Off;
                LeaveSr;
             EndIf;

          Else;                   // Second+ line of procedure start/end.
             Clear DCLP;
             DCLP.definition = %trim(declKeyWords);
             If not inSpan;
                DCLP.definition = %trimr(DCLP.definition) + ';';
             EndIf;
             sourceLine = DCLP;
             inSpan = *Off;
          EndIf;

          convert = *On;

       EndSr;
       //-------------------------------------------------------------------------------------------

      /Eject
       //-------------------------------------------------------------------------------------------
       // Set Resulting Indicators.
       //-------------------------------------------------------------------------------------------
       BegSr subUserSetIndicators;

          //-----------------------------------------------------------------------
          // Scan found.
          If foundCheck;
             Clear nonPrefix;

             codeLine = '*IN' + foundInd + ' = %found();';
             Exsr subUserReformatLine;

             foundCheck = *Off;
          EndIf;

          //-----------------------------------------------------------------------
          // Error indicator check.
          If ERRCheck;
             Clear nonPrefix;

             codeLine = '*IN' + ERRInd + ' = %error();';
             Exsr subUserReformatLine;

             ERRCheck = *Off;
          EndIf;

          //-----------------------------------------------------------------------
          // Record not found check.
          If NRFCheck;
             Clear nonPrefix;

             codeLine = '*IN' + NRFInd + ' = not %found();';
             Exsr subUserReformatLine;

             NRFCheck = *Off;
          EndIf;

          //-----------------------------------------------------------------------
          // End of File check.
          If EOFCheck;
             Clear nonPrefix;

             codeLine = '*IN' + EOFInd + ' = %eof();';
             Exsr subUserReformatLine;

             EOFCheck = *Off;
          EndIf;

          //-----------------------------------------------------------------------
          // Matching Key check.
          If equalCheck;
             Clear nonPrefix;

             codeLine = '*IN' + equalInd + ' = %equal();';
             Exsr subUserReformatLine;

             equalCheck = *Off;
          EndIf;

          //-----------------------------------------------------------------------
          // Perform SETOFF / SETON Expansion.
          If setOff;
             Clear nonPrefix;
             If setOffInd1 <> *Blanks;
                codeLine = '*IN' + setOffInd1 + ' = *Off;';
                Exsr subUserReformatLine;
             EndIf;
             If setOffInd2 <> *Blanks;
                codeLine = '*IN' + setOffInd2 + ' = *Off;';
                Exsr subUserReformatLine;
             EndIf;
             If setOffInd3 <> *Blanks;
                codeLine = '*IN' + setOffInd3 + ' = *Off;';
                Exsr subUserReformatLine;
             EndIf;
             setOff = *Off;
          EndIf;
          If setOn;
             Clear nonPrefix;
             If setOnInd1 <> *Blanks;
                codeLine = '*IN' + setOnInd1 + ' = *On;';
                Exsr subUserReformatLine;
             EndIf;
             If setOnInd2 <> *Blanks;
                codeLine = '*IN' + setOnInd2 + ' = *On;';
                Exsr subUserReformatLine;
             EndIf;
             If setOnInd3 <> *Blanks;
                codeLine = '*IN' + setOnInd3 + ' = *On;';
                Exsr subUserReformatLine;
             EndIf;
             setOn = *Off;
          EndIf;

          //-----------------------------------------------------------------------
          // Resulting indicators...

          // Turn off all specified indicators first.
          If HICheck;
             Clear nonPrefix;
             codeLine = '*IN' + HIInd + ' = *Off;';
             Exsr subUserReformatLine;
          EndIf;
          If LWCheck;
             Clear nonPrefix;
             codeLine = '*IN' + LWInd + ' = *Off;';
             Exsr subUserReformatLine;
          EndIf;
          If EQCheck;
             Clear nonPrefix;
             codeLine = '*IN' + EQInd + ' = *Off;';
             Exsr subUserReformatLine;
          EndIf;

          // And now turn on those specified accordingly.

          // HI check.
          If HICheck;
             Clear nonPrefix;

             codeLine = 'If ' + %trim(HIFactor1) + ' > '
                      + %trim(HIFactor2) + ';';
             Exsr subUserReformatLine;
             codeLine = '*IN' + HIInd + ' = *On;';
             Exsr subUserReformatLine;
             codeLine = 'EndIf;';
             Exsr subUserReformatLine;

             HICheck = *Off;
          EndIf;

          // LO check.
          If LWCheck;
             Clear nonPrefix;

             codeLine = 'If ' + %trim(LWFactor1) + ' < '
                      + %trim(LWFactor2) + ';';
             Exsr subUserReformatLine;
             codeLine = '*IN' + LWInd + ' = *On;';
             Exsr subUserReformatLine;
             codeLine = 'EndIf;';
             Exsr subUserReformatLine;

             LWCheck = *Off;
          EndIf;

          // EQ check.
          If EQCheck;
             Clear nonPrefix;

             codeLine = 'If ' + %trim(EQFactor1) + ' = '
                      + %trim(EQFactor2) + ';';
             Exsr subUserReformatLine;
             codeLine = '*IN' + EQInd + ' = *On;';
             Exsr subUserReformatLine;
             codeLine = 'EndIf;';
             Exsr subUserReformatLine;

             EQCheck = *Off;
          EndIf;

       EndSr;
       //-------------------------------------------------------------------------------------------

      /Eject
       //-------------------------------------------------------------------------------------------
       // Convert ACQ.
       //-------------------------------------------------------------------------------------------
       BegSr subUserCvt_ACQ;

          sourceLine = %trim(operator) + ' ' + %trim(factor1)
                     + ' ' + %trim(factor2) + ';';

          // Set resulting indicators?
          If lw <> *Blanks;
             ERRCheck = *On;
             ERRInd = lw;
          EndIf;

          convert = *On;

       EndSr;
       //-------------------------------------------------------------------------------------------

      /Eject
       //-------------------------------------------------------------------------------------------
       // Convert ADD.
       //-------------------------------------------------------------------------------------------
       BegSr subUserCvt_ADD;

          // Half-adjust?
          x = %scan('H':operator:4);
          If x > 0;
             sourceLine = 'Eval(H)';
          Else;
             sourceLine = *Blanks;
          EndIf;

          If factor1 = *Blanks;
             sourceLine = %trimr(sourceLine) + ' ' + %trim(result)
                        + ' = ' + %trim(result)
                        + ' + ' + %trim(factor2) +';';
          Else;
             sourceLine = %trimr(sourceLine) + ' ' + %trim(result)
                        + ' = ' + %trim(factor1)
                        + ' + ' + %trim(factor2) + ';';
          EndIf;

          sourceLine = %trim(sourceLine);

          convert = *On;

       EndSr;
       //-------------------------------------------------------------------------------------------

      /Eject
       //-------------------------------------------------------------------------------------------
       // Convert ADDDUR.
       //-------------------------------------------------------------------------------------------
       BegSr subUserCvt_ADDDUR;

          // Split out duration and code.
          x = %scan(':':factor2);
          If x = 0;
             nonConvRsn =  'No duration code specified.';
             LeaveSr;
          EndIf;

          durDuration = %trim(%subst(factor2:1:x-1));
          durCode     = %xlate(lo:up:%trim(%subst(factor2:x+1)));

          Select;
             When durCode = '*Y' or durCode = '*YEARS';
                durCode = '%years';
             When durCode = '*M' or durCode = '*MONTHS';
                durCode = '%months';
             When durCode = '*D' or durCode = '*DAYS';
                durCode = '%days';
             When durCode = '*H' or durCode = '*HOURS';
                durCode = '%hours';
             When durCode = '*MN' or durCode = '*MINUTES';
                durCode = '%minutes';
             When durCode = '*S' or durCode = '*SECONDS';
                durCode = '%seconds';
             When durCode = '*MS' or durCode = '*MSECONDS';
                durCode = '%mseconds';
             Other;
                nonConvRsn = 'Invalid duration code specified.';
                LeaveSr;
          EndSl;

          If factor1 = *Blanks;
             sourceLine = %trim(result) + ' = ' + %trim(result);
          Else;
             sourceLine = %trim(result) + ' = ' + %trim(factor1);
          EndIf;

          sourceLine = %trimr(sourceLine) + ' + ' + %trim(durCode)
                     + '(' + %trim(durDuration) + ');';

          // Set resulting indicators?
          If lw <> *Blanks;
             ERRCheck = *On;
             ERRInd = lw;
          EndIf;

          convert = *On;

       EndSr;
       //-------------------------------------------------------------------------------------------

      /Eject
       //-------------------------------------------------------------------------------------------
       // Convert ALLOC.
       //-------------------------------------------------------------------------------------------
       BegSr subUserCvt_ALLOC;

          sourceLine = %trim(result) + ' = %alloc(' + %trim(factor2) + ');';

          // Set resulting indicators?
          If lw <> *Blanks;
             ERRCheck = *On;
             ERRInd = lw;
          EndIf;

          convert = *On;

       EndSr;
       //-------------------------------------------------------------------------------------------

      /Eject
       //-------------------------------------------------------------------------------------------
       // Convert BEGSR.
       //-------------------------------------------------------------------------------------------
       BegSr subUserCvt_BEGSR;

          sourceLine = 'BegSr ' + %trim(factor1) + ';';

          convert = *On;

       EndSr;
       //-------------------------------------------------------------------------------------------

      /Eject
       //-------------------------------------------------------------------------------------------
       // Convert CALLP.
       //-------------------------------------------------------------------------------------------
       BegSr subUserCvt_CALLP;

          // Returning for a multi-line CALLP - restore the original opcode.
          If inCallP;
             operator = callPOperator;
          EndIf;

          Exsr subUserCheckSpan;  // Does this line span more than one line?

          If not inCallP;         // First line of CALLP.
             sourceLine = %trimr(operator) + ' ' + %trim(extFactor2);
             If not inSpan;
                sourceLine = %trim(sourceLine) + ';';
             Else;
                callPOffset = %len(%trim(operator)) + 2;
                inCallP = *On;
                inSpan = *Off;
             EndIf;
          Else;                   // Second+ line of CALLP.
             sourceLine = *Blanks;
             sourceLine = %trim(extFactor2);
             If not inSpan;
                sourceLine = %trimr(sourceLine) + ';';
                //            inCallP = *Off;
             EndIf;
             inSpan = *Off;
          EndIf;

          // Multi-line CALLP?  Save the opcode.
          If inCallP;
             callPOperator = operator;
          Else;
             callPOperator = *Blanks;
          EndIf;

          convert = *On;

       EndSr;
       //-------------------------------------------------------------------------------------------

      /Eject
       //-------------------------------------------------------------------------------------------
       // Convert CASxx.
       //-------------------------------------------------------------------------------------------
       BegSr subUserCvt_CASxx;

          // Extract components.
          caseSubRoutine = %trim(result);
          caseOperator = %subst(operator:4:2);

          // Determine comparator.
          If caseOperator = 'EQ';
             caseOperator = '=';
          ElseIf caseOperator = 'GT';
             caseOperator = '>';
          ElseIf caseOperator = 'LT';
             caseOperator = '<';
          ElseIf caseOperator = 'GE';
             caseOperator = '>=';
          ElseIf caseOperator = 'LE';
             caseOperator = '<=';
          ElseIf caseOperator = 'NE';
             caseOperator = '<>';
          Else;
             caseOperator = 'Else';
          EndIf;

          // Build 'If' statement.
          If not inCase;
             sourceLine = 'If ' +  %trim(factor1) + ' '
                        + %trim(caseOperator) + ' ' + %trim(factor2)
                        + ';';
             inCase = *On;
          Else;
             If caseOperator = 'Else';
                sourceLine = 'Else;';
             Else;
                sourceLine = 'ElseIf ' +  %trim(factor1) + ' '
                           + %trim(caseOperator) + ' ' + %trim(factor2)
                           + ';';
             EndIf;
          EndIf;

          // Do we need to set Resulting indicators?
          If hi <> *Blanks;
             HICheck = *On;
             HIInd = hi;
             HIFactor1 = %trim(factor1);
             HIFactor2 = %trim(factor2);
          EndIf;
          If lw <> *Blanks;
             LWCheck = *On;
             LWInd = lw;
             LWFactor1 = %trim(factor1);
             LWFactor2 = %trim(factor2);
          EndIf;
          If eq <> *Blanks;
             EQCheck = *On;
             EQInd = eq;
             EQFactor1 = %trim(factor1);
             EQFactor2 = %trim(factor2);
          EndIf;

          convert = *On;

       EndSr;
       //-------------------------------------------------------------------------------------------

      /Eject
       //-------------------------------------------------------------------------------------------
       // Convert CAT.
       //-------------------------------------------------------------------------------------------
       BegSr subUserCvt_CAT;

          // Pad the result?
          x = %scan('P':operator:4);
          If x = 0                                              // Not padding.
          and factor1 <> *Blanks                                // Factor1 specified.
          and %xlate(lo:up:factor1) <> %xlate(lo:hi:result);    // Factor1 not the same as result
             nonConvRsn =  'No padding specified, result unpredictable.';
             LeaveSr;    // Don't convert - too difficult to get right.
          EndIf;

          // Drop the extender.
          operator = 'CAT';

          // Determine first part of string.
          If factor1 = *Blanks;
             catFactor1 = %trim(result);
          Else;
             catFactor1 = %trim(factor1);
          EndIf;

          // Determine number of blanks.
          x = %scan(':':factor2);
          If x = 0;   // No trimming required;
             catBlanks = *Blanks;
             catFactor2 = %trim(factor2);
          Else;
             catBlanks = %subst(factor2:x+1);
             catFactor2 = %subst(factor2:1:x-1);
          EndIf;

          // Determine second part of String.

          // Blanks zero?
          If catBlanks <> *blanks;
             Monitor;
                catCount = %dec(catBlanks:3:0);
             On-Error;
                LeaveSr; // Uses a field to vary the number of blanks - don't convert.
             EndMon;
          EndIf;

          // Build the new line.
          If catBlanks = *Blanks;
             // No trimming.
             sourceLine = %trim(result) + ' = ' + %trim(catFactor1)
                        + ' + ' + %trim(catFactor2) + ';';
          ElseIf catCount = 0;
             // No spaces.
             sourceLine = %trim(result) + ' = %trimr(' + %trim(catFactor1)
                        + ') + %trim(' + %trim(catFactor2) + ');';
          ElseIf catCount > 25;
             LeaveSr; // Arbitrary upper limit - don't convert.
          Else;
             sourceLine = %trim(result) + ' = %trimr(' + %trim(catFactor1)
                        + ') + ''' + %str(%addr(blanks):catCount)
                        + ''' + %trim(' + %trim(catFactor2) + ');';
          EndIf;

          // Set resulting indicators?
          If lw <> *Blanks;
             ERRCheck = *On;
             ERRInd = lw;
          EndIf;

          convert = *On;

       EndSr;
       //-------------------------------------------------------------------------------------------

      /Eject
       //-------------------------------------------------------------------------------------------
       // Convert CHAIN.
       //-------------------------------------------------------------------------------------------
       BegSr subUserCvt_CHAIN;

          sourceLine = %trim(operator) + ' ' + %trim(factor1) + ' '
                     + %trim(factor2);

          If result <> *Blanks;
             sourceLine = %trim(sourceLine)  + ' ' + %trim(result) + ';';
          Else;
             sourceLine = %trim(sourceLine)  + ';';
          EndIf;

          // Set resulting indicators?
          If hi <> *Blanks;
             NRFCheck = *On;
             NRFInd = hi;
             NRFFile = %trim(factor2);
          EndIf;
          If lw <> *Blanks;
             ERRCheck = *On;
             ERRInd = lw;
          EndIf;

          convert = *On;

       EndSr;
       //-------------------------------------------------------------------------------------------

      /Eject
       //-------------------------------------------------------------------------------------------
       // Convert CHECK.
       //-------------------------------------------------------------------------------------------
       BegSr subUserCvt_CHECKx;

          // Don't convert of no result specified.
          If result = *Blanks;
             nonConvRsn = 'No result field specified.';
             LeaveSr;
          EndIf;

          If %subst(operator:1:5) = 'CHECKR';
             operator = '%checkr(';
          Else;
             operator = '%check(';
          EndIf;

          // Determine starting point.
          x = %scan(':':factor2);

          // Build the new line.
          If x = 0;
             // No start specified.
             sourceLine = %trim(result) + ' = ' + %trim(operator)
                        + %trim(factor1) + ':' + %trim(factor2) + ');';
          Else;
             // Start from a specified point.
             sourceLine = %trim(result) + ' = ' + %trim(operator)
                        + %trim(factor1) + ':' + %subst(factor2:1:x-1)
                        + ':' + %trim(%subst(factor2:x+1))
                        + ');';
          EndIf;

          // Set resulting indicators?
          If lw <> *Blanks;
             ERRCheck = *On;
             ERRInd = lw;
          EndIf;
          If eq <> *Blanks;
             HICheck = *On;
             HIInd = eq;
             HIFactor1 = result;
             HIFactor2 = '0';
          EndIf;

          convert = *On;

       EndSr;
       //-------------------------------------------------------------------------------------------

      /Eject
       //-------------------------------------------------------------------------------------------
       // Convert CLEAR.
       //-------------------------------------------------------------------------------------------
       BegSr subUserCvt_CLEAR;

          sourceLine = 'Clear ' + %trim(result) + ';';

          convert = *On;

       EndSr;
       //-------------------------------------------------------------------------------------------

      /Eject
       //-------------------------------------------------------------------------------------------
       // Convert CLOSE.
       //-------------------------------------------------------------------------------------------
       BegSr subUserCvt_CLOSE;

          sourceLine = %trim(operator) + ' ' + %trim(factor2) + ';';

          If lw <> *Blanks;
             ERRCheck = *On;
             ERRInd = lw;
          EndIf;

          convert = *On;

       EndSr;
       //-------------------------------------------------------------------------------------------

      /Eject
       //-------------------------------------------------------------------------------------------
       // Convert COMMIT.
       //-------------------------------------------------------------------------------------------
       BegSr subUserCvt_COMMIT;

          sourceLine = %trim(operator) + ' ' + %trim(factor1);

          sourceLine = %trim(sourceLine)  + ';';

          // Check indicators?
          If lw <> *Blanks;
             ERRCheck = *On;
             ERRInd = lw;
          EndIf;

          convert = *On;

       EndSr;
       //-------------------------------------------------------------------------------------------

      /Eject
       //-------------------------------------------------------------------------------------------
       // Convert COMP.
       //-------------------------------------------------------------------------------------------
       BegSr subUserCvt_COMP;

          // Set resulting indicators to check.
          If hi <> *Blanks;
             HICheck = *On;
             HIInd = hi;
             HIFactor1 = factor1;
             HIFactor2 = factor2;
          EndIf;

          If lw <> *Blanks;
             LWCheck = *On;
             LWInd = lw;
             LWFactor1 = factor1;
             LWFactor2 = factor2;
          EndIf;

          If eq <> *Blanks;
             EQCheck = *On;
             EQInd = eq;
             EQFactor1 = factor1;
             EQFactor2 = factor2;
          EndIf;

          // Drop the current line.
          dropLine = *On;
          convert = *On;

       EndSr;
       //-------------------------------------------------------------------------------------------

      /Eject
       //-------------------------------------------------------------------------------------------
       // Convert DEALLOC.
       //-------------------------------------------------------------------------------------------
       BegSr subUserCvt_DEALLOC;

          sourceLine = %trim(operator) + ' ' + %trim(result);

          sourceLine = %trim(sourceLine)  + ';';

          // Set resulting indicators?
          If lw <> *Blanks;
             ERRCheck = *On;
             ERRInd = lw;
          EndIf;

          convert = *On;

       EndSr;
       //-------------------------------------------------------------------------------------------

      /Eject
       //-------------------------------------------------------------------------------------------
       // Convert DELETE.
       //-------------------------------------------------------------------------------------------
       BegSr subUserCvt_DELETE;

          sourceLine = %trim(operator) + ' ' + %trim(factor2);

          sourceLine = %trim(sourceLine)  + ';';

          // Check indicators?
          If hi <> *Blanks;
             NRFCheck = *On;
             NRFInd = eq;
             NRFFile = %trim(factor2);
          EndIf;
          If lw <> *Blanks;
             ERRCheck = *On;
             ERRInd = lw;
          EndIf;

          convert = *On;

       EndSr;
       //-------------------------------------------------------------------------------------------

      /Eject
       //-------------------------------------------------------------------------------------------
       // Convert DIV.
       //-------------------------------------------------------------------------------------------
       BegSr subUserCvt_DIV;

          // Half-adjust?
          If %scan('H':operator:4) > 0;
             sourceLine = 'Eval(H) ';
          Else;
             sourceLine = *Blanks;
          EndIf;

          If factor1 = *Blanks;
             divFactor1 = result;
             divFactor2 = factor2;
          Else;
             divFactor1 = factor1;
             divFactor2 = factor2;
          EndIf;

          sourceLine = %trim( %trimr(sourceLine) + ' ' + %trim(result)
                     + ' = ' + %trim(divFactor1) + ' / '
                     + %trim(divFactor2) + ';');

          convert = *On;

       EndSr;
       //-------------------------------------------------------------------------------------------

      /Eject
       //-------------------------------------------------------------------------------------------
       // Convert DO.
       //-------------------------------------------------------------------------------------------
       BegSr subUserCvt_DO;

          If inDo;
             operator = doOperator;
          EndIf;

          Exsr subUserCheckSpan;  // Does this line span more than one line?

          If operator = 'DOW'     // Use Extended Factor2.
          or operator = 'DOU';    // Use Extended Factor2.
             If not inDo;         // First line of DO.
                sourceLine = %trim(operator) + ' ' + %trim(extFactor2);
                If not inSpan;
                   sourceLine = %trim(sourceLine) + ';';
                Else;
                   inDo = *On;
                   inSpan = *Off;
                EndIf;
             Else;                   // Second line of DO.
                sourceLine = *Blanks;
                //            %subst(sourceLine:40) = %trim(extFactor2);
                sourceLine = %trim(extFactor2);
                If not inSpan;
                   sourceLine = %trimr(sourceLine) + ';';
                   //               inDo = *Off;
                EndIf;
                inSpan = *Off;
             EndIf;
             doCompare = '!!';    // Just a regular DO.
          Else;
             // Fixed format.
             opCode = %xlate(lo:up:opCode);
             If not inDo;         // First line of DO.
                doCompare = %subst(opCode:4:2);
                sourceLine = %subst(opcode:1:3);
             Else;                // Second line of DO.
                If %subst(opCode:1:3) = 'AND';
                   doCompare = %subst(opCode:4:2);
                   sourceLine = 'And';
                Else;
                   doCompare = %subst(opCode:3:2);
                   sourceLine = 'Or';
                EndIf;
             EndIf;

             If doCompare = 'EQ';
                doCompare = '=';
             ElseIf doCompare = 'GT';
                doCompare = '>';
             ElseIf doCompare = 'GE';
                doCompare = '>=';
             ElseIf doCompare = 'LT';
                doCompare = '<';
             ElseIf doCompare = 'LE';
                doCompare = '<=';
             ElseIf doCompare = 'NE';
                doCompare = '<>';
             ElseIf doCompare = '!!';
                // Do nothing.
                Else;    // Just DO - convert to FOR.
                If factor1 = *Blanks;
                   forFactor1 = '1';
                Else;
                   forFactor1 = factor1;
                EndIf;
                forFactor2 = factor2;
                factor1 = *Blanks;
                factor2 = *Blanks;
                doCompare = *Blanks;
                If result = *Blanks;
                   result = '???';
                EndIf;
                sourceLine = 'For ' + %trim(result) + ' = '
                           + %trim(forFactor1) + ' To '
                           + %trim(forFactor2);
             EndIf;

             //         If doCompare = *Blanks;
         //            // Save current indentation level to match up to the associated ENDDO later.
             //            forCount += 1;
             //            forLevel(forCount) = indentCount;
             //         Else;
         //            // Save current indentation level to match up to the associated ENDDO later.
             //            doCount += 1;
             //            doLevel(doCount) = indentCount;
             //         EndIf;

             sourceLine = %trimr(sourceLine) + ' ' + %trim(factor1)
                                + ' ' + %trim(doCompare) + ' '
                                + %trim(factor2);
             If not inSpan;
                sourceLine = %trimr(sourceLine) + ';';
                inDo = *Off;
             Else;
                inDo = *On;
                inSpan = *Off;
             EndIf;
          EndIf;

          // If multi-line, retain the original opcode.
          If inDo;
             doOperator = operator;
          Else;
             doOperator = *Blanks;
          EndIf;

          convert = *On;

       EndSr;
       //-------------------------------------------------------------------------------------------

      /Eject
       //-------------------------------------------------------------------------------------------
       // Convert DSPLY.
       //-------------------------------------------------------------------------------------------
       BegSr subUserCvt_DSPLY;

          sourceLine = %trim(operator);

          If factor1 <> *Blanks;
             sourceLine = %trimr(sourceLine) + ' ' + %trim(factor1);
             If factor2 <> *Blanks;
                sourceLine = %trimr(sourceLine) + ' ' + %trim(factor2);
             ElseIf result <> *Blanks;
                sourceLine = %trimr(sourceLine) + ' ''''';
             EndIf;
             If result <> *Blanks;
                sourceLine = %trimr(sourceLine) + ' ' + %trim(result);
             EndIf;
          EndIf;

          sourceLine = %trimr(sourceLine) + ';';

          // Set resulting indicators?
          If lw <> *Blanks;
             ERRCheck = *On;
             ERRInd = lw;
          EndIf;

          convert = *On;

       EndSr;
       //-------------------------------------------------------------------------------------------

      /Eject
       //-------------------------------------------------------------------------------------------
       // Convert DUMP.
       //-------------------------------------------------------------------------------------------
       BegSr subUserCvt_DUMP;

          If factor1 <> *Blanks;
             sourceLine = %trim(operator) + ' ' + %trim(factor1) + ';';
          Else;
             sourceLine = %trim(operator) + ';';
          EndIf;

          convert = *On;

       EndSr;
       //-------------------------------------------------------------------------------------------

      /Eject
       //-------------------------------------------------------------------------------------------
       // Convert ELSE.
       //-------------------------------------------------------------------------------------------
       BegSr subUserCvt_ELSE;

          sourceLine = 'Else;';

          convert = *On;

       EndSr;
       //-------------------------------------------------------------------------------------------

      /Eject
       //-------------------------------------------------------------------------------------------
       // Convert ELSEIF.
       //-------------------------------------------------------------------------------------------
       BegSr subUserCvt_ELSEIF;

          sourceLine = 'ElseIf ' + %trim(factor2) + ';';

          convert = *On;

       EndSr;
       //-------------------------------------------------------------------------------------------

      /Eject
       //-------------------------------------------------------------------------------------------
       // Convert ENDxx.
       //-------------------------------------------------------------------------------------------
       BegSr subUserCvt_ENDxx;

          // Catch labels on ENDSR.
          If %trim(operator) = 'ENDSR';
             If %len(%trim(factor1)) > 0;
                nonConvRsn = 'Label on ENDSR is not supported in free-form';
                LeaveSr;
             EndIf;
          EndIf;

          // Do we need to convert an ENDDO to ENDFOR?
          If %trim(operator) = 'ENDDO' or %trim(operator) = 'END';
             If forCount > 0;
                If forLevel(forCount) = indentCount - 1;
                   operator = 'ENDFOR' + ' ' + %trim(factor2);
                   If factor2 <> *Blanks;
                      savedSRCDTA = SRCDTA;
                      codeLine = '* CHECK: This is a converted ENDDO -'
                               + ' Please add ''BY'' to the corresponding'
                               + ' FOR';
                      Exsr subUserWriteLine;
                      SRCDTA = savedSRCDTA;
                   EndIf;
                EndIf;
             EndIf;
          EndIf;

          // Convert END to ENDDO?
          If %trim(operator) = 'ENDDO' or %trim(operator) = 'END';
             If doCount > 0;
                If doLevel(doCount) = indentCount - 1;
                   operator = 'ENDDO';
                EndIf;
             EndIf;
          EndIf;

          // Convert END to ENDSL?
          If %trim(operator) = 'ENDSL' or %trim(operator) = 'END';
             If slCount > 0;
                If slLevel(slCount) = indentCount - 2;
                   operator = 'ENDSL';
                EndIf;
             EndIf;
          EndIf;

          If %trim(operator) = 'END';
             If inCase;
                operator = 'ENDCS';
             Else;
                operator = 'ENDIF';
             EndIf;
          EndIf;

          sourceLine = %trim(operator) + ';';

          convert = *On;

          If operator = 'ENDCS';
             inCase = *Off;
          EndIf;

       EndSr;
       //-------------------------------------------------------------------------------------------

      /Eject
       //-------------------------------------------------------------------------------------------
       // Convert EVALx.
       //-------------------------------------------------------------------------------------------
       BegSr subUserCvt_EVALx;

          // Returning for a multi-line EVAL - restore the original opcode.
          If inEval;
             operator = evalOperator;
          EndIf;

          Exsr subUserCheckSpan;  // Does this line span more than one line?

          If not inEval;          // First line of EVAL.
             inEval = *On;
             If %scan('H':operator:5) > 0  // Half-adjust.
             or %scan('R':operator:1) > 0; // EVALR.
                sourceLine = %trimr(operator) + ' ' + %trim(extFactor2);
             Else;
                sourceLine = %trim(extFactor2);
             EndIf;
             If not inSpan;
                sourceLine = %trim(sourceLine) + ';';
             Else;
                inSpan = *Off;
             EndIf;
          Else;                   // Second+ line of EVAL.
             sourceLine = *Blanks;
             %subst(sourceLine:%len(%trim(operator)) + 2)
                   = %trim(extFactor2);
             If not inSpan;
                sourceLine = %trimr(sourceLine) + ';';
             EndIf;
             inSpan = *Off;
          EndIf;

          // Multi-line EVAL?  Save the opcode.
          If inEval;
             evalOperator = operator;
          Else;
             evalOperator = *Blanks;
          EndIf;

          convert = *On;

       EndSr;
       //-------------------------------------------------------------------------------------------

      /Eject
       //-------------------------------------------------------------------------------------------
       // Convert EXCEPT.
       //-------------------------------------------------------------------------------------------
       BegSr subUserCvt_EXCEPT;

          sourceLine = %trim(operator) + ' ' + %trim(factor2) + ';';

          convert = *On;

       EndSr;
       //-------------------------------------------------------------------------------------------

      /Eject
       //-------------------------------------------------------------------------------------------
       // Convert Embedded SQL.
       //-------------------------------------------------------------------------------------------
       BegSr subUserCvt_EXEC_SQL;

          Exsr subUserCheckSpan;  // Does this line span more than one line?

          If workDirective = '/EXEC SQL';
             sourceLine = 'Exec SQL';
             inSQL = *On;
             inSpan = *Off;
          Else;
             sourceLine = %trimr(%subst(codeLine:2));
             If not inSpan;
                sourceLine = %trim(sourceLine) + ';';
             Else;
                inSQL = *On;
                inSpan = *Off;
             EndIf;
          EndIf;

          convert = *On;

       EndSr;
       //-------------------------------------------------------------------------------------------

      /Eject
       //-------------------------------------------------------------------------------------------
       // Convert EXFMT.
       //-------------------------------------------------------------------------------------------
       BegSr subUserCvt_EXFMT;

          sourceLine = %trim(operator) + ' ' + %trim(factor2);

          // Append datastructure?
          If result <> *Blanks;
             sourceLine = %trim(sourceLine)  + ' ' + %trim(result) + ';';
          Else;
             sourceLine = %trim(sourceLine)  + ';';
          EndIf;

          // Check indicators?
          If lw <> *Blanks;
             ERRCheck = *On;
             ERRInd = lw;
          EndIf;

          convert = *On;

       EndSr;
       //-------------------------------------------------------------------------------------------

      /Eject
       //-------------------------------------------------------------------------------------------
       // Convert EXSR.
       //-------------------------------------------------------------------------------------------
       BegSr subUserCvt_EXSR;

          sourceLine = 'ExSr ' + %trim(factor2) + ';';

          convert = *On;

       EndSr;
       //-------------------------------------------------------------------------------------------

      /Eject
       //-------------------------------------------------------------------------------------------
       // Convert EXTRCT
       //-------------------------------------------------------------------------------------------
       BegSr subUserCvt_EXTRCT;

          // Split out duration and code.
          x = %scan(':':factor2);
          If x = 0;
             nonConvRsn =  'No duration code specified.';
             LeaveSr;
          EndIf;

          durDuration = %trim(%subst(factor2:1:x-1));
          durCode     = %xlate(lo:up:%trim(%subst(factor2:x+1)));

          Select;
             When durCode = '*Y' or durCode = '*YEARS';
                durCode = '%years';
             When durCode = '*M' or durCode = '*MONTHS';
                durCode = '%months';
             When durCode = '*D' or durCode = '*DAYS';
                durCode = '%days';
             When durCode = '*H' or durCode = '*HOURS';
                durCode = '%hours';
             When durCode = '*MN' or durCode = '*MINUTES';
                durCode = '%minutes';
             When durCode = '*S' or durCode = '*SECONDS';
                durCode = '%seconds';
             When durCode = '*MS' or durCode = '*MSECONDS';
                durCode = '%mseconds';
             Other;
                nonConvRsn = 'Invalid duration code specified.';
                LeaveSr;
          EndSl;

          sourceLine = %trim(result) + ' = %subdt(' + %trim(durDuration)
                     + ':' + %trim(durCode) + ');';

          // Check indicators?
          If lw <> *Blanks;
             ERRCheck = *On;
             ERRInd = lw;
          EndIf;

          convert = *On;

       EndSr;
       //-------------------------------------------------------------------------------------------

      /Eject
       //-------------------------------------------------------------------------------------------
       // Convert FEOD.
       //-------------------------------------------------------------------------------------------
       BegSr subUserCvt_FEOD;

          sourceLine = %trim(operator) + %trim(extFactor2) + ';';

          // Check indicators?
          If lw <> *Blanks;
             ERRCheck = *On;
             ERRInd = lw;
          EndIf;

          convert = *On;

       EndSr;
       //-------------------------------------------------------------------------------------------

      /Eject
       //-------------------------------------------------------------------------------------------
       // Convert FORCE.
       //-------------------------------------------------------------------------------------------
       BegSr subUserCvt_FORCE;

          sourceLine = %trim(operator) + %trim(extFactor2) + ';';

          convert = *On;

       EndSr;
       //-------------------------------------------------------------------------------------------

      /Eject
       //-------------------------------------------------------------------------------------------
       // Convert FOR.
       //-------------------------------------------------------------------------------------------
       BegSr subUserCvt_FOR;

          sourceLine = 'For ' + %trim(extFactor2) + ';';

          convert = *On;

       EndSr;
       //-------------------------------------------------------------------------------------------

      /Eject
       //-------------------------------------------------------------------------------------------
       // Convert IF.
       //-------------------------------------------------------------------------------------------
       BegSr subUserCvt_IF;

          // Returning for a multi-line IF?  Reinstate original opcode.
          If inIf;
             operator = ifOperator;
          EndIf;

          Exsr subUserCheckSpan;  // Does this line span more than one line?

          If operator = 'IF';     // Use Extended Factor2.
             If not inIf;            // First line of IF.
                sourceLine = %trim(operator) + ' ' + %trim(extFactor2);
                If not inSpan;
                   sourceLine = %trim(sourceLine) + ';';
                Else;
                   inIf = *On;
                   inSpan = *Off;
                EndIf;
             Else;                   // Second line of IF.
                //            sourceLine = *Blanks;
                //            %subst(sourceLine:40) = %trim(extFactor2);
                sourceLine = %trim(extFactor2);
                If not inSpan;
                   sourceLine = %trimr(sourceLine) + ';';
                   //               inIf = *Off;
                EndIf;
                //            inSpan = *On;
                inSpan = *Off;
             EndIf;
          Else;
             // Fixed format.
             opCode = %xlate(lo:up:opCode);
             If not inIf;         // First line of IF.
                ifCompare = %subst(opCode:3:2);
                sourceLine = 'If';
             Else;                // Second line of IF.
                If %subst(opCode:1:3) = 'AND';
                   ifCompare = %subst(opCode:4:2);
                   sourceLine = 'And';
                Else;
                   ifCompare = %subst(opCode:3:2);
                   sourceLine = 'Or';
                EndIf;
             EndIf;
             If ifCompare = 'EQ';
                ifCompare = '=';
             ElseIf ifCompare = 'GT';
                ifCompare = '>';
             ElseIf ifCompare = 'GE';
                ifCompare = '>=';
             ElseIf ifCompare = 'LT';
                ifCompare = '<';
             ElseIf ifCompare = 'LE';
                ifCompare = '<=';
             ElseIf ifCompare = 'NE';
                ifCompare = '<>';
             EndIf;
             sourceLine = %trimr(sourceLine) + ' ' + %trim(factor1)
                                + ' ' + %trim(ifCompare) + ' '
                                + %trim(factor2);
             If not inSpan;
                sourceLine = %trimr(sourceLine) + ';';
                inIf = *Off;
             Else;
                inIf = *On;
                inSpan = *Off;
             EndIf;
          EndIf;

          // Multi-line IF?  Retain original opcode.
          If inIf;
             ifOperator = operator;
          Else;
             ifOperator = *Blanks;
          EndIf;

          convert = *On;

       EndSr;
       //-------------------------------------------------------------------------------------------

      /Eject
       //-------------------------------------------------------------------------------------------
       // Convert IN.
       //-------------------------------------------------------------------------------------------
       BegSr subUserCvt_IN;

          If factor1 <> *Blanks;
             sourceLine = %trim(operator) + ' ' + %trim(factor1) + ' '
                        + %trim(factor2) + ';';
          Else;
             sourceLine = %trim(operator) + ' ' + %trim(factor2) + ';';
          EndIf;

          // Set resulting indicators?
          If lw <> *Blanks;
             ERRCheck = *On;
             ERRInd = lw;
          EndIf;

          convert = *On;

       EndSr;
       //-------------------------------------------------------------------------------------------

      /Eject
       //-------------------------------------------------------------------------------------------
       // Convert ITER.
       //-------------------------------------------------------------------------------------------
       BegSr subUserCvt_ITER;

          sourceLine = %trim(operator) + ';';

          convert = *On;

       EndSr;
       //-------------------------------------------------------------------------------------------

      /Eject
       //-------------------------------------------------------------------------------------------
       // Convert LEAVExx.
       //-------------------------------------------------------------------------------------------
       BegSr subUserCvt_LEAVE;

          sourceLine = %trim(operator) + ';';

          convert = *On;

       EndSr;
       //-------------------------------------------------------------------------------------------

      /Eject
       //-------------------------------------------------------------------------------------------
       // Convert LOOKUP.
       //-------------------------------------------------------------------------------------------
       BegSr subUserCvt_LOOKUP;

          //            If %subst(factor2:1:3) = 'TAB';  // Table lookup.
          //            Else;                            // Array lookup.
          //               // Extract element variable.
          //               x = %scan('(':factor2);
          //               If x = 0;   // No variable specified, so use a substitute.
          //                  lookupVar = 'lookupIndex';
          //               Else;
          //                  lookupVar = %subst(factor2:x+1:%scan(')':factor2:x)-x-1);
          //               EndIf;
          //               If eq <> *Blanks and lw <> *Blanks;
          //                  sourceLine = '%lookupLE(';
          //               ElseIf eq <> *Blanks and hi <> *Blanks;
          //                  sourceLine = '%lookupGE(';
          //               ElseIf lw <> *Blanks;
          //                  sourceLine = '%lookupLT(';
          //               ElseIf hi <> *Blanks;
          //                  sourceLine = '%lookupGT(';
          //               Else;
          //                  sourceLine = '%lookup(';
          //               EndIf;
          //               sourceLine = %trim(sourceLine) + %trim(factor1) + ':'
          //                          + %trim(factor2) + ');';
          //            EndIf;
          //            convert = *On;

       EndSr;
       //-------------------------------------------------------------------------------------------

      /Eject
       //-------------------------------------------------------------------------------------------
       // Convert MONITOR.
       //-------------------------------------------------------------------------------------------
       BegSr subUserCvt_MONITOR;

          sourceLine = 'Monitor;';

          convert = *On;

       EndSr;
       //-------------------------------------------------------------------------------------------

      /Eject
       //-------------------------------------------------------------------------------------------
       // Convert MOVE.
       //-------------------------------------------------------------------------------------------
       BegSr subUserCvt_MOVE;

          // Pad the result?
          x = %scan('P':operator:5);

          If x > 0 and %subst(operator:5:1) <> 'L';
             // Move right and pad left.
             sourceLine = 'EvalR ' + %trim(result) + ' = ' + %trim(factor2)
                        + ';';

          ElseIf x > 0 and %subst(operator:5:1) = 'L';
             // Move left and pad right.
             sourceLine = %trim(result) + ' = ' + %trim(factor2) + ';';

          ElseIf factor1 = *Blanks;
             // Straight move.
             If %lookup(%xlate(lo:up:%trim(result)):ØopCodeUp) = 0;
                sourceLine = %trim(result) + ' = ' + %trim(factor2) + ';';
             Else;
                // Result is a reserved word - don't convert.
                nonConvRsn = 'Result field name is a reserved word.';
                LeaveSr;
             EndIf;

          Else;
             // Conversion from one format to another...
             //         sourceLine = %xlate(lo:up:factor1);

             //         If sourceLine = '*CYMD';   // Date.
             //            sourceLine = %trim(result) + ' = %dec(' + %trim(factor2)
             //                       + ':*CYMD);';
             //         Else;
             nonConvRsn = 'Data conversion is needed.';
             LeaveSr; // Don't convert.
             //         EndIf;
          EndIf;

          convert = *On;

       EndSr;
       //-------------------------------------------------------------------------------------------

      /Eject
       //-------------------------------------------------------------------------------------------
       // Convert MOVEA.
       //-------------------------------------------------------------------------------------------
       BegSr subUserCvt_MOVEA;

          // Not supported.

       EndSr;
       //-------------------------------------------------------------------------------------------

      /Eject
       //-------------------------------------------------------------------------------------------
       // Convert MULT.
       //-------------------------------------------------------------------------------------------
       BegSr subUserCvt_MULT;

          // Half-adjust?
          x = %scan('H':operator:4);
          If x > 0;
             sourceLine = 'Eval(H)';
          Else;
             sourceLine = *Blanks;
          EndIf;

          If factor1 = *Blanks;
             sourceLine = %trimr(sourceLine) + ' ' + %trim(result)
                        + ' = ' + %trim(result)
                        + ' * ' + %trim(factor2) +';';
          Else;
             sourceLine = %trimr(sourceLine) + ' ' + %trim(result)
                        + ' = ' + %trim(factor1)
                        + ' * ' + %trim(factor2) + ';';
          EndIf;

          sourceLine = %trim(sourceLine);

          convert = *On;

       EndSr;
       //-------------------------------------------------------------------------------------------

      /Eject
       //-------------------------------------------------------------------------------------------
       // Convert MVR.
       //-------------------------------------------------------------------------------------------
       BegSr subUserCvt_MVR;

          sourceLine = %trim(result) + ' = %rem(' + %trim(divFactor1)
                     + ':' + %trim(divFactor2) + ');';

          convert = *On;

       EndSr;
       //-------------------------------------------------------------------------------------------

      /Eject
       //-------------------------------------------------------------------------------------------
       // Convert NEXT.
       //-------------------------------------------------------------------------------------------
       BegSr subUserCvt_NEXT;

          sourceLine = %trim(operator) + ' ' + %trim(factor1) + ' '
                     + %trim(factor2) + ';';


          // Check indicators?
          If lw <> *Blanks;
             ERRCheck = *On;
             ERRInd = lw;
          EndIf;

          convert = *On;

       EndSr;
       //-------------------------------------------------------------------------------------------

      /Eject
       //-------------------------------------------------------------------------------------------
       // Convert OCCUR.
       //-------------------------------------------------------------------------------------------
       BegSr subUserCvt_OCCUR;

          If factor1 = *Blanks;      // Get occurrence.
             sourceLine = %trim(result) + ' = ' + '%occur('
                        + %trim(factor2) + ');';
          ElseIf result = *Blanks;   // Set occurrent.
             sourceLine = '%occur(' + %trim(factor2) + ') = '
                        + %trim(factor1) + ';';
          Else;
             nonConvRsn = 'Cannot determine of OCCUR is used to set or '
                        + 'get the occurrence.';
             LeaveSr;
          EndIf;

          // Check resulting indicators?
          If lw <> *Blanks;
             ERRCheck = *On;
             ERRInd = lw;
          EndIf;

          convert = *On;

       EndSr;
       //-------------------------------------------------------------------------------------------

      /Eject
       //-------------------------------------------------------------------------------------------
       // Convert ON-ERROR.
       //-------------------------------------------------------------------------------------------
       BegSr subUserCvt_ON_ERROR;

          If extFactor2 = *Blanks;
             sourceLine = %trim(operator) + ';';
          Else;
             sourceLine = %trim(operator) + ' ' + %trim(extFactor2) + ';';
          EndIf;

          convert = *On;

       EndSr;
       //-------------------------------------------------------------------------------------------

      /Eject
       //-------------------------------------------------------------------------------------------
       // Convert OPEN.
       //-------------------------------------------------------------------------------------------
       BegSr subUserCvt_OPEN;

          sourceLine = %trim(operator) + ' ' + %trim(factor2) + ';';

          // Check resulting indicators?
          If lw <> *Blanks;
             ERRCheck = *On;
             ERRInd = lw;
          EndIf;

          convert = *On;

       EndSr;
       //-------------------------------------------------------------------------------------------

      /Eject
       //-------------------------------------------------------------------------------------------
       // Convert OTHER.
       //-------------------------------------------------------------------------------------------
       BegSr subUserCvt_OTHER;

          sourceLine = 'Other;';

          convert = *On;

       EndSr;
       //-------------------------------------------------------------------------------------------

      /Eject
       //-------------------------------------------------------------------------------------------
       // Convert OUT.
       //-------------------------------------------------------------------------------------------
       BegSr subUserCvt_OUT;

          If factor1 = *Blanks;
             sourceLine = %trim(operator) + ' ' + %trim(factor2) + ';';
          Else;
             sourceLine = %trim(operator) + ' ' + %trim(factor1) + ' '
                        + %trim(factor2) + ';';
          EndIf;

          // Set resulting indicators?
          If lw <> *Blanks;
             ERRCheck = *On;
             ERRInd = lw;
          EndIf;

          convert = *On;

       EndSr;
       //-------------------------------------------------------------------------------------------

      /Eject
       //-------------------------------------------------------------------------------------------
       // Convert POST.
       //-------------------------------------------------------------------------------------------
       BegSr subUserCvt_POST;

          If factor2 = *Blanks;
             nonConvRsn =  'No filename specified in Factor2.';
             LeaveSr;
          EndIf;

          If result <> *Blanks;
             nonConvRsn =  'INFDS specified in result.';
             LeaveSr;
          EndIf;

          If factor1 = *Blanks;
             sourceLine = %trim(operator) + ' ' + %trim(factor2) + ';';
          Else;
             sourceLine = %trim(operator) + ' ' + %trim(factor1) + ' '
                        + %trim(factor2) + ';';
          EndIf;

          // Set resulting indicators?
          If lw <> *Blanks;
             ERRCheck = *On;
             ERRInd = lw;
          EndIf;

          convert = *On;

       EndSr;
       //-------------------------------------------------------------------------------------------

      /Eject
       //-------------------------------------------------------------------------------------------
       // Convert READ.
       //-------------------------------------------------------------------------------------------
       BegSr subUserCvt_READ;

          If factor1 <> *Blanks;
             sourceLine = %trim(operator) + ' ' + %trim(factor1) + ' '
                        + %trim(factor2);
          Else;
             sourceLine = %trim(operator) + ' ' + %trim(factor2);
          EndIf;

          // Append datastructure?
          If result <> *Blanks;
             sourceLine = %trim(sourceLine)  + ' ' + %trim(result) + ';';
          Else;
             sourceLine = %trim(sourceLine)  + ';';
          EndIf;

          // Check indicators?
          If eq <> *Blanks;
             EOFCheck = *On;
             EOFInd = eq;
             EOFFile = %trim(factor2);
          EndIf;
          If lw <> *Blanks;
             ERRCheck = *On;
             ERRInd = lw;
          EndIf;

          convert = *On;

       EndSr;
       //-------------------------------------------------------------------------------------------

      /Eject
       //-------------------------------------------------------------------------------------------
       // Convert REALLOC.
       //-------------------------------------------------------------------------------------------
       BegSr subUserCvt_REALLOC;

          sourceLine = %trim(result) + ' = %realloc(' + %trim(factor2)
                     + ');';

          // Set resulting indicators?
          If lw <> *Blanks;
             ERRCheck = *On;
             ERRInd = lw;
          EndIf;

          convert = *On;

       EndSr;
       //-------------------------------------------------------------------------------------------

      /Eject
       //-------------------------------------------------------------------------------------------
       // Convert REL.
       //-------------------------------------------------------------------------------------------
       BegSr subUserCvt_REL;

          sourceLine = %trim(operator) + ' ' + %trim(factor1)
                     + ' ' + %trim(factor2) + ';';

          // Check resulting indicators?
          If lw <> *Blanks;
             ERRCheck = *On;
             ERRInd = lw;
          EndIf;

          convert = *On;

       EndSr;
       //-------------------------------------------------------------------------------------------

      /Eject
       //-------------------------------------------------------------------------------------------
       // Convert RESET.
       //-------------------------------------------------------------------------------------------
       BegSr subUserCvt_RESET;

          sourceLine = %trim(operator);

          If factor1 <> *Blanks;
             sourceLine = %trimr(sourceLine) + ' ' + %trim(factor1);
          EndIf;

          If factor2 <> *Blanks;
             sourceLine = %trimr(sourceLine) + ' ' + %trim(factor2);
          EndIf;

          sourceLine = %trimr(sourceLine) + ' ' + %trim(result) + ';';

          // Check indicators?
          If hi <> *Blanks;
             NRFCheck = *On;
             NRFInd = eq;
             NRFFile = %trim(factor2);
          EndIf;
          If lw <> *Blanks;
             ERRCheck = *On;
             ERRInd = lw;
          EndIf;

          convert = *On;

       EndSr;
       //-------------------------------------------------------------------------------------------

      /Eject
       //-------------------------------------------------------------------------------------------
       // Convert RETURN;
       //-------------------------------------------------------------------------------------------
       BegSr subUserCvt_RETURN;

          sourceLine = 'Return ' + %trim(%subst(operator:7))
                     + ' ' + %trim(extFactor2) + ';';

          convert = *On;

       EndSr;
       //-------------------------------------------------------------------------------------------

      /Eject
       //-------------------------------------------------------------------------------------------
       // Convert ROLBK.
       //-------------------------------------------------------------------------------------------
       BegSr subUserCvt_ROLBK;

          sourceLine = %trim(operator) + ' ' + %trim(factor1);

          sourceLine = %trim(sourceLine)  + ';';

          // Check indicators?
          If lw <> *Blanks;
             ERRCheck = *On;
             ERRInd = lw;
          EndIf;

          convert = *On;

       EndSr;
       //-------------------------------------------------------------------------------------------

      /Eject
       //-------------------------------------------------------------------------------------------
       // Convert SCAN.
       //-------------------------------------------------------------------------------------------
       BegSr subUserCvt_SCAN;

          // Determine length of comparator.
          x = %scan(':':factor1);
          If x = 0;   // No length specified.
             scanLength = *Blanks;               // Scan length
             scanString = %trim(factor1);        // Scan string
          Else;
             scanLength = %subst(factor1:x+1);   // Scan length
             scanString = %subst(factor1:1:x-1); // Scan string
          EndIf;

          // Determine starting point.
          x = %scan(':':factor2);
          If x = 0;   // No start specified.
             scanStart = '1';                    // Start position
             scanBase = %trim(factor2);          // Base string
          Else;
             scanStart = %subst(factor2:x+1);    // Start position
             scanBase = %subst(factor2:1:x-1);   // Base string
          EndIf;

          // Build the new line.
          If scanLength = *Blanks;
             // No length specified.
             sourceLine = '%scan(' + %trim(scanString)
                        + ':' + %trim(scanBase) + ':' + %trim(scanStart)
                        + ')';
          Else;
             // Use a subset of the scan string.
             sourceLine = '%scan(%subst('
                        + %trim(scanString) + ':1:' + %trim(scanLength)
                        + '):' + %trim(scanBase) + ':' + %trim(scanStart)
                        + ')';
          EndIf;

          // Result specified?
          If result = *Blanks;
             scanNoResult = *On;
             sourceLine = 'If ' + %trimr(sourceLine) + ' = 0;';
          Else;
             scanNoResult = *Off;
             sourceLine = %trim(result) + ' = ' + %trimr(sourceLine) + ';';
          EndIf;

          // Set resulting indicators?
          If lw <> *Blanks;
             ERRCheck = *On;
             ERRInd = lw;
          EndIf;
          If eq <> *Blanks;
             foundCheck = *On;
             foundInd = eq;
          EndIf;

          convert = *On;

       EndSr;
       //-------------------------------------------------------------------------------------------

      /Eject
       //-------------------------------------------------------------------------------------------
       // Convert SELECT
       //-------------------------------------------------------------------------------------------
       BegSr subUserCvt_SELECT;

          sourceLine = 'Select;';

          convert = *On;

       EndSr;
       //-------------------------------------------------------------------------------------------

      /Eject
       //-------------------------------------------------------------------------------------------
       // Convert SETOFF
       //-------------------------------------------------------------------------------------------
       BegSr subUserCvt_SETOFF;

          setOff = *On;
          setOffInd1 = hi;
          setOffInd2 = lw;
          setOffInd3 = eq;

          dropLine = *On;

          convert = *On;

       EndSr;
       //-------------------------------------------------------------------------------------------

      /Eject
       //-------------------------------------------------------------------------------------------
       // Convert SETON
       //-------------------------------------------------------------------------------------------
       BegSr subUserCvt_SETON;

          setOn = *On;
          setOnInd1 = hi;
          setOnInd2 = lw;
          setOnInd3 = eq;

          dropLine = *On;

          convert = *On;

       EndSr;
       //-------------------------------------------------------------------------------------------

      /Eject
       //-------------------------------------------------------------------------------------------
       // Convert SETxx.
       //-------------------------------------------------------------------------------------------
       BegSr subUserCvt_SETxx;

          sourceLine = %trim(operator) + ' ' + %trim(factor1) + ' '
                     + %trim(factor2);
          If result <> *Blanks;
             sourceLine = %trim(sourceLine)  + ' ' + %trim(result) + ';';
          Else;
             sourceLine = %trim(sourceLine)  + ';';
          EndIf;

          // Check resulting indicators.
          If hi <> *Blanks;
             NRFCheck = *On;
             NRFInd = hi;
             NRFFile = %trim(factor2);
          EndIf;
          If eq <> *Blanks;
             equalCheck = *On;
             equalInd = eq;
          EndIf;
          If lw <> *Blanks;
             ERRCheck = *On;
             ERRInd = lw;
          EndIf;

          convert = *On;

       EndSr;
       //-------------------------------------------------------------------------------------------

      /Eject
       //-------------------------------------------------------------------------------------------
       // Convert SHTDN
       //-------------------------------------------------------------------------------------------
       BegSr subUserCvt_SHTDN;

          sourceLine = '*IN' + hi + ' = %shtdn();';

          convert = *On;

       EndSr;
       //-------------------------------------------------------------------------------------------

      /Eject
       //-------------------------------------------------------------------------------------------
       // Convert SORTA.
       //-------------------------------------------------------------------------------------------
       BegSr subUserCvt_SORTA;

          sourceLine = %trim(operator) + ' ' + %trim(extFactor2);

          sourceLine = %trim(sourceLine)  + ';';

          convert = *On;

       EndSr;
       //-------------------------------------------------------------------------------------------

      /Eject
       //-------------------------------------------------------------------------------------------
       // Convert SQRT.
       //-------------------------------------------------------------------------------------------
       BegSr subUserCvt_SQRT;

          sourceLine = %trim(result) + ' = %sqrt(' + %trim(factor2) + ');';

          convert = *On;

       EndSr;
       //-------------------------------------------------------------------------------------------

      /Eject
       //-------------------------------------------------------------------------------------------
       // Convert SUB.
       //-------------------------------------------------------------------------------------------
       BegSr subUserCvt_SUB;

          // Half-adjust?
          x = %scan('H':operator:4);
          If x > 0;
             operator = 'SUB';
             sourceLine = 'Eval(H)';
          Else;
             sourceLine = *Blanks;
          EndIf;

          If factor1 = *Blanks;
             sourceLine = %trimr(sourceLine) + ' ' + %trim(result)
                        + ' = ' + %trim(result)
                        + ' - ' + %trim(factor2) +';';
          Else;
             sourceLine = %trimr(sourceLine) + ' ' + %trim(result)
                        + ' = ' + %trim(factor1)
                        + ' - ' + %trim(factor2) + ';';
          EndIf;

          sourceLine = %trim(sourceLine);

          convert = *On;

       EndSr;
       //-------------------------------------------------------------------------------------------

      /Eject
       //-------------------------------------------------------------------------------------------
       // Convert SUBDUR.
       //-------------------------------------------------------------------------------------------
       BegSr subUserCvt_SUBDUR;

          // Split out duration and code.
          x = %scan(':':factor2);
          If x = 0;
             x = %scan(':':result);
             If x = 0;
                nonConvRsn =  'No duration code specified.';
                LeaveSr;
             Else;
                durNewDate = *Off;
             EndIf;
          Else;
             durNewDate = *On;
          EndIf;

          If durNewDate;
             durDuration = %trim(%subst(factor2:1:x-1));
             durCode     = %xlate(lo:up:%trim(%subst(factor2:x+1)));

             Select;
                When durCode = '*Y' or durCode = '*YEARS';
                   durCode = '%years';
                When durCode = '*M' or durCode = '*MONTHS';
                   durCode = '%months';
                When durCode = '*D' or durCode = '*DAYS';
                   durCode = '%days';
                When durCode = '*H' or durCode = '*HOURS';
                   durCode = '%hours';
                When durCode = '*MN' or durCode = '*MINUTES';
                   durCode = '%minutes';
                When durCode = '*S' or durCode = '*SECONDS';
                   durCode = '%seconds';
                When durCode = '*MS' or durCode = '*MSECONDS';
                   durCode = '%mseconds';
                Other;
                   nonConvRsn = 'Invalid duration code specified.';
                   LeaveSr;
             EndSl;

             If factor1 = *Blanks;
                sourceLine = %trim(result) + ' = ' + %trim(result);
             Else;
                sourceLine = %trim(result) + ' = ' + %trim(factor1);
             EndIf;

             sourceLine = %trimr(sourceLine) + ' - ' + %trim(durCode)
                        + '(' + %trim(durDuration) + ');';
          Else;
             durDuration = %trim(%subst(result:1:x-1));
             durCode     = %xlate(lo:up:%trim(%subst(result:x+1)));

             Select;
                When durCode = '*Y' or durCode = '*YEARS';
                When durCode = '*M' or durCode = '*MONTHS';
                When durCode = '*D' or durCode = '*DAYS';
                When durCode = '*H' or durCode = '*HOURS';
                When durCode = '*MN' or durCode = '*MINUTES';
                When durCode = '*S' or durCode = '*SECONDS';
                When durCode = '*MS' or durCode = '*MSECONDS';
                Other;
                   nonConvRsn = 'Invalid duration code specified.';
                   LeaveSr;
             EndSl;

             sourceLine = %trim(durDuration) + ' = %diff(' + %trim(factor1)
                        + ':' + %trim(factor2) + ':' + %trim(durCode) + ');';
          EndIf;

          // Set resulting indicators?
          If lw <> *Blanks;
             ERRCheck = *On;
             ERRInd = lw;
          EndIf;

          convert = *On;

       EndSr;
       //-------------------------------------------------------------------------------------------

      /Eject
       //-------------------------------------------------------------------------------------------
       // Convert SUBST.
       //-------------------------------------------------------------------------------------------
       BegSr subUserCvt_SUBST;

          // Pad the result?
          x = %scan('P':operator:4);
          If x = 0                                              // Not padding.
          and factor1 <> *Blanks                                // Factor1 specified.
          and %xlate(lo:up:factor1) <> %xlate(lo:hi:result);    // Factor1 not the same as result
             nonConvRsn = 'No padding specified, and factor1 and result '
                        + 'are not the same.';
             LeaveSr;    // Don't convert - too difficult to get right.
          EndIf;

          substLen = %trim(factor1);

          x = %scan(':':factor2);
          If x = 0;
             substStart = '1';
             x = %len(%trim(factor2)) + 1;
          Else;
             substStart = %subst(factor2:x+1);
          EndIf;

          sourceLine = %trim(result) + ' = %subst('
                     + %subst(factor2:1:x-1) + ':'
                     + %trim(substStart)
                     + ':' + %trim(substLen) + ');';

          // Set resulting indicators?
          If lw <> *Blanks;
             ERRCheck = *On;
             ERRInd = lw;
          EndIf;

          convert = *On;

       EndSr;
       //-------------------------------------------------------------------------------------------

      /Eject
       //-------------------------------------------------------------------------------------------
       // Convert TEST.
       //-------------------------------------------------------------------------------------------
       BegSr subUserCvt_TEST;

          If operator = 'TEST';
             operator = 'Test(E)';
          EndIf;

          sourceLine = %trim(operator) + ' ' + %trim(factor1) + ' '
                     + %trim(result) + ';';

          // Set resulting indicators?
          If lw <> *Blanks;
             ERRCheck = *On;
             ERRInd = lw;
          EndIf;

          convert = *On;

       EndSr;
       //-------------------------------------------------------------------------------------------

      /Eject
       //-------------------------------------------------------------------------------------------
       // Convert TIME.
       //-------------------------------------------------------------------------------------------
       BegSr subUserCvt_TIME;

          sourceLine = %trim(result) + ' = %time();';

          convert = *On;

       EndSr;
       //-------------------------------------------------------------------------------------------

      /Eject
       //-------------------------------------------------------------------------------------------
       // Convert UNLOCK.
       //-------------------------------------------------------------------------------------------
       BegSr subUserCvt_UNLOCK;

          sourceLine = %trim(operator) + ' ' + %trim(factor2) + ';';

          // Check indicators?
          If lw <> *Blanks;
             ERRCheck = *On;
             ERRInd = lw;
          EndIf;

          convert = *On;

       EndSr;
       //-------------------------------------------------------------------------------------------

      /Eject
       //-------------------------------------------------------------------------------------------
       // Convert UPDATE.
       //-------------------------------------------------------------------------------------------
       BegSr subUserCvt_UPDATE;

          sourceLine = %trim(operator) + ' ' + %trim(factor2);

          // Append datastructure?
          If result <> *Blanks;
             sourceLine = %trim(sourceLine)  + ' ' + %trim(result) + ';';
          Else;
             sourceLine = %trim(sourceLine)  + ';';
          EndIf;

          // Check indicators?
          If lw <> *Blanks;
             ERRCheck = *On;
             ERRInd = lw;
          EndIf;

          convert = *On;

       EndSr;
       //-------------------------------------------------------------------------------------------

      /Eject
       //-------------------------------------------------------------------------------------------
       // Convert WHEN.
       //-------------------------------------------------------------------------------------------
       BegSr subUserCvt_WHEN;

          // Returning for a multi-line IF?  Reinstate original opcode.
          If inWhen;
             operator = whenOperator;
          EndIf;

          Exsr subUserCheckSpan;  // Does this line span more than one line?

          If operator = 'WHEN';     // Use Extended Factor2.
             If not inWhen;            // First line of IF.
                sourceLine = %trim(operator) + ' ' + %trim(extFactor2);
                If not inSpan;
                   sourceLine = %trim(sourceLine) + ';';
                Else;
                   inWhen = *On;
                   inSpan = *Off;
                EndIf;
             Else;                   // Second line of WHEN.
                //            sourceLine = *Blanks;
                //            %subst(sourceLine:40) = %trim(extFactor2);
                sourceLine = %trim(extFactor2);
                If not inSpan;
                   sourceLine = %trimr(sourceLine) + ';';
                   //               inWhen = *Off;
                EndIf;
                inSpan = *Off;
             EndIf;
          Else;
             // Fixed format.
             opCode = %xlate(lo:up:opCode);
             If not inWhen;         // First line of WHEN.
                whenCompare = %subst(opCode:5:2);
                sourceLine = 'When';
             Else;                // Second line of WHEN.
                If %subst(opCode:1:3) = 'AND';
                   whenCompare = %subst(opCode:4:2);
                   sourceLine = 'And';
                Else;
                   whenCompare = %subst(opCode:3:2);
                   sourceLine = 'Or';
                EndIf;
             EndIf;
             If whenCompare = 'EQ';
                whenCompare = '=';
             ElseIf whenCompare = 'GT';
                whenCompare = '>';
             ElseIf whenCompare = 'GE';
                whenCompare = '>=';
             ElseIf whenCompare = 'LT';
                whenCompare = '<';
             ElseIf whenCompare = 'LE';
                whenCompare = '<=';
             ElseIf whenCompare = 'NE';
                whenCompare = '<>';
             EndIf;
             sourceLine = %trimr(sourceLine) + ' ' + %trim(factor1)
                                + ' ' + %trim(whenCompare) + ' '
                                + %trim(factor2);
             If not inSpan;
                sourceLine = %trimr(sourceLine) + ';';
                inWhen = *Off;
             Else;
                inWhen = *On;
                inSpan = *Off;
             EndIf;
          EndIf;

          // Multi-line IF?  Retain original opcode.
          If inWhen;
             whenOperator = operator;
          Else;
             whenOperator = *Blanks;
          EndIf;

          convert = *On;

       EndSr;
       //-------------------------------------------------------------------------------------------

      /Eject
       //-------------------------------------------------------------------------------------------
       // Convert WRITE.
       //-------------------------------------------------------------------------------------------
       BegSr subUserCvt_WRITE;

          sourceLine = %trim(operator) + ' ' + %trim(factor2);

          // Append datastructure?
          If result <> *Blanks;
             sourceLine = %trim(sourceLine)  + ' ' + %trim(result) + ';';
          Else;
             sourceLine = %trim(sourceLine)  + ';';
          EndIf;

          // Check indicators?
          If eq <> *Blanks;
             EOFCheck = *On;
             EOFInd = eq;
             EOFFile = %trim(factor2);
          EndIf;
          If lw <> *Blanks;
             ERRCheck = *On;
             ERRInd = lw;
          EndIf;

          convert = *On;

       EndSr;
       //-------------------------------------------------------------------------------------------

      /Eject
       //-------------------------------------------------------------------------------------------
       // Convert XFOOT.
       //-------------------------------------------------------------------------------------------
       BegSr subUserCvt_XFOOT;

          If %scan('H':operator) = 0;
             sourceLine = %trim(result) + ' = %xfoot(' + %trim(factor2)
                        + ');';
          Else;
             // Half-adjust.
             sourceLine = 'Eval(H) ' + %trim(result) + ' = %xfoot('
                        + %trim(factor2) + ');';
          EndIf;

          convert = *On;

       EndSr;
       //-------------------------------------------------------------------------------------------

      /Eject
       //-------------------------------------------------------------------------------------------
       // Convert XLATE.
       //-------------------------------------------------------------------------------------------
       BegSr subUserCvt_XLATE;

          //      // Pad the result?
          //      x = %scan('P':operator:6);
          //      If x > 0;
          //         padResult = *On;
          //         padTarget = result;
          //         // Drop the extender.
          //         operator = 'XLATE';
          //      EndIf;

          // Derive from and to.
          x = %scan(':':factor1);
          If x = 0;
             LeaveSr;    // Invalid specification - there MUST be a from and to - don't convert.
          Else;
             xlateFrom = %subst(factor1:1:x-1);
             xlateTo = %subst(factor1:x+1);
          EndIf;

          // Check for start position.
          x = %scan(':':factor2);
          If x = 0;
             xlateStart = *Blanks;
             xlateBase = factor2;
          Else;
             xlateStart = %subst(factor2:x+1);
             xlateBase = %subst(factor2:1:x-1);
          EndIf;

          // Build new line.
          sourceLine = %trim(result) + ' = %xlate('
                     + %trim(xlateFrom) + ':' + %trim(xlateTo) + ':'
                     + %trim(xlateBase);
          If xlateStart <> *Blanks;
             sourceLine = %trimr(sourceLine) + ':' + %trim(xlateStart);
          EndIf;
          sourceLine = %trimr(sourceLine) + ');';

          // Set resulting indicators?
          If lw <> *Blanks;
             ERRCheck = *On;
             ERRInd = lw;
          EndIf;

          convert = *On;

       EndSr;
       //-------------------------------------------------------------------------------------------

      /Eject
       //-------------------------------------------------------------------------------------------
       // Convert Z-ADD.
       //-------------------------------------------------------------------------------------------
       BegSr subUserCvt_Z_ADD;

          sourceLine = %trim(result) + ' = ' + %trim(factor2) + ';';

          // Half-adjust required?
          If %len(%trim(operator)) > 5;
             sourceLine = 'Eval(H) ' + %trim(sourceLine);
          EndIf;

          convert = *On;

       EndSr;
       //-------------------------------------------------------------------------------------------

      /Eject
       //-------------------------------------------------------------------------------------------
       // Convert Z-SUB.
       //-------------------------------------------------------------------------------------------
       BegSr subUserCvt_Z_SUB;


          sourceLine = %trim(result) + ' = ' + %trim(factor2) + ' * -1;';

          // Half-adjust required?
          If %len(%trim(operator)) > 5;
             sourceLine = 'Eval(H) ' + %trim(sourceLine);
          EndIf;

          convert = *On;

       EndSr;
       //-------------------------------------------------------------------------------------------

      /Eject
       //-------------------------------------------------------------------------------------------
       // Check if the next line is a continuation of the current line.
       //-------------------------------------------------------------------------------------------
       BegSr subUserCheckSpan;

          inspan = *Off;
          savedSRCDTA = SRCDTA;
          savedLineType = %xlate(lo:up:lineType);      // Save current line type for comparison.
          x = 0;

          // Is the current line a continuation line?
          If savedLineType = 'D';
             If declName <> *Blanks;
                If %scan('...':%trim(declOptions)) > 0;
                   // Yes - so we must be in a span.
                   inSpan = *On;
                EndIf;
             EndIf;
          EndIf;

          If not inSpan;
             Read SRCREC;
             DoW not %eof();
                x += 1;     // Keep a track of how many lines we have read.

                lineType = %xlate(lo:up:lineType);

                If lineType <> *Blank
                and lineType <> savedLineType;
                   // Not a spanned line.
                   Leave;

                ElseIf lineType = 'D'
                and %subst(directive:1:1) <> '*';                       // D-spec and no comment
                   If declName = *Blanks
                   and declType = *Blanks
                   and declLen = *Blanks
                   and declKeyWords <> *Blanks;
                      //               and ((declType <> *Blanks and workDeclType = *Blanks)
                      //                    or (declType <> *Blanks and declType <> workDeclType)
                      //                    or (declType = *Blanks and declKeyWords <> *Blanks));
                      inSpan = *On;
                   EndIf;
                   Leave;

                ElseIf lineType = 'P'
                and %subst(directive:1:1) <> '*';                       // P-spec and no comment
                   If declName = *Blanks
                   and (procType <> *Blanks or procKeyWords <> *Blanks);
                      inSpan = *On;
                   EndIf;
                   Leave;

                ElseIf lineType = 'H'
                and %subst(directive:1:1) = *Blank;                     // H-spec and no comment
                   inSpan = *On;
                   Leave;

                ElseIf lineType = 'C'
                and %subst(directive:1:1) = *Blank;                      // C-spec and no comment
                   opCode = %xlate(lo:up:opCode);
                   If %subst(operator:1:4) = 'EVAL';
                      If opCode = *Blanks and extFactor2 <> *Blanks;     // EVAL continues.
                         inSpan = *On;
                      EndIf;
                      Leave;
                   ElseIf %subst(operator:1:6) = 'CALLP';
                      If opCode = *Blanks;                               // CALLP continues.
                         inSpan = *On;
                      EndIf;
                      Leave;
                   ElseIf operator = 'IF';                               // IF Continues.
                      If opCode = *Blanks;
                         inSpan = *On;
                      EndIf;
                      Leave;
                   ElseIf %subst(operator:1:2) = 'IF';                   // IF Continues.
                      If %subst(opCode:1:2) = 'OR'
                      or %subst(opCode:1:3) = 'AND'
                      or opCode = *Blanks;
                         inSpan = *On;
                      EndIf;
                      Leave;
                   ElseIf %subst(operator:1:2) = 'DO';                   // DO Continues.
                      If %subst(opCode:1:2) = 'OR'
                      or %subst(opCode:1:3) = 'AND'
                      or opCode = *Blanks;
                         inSpan = *On;
                      EndIf;
                      Leave;
                   ElseIf %subst(operator:1:4) = 'WHEN';                 // WHEN Continues.
                      If %subst(opCode:1:2) = 'OR'
                      or %subst(opCode:1:3) = 'AND'
                      or opCode = *Blanks;
                         inSpan = *On;
                      EndIf;
                      Leave;
                   EndIf;

                ElseIf lineType = 'C'
                and %subst(directive:1:1) = '+';                        // Embedded SQL
                   inSpan = *On;
                   Leave;

                ElseIf lineType = 'F'
                and %subst(directive:1:1) <> '*';                       // F-spec and no comment
                   If fileName = *Blanks and fileKeyWords <> *Blanks;
                      inSpan = *On;
                   EndIf;
                   Leave;

                ElseIf %subst(directive:1:1) = '/';          // Directive, so line must end here.
                   Leave;
                   //            ElseIf lineType = ' '
                   //            and opCode <> *Blanks;
                 //               Leave;                                       // Free-format line.
                EndIf;

                Read SRCREC;
             EndDo;
          EndIf;

          // End of file breaks the logic!  We need to reposition to the last record before
          // continuing.
          If %eof(QRPGLESRC);
             SetGT *HIVAL SRCREC;
             ReadP SRCREC;
          EndIf;

          // Return to the previous point.
          For i = 1 to x;
             ReadP SRCREC;
          EndFor;

          SRCDTA = savedSRCDTA;

       EndSr;
       //-------------------------------------------------------------------------------------------

      /Eject
       //-------------------------------------------------------------------------------------------
       // Get the type of declaration encountered - it may not be on the current line!
       //-------------------------------------------------------------------------------------------
       BegSr subUserGetDeclarationType;

          // Start with what we've got.
          If declSuffix  = ' '
          and (declPrefix = ' '
          or declPrefix = 'U' or declPrefix = 'S');
             workDeclType = %xlate(lo:up:declType);
             savedName = %trim(declName);
          Else;
             workDeclType = *Blank;
             savedName = %trim(%subst(fullLine:1:74));
          EndIf;

          // If we already have the declaration type, then stop.
          If workDeclType = 'S'
          or workDeclType = 'DS'
          or workDeclType = 'C'
          or workDeclType = 'B'
          or workDeclType = 'E'
          or workDeclType = 'PR'
          or workDeclType = 'PI'
          or workDeclType = *Blanks and inPrototype;
             workDeclLine = SRCSEQ;
             LeaveSr;
          EndIf;

          savedSRCDTA = SRCDTA;
          savedLineType = %xlate(lo:up:lineType);      // Save current line type for comparison.
          x = 0;
          workDeclLine = 0;

          //      // Name of the variable/routine should be on this line.
          //      savedName = %trim(declOptions);

          // Trim any ellipsis from the name as this is not valid in free-form.
          x = %scan('...':savedName);
          If x > 0;
             savedName = %subst(savedName:1:x-1);
             x = 0;
          EndIf;

          // Read ahead to find the next line with a declaration type.
          Read SRCREC;
          DoW not %eof();
             x += 1;     // Keep a track of how many lines we have read.

             lineType = %xlate(lo:up:lineType);

             If lineType <> savedLineType;
                // End of this declaration.
                Leave;
             EndIf;

             If declType <> *Blanks;
                workDeclType = %xlate(lo:up:declType);
                workDeclLine = SRCSEQ;
                Leave;
             EndIf;

             Read SRCREC;
          EndDo;

          // End of file breaks the logic!  We need to reposition to the last record before
          // continuing.
          If %eof(QRPGLESRC);
             SetGT *HIVAL SRCREC;
             ReadP SRCREC;
          EndIf;

          // Return to the previous point.
          For i = 1 to x;
             ReadP SRCREC;
          EndFor;

          SRCDTA = savedSRCDTA;

       EndSr;
       //-------------------------------------------------------------------------------------------

      /Eject
       //-------------------------------------------------------------------------------------------
       // Get the line number at which the current structure ends.
       //-------------------------------------------------------------------------------------------
       BegSr subUserGetEndLine;

          savedSRCDTA = SRCDTA;
          endLine = 0;
          endFound = *Off;

          // Read ahead to find the start of the next declaration.
          Read SRCREC;
          x = 1;
          DoW not %eof();
             If lineType <> *Blanks
             and %xlate(lo:up:lineType) <> workLineType;
                // We've found a different line type.
                Leave;
             Else;
                If %len(%trim(codeLine)) >= 4;
                   If %xlate(lo:up:%subst(codeLine:1:4)) = 'DCL-';
                      // We've found a different line type.
                      Leave;
                   EndIf;
                EndIf;
             EndIf;

             If codeLine = *Blanks;
                // Ignore empty lines.
       //      ElseIf %subst(directive:1:1) = '/';
       //         // Ignore directives.
             ElseIf %subst(directive:2:1) = '*'
                 or %len(%trim(codeLine)) >= 2
                and %subst(%trim(codeLine):1:2) = '//';
                // Ignore comment.
             ElseIf inSpan
                and declName = *Blanks
                and SRCSEQ = workDeclLine;
                // Ignore the curent declaration.
             ElseIf declType = *Blanks
                and (declLen <> *Blanks or declKeywords <> *Blanks);
                // Ignore sub-field definition.
             ElseIf declType = *Blanks
                and declName <> *Blanks
                and %scan('...':declOptions) = 0;
                // Ignore sub-field definition.
             ElseIf %scan('...':declOptions) > 0;
                // We have a continuation line, but is it a sub-field or a new
                // delcaration?
                GetDeclarationType(tempDeclType
                                  :tempSavedName
                                  :tempDeclLine);
                If tempDeclType <> *Blanks;
                   // We've hit the next declaration or code.
                   Leave;
                EndIf;
             Else;
                // We've hit the next declaration or code.
                Leave;
             EndIf;

             Read SRCREC;
             x += 1;     // Keep a track of how many lines we have read.
          EndDo;

          // We are now at the start of the next declaration.
          endLine = SRCSEQ;

          // End of file breaks the logic!  We need to reposition to the last record before
          // continuing.
          If %eof(QRPGLESRC);
             SetGT *HIVAL SRCREC;
             //ReadP SRCREC;
          EndIf;

          // Return to the previous point.
          For i = 1 to x;
             ReadP SRCREC;

             // Move the end point for blank lines or comments.
             If not endFound;
                If (lineType = *Blanks
                or %subst(directive:1:1) = '*'
                or %subst(directive:1:2) = '//'
                or (%len(%trim(codeLine)) > 0
                and %subst(%trim(codeLine):1:2) = '//'));
                   //            and %subst(directive:1:1) <> '/';
                Else;
                   endFound = *On;
                   endLine = SRCSEQ;
                EndIf;
             EndIf;
          EndFor;

          SRCDTA = savedSRCDTA;

       EndSr;
       //-------------------------------------------------------------------------------------------

      /Eject
       //-------------------------------------------------------------------------------------------
       // Move field definitions to D-specs.
       //-------------------------------------------------------------------------------------------
       BegSr subUserMoveDefs;

          codeStart = SRCSEQ;   // Save the start of the source.
          savedSRCDTA = SRCDTA;

          Clear movedDefs;
          Reset DCLS;

          // Read through the source and create a D-spec for every field definition found.
          DoW not %eof(QRPGLESRC);
             // Stop if we hit either the start or end of a procedure (to preserve local
             // definitions of variables).
             If lineType = 'P'
             or %xlate(lo:up:%subst(%trim(codeLine) + '        ':1:8))
                                                          = 'DCL-PROC'
             or %xlate(lo:up:%subst(%trim(codeLine) + '        ':1:8))
                                                          = 'END-PROC';
                Leave;
             EndIf;

             If %xlate(lo:up:lineType) = 'C'
             and %subst(directive:1:1) = ' ';
                opCode = %xlate(lo:up:opCode);
                // C-Spec with a size definition.
                If opCode <> *Blanks
                and %subst(opCode:1:4) <> 'EVAL'
                and opCode <> 'IF'
                and opCode <> 'WHEN'
                and opCode <> 'DOW'
                and opCode <> 'DOU'
                and opCode <> 'DSPLY'
                and opCode <> 'CALLP'
                and (len <> *Blanks or opCode = 'DEFINE');
                   moveDef = *Off;
                   // Only do if not already moved.
                   If %lookup(%xlate(lo:up:result):movedDefs) = 0;
                      Reset DCLS;
                      // In-line definition.
                      If len <> *Blanks
                      and %scan('+':len) = 0 and %scan('-':len) = 0;
                         moveDef = *On;
                         DCLS.fieldName = result;
                         If dec = *Blanks;
                            DCLS.type = '     Char';
                         Else;
                            DCLS.type = '   Packed';
                         EndIf;
                         DCLS.definition = '(' + %trim(len);
                         If dec <> *Blanks;
                            DCLS.definition = %trimr(DCLS.definition)
                                            + ':' + %trim(dec);
                         EndIf;
                         DCLS.definition = %trimr(DCLS.definition) + ')';
                      EndIf;

                      // *LIKE Definition
                      If %xlate(lo:up:opCode) = 'DEFINE';
                         moveDef = *On;
                         DCLS.fieldName = result;
                         If %xlate(lo:up:factor1) = '*LIKE';
                            %subst(DCLS.definition:8)
                                        = 'LIKE(' + %trimr(factor2);
                            // Length adjustment?
                            If %scan('+':len) > 0 or %scan('-':len) > 0;
                               len = %scanrpl(' ':'':len);
                               DCLS.definition = %trimr(DCLS.definition)
                                               + ':' + %trim(len);
                            EndIf;
                            DCLS.definition = %trimr(DCLS.definition) + ')';
                         Else;
                            If %xlate(lo:up:%trim(factor2)) = '*LDA';
                               DCLS.definition = %trimr(DCLS.definition)
                                     + ' DTAARA(' + %trimr(factor2) + ')';
                            Else;
                               DCLS.definition = %trimr(DCLS.definition)
                                 + ' DTAARA(''' + %trimr(factor2) + ''')';
                            EndIf;
                         EndIf;
                      EndIf;

                      If moveDef;
                         // Put any additional keywords needed here!
                         DCLS.definition = %trimr(DCLS.definition) + ';';
                         If comment <> *Blanks;
                            DCLS.comment = '// ' + comment;
                         EndIf;

                         // Store the moved definition.
                         x = %lookup(' ':movedDefs);
                         movedDefs(x) = %xlate(lo:up:result);
                      EndIf;
                   EndIf;
                EndIf;
             EndIf;

             // Anything to output?
             If DCLS.fieldName <> *Blanks;
                DCLS.decl = 'Dcl-S ';
                If not defsMoved;
                   // Log start of moved field block;
                   SRCDTA = *Blanks;
                   codeLine = Øcomments(1);
                   Exsr subUserWriteLine;
                   codeLine = Øcomments(2);
                   Exsr subUserWriteLine;
                   codeLine = Øcomments(1);
                   Exsr subUserWriteLine;
                   defsMoved = *On;
                EndIf;

                lineType = ' ';
                codeLine = DCLS;
                countMoved += 1;
                Clear DCLS.fieldName;

                Exsr subUserWriteLine;
             EndIf;

             Read QRPGLESRC;
          EndDo;

          If defsMoved;
             // Log end of moved field block;
             SRCDTA = *Blanks;
             codeLine = Øcomments(1);
             Exsr subUserWriteLine;
             codeLine = Øcomments(3);
             Exsr subUserWriteLine;
             codeLine = Øcomments(1);
             Exsr subUserWriteLine;
          EndIf;

          // Reposition source file pointer to the start of the source again.
          Close QRPGLESRC;
          Open QRPGLESRC;
          Read SRCREC;
          DoW SRCSEQ <> codeStart;
             Read SRCREC;
          EndDo;

          defsMoved = *On;
          SRCDTA = savedSRCDTA;

       EndSr;
       //-------------------------------------------------------------------------------------------

      /Eject
       //-------------------------------------------------------------------------------------------
       // Output the current line.
       //-------------------------------------------------------------------------------------------
       BegSr subUserWriteLine;

          countTarget += 1;

          Write OUTREC;
          //Except OUTREC;

       EndSr;
       //-------------------------------------------------------------------------------------------

      /Eject
       //-------------------------------------------------------------------------------------------
       // Exit the program directly.
       //-------------------------------------------------------------------------------------------
       BegSr subExitProgram;

          Exsr subUserExitProgram;     // Perform any user-specified exit processing.

          // If commitment control is active, a commit should have been done if everything
          // was OK, so issue a rollback here to catch and remove any uncommitted changes.
          If cfgCommitControl = '*MASTER';
             RolBk;
          EndIf;

          If cfgCloseDown = 'Y';
             *INLR = *On;                  // Close down the program.
          EndIf;

          Return;                          // Exit the program.

       EndSr;
       //-------------------------------------------------------------------------------------------

      /Eject
       //-------------------------------------------------------------------------------------------
       // USER: Exit processing.
       //-------------------------------------------------------------------------------------------
       BegSr subUserExitProgram;

          // ** Place any program-specific exit code here.
          // >>>>> Start of User-Point >>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>

          If ØpShutDown <> 'Y';
             Close QRPGLESRC;
             Close QRPGLESRC2;
          EndIf;

          If ØpShutDown = 'Y' and initialCall <> 'Y';
             cfgCloseDown = 'Y';
             Write Z1ENDRPT;
             Close CVTRPGFRP1;
          EndIf;

          // <<<<< End of User-Point   <<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<

       EndSr;
       //-------------------------------------------------------------------------------------------

      /Eject
       //-------------------------------------------------------------------------------------------
       // Initialisation
       //-------------------------------------------------------------------------------------------
       BegSr subInitialise;

          // Flag initial call.
          If initialCall = *Blank;
             initialCall = 'Y';
          Else;
             initialCall = 'N';
          EndIf;

          // Perform user-specified intialisation processing.
          Exsr subUserInitialise;

       EndSr;
       //-------------------------------------------------------------------------------------------

      /Eject
       //-------------------------------------------------------------------------------------------
       // USER: Initialisation
       //-------------------------------------------------------------------------------------------
       BegSr subUserInitialise;

          // Set configuration/processing options:
          cfgCommitControl   = '*NONE  '; // Commitment control setting: *MASTER/*SLAVE
          cfgCloseDown       = 'N';       // Close down the program on exit?


          // >>>>> Start of User-Point >>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>

          // Shut down?
          If ØpShutDown = 'Y';
             Exsr subExitProgram;
          EndIf;

          // Open audit report.
          If initialCall = 'Y';
             Open CVTRPGFRP1;
             Z1ÅTTL = 'RPG/ILE to Free-Format Conversion Report';
             overflow = *On;
          EndIf;

          fromFileLib = %trim(ØpFromLib) + '/' + %trim(ØpFromFile);
          Open QRPGLESRC;

          toFileLib = %trim(ØpToLib) + '/' + %trim(ØpToFile);
          Open QRPGLESRC2;

          Reset countSource;
          Reset countTarget;
          Reset countEligible;
          Reset countConv;
          Reset CountNotConv;

          Reset maxIndent;
          Reset movedDefs;
          Reset moveDef;
          Reset inCode;
          Reset inArrayData;
          Reset indentCount;

          indentCount = mainlineIndent;

          // <<<<< End of User-Point   <<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<

       EndSr;
       //-------------------------------------------------------------------------------------------
       //===========================================================================================

      /Eject
       //==========================================================================================
       // Get the type of declaration encountered - it may not be on the current line!
       //==========================================================================================
       Dcl-Proc GetDeclarationType;

       // -- Procedure Interface ------------------------------------------------------------------
       Dcl-PI GetDeclarationType;
          ØpDeclType               Char( 2 );
          ØpSavedName              Char( 80 );
          ØpDeclLine                        Like(SRCSEQ);
       End-PI;

       // -- Data Structures ----------------------------------------------------------------------

       // -- Variables ----------------------------------------------------------------------------
       Dcl-S savedLineType        Char(  1 );
       Dcl-S x                  Packed( 3:0 );
       Dcl-S savedSRCDTA          Char( 100 );

       //-------------------------------------------------------------------------------------------

          // Start with what we've got.
          If ((declExt = ' ' and declPrefix  = ' ')
          or declPrefix = 'S' or declPrefix = 'U')
          and declSuffix = ' ';
             ØpDeclType = %xlate(lo:up:declType);
             ØpSavedName = %trim(declName);
          Else;
             ØpDeclType = *Blank;
             ØpSavedName = %trim(%subst(fullLine:1:74));
          EndIf;

          x = %scan(' ':ØpSavedName);
          If x > 1;
             ØpSavedName = %subst(ØpSavedName:1:x-1);
          EndIf;

          // If we already have the declaration type, then stop.
          If ØpDeclType = 'S'
          or ØpDeclType = 'DS'
          or ØpDeclType = 'C'
          or ØpDeclType = 'B'
          or ØpDeclType = 'E'
          or ØpDeclType = 'PR'
          or ØpDeclType = 'PI'
          or ØpDeclType = *Blanks and inPrototype;
             ØpDeclLine = SRCSEQ;
             Return;
          EndIf;

          savedSRCDTA = SRCDTA;
          savedLineType = %xlate(lo:up:lineType);      // Save current line type for comparison.
          x = 0;
          ØpDeclLine = 0;

          //   // Name of the variable/routine should be on this line.
          //   savedName = %trim(declOptions);

          // Trim any ellipsis from the name as this is not valid in free-form.
          x = %scan('...':ØpSavedName);
          If x > 0;
             ØpSavedName = %subst(ØpSavedName:1:x-1);
             x = 0;
          ElseIf declFrom <> *Blanks
              or declLen <> *Blanks
              or declOptions <> *BLanks;
             // It's not a declaration - it's a subfield.
             ØpDeclType = %xlate(lo:up:declType);
             ØpDeclLine = SRCSEQ;
             Return;
          EndIf;

          // Read ahead to find the next line with a declaration type.
          Read SRCREC;
          DoW not %eof();
             x += 1;     // Keep a track of how many lines we have read.

             lineType = %xlate(lo:up:lineType);

             If lineType <> savedLineType;
                // End of this declaration.
                Leave;
             EndIf;

             If declType <> *Blanks;
                // We have found the declaration.
                ØpDeclType = %xlate(lo:up:declType);
                ØpDeclLine = SRCSEQ;
                Leave;
             ElseIf declFrom <> *Blanks
                 or declLen <> *Blanks
                 or declOptions <> *BLanks;
                // It's not a declaration - it's a subfield.
                ØpDeclType = %xlate(lo:up:declType);
                ØpDeclLine = SRCSEQ;
                Leave;
             EndIf;

             Read SRCREC;
          EndDo;

          // End of file breaks the logic!  We need to reposition to the last record before
          // continuing.
          If %eof(QRPGLESRC);
             SetGT *HIVAL SRCREC;
             ReadP SRCREC;
          EndIf;

          // Return to the previous point.
          For i = 1 to x;
             ReadP SRCREC;
          EndFor;

          SRCDTA = savedSRCDTA;

          Return;

       //------------------------------------------------------------------------------------------
          End-Proc;

      /Eject
       //==========================================================================================
       // Split a line at a logical break based on a max length.
       //==========================================================================================
          Dcl-Proc SplitLine;

       // -- Procedure Interface ------------------------------------------------------------------
          Dcl-PI SplitLine;
             ØpCurrentLine        VarChar(92);
             ØpOverflow           VarChar(92);
             ØpMaxLength           Packed( 3:0 ) CONST;
          End-PI;

       // -- Data Structures ----------------------------------------------------------------------

       // -- Variables ----------------------------------------------------------------------------
          Dcl-S x                  Packed( 3:0 );

       //-------------------------------------------------------------------------------------------

          ØpOverflow = *Blanks;
          x = %len(%trim(ØpCurrentLine));
          If x > ØpMaxLength;
             x = ØpMaxLength;
          EndIf;

          // Scan backwards through the line, looking for a place to break it.
          For x = x downto 1;
             If %scan(%subst(ØpCurrentLine:x:1):' ') > 0;
                // Break here, and put the rest into a new line.
                ØpOverflow = %subst(ØpCurrentLine:x);
                ØpCurrentLine = %subst(ØpCurrentLine:1:x-1);
                Leave;
             EndIf;
          EndFor;

          Return;

       //------------------------------------------------------------------------------------------
          End-Proc;

      /Eject
       //==========================================================================================
       // Check for an array definition and adjust the length according to the number of elements.
       //==========================================================================================
          Dcl-Proc AdjustArrayLength;

       // -- Procedure Interface ------------------------------------------------------------------
          Dcl-PI AdjustArrayLength;
          ØpLength               Packed( 7:0 );
          End-PI;

       // -- Data Structures ----------------------------------------------------------------------

       // -- Variables ----------------------------------------------------------------------------
          Dcl-S x                  Packed( 3:0 );
          Dcl-S i                  Packed( 3:0 );
          Dcl-S j                  Packed( 3:0 );
          Dcl-S elements           Packed( 5:0 );
          Dcl-S savedSRCDTA          Char( 100 );

       //-------------------------------------------------------------------------------------------

          savedSRCDTA = SRCDTA;
          x = 0;

          // Read ahead to find the next line with a declaration type.
          DoW not %eof();
             // Array definition on the current line?
             i = %scan('DIM(':%xlate(lo:up:declKeywords));

             If i > 0;
                j = %scan(')':declKeywords:i+4);
                elements = %dec(%subst(declKeywords:i + 4:j - i - 4):7:0);
                // Adjust the length of the variable.
                If %rem(ØpLength:elements) = 0;
                   ØpLength = %div(ØpLength:elements);
                EndIf;
                Leave;
             EndIf;

             Read SRCREC;
             x += 1;     // Keep a track of how many lines we have read.

             lineType = %xlate(lo:up:lineType);

             If lineType <> *Blank
             and lineType <> 'D';
                // Not part of this definition - stop looking for array definition.
                Leave;

             ElseIf lineType = 'D'
             and %subst(directive:1:1) <> '*';                       // D-spec and no comment
                If declName <> *Blanks;
                   // A new declaration - stop looking for array definition.
                   Leave;
                EndIf;
             EndIf;
          EndDo;

          // End of file breaks the logic!  We need to reposition to the last record before
          // continuing.
          If %eof(QRPGLESRC);
             SetGT *HIVAL SRCREC;
             ReadP SRCREC;
          EndIf;

          // Return to the previous point.
          For i = 1 to x;
             ReadP SRCREC;
          EndFor;

          SRCDTA = savedSRCDTA;

          Return;

       //------------------------------------------------------------------------------------------
          End-Proc;
       //==========================================================================================
     O*QRPGLESRC2E            OUTREC
     O*                       SRCSEQ
     O*                       SRCDAT
     O*                       SRCDTA
**CTDATA ØopCodeUP
ACQ       Acq
BEGSR     BegSr
CALLP     CallP
CHAIN     Chain
CLEAR     Clear
CLOSE     Close
COMMIT    Commit
DEALLOC   DeAlloc
DELETE    Delete
DOU       DoU
DOW       DoW
DSPLY     Dsply
DUMP      Dump
ELSE      Else
ELSEIF    ElseIf
ENDDO     EndDo
ENDFOR    EndFor
ENDIF     EndIf
ENDMON    EndMon
ENDSL     EndSl
ENDSR     EndSr
EVAL      Eval
EVALR     EvalR
EVAL-CORR Eval-Corr
EXCEPT    Except
EXFMT     Exfmt
EXSR      Exsr
EXEC SQL  Exec SQL
FEOD      FEOD
FOR       For
FORCE     Force
IF        If
IN        In
ITER      Iter
LEAVE     Leave
LEAVESR   LeaveSr
MONITOR   Monitor
NEXT      Next
ON-ERROR  On-Error
OPEN      Open
OTHER     Other
OUT       Out
POST      Post
READ      Read
READC     ReadC
READE     ReadE
READP     ReadP
READPE    ReadPE
REL       Rel
RESET     Reset
RETURN    Return
ROLBK     RolBk
SELECT    Select
SETGT     SetGT
SETLL     SetLL
SORTA     SortA
TEST      Test
UNLOCK    Unlock
UPDATE    Update
WHEN      When
WRITE     Write
XML-INTO  XML-Into
XMLSAX    XMLSAX
ENDCS     ----------
AND       and
OR        or
**CTDATA ØdeclUP
DCL-F     Dcl-F
DCL-S     Dcl-S
DCL-C     Dcl-C
DCL-PR    Dcl-PR
DCL-PI    Dcl-PI
DCL-PROC  Dcl-Proc
DCL-DS    Dcl-DS
END-DS    End-DS
END-PR    End-PR
END-PI    End-PI
END-PROC  End-Proc
CTL-OPT   Ctl-Opt
**CTDATA Øcomments
//===========================================================================================
// Start of moved field definitions.
// End of moved field definitions.
