%ifndef __MACROS
%define __MACROS

;;;
;;; Memory layout for store coordinates
;;;
struc Coordinate
	.degrees:	resb 1
	.minutes:	resb 1
	.orientation:	resb 1
endstruc

;;;
;;; Memory layout for store locales
;;;
struc Locale
	.name:		resb	30
	.latitude:	resb	3  ; Coordinate instance
	.longitude:	resb	3  ; ditto
endstruc


;;;
;;; Helper for function definition. Must be terminated with EXIT and ENDPROC.
;;; args:
;;;	+ function name
;;;	+ bytes reserved for local variables
;;;	+ bytes used by function's parameters
;;; usage:
;;;	PROC sum, 4, 8
;;;	    mov eax, [ebp + 8]
;;;	    add	eax, [ebp + 12]
;;;	    exit
;;;	ENDPROC
;;;
%imacro PROC 3
	%define $stack_unwind %3
	%1:
	%push %1
	enter %2, 0
%endmacro

;;;
;;; Terminate a function definition.
;;;
%imacro ENDPROC 0
	%pop
%endmacro

;;;
;;; Analog to C `return`. One function can have multiple exit points.
;;;
%imacro EXIT 0
	leave
	ret $stack_unwind
%endmacro


;;;
;;; Push multiple values at once.
;;; usage:
;;;	push	eax, esi, edi
;;;
%imacro PUSH 1-* 
	%rep %0 
		push %1 
	%rotate	1
	%endrep 
%endmacro

;;;
;;; Pop multiple values at once.
;;; usage:
;;;	pop	edi, esi, eax
;;;
%imacro POP 1-* 
    %rep %0 
        pop	%1 
	%rotate	1
	%endrep 
%endmacro


; Syscall's values.
%define SYS_EXIT	1
%define SYS_READ	3
%define SYS_WRITE	4
%define SYS_OPEN	5
%define SYS_CLOSE	6
%define SYS_CREAT	8
%define SYS_ACCESS	33

; Standart devices.
%define STDIN  0
%define STDOUT 1
%define STDERR 2

; Values for the second argument to access.
; These may be OR'd together.
%define	R_OK	4		; Test for read permission.
%define	W_OK	2		; Test for write permission.
%define	X_OK	1		; Test for execute permission.
%define	F_OK	0		; Test for existence.

; Values for open/fcntl.
%define O_RDONLY	   00
%define O_WRONLY	   01
%define O_RDWR		   02
%define O_CREAT		 0100
%define O_TRUNC		01000
%define O_APPEND	02000

; POSIX masks for st_mode.
%define S_IRWXU		0700 ; owner has read, write and execute permission
%define S_IRUSR		0400 ; owner has read permission
%define S_IWUSR		0200 ; owner has write permission
%define S_IXUSR		0100 ; owner has execute permission
%define S_IRWXG		 070 ; group has read, write and execute permission
%define S_IRGRP		 040 ; group has read permission
%define S_IWGRP		 020 ; group has write permission
%define S_IXGRP		 010 ; group has execute permission
%define S_IRWXO		  07 ; others have read, write and execute permission
%define S_IROTH		  04 ; others have read permission
%define S_IWOTH		  02 ; others have write permission
%define S_IXOTH		  01 ; others have execute permission

%endif
