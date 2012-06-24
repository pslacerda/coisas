
%include "macros.inc"

%include "sys.asm"
%include "io.asm"

%include "geo.asm"

global _start
[section .text]
_start:
;;; Pedir o nome do arquivo para gravação de coordenadas das localidades
	;; Write prompt
    	push	_prompt1, STDOUT
    	call	io.write
    	jc	error
    	
    	;; Read filename
    	push	255, _filename, STDIN
    	call	io.readln
    	jc	error
    	
    	cmp	eax, 1
    	je	quit
    	
;;; Criar o arquivo de saída com o nome fornecido
	push	S_IRUSR | S_IWUSR, _filename
	call	sys.creat
	jc	error
	mov	[_filehandle], eax

next_locale:
;;; Clean locale variable
	mov	edi, _locale
	mov	ecx, 36
	mov	eax, 0
	rep	stosb

;;; Pedir o nome da localidade
	;; Write prompt
	push	_prompt2, STDOUT
	call	io.write
	jc	error
	
	;; Read locale name
	push	30, _locale + Locale.name, STDIN
	call	io.readln
	jc	error
	
	cmp	eax, 1
	je	quit

;;; Pedir a latitude da localidade em graus, minutos e orientação
ask_latitude:
	;; Write prompt
	push	_prompt3, STDOUT
	call	io.write
	jc	error
	
	;; Read coordiante
	push	'n', 's', 90, _locale + Locale.latitude, STDIN
	call	geo.read_coord
	jc	error
	;; Input error
	jo	latitude_error
	
	;; Continue to longitude
	jmp	ask_longitude
latitude_error:
	push	_err1, STDOUT
	call	io.write
	jc	error
	jmp	ask_latitude

;;; Pedir a longitude da localidade em graus, minutos e orientação
ask_longitude:
	;; Write prompt
	push	_prompt4, STDOUT
	call	io.write
	jc	error
	
	;; Read coordinate
	push	'e', 'w', 180, _locale + Locale.longitude, STDIN
	call	geo.read_coord
	jc	error
	;; Input error
	jo	longitude_error
	
	;; Continue to write file
	jmp	write_file
longitude_error:
	push	_err1, STDOUT
	call	io.write
	jc	error
	jmp	ask_longitude

;;; Gravar um registro com as coordenadas da localidade.
write_file:
	push	36, _locale, dword [_filehandle]
	call	sys.write
	jc	error
	
	;; Ask next locale
	jmp	next_locale

quit:
	mov	ebx, 0
	jmp	terminate
error:
	mov	ebx, 1
	push	_err0, STDERR
	call	io.write
terminate:
	push	dword [_filehandle]
	call	sys.close
	
	push	ebx
	call	sys.exit


[section .data]
_err0		db 10,27,"[1;31mError!",27,"[0m",10,0
_err1		db 27,"[1;31mDados inválidos!",27,"[0m",10, 0
_prompt1	db "Arquivo de coordenadas, ou ENTER para abortar: ", 0
_prompt2	db "Nome da localidade                           : ", 0
_prompt3	db "Latitude <graus, minutos, orientação>        : ", 0
_prompt4	db "Longitude <graus, minutos, orientação>       : ", 0

[section .bss]
_filename	resb 255
_filehandle	resd 1
_locale		resb 36
