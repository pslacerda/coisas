;;;
;;;
;;; calc.asm
;;;	Compute geographic coordinates distances.
;;;
;;;

%include "macros.inc"
%include "sys.asm"
%include "io.asm"

%include "data.inc"
%include "helpers.asm"
%include "bulk.asm"
%include "interactive.asm"

global _start
[section .text]
_start:
	cld
	push	CALC_FANCY_PROGRAM_HEADER, STDOUT
	call	io.write
	jc	.error
	
;; Ask origin
	;write prompt
	push	CALC_ORIGIN_PROMPT, STDOUT
	call	io.write
	jc	.error
	
	;ask
	push	_calc_origin
	call	geo.ask_locale
	jc	.error
	jo	.exit

;; Decide if go to bulk or interactive mode
	;write prompt
	push	CALC_DECIDE_MODE_PROMPT, STDOUT
	call	io.write
	jc	.error
	
	;read input filename
	push	255, _calc_buffer, STDIN
	call	io.readln
	jc	.error
	
	;exit if no filename given
	cmp	eax, 1
	je	.exit
	
	;check for the file existence
	push	R_OK, _calc_buffer
	call	sys.access
	
	;make decision
	cmp	eax, 0
	je	.bulk_mode		;we can read it, go for bulk mode
	jmp	.interactive_mode	;user entered some city name, go
					; for interactive
;; Enter in bulk mode
.bulk_mode:
	push	_calc_buffer	; input filename
	push	_calc_origin	; origin locale
	call	modes.bulk
	
	jc	.error
	jmp	.exit

;; Enter in interactive mode	
.interactive_mode:
	push	_calc_buffer	; name of destination city
	push	_calc_origin	; origin locale
	call	modes.interactive
	
	jc	.error
	jmp	.exit


.exit:
	;no problems so far
	mov	ebx, 0
	jmp	.terminate
	
.error:
	;something gone wrong
	mov	ebx, 1
	push	ERR_MSG, STDERR
	call	io.write
	
.terminate:
	push	ebx
	call	sys.exit

[section .data]
[section .bss]
_calc_origin	resb 36
_calc_buffer	resd 1
