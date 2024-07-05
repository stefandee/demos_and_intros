program TweakMode;

uses dos,crt;
{$R-}
const sequ_addr = $3c4;
      crtc_addr = $3d4;
      vga       = $a000;

type vgamem = array[0..199,0..319] of byte;
     fr     = array[1..161,1..101] of byte;

var r:registers;
    width,height:word;
    widthBytes:word;
    actstart,visstart:word;
    f : file;
    vaddr : ^vgamem;
    i,j : longint;
    workpal : array[0..255,1..3] of byte;
    h,m,s1,s0,s100,s1001 : word;
    dt : real;
    page : integer;
    fractal : ^fr;

const orgx = 160;
      orgy = 120;

var crl,crh,cih,cil,ci,cr,zr,zi,newzr,newzi : real;
    maxiter : integer;
    fwidth,fheight : integer;
    xsize,ysize : real;
    x,y : integer;
    member : boolean;
    aux1,aux2 : real;
    color : byte;
    dx,dy : real;

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


procedure putPixel_X(x,y : integer;color:byte);
begin
       { /* Each address accesses four neighboring pixels, so set
           Write Plane Enable according to which pixel we want
           to modify.  The plane is determined by the two least
           significant bits of the x-coordinate: */}
port[$3c4]:=$02;
      {outportb(0x3c4, 0x02);}
port[$3c5]:=$01 shl (x and 3);
      {outportb(0x3c5, 0x01 << (x & 3));}

      {  /* The offset of the pixel into the video segment is
           offset = (width * y + x) / 4, and write the given
           color to the plane we selected above.  Heed the active
           page start selection. */
      }
        mem[vga:((widthBytes * y) + (x div 4) + actStart)] := color;
end;


procedure Line_X(x1,y1,x2,y2:integer;color:byte;where:word);
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
    push where
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
 for i:=0 to 239 do line_x(0,i,319,i,0,$a000);
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
begin
new(vaddr);
assign(f,'winter.spr');reset(f,1);seek(f,4);blockread(f,vaddr^,64000);close(f);
assign(f,'blue.pal');reset(f,1);blockread(f,workpal,768);close(f);
set320x240x256_x;

for i:=0 to 255 do
    begin
    port[$3c8]:=i;
    port[$3c9]:=workpal[i,1];
    port[$3c9]:=workpal[i,2];
    port[$3c9]:=workpal[i,3];
    end;
setvisiblepage(0);

setactivepage(0);
line_x(0,0,100,100,255,vga);
fwidth:=80;fheight:=50;
crh:=0.5;crl:=-0.5;
cih:=-0.5;cil:=0.5;
maxiter:=256;
dx := 0;dy :=0;
page := 0;
setvisiblepage(0);
new(fractal);

     xsize:=2*(crh-crl)/fwidth;
     ysize:=2*(cih-cil)/fheight;
     ci:=cil;

     for y:=1 to fheight do
         begin
           cr:=crl;
           for x:=1 to fwidth do
               begin
                 zr:=0;zi:=0;
                 for i:=1 to maxiter do
                     begin
                       aux1:=zr*zr;
                       aux2:=zi*zi;
                       newzr:=aux1-aux2+cr;
                       newzi:=2*zr*zi+ci;
                       zr:=newzr;
                       zi:=newzi;
                       if {(aux1>2) or (aux2>2) or }(aux1+aux2>=1024) then break;
                       if port[$60]=1 then halt;
                     end;
                 color := 255-i;
                 fractal^[x,y]:=color;
                 {if color<210 then }putpixel_x(x,y,color);
                 cr:=xsize+cr;
               end;
           ci:=ysize+ci;
         end;
     dx := dx+2;
     dy := dy+2;

for j:=1 to 50 do
    begin
     for i:=1 to 80 do
          line_x(80+i-j,80+j,80+i-j,80+j-fractal^[i,j] div 4,fractal^[i,j],vga);
    end;
{
repeat
setvisiblepage(0);waitretrace;delay(500);
setvisiblepage(1);waitretrace;delay(500);
until keypressed;
}
readln;
asm mov ax,$0003
    int $10 end;

end.
