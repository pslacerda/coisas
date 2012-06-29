%ifndef __BULK
%define __BULK

%include "io.asm"
%include "sys.asm"

[section .text]

;;;
;;; modes.bulk
;;; 	Enter in bulk mode.
;;; args:
;;;     + input filename
;;; ret:
;;;     Nothing
;;; 
PROC modes.bulk, (255 + 8), 4
	
	%define $inf		[ebp - 4]
	%define $outf		[ebp - 8]
	%define $buf		[ebp - (255 + 8)]
	
	;; Open input file
	push	O_RDONLY, dword [ebp + 8]
	call	sys.open
	jc	.error
	mov	$inf, eax
	
	;; Ask output file
	push	255, dword $buf, STDIN
	call	io.readln
	jc	.error
	
	;; Write to STDOUT if no filename given
	mov	dword $outf, STDOUT
	cmp	eax, 1
	jmp	.write_header
	
	;; Create output file
	push	S_IRUSR | S_IWUSR, dword $buf
	call	sys.creat
	jc	.error
	
	;; Open output file
	push	O_WRONLY, dword $buf
	call	sys.open
	jc	.error
	mov	$outf, eax
	
.write_header:
	
	stc
.error:
	stc
.quit:
	exit
ENDPROC

[section .data]
_bulk_exit	db "Não implementado", 0
_bulk_
%endif
