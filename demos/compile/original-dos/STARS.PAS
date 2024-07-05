unit stars;

interface

uses graphics,types3d;

procedure DoStars;

implementation

const
      fillcolor : byte=100;
      pir = pi/180;

var star : array[1..2*20] of point3d;
    i,j : integer;
    crtx,crty : integer;
    n,dn,dr : array[1..3] of shortint;
    radius : array[1..3] of integer;
    angle : array[1..3] of integer;
    color : array[1..3] of byte;


procedure scanleft(var x: integer;y : integer);
var v: byte;
begin
repeat
dec(x);
crtx:=x;crty:=y;
v:=getpixel(x,y,vaddr);
until (v=fillcolor) or (x<=0);
inc(x);
end;
procedure scanright(var x: integer;y:integer);
var v:byte;
begin
repeat
inc(x);
v:=getpixel(x,y,vaddr);
until (v=fillcolor) or (x>=319);
dec(x);
end;


function LaFill(seedx,seedy,d,prevxl,prevxr:integer) :integer;
var x,y,xl,xr,v : integer;

begin
y:=seedy;xl:=seedx;xr:=seedx;
scanleft(xl,y);scanright(xr,y);
hlin(xl,xr+1,y,fillcolor,vaddr);
for x:=xl to xr do
    begin
    v:=getpixel(x,y+d,vaddr);
    if (v=0) then x:=lafill(x,y+d,d,xl,xr);
    end;
for x:=xl to prevxl-1 do
    begin
    v:=getpixel(x,y-d,vaddr);
    if (v=0) then x:=lafill(x,y-d,-d,xl,xr);
    end;
for x:=prevxr to xr-1 do
    begin
    v:=getpixel(x,y-d,vaddr);
    if (v=0) then x:=lafill(x,y-d,-d,xl,xr);
    end;
lafill:=xl;
end;

procedure DrawAStar(cx,cy : integer;index : byte);{centrul}
var i : integer;
    expr1,expr2 : real;
    semi : real;

begin
semi:=pi/n[index];
expr1:=angle[index]*pir;

for i:=1 to n[index] do
    begin
    with star[i shl 1] do
         begin
         expr1:=expr1+2*semi;
         x:=radius[index]*sin(expr1)+cx;
         y:=radius[index]*cos(expr1)+cy;
         end;
    with star[(i shl 1)-1] do
         begin
         x:=(radius[index] shr 1)*sin(expr1-semi)+cx;
         y:=(radius[index] shr 1)*cos(expr1-semi)+cy;
         end;
   end;

for i:=2 to 2*n[index] do
    begin
    line(round(star[i-1].x),round(star[i-1].y),round(star[i].x),round(star[i].y),color[index],vaddr);
    end;
line(round(star[1].x),round(star[1].y),round(star[2*n[index]].x),round(star[2*n[index]].y),color[index],vaddr);
if angle[index]>900 then
begin
case dn[index] of
-1 : if n[index]<5 then dn[index]:=1;
1  : if n[index]>9 then dn[index]:=-1;
end;
n[index]:=n[index]+dn[index];
end;

case dr[index] of
-1 : if radius[index]<15 then dr[index]:=1;
1  : if radius[index]>35 then dr[index]:=-1;
end;
radius[index]:=radius[index]+dr[index];
fillcolor:=color[index];
lafill(cx,cy,1,cx-1,cx+1);
end;


procedure DoStars;

begin

cls(0,vaddr);cls(0,vga);
loadpal('compile.dat',23390);setpal;
hlin:=glare;
radius[1]:=11;radius[2]:=29;radius[3]:=11;
dr[1]:=-1;dr[2]:=1;dr[3]:=-1;
dn[1]:=1;dn[2]:=-1;dn[3]:=1;
n[1]:=5;n[2]:=5;n[3]:=5;
angle[1]:=30;angle[2]:=60;angle[3]:=30;
color[1]:=66;color[2]:=160;color[3]:=200;

repeat
cls(0,vaddr);
for i:=1 to 3 do
    begin
    inc(angle[i],10);
    drawastar(orgx-(i-2)*34,orgy,i);
    end;
flip;
until angle[1]>=1800;

fadeout(4);
end;

begin
end.