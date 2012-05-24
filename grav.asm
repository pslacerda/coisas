
struc Coordinate
	.degrees:	resb 1
	.minutes:	resb 1
	.orientation:	resb 1
endstruc

struc Locale
	.name:		resb	30
	.latitude:	resb	3
	.longitude:	resb	3
endstruc

%include "macros.i"

extern exit
extern creat
extern read
extern readln
extern write
extern writeln

section .bss
	
section .data
	filename	times 254 db ' '
	filenamelen	dw 0
	
	msg1		db "Arquivo de coordenadas ou <ENTER> para abandonar	: "
	msg1len		dw $-msg1

section .text
	global _start

_start:
;;;
;;;	Pede o nome do arquivo para gravação de coordenadas das localidades.
;;; 
	;; Escreve a deixa.
	push	dword[msg1len], msg1, STDOUT
	call	write

	;; Lê o nome do arquivo.
	push	dword[filenamelen], filename, STDIN
	call	readln
	
	;; Salva a quantidade de caracteres que o nome do arquivo ocupa.
	mov	dword[filenamelen], eax

	;; Usuário digitou apenas <ENTER>. Saia.
	cmp	eax, 0
	je	quit

;;;
;;; Criar o arquivo de saída com o nome fornecido
;;;
	push	S_IRUSR | S_IWUSR, filename
	call	creat
	
;;;
;;; Pede o nome da localidade.
;;;
	
	
;;;
;;; Sai do programa.
quit:
	push	0
	call	exit