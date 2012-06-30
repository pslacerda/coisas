%ifndef __TERM
%define __TERM

%include "io.asm"


PROC term.clear, 0, 0
	push	_term_clear, STDOUT
	call	io.write
	jc	.error
	clc
	jmp	.quit
.error:
	stc
.quit:
	exit
ENDPROC

[section .data]
_term_clear	db 27,"[2J", 0

%endif
