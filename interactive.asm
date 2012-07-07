%ifndef __INTERACTIVE
%define __INTERACTIVE

%include "io.asm"
%include "sys.asm"
%include "helpers.asm"

[section .text]

;;;
;;; modes.interactive
;;; 	Enter in interactive mode.
;;; args:
;;;	+ locale name
;;;     + origin
;;; 
PROC modes.interactive, 4, 8
	
	push	ebx, ecx, edx, edi, esi
;;
;;	ECX: Origin pointer
;;	EDX: Destination pointer
;;

;; Setup
	mov	ecx, [ebp + 12]
	mov	edx, _inter_buf1
	
	;clear destination
	push	0, 36, edx
	call	str.fill

;; Store destination name
	;setup
	mov	esi, [ebp + 8]
	mov	edi, edx
	add	edi, Locale.name
	
	;store
	push	30, edi, esi
	call	str.ncopy

;; Ask latitude
.ask_latitude:
	;setup
	mov	edi, edx
	add	edi, Locale.latitude
	
	print	HELPERS_LOCALE_LATITUDE_PROMPT, STDOUT
	
	;read coordinate
	push	'n', 's', 90, edi, STDIN
	call	geo.read_coord
	
	jc	.error
	jo	.latitude_error
	
	;continue
	jmp	.ask_longitude

.latitude_error:
	print	ERR_INVALID_DATA, STDOUT
	jmp	.ask_latitude


;; Ask longitude
.ask_longitude:
	;setup
	mov	edi, edx
	add	edi, Locale.longitude
	
	print	HELPERS_LOCALE_LONGITUDE_PROMPT, STDOUT
	
	;read coordinate
	push	'e', 'w', 180,  edi, STDIN
	call	geo.read_coord
	
	jc	.error
	jo	.longitude_error
	
	;continue
	jmp	.write_header
	
.longitude_error:
	print	ERR_INVALID_DATA, STDOUT
	jmp	.ask_longitude


;; Write headers
.write_header:
	;clear screen	
	call	term.clear
	jc	.error
	
	print	CALC_FANCY_PROGRAM_HEADER, STDOUT


;; Print origin
.print_origin:
	;setup
	mov	esi, ecx
	add	esi, Locale
	
	;print header
	print	CALC_ORIGIN_HEADER, STDOUT
	
	;print origin
	push	esi, STDOUT
	call	geo.print_locale
	jc	.error
	
	;print two new lines
	mov	dword [_inter_buf2], 10 << 8 | 10
	print	_inter_buf2, STDOUT
	
;; Print destinations
.print_destinations:
	;setup
	mov	esi, edx
	add	esi, Locale
	
	;print header
	print CALC_DESTINATION_HEADER, STDOUT
	
	;print destinatin
	push	esi, STDOUT
	call	geo.print_locale
	jc	.error
	
	;compute distance
	push	edx, ecx
	call	geo.locale_distance
	mov	ebx, eax
	
	;convert distance to string
	push	_inter_buf2, ebx
	call	str.ftoa
	jc	.error
	
	;format distance
	push	' ', 18, _inter_buf3
	call	str.fill
	
	push	_inter_buf2, _inter_buf3
	call	str.rjust
	jc	.error
	
	push	_inter_buf3, STDOUT
	call	io.writeln
	jc	.error
	
	clc
	jmp	.exit
.error:
	stc
.exit:
	pop	esi, edi, ebx
	exit
ENDPROC

[section .bss]
_inter_buf1		resb 36
_inter_buf2		resb 36
_inter_buf3		resb 36


%endif
