program morpin;

uses graphics,types3d,crt;

const beg = -pi*20;
      fin = pi*20;
      zoom : byte = 50;
var i : integer;
    count : real;
    color : byte;
    points : array[1..800,1..2] of longint;
    param : real;

begin

vga256;initvscreen;
loadpal('default.pal');setpal;
cls(0,vaddr);

repeat
cls(0,vaddr);
i:=1;count:=beg;param:=param+0.1;

repeat
count:=count+1;
inc(color);
points[i,1]:=orgx+round(zoom*cos((param/10)*count)*cos(count)*cos(count));
points[i,2]:=orgy+round(zoom*cos((param/10)*count)*cos(count)*sin(count));
putpixel(points[i,1],points[i,2],30+color mod 50,vaddr);

inc(i);
until count>abs(fin)+abs(beg);
flip;
until keypressed;
end.
