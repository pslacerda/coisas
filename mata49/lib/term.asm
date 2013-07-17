%ifndef __TERM
%define __TERM

%include "io.asm"

;;;
;;; term.clear
;;; 	Clear the terminal. The terminal must support ANSI/VT100+ escape sequences.
;;; 

[section .text]
PROC term.clear, 0, 0
	push	eax
	
	push	_term_clear, STDOUT
	call	io.write
	jc	.error
	clc
	jmp	.quit
.error:
	stc
.quit:
	pop	eax
	exit
ENDPROC

[section .data]
_term_clear	db 27,"[2J", 0

%endif
