%ifndef __HELPERS
%define __HELPERS

%include "macros.inc"
%include "io.asm"
%include "str.asm"
%include "math.asm"

%include "data.inc"

%imacro PRINT 2
	push	%1, %2
	call	io.write
	jc	.error
%endmacro

[section .text]
;;;
;;; geo.read_coord
;;; 	Read a line and parse into a Coordinate structure.
;;; args:
;;;     + file descriptor
;;;     + pointer to structure
;;;     + max degree
;;;	+ orientation ('N' | 'E')
;;;	+ orientation ('S' | 'W')
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
	push	HELPERS_LOCALE_NAME_PROMPT, STDOUT
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
	push	HELPERS_LOCALE_LATITUDE_PROMPT, STDOUT
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
	push	ERR_INVALID_DATA, STDOUT
	call	io.write
	jc	.error
	jmp	.ask_latitude

.ask_longitude:
	;; Write prompt
	push	HELPERS_LOCALE_LONGITUDE_PROMPT, STDOUT
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
	push	ERR_INVALID_DATA, STDOUT
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

;;;
;;; geo.format_coord
;;;	Format coordinates to print.
;;; args:
;;;	+ pointer to coordinates
;;;	+ output buffer (a least 9 bytes)
;;; ret:
;;;	Pointer to output buffer
;;;
PROC geo.format_coord, 0, 8
	
	%define $coord		[ebp + 8]
	%define $output		[ebp + 12]
	
	%define $buf1	_geo_format_coord_buffer1
	%define $buf2	_geo_format_coord_buffer2
	
	push	edi, esi
	
;; Format degrees
	;setup
	mov	esi, $coord
	add	esi, Coordinate.degrees
	mov	edi, $output
	
	;convert degrees to string
	movzx	eax, byte [esi]
	push	dword $buf1, eax
	call	str.itoa
	jc	.error
	
	;fill $buf2 with spaces
	push	' ', 4, dword $buf2
	call	str.fill
	
	;format
	push	dword $buf1, dword $buf2
	call	str.rjust
	jc	.error
	
	;write output
	push	3, edi, dword $buf2
	call	str.ncopy

;; Format minutes
	;setup
	mov	esi, $coord
	add	esi, Coordinate.minutes
	mov	edi, $output
	add	edi, 3
	
	;convert degrees to string
	movzx	eax, byte [esi]
	push	dword $buf1, eax
	call	str.itoa
	jc	.error
	
	;fill $buf2 with spaces
	push	' ', 4, dword $buf2
	call	str.fill
	
	;format
	push	dword $buf1, dword $buf2
	call	str.rjust
	jc	.error
	
	;write output
	push	3, edi, dword $buf2
	call	str.ncopy

;; Format orientation
	;setup
	mov	esi, $coord
	add	esi, Coordinate.orientation
	mov	edi, $output
	add	edi, 3 + 3
	
	;get orientation
	mov	al, [esi]
	
	;write output
	mov	byte [edi + 0], ' '
	mov	byte [edi + 1], al
	
	clc
.error:
	stc
.exit:
	mov	eax, [ebp + 12]
	pop	esi, edi
	clc
	exit
ENDPROC


;;;
;;; geo.print_locale
;;; 	Print a locale to a file.
;;; args:
;;;     + file descriptor
;;;     + pointer to locale structure
;;; 
PROC geo.print_locale, 0, 8
	
	%define $fp		[ebp + 8]
	%define $locale		[ebp + 12]
	
	%define $buf1		_geo_print_locale_buffer1
	%define $buf2		_geo_print_locale_buffer2
	
	push	ecx, edi, esi
	
;; Print name
	;setup
	mov	esi, $locale
	add	esi, Locale.name
	
	;copy name into $buf1
	push	30, dword $buf1, esi
	call	str.ncopy
	mov	byte [$buf1 + 31], 0	; add \0 at end
	
	;fill $buf2 with spaces
	push	' ', 31, $buf2
	call	str.fill
	
	;format
	push	$buf1, $buf2
	call	str.ljust
	jc	.error
	
	;print
	push	dword $buf2, dword $fp
	call	io.write
	jc	.error

;; Print latitude
	;setup
	mov	esi, $locale
	add	esi, Locale.latitude
	
	;format
	push	dword $buf1, esi
	call	geo.format_coord
	
	;print
	push	dword $buf1, dword $fp
	call	io.write
	jc	.error

;; Print spaces
	;fill $buf1 with spaces
	push	' ', 5, $buf1
	call	str.fill
	
	;print
	push	dword $buf1, dword $fp
	call	io.write
	jc	.error
	
;; Print longitude
	;setup
	mov	esi, $locale
	add	esi, Locale.longitude
	
	push	dword $buf1, esi
	call	geo.format_coord
	
	;print
	push	dword $buf1, dword $fp
	call	io.write
	jc	.error	

	clc
	jmp	.exit

.error:
	stc
.exit:
	pop	esi, edi, ecx
	exit
ENDPROC

;;;
;;; geo.read_locale
;;; 	Read a locale from a file. The file position indicator is set to the
;;;	next locale.
;;; args:
;;;     + file descriptor
;;;	+ output buffer, with 36 bytes
;;; err:
;;;	Set CF if reach end of file or other errors.
;;;
PROC geo.read_locale, 0, 8

	%define $fd	[ebp + 8]
	%define $output [ebp + 12]
	
	push	36, dword $output, dword $fd
	call	sys.read
	jc	.error
	clc
	jmp	.exit
.error:
	stc
.exit:
	exit
ENDPROC

;;;
;;; geo.dmd2rd
;;;	Converts coordinates in degree/minute/direction format to radians
;;;	degrees.
;;; args:
;;;	+ degree
;;;	+ minutes
;;;	+ direction
;;; example:
;;;	36°57'N -> 36.9525
;;;	110°4'W -> -110.0725
;;;
PROC geo.dmd2rd, 12, 12
	
	%define $deg	[ebp + 8]
	%define $min	[ebp + 12]
	%define $dir	[ebp + 16]
	
	%define $n60	[ebp - 4]
	%define $tmp	[ebp - 8]
	%define $n180	[ebp - 12]
	
	mov	dword $n60, 60
	mov	dword $n180, 180
	
	;st0 = deg + min/60;
	fild	dword $min
	fild	dword $n60
	fdiv
	fild	dword $deg
	fadd
	
	; if (dir == 'N' | dir == 'E') do nothing;
	cmp	dword $dir, 'N'
	je	.convert_to_radians
	
	cmp	dword $dir, 'E'
	je	.convert_to_radians
	
	; else st0 = -st0;
	fchs

.convert_to_radians:
	fldpi
	fmul
	fild	dword $n180
	fdiv
	
	;return
	fst	dword $tmp
	mov	eax, $tmp
	exit
ENDPROC

;;;
;;; geo.locale_distance
;;;	Compute the from locale A to B.
;;; args:
;;;	+ latitude of A in radians
;;;	+ longitude of A in radians
;;;	+ latitude of B in radians
;;;	+ longitude of B in radians
;;;	+ sphere radius
;;; ret:
;;;	Returns the distance.
;;;
PROC geo.locale_distance, 16, 8
	
	mov	eax, 42
	exit
	
	%define $latA	[ebp - 4]
	%define $lngA	[ebp - 8]
	%define $latB	[ebp - 12]
	%define $lngB	[ebp - 16]
	
	;convert A latitude to radians
	mov	esi, dword [ebp + 8]
	add	esi, Locale.latitude
	call	.convert_coordinate_to_radian
	mov	$latA, eax
	
	;convert A longitude to radians
	mov	esi, dword [ebp + 8]
	add	esi, Locale.longitude
	call	.convert_coordinate_to_radian
	mov	$lngA, eax
	
	;convert B latitude to radians
	mov	esi, dword [ebp + 12]
	add	esi, Locale.latitude
	call	.convert_coordinate_to_radian
	mov	$latB, eax
	
	;convert B longitude to radians
	mov	esi, dword [ebp + 12]
	add	esi, Locale.longitude
	call	.convert_coordinate_to_radian
	mov	$lngB, eax
	
	;compute distance
	mov	eax, 6371	;earth radius
	push	eax, dword $lngB, dword $latB, dword $lngA, dword $latA
	call	math.great_circle_distance
	
	exit
	
.convert_coordinate_to_radian:
	movzx	eax, byte [esi + Coordinate.degrees]
	movzx	ebx, byte [esi + Coordinate.minutes]
	movzx	ecx, byte [esi + Coordinate.orientation]
	push	ecx, ebx, eax
	call	geo.dmd2rd
	ret
	
ENDPROC


[section .bss]
_coord_buf			resb 255

_geo_print_locale_buffer1	resb 36
_geo_print_locale_buffer2	resb 36

_geo_format_coord_buffer1	resb 5
_geo_format_coord_buffer2	resb 5

%endif
