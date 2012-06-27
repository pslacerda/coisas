%ifndef __BULK
%define __BULK

[section .text]

;;;
;;; modes.bulk
;;; 	Enter in bulk mode.
;;; args:
;;;     + input filename
;;; ret:
;;;     Nothing
;;; 
PROC modes.bulk, 0, 4
	
	;; Open input file
	push	O_RDONLY, dword [ebp + 8]
	call	sys.open
	jc	.error
	mov	[_bulk_inf], eax
	
	;; Ask output file
	push	255, _bulk_buffer, STDIN
	call	io.readln
	jc	.error
	
	;; Write to STDOUT if no filename given
	mov	dword [_bulk_outf], 1
	cmp	eax, 1
	jmp	.write_header
	
	;; Create output file
	push	S_IRUSR | S_IWUSR, _buffer
	call	sys.creat
	jc	.error
	
	;; Open output file
	push	O_WRONLY, _buffer
	call	sys.open
	jc	.error
	mov	[_bulk_outf], eax
	
.write_header:
	
	stc
.error:
	stc
.quit:
	pop	ecx, edi
	exit
ENDPROC

[section .data]

[section .bss]
_bulk_buffer	resb 255
_bulk_inf	resd 1
_bulk_outf	resd 1

%endif
