
[section .text]

;;;
;;; math.great_circle_distance
;;;	Compute the great circle distance from A to B.
;;; args:
;;;	+ latitude of A in radians
;;;	+ longitude of A in radians
;;;	+ latitude of B in radians
;;;	+ longitude of B in radians
;;;	+ radius
;;; ret:
;;;	radius * arccos(sin(A.lat)*sin(B.lat) + cos(A.lat)*cos(B.lat)*cos(Δlng)))
;;;
PROC math.great_circle_distance, 12, 20
	
	%define $latA		[ebp + 8]
	%define $lngA		[ebp + 12]
	%define $latB		[ebp + 16]
	%define $lngB		[ebp + 20]
	%define $radius		[ebp + 24]
	
	%define $sinLatB	[ebp - 4]
	%define $sinLatA	[ebp - 8]
	%define $tmp		[ebp - 12]
	
	
	;st0 := cos(Δlng) = cos(abs(abs(A.lat) - abs(B.lat)))
	fld	dword $lngB
	fabs
	fld	dword $lngA
	fabs
	fsub
	fabs
	fcos
	
	;st0 := cos(A.lat) * cos(B.lat) * st0
	fld	dword $latA
	fcos
	fld	dword $latB
	fcos
	fmul
	fmul
	
	;st0 := sin(A.lat) * sin(B.lat) + st0
	fld	dword $latA
	fsin
	fld	dword $latB
	fsin
	fmul
	fadd
	
	; source: http://216.92.238.133/Webster/AoA/DOS/ch14/CH14-6.html
	; X means st0
	; st0 := acos(st0) = atan(sqrt((1-st0*st0)/(st0*st0)))
	fld     st0	;Duplicate X on tos.
	fmul		;Compute X**2.
	fld	st0	;Duplicate X**2 on tos.
	fld1		;Compute 1-X**2.
	fsubr
	fdivr		;Compute (1-x**2)/X**2.
	fsqrt		;Compute sqrt((1-X**2)/X**2).
	fld1		;To compute full arctangent.
        fpatan		;Compute atan of the above.
        
        fld	dword $tmp
        mov	eax, $tmp
        
	exit	
ENDPROC
