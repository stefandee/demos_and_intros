PROGRAM
        Demo;
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

{$L xscale1.obj}
{$F+}
procedure XSCALE1 ( DestX:WORD;DestY:WORD;DestWidth:WORD;DestHeight:WORD;SourceWidth:WORD;SourceHeight:WORD;
                    Start:Word;Bitmap:pointer);external;
{$F-}

{ video defs }
CONST
      sequ_addr      = $3c4;
      crtc_addr      = $3d4;
      input_status_0 = $3c2;
      input_status_1 = $3da;
      vga       = $a000;

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

{ fractal defs }
TYPE
    ftab = array[1..160,1..160] of byte;
VAR
    crl,crh,cih,cil,ci,
    cr,zr,zi,newzr,newzi : single;
    maxiter              : integer;
    fracwidth,fracheight : integer;
    xsize,ysize          : single;
    x,y,z                : integer;
    aux1,aux2            : single;
    fractal              : ^ftab;

{ background defs }
CONST
     tinc1  : byte = 2;
     tinc2  : byte = 3;
     tinc3  : byte = 3;
     tinc4  : byte = 2;
TYPE
    PBGnd = ^TBGnd;
    TBGnd = RECORD
               angle : integer;
               newxl,newyl : integer;
               wherex,wherey : integer;
               minxl,maxxl,minyl,maxyl : integer;
               dirx,diry : integer;
               end;
    PBack   = ^TBack;
    TBack   = Array[1..10,1..10] of PBGnd;

VAR
   CurentXl,CurentYl : integer;
   BackGround1 : PBack;
   mov1,mov2,mov3,mov4 : byte;  { current positions }
   tmov1,tmov2,tmov3,tmov4:byte; { Temporary variables, so we dont destroy}
   inc1,inc2,inc3,inc4 : byte;

{ demo defs }
CONST
     theend : string[80] = 'ICED(The Wasted Years) by Karg,feb-mar 1997'#13#10'E-mail : pp709@cs.utt.ro$';
     Precision           = 100;
     Radius              = 50;
     EyeDist             = 96;
     Greet : string      =
     'Wellcome to ICED, PC user. This demo is dedicated to Julie and to the magic hours spend with her on IRC.'+
     ' Karg also greets Steli, Alex, John, Adi&Paul&Traian Pop and everybody that helped me the last two years             ';
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
            color       : byte
            end;
    trigtable = array[0..359] of integer;
    sphere    = array[0..Precision,0..Precision] of point2d;
    colors    = array[0..Precision,0..Precision] of byte;
VAR
   i,j,k,l,temp : longint;
   phase      : integer;
   sysaction  : integer;
   Poly       : array[0..199,1..2] of integer;
   sint,cost  : trigtable;
   st         : ^sphere;
   ct         : ^colors;
   curentchar : array[1..14,1..8] of byte;
   cseg,cofs  : word;
   ccol       : word;
   curchar    : word;
   centerx    : integer;
   dirx       : integer;
   centery    : integer;
   diry       : integer;
   tempang    : longint;
   tempdist   : longint;
   dodraw     : boolean;
   Int1CSave  : procedure;
   ang        : point3d;
   center     : point3d;
   light      : point3d;
   look       : point3d;
   pro        : array[1..100] of point2d;
   points     : array[1..150] of point3d;
   rot        : array[1..150] of point3d;
   obj3d      : array[1..100] of plane;

{ RayTracing...}
CONST
      eye  = -100;
TYPE
    frame = array[-80..80,-80..80] of byte;
    pframe = ^frame;
VAR
    u,lastx,lasty,lastz : single;
    lastcolor   : byte;
    caze        : byte;
    s1,s2       : point3d;
    reclevel    : byte;
    x1,x2,y1,y2,z1,z2 : single;
    cx2,cy2,cz2 : integer;
    cx1,cy1,cz1 : integer;
    rad : single;
    dir2,dir1   : integer;
    rlight      : point3d;
    crtframe    : byte;
    rayrepeat   : byte;
    frames      : array[1..18] of pframe;

{$L rosepal.obj}
procedure rosepal;external;
{$L rose.obj}
procedure rose;external;

{ the rose }
TYPE
    explosion = record
              vx0,vy0,vy : single;
              x,y        : integer;
              time       : single;
              color      : byte;
              useme      : boolean;
              end;
VAR
   rseg,rofs    : word;
   newrose      : pointer;
   rpseg,rpofs  : word;
   newrosepal   : ^Pal;
   maxindex     : integer;
   rosepixel    : array[1..2000] of ^explosion;
   nopixels     : boolean;
   ypart,xpart  : integer;

{$F+,S-,W-}
procedure TimerHandler; interrupt;
  begin
   dodraw := true;
   with ang do begin x:=(x+5) mod 360;y:=(y+4) mod 360;z:=(z+1) mod 360;end;
   inline ($9C); { PUSHF -- Push flags }
   Int1CSave;
  end;
{$F-,S+}

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
 {portw[CRTC_ADDR]:= $0C;               {/* set high byte */}
 {portw[CRTC_ADDR+1]:=viStart shr 8;
 portw[CRTC_ADDR]:= $0D;               {/* set low byte */}
 {portw[CRTC_ADDR+1]:=viStart and $ff;}
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
 { /* Set the unchained version of mode 13h: */}

  modex;

 { /* Modify the vertical sync polarity bits in the Misc. Output
     Register to achieve square aspect ratio: */}

  port[$3c2]:=$e3;
 { outportb(0x3C2, 0xE3);}

  {/* Modify the vertical timing registers to reflect the increased
     vertical resolution, and to center the image as good as
     possible: */}

  {outport(0x3D4, 0x2C11);         /* turn off write protect */}
  portw[$3d4]:=$2c11;
  {outport(0x3D4, 0x0D06);         /* vertical total */}
  portw[$3d4]:=$0d06;
  {outport(0x3D4, 0x3E07);         /* overflow register */}
  portw[$3d4]:=$3e07;
  {outport(0x3D4, 0xEA10);         /* vertical retrace start */}
  portw[$3d4]:=$ea10;
  {outport(0x3D4, 0xAC11);         /* vertical retrace end AND wr.prot */}
  portw[$3d4]:=$ac11;
  {outport(0x3D4, 0xDF12);         /* vertical display enable end */}
  portw[$3d4]:=$df12;
  {outport(0x3D4, 0xE715);         /* start vertical blanking */}
  portw[$3d4]:=$e715;
  {outport(0x3D4, 0x0616);         /* end vertical blanking */}
  portw[$3d4]:=$0616;
  {/* Update mode info, so future operations are aware of the
     resolution: */}
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

procedure Triangle(x1,y1,x2,y2,x3,y3 : integer;color,depth : byte);
begin
 if depth<6
    then begin
          line_x((x1+x2) div 2,(y1+y2) div 2,(x2+x3) div 2,(y2+y3) div 2,color-depth*2);
          line_x((x1+x2) div 2,(y1+y2) div 2,(x1+x3) div 2,(y1+y3) div 2,color-depth*2);
          line_x((x2+x3) div 2,(y2+y3) div 2,(x1+x3) div 2,(y1+y3) div 2,color-depth*2);
          triangle((x3+x1) div 2,(y3+y1) div 2,(x1+x2) div 2,(y1+y2) div 2,x1,y1,color,depth+1);
          triangle((x3+x2) div 2,(y3+y2) div 2,(x1+x3) div 2,(y1+y3) div 2,x3,y3,color,depth+1);
          triangle((x3+x2) div 2,(y3+y2) div 2,(x1+x2) div 2,(y1+y2) div 2,x2,y2,color,depth+1);
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
  with p1 do begin x:=x1;y:=y1;end;
  with p2 do begin x:=x2;y:=y2;end;
  if not Clip(p1,p2) then exit;
  x1:=p1.x;y1:=p1.y;x2:=p2.x;y2:=p2.y;

  if y1=y2 then exit;
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
    if (loop1>cliptp-1) and (loop1<clipbt+1) then BEGIN
      if (x shr 7<poly[loop1,1]) then poly[loop1,1]:=x shr 7;
      if (x shr 7>poly[loop1,2]) then poly[loop1,2]:=x shr 7;
    END;
    x:=x+xinc;
  END;
END;

begin
  miny := seg(poly);
  asm
    push  ds
    mov   dx,miny
    mov   ds,dx
    mov   si,offset poly
    mov   cx,200
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
    if (poly[loop1,1]<>32766) or (poly[loop1,2]<>-32767) then
    line_x (poly[loop1,1],loop1,poly[loop1,2],loop1,color);
end;


procedure PutLogo(x,y : integer);
Const
     LogoPoints : array[1..35{37}] of point2d=(
                  (x:0;y:-30),(x:0;y:20),(x:10;y:-20),(x:10;y:30),(x:0;y:30),(x:0;y:40),(x:10;y:40),(x:10;y:50),{I}
                  (x:20;y:-20),(x:20;y:20),(x:30;y:-15),(x:30;y:15),(x:35;y:30),(x:35;y:20),(x:35;y:-30),(x:35;y:-20),
                  (x:50;y:15),(x:45;y:10),(x:45;y:-10),(x:50;y:-15),
                  (x:80;y:30),(x:80;y:15),(x:70;y:5),(x:80;y:0),(x:80;y:0),(x:70;y:-5),(x:80;y:-15),(x:80;y:-30),(x:50;y:0),
                  (x:90;y:30),(x:90;y:-30),(x:120;y:0),(x:100;y:10),(x:100;y:-10),(x:110;y:0));
     LogoPolys  : array[1..15] of Face=(
                  (p1:1;p2:2;p3:3;p4:4;color:250),(p1:5;p2:6;p3:7;p4:8;color:250),
                  (p1:9;p2:10;p3:11;p4:12;color:250),(p1:10;p2:12;p3:13;p4:14;color:250),
                  (p1:10;p2:12;p3:13;p4:14;color:250),(p1:15;p2:16;p3:9;p4:11;color:250),
                  (p1:13;p2:14;p3:17;p4:18;color:250),(p1:15;p2:16;p3:19;p4:20;color:250),
                  (p1:21;p2:22;p3:23;p4:29;color:250),(p1:26;p2:27;p3:28;p4:29;color:250),
                  (p1:23;p2:24;p3:25;p4:26;color:250),(p1:23;p2:26;p3:29;p4:29;color:250),
                  (p1:30;p2:31;p3:33;p4:34;color:250),(p1:30;p2:32;p3:35;p4:33;color:250),
                  (p1:31;p2:32;p3:34;p4:35;color:250));

begin
 for i:=1 to 15 do
     DrawPoly(
      x+LogoPoints[LogoPolys[i].p1].x,y-LogoPoints[LogoPolys[i].p1].y,
      x+LogoPoints[LogoPolys[i].p2].x,y-LogoPoints[LogoPolys[i].p2].y,
      x+LogoPoints[LogoPolys[i].p3].x,y-LogoPoints[LogoPolys[i].p3].y,
      x+LogoPoints[LogoPolys[i].p4].x,y-LogoPoints[LogoPolys[i].p4].y,
      LogoPolys[i].color);
end;

procedure ReadCurentChar(whatchar : byte);
var s,o       : word;
    s1,o1     : word;
begin
asm
 push bp
 push es
 mov  al,$30
 mov  bh,2
 mov  ah,$11
 int  $10
 mov  ax,bp
 mov  bx,es
 pop  es
 pop  bp
 mov  s,bx
 mov  o,ax
 push ds
 push es
end;
 {
 r.al:=$30;
 r.bh:=3;
 r.ah:=$11;
 intr($10,r);
 s:=r.es;o:=r.bp;}
 s1:= seg(curentchar);o1:=ofs(curentchar);
 o := o+14*whatchar;{A}
asm
 mov ax,s
 mov es,ax
 mov di,o
 mov cx,14
 mov ax,s1
 mov ds,ax
 mov bl,255
 mov si,o1
 @1 :
    push cx
    mov cx,8
    mov al,es:[di]
    inc di
 @3 :
    xor ah,ah
    shl ax,1
    and ah,1
    jz @2
    mov ds:[si],bl
 @2 :
    inc si
    loop @3
    pop cx
    loop @1
 pop es
 pop ds
end;
end;

procedure DoScroll;
var
   start,incr  : word;
   chseg,chofs : word;
begin
 start := (Precision+1) div 2-4;
 incr  := 2*((Precision+1) div 2-4);
 chseg := seg(curentchar);
 chofs := ofs(curentchar);
 asm
  cld
  push es
  push ds
  mov es,cseg
  mov ds,cseg
  mov di,cofs
  add di,start
  mov si,cofs
  add si,Precision+1;
  add si,start
  mov dx,Precision
  mov bx,4

  @loop:
   mov cx,bx
   rep movsw
   add di,incr
   add si,incr
   dec dx
  jnz @loop

  sub si,8
  mov di,si
  mov ds,chseg
  mov si,chofs
  mov ax,ccol
  shl ax,3
  add si,ax
  mov cx,bx
  rep movsw

  pop ds
  pop es
 end;
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

PROCEDURE DepthSort(planenr : byte);
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
 mid:=EyeD[(i+j) div 2];
 repeat
  while EyeD[i]<mid do inc(i);
  while EyeD[j]>mid do dec(j);
  if i<=j
     then begin
          temp     := Obj3d[i];
          Obj3d[i] := Obj3d[j];
          Obj3d[j] := temp;
          exchg    := eyed[i];
          eyed[i]  := eyed[j];
          eyed[j]  := exchg;
          dec(j);
          inc(i);
          end;
 until i>j;
 if first<j then Kwik(first,j);
 if last>i  then Kwik(i,last);
end;

BEGIN
 for i:=1 to planenr do
     with obj3d[i] do
     EyeD[i]:= {round(sqrt(SQR((rot[P1].x+rot[P2].x+rot[P3].x+rot[P4].x) div 4-look.x)+
               SQR((}rot[P1].y+rot[P2].y+rot[P3].y+rot[P4].y div 4-look.y{)+
               SQR((rot[P1].z+rot[P2].z+rot[P3].z+rot[P4].z div 4-look.z)))};
 Kwik(1,planenr);
END;

function CosVPV(c,p1,p2 : point3d) : integer;
var s11,s21,s31,s12,s22,s32 : longint;
    a,m1pm2                 : longint;
    i                       : integer;
BEGIN
 s12:=(c.x-p2.x) div 16;s22:=(c.y-p2.y) div 16;s32:=(c.z-p2.z) div 16;
 m1pm2:=round(sqrt(abs((p1.x*p1.x+p1.y*p1.y+p1.z*p1.z)*(s12*s12+s22*s22+s32*s32))));
 CosVPV:=0;
 if m1pm2=0 then exit;
 a:=round(16384*((p1.x*s12+p1.y*s22+p1.z*s32)/m1pm2));
 CosVPV:=a;
END;

function IntSphere(xc,yc,zc,radp : single) : boolean;
var
   p1,p2,p3,p4,p5,a,b,c,sol1,sol2,delta,sqrtd,xj,yj,zj,xr,yr,zr,modul : single;
begin
 IntSphere := false;
 a := x2*x2+y2*y2+z2*z2;
 b := (x1-xc)*x2+(y1-yc)*y2+(z1-zc)*z2;
 c := (x1-xc)*(x1-xc)+(y1-yc)*(y1-yc)+(z1-zc)*(z1-zc)-radp;
 delta:=b*b-a*c;
 if delta<0 then exit;{ no intersection with sphere }
 sqrtd := sqrt(delta);
 p1 := -b/a;p2:=sqrtd/a;
 {sol1 := p1+p2;}
 sol2 := p1-p2;
 {if sol1<sol2
    then begin
          xj := x1+sol1*x2;yj:=y1+sol1*y2;zj:=z1+sol1*z2;
          modul := sqr(xj-xc)+sqr(yj-yc)+sqr(zj-zc);
          xr := (xj-xc)/modul;yr := (yj-yc)/modul;zr := (zj-zc)/modul;
          x1:=xj;x2:=xr;y1:=yj;y2:=yr;z1:=zj;z2:=zr;
          IntSphere := true;
         end
    else begin}
          xj := x1+sol2*x2;yj:=y1+sol2*y2;zj:=z1+sol2*z2;
          modul := sqrt(sqr(xj-xc)+sqr(yj-yc)+sqr(zj-zc));
          xr := (xj-xc)/modul;yr := (yj-yc)/modul;zr := (zj-zc)/modul;
          {modul := sqrt(x2*x2+y2*y2+z2*z2);
          x2 := x2/modul;y2:=y2/modul;z2:=z2/modul;}
          {modul := 2*(x2*xr+y2*yr+z2*zr);
          if modul>0
             then begin
                   x2 := xr-x2/modul;
                   y2 := yr-y2/modul;
                   z2 := zr-z2/modul;
                  end
             else if modul=0
                     then begin
                           x2 := -x2;
                           y2 := -y2;
                           z2 := -z2;
                          end
                    else begin
                          x2 := -xr+x2/modul;
                          y2 := -yr+y2/modul;
                          z2 := -zr+z2/modul;
                         end;}
          {x1:=xj;y1:=yj;z1:=zj;}
          x1:=xj;y1:=yj;z1:=zj;x2:=xr;y2:=yr;z2:=zr;
          IntSphere := true;
         {end;}
end;

function IntTable(x,y,z : single) : boolean;
var
   modul,x1s,x2s,y1s,y2s,z1s,z2s : single;
   decc : byte;
label endproc;
begin
 { check int with table }
 IntTable := false;
 if z2=0 then exit;
 {asm
  finit
  fld z2
  ftst
  fstsw ax
  and ax,0100000000000000b
  cmp ax,0
  jz endproc
 end;}
 asm
  finit
  fld z
  fsub z1
  fdiv z2
  fst u
  fmul x2
  fadd x1
  fst lastx
  fld u
  fmul y2
  fadd y1
  fst lasty
 end;
 { shade ... begin }
 x1s:=x1;x2s:=x2;y1s:=y1;y2s:=y2;z1s:=z1;z2s:=z2;
 x2:= rlight.x;y2:=rlight.y;z2:=rlight.z;
 x1:= lastx;y1:=lasty;z1:=z;
 decc := 0;
 if IntSphere(cx1,cy1,cz1,rad/2) or IntSphere(cx2,cy2,cz2,rad) then decc:=40
    else begin
          decc := round(1.4*sqrt(sqr(lastx+30)+sqr(lasty-30)+sqr(z+60))/5);
         end;
 x1:=x1s;x2:=x2s;y1:=y1s;y2:=y2s;z1:=z1s;z2:=z2s;
 {...end cast shadow}
 if (lastx<200) and (lastx>-200) and (lasty>-10) and (lasty<100)
    then begin
          lastx := abs(round(lastx) mod 40);
          lasty := abs(round(lasty) mod 40);
          case round(lastx) of
           0..20  : case round(lasty) of
                     0..20  : lastcolor := 255-decc;
                     21..39 : lastcolor := 63-decc;
                    end;
           20..39 : case round(lasty) of
                     0..20  : lastcolor := 63-decc;
                     21..39 : lastcolor := 255-decc;
                    end;
          end;
          IntTable := true;
         end;
endproc:end;

procedure LogoColor(r,g,b : byte);
begin
 workpal^[250,1]:=r;workpal^[250,2]:=g;workpal^[250,3]:=b;
end;

label thyend,again,next;

BEGIN

 { clear fractal memory }
 new(fractal);new(BackGround1);new(workpal);
 new(st);new(ct);
 fseg := seg(fractal^);
 fofs := ofs(fractal^);
 asm
  mov es,fseg
  mov di,fofs
  mov cx,160*80
  xor ax,ax
  rep stosw
 end;

 set320x240x256_X;
 setactivepage(0);setvisiblepage(0);
 pseg := seg(workpal^);
 pofs := ofs(workpal^);
 genpal;
 LogoColor(0,0,0);
 setpal;
 { generate a lookup table for fractal }
 for i:=0 to 359 do
     begin
      sint[i] := round(16384*sin(i*pi/180));
      cost[i] := round(16384*cos(i*pi/180));
     end;
 { generate sphere }
 cseg := seg(ct^);
 cofs := ofs(ct^);
 for i:=-Precision div 2 to Precision div 2 do
     for j:=-Precision div 2 to Precision div 2 do
         begin
          Temp := Radius*Radius-i*i-j*j;
          if temp>0
             then begin
                   st^[i+Precision div 2,j+Precision div 2].x := EyeDist*i div round(-sqrt(abs(temp))+EyeDist);
                   st^[i+Precision div 2,j+Precision div 2].y := EyeDist*j div round(-sqrt(abs(temp))+EyeDist);
                   ct^[i+Precision div 2,j+Precision div 2]   := 0;
                  end
             else begin
                   st^[i+Precision div 2,j+Precision div 2].x := i;
                   st^[i+Precision div 2,j+Precision div 2].y := j;
                   ct^[i+Precision div 2,j+Precision div 2]   := 0;
                  end;
         end;


 Triangle(160,30,60,188,260,188,191,1);
 PutLogo(105,120);

 for i:=0 to 63 do begin waitretrace;SetRgb(250,i,i,i);end;
 LogoColor(63,63,63);

 { generate fractal - unable to optimize :-(}
 fracwidth:=160;fracheight:=160;
 crh:=0.5;crl:=-0.5;
 cih:=0.5;cil:=-0.5;
 xsize:=(crh-crl)/fracwidth;
 ysize:=(cih-cil)/fracheight;
 maxiter:=64;
 ci:=cil;
 for y:=1 to fracheight do
     begin
       cr:=crl;
       for x:=1 to fracwidth do
           begin
             zr:=0;zi:=0;
             for i:=1 to maxiter do
                 begin
                   newzr:=zr-zr*zr*zr+1.73*zr*zi*zi+cr;
                   newzi:=zi+zi*zi*zi-pi*zi*zr*zr+ci;
                   zr:=newzr;
                   zi:=newzi;
                   if zi*zi+zr*zr>4 then break;
                 end;
             if (i+155) > 191 then fractal^[y,x] := 0
                else fractal^[y,x]:=i+155;
             cr:=xsize+cr;
           end;
       ci:=ysize+ci;
     end;

 CurentXl := 160;CurentYl := 160;
 for i:=1 to 10 do
     for j:=1 to 10 do
         begin
          new(BackGround1^[i,j]);
          with BackGround1^[i,j]^ do
               begin
                angle := 0;
                newxl := 60;newyl:=60;
                wherex := -260+(i-1)*60;wherey := -450+(j-1)*60;
                minxl := 35;maxxl:= 320;minyl := 35;maxyl := 320;
                dirx := 2;diry := 2;
               end;
         end;

 FadeOut(1);Cls(0);genpal;setpal;
 page  := 1;
 phase := 0;
 centerx:=orgx;dirx:=1;centery:=orgy;diry:=1;
 { init raytracing related vars... }
 cx2 := -10;cy2 := 0;cz2:=-34;rad:=1600;page:=1;
 cx1 := 50;cy1 := 0;cz1:=-52;
 dir2 := -3;dir1:=3;
 with rlight do begin x := -16;y:=-16;z:=-16;end;

 { init the sphere... }
 curchar := 1;ReadCurentChar(byte(Greet[curchar]));ccol := 0;page := 1;
 { init the cube...a Lambert illumination model - suxx :-) }
 with points[1] do begin x:=+radius div 2;y:=+radius div 2;z:=+radius div 2;end;
 with points[2] do begin x:=-radius div 2;y:=+radius div 2;z:=+radius div 2;end;
 with points[3] do begin x:=+radius div 2;y:=-radius div 2;z:=+radius div 2;end;
 with points[4] do begin x:=+radius div 2;y:=+radius div 2;z:=-radius div 2;end;
 with points[5] do begin x:=-radius div 2;y:=-radius div 2;z:=+radius div 2;end;
 with points[6] do begin x:=+radius div 2;y:=-radius div 2;z:=-radius div 2;end;
 with points[7] do begin x:=-radius div 2;y:=+radius div 2;z:=-radius div 2;end;
 with points[8] do begin x:=-radius div 2;y:=-radius div 2;z:=-radius div 2;end;
 with obj3d[1] do
      begin
       p1:=1;p2:=2;p3:=4;p4:=7;with n do begin x:=0;y:=16;z:=0;end;color := 0;
       with np do begin x:=0;y:=radius div 2;z:=0;end;
      end;
 with obj3d[2] do
      begin
       p1:=1;p2:=4;p3:=3;p4:=6;with n do begin x:=16;y:=0;z:=0;end;color := 0;
       with np do begin y:=0;x:=radius div 2;z:=0;end;
      end;
 with obj3d[3] do
      begin
       p1:=3;p2:=5;p3:=6;p4:=8;with n do begin x:=0;y:=-16;z:=0;end;color := 0;
       with np do begin x:=0;y:=-radius div 2;z:=0;end;
      end;
 with obj3d[4] do
      begin
       p1:=1;p2:=2;p3:=3;p4:=5;with n do begin x:=0;y:=0;z:=16;end;color := 0;
       with np do begin x:=0;z:=radius div 2;y:=0;end;
      end;
 with obj3d[5] do
      begin
       p1:=2;p2:=5;p3:=7;p4:=8;with n do begin x:=-16;y:=0;z:=0;end;color := 0;
       with np do begin z:=0;x:=-radius div 2;y:=0;end;
      end;
 with obj3d[6] do
      begin
       p1:=4;p2:=6;p3:=7;p4:=8;with n do begin x:=0;y:=0;z:=-16;end;color := 62;
       with np do begin x:=0;z:=-radius div 2;y:=0;end;
      end;
 with center do begin x:=0;y:=0;z:=0;end;
 ang := center;
 with light do begin x:=-100;y:=-100;z:=100 end;
 with look do begin x:=0;z:=0;y:=-EyeDist;end;
 sysaction := 0;
 GetIntVec($1C,@Int1CSave);
 SetIntVec($1C,Addr(TimerHandler));

 again:
  setactivepage(page);
  case sysaction of
   1 : begin
        FadeOut(2);
        cls(0);cls(1);
        genpal;
        LogoColor(0,0,0);
        setpal;
        setvisiblepage(page);

        Triangle(160,30,60,188,260,188,191,1);
        PutLogo(105,120);
        for i:=0 to 63 do begin waitretrace;SetRgb(250,i,i,i);end;
        LogoColor(63,63,63);

        dispose(ct);dispose(st);dispose(fractal);dispose(BackGround1);
        for i:=1 to 17 do new(frames[i]);
        for k:=1 to 17 do
            begin
             for x:=-80 to 80 do
                 for z:=-80 to 80 do
                     begin
                      caze := 0;
                      reclevel := 4;
                      repeat
                       case caze of
                        0 : begin
                             x1 := 0;x2 := x;y1 := -eye;y2 := eye;z1 := -10;z2 := z;
                             if IntTable(0,0,20) then goto next
                                else if IntSphere(cx1,cy1,cz1,rad/2) then caze :=1
                                     else if IntSphere(cx2,cy2,cz2,rad) then caze := 2
                                             else begin
                                                   lastcolor := 1;{ out of scene ! }
                                                   goto next;
                                                  end;
                            end;
                        2 : begin
                             lastcolor := round(127-sqrt(sqr(x1+30)+sqr(y1-30)+sqr(z1+60))/1.4);{bila opaca}
                             goto next;
                            end;
                        1 : begin
                             if IntTable(0,0,20) then goto next
                                else if IntSphere(cx2,cy2,cz2,rad) then caze:=2
                                else begin
                                      lastcolor := round(191-sqrt(sqr(x1+30)+sqr(y1-30)+sqr(z1+60))/1.9)+3;{bila transparenta}
                                      goto next;
                                     end;
                            end;
                       end;
                       dec(reclevel);
                      until reclevel<=0;
                      next:frames[k]^[z,x] := lastcolor;
                     end;
             cz2 := cz2 + dir2;
             case dir2 of
              -3 : if cz2<-56 then dir2:=3;
              3 : if cz2>-33 then dir2:=-3;
             end;
             cz1 := cz1 + dir1;
             case dir1 of
              -3 : if cz1<-56 then dir1:=3;
               3 : if cz1>-33 then dir1:=-3;
             end;
            end;
        phase := 1;sysaction := 0;rayrepeat := 255;
        crtframe:=0;x1:=6;
        FadeOut(2);
        cls(0);
        cls(1);
        genpal;
        setpal;
        setvisiblepage((page+1) mod 2);
       end;
   2 : begin
        FadeOut(2);
        cls(0);cls(1);
        for i:=1 to 17 do dispose(frames[i]);
        rpseg := seg(rosepal);rpofs := ofs(rosepal);
        rseg := seg(rose);rofs := ofs(rose);
        newrose:=ptr(rseg,rofs);newrosepal:=ptr(rpseg,rpofs);
        move(newrosepal^,workpal^,768);
        setpal;
        maxindex:=1;l:=0;
        randomize;
        repeat
         if mem[rseg:rofs+l]<>0
            then begin
                  new(rosepixel[maxindex]);
                  with rosepixel[maxindex]^ do
                       begin
                        j     := random(30)+25;
                        k     := random(160)+10;
                        vx0   := (j*cost[k])/16384;
                        vy0   := (j*sint[k])/16384;
                        x     := l mod 76-38;
                        y     := l div 76-23;
                        color := mem[rseg:rofs+l];
                        useme := true;time:=0;
                        if maxindex<2000 then inc(maxindex);
                       end;
                 end;
         inc(l);
        until l>=76*46-1;
        dec(maxindex);
        for j:=1 to maxindex do putpixel_x(rosepixel[j]^.x+orgx,orgy+rosepixel[j]^.y,rosepixel[j]^.color);
        setvisiblepage(page);
        for i:=1 to 40 do
            begin
             asm cli end;
              dodraw := false;
             asm sti end;
             repeat
             until dodraw;
            end;
        phase := 2;sysaction:=0;
       end;
  end;

  case phase of
  2 : begin
       cls(page);
       nopixels := true;
       for i:=1 to maxindex do
           with rosepixel[i]^ do
                if useme
                   then begin
                         nopixels := false;
                         time     := time+0.07;
                         xpart    := x+round(vx0*time);
                         ypart    := y-round(vy*time-4.8*sqr(time));
                         vy       := vy0-9.6*time;
                         putpixel_x(xpart+orgx,orgy+ypart,color);
                         if (vy<0.2) and (vy>-0.2) then useme:=false;
                         if (xpart+orgx<ClipLt) or (orgx+xpart>ClipRt)
                            then vx0:=-vx0;
                         if orgy+ypart>=180
                            then begin
                                  y  := ypart;
                                  x  := xpart;
                                  vy0 := vy0*0.85;
                                  time := 0;
                                 end;
                        end;
       if nopixels
          then asm
                jmp thyend
               end;
      end;
  1 : begin
       cls(page);
       inc(crtframe);
       if crtframe>17 then crtframe:=1;
       if x1>1 then x1:=x1-0.5;
       xscale1(orgx-round(x1*161/2),orgy-round(x1*161/2),round(161*x1),round(161*x1),161,161,actstart,frames[crtframe]);
       dec(rayrepeat);
       if rayrepeat=0 then sysaction := 2;
      end;
  0 : begin
       { draw fractal background }
       for i:=1 to 10 do
           for j:=1 to 10 do
               with BackGround1^[i,j]^ do
                    begin
                      newxl := newxl+dirx;
                      case dirx of
                       2  : if newxl>maxxl then dirx:=-dirx;
                       -2 : if newxl<minxl then dirx:=-dirx;
                      end;
                      newyl := newyl+diry;
                      case diry of
                       2  : if newyl>maxyl then diry:=-diry;
                       -2 : if newyl<minyl then diry:=-diry;
                      end;
                      xscale1( 160-newxl*5+(i-1)*newxl-newxl div 2,120-newyl*5+(j-1)*newyl-newyl div 2,newxl,newyl,160,160,
                               actstart,fractal);
                     end;
       centerx := centerx + dirx;
       if (centerx+Precision div 2>ClipRt-10) or (centerx-Precision div 2<ClipLt+10)
          then dirx:=-dirx;
       centery := centery + diry;
       if (centery-Precision div 2<ClipTp+10) or (centery+Precision div 2>ClipBt-10)
          then diry:=-diry;
       { do cube }

       for i:=1 to 8 do
           begin
            rot[i]:=points[i];
            RotatePoint(i,i,ang.x,ang.y,ang.z);
            with pro[i] do
                 begin
                  x:=look.y*rot[i].x div (rot[i].y+look.y);
                  y:=look.y*rot[i].z div (rot[i].y+look.y);
                 end;
           end;
       {DepthSort(6);}
       for i:=1 to 6 do
           begin
            points[11]  := obj3d[i].n;
            RotatePoint(11,1,ang.x,ang.y,ang.z);
            points[12]  := obj3d[i].np;
            RotatePoint(12,2,ang.x,ang.y,ang.z);
            with Rot[2] do tempdist:= round(sqrt(abs(sqr(x-light.x)+sqr(y-light.y)+sqr(z-light.z))));
            tempang := CosVPV(light,Rot[1],Rot[2]);
            if rot[1].y>0 then begin
            tempang := 10+(tempdist div 4)*abs(tempang) div 16384;
            obj3d[i].color := 64+abs(tempang mod 63);
            DrawPoly(
             pro[obj3d[i].p1].x+centerx,pro[obj3d[i].p1].y+centery,
             pro[obj3d[i].p2].x+centerx,pro[obj3d[i].p2].y+centery,
             pro[obj3d[i].p3].x+centerx,pro[obj3d[i].p3].y+centery,
             pro[obj3d[i].p4].x+centerx,pro[obj3d[i].p4].y+centery,
             obj3d[i].color);
            end;
           end;
       { do write on sphere }
       for i:=1 to 14 do ct^[Precision,i+Precision div 2-7]:=curentchar[i,ccol+1];
       for i:=1 to Precision-1 do for j:=Precision div 2-10 to Precision div 2+10 do ct^[i,j]:=ct^[i+1,j];
       for i := 0 to Precision-1 do
           for j := 0 to Precision-1 do
               begin
                if ct^[i,j]<>0
                   then DrawPoly(st^[i,j].x+centerx,st^[i,j].y+centery,st^[i+1,j].x+centerx,st^[i+1,j].y+centery,
                                 st^[i,j+1].x+centerx,st^[i,j+1].y+centery,st^[i+1,j+1].x+centerx,st^[i+1,j+1].y+centery,
                                 ct^[i,j]);
              end;
       inc(ccol);
       if ccol>7
          then begin
                ccol := 0;
                inc(curchar);
                if curchar>length(Greet) then sysaction:=1;
                for i:=1 to 14 do for j:=1 to 8 do curentchar[i,j]:=0;
                ReadCurentChar(byte(Greet[curchar]));
               end;
      end;
  end;
  repeat
  until dodraw;
  setvisiblepage(page);
  page := (page+1) mod 2;
  asm cli end;
   dodraw := false;
  asm sti end;
  asm
   in al,60h
   dec al
   jz thyend
   jmp again
  end;
 thyend:

 SetIntVec($1C,@Int1CSave);
 { fade to white }
 totextmode;
 asm
  mov dx,seg theend
  mov ds,dx
  mov dx,offset theend
  inc dl
  mov ah,9
  int 21h
 end;
END.

