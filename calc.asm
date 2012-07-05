
%include "macros.inc"
%include "sys.asm"
%include "io.asm"

%include "utils.asm"
%include "bulk.asm"
%include "interactive.asm"

global _start
[section .text]
_start:
	cld
	push	_header1, STDOUT
	call	io.write
	jc	.error
	
.ask_origin:
	;; Write prompt
	push	_prompt1, STDOUT
	call	io.write
	jc	.error
	;; Ask origin
	push	_origin
	call	geo.ask_locale
	jc	.error
	jo	.quit

.decide_bulk_or_interactive:
	;; Write prompt
	push	_prompt2, STDOUT
	call	io.write
	jc	.error
	;; Read line
	push	30, _buffer, STDIN
	call	io.readln
	jc	.error
	;; Quit if empty input
	cmp	eax, 1
	je	.quit
	;; Try to open the input file
	push	R_OK, _buffer
	call	sys.access
	
	;; Go to bulk mode if file exists, interactive mode otherwise
	cmp	eax, 0
	je	.bulk_mode
	jmp	.interactive_mode

.bulk_mode:
	push	_origin, _buffer
	call	modes.bulk
	jc	.error
	jmp	.quit
	
.interactive_mode:
	push	_origin, _buffer
	call	modes.interactive
	jc	.error
	jmp	.quit

.quit:
	mov	ebx, 0
	jmp	.terminate
.error:
	mov	ebx, 1
	push	_err1, STDERR
	call	io.write
	
.terminate:
	push	ebx
	call	sys.exit

[section .data]
_header1	db 27,"[1;32m", "Universidade Federal da Bahia",10
		db "MATA49 Programação de Software Básico",10,10
		db "Cálculo de distâncias geodésicas",27,"[0m",10,10,0
_err1		db 10,27,"[1;31mErro!",27,"[0m",10,0
_prompt1	db "Informe a origem (↵ encerra): ", 10, 0
_prompt2	db 10, "Arquivo de coordenadas ou destino (↵ encerra) : ", 0

[section .bss]
_origin		resb 36
_buffer		resb 30
_infile		resd 1
