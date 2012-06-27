
%include "macros.inc"
%include "sys.asm"
%include "io.asm"

%include "geo.asm"
%include "bulk.asm"
%include "interactive.asm"

global _start
[section .text]
_start:
	clc
	push	_header, STDOUT
	call	io.write
	
.ask_origin:
	;; Write prompt
	push	_prompt1, STDOUT
	call	io.writeln
	jc	.error
	;; Ask origin
	push	_origin
	call	geo.ask_locale
	jc	.error
	jo	.quit

.decide_if_bulk_or_interactive:
	;; Write prompt
	push	_prompt2, STDOUT
	call	io.write
	jc	.error
	;; Read line
	push	30, _buffer, STDIN
	call	io.readln
	jc	.error
	;; Quit in case of empty input
	cmp	eax, 1
	je	.quit
	;; Try to open the input file
	push	S_IRUSR, _buffer
	call	sys.access
.bla:
	;; If the file exists goto bulk mode, goto interactive otherwise
	cmp	eax, 0
	je	.bulk_mode
	jmp	.interactive_mode

.bulk_mode:
	push	_buffer
	call	modes.bulk
	jc	.error
	jmp	.quit
	
.interactive_mode:
	push	_buffer
	call	modes.interactive
	jc	.error
	jmp	.quit

.quit:
	mov	ebx, 0
	jmp	.terminate
.error:
	mov	ebx, 1
	push	_err0, STDERR
	call	io.write
.terminate:
;	push	dword [_filehandle]
;	call	sys.close
	
	push	ebx
	call	sys.exit

[section .data]
_header		db 27,"[1;32mUniversidade Federal da Bahia",10
		db "MATA49 Programação de Software Básico",27,"[0m",10,10, 0
_err0		db 10,27,"[1;31mErro!",27,"[0m",10,0
_prompt1	db "Dados da origem (RET termina)", 0
_prompt2	db "Arquivo de coordenadas ou nome de localidade (RET termina): ", 0

[section .bss]
_origin		resb 36
_buffer		resb 30
_infile		resd 1
