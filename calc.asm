
%include "macros.inc"
%include "sys.asm"
%include "io.asm"

%include "geo.asm"

global _start
[section .text]
_start:
	push	_prompt1, STDOUT
	call	io.writeln
	jc	.error
	
.ask_origin:
	push	_origin
	call	geo.ask_locale
	jc	.error
	jo	.quit		; no local given


.quit:
	mov	ebx, 0
	jmp	.terminate
.error:
	mov	ebx, 1
	push	_err0, STDERR
	call	io.write
.terminate:
	push	dword [_filehandle]
	call	sys.close
	
	push	ebx
	call	sys.exit

[section .data]
_err0		db 10,27,"[1;31mError!",27,"[0m",10,0
_prompt1	db "Localidade de origem ou <RET> para terminar: ", 0
_prompt2	db "Arquivo de coordenadas ou localidade ou <RET> para terminar: ", 0

[section .bss]
_origin		resb 36
