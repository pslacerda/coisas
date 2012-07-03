%ifndef __BULK
%define __BULK

%include "io.asm"
%include "sys.asm"
%include "term.asm"

[section .text]

;;;
;;; modes.bulk
;;; 	Enter in bulk mode.
;;; args:
;;;	+ input filename
;;;     + origin
;;; 
PROC modes.bulk, 8, 8
	
	;parameters
	%define $infilename	[ebp + 8]
	%define $origin		[ebp + 12]

	;variables
	%define $inf		[ebp - 4]
	%define $outf		[ebp - 8]
	%define $buf1		_bulk_buffer1
	%define $buf2		_bulk_buffer2
	
	push	ebx
	
	;open input file
	push	O_RDONLY, dword $infilename
	call	sys.open
	jc	.error
	mov	$inf, eax
	
	;write prompt
	push	_bulk_prompt1, STDOUT
	call	io.write
	jc	.error
	
	;ask output file
	push	255, dword $buf1, STDIN
	call	io.readln
	jc	.error
	
	;write to STDOUT if no filename given
	mov	dword $outf, STDOUT
	cmp	eax, 1
	je	.clear_screen
	
	;create output file
	push	S_IRUSR | S_IWUSR, dword $buf1
	call	sys.creat
	jc	.error
	
	;open output file
	push	O_WRONLY, dword $buf
	call	sys.open
	jc	.error
	mov	$outf, eax
	
	mov	ebx, _bulk_header1
	jmp	.write_origin_header
	
.clear_screen:
	call	term.clear
	jc	.error
	mov	ebx, _header1
	
.write_origin_header:
	push	ebx, dword $outf
	call	io.write
	jc	.error
	
	push	_bulk_header2, dword $outf
	call	io.write
	jc	.error

;; Print origin
	;print
	push	dword $origin, dword $outf
	call	geo.print_locale
	jc	.error
	
	;print two new lines
	mov	dword [$buf1], 10
	push	dword $buf1, dword $outf
	call	io.writeln

;; Print destines header
	push	_bulk_header3, dword $outf
	call	io.write
	jc	.error

;; Read and compute distances
.distances_loop:
	;read locale
	push	dword $buf1, dword $inf
	call	geo.read_locale
	jc	.error
	cmp	eax, 36
	jl	.end_of_locales
	
	;compute distance
	push	dword $buf1, dword $origin
	call	geo.compute_distance
	mov	ebx, eax
	
	;print locale
	push	dword $buf1, dword $outf
	call	geo.print_locale
	jc	.error
	
	;convert distance to string
	push	dword $buf1, ebx
	call	str.itoa
	jc	.error
	
	;format distance
	push	' ', 18, dword $buf2
	call	str.fill
	
	push	dword $buf1, dword $buf2
	call	str.rjust
	jc	.error
	
	push	dword $buf2, dword $outf
	call	io.writeln
	
	;loooop!
	jmp	.distances_loop
	
.end_of_locales:
	clc
	jmp	.quit
.error:
	stc
.quit:
	pop	ebx
	exit
ENDPROC

[section .bss]
_bulk_buffer1	resb 255
_bulk_buffer2	resb 255

[section .data]
_bulk_header1	db "Universidade Federal da Bahia",10
		db "MATA49 Programação de Software Básico",10,10
		db "Cálculo de distâncias geodésicas",10,10,0
_bulk_header2	db "Origem                        Latitude   Longitude",10,0
_bulk_header3	db "Destino                       Latitude   Longitude   Distância (km)",10,0
_bulk_prompt1	db "Arquivo para salvar relatório (↵ STDOUT): ",0

%endif

