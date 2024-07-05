PROGRAM
        World;
USES
    DOS;
{$M 65520,0,655360}
{ maximum 16k - Pascal limitations }
{$R-}

{ external scale defs }
CONST
     ClipLT   : word = 5;
     ClipRT   : word = 315;
     ClipTP   : word = 30;
     ClipBT   : word = 210;
     OrgX            = 160;
     OrgY            = 120;

{ video defs }
CONST
      sequ_addr      = $3c4;
      crtc_addr      = $3d4;
      input_status_0 = $3c2;
      input_status_1 = $3da;
      vga            = $a000;

TYPE
    Pal = array[0..255,1..3] of byte;

VAR
    width,height  : word;
    widthBytes    : word;
    vistart       : word;
    actstart      : word;
    workpal       : ^Pal;
    page          : integer;
    pseg,pofs     : integer;
    fseg,fofs     : integer;

TYPE
    point2d = record
            x,y : integer;
            end;
    point3d = record
            x,y,z : integer;
            end;
    face    = record
            p1,p2,p3,p4 : byte;
            color       : byte
            end;
    plane   = record
            p1,p2,p3,p4 : byte;
            n,np        : point3d;
            eyed        : longint;
            color       : byte
            end;
    move   = record
           dest   : point3d;
           lookto : point3d;
           end;

    trigtable = array[0..359] of integer;
VAR
   i,j,k,temp : longint;
   Poly       : array[0..239,1..2] of integer;
   sint,cost  : trigtable;
   pro        : array[1..150] of point2d;
   points     : array[1..150] of point3d;
   rot        : array[1..150] of point3d;
   obj3d      : array[1..100] of plane;
   movement   : array[1..20] of move;
   center     : point3d;
   head       : point3d;{ direction to move }
   view       : point3d;{ direction to look }
   headang    : point3d;
   viewang    : point3d;
   olastindex : integer;
   plastindex : integer;
   vi,vj,vk   : point3d;
   dvi,dvj,dvk: point3d;
   ovi,ovj,ovk: point3d;
   a1,a2,a3,modul : single;
   maxmove    : integer;
   crtmove    : integer;
   Invert     : array[1..3,1..3] of longint;

procedure setvisiblestart(offset : integer);
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

procedure setactivestart(offset : integer);
begin
 actstart := offset;
end;

procedure setactivepage(page : integer);
begin
 setactivestart(page * widthbytes * height);
end;

procedure setvisiblepage(page : integer);
begin
 setvisiblestart(page * widthbytes * height);
end;

procedure putpixel_x(x,y : integer;color : byte);
 var
    dummy : byte;
 begin
	dummy := 1 shl (x and 3);
	asm
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
	end;
 end;

procedure modex;
begin
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
 height     := 200;
 width      := 320;
 widthbytes := 80;
 actstart   := 0;
 vistart    := 0;
end;

procedure waitretrace;assembler;
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

procedure setpal;
var pseg1,pofs1 : word;
 begin
   pseg1 := pseg;
   pofs1 := pofs;
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

procedure FadeOut(speed:byte);
var i,j:integer;
begin
for i:=1 to 64 div speed do
    begin
    for j:=0 to 255 do
        begin
        if workpal^[j,1]>=speed then dec(workpal^[j,1],speed);
        if workpal^[j,2]>=speed then dec(workpal^[j,2],speed);
        if workpal^[j,3]>=speed then dec(workpal^[j,3],speed);
        end;
    for j:=1 to 1024 do asm nop end;
    waitretrace;
    Setpal;
    end;
end;

procedure totextmode;assembler;
 asm
   mov ax,0003h
   int 10h
 end;

procedure set320x240x256_X;
begin
  modex;
  port[$3c2]:=$e3;
  portw[$3d4]:=$2c11;
  portw[$3d4]:=$0d06;
  portw[$3d4]:=$3e07;
  portw[$3d4]:=$ea10;
  portw[$3d4]:=$ac11;
  portw[$3d4]:=$df12;
  portw[$3d4]:=$e715;
  portw[$3d4]:=$0616;
  height := 240;
end;

procedure genpal;{a standard pallete}
begin
asm
 mov es,pseg
 mov di,pofs
 mov cx,384
 xor ax,ax
 rep stosw

 mov di,pofs
 xor al,al
 mov cx,64
 @l1:
      stosb
      inc di
      inc di
      inc al
      loop @l1
 xor al,al
 mov di,pofs
 add di,193
 mov cx,64
 @l2:
      stosb
      inc di
      stosb
      {inc di}
      inc al
      loop @l2
 xor al,al
 mov di,pofs
 add di,386
 mov cx,64
 @l3:
      stosb
      inc di
      inc di
      inc al
      loop @l3
 mov di,pofs
 add di,576
 xor al,al
 mov cx,64
 @l4:
      stosb
      stosb
      stosb
      inc al
      loop @l4
 end;
end;

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
   nr               : integer;

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
 nr := 0;

 while (not Inside) and (not Outside) and (nr<5) do
       begin
        inc(nr);
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
	       P1.y := P1.x+round((P2.y-P1.y)*(ClipRt-P1.x) div (P2.x-P1.x));
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
  x1:=p1.x;y1:=p1.y;
  x2:=p2.x;y2:=p2.y;

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
  screen := word(y1) * 80 +actstart;
  screeninc1 := yinc1 * 80;
  screeninc2 := yinc2 * 80;

  { Draw the pixels }
  asm

    { Use as many registers as are available }
    mov dx,$a000
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

Procedure DrawPoly(x1,y1,x2,y2,x3,y3,x4,y4:integer;color:byte);
  { This draw a polygon with 4 points at x1,y1 , x2,y2 , x3,y3 , x4,y4
    in color col }
var miny,maxy:integer;
    loop1:integer;

Procedure doside (x1,y1,x2,y2:integer);
  { This scans the side of a polygon and updates the poly variable }
VAR temp:integer;
    x,xinc:integer;
    loop1:integer;
    p1,p2 : point2d;
BEGIN
  {with p1 do begin x:=x1;y:=y1;end;
  with p2 do begin x:=x2;y:=y2;end;
  if not Clip(p1,p2) then exit;
  x1:=p1.x;y1:=p1.y;
  x2:=p2.x;y2:=p2.y;}

  if y1=y2 then inc(y1);
  if y2<y1 then BEGIN
    temp:=y2;
    y2:=y1;
    y1:=temp;
    temp:=x2;
    x2:=x1;
    x1:=temp;
  END;
  xinc:=((x2-x1) shl 7) div (y2-y1);
  x:=x1 shl 7;
  for loop1:=y1 to y2 do BEGIN
    if (loop1>cliptp) and (loop1<clipbt) then BEGIN
      if (x shr 7<poly[loop1,1]) then poly[loop1,1]:=x shr 7;
      if (x shr 7>poly[loop1,2]) then poly[loop1,2]:=x shr 7;
    END;
    x:=x+xinc;
  END;
END;

begin
  if (x1=MaxInt) or (x2=MaxInt) or (x3=MaxInt) or (x4=MaxInt) and
     (y1=MaxInt) or (y2=MaxInt) or (y3=MaxInt) or (y4=MaxInt) then exit;
  miny := seg(poly);
  asm
    push  ds
    mov   dx,miny
    mov   ds,dx
    mov   si,offset poly
    mov   cx,240
@Loop1:
    mov   ax,32766
    mov   ds:[si],ax
    inc   si
    inc   si
    mov   ax,-32767
    mov   ds:[si],ax
    inc   si
    inc   si
    loop  @loop1
    pop   ds
  end;     { Setting the minx and maxx values to extremes }
  miny:=y1;
  maxy:=y1;

  if y2<miny then miny:=y2;
  if y3<miny then miny:=y3;
  if y4<miny then miny:=y4;
  if y2>maxy then maxy:=y2;
  if y3>maxy then maxy:=y3;
  if y4>maxy then maxy:=y4;
  if miny<cliptp then miny:=cliptp;
  if maxy>clipbt then maxy:=clipbt;
  if (miny>239) or (maxy<0) then exit;

  Doside (x1,y1,x2,y2);
  Doside (x2,y2,x3,y3);
  Doside (x3,y3,x4,y4);
  Doside (x4,y4,x1,y1);
  Doside (x3,y3,x1,y1);
  Doside (x4,y4,x2,y2);

  for loop1:= miny to maxy do
    if (poly[loop1,1]<>32766) and (poly[loop1,2]<>-32767) then
    line_x (poly[loop1,1],loop1,poly[loop1,2],loop1,color);
end;


procedure RotatePoint(indexs,indexd : integer;x,y,z : integer);
VAR
   a,b,c : integer;
BEGIN
 x:=x mod 360;y:=y mod 360;z:=z mod 360;

 b:=cost[y];
 c:=points[indexs].x-center.x;
 asm
   mov   ax,b
   imul  c
   sal   ax,1
   rcl   dx,1
   sal   ax,1
   rcl   dx,1
   mov   a,dx
 end;
 b:=sint[y];
 c:=points[indexs].z-center.z;
 asm
   mov   ax,b
   imul  c
   sal   ax,1
   rcl   dx,1
   sal   ax,1
   rcl   dx,1
   add   a,dx
 end;
 rot[indexd].x:=a;
 rot[indexd].y:=points[indexs].y-center.y;
 b:=-sint[y];
 c:=points[indexs].x-center.x;
 asm
   mov   ax,b
   imul  c
   sal   ax,1
   rcl   dx,1
   sal   ax,1
   rcl   dx,1
   mov   a,dx
 end;
 b:=cost[y];
 c:=points[indexs].z-center.z;
 asm
   mov   ax,b
   imul  c
   sal   ax,1
   rcl   dx,1
   sal   ax,1
   rcl   dx,1
   add   a,dx
 end;
 rot[indexd].z:=a+center.z;

 if x<>0 then BEGIN
   b:=cost[x];
   c:=rot[indexd].y-center.y;
   asm
     mov   ax,b
     imul  c
     sal   ax,1
     rcl   dx,1
     sal   ax,1
     rcl   dx,1
     mov   a,dx
   end;
   b:=sint[x];
   c:=rot[indexd].z-center.z;
   asm
     mov   ax,b
     imul  c
     sal   ax,1
     rcl   dx,1
     sal   ax,1
     rcl   dx,1
     sub   a,dx
   end;
   b:=sint[x];
   c:=rot[indexd].y-center.y;
   rot[indexd].y:=a-center.y;
   asm
     mov   ax,b
     imul  c
     sal   ax,1
     rcl   dx,1
     sal   ax,1
     rcl   dx,1
     mov   a,dx
   end;
   b:=cost[x];
   c:=rot[indexd].z-center.z;
   asm
     mov   ax,b
     imul  c
     sal   ax,1
     rcl   dx,1
     sal   ax,1
     rcl   dx,1
     add   a,dx
   end;
   rot[indexd].z:=a+center.z;
 END;

 if z<>0 then BEGIN
   b:=cost[z];
   c:=rot[indexd].x-center.x;
   asm
     mov   ax,b
     imul  c
     sal   ax,1
     rcl   dx,1
     sal   ax,1
     rcl   dx,1
     mov   a,dx
   end;
   b:=sint[z];
   c:=rot[indexd].y-center.y;
   asm
     mov   ax,b
     imul  c
     sal   ax,1
     rcl   dx,1
     sal   ax,1
     rcl   dx,1
     sub   a,dx
   end;
   b:=sint[z];
   c:=rot[indexd].x-center.x;
   rot[indexd].x:=a+center.x;
   asm
     mov   ax,b
     imul  c
     sal   ax,1
     rcl   dx,1
     sal   ax,1
     rcl   dx,1
     mov   a,dx
   end;
   b:=cost[z];
   c:=rot[indexd].y-center.y;
   asm
     mov   ax,b
     imul  c
     sal   ax,1
     rcl   dx,1
     sal   ax,1
     rcl   dx,1
     add   a,dx
   end;
   rot[indexd].y:=a-center.y;
 END;
END;{end procedure rotate point}

PROCEDURE DepthSort(fi,li : integer);
 VAR i,j   : integer;
     temp  : Plane;
     exchg : longint;
     eyed  : array[1..100] of longint;

procedure Kwik (first,last:integer);

var
    i,j   : integer;
    mid   : integer;

begin
 i:=first;
 j:=last;
 mid:=Obj3d[(i+j) div 2].EyeD;
 repeat
  while Obj3d[i].EyeD<mid do inc(i);
  while Obj3d[j].EyeD>mid do dec(j);
  if i<=j
     then begin
          temp     := Obj3d[i];
          Obj3d[i] := Obj3d[j];
          Obj3d[j] := temp;
          dec(j);
          inc(i);
          end;
 until i>j;
 if first<j then Kwik(first,j);
 if last>i  then Kwik(i,last);
end;

BEGIN
 for i:=fi to li do
     with obj3d[i] do
     EyeD:= round(sqrt(abs(SQR((rot[P1].x+rot[P2].x+rot[P3].x+rot[P4].x) div 4-head.x)+
               SQR((rot[P1].y+rot[P2].y+rot[P3].y+rot[P4].y) div 4-head.y)+
               SQR((rot[P1].z+rot[P2].z+rot[P3].z+rot[P4].z) div 4-head.z))));

 Kwik(fi,li);
END;

procedure Inverter;
BEGIN
 Invert[1,1]:=vj.y*vk.z-vj.z*vk.y;
 Invert[1,2]:=vi.z*vk.y-vi.y*vk.z;
 Invert[1,3]:=vi.y*vj.z-vi.z*vj.y;
 Invert[2,1]:=vj.z*vk.x-vj.x*vk.z;
 Invert[2,2]:=vi.x*vk.z-vi.z*vk.x;
 Invert[2,3]:=vj.x*vi.z-vi.x*vj.z;
 Invert[3,1]:=vj.x*vk.y-vk.x*vj.y;
 Invert[3,2]:=vk.x*vi.y-vi.x*vk.y;
 Invert[3,3]:=vi.x*vj.y-vi.y*vj.x;
END;

procedure ProLook(fi,li : integer);
var XPro,YPro,ZPro : longint;
    fpr : real;
    i : integer;
    difx,dify,difz,cdifx,cdify,cdifz,num : longint;
BEGIN
 for i:=fi to li do
            begin
             cdifx:=head.x+Rot[i].x;
             cdify:=head.y+Rot[i].y;
             cdifz:=head.z+Rot[i].z;

             XPro:=
                    cdifx*Invert[1,1]+
                    cdify*Invert[2,1]+
                    cdifz*Invert[3,1];
             YPro:=
                    cdifx*Invert[1,2]+
                    cdify*Invert[2,2]+
                    cdifz*Invert[3,2];
             ZPro:=
                    cdifx*Invert[1,3]+
                    cdify*Invert[2,3]+
                    cdifz*Invert[3,3];

             if YPro>0
                then begin
                      Pro[i].x:=(XPro shl 7) div YPro+orgx;
                      Pro[i].y:=(ZPro shl 7) div YPro+orgy;
                     end
                else begin
                      Pro[i].x:=MaxInt;
                      Pro[i].y:=MaxInt;
                     end;

            end;
END;

procedure GenCube(xc,yc,zc,xl,yl,zl : integer;fcolor : byte);
begin
 with points[plastindex+1] do begin x:=xc+xl div 2;y:=yc+yl div 2;z:=zc+zl div 2;end;
 with points[plastindex+2] do begin x:=xc-xl div 2;y:=yc+yl div 2;z:=zc+zl div 2;end;
 with points[plastindex+3] do begin x:=xc+xl div 2;y:=yc-yl div 2;z:=zc+zl div 2;end;
 with points[plastindex+4] do begin x:=xc+xl div 2;y:=yc+yl div 2;z:=zc-zl div 2;end;
 with points[plastindex+5] do begin x:=xc-xl div 2;y:=yc-yl div 2;z:=zc+zl div 2;end;
 with points[plastindex+6] do begin x:=xc+xl div 2;y:=yc-yl div 2;z:=zc-zl div 2;end;
 with points[plastindex+7] do begin x:=xc-xl div 2;y:=yc+yl div 2;z:=zc-zl div 2;end;
 with points[plastindex+8] do begin x:=xc-xl div 2;y:=yc-yl div 2;z:=zc-zl div 2;end;
 with obj3d[olastindex+1] do
      begin
       p1:=plastindex+1;p2:=plastindex+2;p3:=plastindex+4;p4:=plastindex+7;
       with n do begin x:=0;y:=16;z:=0;end;
       color := fcolor;
       with np do begin x:=0;y:=yl div 2;z:=0;end;
      end;
 with obj3d[olastindex+2] do
      begin
       p1:=plastindex+1;p2:=plastindex+4;p3:=plastindex+3;p4:=plastindex+6;
       with n do begin x:=16;y:=0;z:=0;end;
       color := fcolor-3;
       with np do begin y:=0;x:=xl div 2;z:=0;end;
      end;
 with obj3d[olastindex+3] do
      begin
       p1:=plastindex+3;p2:=plastindex+5;p3:=plastindex+6;p4:=plastindex+8;
       with n do begin x:=0;y:=-16;z:=0;end;
       color := fcolor+3;
       with np do begin x:=0;y:=-yl div 2;z:=0;end;
      end;
 with obj3d[olastindex+4] do
      begin
       p1:=plastindex+1;p2:=plastindex+2;p3:=plastindex+3;p4:=plastindex+5;
       with n do begin x:=0;y:=0;z:=16;end;
       color := fcolor;
       with np do begin x:=0;z:=zl div 2;y:=0;end;
      end;
 with obj3d[olastindex+5] do
      begin
       p1:=plastindex+2;p2:=plastindex+5;p3:=plastindex+7;p4:=plastindex+8;
       with n do begin x:=-16;y:=0;z:=0;end;
       color := fcolor-3;
       with np do begin z:=0;x:=-xl div 2;y:=0;end;
      end;
 with obj3d[olastindex+6] do
      begin
       p1:=plastindex+4;p2:=plastindex+6;p3:=plastindex+7;p4:=plastindex+8;
       with n do begin x:=0;y:=0;z:=-16;end;
       color := fcolor+3;
       with np do begin x:=0;z:=-zl div 2;y:=0;end;
      end;
 inc(olastindex,6);inc(plastindex,8);
end;

BEGIN
 set320x240x256_X;
 new(WorkPal);
 pseg := seg(WorkPal^);
 pofs := ofs(WorkPal^);
 genpal;
 setpal;
 olastindex := 0;plastindex := 0;
 GenCube(70,50,-50,40,40,40,60);
 GenCube(-60,5,-50,60,60,40,124);

 with vi do begin x:=16;y:=0;z:=0;end;
 with vj do begin x:=0;y:=16;z:=0;end;
 with vk do begin x:=0;y:=0;z:=16;end;
 ovi := vi;ovj := vj;ovk := vk;

 with head do begin x:=0;y:=90;z:=0;end;
 page := 1;setactivepage(1);setvisiblepage(0);
 with viewang do begin x:=0;y:=0;z:=0;end;
 maxmove := 4;crtmove := 1;
 with movement[1] do with dest do begin x:=0;y:=0;z:=50;end;
 with movement[2] do with dest do begin x:=10;y:=200;z:=50;end;
 with movement[3] do with dest do begin x:=100;y:=0;z:=0;end;
 with movement[4] do with dest do begin x:=0;y:=170;z:=20;end;

 repeat
  setactivepage(page);
  cls(page);

  {vi:=ovi;vj:=ovj;vk:=ovk;
  if headto.x<0 then headto.x:=360-headto.x;
  if headto.y<0 then headto.y:=360-headto.y;
  if headto.z<0 then headto.z:=360-headto.z;
  with headto do begin x:=x mod 360;y:=y mod 360;z:=z mod 360;end;
  dummyang:=nework^.RealAngleVPV(dummypoint,vk,look);}

  a1:=(-head.x+movement[crtmove].dest.x);
  a2:=(-head.y+movement[crtmove].dest.y);
  a3:=(-head.z+movement[crtmove].dest.z);
  modul := sqrt(abs(a1*a1+a2*a2+a3*a3));
  if modul<>0
     then begin
           dvk.x := round(16*a1/modul);
           dvk.y := round(16*a2/modul);
           dvk.z := round(16*a3/modul);
          end
     else dvk := ovk;

  head.x:=head.x+2*dvk.x div 16;
  head.y:=head.y+2*dvk.y div 16;
  head.z:=head.z+2*dvk.z div 16;

  if (head.x>movement[crtmove].dest.x-4) and (head.x<movement[crtmove].dest.x+4) and
     (head.y>movement[crtmove].dest.y-4) and (head.y<movement[crtmove].dest.y+4) and
     (head.z>movement[crtmove].dest.z-4) and (head.z<movement[crtmove].dest.z+4)
     then begin
           inc(crtmove);
           if crtmove>maxmove then crtmove:=-1;
          end;

  system.move(points,rot,sizeof(rot));
  DepthSort(1,olastindex);
  Inverter;
  ProLook(1,plastindex);
  for i:=1 to olastindex do
      DrawPoly(
      Pro[Obj3d[i].p1].x,Pro[Obj3d[i].p1].y,
      Pro[Obj3d[i].p2].x,Pro[Obj3d[i].p2].y,
      Pro[Obj3d[i].p3].x,Pro[Obj3d[i].p3].y,
      Pro[Obj3d[i].p4].x,Pro[Obj3d[i].p4].y,
      Obj3d[i].color);
  setvisiblepage(page);
  page := (page+1) mod 2;
 until port[$60]=1;

END.