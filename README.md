# cvtrpgfree
Convert RPG to free

* Features:
Non-destructive conversion: The utility converts the source from one member to a new member (the original source is left untouched), converting, where possible, fixed-format code to free-form code.


Clearer, cleaner code: Free-form code (both new and existing) is indented to show nesting, and all opcodes are converted to a standard case format for consistency.


Definition consolidation: All in-line field definitions are moved to 'D' specs. Duplicate definitions (which do not generate compiler errors when defined in fixed-format) are dropped to avoid confusion.


Consistent free-form definitions: File, constant and variable declarations are converted to their free-form equivalents (see caveats in documentation).


* SEE/Change-friendly: 
Converted lines have their original change date (and prefix) preserved, which fools SEE/Change into thinking that the line hasn't changed. This is useful because converted lines aren't flagged as changed, whereas any lines that are subsequently changed/added are highlighted, meaning that a source can be converted to free-form as part of an amendment and only the actual changes performed subsequent to the conversion are flagged, making the actual changes stand out from the conversion.


* Audit Report: 
An audit report is produced listing every source member processed by the utility, detailing the number of lines, the number of lines converted and a conversion ratio.

* Mass conversion: 
The utility can be run for all members of a source file, enabling the mass conversion of legacy code to the latest free-form version.
