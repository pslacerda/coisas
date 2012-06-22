
%include "macros.inc"
%include "io.asm"
%include "str.asm"
%include "sys.asm"

[section .bss]
_coord_buf	resb 255


[section .text]

;;;
;;; geo.read_coord
;;; 	Parse a line into a Coordinate structure.
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
PROC geo.read_coord, 0, 24
	%define $fp		[ebp + 8]
	%define $locale		[ebp + 12]
	%define $max_deg	[ebp + 16]
	%define $coord1		[ebp + 20]
	%define $coord2		[ebp + 24]
	
	push	esi, edi
	
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
	pop	edi, esi
	exit
ENDPROC
