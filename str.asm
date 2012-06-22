%ifndef __STR
%define __STR

%include "macros.inc"


;;;
;;; str.len
;;; 	Calculate the length of a NULL terminated string.
;;; args:
;;;     - string pointer
;;; ret:
;;;     string length
;;;
PROC str.len, 0, 4
	push	esi
	
	mov	esi, [ebp + 8]
	mov	eax, 0
.loop:
	cmp	byte [esi + eax], 0
	je	.quit
	inc	eax
	jmp	.loop
	
.quit:
	inc	eax
	pop	esi
	exit
ENDPROC

;;;
;;; str.skip_spaces
;;; 	Skips blank chars.
;;; args:
;;;     - string pointer
;;; ret:
;;;     A pointer to the end of blanks.
;;;
PROC str.skip_spaces, 0, 4
	mov	eax, [ebp + 8]
	jmp	.skip
.next:
	inc	eax
.skip:
	cmp	byte [eax], 0
	je	.error
	
	cmp	byte [eax], 9
	je	.next
	cmp	byte [eax], 10
	je	.next
	cmp	byte [eax], 13
	je	.next
	cmp	byte [eax], ' '
	je	.next
	
	jmp	.quit
.error:
	stc
.quit:
	clc
	exit
ENDPROC

;;;
;;; str.atoi
;;;	Parse an ASCII terminated string and returns an integer.
;;; args:
;;;	+ string
;;; ret:
;;;	Parsed number in EAX, and number of readen chars on EDX.
;;;
PROC str.atoi, 0, 4
	push	esi, ebx, ecx
	
	push	dword [ebp + 8]
	call	str.skip_spaces
	
	mov	esi, eax	;string pointer
	mov	ecx, 0		;counter
	mov	eax, 0		;acumulator
	
	;save counter
	mov	edx, ecx

.translate:
	;stop conditions
	cmp	byte [esi + ecx], '0'
	jl	.done
	cmp	byte [esi + ecx], '9'
	jg	.done
	
	;EAX *= 10, make place for the next digit
	mov	ebx, 10
	mul	ebx
	
	;any numeric char subtracted by '0' is its value
	mov	bl, byte [esi + ecx]
	sub	bl, '0'
	
	;EAX += EBX, append digit to acumulator
	add	eax, ebx
	
	;loooop!
	inc	ecx
	jmp	.translate

.done:
	;no numeric char was read
	cmp	edx, ecx
	je	.error
	
	;no errors happened
	clc
	
	;neturn how many chars was read
	mov	edx, ecx
	jmp	.exit
.error:
	stc
.exit:
	pop	ecx, ebx, esi
	exit
ENDPROC
%endif
