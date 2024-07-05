unit geometry;

INTERFACE

uses objects,graphics;

type
    rgb= record
           r,g,b:byte;
         end;
    plane=record
            a,b,c,d:real
          end;
    dreapta=record
             i,j,k:real
            end;
    pointstruct=record
                 p:pointer;
                 s,o:word;
                 size:longint
                end;
     sline = record
          p1,p2 : point3d;
          end;

     pline = record
           p1,p2 : point2d;
           end;
     formtype = array[1..100] of sline;
     pformtype= array[1..10] of pline;
     Tpoliedru = object(Tobject)
                      nrvrf  : byte;
                      nrlaturi:byte;
                      center   : point3d;
                      form   : formtype;
                      color  : byte;
                      col:array[1..10] of byte;
                      p1 : point3d;
                      normal:array[1..10] of dreapta;
                      lmare1,lmare2,inalt1,inalt2,lmic  : real;
                      constructor Init;
                      procedure Draw;virtual;
                      destructor Done;virtual;
                 end;

      Tpoligon= object(Tobject)
                      center:point2d;
                      color:byte;
                      p1:point2d;

                      l:real;
                      nrvrf:byte;
                      nrlaturi:byte;
                      ppoint:array[1..10] of point2d;
                      constructor Init;
                      procedure Draw;virtual;
                      procedure fillfast;virtual;
                      destructor Done;virtual;

                 end;
     pointinc=record
               dx,dy,dz:real
              end;
    map=array[1..80,1..80] of byte;

var look,light:point3d;
    p3d,p1:point3d;
    p2d:point3d;
    ccenter,scenter:point3d;
    center:point3d;
    p,screen:plane;
    xmax,ymax:integer;
    px,py,pz,pcolor:pointstruct;{keep the coordinates of x and y for geometric transformations}
    dr:dreapta;
    r:real;
    l:real;
    angle:real;
    poliedru:tpoliedru;
    helpsin,helpcos:real;
    i,j:integer;
    x,y:integer;
    pimage:point3d;
    dimimage:point3d;{dim pe cele 3 axe}
    sh,oh:word;
    bool1,bool2:boolean;
    r1,r2:real;
    virscr:pointer;

Procedure Cls (Col : Byte; Where:word);
procedure getrgbpal(col:byte;var r,g,b:byte);
procedure setrgbpal(col:byte;r,g,b:byte);
function  sgn(a:real):integer;
procedure myline(s_vir,o_vir:word;a,b,c,d:integer;color:byte);
procedure myline13h(s_vir,o_vir:word;x1,y1,x2,y2:integer;color:byte);
procedure translation(p3d:pointinc;var p2d:point3d);

procedure rotation_x(d:dreapta;var p3d:point3d;angle:real);
procedure rotation_y(d:dreapta;var p3d:point3d;angle:real);
procedure rotation_z(d:dreapta;var p3d:point3d;angle:real);

procedure putmypixel(s,o:word;x,y:integer;col:byte);
procedure putimagelook(look:point3d;s,o:word;p3d:point3d;col:byte);
procedure transform3d(p:plane;look,p3d:point3d;var p2d:point3d);
{pct p3d vazut prin planul p din pct look,p2d=proi}
procedure putcilinder(var p3d:point3d;r:real;l:real;ccenter:point3d);{de pe ecran (z=0) pe cilindru
                                       tangent la ecran pe linia
                                       mediana verticala ,si de raza r}
procedure putcilimage(xi:integer;s,o:word);
function  visual(look,p3d:point3d;normal:dreapta):boolean;
procedure morph(var pol1:tpoliedru;pol2:tpoliedru;frames,framesexe:word);{transform pol1 in pol2
                                                   basicaly with the line help}

procedure filltriangle(triangle:tpoliedru;color:byte;frames:integer);
procedure putlight(light,look:point3d;p:plane;var shadow:point3d;p3d:point3d;var col:byte);
procedure sphere(var p3d:point3d;r:real;scenter:point3d);
procedure putsphere(x,y:integer;s,o:word);
function  dist(a,b:point3d):real;
function  modul(nn:dreapta):real;
procedure alloc(p:pointer;var s,o:word;size:word);


IMPLEMENTATION

procedure alloc;
begin
  getmem(p,size);
  s:=seg(p^);
  o:=ofs(p^);
end;


function modul;
begin
  modul:=sqrt(nn.i*nn.i+nn.j*nn.j+nn.k*nn.k);
end;

function dist;
begin
  dist:=sqrt((a.x-b.x)*(a.x-b.x)+(a.y-b.y)*(a.y-b.y)+(a.z-b.z)*(a.z-b.z));
end;

function  visual;
begin
 visual:=((look.x-p3d.x)*normal.i+(look.y-p3d.y)*normal.j+(look.z-p3d.z)*normal.k)>=0;
end;

procedure putcilinder;
var a:real;
begin
  a:=pi-(2*(pimage.x-p3d.x)+l)/(2*r);
  p3d.z:=ccenter.z+r*cos(a);
  p3d.x:=ccenter.x-r*sin(a);
end;

procedure putcilimage;
var normal:dreapta; {for cilinder}
begin
 with normal do begin
   k:=(p3d.z-ccenter.z);
   j:=0;
   i:=(p3d.x-ccenter.x);
 end;
 if visual(look,p3d,normal) then
  for y:=0 to 199 do
    mem[s:o+y shl 8+y shl 6+trunc(p3d.x)]:=mem[sh:oh+y shl 8+y shl 6+xi];
end;

procedure sphere;
begin
  with p3d do begin
    x:=scenter.x+sqrt(r*r-(y-scenter.y)*(y-scenter.y))*(x-scenter.x)/r;
    z:=scenter.z+sqrt(r*r-(y-scenter.y)*(y-scenter.y))*(z-scenter.z)/r;
  end;
end;

procedure putsphere;
var normal:dreapta; {for sphere}

begin
   with normal do begin
   k:=(p3d.z-scenter.z);
   j:=(p3d.y-scenter.y);
   i:=(p3d.x-scenter.x);
 end;
 if visual(look,p3d,normal) then
   mem[s:o+trunc(320*p3d.y+p3d.x)]:=mem[sh:oh+y shl 8+y shl 6+x];

end;

procedure translation;
begin
  p2d.x:=p2d.x+p3d.dx;
  p2d.y:=p2d.y+p3d.dy;
  p2d.z:=p2d.z+p3d.dz;
end;

procedure putlight;
var    normal:dreapta;
begin
    with normal do begin
      i:=p.a;
      j:=p.b;
      k:=p.c
    end;
    if  visual(light,p3d,normal) then begin
       transform3d(p,light,p3d,shadow);
       transform3d(screen,look,shadow,p3d);
       if visual(look,p3d,normal) then
         putmypixel(workseg,workofs,trunc(p3d.y),trunc(p3d.x),col)
    end;
end;

procedure  rotation_z; {rotation  around z_axis and paralels}
var pp:point3d;
begin
 pp:=p3d;
 helpcos:=cos(angle);
 helpsin:=sin(angle);
 with  pp do begin
  p3d.x:=d.i+(x-d.i)*helpcos-(y-d.j)*helpsin;
  p3d.y:=d.j+(x-d.i)*helpsin+(y-d.j)*helpcos;
 end;
end;

procedure  rotation_y;
var pp:point3d;
begin
 helpcos:=cos(angle);
 helpsin:=sin(angle);
 pp:=p3d;
 with  pp do begin
  p3d.x:=d.i+(x-d.i)*helpcos-(z-d.k)*helpsin;
  p3d.z:=d.k+(x-d.i)*helpsin+(z-d.k)*helpcos;
 end;
end;

procedure  rotation_x;
var pp:point3d;
begin
 helpcos:=cos(angle);
 helpsin:=sin(angle);
 pp:=p3d;
 with  pp do begin
  p3d.z:=d.k+(z-d.k)*helpcos-(y-d.j)*helpsin;
  p3d.y:=d.j+(z-d.k)*helpsin+(y-d.j)*helpcos;
 end;
end;

procedure putmypixel;
begin
 mem[s:o+(y shl 8+y shl 6)+x]:=col;
end;

procedure putimagelook;
var normal:dreapta; {for cilinder}
begin
 with normal do begin
   k:=(2*(p3d.z-r));
   j:=0;
   i:=2*p3d.x-l;
 end;
 if visual(look,p3d,normal) then
 mem[s:o+(trunc(p3d.y) shl 8 +trunc(p3d.y) shl 6)+trunc(p3d.x)]:=col;
end;

{procedure transform3d(p:plane;look,p3d:point3d;var p2d:point3d);
{pct p3d vazut prin planul p din pct look,p2d=proi}

procedure transform3d; {getimage of p3d in plane p viewed from look}
var t:real;
    d1,d2,d3:real;
begin
 with p do begin
   d1:=p3d.x-look.x;
   d2:=p3d.y-look.y;
   d3:=p3d.z-look.z;
   t:=-(d+a*look.x+b*look.y+c*look.z)/(a*d1+b*d2+c*d3);
   with p2d do begin
     x:=t*d1+look.x;
     y:=t*d2+look.y;
     z:=t*d3+look.z
   end;
 end;
end;


function sgn;
begin
     if a>0 then sgn:=+1;
     if a<0 then sgn:=-1;
     if a=0 then sgn:=0;
end;

procedure myline;
var u,s,v,d1x,d1y,d2x,d2y,m,n:real;
    i:integer;
begin
     u:= c - a;
     v:= d - b;
     d1x:= SGN(u);
     d1y:= SGN(v);
     d2x:= SGN(u);
     d2y:= 0;
     m:= ABS(u);
     n := ABS(v);
     IF NOT (M>N) then
     BEGIN
          d2x := 0 ;
          d2y := SGN(v);
          m := ABS(v);
          n := ABS(u);
     END;
     s := INT(m / 2);
     FOR i := 0 TO round(m) DO
     BEGIN
          putmypixel(workseg,workofs,a,b,color);
          s := s + n;
          IF not (s<m) THEN
          BEGIN
               s := s - m;
               a:= a +round(d1x);
               b :=b + round(d1y);
          END
          ELSE
          BEGIN
               a := a + round(d2x);
               b := b + round(d2y);
          END;
     end;
END;      {for any resolution}
procedure myline13h;
{especialy for 13h mode}

var screen : word;
    screeninc1, screeninc2 : integer;
    d, dinc1, dinc2,
    x, xinc1, xinc2,
    y, yinc1, yinc2 ,
    i, deltax, deltay, numpixels:integer;

begin
  { Calculate deltax and deltay for initialisation }
  deltax := abs(x2 - x1);
  deltay := abs(y2 - y1);

  { Initialize all vars based on which is the independent variable }
  if deltax >= deltay then
    begin

      { x is independent variable }
      numpixels := deltax + 1;
      d := ( deltay shl 1) - deltax;
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
      d := (deltax shl 1) - deltay;
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
  screen := word(y1) shl 8+word(y1) shl 6 + x1;
  screeninc1 := yinc1 shl 8+yinc1 shl 6 + xinc1;
  screeninc2 := yinc2 shl 8 +yinc2 shl 6+ xinc2;

  { Draw the pixels }
  asm

    { Use as many registers as are available }
    push s_vir
    pop es
   { mov ax,screen
    add ax,o_vir}

    mov di,screen
    mov dx, d

    mov al, color
    mov cx, numpixels
    mov bx, dinc1

    @bres1:

    { Draw the current pixel and compare the decision variable to 0 }
    mov es:[di], al
    cmp dx, 0
    jnl @bres2

    { D < 0 }
    add dx,bx { bx = dinc1 }
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

Procedure Cls;
   { This clears the screen to the specified color }
BEGIN
     asm
        push    es
        mov     cx, 32000;
        mov     es,where
        xor     di,di
        mov     al,col
        mov     ah,al
        rep     stosw
        pop     es
     End;
END;


constructor tpoliedru.init;
begin

if nrlaturi=12 then begin

form[1].p1:=p1;p1.z:=p1.z-lmare1;form[1].p2:=p1;
form[2].p1:=p1;p1.x:=p1.x+lmare2;form[2].p2:=p1;
form[3].p1:=p1;p1.z:=p1.z+lmare1;form[3].p2:=p1;
form[4].p1:=p1;p1.x:=p1.x-lmare2;form[4].p2:=p1;

form[5].p1:=p1;p1.y:=p1.y-inalt1;
form[5].p2:=p1;

form[6].p1:=p1;p1.z:=p1.z-lmare1;form[6].p2:=p1;
form[7].p1:=p1;p1.x:=p1.x+lmare2;form[7].p2:=p1;
form[8].p1:=p1;p1.z:=p1.z+lmare1;form[8].p2:=p1;
form[9].p1:=p1;p1.x:=p1.x-lmare2;form[9].p2:=p1;

form[10].p1:=form[6].p2;form[10].p2:=form[1].p2;
form[11].p1:=form[7].p2;form[11].p2:=form[2].p2;
form[12].p1:=form[8].p2;form[12].p2:=form[3].p2;


{ with center do begin
   x:=0;
   y:=lmic*sqrt(2/3);
   z:=0;
 end;
  p1:=center;
  p1.z:=-lmic/sqrt(3);

  form[1].p1:=p1;
  form[2].p1:=p1;
  form[3].p1:=p1;
  form[1].p2.x:=-lmic*sqrt(2)/2;
  form[1].p2.y:=lmic*sqrt(3/2);
  form[1].p2.z:=0;

  form[2].p2.z:=0;
  form[2].p2.x:=0;
  form[2].p2.y:=0;

  form[3].p2.x:=lmic/sqrt(2);
  form[3].p2.y:=form[1].p2.y;
  form[3].p2.z:=0;
  p1.z:=-p1.z;
  for i:=1 to 3 do begin
   form[i+3].p2:=form[i].p2;
   form[i+3].p1:=p1;
  end;
  form[7].p1:=form[1].p2;
  form[7].p2:=form[4].p2;

  form[9].p1:=form[2].p2;
  form[9].p2:=form[5].p2;

  form[11].p1:=form[3].p2;
  form[11].p2:=form[6].p2;

  form[8].p1:=form[2].p2;
  form[8].p2:=form[4].p2;

  form[10].p1:=form[3].p2;
  form[10].p2:=form[5].p2;

  form[12].p1:=form[1].p2;
  form[12].p2:=form[6].p2;

 }
end
else begin
{form[1].p1:=p1;p1.z:=p1.z-lmic;form[1].p2:=p1;
form[2].p1:=p1;p1.x:=p1.x+lmic;form[2].p2:=p1;
form[3].p1:=p1;p1.z:=p1.z+lmic;form[3].p2:=p1;
form[4].p1:=p1;p1.x:=p1.x-lmic;form[4].p2:=p1;

form[5].p1:=p1;p1.y:=p1.y-inalt1;p1.x:=p1.x-(lmare1-lmic)/2;p1.z:=p1.z+(lmare1-lmic)/2;
form[5].p2:=p1;

form[6].p1:=p1;p1.z:=p1.z-lmare1;form[6].p2:=p1;
form[7].p1:=p1;p1.x:=p1.x+lmare1;form[7].p2:=p1;
form[8].p1:=p1;p1.z:=p1.z+lmare1;form[8].p2:=p1;
form[9].p1:=p1;p1.x:=p1.x-lmare1;form[9].p2:=p1;

form[10].p1:=form[6].p2;form[10].p2:=form[1].p2;
form[11].p1:=form[7].p2;form[11].p2:=form[2].p2;
form[12].p1:=form[8].p2;form[12].p2:=form[3].p2;

p1.y:=p1.y+inalt2+inalt1;
p1.x:=p1.x+(lmare1-lmare2)/2;
p1.z:=p1.z+(lmare2-lmare1)/2;

form[13].p1:=p1;p1.z:=p1.z-lmare2;form[13].p2:=p1;
form[14].p1:=p1;p1.x:=p1.x+lmare2;form[14].p2:=p1;
form[15].p1:=p1;p1.z:=p1.z+lmare2;form[15].p2:=p1;
form[16].p1:=p1;p1.x:=p1.x-lmare2;form[16].p2:=p1;

form[17].p1:=form[1].p1;
form[17].p2:=form[13].p1;

form[18].p1:=form[1].p2;form[18].p2:=form[13].p2;
form[19].p1:=form[2].p2;form[19].p2:=form[14].p2;
form[20].p1:=form[3].p2;form[20].p2:=form[15].p2;
end; }
{.......................................}
if bool2 then begin
with center do begin
  x:=lmic;
  y:=lmic;
  z:=lmic;
end;
with form[1].p1 do begin
   x:=lmic;
   y:=lmic;
   z:=0 ;
end;
with form[1].p2 do begin
   x:=0;
   y:=lmic;
   z:=lmic;
end;

form[2].p1:=form[1].p2;

with form[2].p2 do begin
   x:=lmic;
   y:=lmic;
   z:=2*lmic;
end;

form[3].p1:=form[2].p2;
with form[3].p2 do begin
   x:=2*lmic;
   y:=lmic;
   z:=lmic;
end;

form[4].p1:=form[3].p2;
form[4].p2:=form[1].p1;

for  i:=1 to 4 do
 form[i+4]:=form[i];

with form[9].p1 do begin
   x:=0;
   y:=lmic;
   z:=lmic;
end;
with form[9].p2 do begin
   x:=r1;
   y:=lmic;
   z:=r1;
end;
form[10].p1:=form[9].p2;
form[10].p2:=form[9].p1;
with form[11].p1 do begin
   x:=0;
   y:=lmic;
   z:=lmic;
end;
with form[11].p2 do begin
   x:=r1;
   y:=lmic;
   z:=r2;
end;

form[12].p1:=form[11].p2;
form[12].p2:=form[11].p1;

with form[13].p1 do begin
   x:=lmic;
   y:=lmic;
   z:=2*lmic;
end;
with form[13].p2 do begin
   x:=r1;
   y:=lmic;
   z:=r2;
end;

form[14].p1:=form[13].p2;
form[14].p2:=form[13].p1;

with form[15].p1 do begin
   x:=lmic;
   y:=lmic;
   z:=2*lmic;
end;

with form[15].p2 do begin
   x:=r2;
   y:=lmic;
   z:=r2;
end;

form[16].p1:=form[15].p2;
form[16].p2:=form[15].p1;

with form[17].p1 do begin
   x:=2*lmic;
   y:=lmic;
   z:=lmic;
end;

with form[17].p2 do begin
   x:=r2;
   y:=lmic;
   z:=r2;
end;

form[18].p1:=form[17].p2;
form[18].p2:=form[17].p1;

with form[19].p1 do begin
   x:=2*lmic;
   y:=lmic;
   z:=lmic;
end;

with form[19].p2 do begin
   x:=r2;
   y:=lmic;
   z:=r1;
end;

form[20].p1:=form[19].p2;
form[20].p2:=form[19].p1;

with form[21].p1 do begin
   x:=lmic;
   y:=lmic;
   z:=0;
end;

with form[21].p2 do begin
   x:=r2;
   y:=lmic;
   z:=r1;
end;


form[22].p1:=form[21].p2;
form[22].p2:=form[21].p1;


with form[23].p1 do begin
   x:=lmic;
   y:=lmic;
   z:=0;
end;

with form[23].p2 do begin
   x:=r1;
   y:=lmic;
   z:=r1;
end;

form[24].p1:=form[23].p2;
form[24].p2:=form[23].p1;

end;

{.......................................}
if bool1 then begin
with center do begin
  x:=lmic;
  y:=lmic;
  z:=lmic
end;
with form[1].p1 do begin
   x:=lmic;
   y:=0;
   z:=0;
end;
with form[1].p2 do begin
   x:=0;
   y:=0;
   z:=lmic;
end;

form[2].p1:=form[1].p2;
with form[2].p2 do begin
   x:=lmic;
   y:=0;
   z:=2*lmic;
end;

form[3].p1:=form[2].p2;
with form[3].p2 do begin
   x:=2*lmic;
   y:=0;
   z:=lmic;
end;

form[4].p1:=form[3].p2;
form[4].p2:=form[1].p1;

with form[5].p1 do begin
   x:=lmic;
   y:=2*lmic;
   z:=0;
end;
with form[5].p2 do begin
   x:=0;
   y:=2*lmic;
   z:=lmic;
end;

form[6].p1:=form[5].p2;
with form[6].p2 do begin
   x:=lmic;
   y:=2*lmic;
   z:=2*lmic;
end;

form[7].p1:=form[6].p2;
with form[7].p2 do begin
   x:=2*lmic;
   y:=2*lmic;
   z:=lmic;
end;

form[8].p1:=form[7].p2;
form[8].p2:=form[5].p1;

form[9].p1:=form[1].p2;
with form[9].p2 do begin
   x:=0;
   y:=lmic;
   z:=0;
end;

form[10].p1:=form[9].p2;
form[10].p2:=form[5].p2;

form[11].p1:=form[10].p2;
with form[11].p2 do begin
   x:=0;
   y:=lmic;
   z:=2*lmic;
end;

form[12].p1:=form[11].p2;
form[12].p2:=form[1].p2;

form[13].p1:=form[2].p2;
form[13].p2:=form[11].p2;

form[14].p1:=form[13].p2;
form[14].p2:=form[6].p2;

form[15].p1:=form[14].p2;
with form[15].p2 do begin
   x:=2*lmic;
   y:=lmic;
   z:=2*lmic;
end;

form[16].p1:=form[15].p2;
form[16].p2:=form[2].p2;

form[17].p1:=form[3].p2;
form[17].p2:=form[15].p2;

form[18].p1:=form[17].p2;
form[18].p2:=form[7].p2;

form[19].p1:=form[18].p2;
with form[19].p2 do begin
   x:=2*lmic;
   y:=lmic;
   z:=0;
end;

form[20].p1:=form[19].p2;
form[20].p2:=form[3].p2;

form[21].p1:=form[4].p2;
form[21].p2:=form[19].p2;

form[22].p1:=form[21].p2;
form[22].p2:=form[8].p2;

form[23].p1:=form[22].p2;
form[23].p2:=form[9].p2;

form[24].p1:=form[23].p2;
form[24].p2:=form[4].p2;
end;
end;
end;

procedure tpoliedru.draw;
var aa,bb:point3d;
begin

  for i:=1 to nrlaturi do  begin

         transform3d(screen,look,form[i].p1,aa);
         transform3d(screen,look,form[i].p2,bb);
         if (aa.x>=0) and (bb.x>=0) and (aa.x<=320) and (bb.x<=320)
         and (aa.y>=0) and (bb.y>=0) and (aa.y<=200) and (bb.y<=200) then
         myline13h(workseg,workofs,trunc(aa.x),trunc(aa.y),trunc(bb.x),trunc(bb.y),color);


   end;
end;

procedure morph;
var param :array[1..40,1..2] of real;
    mmorph:array[1..40,1..2,'x'..'z'] of boolean;
    drepte:array[1..40,1..2] of pointinc;
    aux:real;
    j:integer;
begin
  for i:=1 to pol1.nrlaturi do begin
        mmorph[i,1,'x']:=false;
        mmorph[i,2,'x']:=false;
        mmorph[i,1,'y']:=false;
        mmorph[i,2,'y']:=false;
        mmorph[i,1,'z']:=false;
        mmorph[i,2,'z']:=false;
        with drepte[i,1] do begin
          dx:=pol2.form[i].p1.x-pol1.form[i].p1.x;
          dy:=pol2.form[i].p1.y-pol1.form[i].p1.y;
          dz:=pol2.form[i].p1.z-pol1.form[i].p1.z;
          param[i,1]:=dz/frames;
          if dz=0 then begin
             mmorph[i,1,'z']:=true;
             param[i,1]:=dy/frames;

             if dy=0 then begin
                mmorph[i,1,'y']:=true;
                param[i,1]:=dx/frames;

                if dx=0 then begin
                   mmorph[i,1,'x']:=true;
                   param[i,1]:=0;
                end;
             end;
          end;
        end;
        with drepte[i,2] do begin
          dx:=pol2.form[i].p2.x-pol1.form[i].p2.x;
          dy:=pol2.form[i].p2.y-pol1.form[i].p2.y;
          dz:=pol2.form[i].p2.z-pol1.form[i].p2.z;
          param[i,2]:=dz/frames;
          if dz=0 then begin
             mmorph[i,2,'z']:=true;
             param[i,2]:=dy/frames;

             if dy=0 then begin
                mmorph[i,2,'y']:=true;
                param[i,2]:=dx/frames;
                if dx=0 then  begin
                   mmorph[i,2,'x']:=true;
                   param[i,2]:=0;
                end;
             end;
          end;
        end;
  end;

  for j:=1 to framesexe do begin
   for i:=1 to pol1.nrlaturi do begin
      if (param[i,1]<>0) then begin
        if not mmorph[i,1,'z'] then begin
           pol1.form[i].p1.z:=pol1.form[i].p1.z+param[i,1];
           aux:=(pol1.form[i].p1.z-pol2.form[i].p1.z)/drepte[i,1].dz;

           pol1.form[i].p1.y:=drepte[i,1].dy*aux+pol2.form[i].p1.y;

           pol1.form[i].p1.x:=drepte[i,1].dx*aux+pol2.form[i].p1.x;

        end;
        if (mmorph[i,1,'z']) and not(mmorph[i,1,'y']) then begin
           pol1.form[i].p1.y:=pol1.form[i].p1.y+param[i,1];
           aux:=(pol1.form[i].p1.y-pol2.form[i].p1.y)/drepte[i,1].dy;

           pol1.form[i].p1.x:=drepte[i,1].dx*aux+pol2.form[i].p1.x;
        end;
        if (mmorph[i,1,'z']) and (mmorph[i,1,'y']) then
           pol1.form[i].p1.x:=pol1.form[i].p1.x+param[i,1];
      end;
      if (param[i,2]<>0) then begin
        if not mmorph[i,2,'z'] then begin
           pol1.form[i].p2.z:=pol1.form[i].p2.z+param[i,2];
           aux:=(pol1.form[i].p2.z-pol2.form[i].p2.z)/drepte[i,2].dz;

           pol1.form[i].p2.y:=drepte[i,2].dy*aux+pol2.form[i].p2.y;

           pol1.form[i].p2.x:=drepte[i,2].dx*aux+pol2.form[i].p2.x;

        end;
        if (mmorph[i,2,'z']) and not(mmorph[i,2,'y']) then begin
           pol1.form[i].p2.y:=pol1.form[i].p2.y+param[i,2];
           aux:=(pol1.form[i].p2.y-pol2.form[i].p2.y)/drepte[i,2].dy;

           pol1.form[i].p2.x:=drepte[i,2].dx*aux+pol2.form[i].p2.x;
        end;
        if (mmorph[i,2,'z']) and (mmorph[i,2,'y']) then
           pol1.form[i].p2.x:=pol1.form[i].p2.x+param[i,2];
      end;
   end;

   fillchar(mem[workseg:workofs],64000,0);

   tpoliedru(pol1).draw;
   flip(workseg,workofs,$a000,0,32000);
  end;

 {  for i:=1 to pol1.nrlaturi do begin
    pol1.form[i]:=pol2.form[i]
   end;
   fillchar(mem[workseg:workofs],64000,0);
   tpoliedru(pol1).draw;
   flip(workseg,workofs,$a000,0,32000);}
end;

procedure filltriangle;
var drepte:array[1..2] of pointinc;
    aux:real;
    param:array[1..2] of real;
    mmorph:array[1..2,'x'..'z'] of boolean;
    aa,bb:point3d;
    final:point3d;
begin
 aa:=triangle.form[1].p1;
 bb:=triangle.form[3].p1;
 final:=triangle.form[2].p1;
 with triangle do
  for i:=1 to 2 do begin
        mmorph[i,'x']:=false;
        mmorph[i,'x']:=false;
        mmorph[i,'y']:=false;
        mmorph[i,'y']:=false;
        mmorph[i,'z']:=false;
        mmorph[i,'z']:=false;

    with drepte[i] do begin   {pct 1 si 2 resp 2 si 3}
      dx:=form[i].p2.x-form[i].p1.x;
      dy:=form[i].p2.y-form[i].p1.y;
      dz:=form[i].p2.z-form[i].p1.z;
          param[i]:=dz/frames;
          if dz=0 then begin
             mmorph[i,'z']:=true;
             param[1]:=dy/frames;

             if dy=0 then begin
                mmorph[i,'y']:=true;
                param[1]:=dx/frames;

                if dx=0 then begin
                   mmorph[i,'x']:=true;
                   param[1]:=0;
                end;
             end;
          end;
    end;
  end;
    for i:=1 to frames do begin
      if (param[1]<>0) then begin
        if not mmorph[1,'z'] then begin
           aa.z:=aa.z+param[1];
           aux:=(aa.z-final.z)/drepte[1].dz;

           aa.y:=drepte[1].dy*aux+final.y;

           aa.x:=drepte[1].dx*aux+final.x;

        end;
        if (mmorph[1,'z']) and not(mmorph[1,'y']) then begin
           aa.y:=aa.y+param[1];
           aux:=(aa.y-final.y)/drepte[1].dy;

           aa.x:=drepte[1].dx*aux+final.x;
        end;
        if (mmorph[1,'z']) and (mmorph[1,'y']) then
           aa.x:=aa.x+param[1];
      end;

      {second line}
      if (param[2]<>0) then begin
        if not mmorph[2,'z'] then begin
           bb.z:=bb.z-param[2];
           aux:=(bb.z-final.z)/drepte[2].dz;

           bb.y:=drepte[2].dy*aux+final.y;

           bb.x:=drepte[2].dx*aux+final.x;

        end;
        if (mmorph[2,'z']) and not(mmorph[2,'y']) then begin
           bb.y:=bb.y-param[2];
           aux:=(bb.y-final.y)/drepte[2].dy;

           bb.x:=drepte[2].dx*aux+final.x;
        end;
        if (mmorph[2,'z']) and (mmorph[2,'y']) then
           bb.x:=bb.x-param[2];
      end;
      transform3d(p,look,aa,p2d);
      transform3d(p,look,bb,p3d);
      myline13h(workseg,workofs,trunc(p2d.x),trunc(p2d.y),trunc(p3d.x),trunc(p3d.y),color);
    end;
   flip(workseg,workofs,$a000,0,32000);
end;

destructor tpoliedru.done;
begin
end;

constructor tpoligon.init;
begin


end;

procedure tpoligon.draw;
begin
  for i:=1 to nrvrf do

    myline13h(workseg,workofs,trunc(ppoint[i].x),trunc(ppoint[i].y),
               trunc(ppoint[i+1].x),trunc(ppoint[i+1].y),color);

end;

procedure tpoligon.fillfast;
var pp:array[1..11] of point2d;
    pminy,pmaxy:real;
    plecare,sosire:integer;
    p:integer;
    x:array[1..2] of real;
    tg,d:array[1..10] of real;
begin

  pp[nrvrf+1]:=pp[1];

for i:=1 to nrvrf do begin
 if  pp[i].x<>pp[i+1].x then begin
   tg[i]:=(pp[i].y-pp[i+1].y)/(pp[i].x-pp[i+1].x);
   d[i]:=pp[i].y-tg[i]*pp[i].x
  end
  else  tg[i]:=100000;
end;

  for i:=1 to nrvrf do
    myline13h(workseg,workofs,trunc(pp[i].x),trunc(pp[i].y),trunc(pp[i+1].x),trunc(pp[i+1].y),color);

  pminy:=pp[1].y;
  pmaxy:=pp[1].y;
  for i:=2 to nrvrf do begin
     if pminy>=pp[i].y then pminy:=pp[i].y;
     if pmaxy<=pp[i].y then pmaxy:=pp[i].y
  end;
  plecare:=trunc(pminy);
  sosire:=trunc(pmaxy);
  for j:=plecare to sosire do begin
      p:=1;
      for i:=1 to nrvrf do begin
        if (tg[i]<>0) and (tg[i]<>100000) then
          if  (j >=min(pp[i].y,pp[i+1].y))  and
              (j <=max(pp[i].y,pp[i+1].y)) then  begin
                  x[p]:=(j-d[i])/tg[i];
                  inc(p);
           end;
        if tg[i]=100000 then
          if (j<=max(pp[i].y,pp[i+1].y)) and (j>=min(pp[i].y,pp[i+1].y))  then
            begin
                  x[p]:=pp[i].x;
                  inc(p);
            end;
      end;
        if p>=3 then
          myline13h(workseg,workofs,trunc(x[1]),j,trunc(x[2]),j,color);
    end;



end;

destructor tpoligon.done;
begin
end;

procedure setrgbpal;
Begin
   Port[$3c8] := Col;
   Port[$3c9] := R;
   Port[$3c9] := G;
   Port[$3c9] := B;
End;

procedure getrgbpal;
Begin
   Port[$3c7] := Col;
   r:=Port[$3c9] ;
   g:=Port[$3c9] ;
   b:=Port[$3c9] ;
End;

begin
{ dimimage:=64000;  }
 xmax:=320;
 ymax:=200;
 with p do begin
  a:=0;
  b:=0;
  c:=1;
  d:=0
 end;
{  px.size:=2*dimimage;
  py.size:=2*dimimage;
  pcolor.size:=dimimage;
  with px do begin
    getmem(p,size);
    s:=seg(p^);
    o:=ofs(p^);
  end;
  with pz do begin
    getmem(p,size);
    s:=seg(p^);
    o:=ofs(p^);
  end;
  with pcolor do begin
    getmem(p,size);
    s:=seg(p^);
    o:=ofs(p^);
  end;}
 r:=100;
 l:=320;
 with look do begin
   z:=-100;
   x:=160;
   y:=100;
 end;
 with screen do begin
   a:=0;
   b:=0;
   c:=1;
   d:=0
 end;
end.