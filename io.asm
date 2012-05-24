 ;; 
 ;; io.asm
 ;; 
 ;; Copyright (c) 2012 Pedro Lacerda
 ;; 
 ;; Permission is hereby granted, free of charge, to any person obtaining a copy
 ;; of this software and associated documentation files (the "Software"), to deal
 ;; in the Software without restriction, including without limitation the rights
 ;; to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
 ;; copies of the Software, and to permit persons to whom the Software is
 ;; furnished to do so, subject to the following conditions:
 ;; 
 ;; The above copyright notice and this permission notice shall be included in
 ;; all copies or substantial portions of the Software.
 ;; 
 ;; THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
 ;; IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
 ;; FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
 ;; AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
 ;; LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
 ;; OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN
 ;; THE SOFTWARE.

%include "macros.i"

section .data
section .bss
section .text

global creat
global read
global readln
global write
global writeln

extern exit


;;;
;;; int create(pathname, mode)
;;;	Cria um arquivo.
;;;
creat:
	enter	0, 0
	push	eax, ebx, ecx
	
	mov	eax, SYS_CREAT	;
	mov	ebx, [ebp +  8]	; pathname
	mov	ecx, [ebp + 12]	; mode
	int	80h		;

	pop	ecx, ebx, eax
	leave
	ret

;;;
;;; void close(fd)
;;;	Fecha o arquivo `fd`.
;;; 
close:
	enter	0, 0
	push	eax, ebx

	mov	eax, 0x6
	mov	ebx, dword[ebp +  8]
	int	80h

	pop	ebx, eax
	leave
	ret

;;;
;;; void read(fp, buf, count)
;;; 	Lê `count` caracteres do arquivo `fp`.
;;; 
read:
	enter 	0, 0
	push	eax, ebx, ecx, edx

	mov	eax, SYS_READ	;
	mov	ebx, [ebp + 8]	; arquivo para leitura
	mov	ecx, [ebp + 12]	; buffer para salvar
	mov	edx, [ebp + 16]	; número de caracteres a ser lido
	int	80h		;

	pop	edx, ecx, ebx, eax
	leave
	ret

;;;
;;; int readln(fp, buf, count)
;;; 	Lê uma linha terminada por '\n' ou, no máximo, `count` caracteres
;;; 	do arquivo `fp` e os salva em `buf`. Adiciona '\0' ao final da
;;; 	string e retorna a quantidade de caracteres lidos.
;;;
readln:
	enter 	0, 0

	mov	ecx, 1		; contador
	mov	edx, [ebp + 12] ; ponteiro p/ buffer
.loop:
	;; Contador atingiu `count`?
	cmp	ecx, [ebp + 16]
	je	.exit
	
	;; Leia 1 byte.
	push	1		; quantidade de bytes
	push	edx		; endereço do buffer
	push	dword[ebp + 8]	; descritor do arquivo
	call	read		;

	;; Se foi lido '\n' vá embora.
	cmp	byte[edx], 10
	je	.exit

	;; Looooop!
	inc	ecx		; incremente contador
	inc	edx		; incremente apondador do buffer
	jmp	.loop
.exit:
	mov	byte[edx], 0	; adicione '\0' ao final
	mov	eax, ecx
	
	pop	edx, ecx
	leave
	ret

;;;
;;; void write(fd, buf, count)
;;;	Escreve em `fd` `count` caracteres apontados por `buf`.
;;; 
write:
	enter	0, 0
	push	eax, ebx, ecx, edx
	
	mov	eax, SYS_WRITE
	mov	ebx, [ebp + 8]
	mov	ecx, [ebp + 12]
	mov	edx, [ebp + 16]
	int	80h

	pop	edx, ecx, ebx, eax
	leave
	ret


;;;
;;; void writeln(fd, buf, count)
;;;	Escreve em `fd` `count` caracteres apontados por `buf` e
;;; 	insere '\n' ao final.
;;;
writeln:
	enter	4, 0
	push	eax
	
	;; Escreve a string do `buf`.
	push	dword[ebp + 16]
	push	dword[ebp + 12]
	push	dword[ebp + 8]
	call	write

	;; Põe '\n' num buffer local e salva seu endereço.
	mov	dword[ebp - 4], 10
	lea	eax, [ebp - 4]

	;; Escreve '\n'.
	push	1
	push	eax
	push	dword[ebp + 8]
	call	write

	pop	eax
	leave
	ret