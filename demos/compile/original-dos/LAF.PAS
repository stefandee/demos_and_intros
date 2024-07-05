program laf;
{$M 16384,0,100000}

uses graphics;

const up=-1;
      down=1;
      fillvalue=255;
      margin=200;
      ilev:integer=0;
      pf:longint=0;

procedure scanleft(var x: integer;y : integer);
var v:integer;
begin
repeat
dec(x);
v:=getpixel(x,y,vga);
until (v<>0);
inc(x);
end;
procedure scanright(var x: integer;y:integer);
var v:integer;
begin
repeat
inc(x);
v:=getpixel(x,y,vga);
until (v<>0);
dec(x);
end;


function LaFill(seedx,seedy,d,prevxl,prevxr:integer):integer;
var x,y,xl,xr,v : integer;
begin
y:=seedy;xl:=seedx;xr:=seedx;
scanleft(xl,y);scanright(xr,y);
hlin(xl,xr,y,fillvalue,vga);
for x:=xl to xr do
    begin
    v:=getpixel(x,y+d,vga);
    if (v=0) then x:=lafill(x,y+d,d,xl,xr);
    end;
for x:=xl to prevxl-1 do
    begin
    v:=getpixel(x,y-d,vga);
    if (v=0) then x:=lafill(x,y-d,-d,xl,xr);
    end;
for x:=prevxr to xr-1 do
    begin
    v:=getpixel(x,y-d,vga);
    if (v=0) then x:=lafill(x,y-d,-d,xl,xr);
    end;
inc(ilev);
lafill:=xl;
end;

begin
vga256;
loadpal('default.pal');setpal;
hlin:=nhlin;
rectangle(0,0,100,100,margin,vga);
rectangle(60,60,200,200,margin,vga);
pf:=lafill(51,51,-1,51,51);
readln;
end.