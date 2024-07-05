procedure Set320x240;
begin
  { /* Set the unchained version of mode 13h: */}
  asm
    mov ax, 13h
    int 10h
    mov bx, SEQU_ADDR
    mov dx,bx
    mov ax, 0604h
    out dx, ax
    mov dx, CRTC_ADDR
    mov ax, 0e317h
    out dx, ax
    mov ax, 14h
    out dx, ax
    mov dx, bx;
    mov ax, 0F02h
    out dx, ax
    xor di, di
    xor ax, ax
    mov dx, VGA
    xor ax, ax
    mov es, dx
    mov cx, 32000
    rep stosw
  end;

 { Modify the vertical sync polarity bits in the Misc. Output
     Register to achieve square aspect ratio: }
  port[$3c2]:=$e3;

  { Modify the vertical timing registers to reflect the increased
     vertical resolution, and to center the image as good as
     possible: }

  { turn off write protect }
  portw[$3d4]:=$2c11;
  { vertical total         }
  portw[$3d4]:=$0d06;
  { overflow register      }
  portw[$3d4]:=$3e07;
  { vertical retrace start }
  portw[$3d4]:=$ea10;
  { vertical retrace end AND wr.prot }
  portw[$3d4]:=$ac11;
  { vertical display enable end }
  portw[$3d4]:=$df12;
  { start vertical blanking }
  portw[$3d4]:=$e715;
  { end vertical blanking }
  portw[$3d4]:=$0616;

  height     := 240;
  width      := 320;
  widthbytes := 80;
  actstart   := 0;
  vistart    := 0;
end;

procedure SetVisibleStart(offset : integer);
begin
  viStart := offset;
  asm
    mov   ax,viStart
    mov   cx,ax
    mov   bh,cl
    mov   bl,0dh
    mov   cl,0ch
    mov   dx,input_status_1
   @WaitDE:{ which is display enable }
    in    al,dx
    test  al,01h
    jnz   @WaitDE
    mov   dx,CRTC_ADDR
    mov   ax,bx
    out   dx,ax
    mov   ax,cx
    out   dx,ax
    mov   dx,input_status_1
   @WaitVS:
    in    al,dx
    test  al,08h
    jz    @WaitVS
  end;
end;

procedure SetActiveStart(offset : integer);
begin
 actstart := offset;
end;

procedure SetActivePage(page : integer);
begin
 setactivestart(page * widthbytes * height);
end;

procedure SetVisiblePage(page : integer);
begin
 setvisiblestart(page * widthbytes * height);
end;

procedure PutPixel_X(x,y : integer;color : byte);
 var
    dummy : byte;
 begin
	dummy := 1 shl (x and 3);
	asm
         push es
	 mov dx, SEQU_ADDR
	 mov al, 02h
	 out dx, al
	 inc dx
	 mov al, dummy
	 out dx, al
	 mov dx, VGA
	 mov es, dx
	 mov bx, [x]
	 shr bx, 2
	 mov di, [y]
	 mov ax, di
	 shl di, 6
	 shl ax, 4
	 add di, ax
	 add di, actstart
	 add di, bx
	 mov al, color
	 mov es:[di],al
         pop es
	end;
 end;

procedure WaitRetrace;assembler;
asm
  mov dx,input_status_1
  @l1:
    in al,dx
    and al,08h
    jnz @l1
  @l2:
    in al,dx
    and al,08h
    jz  @l2
end;

{procedure SetRGB(index,r,g,b : byte);
begin
 port[$3c8]:=index;
 port[$3c9]:=r;
 port[$3c9]:=g;
 port[$3c9]:=b;
end;}

procedure SetPal;
var pseg1,pofs1 : word;
 begin
   pseg1 := seg(workpal);
   pofs1 := ofs(workpal);
   asm
     push ds
     mov ax,pseg1
     mov ds,ax
     mov si,pofs1
   end;
   {waitretrace;}
   asm
     mov dx,3c8h
     mov al,0
     out dx,al
     inc dx
     mov cx,384
     rep outsb
   end;
   {waitretrace;}
   asm
     mov dx,3c8h
     mov al,128
     out dx,al
     inc dx
     mov cx,384
     rep outsb
     pop ds
   end;
end;

{procedure FadeOut(speed:byte);
var i,j:integer;
begin
for i:=1 to 64 div speed do
    begin
    for j:=0 to 255 do
        begin
        if workpal[j,1]>=speed then dec(workpal[j,1],speed);
        if workpal[j,2]>=speed then dec(workpal[j,2],speed);
        if workpal[j,3]>=speed then dec(workpal[j,3],speed);
        end;
    for j:=1 to 1024 do asm nop end;
    waitretrace;
    Setpal;
    end;
end;}

procedure Cls(page : integer);
var
   a,b : word;
begin
 a := widthbytes;
 b := height;
 asm
  mov dx,SEQU_ADDR
  mov ax, 0F02h
  out dx, ax
  mov dx,$a000
  mov es,dx
  mov ax,page
  mul a
  mul b
  mov di,ax
  xor ax,ax
  mov cx,9600
  rep stosw
 end;
end;

Procedure XRectFill( StartX,StartY,EndX,EndY,Color:word ); assembler;
asm
	push bp
	cld
	mov  ax,WidthBytes
	mul  StartY
	mov  di,StartX
	shr  di,1
	shr  di,1
	add  di,ax
	add  di,ActStart
	mov  ax,VGA
	mov  es,ax
	mov  dx,SEQU_ADDR
	mov  al,MAPMASK
	out  dx,al
	inc  dx
	mov  si,StartX
	and  si,0003h
	mov  bh,byte ptr LeftClipPlaneMask[si]
	mov  si,EndX
	and  si,0003h
	mov  bl,byte ptr RightClipPlaneMask[si]
	mov  cx,EndX
	mov  si,StartX
	cmp  cx,si
	jle  @@FillDone
	dec  cx
	and  si,not 011b
	sub  cx,si
	shr  cx,1
	shr  cx,1
	jnz  @@MasksSet
	and  bh,bl

@@MasksSet:
	mov  si,EndY
	sub  si,StartY
	jle  @@FillDone
	mov  ah,byte ptr Color
	mov  bp,WidthBytes
	sub  bp,cx
	dec  bp
@@FillRowsLoop:
	push cx
	mov  al,bh
	out  dx,al
	mov  al,ah
	stosb
	dec  cx
	js   @@FillLoopBottom
	jz   @@DoRightEdge
	mov  al,00fh
	out  dx,al
	mov  al,ah
	rep  stosb
@@DoRightEdge:
	mov  al,bl
	out  dx,al
	mov  al,ah
	stosb
@@FillLoopBottom:
	add  di,bp
	pop  cx
	dec  si
	jnz  @@FillRowsLoop
@@FillDone:
	pop bp
end;


procedure TextMode;assembler;
asm
  mov ax,0003h
  int 10h
end;
