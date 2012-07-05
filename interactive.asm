%ifndef __INTERACTIVE
%define __INTERACTIVE

%include "io.asm"
%include "sys.asm"
%include "geo.asm"

[section .text]

;;;
;;; modes.interactive
;;; 	Enter in interactive mode.
;;; args:
;;;	+ locale name
;;;     + origin
;;; 
PROC modes.interactive, 4, 8
	
	;parameters
	%define $dname	[ebp + 8]	;destine name
	%define $org	[ebp + 12]	;origin locale
	
	;variables
	%define $dst	[ebp - 4]	;destination locale
	
	;aliases
	%define $_buffer1		_inter_buffer2
	%define $_buffer2		_inter_buffer3
	%define $_latitude_prompt	_inter_prompt1
	%define $_longitude_prompt	_inter_prompt2
	%define $_program_header	_header1
	%define $_origin_header		_inter_header1
	%define $_destination_header	_inter_header2
	
;; Setup
	mov	eax, _inter_buffer1
	mov	$dst, eax
	
	;clear $dst locale
	push	0, 36, dword $dst
	call	str.fill

;; Store destine name
	;setup
	mov	esi, $dname
	mov	edi, $dst
	add	edi, Locale.name
	
	;store
	push	30, edi, esi
	call	str.ncopy

;; Ask latitude
.ask_latitude:
	;setup
	mov	edi, $dst
	add	edi, Locale.latitude
	
	print	$_latitude_prompt, STDOUT
	
	;read coordinate
	push	'n', 's', 90, edi, STDIN
	call	geo.read_coord
	
	jc	.error
	jo	.latitude_error
	
	;continue
	jmp	.ask_longitude

.latitude_error:
	print	_inter_err1, STDOUT
	jmp	.ask_latitude


;; Ask longitude
.ask_longitude:
	;setup
	mov	edi, $dst
	add	edi, Locale.longitude
	
	print	$_longitude_prompt, STDOUT
	
	;read coordinate
	push	'e', 'w', 180,  edi, STDIN
	call	geo.read_coord
	
	jc	.error
	jo	.longitude_error
	
	;continue
	jmp	.write_header
	
.longitude_error:
	print	$_longitude_prompt, STDOUT
	jmp	.ask_longitude


;; Write headers
.write_header:
	;clear screen	
	call	term.clear
	jc	.error
	
	print	$_program_header, STDOUT


;; Print origin
.print_origin:
	;setup
	mov	esi, $org
	add	esi, Locale
	
	;print header
	print	$_origin_header, STDOUT
	
	;print origin
	push	esi, STDOUT
	call	geo.print_locale
	jc	.error
	
	;print two new lines
	mov	dword [$_buffer1], 10 << 8 | 10
	push	dword $_buffer1, STDOUT
	call	io.write
	
;; Printe destinations
.print_destinations:
	;setup
	mov	esi, $dst
	add	esi, Locale
	
	;print header
	print $_destination_header, STDOUT
	
	;print destinatin
	push	esi, STDOUT
	call	geo.print_locale
	jc	.error
	
	;compute distance
	push	dword $dst, dword $org
	call	geo.compute_distance
	mov	ebx, eax
	
	;convert distance to string
	push	$_buffer1, ebx
	call	str.itoa
	jc	.error
	
	;format distance
	push	' ', 18, $_buffer1
	call	str.fill
	
	push	$_buffer1, $_buffer2
	call	str.rjust
	jc	.error
	
	push	$_buffer2, STDOUT
	call	io.writeln
	jc	.error
	
	clc
	jmp	.exit
.error:
	stc
.exit:
	exit
ENDPROC

[section .data]
_inter_err1	db 27,"[1;31mDados inválidos!",27,"[0m",10, 0

_inter_header1	db "Origem                        Latitude   Longitude",10,0
_inter_header2	db "Destino                       Latitude   Longitude   Distância (km)",10,0

_inter_prompt1	db "    Lat.  <graus, minutos, orientação>: ", 0
_inter_prompt2	db "    Long. <graus, minutos, orientação>: ", 0

[section .bss]
_inter_buffer1		resb 36
_inter_buffer2		resb 36
_inter_buffer3		resb 36


%endif
