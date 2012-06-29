%ifndef __INTERACTIVE
%define __INTERACTIVE

%include "io.asm"
%include "sys.asm"

[section .text]
PROC modes.interactive, 0, 4
	exit
ENDPROC

[section .data]
[section .bss]

%endif
