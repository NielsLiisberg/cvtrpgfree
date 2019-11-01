# cvtrpgfree
Convert RPG to free


### Installation
What you need before you start:

* IBM i 7.3 TR3 (or higher)
* YUM installed from ACS (to install: git and make-gnu (gmake))
* ILE RPG compiler


From a IBM i menu prompt start the SSH deamon:`===> STRTCPSVR *SSHD`
And start ssh from win/mac/linux

first install the opensource tools:
```
yum install git
yum install make-gnu
```
Now you are ready to clone the cvtrpgfree  git repo: 

```
mkdir /prj
cd /prj 
git -c http.sslVerify=false clone  git@github.com:NielsLiisberg/cvtrpgfree.git
cd cvtrpgfree
gmake all 
```

By now you will have a library CVTRPGFREE with a command CVTRPGFREE and you can bring 
your code forward.


### vsCode
This repo includes the .vsCode folder that makes it easyc  to just build 
the package and compile the programs. However you need to xhange 
references in task.js file to point to your IBM i.


### Features:
Non-destructive conversion: The utility converts the source from one member to a new member (the original source is left untouched), converting, where possible, fixed-format code to free-form code.

Clearer, cleaner code: Free-form code (both new and existing) is indented to show nesting, and all opcodes are converted to a standard case format for consistency.

Definition consolidation: All in-line field definitions are moved to 'D' specs. Duplicate definitions (which do not generate compiler errors when defined in fixed-format) are dropped to avoid confusion.

Consistent free-form definitions: File, constant and variable declarations are converted to their free-form equivalents (see caveats in documentation).


### SEE/Change-friendly: 
Converted lines have their original change date (and prefix) preserved, which fools SEE/Change into thinking that the line hasn't changed. This is useful because converted lines aren't flagged as changed, whereas any lines that are subsequently changed/added are highlighted, meaning that a source can be converted to free-form as part of an amendment and only the actual changes performed subsequent to the conversion are flagged, making the actual changes stand out from the conversion.


### Audit Report: 
An audit report is produced listing every source member processed by the utility, detailing the number of lines, the number of lines converted and a conversion ratio.

### Mass conversion: 
The utility can be run for all members of a source file, enabling the mass conversion of legacy code to the latest free-form version.


# Thanx
This project vas original started at SourceForge by Ewarwoowar - Thank you for all the good work.
  
