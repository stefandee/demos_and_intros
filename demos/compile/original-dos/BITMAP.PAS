unit Bitmap;

interface

procedure DoSail;
procedure DoWinter;

implementation

uses graphics,types3d;

const barsize = 20;

var map         : array[1..65,1..92] of byte;
    sc          : array[0..359,1..2] of integer;
    aline       : array[1..320] of byte;
    cline       : array[1..320] of byte;
    f           : file;
    mseg,mofs   : word;
    i,j         : integer;
    ic,jc       : byte;
    rx,ry,elen  : integer;
    x,y         : integer;
    rad,cl      : integer;
    sailx       : integer;
    saily       : real;
    do_wind     : boolean;
    decr_ry     : boolean;
    lin,cnt     : byte;


procedure TLine(x1,y1,x2,y2:integer;where:word;wl:word);
var i, deltax, deltay, numpixels,
    d, dinc1, dinc2,
    x, xinc1, xinc2,
    y, yinc1, yinc2 : integer;
    screen : word;
    screeninc1, screeninc2 : integer;
    wline : word;
    xb,xf : integer;
    len   : byte;

begin

  if x1>x2 then begin xb:=x2;xf:=x1; end
           else begin xb:=x1;xf:=x2; end;

  if xb<0 then begin len:=-xb;xb:=0;end;

  if xb<0 then xb:=0;
  if y1<0 then y1:=0;
  if y2<0 then y2:=0;
  if xf>319 then xf:=319;
  if y1>199 then y1:=199;
  if y2>199 then y2:=199;


  { Calculate deltax and deltay for initialisation }
  deltax := abs(xf - xb);
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

  screen := word(Y1) shl 8+word(Y1) shl 6 + xb;
  screeninc1 := word(Yinc1) shl 8+word(Yinc1) shl 6 + xinc1;
  screeninc2 := word(Yinc2) shl 8+word(Yinc2) shl 6 + xinc2;
  wline:=mofs+92*wl+len;

  { Draw the pixels }
  asm

    { Use as many registers as are available }
    push where
    pop es
    mov di, screen
    mov dx, d
    mov ax, mseg
    mov ds, ax
    mov ax, wline
    mov si, ax
    mov cx, numpixels
    mov bx, dinc1
    mov ah, 0

    @bres1:

    { Draw the current pixel and compare the decision variable to 0 }

    lodsb
    inc ah
    cmp ah,110
    jbe @dopixel
    mov al,0
    dec si
@dopixel :
    mov es:[di], al
    cmp dx, 0
    jnl @bres2

    { D < 0 }
    add dx, bx { bx = dinc1 }
    add di, screeninc1
    jmp @bres3

    @bres2:

    { D >= 0 }
    add dx, dinc2
    add di, screeninc2

    @bres3:

    loop @bres1
  end;

end;


procedure DoSail;
begin

cls(0,vaddr);cls(0,vga);

hlin:=Nhlin;
loadpal('compile.dat',24926);setpal;
loadspr('compile.dat',1,121725);
loadspr('compile.dat',2,57721);
{read texture map}
assign(f,'compile.dat');reset(f,1);seek(f,4+48574);
for j:=65 downto 1 do for i:=1 to 92 do begin blockread(f,map[j,i],1);{putpixel(i,j,map[j,i],vga)};end;
close(f);

assign(f,'compile.dat');reset(f,1);seek(f,26462);blockread(f,sc,sizeof(sc));close(f);
mseg:=seg(map);mofs:=ofs(map);rx:=30;ry:=40;sailx:=0;saily:=0;do_wind:=false;

randomize;

putspr(2,0,0,normalput,vaddr);
for i:=1 to 1500 do putpixel(random(320),spr[1].yl-5+random(10),0,vaddr);
getimage(3,0,spr[1].yl-5,320,10,vaddr);

putspr(2,0,0,normalput,vaddr);

for ic:=0 to 199 do
    begin
      asm
       mov bl,ic
       xor bh,bh
       push es
       push ds

       mov ax,vaddr
       mov ds,ax
       mov ax,bx
       mov cx,320
       mul cx
       mov si,ax

       mov ax,seg aline
       mov es,ax
       mov di,offset aline
       mov cx,160
       cld
       rep movsw
       pop ds
       pop es
    end;

    for jc:=1 to barsize do
        asm
           push es
           push ds

           mov dl,jc
           xor dh,dh

           mov ax,vaddr
           mov ds,ax
           mov ax,bx
           add al,dl
           add al,barsize
           cmp ax,200
           jae @done

           mov cx,320
           push dx
           mul cx
           mov si,ax
           pop dx

           mov ax,seg cline
           mov es,ax
           mov di,offset cline
           mov cx,160
           cld
           rep movsw

           mov ax,vga
           mov es,ax
           mov ax,bx
           sub al,dl
           add al,barsize
           mov cx,320
           mul cx
           mov di,ax

           mov ax,seg cline
           mov ds,ax
           mov si,offset cline

           mov cx,160
           cld
           rep movsw
           @done:

           pop ds
           pop es
           end;
        asm
           mov ax,vga
           mov es,ax
           mov ax,bx
           mov cx,320
           mul cx
           mov di,ax

           mov ax,seg aline
           mov ds,ax
           mov si,offset aline

           call waitretrace;
           mov cx,160
           cld
           rep movsw

        end;
        for i:=1 to 1000 do
     end;


repeat

cls(0,vaddr);
putspr(2,0,0,normalput,vaddr);
putspr(1,sailx,round(saily),gameput,vaddr);
putspr(3,0,spr[1].yl-5,gameput,vaddr);

rad:=round(sqrt(rx*rx+ry*ry));elen{d}:=round(2*pi*rad);

for i:=0 to 359 do
    begin
    cl:=round((i*pi*rad)/180);
    x:=sailx+(rx*sc[(i+270) mod 360,1]) div 256-spr[1].xl div 2;
    y:=round(saily+spr[1].yl div 2-10+(ry*sc[(i+270) mod 360,2]) div 256);
    if (cl>elen div 2-32) and (cl<elen div 2+32)
    then tline(x,y,x+92,y,vaddr,cl-elen div 2+32);
    end;

flip;
inc(sailx,2);
saily:=saily+0.02;
if sailx mod 9 =0 then begin
                       do_wind:=true;
                       decr_ry:=true;
                       end;
if do_wind then begin
                if decr_ry then if ry>35 then begin
                                              dec(ry);
                                              inc(rx);
                                              end
                                         else decr_ry:=false;
                if not decr_ry then if ry<45 then begin
                                                 inc(ry);
                                                 dec(rx);
                                                 end
                                            else do_wind:=false;
               end;
until sailx>320;

lin:=199;

repeat

putspr(2,0,0,normalput,vaddr);

asm
   mov bl,lin
   xor bh,bh
   push es
   push ds

end;

asm
   mov ax,vaddr
   mov ds,ax
   mov ax,bx
   mov cx,320
   mul cx
   mov si,ax

   mov ax,seg aline
   mov es,ax
   mov di,offset aline
   mov cx,160
   cld
   rep movsw
end;

asm
   pop ds
   pop es
end;

cnt:=lin;

asm
   push es
   push ds
end;

repeat
    asm
       mov ax,vaddr
       mov es,ax
       xor ah,ah
       mov al,cnt
       mov cx,320
       mul cx
       mov di,ax

       mov ax,seg aline
       mov ds,ax
       mov si,offset aline

       mov cx,160
       cld
       rep movsw
    end;
inc(cnt);
until cnt=200;

asm
   pop ds
   pop es
end;
waitretrace;
flip;
dec(lin);
until lin<=1;

fadeout(3);
donespr(1);donespr(2);donespr(3);
end;

procedure DoWinter;

type snowflake = record
               x,xo,stepx : integer;
               y,stepy  : real;
               thru : boolean;
               pixel : byte;
               end;

const nr=400;
      cl : byte=255;

var snow : array[1..nr] of snowflake;
    i : integer;

procedure InitAPixel(index : integer);
 begin
   with snow[index] do
      begin
        x:=random(310)+5;xo:=x;
        y:=random(150)+1;
        case random(3) of
         0 : stepx:=-1;
         1 : stepx:=1;
         2 : stepx:=0;
        end;
        stepy := random(49)/100+0.5;
        case random(15) of
         1 : thru:=true;
         else thru:=false;
        end;
      end;
end;


begin

cls(0,vaddr);cls(0,vga);

loadpal('compile.dat',25694);setpal;
loadspr('compile.dat',1,127654);
loadspr('compile.dat',2,130769);
putspr(2,0,199-spr[2].yl,normalput,vaddr);
putspr(1,60,199-spr[1].yl,gameput,vaddr);
putspr(2,120,199-spr[2].yl,normalput,vaddr);
putspr(1,200,199-spr[1].yl,gameput,vaddr);
putspr(1,260,199-spr[1].yl,gameput,vaddr);

hlin:=nhlin;
rectangle(0,0,319,199,cl,vaddr);
randomize;
for i:=1 to nr do InitAPixel(i);

repeat

outtext(55,100,'IS IT SNOWING OR WHAT ?!!',4,cl-1,vaddr);

for i:=1 to nr do
    with snow[i] do
      begin

      if ((thru=true) and (getpixel(x,round(y),vaddr)=cl))
         or (thru=false) then putpixel(x,round(y),0,vaddr);

      y:=y+stepy;
      x:=stepx+x;

      if (x>xo+1) or
         (x<xo-1)
         then stepx:=-stepx;

      case thru of
      false : begin
                if getpixel(x,round(y),vaddr)<>0
                   then
                       if getpixel(x+1,round(y),vaddr)=0
                          then inc(x)
                          else if getpixel(x-1,round(y),vaddr)=0
                                  then dec(x)
                                  else begin
                                       putpixel(x,round(y-1),cl,vaddr);
                                       InitAPixel(i);
                                       end;
                putpixel(x,round(y),cl,vaddr);
              end;
     true : begin
              if getpixel(x,round(y),vaddr)=0 then putpixel(x,round(y),cl,vaddr);
              if y>=198 then begin
                               putpixel(x,round(y),cl,vaddr);
                               InitAPixel(i);
                             end;
            end;
     end;
     end;

flip;
until port[$60]=1;
fadeout(4);
donespr(1);donespr(2);
end;


Begin
End.
