%include "macros.inc"
%include "io.asm"
%include "str.asm"

[section .text]
;;;
;;; geo.read_coord
;;; 	Read a line and parse into a Coordinate structure.
;;; args:
;;;     + file descriptor
;;;     + pointer to structure
;;;     + max degree
;;;	+ orientation ('N'| 'E')
;;;	+ orientation ('S', 'W')
;;; ret:
;;;     Nothing
;;; err:
;;;	Overflow flag set on parser error. Carry flag set on other errors.
;;; 
PROC geo.read_coord, 0, 20
	%define $fp		[ebp + 8]
	%define $locale		[ebp + 12]
	%define $max_deg	[ebp + 16]
	%define $coord1		[ebp + 20]
	%define $coord2		[ebp + 24]
	
	push	esi, edi, ebx, edx
	
	mov	esi, _coord_buf
	mov	edi, $locale
	
	;; Read line into buffer
	push	255, esi, dword $fp
	call	io.readln
	jc	.error
	
	;; Parse degrees
	push	esi
	call	str.atoi
	jc	.input_error
	add	esi, edx

	;; Validade degrees
	cmp	eax, $max_deg
	jg	.input_error
	mov	[edi + Coordinate.degrees], al
	
	;; Parse minutes
	push	esi
	call	str.atoi
	jc	.input_error
	add	esi, edx
	
	;; Validade minutes
	cmp	eax, 59
	jg	.input_error
	mov	[edi + Coordinate.minutes], al
	
	;; Skip spaces
	push	esi
	call	str.skip_spaces
	jc	.input_error
	mov	esi, eax
	
	;; Parse orientation
	mov	al, [esi]
	
	;; Validade orientation
	mov	bl, byte $coord1
	mov	bh, byte $coord2
	
	cmp	al, bl
	je	.data_ok
	sub	bl, 'a' - 'A'
	cmp	al, bl
	je	.data_ok
	
	cmp	al, bh
	je	.data_ok
	sub	bh, 'a' - 'A'
	cmp	al, bh
	je	.data_ok
	jmp	.input_error
	
	
.data_ok:
	;; Is orientation upper case?
	cmp	al, 'a'
	jl	.save_data
	
	;; Turn orientation lower case
	sub	al, 'a' - 'A'

.save_data:
	mov	[edi + Coordinate.orientation], al
	
	clc
	jmp	.quit
.error:
	stc
	jmp	.quit
.input_error:
	clc
	mov	al, 127 ;
	inc	al	; overflow, input error
	jmp	.quit
.quit:
	pop	edx, ebx, edi, esi
	exit
ENDPROC


;;;
;;; geo.ask_locale
;;; 	Ask the user for a locale.
;;; args:
;;;     + pointer to locale structure
;;; ret:
;;;     Nothing
;;; err:
;;;	Overflow flag set for no input given. Carry flag set on other errors.
;;; 
PROC geo.ask_locale, 0, 4
	push	edi, ecx
	
	mov	edi, [ebp + 8]
	
	;;; Clean locale variable
	mov	ecx, 36
	mov	eax, 0
	rep	stosb
	sub	edi, 36

	;;; Ask locale name
	;; Write prompt
	push	_geo_prompt1, STDOUT
	call	io.write
	jc	.error
	;; Read locale name
	push	30, edi + Locale.name, STDIN
	call	io.readln
	jc	.error
	;; Quit function
	cmp	eax, 1
	je	.eoi

.ask_latitude:
	;; Write prompt
	push	_geo_prompt2, STDOUT
	call	io.write
	jc	.error
	
	;; Read coordiante
	lea	eax, [edi + Locale.latitude]
	push	'n', 's', 90, eax, STDIN
	call	geo.read_coord
	jc	.error
	
	;; Input error
	jo	.latitude_error
	
	;; Continue to longitude
	jmp	.ask_longitude

.latitude_error:
	push	_geo_err1, STDOUT
	call	io.write
	jc	.error
	jmp	.ask_latitude

.ask_longitude:
	;; Write prompt
	push	_geo_prompt3, STDOUT
	call	io.write
	jc	.error
	
	;; Read coordinate
	lea	eax, [edi + Locale.longitude]
	push	'e', 'w', 180,  eax, STDIN
	call	geo.read_coord
	jc	.error
	;; Input error
	jo	.longitude_error
	
	;; Continue to write file
	jmp	.quit
	
.longitude_error:
	push	_geo_err1, STDOUT
	call	io.write
	jc	.error
	jmp	.ask_longitude

.eoi: ;End Of Input
	clc
	mov	al, 127 ;
	inc	al	; set OF
	jmp	.quit
.error:
	stc
.quit:
	pop	ecx, edi
	exit
ENDPROC

[segment .data]
_geo_err1	db 27,"[1;31mDados inválidos!",27,"[0m",10, 0
_geo_prompt1	db "    Nome                              : ", 0
_geo_prompt2	db "    Lat.  <graus, minutos, orientação>: ", 0
_geo_prompt3	db "    Long. <graus, minutos, orientação>: ", 0

[section .bss]
_coord_buf	resb 255
