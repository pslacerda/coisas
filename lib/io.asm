%ifndef __IO
%define __IO

%include "macros.inc"

%include "str.asm"
%include "sys.asm"


[section .text]

;;;
;;; io.read
;;; 	Read a string from file descriptor into a buffer.
;;; args:
;;;     + file descriptor
;;;     + buffer
;;;     + max number of chars to read
;;; ret:
;;;     Length of readen string. On error, -1 is returned.
;;; 

PROC io.read, 0, 12
	%define $fp	[ebp + 8]
	%define $buf	[ebp + 12]
	%define $count	[ebp + 16]
	
	push	ebx
	
	mov	eax, $count
	dec	eax
	mov	ebx, $buf
	mov	byte [ebx + eax], 0
	
	push	eax, dword $buf, dword $fp
	call	sys.read
	jc	.error
	
	clc
	jmp	.quit
.error:
	stc
.quit:
	pop	ebx
	exit
ENDPROC

;;;
;;; sys.readln
;;; 	Read a line from file descriptor into a buffer.
;;; args:
;;;     + file descriptor
;;;     + buffer
;;;     + max number of chars to read
;;; ret:
;;;     Length of string. On error, -1 is returned.
;;; 
PROC io.readln, 0, 12
	push	ebx, ecx, edx
	
	mov	ecx, 1		; contador
	mov	edx, [ebp + 12] ; ponteiro p/ buffer
.loop:
	;; Contador atingiu `count`?
	cmp	ecx, [ebp + 16]
	je	.exit
	
	;; Leia 1 byte.
	push	1		; quantidade de bytes
	push	edx		; endereço do buffer
	push	dword [ebp + 8]	; descritor do arquivo
	call	sys.read		;
	jc	.error

	;; Se foi lido '\n' vá embora.
	cmp	byte [edx], 10
	je	.exit

	;; Looooop!
	inc	ecx		; incremente contador
	inc	edx		; incremente apondador do buffer
	jmp	.loop
.error:
	pop	edx, ecx, ebx
	stc	
	exit
.exit:
	mov	byte [edx], 0	; adicione '\0' ao final
	mov	eax, ecx
	
	pop	edx, ecx, ebx
	clc
	exit
ENDPROC

;;;
;;; sys.write
;;;	Write a NULL terminated string to file descriptor.
;;; args:
;;;     + file descriptor
;;;     + string
;;; ret:
;;;     Number of bytes written. On error, -1 is returned.
;;;
PROC io.write, 0, 8
	
	push	dword [ebp + 12]
	call	str.len
	
	push	eax
	push	dword [ebp + 12]
	push	dword [ebp + 8]
	call	sys.write
	
	cmp	eax, -1
	je	.error
	clc
	jmp	.quit
.error:
	stc
.quit:
	exit
ENDPROC

;;;
;;; sys.writeln
;;;	Write a NULL terminated string to file descriptor and breaks a line.
;;; args:
;;;     + file descriptor
;;;     + string
;;; ret:
;;;     Number of bytes written. On error, -1 is returned.
;;;
PROC io.writeln, 1, 8
	%define $fd	[ebp + 8]
	%define $str	[ebp + 12]
	%define $nl	[ebp - 1]
	
	push	ebx
	mov	ebx, 0	; bytes written
	
	;; Write string
	push	dword $str, dword $fd
	call	io.write
	cmp	eax, -1
	je	.error
	add	ebx, eax
	
	;; Store '\n' into memory
	mov	byte $nl, 10
	lea	eax, $nl
	
	;; Write '\n'
	push	1, eax, dword $fd
	call	sys.write
	cmp	eax, -1
	je	.error
	add	ebx, eax
	
	;; Return bytes written
	mov	eax, ebx
	stc
	jmp	.quit
.error:
	stc
.quit:
	pop	ebx
	exit
ENDPROC

%endif
