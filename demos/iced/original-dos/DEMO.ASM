	ifndef	??version
?debug	macro
	endm
publicdll macro	name
	public	name
	endm
$comm	macro	name,dist,size,count
	comm	dist name:BYTE:count*size
	endm
	else
$comm	macro	name,dist,size,count
	comm	dist name[size]:BYTE:count
	endm
	endif
	?debug	V 300h
	?debug	S "demo.c"
	?debug	C E9F9BC49220664656D6F2E63
	?debug	C E94019CA181A433A5C42494E5C42435C494E434C5544455C6D616C+
	?debug	C 6C6F632E68
	?debug	C E94019CA1819433A5C42494E5C42435C494E434C5544455C616C6C+
	?debug	C 6F632E68
	?debug	C E94019CA1819433A5C42494E5C42435C494E434C5544455C5F6465+
	?debug	C 66732E68
	?debug	C E94019CA1819433A5C42494E5C42435C494E434C5544455C5F6E75+
	?debug	C 6C6C2E68
	?debug	C E94019CA1819433A5C42494E5C42435C494E434C5544455C636F6E+
	?debug	C 696F2E68
	?debug	C E94019CA1817433A5C42494E5C42435C494E434C5544455C646F73+
	?debug	C 2E68
_TEXT	segment byte public 'CODE'
_TEXT	ends
DGROUP	group	_DATA,_BSS
	assume	cs:_TEXT,ds:DGROUP
_DATA	segment word public 'DATA'
d@	label	byte
d@w	label	word
_DATA	ends
_BSS	segment word public 'BSS'
b@	label	byte
b@w	label	word
_BSS	ends
_DATA	segment word public 'DATA'
_fractwidth	label	word
	db	159
	db	0
_fractheight	label	word
	db	99
	db	0
_maxiter	label	word
	db	255
	db	0
_SEQU_ADDR	label	word
	db	196
	db	3
_CRTC_ADDR	label	word
	db	212
	db	3
_VGA	label	word
	db	0
	db	160
_DATA	ends
_TEXT	segment byte public 'CODE'
   ;	
   ;	void setvisiblestart(int offset)
   ;	
	assume	cs:_TEXT
_setvisiblestart	proc	near
	push	bp
	mov	bp,sp
   ;	
   ;	 {
   ;		vistart = offset;
   ;	
	mov	ax,word ptr [bp+4]
	mov	word ptr DGROUP:_vistart,ax
   ;	
   ;		asm{
   ;		 mov dx, CRTC_ADDR
   ;	
	mov	 dx, DGROUP:_CRTC_ADDR
   ;	
   ;		 mov ax, 0ch
   ;	
	mov	 ax, 0ch
   ;	
   ;		 out dx, ax
   ;	
	out	 dx, ax
   ;	
   ;		 inc dx
   ;	
	inc	 dx
   ;	
   ;		 mov ax, vistart
   ;	
	mov	 ax, DGROUP:_vistart
   ;	
   ;		 shr ax, 8
   ;	
	shr	 ax, 8
   ;	
   ;		 out dx, ax
   ;	
	out	 dx, ax
   ;	
   ;		 mov ax, 0dh
   ;	
	mov	 ax, 0dh
   ;	
   ;		 dec dx
   ;	
	dec	 dx
   ;	
   ;		 out dx, ax
   ;	
	out	 dx, ax
   ;	
   ;		 inc dx
   ;	
	inc	 dx
   ;	
   ;		 mov ax, vistart
   ;	
	mov	 ax, DGROUP:_vistart
   ;	
   ;		 and ax, 0ffh
   ;	
	and	 ax, 0ffh
   ;	
   ;		}
   ;	 }
   ;	
	pop	bp
	ret	
_setvisiblestart	endp
   ;	
   ;	void setactivestart(int offset)
   ;	
	assume	cs:_TEXT
_setactivestart	proc	near
	push	bp
	mov	bp,sp
   ;	
   ;	 {
   ;		actstart = offset;
   ;	
	mov	ax,word ptr [bp+4]
	mov	word ptr DGROUP:_actstart,ax
   ;	
   ;	 }
   ;	
	pop	bp
	ret	
_setactivestart	endp
   ;	
   ;	void setactivepage(int page)
   ;	
	assume	cs:_TEXT
_setactivepage	proc	near
	push	bp
	mov	bp,sp
   ;	
   ;	 {
   ;		setactivestart(page * widthbytes * height);
   ;	
	mov	ax,word ptr [bp+4]
	imul	word ptr DGROUP:_widthbytes
	imul	word ptr DGROUP:_height
	push	ax
	call	near ptr _setactivestart
	pop	cx
   ;	
   ;	 }
   ;	
	pop	bp
	ret	
_setactivepage	endp
   ;	
   ;	void setvisiblepage(int page)
   ;	
	assume	cs:_TEXT
_setvisiblepage	proc	near
	push	bp
	mov	bp,sp
   ;	
   ;	 {
   ;		setvisiblestart(page * widthbytes * height);
   ;	
	mov	ax,word ptr [bp+4]
	imul	word ptr DGROUP:_widthbytes
	imul	word ptr DGROUP:_height
	push	ax
	call	near ptr _setvisiblestart
	pop	cx
   ;	
   ;	 }
   ;	
	pop	bp
	ret	
_setvisiblepage	endp
   ;	
   ;	void putpixel_x(int x,int y,unsigned char color)
   ;	
	assume	cs:_TEXT
_putpixel_x	proc	near
	push	bp
	mov	bp,sp
	sub	sp,2
	push	di
   ;	
   ;	 {
   ;		unsigned char dummy;
   ;		dummy = 0x01 << (x & 3);
   ;	
	mov	cl,byte ptr [bp+4]
	and	cl,3
	mov	al,1
	shl	al,cl
	mov	byte ptr [bp-1],al
   ;	
   ;		asm{
   ;		 mov dx, SEQU_ADDR
   ;	
	mov	 dx, DGROUP:_SEQU_ADDR
   ;	
   ;		 mov al, 02h
   ;	
	mov	 al, 02h
   ;	
   ;		 out dx, al
   ;	
	out	 dx, al
   ;	
   ;		 inc dx
   ;	
	inc	 dx
   ;	
   ;		 mov al, dummy
   ;	
	mov	 al, [bp-1]
   ;	
   ;		 out dx, al
   ;	
	out	 dx, al
   ;	
   ;		 mov dx, VGA
   ;	
	mov	 dx, DGROUP:_VGA
   ;	
   ;		 mov es, dx
   ;	
	mov	 es, dx
   ;	
   ;		 mov bx, [x]
   ;	
	mov	 bx, [[bp+4]]
   ;	
   ;		 shr bx, 2
   ;	
	shr	 bx, 2
   ;	
   ;		 mov di, [y]
   ;	
	mov	 di, [[bp+6]]
   ;	
   ;		 mov ax, di
   ;	
	mov	 ax, di
   ;	
   ;		 shl di, 6
   ;	
	shl	 di, 6
   ;	
   ;		 shl ax, 4
   ;	
	shl	 ax, 4
   ;	
   ;		 add di,ax
   ;	
	add	 di,ax
   ;	
   ;		 add di, actstart
   ;	
	add	 di, DGROUP:_actstart
   ;	
   ;		 add di, bx
   ;	
	add	 di, bx
   ;	
   ;		 mov al, color
   ;	
	mov	 al, [bp+8]
   ;	
   ;		 mov es:[di],al
   ;	
	mov	 es:[di],al
   ;	
   ;		}
   ;	 }
   ;	
	pop	di
	mov	sp,bp
	pop	bp
	ret	
_putpixel_x	endp
   ;	
   ;	void modex(void)
   ;	
	assume	cs:_TEXT
_modex	proc	near
	push	bp
	mov	bp,sp
	push	di
   ;	
   ;	 {
   ;		asm{
   ;		 mov ax, 13h
   ;	
	mov	 ax, 13h
   ;	
   ;		 int 10h
   ;	
	int	 10h
   ;	
   ;		 mov bx, SEQU_ADDR  //init chain-4
   ;	
	mov	 bx, DGROUP:_SEQU_ADDR  
   ;	
   ;		 mov dx,bx
   ;	
	mov	 dx,bx
   ;	
   ;		 mov ax, 0604h
   ;	
	mov	 ax, 0604h
   ;	
   ;		 out dx, ax
   ;	
	out	 dx, ax
   ;	
   ;		 mov dx, CRTC_ADDR  //turn off word mode
   ;	
	mov	 dx, DGROUP:_CRTC_ADDR  
   ;	
   ;		 mov ax, 0e317h
   ;	
	mov	 ax, 0e317h
   ;	
   ;		 out dx, ax
   ;	
	out	 dx, ax
   ;	
   ;		 mov ax, 14h        //turn off double word mode
   ;	
	mov	 ax, 14h        
   ;	
   ;		 out dx, ax
   ;	
	out	 dx, ax
   ;	
   ;		 mov dx, bx;        //clear video memory-select all four planes
   ;	
	mov	 dx, bx
   ;	
   ;		 mov ax, 0F02h
   ;	
	mov	 ax, 0F02h
   ;	
   ;		 out dx, ax
   ;	
	out	 dx, ax
   ;	
   ;		 xor di, di         // clear thy mem
   ;	
	xor	 di, di         
   ;	
   ;		 xor ax, ax
   ;	
	xor	 ax, ax
   ;	
   ;		 mov dx, VGA
   ;	
	mov	 dx, DGROUP:_VGA
   ;	
   ;		 xor ax, ax
   ;	
	xor	 ax, ax
   ;	
   ;		 mov es, dx
   ;	
	mov	 es, dx
   ;	
   ;		 mov cx, 32000
   ;	
	mov	 cx, 32000
   ;	
   ;		 rep stosw
   ;	
	rep stosw	
   ;	
   ;		}
   ;		height     = 200;
   ;	
	mov	word ptr DGROUP:_height,200
   ;	
   ;		width      = 320;
   ;	
	mov	word ptr DGROUP:_width,320
   ;	
   ;		widthbytes = 80;
   ;	
	mov	word ptr DGROUP:_widthbytes,80
   ;	
   ;		actstart   = 0;
   ;	
	mov	word ptr DGROUP:_actstart,0
   ;	
   ;		vistart    = 0;
   ;	
	mov	word ptr DGROUP:_vistart,0
   ;	
   ;	 }
   ;	
	pop	di
	pop	bp
	ret	
_modex	endp
   ;	
   ;	void waitretrace(void)
   ;	
	assume	cs:_TEXT
_waitretrace	proc	near
	push	bp
	mov	bp,sp
   ;	
   ;	 {
   ;		 asm{
   ;				 mov dx,3DAh
   ;	
	mov	 dx,3DAh
@7@58:
   ;	
   ;	      }
   ;		 l1:;
   ;		 asm{
   ;				 in al,dx
   ;	
	in	 al,dx
   ;	
   ;				 and al,08h
   ;	
	and	 al,08h
   ;	
   ;				 jnz l1
   ;	
	jne	short @7@58
@7@142:
   ;	
   ;				}
   ;		 l2:;
   ;		 asm{
   ;				 in al,dx
   ;	
	in	 al,dx
   ;	
   ;				 and al,08h
   ;	
	and	 al,08h
   ;	
   ;				 jz  l2
   ;	
	je	short @7@142
   ;	
   ;		 };
   ;	 }
   ;	
	pop	bp
	ret	
_waitretrace	endp
   ;	
   ;	void setpal(void)
   ;	
	assume	cs:_TEXT
_setpal	proc	near
	push	bp
	mov	bp,sp
	sub	sp,4
	push	si
   ;	
   ;	 {
   ;		 int pseg,pofs;
   ;	   pseg = FP_SEG(pallete);
   ;	
	mov	word ptr [bp-2],ds
   ;	
   ;		 pofs = FP_OFF(pallete);
   ;	
	mov	word ptr [bp-4],offset DGROUP:_pallete
   ;	
   ;		 asm{
   ;				push ds
   ;	
	push	 ds
   ;	
   ;				mov ax,pseg
   ;	
	mov	 ax,[bp-2]
   ;	
   ;				mov ds,ax
   ;	
	mov	 ds,ax
   ;	
   ;				mov si,pofs
   ;	
	mov	 si,[bp-4]
   ;	
   ;		 };
   ;		 waitretrace();
   ;	
	call	near ptr _waitretrace
   ;	
   ;		 asm{
   ;				mov dx,3c8h
   ;	
	mov	 dx,3c8h
   ;	
   ;				mov al,0
   ;	
	mov	 al,0
   ;	
   ;				out dx,al
   ;	
	out	 dx,al
   ;	
   ;				inc dx
   ;	
	inc	 dx
   ;	
   ;				mov cx,384
   ;	
	mov	 cx,384
   ;	
   ;				rep outsb
   ;	
	rep outsb	
   ;	
   ;		 };
   ;		 waitretrace();
   ;	
	call	near ptr _waitretrace
   ;	
   ;		 asm{
   ;				mov dx,3c8h
   ;	
	mov	 dx,3c8h
   ;	
   ;				mov al,128
   ;	
	mov	 al,128
   ;	
   ;				out dx,al
   ;	
	out	 dx,al
   ;	
   ;				inc dx
   ;	
	inc	 dx
   ;	
   ;				mov cx,384
   ;	
	mov	 cx,384
   ;	
   ;				rep outsb
   ;	
	rep outsb	
   ;	
   ;				pop ds
   ;	
	pop	 ds
   ;	
   ;		 }
   ;	}
   ;	
	pop	si
	mov	sp,bp
	pop	bp
	ret	
_setpal	endp
   ;	
   ;	void totextmode(void)
   ;	
	assume	cs:_TEXT
_totextmode	proc	near
	push	bp
	mov	bp,sp
   ;	
   ;	 {
   ;		asm{
   ;		 mov ax,0003h
   ;	
	mov	 ax,0003h
   ;	
   ;		 int 10h
   ;	
	int	 10h
   ;	
   ;		}
   ;	 }
   ;	
	pop	bp
	ret	
_totextmode	endp
   ;	
   ;	void main()
   ;	
	assume	cs:_TEXT
_main	proc	near
	push	bp
	mov	bp,sp
	sub	sp,2
   ;	
   ;	{
   ;	 modex();
   ;	
	call	near ptr _modex
   ;	
   ;	 setvisiblepage(0);
   ;	
	xor	ax,ax
	push	ax
	call	near ptr _setvisiblepage
	pop	cx
   ;	
   ;	 setactivepage(0);
   ;	
	xor	ax,ax
	push	ax
	call	near ptr _setactivepage
	pop	cx
   ;	
   ;	
   ;	 //create pallete
   ;	 for(i=0;i<63;i++)
   ;	
	mov	word ptr DGROUP:_i,0
	jmp	@10@114
@10@58:
   ;	
   ;		{
   ;			pallete[i][0]=i;pallete[i][1]=0;pallete[i][2]=0;
   ;	
	mov	bx,word ptr DGROUP:_i
	shl	bx,1
	mov	al,byte ptr DGROUP:_i
	mov	byte ptr DGROUP:_pallete[bx],al
	mov	bx,word ptr DGROUP:_i
	shl	bx,1
	mov	byte ptr DGROUP:_pallete[bx+1],0
	mov	bx,word ptr DGROUP:_i
	shl	bx,1
	mov	byte ptr DGROUP:_pallete[bx+2],0
   ;	
   ;			pallete[i+64][0]=0;pallete[i+64][1]=i;pallete[i+64][2]=0;
   ;	
	mov	bx,word ptr DGROUP:_i
	shl	bx,1
	mov	byte ptr DGROUP:_pallete[bx+128],0
	mov	bx,word ptr DGROUP:_i
	shl	bx,1
	mov	al,byte ptr DGROUP:_i
	mov	byte ptr DGROUP:_pallete[bx+129],al
	mov	bx,word ptr DGROUP:_i
	shl	bx,1
	mov	byte ptr DGROUP:_pallete[bx+130],0
   ;	
   ;			pallete[i+128][0]=0;pallete[i+128][1]=0;pallete[i+128][2]=i;
   ;	
	mov	bx,word ptr DGROUP:_i
	shl	bx,1
	mov	byte ptr DGROUP:_pallete[bx+256],0
	mov	bx,word ptr DGROUP:_i
	shl	bx,1
	mov	byte ptr DGROUP:_pallete[bx+257],0
	mov	bx,word ptr DGROUP:_i
	shl	bx,1
	mov	al,byte ptr DGROUP:_i
	mov	byte ptr DGROUP:_pallete[bx+258],al
   ;	
   ;			pallete[i+192][0]=i;pallete[i+192][1]=i;pallete[i+192][2]=i;
   ;	
	mov	bx,word ptr DGROUP:_i
	shl	bx,1
	mov	al,byte ptr DGROUP:_i
	mov	byte ptr DGROUP:_pallete[bx+384],al
	mov	bx,word ptr DGROUP:_i
	shl	bx,1
	mov	al,byte ptr DGROUP:_i
	mov	byte ptr DGROUP:_pallete[bx+385],al
	mov	bx,word ptr DGROUP:_i
	shl	bx,1
	mov	al,byte ptr DGROUP:_i
	mov	byte ptr DGROUP:_pallete[bx+386],al
	inc	word ptr DGROUP:_i
@10@114:
	cmp	word ptr DGROUP:_i,63
	jge	@@0
	jmp	@10@58
@@0:
   ;	
   ;		}
   ;	
   ;	 setpal();
   ;	
	call	near ptr _setpal
   ;	
   ;	 fractal = (tab*)malloc(sizeof(tab));
   ;	
	mov	ax,16000
	push	ax
	call	near ptr _malloc
	pop	cx
	mov	word ptr DGROUP:_fractal,ax
   ;	
   ;	
   ;	 for(y=0;y<319;y++) putpixel_x(50,y,62);
   ;	
	mov	word ptr DGROUP:_y,0
	jmp	short @10@226
@10@170:
	mov	al,62
	push	ax
	push	word ptr DGROUP:_y
	mov	ax,50
	push	ax
	call	near ptr _putpixel_x
	add	sp,6
	inc	word ptr DGROUP:_y
@10@226:
	cmp	word ptr DGROUP:_y,319
	jl	short @10@170
   ;	
   ;	
   ;	 crh=1.3232;crl=-1;
   ;	
	mov	word ptr DGROUP:_crh+2,16297
	mov	word ptr DGROUP:_crh,24222
	mov	word ptr DGROUP:_crl+2,-16512
	mov	word ptr DGROUP:_crl,0
   ;	
   ;	 cih=-1.5437437;cil=0;
   ;	
	mov	word ptr DGROUP:_cih+2,-16443
	mov	word ptr DGROUP:_cih,-26267
	mov	word ptr DGROUP:_cil+2,0
	mov	word ptr DGROUP:_cil,0
   ;	
   ;	
   ;	 ysize=2*(crh-crl)/fractwidth;
   ;	
	mov	ax,word ptr DGROUP:_fractwidth
	mov	word ptr [bp-2],ax
	fild	word ptr [bp-2]
	fld	dword ptr DGROUP:_crh
	fsub	dword ptr DGROUP:_crl
	fmul	dword ptr DGROUP:s@
	fdivr	
	fstp	dword ptr DGROUP:_ysize
   ;	
   ;	 xsize=2*(cih-cil)/fractheight;
   ;	
	fwait	
	mov	ax,word ptr DGROUP:_fractheight
	mov	word ptr [bp-2],ax
	fild	word ptr [bp-2]
	fld	dword ptr DGROUP:_cih
	fsub	dword ptr DGROUP:_cil
	fmul	dword ptr DGROUP:s@
	fdivr	
	fstp	dword ptr DGROUP:_xsize
   ;	
   ;	 ci=cil;
   ;	
	fwait	
	mov	ax,word ptr DGROUP:_cil+2
	mov	dx,word ptr DGROUP:_cil
	mov	word ptr DGROUP:_ci+2,ax
	mov	word ptr DGROUP:_ci,dx
   ;	
   ;	
   ;	 for(y = 0;y<fractheight;y++)
   ;	
	mov	word ptr DGROUP:_y,0
	jmp	@10@646
@10@282:
   ;	
   ;		{
   ;			cr= crl;
   ;	
	mov	ax,word ptr DGROUP:_crl+2
	mov	dx,word ptr DGROUP:_crl
	mov	word ptr DGROUP:_cr+2,ax
	mov	word ptr DGROUP:_cr,dx
   ;	
   ;			for(x= 0;x<fractwidth;x++)
   ;	
	mov	word ptr DGROUP:_x,0
	jmp	@10@562
@10@310:
   ;	
   ;			 {
   ;				 zr= 0;zi= 0;
   ;	
	mov	word ptr DGROUP:_zr+2,0
	mov	word ptr DGROUP:_zr,0
	mov	word ptr DGROUP:_zi+2,0
	mov	word ptr DGROUP:_zi,0
   ;	
   ;				 for(i= 1;i<maxiter;i++)
   ;	
	mov	word ptr DGROUP:_i,1
	jmp	@10@422
@10@338:
   ;	
   ;					{
   ;						aux1= zr*zr;
   ;	
	fld	dword ptr DGROUP:_zr
	fmul	dword ptr DGROUP:_zr
	fstp	dword ptr DGROUP:_aux1
   ;	
   ;						aux2= zi*zi;
   ;	
	fld	dword ptr DGROUP:_zi
	fmul	dword ptr DGROUP:_zi
	fstp	dword ptr DGROUP:_aux2
   ;	
   ;						newzr= aux1-aux2+cr;
   ;	
	fld	dword ptr DGROUP:_aux1
	fsub	dword ptr DGROUP:_aux2
	fadd	dword ptr DGROUP:_cr
	fstp	dword ptr DGROUP:_newzr
   ;	
   ;						newzi= 2*zr*zi+ci;
   ;	
	fld	dword ptr DGROUP:s@
	fmul	dword ptr DGROUP:_zr
	fmul	dword ptr DGROUP:_zi
	fadd	dword ptr DGROUP:_ci
	fstp	dword ptr DGROUP:_newzi
   ;	
   ;						zr= newzr;
   ;	
	fwait	
	mov	ax,word ptr DGROUP:_newzr+2
	mov	dx,word ptr DGROUP:_newzr
	mov	word ptr DGROUP:_zr+2,ax
	mov	word ptr DGROUP:_zr,dx
   ;	
   ;						zi= newzi;
   ;	
	mov	ax,word ptr DGROUP:_newzi+2
	mov	dx,word ptr DGROUP:_newzi
	mov	word ptr DGROUP:_zi+2,ax
	mov	word ptr DGROUP:_zi,dx
   ;	
   ;						if (aux1+aux2>4) break;
   ;	
	fld	dword ptr DGROUP:_aux1
	fadd	dword ptr DGROUP:_aux2
	fcomp	dword ptr DGROUP:s@+4
	fstsw	word ptr [bp-2]
	fwait	
	mov	ax,word ptr [bp-2]
	sahf	
	jbe	short @10@394
	jmp	short @10@450
@10@394:
	inc	word ptr DGROUP:_i
@10@422:
	mov	ax,word ptr DGROUP:_i
	cmp	ax,word ptr DGROUP:_maxiter
	jge	@@1
	jmp	@10@338
@@1:
@10@450:
   ;	
   ;					};
   ;					if (255-i<210) putpixel_x(x,y,255-i);
   ;	
	mov	ax,255
	sub	ax,word ptr DGROUP:_i
	cmp	ax,210
	jge	short @10@506
	mov	al,255
	sub	al,byte ptr DGROUP:_i
	push	ax
	push	word ptr DGROUP:_y
	push	word ptr DGROUP:_x
	call	near ptr _putpixel_x
	add	sp,6
@10@506:
   ;	
   ;					cr= xsize+cr;
   ;	
	fld	dword ptr DGROUP:_xsize
	fadd	dword ptr DGROUP:_cr
	fstp	dword ptr DGROUP:_cr
	fwait	
	inc	word ptr DGROUP:_x
@10@562:
	mov	ax,word ptr DGROUP:_x
	cmp	ax,word ptr DGROUP:_fractwidth
	jge	@@2
	jmp	@10@310
@@2:
   ;	
   ;			 }
   ;			ci= ysize+ci;
   ;	
	fld	dword ptr DGROUP:_ysize
	fadd	dword ptr DGROUP:_ci
	fstp	dword ptr DGROUP:_ci
	fwait	
	inc	word ptr DGROUP:_y
@10@646:
	mov	ax,word ptr DGROUP:_y
	cmp	ax,word ptr DGROUP:_fractheight
	jge	@@3
	jmp	@10@282
@@3:
   ;	
   ;		}
   ;	
   ;	 {for (x=0;x<fractheight;x++) for(y=0;y<fractwidth;y++) putpixel_x(80+x,50+y,*fractal[y][x]);}
   ;	
	mov	word ptr DGROUP:_x,0
	jmp	short @10@842
@10@702:
	mov	word ptr DGROUP:_y,0
	jmp	short @10@786
@10@730:
	mov	ax,word ptr DGROUP:_y
	mov	dx,16000
	imul	dx
	mov	bx,word ptr DGROUP:_fractal
	add	bx,ax
	mov	ax,word ptr DGROUP:_x
	mov	dx,100
	imul	dx
	add	bx,ax
	mov	al,byte ptr [bx]
	push	ax
	mov	ax,word ptr DGROUP:_y
	add	ax,50
	push	ax
	mov	ax,word ptr DGROUP:_x
	add	ax,80
	push	ax
	call	near ptr _putpixel_x
	add	sp,6
	inc	word ptr DGROUP:_y
@10@786:
	mov	ax,word ptr DGROUP:_y
	cmp	ax,word ptr DGROUP:_fractwidth
	jl	short @10@730
	inc	word ptr DGROUP:_x
@10@842:
	mov	ax,word ptr DGROUP:_x
	cmp	ax,word ptr DGROUP:_fractheight
	jl	short @10@702
   ;	
   ;	 getch();
   ;	
	call	near ptr _getch
   ;	
   ;	 totextmode();
   ;	
	call	near ptr _totextmode
   ;	
   ;	}
   ;	
	mov	sp,bp
	pop	bp
	ret	
_main	endp
_TEXT	ends
_BSS	segment word public 'BSS'
_vistart	label	word
	db	2 dup (?)
_actstart	label	word
	db	2 dup (?)
_widthbytes	label	word
	db	2 dup (?)
_height	label	word
	db	2 dup (?)
_width	label	word
	db	2 dup (?)
_i	label	word
	db	2 dup (?)
_y	label	word
	db	2 dup (?)
_x	label	word
	db	2 dup (?)
_pallete	label	byte
	db	510 dup (?)
_fractal	label	word
	db	2 dup (?)
_newzi	label	dword
	db	4 dup (?)
_newzr	label	dword
	db	4 dup (?)
_zi	label	dword
	db	4 dup (?)
_zr	label	dword
	db	4 dup (?)
_ysize	label	dword
	db	4 dup (?)
_xsize	label	dword
	db	4 dup (?)
_aux2	label	dword
	db	4 dup (?)
_aux1	label	dword
	db	4 dup (?)
_cil	label	dword
	db	4 dup (?)
_cih	label	dword
	db	4 dup (?)
_cr	label	dword
	db	4 dup (?)
_ci	label	dword
	db	4 dup (?)
_crh	label	dword
	db	4 dup (?)
_crl	label	dword
	db	4 dup (?)
	?debug	C E9
	?debug	C FA00000000
_BSS	ends
_DATA	segment word public 'DATA'
s@	label	byte
	db	0
	db	0
	db	0
	db	'@'
	db	0
	db	0
	db	-128
	db	'@'
_DATA	ends
_TEXT	segment byte public 'CODE'
_TEXT	ends
	public	_main
	public	_totextmode
	public	_setpal
	public	_waitretrace
	public	_modex
	public	_putpixel_x
	public	_setvisiblepage
	public	_setactivepage
	public	_setactivestart
	public	_setvisiblestart
	public	_vistart
	public	_actstart
	public	_widthbytes
	public	_height
	public	_width
	public	_i
	public	_y
	public	_x
	public	_pallete
	public	_VGA
	public	_CRTC_ADDR
	public	_SEQU_ADDR
	public	_fractal
	public	_maxiter
	public	_fractheight
	public	_fractwidth
	public	_newzi
	public	_newzr
	public	_zi
	public	_zr
	public	_ysize
	public	_xsize
	public	_aux2
	public	_aux1
	public	_cil
	public	_cih
	public	_cr
	public	_ci
	public	_crh
	public	_crl
	extrn	_getch:near
	extrn	_malloc:near
_s@	equ	s@
	end
