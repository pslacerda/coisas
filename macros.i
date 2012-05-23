%ifndef MACROS
%define MACROS



%define SYS_READ 3
%define SYS_WRITE 4

%define STDIN 0
%define STDOUT 1


%define param(n) dword[ebp + 4 + 4*n]
%define var(n)   dword[ebp - 4*n]



%macro	begin 1
	enter 4*%1, 0
%endmacro


%macro end 0
	leave
	ret
%endmacro


%macro  push 1-* 
  %rep  %0 
        push    %1 
  %rotate 1 
  %endrep 
%endmacro


%macro  pop 1-* 
  %rep %0 
  %rotate 1 
        pop     %1 
  %endrep 
%endmacro


%endif
