%ifndef __SYS
%define __SYS


;;;
;;; sys.exit
;;;     Terminate the program.
;;; args:
;;;     + return code
;;;
PROC sys.exit, 0, 4
	mov	ebx, [ebp + 8]
	mov	eax, SYS_EXIT
	int	80h
	exit
ENDPROC

;;;
;;; sys.creat
;;;     Create a file.
;;; args:
;;;     + pathname
;;;     + mode
;;; ret:
;;;     File descriptor or -1.
PROC sys.creat, 0, 8
	push	ebx, ecx
	
	mov	ebx, [ebp +  8]
	mov	ecx, [ebp + 12]
	mov	eax, SYS_CREAT
	int	80h
	
	cmp	eax, -1
	je	.error
	clc
	jmp	.quit
.error:
	stc
.quit:
	pop	ecx, ebx
	exit
ENDPROC

;;;
;;; sys.open
;;;	Open a file.
;;; args:
;;; 	+ filename
;;;	+ flags
;;; ret:
;;;     A new file descriptor or -1 if an error ocurred.
;;; 
PROC sys.open, 0, 8
	push	ebx, ecx

	mov	ebx, [ebp +  8]
	mov	ecx, [ebp + 12]
	mov	eax, SYS_OPEN
	int	80h
	
	cmp	eax, -1
	je	.error
	clc
	jmp	.quit
.error:
	stc
.quit:
	pop	ecx, ebx
	exit
ENDPROC

;;;
;;; sys.close
;;;	Close a file.
;;; args:
;;; 	+ file descriptor
;;; ret:
;;;     0 on success, -1 on error.
;;; 
PROC sys.close, 0, 4
	push	ebx

	mov	ebx, [ebp +  8]
	mov	eax, SYS_CLOSE
	int	80h
	
	cmp	eax, -1
	je	.error
	clc
	jmp	.quit
.error:
	stc
.quit:
	pop	ebx
	exit
ENDPROC

;;;
;;; sys.read
;;; 	Read bytes from file descriptor into a buffer.
;;; args:
;;;     + file descriptor
;;;     + buffer
;;;     + number of bytes to read
;;; ret:
;;;     Number of bytes read. On error, -1 is returned.
;;; 
PROC sys.read, 0, 12
	push	ebx, ecx, edx

	mov	ebx, [ebp + 8]
	mov	ecx, [ebp + 12]
	mov	edx, [ebp + 16]
	mov	eax, SYS_READ
	int	80h
	
	cmp	eax, -1
	je	.error
	clc
	jmp	.quit
.error:
	stc
.quit:
	pop	edx, ecx, ebx
	exit
ENDPROC

;;;
;;; sys.write
;;;	Write bytes from buffer to file descriptor.
;;; args:
;;;     + file descriptor
;;;     + buffer
;;;     + number of bytes to write
;;; ret:
;;;     Number of bytes written. On error, -1 is returned.
;;;
PROC sys.write, 0, 12
	push	ebx, ecx, edx
	
	mov	ebx, [ebp + 8]
	mov	ecx, [ebp + 12]
	mov	edx, [ebp + 16]
	mov	eax, SYS_WRITE
	int	80h
	
	cmp	eax, -1	; some error?
	jl	.error
	clc
	jmp	.quit
.error:
	stc
.quit:
	pop	edx, ecx, ebx
	exit
ENDPROC

;;;
;;; sys.access
;;;	Check user's permissions for a file
;;; args:
;;;     + filename
;;;     + mode
;;; ret:
;;;     0 for success, -1 for error.
;;;
PROC sys.access, 0, 12
	push	ebx, ecx
	
	mov	ebx, [ebp + 8]
	mov	ecx, [ebp + 12]
	mov	eax, SYS_ACCESS
	int	80h
	
	cmp	eax, -1
	jl	.error
	clc
	jmp	.quit
.error:
	stc
.quit:
	pop	ecx, ebx
	exit
ENDPROC

%endif
