
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
	
	finit
	
	
	;ST0 := cos(abs(B.lng - A.lng))
	fld	dword $lngB
	fld	dword $lngA
	fsubp
	fabs
	fcos
	
	;ST0 := ST0 * cos(B.lat)
	fld	dword $latB
	fcos
	fmulp
	
	;ST0 := ST0 * cos(A.lat)
	fld	dword $latA
	fcos
	fmulp
	
	;ST0 := ST0 + sin(A.lat) * sin(B.lat)
	fld	dword $latB
	fsin
	fld	dword $latA
	fsin
	fmulp
	faddp
	
	;ST0 := acos(ST0)
	fld	st0
	fmul	st0, st0
	fld1
	fsubr
	fsqrt
	fxch
	fpatan
	
	;ST0 := ST0 * radius
	fld	dword $radius
	fmulp
	
.bla:
        fst	dword $tmp
        mov	eax, $tmp
	exit	
ENDPROC
