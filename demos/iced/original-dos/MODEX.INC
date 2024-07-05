;ษออออออออออออออออออออออออออออออออออออออออออออออออป
;บ  Name:Mode_X_(320x240)_Routines_______  V01.00 บ
;บ                                                บ
;บ  Modified:22-Nov-93			       FB บ
;ศออออออออออออออออออออออออออออออออออออออออออออออออผ
;
;  All code assumes that ES points to video segment!
;
;**************************************************
; Vars NOT defined in this INC file
;	WriteOffset:word
;	ClipMinX:word
;	ClipMinY:word
;	ClipMaxX:word
;	ClipMaxY:word
;	ClearColor:byte

;General Regs
MISC_OUTPUT	    equ   03c2h
MISC_OUTPUT_READ    equ   03cch
FCW		    equ   03dah
FCR		    equ   03cah
INPUT_STATUS_0	    equ   03c2h
INPUT_STATUS_1	    equ   03dah

;Sequencer Regs
SC_INDEX	    equ   03c4h
SC_DATA 	    equ   03c5h
MAP_MASK	    equ     02h

;CRTC Regs
CRTC_INDEX	    equ   03d4h
CRTC_DATA	    equ   03d5h

;Graphics Regs
GC_INDEX	    equ   03ceh
GC_DATA 	    equ   03cfh
READ_MAP	    equ     04h

;Attribute Regs
ACW_FF		    equ   03c0h
ACR_FF		    equ   03c1h

;Color Regs
PEL_GET 	    equ   03c7h
PEL_SET 	    equ   03c8h
PEL_DATA	    equ   03c9h

START_ADDRESS_HIGH  equ     0ch   ;bitmap start address high byte
START_ADDRESS_LOW   equ     0dh   ;bitmap start address low byte

tmppal	db 768 DUP (0)	     ;temp palette
DONE	dw 0		     ;temp word

; Sequencer Regs
Sequencer   db 003h,021h,00fh,000h
SeqEnd	    db 006h

; CRTC Regs
CRTC	    db	05fh,04fh,050h,082h,054h,080h,00dh,03eh
	    db	000h,041h,000h,000h,000h,000h,003h,0c0h
	    db	0eah,02ch,0dfh,028h,000h,0e7h,006h,0e3h
CRTCEnd     db	0ffh

; Graphics Regs
Graphics    db	000h,000h,000h,000h,000h,040h,005h,00fh
GraphicsEnd db	0ffh

;Attribute Regs
Attrib	    db	041h,000h,00fh,000h
AttribEnd   db	000h

;--------------------------------------------------------
;
; Scron - Sets ModeX 320x240x256
;    IN     : -
;   OUT     : -
;  Modified : ax,cx,dx,si,di
;  Vars Used: ClearColor
;
Scron		PROC

	mov	dx,INPUT_STATUS_1
Scron1:
	in	al,dx
	test	al,08h
	jz	Scron1	;vertical sync is active high (1 = active)

	;turn screen off
	mov	dx,SC_INDEX
	mov	al,1
	out	dx,al
	inc	dx
	in	al,dx
	or	al,00100000b
	out	dx,al

	mov	cx,5
	mov	dx,ACW_FF
	mov	si,offset AttribEnd
Scron6:
	mov	al,cl
	add	al,2fh
	out	dx,al
	mov	al,cs:[si]
	out	dx,al
	dec	si
	loop	Scron6

	mov	cx,10h		;Bit 5 not set-> allow host access to pal
Scron5:
	mov	al,cl
	dec	al
	out	dx,al
	out	dx,al
	loop	Scron5

	mov	al,30h
	out	dx,al

	mov	dx,SC_INDEX
	mov     ax,0604h
	out	dx,ax		;disable chain4 mode
	mov	ax,0100h
	out	dx,ax		;synchronous reset while setting Misc Output
				; for safety, even though clock unchanged
	;General Regs
	mov	dx,MISC_OUTPUT
	mov	al,0e3h
	out	dx,al

	mov	si,offset SeqEnd
	mov	dx,SC_INDEX
	mov	cx,5
Scron2:
	mov	al,cl
	dec	al
	mov	ah,cs:[si]
	dec	si
	out	dx,ax
	loop	Scron2

	mov	si,offset CRTCEnd
	mov	dx,CRTC_INDEX
	mov	cx,19h
Scron3:
	mov	al,cl
	dec	al
	mov	ah,cs:[si]
	dec	si
	out	dx,ax
	loop	Scron3

	mov	si,offset GraphicsEnd
	mov	dx,GC_INDEX
	mov	cx,9
Scron4:
	mov	al,cl
	dec	al
	mov	ah,cs:[si]
	dec	si
	out	dx,ax
	loop	Scron4

	mov	dx,SC_INDEX
	mov     ax,0f02h
	out	dx,ax		    ;enable writes to all four planes

	sub	di,di		    ;point ES:DI to display memory
	mov	al,[ClearColor]
	mov	ah,al
	mov	cx,8000h	    ;# of words in display memory
	rep	stosw		    ;clear all of display memory

	mov	dx,03c4h	    ;turn screen on again
	mov	ax,0101h
	out	dx,ax

	ret

Scron           ENDP

;--------------------------------------------------------
;
; Scroff  - Leaves ModeX
;    IN     : -
;   OUT     : -
;  Modified : ax,dx
;  Vars Used: -
;

Scroff		PROC

	mov	dx,03c4h
	mov	al,1
	out	dx,al
	inc	dx
	in	al,dx
	or	al,00100000b
	out	dx,al
	mov	dx,INPUT_STATUS_1
WaitVS:
	in	al,dx
	test	al,08h
	jz	WaitVS	;vertical sync is active high (1 = active)

	push	ds
	push	0000
	pop	ds
	;we didn't use int10h to set video mode
	;so we the old mode # is still set in
	;BIOS data area.
	mov	al,ds:[0449h]	    ;get previous mode
	mov	ah,00h
	int	10h
	pop	ds
	ret

Scroff          ENDP

;--------------------------------------------------
;
; ScrClear  - Clears 320x240 Window
;    IN     : -
;   OUT     : -
;  Modified : ax,cx,dx,di
;  Vars Used: WriteOffset,ClearColor
;

ScrClear	PROC

	mov     dx,SC_INDEX
	mov     ax,0f02h
	out	dx,ax		    ;enable writes to all four planes
	mov	di,[WriteOffset]    ;point ES:DI to display memory
	mov	al,[ClearColor]
	mov	ah,al
	mov	cx,2580h	    ;# of words
	cld
	rep     stosw    ;clear all of page

	ret

ScrClear        ENDP

;--------------------------------------------------
; BoxClear  - Clears Window on 4-pixel boundary
;    IN     : cx   (XPos div 4)
;	      dx   (YPos)
;	      ax   (XLen div 4)
;	      bx   (YLen)
;   OUT     : -
;  Modified : ax,bx,cx,dx,di,es
;  Vars Used: WriteOffset,ClearColor
;
;Note: This only clears on 4-pixel boundaries! - but FAST!

BoxClear	PROC


	xor	edi,edi
	mov	di,dx
	shl	di,4			    ;multiply by 16
	lea	edi,[edi+4*edi] 	    ;multiply by 5
	add	di,cx
	add	di,[WriteOffset]	    ;point ES:DI to display memory
	mov	dx,80
	sub	dx,ax
	mov	cx,ax
	cld
	mov	dx,SC_INDEX
	mov     ax,0f02h
	out	dx,ax			    ;enable writes to all four planes

	mov	al,[ClearColor]

boxclear1:
	push	cx
	rep	stosb			    ;clears horizontal line
	pop	cx
	add	di,dx
	dec	bx
	jnz	boxclear1

	ret

BoxClear	ENDP

;--------------------------------------------------
; ClearVGAMem  - Clears VGA Video Memory
;    IN     : -
;   OUT     : -
;  Modified : ax,cx,dx,di,es
;  Vars Used: ClearColor

ClearVGAMem	PROC

	mov     dx,SC_INDEX
	mov     ax,0f02h
	out	dx,ax		    ;enable writes to all four planes
	sub	di,di		    ;point ES:DI to display memory
	mov	al,[ClearColor]
	mov	ah,al
	mov	cx,8000h	    ;# of words in display memory
	cld
	rep	stosw		    ;clear all of display memory

	ret

ClearVGAMem     ENDP

;--------------------------------------------------
; SetDot - Sets Dot/Pixel - with clipping
;    IN     : cx   (XPos)
;	      dx   (YPos)
;	      al   (Color)
;   OUT     : -
;  Modified : bx,cx,dx,es
;  Vars Used: WriteOffset
;

SetDot		PROC

	cmp	dx,[ClipMaxY]
	jae	NoDot
	cmp	dx,[ClipMinY]
	jb	NoDot

	cmp	cx,[ClipMaxX]
	jae	NoDot
	cmp	cx,[ClipMinX]
	jb	NoDot

	push	ax
	xor	eax,eax
	mov	ax,dx
	;multyply by 80
	shl	ax,4		;multiply by 16
	lea	eax,[eax+4*eax] ;multiply by 5

	mov	bx,cx
	shr     bx,2
	add	bx,ax			;offset of pixel in page
	add	bx,[WriteOffset]	;offset of pixel in display memory

	and	cl,011b 		;pixel's plane
	mov	ax,0100h + MAP_MASK	;AL = index in SC of Map Mask reg
	shl	ah,cl	    ;set only the bit for the pixel's plane to 1
	mov     dx,SC_INDEX ;set the Map Mask to enable only the
	out	dx,ax	    ; pixel's plane

	pop	ax
	mov	es:[bx],al  ;draw the pixel in the desired color
NoDot:
	ret
SetDot		ENDP

;--------------------------------------------------
; GetDot - Gets Dot/Pixel
;    IN     : cx   (XPos)
;	      dx   (YPos)
;   OUT     : ax   (Color)
;  Modified : bx,cx,dx,es
;  Vars Used: WriteOffset
;

GetDot	       PROC

	xor	eax,eax
	mov	ax,dx
	shl	ax,4		;multiply by 16
	lea	eax,[eax+4*eax] ;multiply by 5
	mov	bx,cx
	shr	bx,2
	add	bx,ax		     ;offset of pixel in page
	add	bx,[WriteOffset]     ;offset of pixel in display memory

	mov	ah,cl
	and	ah,011b 	     ;AH = pixel's plane
	mov	al,READ_MAP	     ;AL = index in GC of the Read Map reg
	mov	dx,GC_INDEX	     ;set the Read Map to read the pixel's
	out	dx,ax		     ; plane

	mov	al,es:[bx]	     ;read the pixel's color
	sub	ah,ah		     ;convert it to an unsigned int

	ret

GetDot	       ENDP

;--------------------------------------------------
; SetCol - Sets Color Register
;    IN     : al   (ColReg)
;	      ah   (Red)
;	      bl   (Green)
;	      bh   (Blue)
;   OUT     : -
;  Modified : ax,bx,dx
;  Vars Used: -

SetCol	  PROC

	  mov	dx,PEL_SET
	  out   dx,al

	  inc   dx

	  mov	al,ah
	  out   dx,al
	  mov	al,bl
	  out   dx,al
	  mov	al,bh
	  out   dx,al

	  ret

SetCol    ENDP

;--------------------------------------------------
; SetPal - Sets Color Palette
;    IN     : ds:si   (Ptr to Palette)
;	      al   (ColReg - Start)
;	      cx   (Range)
;   OUT     : -
;  Modified : ax,cx,dx,si
;  Vars Used: -
SetPal	    PROC

	mov	dx,PEL_SET
	out	dx,al

	cld
	mov	dx,cx
	shl	cx,1
	add	cx,dx		    ;cx=cx*3

	mov	dx,INPUT_STATUS_1
WaitVS1:
	in	al,dx
	test	al,08h
	jz	WaitVS1 	    ;vertical sync is active high (1 = active)
	mov	dx,PEL_SET+1

palwrite:
	outsb			    ;very fast V-cards don't like rep outsb
	loop palwrite

	ret

SetPal	    ENDP
;--------------------------------------------------
; FadeIn - Fades Current Palette into New Palette
;    IN     : ds:si   (Ptr to (should-be) Palette)
;	      al   (From ColReg)
;	      ah   (Stepsize)
;	      cx   (Range)
;   OUT     : -
;  Modified : ax,bx,cx,dx,si,di,bp
;  Vars Used: tmppal (local cs)
FadeIn	    PROC

	mov	dx,PEL_SET-1	;PEL Read Mode Reg
	out	dx,al		;start reading PEL data from color entry FR_COL

	mov	dx,cx
	shl	cx,1
	add	cx,dx		;cx=cx*3
	mov	dx,PEL_SET+1	;PEL Data Reg

	mov	bp,cx
	mov	di,offset tmppal
	cld

	push	es
	push	cs
	pop	es
fadein5:
	insb			  ;read PEL data
	loop	fadein5
	pop	es

	xor	ecx,ecx
	mov	cl,al
	lea	ecx,[ecx+2*ecx]

	mov	di,offset tmppal
	add	si,cx
	add	di,cx
	xchg	di,si
	mov	cx,bp

fadeagain:
       ;mov	dx,PEL_SET	;PEL Read Mode Reg
       ;out	dx,al		;start reading PEL data from color entry FR_COL

	xor	bp,bp		;number of colregs that actually changed

	push	si
	push	di
	push	cx
fadein1:
	mov	al,byte ptr [di]	  ;should-be-value
	mov	bl,byte ptr cs:[si]
	sub	bl,al		    ;compare with is-value
	je	fadein2 	    ;reached destination value?
	jb	fadein3

	cmp	bl,ah
	jge	fadein7
	mov	byte ptr cs:[si],al
	jmp	short fadein4
fadein7:
	sub	byte ptr cs:[si],ah    ;should-be-value < is-value
	jmp	short fadein4
fadein3:
	neg	bl
	cmp	bl,ah
	jge	fadein8
	mov	byte ptr cs:[si],al
	jmp	short fadein4
fadein8:
	add	byte ptr cs:[si],ah
fadein4:

	inc	bp
fadein2:
	inc	di
	inc	si
	loop	fadein1
	pop	cx
	pop	di
	pop	si
	or	bp,bp		    ;have any colregs changed?
	je	fadedone

	push	cx
	push	si
	mov	dx,INPUT_STATUS_1
WaitVS2:
	in	al,dx
	test	al,08h
	jz	WaitVS2 	    ;vertical sync is active high (1 = active)

	mov	dx,PEL_SET	    ;PEL Read Mode Reg
	mov	al,0
	out	dx,al		    ;start reading PEL data from color entry FR_COL

	mov	dx,PEL_SET+1	    ;PEL Data Reg
fadein6:
	outs	dx,byte ptr cs:[si] ;do the deed
	loop	fadein6

	pop	si
	pop	cx
	jmp	short fadeagain
fadedone:
	ret

FadeIn	    ENDP
;--------------------------------------------------
; SetPage - Sets page to write to
;    IN     : ax   (WriteOffset)
;   OUT     : -
;  Modified : -
;  Vars Used: -

SetPage 	PROC

	mov	[WriteOffset],ax
	ret

SetPage         ENDP

;--------------------------------------------------
; ShowPage - Sets page to show
;    IN     : ax   (DisplayStart)
;   OUT     : -
;  Modified : ax,bx,cx,dx
;  Vars Used: -

;code originally from PC-Mag (?)

ShowPage	PROC

; Wait for display enable to be active (status is active low), to be
; sure both halves of the start address will take in the same frame.
	mov	cx,ax
	mov     bh,cl
	mov     bl,START_ADDRESS_LOW
	mov     cl,START_ADDRESS_HIGH
	mov     dx,INPUT_STATUS_1
WaitDE:
	in	al,dx
	test	al,01h
	jnz	WaitDE	;display enable is active low (0 = active)

; Set the start offset in display memory of the page to display.
	mov     dx,CRTC_INDEX
	mov     ax,bx
	out     dx,ax   ;start address low
	mov     ax,cx
	out     dx,ax   ;start address high

; Now wait for vertical sync, so the other page will be invisible when
; we start drawing to it.

       ;we are synchronized with VR, so we don't need this...

       ;mov	dx,INPUT_STATUS_1
;WaitVS3:
       ;in	al,dx
       ;test	al,08h
       ;jz	WaitVS3 ;vertical sync is active high (1 = active)

       ret
ShowPage       ENDP

;--------------------------------------------------
;**************************************************
