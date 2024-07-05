CONST
     { clipping variables }
     XMode320x200    = 0;
     XMode320x240    = 1;
     XMode360x200    = 2;
     XMode360x240    = 3;
     XMode376x282    = 4;
     XMode320x400    = 5;
     XMode320x480    = 6;
     XMode360x400    = 7;
     XMode360x480    = 8;
     XMode360x360    = 9;
     XMode376x308    = 10;
     XMode376x564    = 11;
     CurrXMode       : word = 0;
     ClipLT   : word = 0;
     ClipRT   : word = 319;
     ClipTP   : word = 0;
     ClipBT   : word = 399;
     Color    : byte = 255;
     Height   : word = 400;
     Width    : word = 320;
     WidthBytes:word = 80;
     ActStart : word = 0;
     ViStart  : word = 0;
     OrgX     : word = 160;
     OrgY     : word = 200;
     Page     : word = 1;
     { video defs }
     SEQU_ADDR      = $3c4;
     CRTC_ADDR      = $3d4;
     INPUT_STATUS_0 = $3c2;
     INPUT_STATUS_1 = $3da;
     MapMask        = $02;
     ReadMap        = $04;
     GcIndex        = $03CE;
     VGA            = $a000;
     LeftClipPlaneMask  : array[0..3] of byte = ( $0F, $0E, $0C, $08 );
     RightClipPlaneMask : array[0..3] of byte = ( $0F, $01, $03, $07 );
     ColumnMask         : array[0..3] of byte = ( $11, $22, $44, $88 );
     LeftMaskTable      : array[0..8] of byte = ( 0, $ff, $ee, 0, $cc, 0, 0, 0, $88 );
     RightMaskTable     : array[0..8] of byte = ( 0, $11, $33, 0, $77, 0, 0, 0, $ff );
     TweakValues : array[0..180] of word =
	     ( $0200, $0014, $E317, 320, 200,
		     $0AE3, $0D06, $3E07, $4109, $EA10, $AC11, $DF12, $0014, $E715, $0616,
			     $E317, 320, 240,
		     $08E7, $6B00, $5901, $5A02, $8E03, $5E04, $8A05, $0014, $E317, 360, 200,
		     $11E7, $6b00, $5901, $5A02, $8E03, $5E04, $8A05, $0D06, $3E07, $4109,
			     $EA10, $AC11, $DF12, $2D13, $0014, $E715, $0616, $E317, 360, 240,
		     $12E7, $6E00, $5D01, $5E02, $9103, $06204, $8F05, $6206, $F007, $6109,
			     $310F, $3710, $8911, $3312, $2F13, $0014, $3C15, $5C16, $E317, 376, 564,
		     $03E3, $4009 ,$0014, $E317, 320, 400,
		     $0AE3, $0D06, $3E07, $4009, $EA10, $AC11, $DF12, $0014, $E715, $0616,
			     $E317, 320, 480,
		     $09E7, $6B00, $5901, $5A02, $8E03, $5E04, $8A05, $4009, $0014, $E317,
			     360, 400,
		     $11E7, $6B00, $5901, $5A02, $8E03, $5E04, $8A05, $0D06, $3E07, $4009,
			     $EA10, $AC11, $DF12, $2D13, $0014, $E715, $0616, $E317, 360, 480,
		     $0FE7, $6b00, $5901, $5A02, $8E03, $5E04, $8A05, $4009, $8810, $8511,
			     $6712, $2D13, $0014, $6D15, $BA16, $E317, 360, 360,
		     $12E7, $6E00, $5D01, $5E02, $9103, $6204, $8F05, $6206, $0F07, $4009,
			     $310F, $3710, $8911, $3312, $2F13, $0014, $3C15, $5C16, $E317, 376, 308,
		     $12E7, $6E00, $5D01, $5E02, $9103, $6204, $8F05, $6206, $F007, $6009,
			     $310F, $3710, $8911, $3312, $2F13, $0014, $3C15, $5C16, $E317, 376, 564 );

     ModeTable : array[0..11] of word =
	     ( Ofs(TweakValues[0]), Ofs(TweakValues[5]), Ofs(TweakValues[18]),
		     Ofs(TweakValues[29]), Ofs(TweakValues[49]), Ofs(TweakValues[70]),
		     Ofs(TweakValues[76]), Ofs(TweakValues[89]), Ofs(TweakValues[101]),
		     Ofs(TweakValues[121]), Ofs(TweakValues[139]), Ofs(TweakValues[160]) );

TYPE
    TPal = array[0..255,1..3] of shortint;

VAR
   WorkPal     : pointer;
   TmpPal      : pointer;
   DrawEnabled : boolean;


Function TweakMode( Mode, WidthInPixels : Word ) : Word; assembler;
asm
	cld
	mov   ax,ds
	mov   es,ax
	mov   cx,mode
	cmp   cx,13
	jle   @@ValidMode
	mov   ax,-1
	jmp @@Done

@@ValidMode:
	mov   CurrXMode,cx
	xor   al,al
	cmp   cx,3
	jg    @@SetDoubleScanFlag
	mov   al,1

@@SetDoubleScanFlag:
	{mov   DoubleScanFlag,al}
	push  cx
	mov   ax,13h
	int   10h
	pop   cx
	mov   dx,SEQU_ADDR
	mov   ax,0604h
	out   dx,ax
	mov   ax,0100h
	out   dx,ax
	mov   bx,offset ModeTable
	shl   cx,1
	add   bx,cx
	mov   si, word ptr [bx]
	lodsb
	or    al,al
	jz    @@DontSetDot
	mov   dx,INPUT_STATUS_0 {miscoutput}
	out   dx,al

@@DontSetDot:
	mov   dx,SEQU_ADDR
	mov   ax,0300h
	out   dx,ax
	mov   dx,CRTC_ADDR
	mov   al,11h
	out   dx,al
	inc   dx
	in    al,dx
	and   al,07fh
	out   dx,al
	dec   dx
	cld
	xor   cx,cx
	lodsb
	mov   cl,al

@@SetCRTParmsLoop:
	lodsw

	out   dx,ax
	loop  @@SetCRTParmsLoop
	mov   dx,SEQU_ADDR
	mov   ax,0f02h
	out   dx,ax
	mov   ax,VGA
	mov   es,ax
	sub   di,di
	sub   ax,ax
	mov   cx,8000h
	rep   stosw
	lodsw
	mov   Width,ax
	{mov   SplitScrnScanLine,ax}
	mov   bx,ax
	shr   ax,2
	mov   WidthBytes,ax
	lodsw
	mov   Height,ax
	mov   cx,widthinpixels
	mov   dx,CRTC_ADDR
	mov   al,$13
	out   dx,al
	inc   dx
	mov   ax,cx
	cmp   ax,Width
	jge   @@ValidLogicalWidth
	mov   ax,bx

@@ValidLogicalWidth:
	shr   ax,3
	out   dx,al
	shl   ax,1
	mov   bx,ax
	mov   WidthBytes,ax
	{mov   RightClip,ax}
	sub   ax,WidthBytes
	shl   ax,2
	{mov   MaxScrollX,ax}
	mov   ax,bx
	shl   ax,2
	mov   Width,ax
	mov   cx,ax
	mov   ax,0ffffh
	sub   dx,dx
	div   bx
	mov   Height,ax
	{mov   BottomClip,ax}
	sub   ax,Height
	{mov   MaxScrollY,ax}
	{mov   ax,cx
	mov   ax,WidthBytes
	mul   Height
	{mov   NonVisualOffs,ax}

@@Done:
	mov		ax, 0CB00h
	int		10h
        mov             actstart,0
        mov             vistart,0
End;
  {height     := 400;
  width      := 320;
  widthbytes := 80;
  actstart   := 0;
  vistart    := 0;
end;}

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
         mov ax,x
         cmp ax,ClipLt
         jl  @theend
         cmp ax,ClipRt
         jg  @theend
         mov ax,y
         cmp ax,ClipBt
         jg  @theend
         cmp ax,ClipTp
         jl  @theend
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
         @theend:
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

procedure SetRGB(index,r,g,b : byte);
begin
  port[$3c8]:=index;
  port[$3c9]:=r;
  port[$3c9]:=g;
  port[$3c9]:=b;
end;

procedure SetPal(whatpal : pointer);
var pseg1,pofs1 : word;
 begin
   pseg1 := seg(whatpal^);
   pofs1 := ofs(whatpal^);
   asm
     push ds
     mov ax,pseg1
     mov ds,ax
     mov si,pofs1
     cld
     xor ax,ax
     mov dx,$3c8
     out dx,al
     mov cx,768
     mov dx,INPUT_STATUS_1
     @waitvs:
       in al,dx
       test al,08h
     jz @waitvs
     mov dx,$3c9
     @setit:
       outsb
     loop @setit
     pop ds
  end;
end;

procedure PalMorph(SrcPal,DstPal : pointer;speed : byte);
const
   modified : boolean = false;
var
   i,j : integer;
   workpal : pointer;
begin
  getmem(workpal,768);
  Move(SrcPal^,WorkPal^,768);
  repeat
    modified := false;
    for j:=0 to 255 do
        begin
          if TPal(WorkPal^)[j,1]<TPal(DstPal^)[j,1]
             then begin
                    inc(TPal(WorkPal^)[j,1],speed);
                    if TPal(WorkPal^)[j,1]>TPal(DstPal^)[j,1] then TPal(WorkPal^)[j,1] := TPal(DstPal^)[j,1];
                    modified := true;
                  end
             else if TPal(WorkPal^)[j,1]>TPal(DstPal^)[j,1]
                  then begin
                         dec(TPal(WorkPal^)[j,1],speed);
                         if TPal(WorkPal^)[j,1]<TPal(DstPal^)[j,1] then TPal(WorkPal^)[j,1] := TPal(DstPal^)[j,1];
                         modified := true;
                       end;
          if TPal(WorkPal^)[j,2]<TPal(DstPal^)[j,2]
             then begin
                    inc(TPal(WorkPal^)[j,2],speed);
                    if TPal(WorkPal^)[j,2]>TPal(DstPal^)[j,2] then TPal(WorkPal^)[j,2] := TPal(DstPal^)[j,2];
                    modified := true;
                  end
             else if TPal(WorkPal^)[j,2]>TPal(DstPal^)[j,2]
                  then begin
                         dec(TPal(WorkPal^)[j,2],speed);
                         if TPal(WorkPal^)[j,2]<TPal(DstPal^)[j,2] then TPal(WorkPal^)[j,2] := TPal(DstPal^)[j,2];
                         modified := true;
                       end;
          if TPal(WorkPal^)[j,3]<TPal(DstPal^)[j,3]
             then begin
                    inc(TPal(WorkPal^)[j,3],speed);
                    if TPal(WorkPal^)[j,3]>TPal(DstPal^)[j,3] then TPal(WorkPal^)[j,3] := TPal(DstPal^)[j,3];
                    modified := true;
                  end
             else if TPal(WorkPal^)[j,3]>TPal(DstPal^)[j,3]
                  then begin
                         dec(TPal(WorkPal^)[j,3],speed);
                         if TPal(WorkPal^)[j,3]<TPal(DstPal^)[j,3] then TPal(WorkPal^)[j,3] := TPal(DstPal^)[j,3];
                         modified := true;
                       end;
        end;
    SetPal(WorkPal);
  until modified = false;
  FreeMem(workpal,768);
end;

procedure PalRot(whatpal : pointer;StartColor,EndColor : word);
var
   r,g,b : byte;
   i     : integer;
   Tmp   : array[1..3] of byte;
begin
  {r := TPal(WhatPal^)[EndColor,1];
  g := TPal(WhatPal^)[EndColor,2];
  b := TPal(WhatPal^)[EndColor,3];
  for i:=EndColor downto StartColor+1 do
      begin
        TPal(WhatPal^)[i,1] := TPal(WhatPal^)[i-1,1];
        TPal(WhatPal^)[i,2] := TPal(WhatPal^)[i-1,2];
        TPal(WhatPal^)[i,3] := TPal(WhatPal^)[i-1,3];
      end;
  TPal(WhatPal^)[StartColor,1] := r;
  TPal(WhatPal^)[StartColor,2] := g;
  TPal(WhatPal^)[StartColor,3] := b;}
  Move(TPal(WhatPal^)[EndColor],Tmp[1],3);
  Move(TPal(WhatPal^)[StartColor],TPal(WhatPal^)[StartColor+1],(EndColor-StartColor)*3);
  Move(Tmp,TPal(WhatPal^)[StartColor],3);
end;

procedure Cls(page : integer;color : byte);
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
  mov ax,a
  mul b
  mov cx,ax
  mul page
  mov di,ax
  mov bl,color
  mov al,bl
  mov ah,bl
  db $66
  shl ax,16
  mov al,bl
  mov ah,bl
  shr cx,2
  db $66
  rep stosw
 end;
end;

Procedure XRectFill( StartX,StartY,EndX,EndY,Color:word ); assembler;
asm
        mov ax,StartX
        cmp ax,ClipRt
        jg  @invisible
        mov ax,StartY
        cmp ax,ClipBt
        jg  @invisible

        mov ax,EndX
        cmp ax,ClipRt
        jle @rcok
        mov ax,ClipRt
        mov EndX,ax
      @rcok:
        mov ax,EndY
        cmp ax,ClipBt
        jle @bcok
        mov ax,ClipBt
        mov EndY,ax
      @bcok:
        mov ax,StartX
        cmp ax,ClipLt
        jge @lcok
        mov ax,ClipLt
        mov StartX,ax
      @lcok:
        mov ax,StartY
        cmp ax,ClipTp
        jge @tcok
        mov ax,ClipTp
        mov StartY,ax
      @tcok:
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
@invisible:
end;


Procedure XCircle( Left, Top, Diameter, Color : word ); assembler;
Var
	offset0,offset1,offset2,offset3,offset4,offset5,offset6,offset7,mask0n1,
	mask2n3,mask4n5,mask6n7,shrunkradius,diametereven,error:word;
asm
	push ds
	mov di, WidthBytes
	xor dx, dx
	mov ax, Diameter
	dec ax
	shr ax, 1
	adc dx, 0
	mov shrunkradius, ax
	mov diametereven, dx
	add ax, Top
	mul di
	add ax, ActStart

	mov bx, Left
	mov cx, bx
	mov si, bx
	shr si, 2
	add si, ax
	mov offset6, si
	and bx, 3
	mov bl, byte ptr ColumnMask[bx]
	mov mask6n7, bx

	add cx, Diameter
	dec cx
	mov bx, cx
	shr cx, 2
	add cx, ax
	mov offset2, cx
	and bx, 3
	mov bl, byte ptr ColumnMask[bx]
	mov mask2n3, bx

	cmp diametereven, 1
	jne @@MiddlePlotsOverlap
	add si, di
	add cx, di
@@MiddlePlotsOverlap:
	mov offset7, si
	mov offset3, cx

	mov bx, Left
	add bx, shrunkradius

	mov ax, Top
	mul di
	add ax, ActStart
	mov si, ax

	mov ax, Diameter
	dec ax
	mul di
	add ax, si

	mov di, bx
	shr di, 2
	add si, di
	mov offset4, si
	add di, ax
	mov offset5, di
	and bx, 3
	mov bl, byte ptr ColumnMask[bx]
	mov mask4n5, bx

	cmp diametereven, 1
	jne @@TopAndBottomPlotsOverlap
	rol bl, 1
	jnc @@TopAndBottomPlotsOverlap
	inc si
	inc di
@@TopAndBottomPlotsOverlap:
	mov offset0, si
	mov offset1, di
	mov mask0n1, bx
	mov bx, WidthBytes

	mov dx, VGA
	mov ds, dx

	mov dx, SEQU_ADDR
	mov al, MAPMASK
	out dx, al
	inc dx

	mov si, Diameter
	inc si

	mov cx, si
	neg cx
	add cx, 2
	mov error, cx

	xor cx, cx
	mov ah, byte ptr Color
	jmp @@CircleCalc

@@NoAdvance:
	mov al, byte ptr mask0n1
	out dx, al
	mov di, offset0
	mov [di], ah
	rol al, 1
	mov byte ptr mask0n1, al
	adc di, 0
	mov offset0, di
	mov di, offset1
	mov [di], ah
	ror al, 1
	adc di, 0
	mov offset1, di

	mov al, byte ptr mask2n3
	out dx, al
	mov di, offset2
	mov [di], ah
	sub di, bx
	mov offset2, di
	mov di, offset3
	mov [di], ah
	add di, bx
	mov offset3, di

	mov al, byte ptr mask4n5
	out dx, al
	mov di, offset4
	mov [di], ah
	ror al, 1
	mov byte ptr mask4n5, al
	sbb di, 0
	mov offset4, di
	mov di, offset5
	mov [di], ah
	rol al, 1
	sbb di, 0
	mov offset5, di

	mov al, byte ptr mask6n7
	out dx, al
	mov di, offset6
	mov [di], ah
	sub di, bx
	mov offset6, di
	mov di, offset7
	mov [di], ah
	add di, bx
	mov offset7, di

	jmp @@CircleCalc

@@Advance:
	mov al, byte ptr mask0n1
	out dx, al
	mov di, offset0
	mov [di], ah
	rol al, 1
	mov byte ptr mask0n1, al
	adc di, bx
	mov offset0, di
	mov di, offset1
	mov [di], ah
	ror al, 1
	adc di, 0
	sub di, bx
	mov offset1, di

	mov al, byte ptr mask2n3
	out dx, al
	mov di, offset2
	mov [di], ah
	ror al, 1
	mov byte ptr mask2n3, al
	sbb di, bx
	mov offset2, di
	mov di, offset3
	mov [di], ah
	rol al, 1
	sbb di, 0
	add di, bx
	mov offset3, di

	mov al, byte ptr mask4n5
	out dx, al
	mov di, offset4
	mov [di], ah
	ror al, 1
	mov byte ptr mask4n5, al
	sbb di, 0
	add di, bx
	mov offset4, di
	mov di, offset5
	mov [di], ah
	rol al, 1
	sbb di, bx
	mov offset5, di

	mov al, byte ptr mask6n7
	out dx, al
	mov di, offset6
	mov [di], ah
	rol al, 1
	mov byte ptr mask6n7, al
	adc di, 0
	sub di, bx
	mov offset6, di
	mov di, offset7
	mov [di], ah
	ror al, 1
	adc di, bx
	mov offset7, di

@@CircleCalc:
	add cx, 2
	mov di, error
	add di, cx
	inc di
	jl @@CircleNoError
	cmp cx, si
	ja @@FleeFlyFlowFum
	sub si, 2
	sub di, si
	mov error, di
	jmp @@Advance
@@CircleNoError:
	mov error, di
	jmp @@NoAdvance

@@FleeFlyFlowFum:
	pop ds
end;

Procedure XFilledCircle( Left, Top, Diameter, Color : word ); assembler;
Var
	offset0,offset1,offset2,offset3,offset4,offset5,offset6,offset7,mask0n1,
	mask2n3,mask4n5,mask6n7,shrunkradius,diametereven,error,jumpvector:word;
asm
	cld
	mov di, WidthBytes
	xor dx, dx
	mov ax, Diameter
	dec ax
	shr ax, 1
	adc dx, 0
	mov shrunkradius, ax
	mov diametereven, dx
	add ax, Top
	mul di
	add ax, ActStart

	mov bx, Left
	mov cx, bx
	mov si, bx
	shr si, 2
	add si, ax
	mov offset6, si
	and bx, 3
	mov bl, byte ptr ColumnMask[bx]
	mov mask6n7, bx

	add cx, Diameter
	dec cx
	mov bx, cx
	shr cx, 2
	add cx, ax
	mov offset2, cx
	and bx, 3
	mov bl, byte ptr ColumnMask[bx]
	mov mask2n3, bx

	cmp diametereven, 1
	jne @@MiddlePlotsOverlap
	add si, di
	add cx, di
@@MiddlePlotsOverlap:
	mov offset7, si
	mov offset3, cx

	mov bx, Left
	add bx, shrunkradius

	mov ax, Top
	mul di
	add ax, ActStart
	mov si, ax

	mov ax, Diameter
	dec ax
	mul di
	add ax, si

	mov di, bx
	shr di, 2
	add si, di
	mov offset4, si
	add di, ax
	mov offset5, di
	and bx, 3
	mov bl, byte ptr ColumnMask[bx]
	mov mask4n5, bx

	cmp diametereven, 1
	jne @@TopAndBottomPlotsOverlap
	rol bl, 1
	jnc @@TopAndBottomPlotsOverlap
	inc si
	inc di
@@TopAndBottomPlotsOverlap:
	mov offset0, si
	mov offset1, di
	mov mask0n1, bx

	mov bx, WidthBytes

	mov dx, VGA
	mov es, dx

	mov dx, SEQU_ADDR
	mov al, MAPMASK
	out dx, al
	inc dx
	mov si, Diameter
	inc si

	mov cx, si
	neg cx
	add cx, 2
	mov error, cx
	xor cx, cx
	mov ah, byte ptr Color
	jmp @@FilledCircleCalc
@@PlotLines:
	push cx

	mov di, mask0n1
	and di, 0000fh
	mov al, byte ptr RightMaskTable[di]
	mov di, offset0
	cmp di, offset4
	jne @@PlotXMajorNontrivial
	mov di, mask4n5
	and di, 0000fh
	and al, byte ptr LeftMaskTable[di]
	out dx, al
	mov di, offset4
	mov es:[di], ah
	mov di, offset5
	mov es:[di], ah
	jmp @@PlotYMajor
@@PlotXMajorNontrivial:
	out dx, al
	mov es:[di], ah
	mov di, offset1
	mov es:[di], ah

	mov di, mask4n5
	and di, 0000fh
	mov al, byte ptr LeftMaskTable[di]
	out dx, al
	mov di, offset4
	mov es:[di], ah
	mov di, offset5
	mov es:[di], ah

	mov al, 0ffh
	out dx, al
	mov al, ah
	inc di
	mov cx, offset1
	sub cx, di
	push cx
	shr cx, 1
	rep stosw
	adc cx, 0
	rep stosb

	mov di, offset4
	inc di
	pop cx
	shr cx, 1
	rep stosw
	adc cx, 0
	rep stosb

@@PlotYMajor:
	mov di, mask2n3
	and di, 0000fh
	mov al, byte ptr RightMaskTable[di]
	mov di, offset2
	cmp di, offset6
	jne @@PlotYMajorNontrivial
	mov di, mask6n7
	and di, 0000fh
	and al, byte ptr LeftMaskTable[di]
	out dx, al
	mov di, offset6
	mov es:[di], ah
	mov di, offset7
	mov es:[di], ah
	jmp @@ClimaxOfPlot
@@PlotYMajorNontrivial:
	out dx, al
	mov es:[di], ah
	mov di, offset3
	mov es:[di], ah

	mov di, mask6n7
	and di, 0000fh
	mov al, byte ptr LeftMaskTable[di]
	out dx, al
	mov di, offset6
	mov es:[di], ah
	mov di, offset7
	mov es:[di], ah

	mov al, 0ffh
	out dx, al
	mov al, ah

	inc di
	mov cx, offset3
	sub cx, di
	push cx
	shr cx, 1
	rep stosw
	adc cx, 0
	rep stosb

	mov di, offset6
	inc di
	pop cx
	shr cx, 1
	rep stosw
	adc cx, 0
	rep stosb

@@ClimaxOfPlot:
	pop cx
	jmp [jumpvector]


@@NoAdvance:
	mov al, byte ptr mask0n1
	mov di, offset0
	rol al, 1
	mov byte ptr mask0n1, al
	adc di, 0
	mov offset0, di
	mov di, offset1
	ror al, 1
	adc di, 0
	mov offset1, di

	mov al, byte ptr mask4n5
	mov di, offset4
	ror al, 1
	mov byte ptr mask4n5, al
	sbb di, 0
	mov offset4, di
	mov di, offset5
	rol al, 1
	sbb di, 0
	mov offset5, di

	mov al, byte ptr mask2n3
	mov di, offset2
	sub di, bx
	mov offset2, di
	mov di, offset3
	add di, bx
	mov offset3, di

	mov al, byte ptr mask6n7
	mov di, offset6
	sub di, bx
	mov offset6, di
	mov di, offset7
	add di, bx
	mov offset7, di

	jmp @@FilledCircleCalc

@@Advance:
	mov al, byte ptr mask0n1
	mov di, offset0
	rol al, 1
	mov byte ptr mask0n1, al
	adc di, bx
	mov offset0, di
	mov di, offset1
	ror al, 1
	adc di, 0
	sub di, bx
	mov offset1, di

	mov al, byte ptr mask2n3
	mov di, offset2
	ror al, 1
	mov byte ptr mask2n3, al
	sbb di, bx
	mov offset2, di
	mov di, offset3
	rol al, 1
	sbb di, 0
	add di, bx
	mov offset3, di

	mov al, byte ptr mask4n5
	mov di, offset4
	ror al, 1
	mov byte ptr mask4n5, al
	sbb di, 0
	add di, bx
	mov offset4, di
	mov di, offset5
	rol al, 1
	sbb di, bx
	mov offset5, di

	mov al, byte ptr mask6n7
	mov di, offset6
	rol al, 1
	mov byte ptr mask6n7, al
	adc di, 0
	sub di, bx
	mov offset6, di
	mov di, offset7
	ror al, 1
	adc di, bx
	mov offset7, di

@@FilledCircleCalc:
	add cx, 2
	mov di, error
	add di, cx
	inc di
	jl @@FilledCircleNoError
	cmp cx, si
	ja @@FleeFlyFlowFum
	sub si, 2
	sub di, si
	mov error, di
	mov jumpvector, offset @@Advance
	jmp @@PlotLines
@@FilledCircleNoError:
	mov error, di
	mov jumpvector, offset @@NoAdvance
	jmp @@PlotLines

@@FleeFlyFlowFum:
end;

procedure Triangle( X0, Y0, X1, Y1, X2, Y2, Color : integer);assembler;
var
   DX01, DY01, DX02, DY02, DX12, DY12,
   DP01, DP02, DP12, XA01, XA02, XA12 : word;
asm
	  push 	  di
	  push    es
	  push    ds
	  mov     ax,X0
	  mov     bx,Y0
	  mov     cx,X1
	  mov     dx,Y1
	  cmp     bx,dx
	  jl      @@triY0lY1
	  je      @@triY0eY1
	  xchg    ax,cx
	  xchg    bx,dx

  @@triY0lY1:
	  cmp     dx,Y2
	  jg      @@tria
	  jmp     @@trisorted
  @@tria:
	  xchg    cx,X2
	  xchg    dx,Y2
	  cmp     bx,dx
	  jge     @@trib
	  jmp     @@trisorted
  @@trib:
	  je      @@tribot
	  xchg    ax,cx
	  xchg    bx,dx
	  jmp     @@trisorted
  @@triY0eY1:
	  cmp     bx,Y2
	  jl      @@tribot
	  jg      @@tric
	  jmp     @@tridone
  @@tric:
	  xchg    ax,X2
	  xchg    bx,Y2
	  jmp     @@trisorted

  @@tribot:
	  cmp     ax,cx
	  jl      @@tribotsorted
	  jg      @@tribota
	  jmp     @@tridone
  @@tribota:
	  xchg    ax,cx
  @@tribotsorted:
	  cmp     bx,ClipBt
	  jle     @@triboty0ok
	  jmp     @@tridone
  @@triboty0ok:
	  mov     si,Y2
	  cmp     si,ClipTp
	  jge     @@triboty2ok
	  jmp     @@tridone
  @@triboty2ok:
	  mov     X0,ax
	  mov     Y0,bx
	  mov     X1,cx
	  mov     Y1,dx

	  mov     bx,Y2
	  sub     bx,Y0
	  mov     DY02,bx
	  mov     ax,X2
	  sub     ax,X0
	  mov     DX02,ax
	  mov     cx,ax
	  cwd
	  idiv    bx
	  cmp     cx,0
	  jge     @@tribot02
	  dec     ax
  @@tribot02:
	  mov     XA02,ax
	  imul    bx
	  sub     cx,ax
	  mov     DP02,cx

	  mov     bx,Y2
	  sub     bx,Y1
	  mov     DY12,bx
	  mov     ax,X2
	  sub     ax,X1
	  mov     DX12,ax
	  mov     cx,ax
	  cwd
	  idiv    bx
	  cmp     cx,0
	  jge     @@tribot12
	  dec     ax
  @@tribot12:
	  mov     XA12,ax
	  imul    bx
	  sub     cx,ax
	  mov     DP12,cx

	  mov     ax,0
	  mov     bx,0
	  mov     cx,Y0
	  mov     si,X0
	  mov     di,X1
	  dec     di
  @@tribotloop:
	  inc     cx

	  add     ax,DP02
	  jle     @@tribotshortl
	  sub     ax,DY02
	  inc     si
  @@tribotshortl:
	  add     si,XA02

	  add     bx,DP12
	  jle     @@tribotshortr
	  sub     bx,DY12
	  inc     di
  @@tribotshortr:
	  add     di,XA12

	  push    di
	  push    si
	  cmp     cx,Y2
	  jl      @@tribotloop

	  jmp     @@tridrawlines


  @@trisorted:
	  cmp     bx,ClipBt
	  jle     @@triy0ok
	  jmp     @@tridone
  @@triy0ok:
	  mov     si,Y2
	  cmp     si,ClipTp
	  jge     @@triy2ok
	  jmp     @@tridone
  @@triy2ok:
	  mov     X0,ax
	  mov     Y0,bx
	  mov     X1,cx
	  mov     Y1,dx

	  mov     bx,dx
	  sub     bx,Y0
	  mov     DY01,bx
	  mov     ax,X1
	  sub     ax,X0
	  mov     DX01,ax
	  mov     cx,ax
	  cwd
	  idiv    bx
	  cmp     cx,0
	  jge     @@tripsl01
	  dec     ax
  @@tripsl01:
	  mov     XA01,ax
	  imul    bx
	  sub     cx,ax
	  mov     DP01,cx

	  mov     bx,Y2
	  sub     bx,Y0
	  mov     DY02,bx
	  mov     ax,X2
	  sub     ax,X0
	  mov     DX02,ax
	  mov     cx,ax
	  cwd
	  idiv    bx
	  cmp     cx,0
	  jge     @@tripsl02
	  dec     ax
  @@tripsl02:
	  mov     XA02,ax
	  imul    bx
	  sub     cx,ax
	  mov     DP02,cx

	  mov     bx,Y2
	  sub     bx,Y1
	  jle     @@triconstcomputed
	  mov     DY12,bx
	  mov     ax,X2
	  sub     ax,X1
	  mov     DX12,ax
	  mov     cx,ax
	  cwd
	  idiv    bx
	  cmp     cx,0
	  jge     @@tripsl12
	  dec     ax
  @@tripsl12:
	  mov     XA12,ax
	  imul    bx
	  sub     cx,ax
	  mov     DP12,cx

  @@triconstcomputed:
	  mov     ax,DX01
	  imul    word ptr DY02
	  mov     bx,ax
	  mov     cx,dx

	  mov     ax,DX02
	  imul    word ptr DY01
	  cmp     cx,dx
	  jg      @@tript1rt
	  jl      @@tript1lt
	  cmp     bx,ax
	  ja      @@tript1rt
	  jb      @@tript1lt
	  jmp     @@tridone

  @@tript1lt:
	  mov     ax,0
	  mov     bx,0
	  mov     cx,Y0
	  mov     si,X0
	  mov     di,si
	  dec     si
  @@triltloop:
	  inc     cx

	  add     ax,DP02
	  jle     @@triltshortl
	  sub     ax,DY02
	  inc     si
  @@triltshortl:
	  add     si,XA02
	  add     bx,DP01
	  jle     @@triltshortr
	  sub     bx,DY01
	  inc     di
  @@triltshortr:
	  add     di,XA01
	  push    si
	  push    di
	  cmp     cx,Y1
	  jl      @@triltloop
	  jmp     @@trilbstart
  @@trilbloop:
	  inc     cx
	  add     ax,DP02
	  jle     @@trilbshortl
	  sub     ax,DY02
	  inc     si
  @@trilbshortl:
	  add     si,XA02

	  add     bx,DP12
	  jle     @@trilbshortr
	  sub     bx,DY12
	  inc     di
  @@trilbshortr:
	  add     di,XA12

	  push    si
	  push    di
  @@trilbstart:
	  cmp     cx,Y2
	  jl      @@trilbloop
	  jmp     @@tridrawlines

  @@tript1rt:
	  mov     ax,0
	  mov     bx,0
	  mov     cx,Y0
	  mov     si,X0
	  mov     di,si
	  dec     di
  @@trirtloop:
	  inc     cx

	  add     ax,DP02
	  jle     @@trirtshortl
	  sub     ax,DY02
	  inc     si
  @@trirtshortl:
	  add     si,XA02

	  add     bx,DP01
	  jle     @@trirtshortr
	  sub     bx,DY01
	  inc     di
  @@trirtshortr:
	  add     di,XA01

	  push    di
	  push    si
	  cmp     cx,Y1
	  jl      @@trirtloop
	  jmp     @@trirbstart

  @@trirbloop:
	  inc     cx
	  add     ax,DP02
	  jle     @@trirbshortl
	  sub     ax,DY02
	  inc     si
  @@trirbshortl:
	  add     si,XA02

	  add     bx,DP12
	  jle     @@trirbshorts
	  sub     bx,DY12
	  inc     di
  @@trirbshorts:
	  add     di,XA12

	  push    di
	  push    si
  @@trirbstart:
	  cmp     cx,Y2
	  jl      @@trirbloop

  @@tridrawlines:
	  mov     cx,VGA
	  mov     es,cx
	  mov     dx,SEQU_ADDR
	  mov     al,MAPMASK
	  out     dx,al

  @@lineloop:
	  pop     ax
	  pop     dx
	  cmp     ax,dx
	  jg      @@tridrawnext
	  mov     bx,Color
	  mov     cx,Y2
	  add     dx,2
          {xor     di,di}
	  mov     di,ActStart

          { here should be HLineClipR2 }
	  push    di
          {cmp cx , YBotClip
          jae @@invisible
          cmp cx,0
          jb @@invisible}

	  cmp     dx,ax
	  jl      @@Invisible

	  cmp     cx,ClipTp
	  jl      @@Invisible

	  cmp     cx,ClipBt
	  jg      @@Invisible

	  mov     di,ClipRt
	  {sal     di,2}
	  cmp     ax,di
	  jg      @@Invisible
	  cmp     dx,di
	  jle     @@ClipLeft
	  mov     dx,di

  @@ClipLeft:
	  mov     di,ClipLt
	  {sal     di,2}
	  cmp     dx,di
	  jl      @@Invisible
	  cmp     ax,di
	  jge     @@DoLine
	  mov     ax,di
	  jmp     @@DoLine

  @@Invisible:
	  pop     di
          jmp     @@Invisible2

  @@DoLine:
	  pop     di
	  xchg    cx,ax
	  mov     si,dx
	  mul     WidthBytes
	  mov     dx,si
	  add     ax,di
	  mov     di,cx
	  sar     di,2
	  add     di,ax
	  and     si,03h
	  mov     ah,byte ptr RightClipPlaneMask[si]
	  mov     si,cx
	  and     si,03h
	  mov     al,byte ptr LeftClipPlaneMask[si]
	  cmp     dx,cx
	  jle     @@Invisible2
	  xchg    cx,dx
	  dec     cx
	  and     dx,not 03h
	  sub     cx,dx
	  js      @@Invisible2
	  shr     cx,2
	  jnz     @@MasksSet
	  and     al,ah
  @@MasksSet:
	  mov     dl,bl
	  mov     bx,ax
	  mov     ah,dl
	  mov     dx,SEQU_ADDR+1
	  mov     al,bl
	  out     dx,al
	  mov     al,ah
	  stosb
	  dec     cx
	  js      @@Invisible2
	  jz      @@RightEnd
	  mov     al,0fh
	  out     dx,al
	  mov     al,ah
	  shr     cx,1
	  rep     stosw
	  adc     cx,cx
	  rep     stosb

  @@RightEnd:
	  mov     al,bh
	  out     dx,al
	  mov     al,ah
	  stosb
  @@Invisible2:
          { here should end HLineClipR2 }

  @@tridrawnext:
	  dec     word ptr Y2
	  dec     word ptr DY02
	  jnz     @@lineloop

  @@tridone:
	  pop     ds
	  pop 	  es
	  pop 	  di
  end;

function Clip(var p1,p2 : point2d) : boolean;
{ input      : P1 , P2 - the points that define the segment to be clipped
               (ussually called by Line/Fill routines)
  output     : the same P1 and P2
  remark     : transcribed from the C routine found in Video docs series,
               which is the implementation of Sutherland-Cohen algorithm
               the C original is (he)artwork
  date       : 30.10.1996, by Karg;original comments                     }
Type
    OutCodeType = record
                code0,code1,code2,code3 : boolean;
                outcodes                : byte;
                end;

Var
   ocu1,ocu2,ocuaux : OutCodeType;
   Inside           : boolean;
   Outside          : boolean;
   temp             : Point2D;

procedure SetOutCodes(var U : OutCodeType ; P : Point2D);
begin
 U.code0 := (P.x<ClipLt);
 U.code1 := (P.y<ClipTp);
 U.code2 := (P.x>ClipRt);
 U.code3 := (P.y>ClipBt);
 U.outcodes := 0;
 {Feel like coding horror !?}
 U.outcodes := (((((((U.outcodes or byte(U.code3)) shl 1) or byte(U.code2)) shl 1) or byte(U.code1)) shl 1) or byte(U.code0));
end;

begin
 {init 4-bit codes}
 SetOutCodes(ocu1,P1);
 SetOutCodes(ocu2,P2);
 Inside  := (ocu1.outcodes or ocu2.outcodes) = 0;
 OutSide := (ocu1.outcodes and ocu2.outcodes ) <> 0;

 while (not Inside) and (not Outside) do
       begin
        if ocu1.outcodes = 0
           then begin           { swap endpoints if necessary so that P1 to}
                 temp := P1;    { be clipped                               }
                 P1   := P2;
                 P2   := temp;
                 ocuaux := ocu1;
                 ocu1   := ocu2;
                 ocu2   := ocuaux;
                end;
        if ocu1.code0 then begin                 { clip left }
	   P1.y := P1.y+round((P2.y-P1.y)*(ClipLt-P1.x) div (P2.x-P1.x));
	   P1.x := ClipLt;
          end
          else if ocu1.code1 then begin            { clip above }
	       P1.x := P1.x+round((P2.x-P1.x)*(ClipTp-P1.y) div (P2.y-P1.y));
	       P1.y := ClipTp;
	      end
	  else if ocu1.code2 then begin	           { clip right }
	       P1.y := P1.y+round((P2.y-P1.y)*(ClipRt-P1.x) div (P2.x-P1.x));
	       P1.x := ClipRt;
              end
	  else if ocu1.code3 then begin		   { clip below }
	       P1.x := P1.x+round((P2.x-P1.x)*(ClipBt-P1.y) div (P2.y-P1.y));
	       P1.y := ClipBt;
	      end;
        SetOutCodes(ocu1,P1); { update for P1 }
        Inside  := (ocu1.outcodes or ocu2.outcodes ) = 0;    { update 4-bit codes}
        OutSide := (ocu1.outcodes and ocu2.outcodes ) <> 0;
       end;
 Clip := Inside;
end;

procedure Line_X(x1,y1,x2,y2:integer;color:byte);
var i, deltax, deltay, numpixels,
    d, dinc1, dinc2,
    x, xinc1, xinc2,
    y, yinc1, yinc2 : integer;
    screen : word;
    dxtemp,page   : word;
    page4 : byte;
    screeninc1, screeninc2 : integer;
    p1,p2 : point2d;
begin

  with p1 do begin x:=x1;y:=y1;end;
  with p2 do begin x:=x2;y:=y2;end;
  if not Clip(p1,p2) then exit;
  x1:=p1.x;y1:=p1.y;x2:=p2.x;y2:=p2.y;
  { Calculate deltax and deltay for initialisation }
  deltax := abs(x2 - x1);
  deltay := abs(y2 - y1);

  { Initialize all vars based on which is the independent variable }
  if deltax >= deltay then
    begin

      { x is independent variable }
      numpixels := deltax + 1;
      d := (2 * deltay) - deltax;
      dinc1 := deltay Shl 1;
      dinc2 := (deltay - deltax) shl 1;
      xinc1 := 1;
      xinc2 := 1;
      yinc1 := 0;
      yinc2 := 1;
    end
  else
    begin

      { y is independent variable }
      numpixels := deltay + 1;
      d := (2 * deltax) - deltay;
      dinc1 := deltax Shl 1;
      dinc2 := (deltax - deltay) shl 1;
      xinc1 := 0;
      xinc2 := 1;
      yinc1 := 1;
      yinc2 := 1;
    end;

  { Make sure x and y move in the right directions }
  if x1 > x2 then
    begin
      xinc1 := - xinc1;
      xinc2 := - xinc2;
    end;
  if y1 > y2 then
    begin
      yinc1 := - yinc1;
      yinc2 := - yinc2;
    end;

  { Start drawing at <x1, y1> }
  screen := word(y1) * 80 +ActStart;
  screeninc1 := yinc1 * 80;
  screeninc2 := yinc2 * 80;

  { Draw the pixels }
  asm

    { Use as many registers as are available }
    mov dx,VGA
    mov es,dx
    mov di, screen
    mov dx, d
    mov ah, color
    {mov cx, numpixels}
    mov bx, dinc1
    mov cx, x1

    @bres1:

    { Draw the current pixel and compare the decision variable to 0 }
    { Set page - to be optimized !}
    mov page, cx
    mov dxtemp,dx
    and cx, 3
    mov al,1
    {inc cx
   @x:shl al,1
    loop @x
    shr al,1}
    shl al,cl
    mov page4,al
    mov al,2
    mov dx, 3c4h
    out dx,al
    mov al,page4
    inc dx
    out dx,al
    {?}
    mov cx,page
    shr cx,2
    mov si,di
    add di,cx
    mov es:[di], ah
    mov cx,page
    mov di,si
    mov dx,dxtemp

    cmp dx, 0
    jnl @bres2

    { D < 0 }
    add dx, bx { bx = dinc1 }
    add di, screeninc1
    add cx, xinc1
    jmp @bres3

    @bres2:

    { D >= 0 }
    add dx, dinc2
    add di, screeninc2
    add cx, xinc2
    @bres3:
    dec numpixels
    jnz @bres1
  end;

end;

Function GetPixel( x,y :word ) : word; assembler;
asm
	mov  ax,WidthBytes
	mul  Y
	mov  bx,X
	shr  bx,1
	shr  bx,1
	add  bx,ax
	add  bx,ActStart
	mov  ax,VGA
	mov  es,ax

	mov  ah,byte ptr X
	and  ah,011b
	mov  al,READMAP
	mov  dx,GCINDEX
	out  dx,ax
	mov  al,es:[bx]
	sub  ah,ah
end;


procedure TextMode;assembler;
asm
  mov ax,0003h
  int 10h
end;
