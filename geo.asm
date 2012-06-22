
%include "macros.inc"
%include "sys.asm"

[section .bss]
_coord_buf	resb 255


[section .text]
PROC geo.read_coordinate, 0, 16
	
	%define $fp		[ebp + 8]
	%define $locale		[ebp + 12]
	%define $max_deg	[ebp + 16]
	
	mov	esi, _coord_buf
	mov	edi, $locale
	
	;; Read line into buffer
	push	255, esi, dword $fp
	call	io.readln
	jc	.error
	
	;; Parse degrees
	push	esi
	call	str.atoi
	jc	.error

	dec	edx
	add	esi, edx
	
	;; Validade degrees
	cmp	eax, $max_deg
	jg	.error
	mov	[edi + Coordinate.degrees], al
	
;	push	dword $max_deg
;	call	sys.exit
;	
;	;; Parse minutes
;	push	esi
;	call	str.atoi
;	jc	.error
;	add	esi, edx
;	
;	;; Validade minutes
;	cmp	eax, 59
;	jg	.error
;	mov	[edi + Coordinate.minutes], al
.error:
	push	-1
	call	sys.exit
	stc
.quit:
	exit
ENDPROC
