program TweakMode;
{$N+}
uses dos;
const sequ_addr = $3c4;
      crtc_addr = $3d4;
      vga       = $a000;

{ external scale defs }
CONST
     ClipLT   : word = 5;
     ClipRT   : word = 315;
     ClipTP   : word = 40;
     ClipBT   : word = 200;
     OrgX            = 160;
     OrgY            = 120;

{$L xscale1.obj}
{$F+}
procedure XSCALE1 ( DestX:WORD;DestY:WORD;DestWidth:WORD;DestHeight:WORD;SourceWidth:WORD;SourceHeight:WORD;
                    Start:Word;Bitmap:pointer);external;
{$F-}

var
   r:registers;
    width,height:word;
    widthBytes:word;
    actstart,visstart:word;
    f : file;
    i,j,k : longint;
    workpal : array[0..255,1..3] of byte;
    page : integer;
    pseg,pofs : word;

type
    point3d = record
            x,y,z : integer;
            end;
    frame = array[-80..80,-80..80] of byte;
    pframe = ^frame;

var {raytrace}
    u,lastx,lasty,lastz : single;
    lastcolor   : byte;
    caze        : byte;
    s1,s2       : point3d;
    x,y,z       : integer;
    reclevel    : byte;
    x1,x2,y1,y2,z1,z2 : single;
    cx2,cy2,cz2 : integer;
    cx1,cy1,cz1 : integer;
    light       : point3d;
    rad : single;
    dir2,dir1  : integer;
    frames      : array[1..18] of pframe;

const
      eye  = -100;

procedure setpal;
begin
     r.ax:=$1012;
     r.es:=seg(workpal);
     r.dx:=ofs(workpal);
     r.bx:=0;
     r.cx:=256;
     intr($10,r);
end;


procedure set320x200x256_X;
begin

        {/* Set VGA BIOS mode 13h: */}

        r.ax := $0013;
        intr($10,r);

        {/* Turn off the Chain-4 bit (bit 3 at index 4, port 0x3c4): */}

        portw[SEQU_ADDR]:=$0604;
        {outport(SEQU_ADDR, 0x0604);}

        {/* Turn off word mode, by setting the Mode Control register
           of the CRT Controller (index 0x17, port 0x3d4): */}

        {outport(CRTC_ADDR, 0xE317);}
        portw[crtc_addr]:=$E317;

        {/* Turn off doubleword mode, by setting the Underline Location
           register (index 0x14, port 0x3d4): */}

        {outport(CRTC_ADDR, 0x0014);}
        portw[crtc_addr]:=$0014;

        {/* Clear entire video memory, by selecting all four planes, then
           writing 0 to the entire segment. */}

        {outport(SEQU_ADDR, 0x0F02);}

        portw[sequ_addr]:=$0F02;

        fillchar(mem[vga:0],$ffff,0);
        {memset(vga+1, 0, 0xffff); /* stupid size_t exactly 1 too small */}
        mem[vga:0] := 0;

        {/* Update the global variables to reflect the dimensions of this
           mode.  This is needed by most future drawing operations. */}

        width   := 320;
        height  := 200;

        {/* Each byte addresses four pixels, so the width of a scan line
           in *bytes* is one fourth of the number of pixels on a line. */}

        widthBytes := width div 4;

        {/* By default we want screen refreshing and drawing operations
           to be based at offset 0 in the video segment. */}

        actStart :=0;
        visStart :=0;

end;

procedure setActiveStart(offset : word);
begin
actStart := offset;
end;

procedure setVisibleStart(offset : word);
begin
        visStart := offset;
        portw[CRTC_ADDR]:= $0C;               {/* set high byte */}
        portw[CRTC_ADDR+1]:=visStart shr 8;
        portw[CRTC_ADDR]:= $0D;               {/* set low byte */}
        portw[CRTC_ADDR+1]:=visStart and $ff;
end;

procedure setActivePage(page : integer);
begin
setActiveStart(page * widthBytes * height);
end;

procedure setVisiblePage(page : integer);
begin
setVisibleStart(page * widthBytes * height);
end;

procedure putpixel_x(x,y : integer;color : byte);assembler;
 asm
  mov dx, SEQU_ADDR
  mov al, 02h
  out dx, al
  inc dx
  mov al,1
  mov cx,x
  and cx,3
  shl al,cl
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

procedure Line_X(x1,y1,x2,y2:integer;color:byte);
var i, deltax, deltay, numpixels,
    d, dinc1, dinc2,
    x, xinc1, xinc2,
    y, yinc1, yinc2 : integer;
    screen : word;
    dxtemp,page   : word;
    page4 : byte;
    screeninc1, screeninc2 : integer;

begin
  {
  if x1<0 then x1:=0;
  if x2<0 then x2:=0;
  if y1<0 then y1:=0;
  if y2<0 then y2:=0;
  if x1>319 then x1:=319;
  if x2>319 then x2:=319;
  if y1>199 then y1:=199;
  if y2>199 then y2:=199;
  }

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
    push VGA
    pop es
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
    inc cx
   @x:shl al,1
    loop @x
    shr al,1
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

procedure Cls(Page : byte);
var
   i,j : integer;
begin
 for i:=0 to 239 do line_x(0,i,319,i,0);
end;

procedure set320x240x256_X;
begin
       { /* Set the unchained version of mode 13h: */}

        set320x200x256_X;

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
 x2:= light.x;y2:=light.y;z2:=light.z;
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

procedure waitretrace;assembler;
  asm
    mov dx,3DAh
  @l1:
    in al,dx
    and al,08h
    jnz @l1
  @l2:
    in al,dx
    and al,08h
    jz  @l2
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

label next;

begin
asm
 finit
 fwait
end;
{assign(f,'main.pal');reset(f,1);blockread(f,workpal,768);close(f);}

set320x240x256_x;

pseg := seg(workpal);pofs := ofs(workpal);

genpal;
for i:=0 to 255 do
    begin
    port[$3c8]:=i;
    port[$3c9]:=workpal[i,1];
    port[$3c9]:=workpal[i,2];
    port[$3c9]:=workpal[i,3];
    end;
setactivepage(0);
setvisiblepage(0);

cx2 := -10;cy2 := 0;cz2:=-34;rad:=1600;page:=1;
cx1 := 50;cy1 := 0;cz1:=-52;
dir2 := -3;dir1:=3;
with light do begin x := -16;y:=-16;z:=-16;end;
for i:=1 to 18 do new(frames[i]);

for k:=1 to 18 do
begin
  setactivepage(page);
for x:=-80 to 80 do
    for z:=-80 to 80 do
        begin
         caze := 0;
         reclevel := 4;
         repeat
          case caze of
           0 : begin
                x1 := 0;x2 := x;y1 := -eye;y2 := eye;z1 := -10;z2 := z;
                if IntTable(0,0,20) then goto next{break}
                   else if IntSphere(cx1,cy1,cz1,rad/2) then caze :=1
                        else if IntSphere(cx2,cy2,cz2,rad) then caze := 2
                                else begin
                                      lastcolor := 1;{ out of scene ! }
                                      goto next;{break;}
                                     end;
               end;
           2 : begin
                {if IntTable(0,0,20) then break
                   else begin}
                         lastcolor := round(127-sqrt(sqr(x1+30)+sqr(y1-30)+sqr(z1+60))/1.4);{bila opaca}
                         goto next;{break;
                        {end;}
               end;
           1 : begin
                if IntTable(0,0,20) then goto next
                   else if IntSphere(cx2,cy2,cz2,rad) then caze:=2
                   else begin
                         lastcolor := round(191-sqrt(sqr(x1+30)+sqr(y1-30)+sqr(z1+60))/1.9)+3;{bila transparenta}
                         goto next;{break;}
                        end;
               end;
          end;
          dec(reclevel);
         until reclevel<=0;
         next:frames[k]^[z,x] := lastcolor;
         {putpixel_x(x+orgx,z+orgy,lastcolor);}
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
  setvisiblepage(page);
  page := (page+1) mod 2;
end;

 i:=0;x1:=6;
 repeat
  inc(i);
  if i>18 then i:=1;
  setactivepage(page);
  cls(page);
  if x1>1 then x1:=x1-0.5;
  xscale1(orgx-round(x1*161/2),orgy-round(x1*161/2),round(161*x1),round(161*x1),161,161,actstart,frames[i]);
  waitretrace;
  setvisiblepage(page);
  page := (page+1) mod 2;
 until port[$60]<128;

asm
 mov ax,$0003
 int $10
end;

end.
