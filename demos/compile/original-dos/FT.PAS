program fast_textures;
{$R-}
{$M 32768,0,300000}

uses graphics,types3d,crt;

const
      xspeed = 0;
      yspeed = 0;
      zspeed = 0;

var
    mseg,mofs : word;
    walls : obj;
    len,lun : byte;
    i,j : integer;


procedure TLine(x1,y1,x2,y2:integer;where:word;wl:word);

var deltax, deltay, numpixels,
    d, dinc1, dinc2,
    x, xinc1, xinc2,
    y, yinc1, yinc2 : integer;
    screen : word;
    screeninc1, screeninc2 : integer;
    wline : word;

begin

  if x1<0 then x1:=0;
  if x2<0 then x2:=0;
  if y1<0 then y1:=0;
  if y2<0 then y2:=0;
  if x1>319 then x1:=319;
  if x2>319 then x2:=319;
  if y1>199 then y1:=199;
  if y2>199 then y2:=199;


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

  screen := word(Y1) shl 8+word(Y1) shl 6 + x1;
  screeninc1 :=word(word(Yinc1) shl 8+word(Yinc1) shl 6 + word(xinc1));
  screeninc2 :=word(word(Yinc2) shl 8+word(Yinc2) shl 6 + word(xinc2));
  wline:=mofs+82*wl;

  { Draw the pixels }
  asm

    { Use as many registers as are available }
    push ds
    push es

    mov ax,where
    mov es,ax
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
    cmp ah,82
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

    pop es
    pop ds
  end;

end;

procedure Draw(var what : obj);

  var pro  : pobj;
      i,j  : integer;
      fpr  : real;
      cnt  : integer;
      xd1,xd2,pd1,pd2 : real;

begin

  DepthSort(what);

  for i:=1 to what.face do
      with what.form[i] do
      begin
        with p1 do begin x:=x+xspeed;y:=y+yspeed;z:=z+zspeed; end;
        with p2 do begin x:=x+xspeed;y:=y+yspeed;z:=z+zspeed; end;
        with p3 do begin x:=x+xspeed;y:=y+yspeed;z:=z+zspeed; end;
        with p4 do begin x:=x+xspeed;y:=y+yspeed;z:=z+zspeed; end;
        fpr:=z0/(z0+p1.z);pro[i].p1.x:=round(fpr*p1.x)+orgx;pro[i].p1.y:=round(fpr*p1.y)+orgy;
        fpr:=z0/(z0+p2.z);pro[i].p2.x:=round(fpr*p2.x)+orgx;pro[i].p2.y:=round(fpr*p2.y)+orgy;
        fpr:=z0/(z0+p3.z);pro[i].p3.x:=round(fpr*p3.x)+orgx;pro[i].p3.y:=round(fpr*p3.y)+orgy;
        fpr:=z0/(z0+p4.z);pro[i].p4.x:=round(fpr*p4.x)+orgx;pro[i].p4.y:=round(fpr*p4.y)+orgy;
      end;

for j:=1 to what.face do
    with pro[j] do
         begin
           if p3.y-p4.y=0
              then xd1:=10*(p3.x-p4.x)
              else xd1:=(p3.x-p4.x)/(p3.y-p4.y);
           pd1:=p4.x-p4.y*xd1;

           if p1.y-p2.y=0
              then begin
                   xd2:=10*(p1.x-p2.x);
                   end
              else begin
                   xd2:=(p1.x-p2.x)/(p1.y-p2.y);
                   end;
           pd2:=p2.x-p2.y*xd2;

           cnt:=0;
           mseg:=seg(spr[walls.form[j].color].pspr^);mofs:=ofs(spr[walls.form[j].color].pspr^);

           len:=52;{spr[walls.form[j].color].yl;}
           lun:=82;{spr[walls.form[j].color].xl;}

           if p3.y>p4.y
              then for i:=p4.y to p3.y do
                       begin
                         if cnt<=51 then tline(round(xd1*i+pd1),i,round(xd2*(p2.y+i-p4.y)+pd2),p2.y+i-p4.y,vaddr,52-i+p4.y);
                         inc(cnt);
                       end
              else for i:=p3.y to p4.y do
                       begin
                         if cnt<=51 then tline(round(xd1*i+pd1),i,round(xd2*(p1.y+i-p3.y)+pd2),p1.y+i-p3.y,vaddr,i-p3.y);
                         inc(cnt);
                       end;
         end;
end;

BEGIN
vga256;initvscreen;
loadpal('green.pal');setpal;
{read texture map...}
loadspr('face1.spr',1);loadspr('face2.spr',2);loadspr('face3.spr',3);
loadspr('face4.spr',4);

{init...}
walls.face:=4;
walls.core:=origin;
len:=52;lun:=62;

with walls.form[1] do
     begin
     color:=1;
     {len:=spr[color].yl;lun:=spr[color].xl;}
     p1.x:=-lun div 2;p1.y:=-len div 2;p1.z:=-lun div 2;
     p2.x:=-lun div 2;p2.y:=+len div 2;p2.z:=-lun div 2;
     p3.x:=+lun div 2;p3.y:=-len div 2;p3.z:=-lun div 2;
     p4.x:=+lun div 2;p4.y:=+len div 2;p4.z:=-lun div 2;
     end;

with walls.form[2] do
     begin
     color:=2;
     p1.x:=-lun div 2;p1.y:=-len div 2;p1.z:=lun div 2;
     p2.x:=-lun div 2;p2.y:=+len div 2;p2.z:=lun div 2;
     p3.x:=+lun div 2;p3.y:=-len div 2;p3.z:=lun div 2;
     p4.x:=+lun div 2;p4.y:=+len div 2;p4.z:=lun div 2;
     end;

with walls.form[3] do
     begin
     color:=3;
     p1.x:=-lun div 2;p1.y:=-len div 2;p1.z:=-lun div 2;
     p2.x:=-lun div 2;p2.y:=+len div 2;p2.z:=-lun div 2;
     p3.x:=-lun div 2;p3.y:=-len div 2;p3.z:=+lun div 2;
     p4.x:=-lun div 2;p4.y:=+len div 2;p4.z:=+lun div 2;
     end;

with walls.form[4] do
     begin
     color:=4;
     p1.x:=lun div 2;p1.y:=-len div 2;p1.z:=-lun div 2;
     p2.x:=lun div 2;p2.y:=+len div 2;p2.z:=-lun div 2;
     p3.x:=lun div 2;p3.y:=-len div 2;p3.z:=+lun div 2;
     p4.x:=lun div 2;p4.y:=+len div 2;p4.z:=+lun div 2;
     end;

look:=origin;
look.z:=-100;

{
j:=1;
mseg:=seg(spr[walls.form[j].color].pspr^);mofs:=ofs(spr[walls.form[j].color].pspr^);
for i:=1 to 52 do tline(0,i,160,i,vga,i);
readln;
}

repeat
cls(55,vaddr);
rotateobj(walls,1,4,2);
draw(walls);
flip;
until keypressed;

donevga256;
donevscreen;
END.
