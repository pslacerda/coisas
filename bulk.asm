%ifndef __BULK
%define __BULK

%include "io.asm"
%include "sys.asm"
%include "term.asm"

%include "helpers.asm"

[section .text]

;;;
;;; modes.bulk
;;; 	Enter in bulk mode.
;;; args:
;;;	+ input filename
;;;     + origin
;;; 
PROC modes.bulk, 0, 8
	
	;parameters
	%define $infilename	[ebp + 8]
	%define $origin		[ebp + 12]

	push	ebx
	
;;
;;	EBX: Pointer to program header (fancy if STDOUT else plain)
;;	ECX: Input file
;;	EDX: Output file
;;

;; Open input file
	push	O_RDONLY, dword [ebp + 8]
	call	sys.open
	jc	.error
	mov	ecx, eax

;; Determine output file
	print	BULK_OUTPUT_FILE_PROMPT, STDOUT
	
	;ask filename
	push	255, _bulk_buf1, STDIN
	call	io.readln
	jc	.error
	
	;determine
	cmp	eax, 1			; if no filename given
	je	.write_to_STDOUT	; write to STDOUT
	jmp	.write_to_file		; write to file otherwise
	
;; User choose to print results to STDOUT
.write_to_STDOUT:
	;save file descriptor
	mov	edx, STDOUT
	
	;clear screen
	call	term.clear
	jc	.error
	
	;choose fancy header
	mov	ebx, CALC_FANCY_PROGRAM_HEADER
	
	;continue
	jmp	.write_program_header

;; User coose to print results to some file
.write_to_file:
	;create output file
	push	S_IRUSR | S_IWUSR, _bulk_buf1
	call	sys.creat
	jc	.error
	
	;open output file
	push	O_WRONLY, _bulk_buf1
	call	sys.open
	jc	.error
	mov	edx, eax
	
	;choose plain header
	mov	ebx, CALC_PROGRAM_HEADER
	jmp	.write_program_header

;; Write program header
.write_program_header:
	push	ebx, edx
	call	io.write
	jc	.error

;; Print origin
	print	CALC_ORIGIN_HEADER, edx

	;print origin
	push	dword $origin, edx
	call	geo.print_locale
	jc	.error
	
	;print two new lines
	mov	dword [_bulk_buf2], (10 << 8) | 10
	print	_bulk_buf2, edx

;; Print destination header
	print	CALC_DESTINATION_HEADER, edx

;; Read and compute distances
.distances_loop:
	;read locale
	push	_bulk_buf1, ecx
	call	geo.read_locale
	jc	.error
	cmp	eax, 36
	jl	.close_files

	;print locale
	push	_bulk_buf1, edx
	call	geo.print_locale
	jc	.error

	;compute distance
	push	_bulk_buf1, dword $origin
	call	geo.locale_distance
	
	;convert distance to string
	push	_bulk_buf1, eax
	call	str.ftoa
	jc	.error
	
	;format distance
	push	' ', 23, _bulk_buf2
	call	str.fill
	
	push	_bulk_buf1, _bulk_buf2
	call	str.rjust
	jc	.error
	
	push	_bulk_buf2, edx
	call	io.writeln
	
	;loooop!
	jmp	.distances_loop

;; Close files
.close_files:
	;close output file
	push	edx
	call	sys.close
	jc	.error
	
	cmp	ecx, STDOUT
	je	.exit
	
	;close input file
	push	ecx
	call	sys.close
	jc	.error

	clc
	jmp	.exit

.error:
	stc

.exit:
.quit:
	pop	ebx
	exit
ENDPROC

[section .bss]
_bulk_buf1	resb 255
_bulk_buf2	resb 255

%endif

