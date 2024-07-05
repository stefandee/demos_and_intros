program pixel_fading;

uses graphics;

var i,j:integer;
    k:longint;

procedure pixeling(xb,yb,xe,ye:word);
var xchg:integer;
    nrpixels,x,y:word;
    error:byte;
begin
if xb>xe then begin
              xchg:=xb;
              xb:=xe;
              xe:=xchg;
              end;
if yb>ye then begin
              xchg:=yb;
              yb:=ye;
              ye:=xchg;
              end;

nrpixels:=(xe-xb+1)*(ye-yb+1);
k:=0;
error:=nrpixels div 640;
repeat
    x:=random(xe-xb+1)+xb;
    y:=random(ye-yb+1)+yb;
    if getpixel(x,y,vga)<>0 then begin
                                 putpixel(x,y,0,vga);
                                 inc(k);
                                 end;
until k=nrpixels-error;
for x:=xb to xe do for y:=yb to ye do
    if getpixel(x,y,vga)<>0 then putpixel(x,y,0,vga);
end;

begin
vga256;
loadpal('fight1.pal');
setpal;
for i:=0 to 199 do line(0,i,319,i,224,vga);
pixeling(80,70,240,130);
readln;
donevga256;
end.