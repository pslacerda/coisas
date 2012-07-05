
%include "macros.inc"

%include "sys.asm"
%include "io.asm"

%include "utils.asm"

global _start
[section .text]
_start:
	clc
	push	_header1, STDOUT
	call	io.write
	jc	.error
	
.ask_filename:
	;; Write prompt
    	push	_prompt1, STDOUT
    	call	io.write
    	jc	.error
    	;; Read filename
    	push	255, _filename, STDIN
    	call	io.readln
    	jc	.error
    	;; No filename given, quit
    	cmp	eax, 1
    	je	.quit
    	
.create_file:
	push	S_IRUSR | S_IWUSR, _filename
	call	sys.creat
	jc	.error
	mov	[_filehandle], eax

.ask_locale:
	;; Write header
	push	_header2, STDOUT
	call	io.write
	jc	.error
	
	push	_locale
	call	geo.ask_locale
	jc	.error
	jo	.quit		; no local given

.write_file:
	push	36, _locale, dword [_filehandle]
	call	sys.write
	jc	.error
	;; Continue to next locale
	jmp	.ask_locale


.quit:
	mov	ebx, 0
	jmp	.terminate
.error:
	mov	ebx, 1
	push	_err1, STDERR
	call	io.write
.terminate:
	push	dword [_filehandle]
	call	sys.close
	
	push	ebx
	call	sys.exit


[section .data]
_header1	db 27,"[1;32mUniversidade Federal da Bahia",10
		db "MATA49 Programação de Software Básico",27,"[0m",10,10, 0
_header2	db 27,"[1;34m  Nova localidade (↵ encerra):",27,"[0m",10, 0
_err1		db 10,27,"[1;31mErro!",27,"[0m",10,0
_prompt1	db "Arquivo de coordenadas (↵ encerra): ", 0

[section .bss]
_filename	resb 255
_filehandle	resd 1
_locale		resb 36
