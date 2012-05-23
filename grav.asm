
;; struc Coordinate
;; 	.degrees:	resb 1
;; 	.minutes:	resb 1
;; 	.orientation:	resb 1
;; endstruc

;; struc Locale
;; 	.name:		resb	30
;; 	.latitude:	resb	3
;; 	.longitude:	resb	3
;; endstruc

%include "macros.i"

extern exit
extern read
extern readln
extern writeln

section .data
	str:	db "hello", 0

section .text
	global _start

_start:
	push	3
	push	str
	push	STDIN
	call	readln
	mov	ebx, eax
	
	push	3
	push	str
	push	STDOUT
	call	writeln
	
	push	ebx
	call	exit
