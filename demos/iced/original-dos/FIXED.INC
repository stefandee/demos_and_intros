;ษออออออออออออออออออออออออออออออออออออออออออออออออป
;บ  Name:Fixed_Point_Routines____________  V01.00 บ
;บ                                                บ
;บ  Modified:15-Nov-93                         FB บ
;ศออออออออออออออออออออออออออออออออออออออออออออออออผ
;

;**************************************************

INCLUDE TRIGTABL.DAT

;--------------------------------------------------
; FixedMul - Fixed Point Multiplication and rounding
;    IN     : - eax
;               edx
;   OUT     : - eax
;  Modified : eax,edx
;  Vars Used: -

FixedMul        PROC

	imul    edx
	add     eax,8000h
	adc     edx,0
	shrd    eax,edx,16
	ret


FixedMul        ENDP
;--------------------------------------------------
; FixedDiv - Fixed Point Division (No Rounding!)
;    IN     : - edx     (edx div ebx)
;               ebx
;   OUT     : - eax
;  Modified : eax,ebx,edx

FixedDiv        PROC

       ;mov     edx,A
	xor     eax,eax
	shrd    eax,edx,16
	sar     edx,16
	idiv    ebx
	ret

FixedDiv        ENDP
;--------------------------------------------------
; Sin - Fixed Point Sine (lookup - circle=1024 steps)
;    IN     : bx  (deg 0..1023)
;   OUT     : eax
;  Modified : bx dx
Sin            PROC

       ;mov     bx,DEG          ;0-> 1, 256-> 0, 512-> -1, 768-> 0
	add     bx,768          ;convert sin to cos
	xor     dx,dx
	and     bx,1023         ;Maxdegree
	shl     bx,1
	mov     ax,cs:trigtable[bx]
	cmp     bx,256*2          ;is it negative
	jbe     fcosi2
	cmp     bx,768*2
	jae     fcosi2
	dec     dx
fcosi2:
	shl     eax,16
	shrd    eax,edx,16
	ret

Sin            ENDP
;--------------------------------------------------
; Cos - Fixed Point Cosine (lookup - circle=1024 steps)
;    IN     : bx  (deg 0..1023)
;   OUT     : eax
;  Modified : bx dx
Cos            PROC

       ;mov     bx,DEG          ;0-> 1, 256-> 0, 512-> -1, 768-> 0
	xor     dx,dx
	and     bx,1023         ;Maxdegree
	shl     bx,1
	mov     ax,cs:trigtable[bx]
	cmp     bx,256*2          ;is it negative
	jbe     fcosi
	cmp     bx,768*2
	jae     fcosi
	dec     dx
fcosi:
	shl     eax,16
	shrd    eax,edx,16
	ret

Cos            ENDP
;--------------------------------------------------
; SqrtLP - Fixed Point Square Root (Low Precision)
;    IN     : ecx
;   OUT     : eax
;  Modified : ebx,ecx,edx

SqrtLP           PROC
;NOTE:
;this function only gives a 8.8 precision !!!!!!!!!!!!!

	xor     eax,eax

	mov     ebx,40000000h
sqrtLP1:
	mov     edx,ecx         ;edx = val
	sub     edx,ebx         ;val - bitsqr
	jl      sqrtLP2
	sub     edx,eax         ;val - root
	jl      sqrtLP2
	mov     ecx,edx         ;val >= (root+bitsqr) -> accept subs
	shr     eax,1           ;root >> 1
	or      eax,ebx         ;root | bitsqr
	shr     ebx,2           ;bitsqr>>2
	jnz     sqrtLP1
	shl     eax,8
	ret
sqrtLP2:
	shr     eax,1           ;val < (root+bitsqr) -> dont change val
	shr     ebx,2           ;bitsqr>>2
	jnz     sqrtLP1
	shl     eax,8
	ret

SqrtLP           ENDP
;--------------------------------------------------
; Sqrt - Fixed Point Square Root (High/Normal Precision)
;    IN     : ecx
;   OUT     : eax
;  Modified : ebx,ecx,edx
Sqrt         PROC

;This is the High Precision version for the sqrt.
;It gives the optimal 8.16 precision but takes
;a little longer (24 iterations, 48 bits intead of
;16 iterations and 32 bits)

	xor     eax,eax         ;eax is root
	mov     ebx,40000000h
sqrt1:
	mov     edx,ecx         ;edx = val
	sub     edx,ebx         ;val - bitsqr
	jb      sqrt2
	sub     edx,eax         ;val - root
	jb      sqrt2
	mov     ecx,edx         ;val >= (root+bitsqr) -> accept subs
	shr     eax,1           ;root >> 1
	or      eax,ebx         ;root | bitsqr
	shr     ebx,2           ;bitsqr>>2
	jnz     sqrt1
	jz      sqrt5
sqrt2:
	shr     eax,1           ;val < (root+bitsqr) -> dont change val
	shr     ebx,2           ;bitsqr>>2
	jnz     sqrt1
; we now have the 8.8 precision

sqrt5:
	mov     ebx,00004000h
	shl     eax,16
	shl     ecx,16
sqrt3:
	mov     edx,ecx         ;edx = val
	sub     edx,ebx         ;val - bitsqr
	jb      sqrt4
	sub     edx,eax         ;val - root
	jb      sqrt4
	mov     ecx,edx         ;val >= (root+bitsqr) -> accept subs
	shr     eax,1           ;root >> 1
	or      eax,ebx         ;root | bitsqr
	shr     ebx,2           ;bitsqr>>2
	jnz     sqrt3
	ret
sqrt4:
	shr     eax,1           ;val < (root+bitsqr) -> dont change val
	shr     ebx,2           ;bitsqr>>2
	jnz     sqrt3
	ret

Sqrt           ENDP
;--------------------------------------------------
; RotateX - Fixed Point X-Axis-rotation
;    IN     : gs:si     (ptr to x,y,z fixed point coords)
;             Xsin      ( sine )
;             Xcos      ( cosine )
;   OUT     :
;             ebx       (y)
;             ecx       (z)
;  Modified : eax,edx,ebp
RotateX         PROC

	mov     eax,gs:[si+4]       ;get y value
	imul    Xcos                ; y*cos
	add     eax,8000h
	adc     edx,0
	shrd    eax,edx,16
	mov     ebp,eax

	mov     eax,gs:[si+8]       ;get z value
	imul    Xsin                ; z*sin
	add     eax,8000h
	adc     edx,0
	shrd    eax,edx,16
	sub     ebp,eax             ; y*cos-z*sin

	mov     eax,gs:[si+4]       ;get y value
	imul    Xsin                ; y*sin
	add     eax,8000h
	adc     edx,0
	shrd    eax,edx,16
	mov     ebx,ebp             ;set up return register (y)
	mov     ebp,eax

	mov     eax,gs:[si+8]       ;get z value
	imul    Xcos                ; z*cos
	add     eax,8000h
	adc     edx,0
	shrd    eax,edx,16
	add     ebp,eax             ; y*sin+z*cos
	mov     ecx,ebp             ;set up return register (z)

	ret

RotateX         ENDP
;--------------------------------------------------
; RotateY - Fixed Point Y-Axis-rotation
;    IN     : gs:si     (ptr to x,y,z fixed point coords)
;             Ysin      ( sine )
;             Ycos      ( cosine )
;   OUT     :
;             ebx       (x)
;             ecx       (z)
;  Modified : eax,edx,ebp
RotateY         PROC

	mov     eax,gs:[si]         ;get x value
	imul    Ycos                ; x*cos
	add     eax,8000h
	adc     edx,0
	shrd    eax,edx,16
	mov     ebp,eax

	mov     eax,gs:[si+8]       ;get z value
	imul    Ysin                ; z*sin
	add     eax,8000h
	adc     edx,0
	shrd    eax,edx,16
	sub     ebp,eax             ; x*cos-z*sin

	mov     eax,gs:[si+8]       ;get z value
	imul    Ycos                ; z*cos
	add     eax,8000h
	adc     edx,0
	shrd    eax,edx,16
	mov     ebx,ebp             ;set up return register (x)
	mov     ebp,eax             ; z*cos

	mov     eax,gs:[si]         ;get x value
	imul    Ysin                ; x*sin
	add     eax,8000h
	adc     edx,0
	shrd    eax,edx,16
	add     ebp,eax             ; z*cos+x*sin
	mov     ecx,ebp             ;set up return register (z)

	ret

RotateY         ENDP
;--------------------------------------------------
; RotateZ - Fixed Point Z-Axis-rotation
;    IN     : gs:si     (ptr to x,y,z fixed point coords)
;             Zsin      ( sine )
;             Zcos      ( cosine )
;   OUT     :
;             ebx       (x)
;             ecx       (y)
;  Modified : eax,edx,ebp
RotateZ         PROC

	mov     eax,gs:[si]         ;get x value
	imul    Zcos                ; x*cos
	add     eax,8000h
	adc     edx,0
	shrd    eax,edx,16
	mov     ebp,eax

	mov     eax,gs:[si+4]       ;get y value
	imul    Zsin                ; y*sin
	add     eax,8000h
	adc     edx,0
	shrd    eax,edx,16
	sub     ebp,eax             ; x*cos-y*sin

	mov     eax,gs:[si]         ;get x value
	imul    Zsin                ; x*sin
	add     eax,8000h
	adc     edx,0
	shrd    eax,edx,16
	mov     ebx,ebp             ;set up return register (x)
	mov     ebp,eax

	mov     eax,gs:[si+4]       ;get y value
	imul    Zcos                ; y*cos
	add     eax,8000h
	adc     edx,0
	shrd    eax,edx,16
	add     ebp,eax             ; x*sin+y*cos
	mov     ecx,ebp             ;set up return register (y)

	ret

RotateZ         ENDP
;--------------------------------------------------
; Three2TwoD - Fixed Point (x,y,z) to (x,y)
;    IN     : gs:si     (ptr to x,y,z fixed point coords)
;             ebx       (z) value  (usually gs:[si+8])
;   OUT     :
;             ecx       (x)
;             edx       (y)
;  Modified : eax
Three2TwoD      PROC

	mov     edx,gs:[si+4]           ;get y-value
	shl     edx,7                   ;zoom factor = 128

	xor     eax,eax
	shrd    eax,edx,16
	sar     edx,16
	idiv    ebx
	mov     ecx,eax

	mov     edx,gs:[si]             ;get x-value
	shl     edx,7                   ;zoom factor = 128

	xor     eax,eax
	shrd    eax,edx,16
	sar     edx,16
	idiv    ebx
	mov     edx,ecx
	mov     ecx,eax

	ret

Three2TwoD      ENDP
;--------------------------------------------------
;**************************************************
