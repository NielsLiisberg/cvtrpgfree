
#-----------------------------------------------------------
# User-defined part start
#

# NOTE - UTF is not allowed for ILE source (yet) - so convert to WIN-1252

# BIN_LIB is the destination library for the service program.
# the rpg modules and the binder source file are also created in BIN_LIB.
# binder source file and rpg module can be remove with the clean step (make clean)
BIN_LIB=CVTRPGFREE
LIBLIST=$(BIN_LIB)
DBGVIEW=*ALL
TARGET_CCSID=*JOB
SHELL=/QOpenSys/usr/bin/qsh
OBJECT_DESCRIPTION=Convert to RPG free
OUTPUT=*PRINT
RCFLAGS=OPTION(*NOUNREF) DBGVIEW(*LIST)  OUTPUT($(OUTPUT)) INCDIR('./..')
SQLRPGCFLAGS=OPTION(*NOUNREF) DBGVIEW(*LIST)  OUTPUT($(OUTPUT)) INCDIR(''./..'')
FILTERXXX=| grep '*RNF' | grep -v '*RNF7031' | sed  "s!*!$<: &!"
FILTER=>errorlist.txt

# Do not touch below
INCLUDE='/QIBM/include' 'headers/' 

CCFLAGS=OPTIMIZE(10) ENUM(*INT) TERASPACE(*YES) STGMDL(*INHERIT) SYSIFCOPT(*IFSIO) INCDIR($(INCLUDE)) DBGVIEW($(DBGVIEW)) TGTCCSID($(TARGET_CCSID))

# For current compile:
CCFLAGS2=OPTION(*STDLOGMSG) OUTPUT(*print) OPTIMIZE(10) ENUM(*INT) TERASPACE(*YES) STGMDL(*INHERIT) SYSIFCOPT(*IFSIO) DBGVIEW(*ALL) INCDIR($(INCLUDE)) 
CCFLAGSB=OPTION(*STDLOGMSG) OUTPUT(*print) OPTIMIZE(10) ENUM(*INT) TERASPACE(*YES) SYSIFCOPT(*IFSIO) DBGVIEW(*ALL) INCDIR($(INCLUDE)) 

#
# User-defined part end
#-----------------------------------------------------------

# Dependency list

all:  $(BIN_LIB).lib nooutput cvtrpgfree.obj 

cvtrpgfree.obj: cvtrpgfree.clle cvtrpgfree.cmd cvtrpgfree.prtf cvtrpgfree.rpgle  

cvtrpgfree.bnddir: cvtrpgfree.entry

#-----------------------------------------------------------

%.lib:
	-system -q "CRTLIB $* TYPE(*TEST)"


%.entry:
	# Basically do nothing..
	@echo "Adding binding entry $*"

%.c:
	system -q "CHGATR OBJ('src/$*.c') ATR(*CCSID) VALUE(1252)"
	system "CRTBNDC PGM($(BIN_LIB)/$(notdir $*)) SRCSTMF('src/$*.c') $(CCFLAGSB)"

%.rpgle:
	- system -q "CRTSRCPF FILE($(BIN_LIB)/QRPGLESRC)  RCDLEN(112)"
	- system -q "CRTSRCPF FILE($(BIN_LIB)/QRPGLESRC2) RCDLEN(112)"
	touch errorlist.txt ;\
	setccsid 1252 errorlist.txt;\
	liblist -a $(LIBLIST);\
	setccsid 1252 src/$*.rpgle;\
	system -iK "CRTBNDRPG PGM($(BIN_LIB)/$(notdir $*)) SRCSTMF('src/$*.rpgle') $(RCFLAGS) TEXT('$(OBJECT_DESCRIPTION)')" $(FILTER) ;\
	
%.sqlrpgle:
	liblist -a $(LIBLIST);\
	system -iK "CRTSQLRPGI OBJ($(BIN_LIB)/$(notdir $*)) SRCSTMF('src/$*.sqlrpgle') RPGPPOPT(*LVL2) COMPILEOPT('$(SQLRPGCFLAGS)') DBGVIEW(*NONE) TEXT('$(OBJECT_DESCRIPTION)')"


%.cmd:
	system -q "CHGATR OBJ('src/$*.cmd') ATR(*CCSID) VALUE(1252)"
	-system -q "CRTSRCPF FILE($(BIN_LIB)/QCMDSRC) RCDLEN(132)"
	system "CPYFRMSTMF FROMSTMF('src/$*.cmd') TOMBR('/QSYS.lib/$(BIN_LIB).lib/QCMDSRC.file/$(notdir $*).mbr') MBROPT(*REPLACE)"
	system "CRTCMD prdlib($(BIN_LIB)) cmd($(BIN_LIB)/$(notdir $*)) PGM($(notdir $*)) SRCFILE($(BIN_LIB)/QCMDSRC)"

%.prtf:
	system -q "CHGATR OBJ('src/$*.prtf') ATR(*CCSID) VALUE(1252)"
	-system -q "CRTSRCPF FILE($(BIN_LIB)/QDDSSRC) RCDLEN(132)"
	system "CPYFRMSTMF FROMSTMF('src/$*.prtf') TOMBR('/QSYS.lib/$(BIN_LIB).lib/QDDSSRC.file/$(notdir $*).mbr') MBROPT(*REPLACE)"
	system "CRTPRTF  file($(BIN_LIB)/$(notdir $*)) SRCFILE($(BIN_LIB)/QDDSSRC)"

%.clle:
	system -q "CHGATR OBJ('src/$*.clle') ATR(*CCSID) VALUE(1252)"
#-system -q "CRTSRCPF FILE($(BIN_LIB)/QCLLESRC) RCDLEN(132)"
#	system "CPYFRMSTMF FROMSTMF('src/$*.clle') TOMBR('/QSYS.lib/$(BIN_LIB).lib/QCLLESRC.file/$(notdir $*).mbr') MBROPT(*REPLACE)"
	system "CRTBNDCL pgm($(BIN_LIB)/$(notdir $*)) SRCSTMF('src/$*.clle') DBGVIEW($(DBGVIEW))"

%.srvpgm:
	system -q "CRTSRCPF FILE($(BIN_LIB)/QSRVSRC) RCDLEN(112)"
	system "CPYFRMSTMF FROMSTMF('headers/$*.binder') TOMBR('/QSYS.lib/$(BIN_LIB).lib/QSRVSRC.file/$*.mbr') MBROPT(*replace)"
	
	# You may be wondering what this ugly string is. It's a list of objects created from the dep list that end with .c or .clle.
	$(eval modules := $(patsubst %,$(BIN_LIB)/%,$(basename $(filter %.c %.clle,$(notdir $^)))))
	
	system -q -kpieb "CRTSRVPGM SRVPGM($(BIN_LIB)/$*) MODULE($(modules)) SRCFILE($(BIN_LIB)/QSRVSRC) ACTGRP(QILE) ALWLIBUPD(*YES) TGTRLS(*current)"


all:
	@echo Build success!

nooutput:
	OUTPUT=*NONE

clean:
	-system -q "DLTOBJ OBJ($(BIN_LIB)/*ALL) OBJTYPE(*FILE)"
	-system -q "DLTOBJ OBJ($(BIN_LIB)/*ALL) OBJTYPE(*MODULE)"
	
release: clean
	@echo " -- Creating cvtrpgfree release. --"
	@echo " -- Creating save file. --"
	system "CRTSAVF FILE($(BIN_LIB)/cvtrpgfree)"
	system "SAVLIB LIB($(BIN_LIB)) DEV(*SAVF) SAVF($(BIN_LIB)/cvtrpgfree) OMITOBJ((RELEASE *FILE))"
	-rm -r release
	-mkdir release
	system "CPYTOSTMF FROMMBR('/QSYS.lib/$(BIN_LIB).lib/CVTRPGFREE.FILE') TOSTMF('./release/cvtrpgfree.savf') STMFOPT(*REPLACE) STMFCCSID(1252) CVTDTA(*NONE)"
	@echo " -- Cleaning up... --"
	system "DLTOBJ OBJ($(BIN_LIB)/cvtrpgfree) OBJTYPE(*FILE)"
	@echo " -- Release created! --"
	@echo ""
	@echo "To install the release, run:"
	@echo "  > CRTLIB $(BIN_LIB)"
	@echo "  > CPYFRMSTMF FROMSTMF('./release/cvtrpgfree.savf') TOMBR('/QSYS.lib/$(BIN_LIB).lib/CVTRPGFREE.FILE') MBROPT(*REPLACE) CVTDTA(*NONE)"
	@echo "  > RSTLIB SAVLIB($(BIN_LIB)) DEV(*SAVF) SAVF($(BIN_LIB)/CVTRPGFREE)"
	@echo ""

# For vsCode / single file then i.e.: gmake current sqlio.c  
current: 
	system -i "CRTCMOD MODULE($(BIN_LIB)/$(SRC)) SRCSTMF('src/$(SRC).c') $(CCFLAGS2) "

# For vsCode / single file then i.e.: gmake current sqlio.c  
example: 
	system -i "CRTBNDRPG PGM($(BIN_LIB)/$(SRC)) SRCSTMF('examples/$(SRC).rpgle') DBGVIEW(*ALL)" > error.txt