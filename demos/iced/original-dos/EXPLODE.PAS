PROGRAM
        World;
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

{$L rosepal.obj}
procedure rosepal;external;
{$L rose.obj}
procedure rose;external;

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
    explosion = record
              vx0,vy0,vy : single;
              x,y        : integer;
              time       : single;
              color      : byte;
              useme      : boolean;
              end;
    trigtable = array[0..359] of integer;
VAR
   i,j,k,temp,l : longint;
   sint,cost    : trigtable;
   rseg,rofs    : word;
   newrose      : pointer;
   rpseg,rpofs  : word;
   newrosepal   : ^Pal;
   maxindex     : integer;
   rosepixel    : array[1..2000] of ^explosion;
   nopixels     : boolean;
   ypart,xpart  : integer;

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

BEGIN
 set320x240x256_X;
 new(WorkPal);
 pseg := seg(WorkPal^);pofs := ofs(WorkPal^);
 rpseg := seg(rosepal);rpofs := ofs(rosepal);
 rseg := seg(rose);rofs := ofs(rose);
 newrose:=ptr(rseg,rofs);newrosepal:=ptr(rpseg,rpofs);
 {for i:=0 to 255 do workpal^[i]:=newrosepal^[i];}
 move(newrosepal^,workpal^,768);
 setpal;

 for i:=0 to 359 do
     begin
      sint[i] := round(16384*sin(i*pi/180));
      cost[i] := round(16384*cos(i*pi/180));
     end;

 maxindex:=1;l:=0;
 randomize;
 repeat

  if mem[rseg:rofs+l]<>0
     then begin
           new(rosepixel[maxindex]);
           with rosepixel[maxindex]^ do
                begin
                 j     := random(30)+30;
                 k     := random(160)+10;
                 vx0   := (j*cost[k]) div 16384;
                 vy0   := (j*sint[k]) div 16384;
                 x     := l mod 76-38;
                 y     := l div 76-23;
                 color := mem[rseg:rofs+l];
                 useme := true;time:=0;
                 if maxindex<3000 then inc(maxindex);
                end;
          end;
  inc(l);
 until l>=76*46;
 dec(maxindex);
 for j:=1 to maxindex do putpixel_x(rosepixel[j]^.x+orgx,orgy+rosepixel[j]^.y,rosepixel[j]^.color);
 readln;
 page := 1;setvisiblepage(0);

 repeat
  setactivepage(page);
  cls(page);
  nopixels := true;
  for i:=1 to maxindex do
      with rosepixel[i]^ do
           if useme
              then begin
                    nopixels := false;
                    time     := time+0.03;
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
                    {
                    vy   := vy0-9.6*time;
                    temp := orgy+y-round(vy*time-4.8*sqr(time));
                    putpixel_x( x+round(vx0*time)+orgx,
                                temp,
                                color);
                    if (vy<0.2) and (vy>-0.2) then useme:=false;
                    if (x+round(vx0*time)+orgx<ClipLt) or (orgx+x+round(vx0*time)>ClipRt)
                       then begin
                             vx0:=-vx0;
                            end;
                    if temp>=180
                       then begin
                             y  := y-round(vy*time-4.8*sqr(time));
                             x  := x+round(vx0*time);
                             vy0 := vy0*0.8;
                             time := 0;
                            end;
                   }
                   end;
  setvisiblepage(page);
  page := (page+1) mod 2;
 until (nopixels) or (port[$60]=1);
END.