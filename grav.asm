
%include "macros.inc"

%include "str.asm"
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
;	push	S_IRUSR | S_IWUSR, _filename
;	call	sys.creat
;	jc	error

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
	;; Write prompt
	push	_prompt3, STDOUT
	call	io.write
	jc	error
	
	push	90, _locale + Locale.latitude, STDIN
	call	geo.read_coordinate
	
quit:
	push	eax
	call	sys.exit

error:
;	push	STDERR, _err
;	call	io.write
;	
;	push	STDERR, eax
;	call	io.writeln
	
	push	_err
	call	io.write
	
	push	1
	call	sys.exit


[section .data]
_err		db 10,27,"[1;31mError!",27,"[0m",10,0
_prompt1	db "Arquivo de coordenadas, ou ENTER para abortar: ", 0
_prompt2	db "Nome da localidade                           : ", 0
_prompt3	db "Latitude <graus, minutos, orientação>        : ", 0
_prompt4	db "Coordenadas <graus, minutos, orientação>     : ", 0
_test		db "  	abc", 0

[section .bss]
_filename	resb 255
_filehandle	resd 1
_locale		resb 36
