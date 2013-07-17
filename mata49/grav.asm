;;;
;;;
;;; grav.asm
;;;	Write geographic coordinates to a file.
;;;
;;;

%include "macros.inc"
%include "sys.asm"
%include "io.asm"

%include "data.inc"
%include "helpers.asm"

global _start

[section .text]
_start:
	clc
	push	GRAV_FANCY_PROGRAM_HEADER, STDOUT
	call	io.write
	jc	.error
	
;; Ask filename
	;write prompt
    	push	GRAV_FILENAME_PROMPT, STDOUT
    	call	io.write
    	jc	.error
    	
    	;read filename
    	push	255, _filename, STDIN
    	call	io.readln
    	jc	.error
    	
    	; exit if no filename given
    	cmp	eax, 1
    	je	.exit
    	
;; Create output file
	;create
	push	S_IRUSR | S_IWUSR, _filename
	call	sys.creat
	jc	.error
	
	;save file descriptor
	mov	edx, eax

;; Ask locale
.ask_locale:
	;write header
	push	GRAV_NEW_LOCALE_HEADER, STDOUT
	call	io.write
	jc	.error
	
	;ask
	push	_locale
	call	geo.ask_locale
	jc	.error
	jo	.exit

	;write locale to output file
	push	Locale_SIZE, _locale, edx
	call	sys.write
	jc	.error
	
	;continue to next locale
	jmp	.ask_locale


.exit:
	;close output file
	push	ebx
	call	sys.close
	
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


[section .bss]
_filename	resb 255
_locale		resb 36

