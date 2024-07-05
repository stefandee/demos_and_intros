uses graphics;

var crl,crh,cih,cil,ci,cr,zr,zi,newzr,newzi : real;
    maxiter : integer;
    i,width,height : integer;
    xsize,ysize : real;
    x,y : integer;
    member : boolean;
    aux : real;

begin

vga256;
loadpal('stand.pal',0);setpal;
width:=320;height:=200;
crh:=0.5;crl:=-0.5;
cih:=0.5;cil:=-0.5;

xsize:=4*(crh-crl)/(width);
ysize:=4*(cih-cil)/(height);
maxiter:=15;ci:=cil;

for y:=0 to height-1 do
    begin
      ci:=ysize*y+cil;
      for x:=0 to width-1 do
          begin
            member:=true;
            zr:=0.5;zi:=0;
            cr:=xsize*x+crl;
            for i:=1 to maxiter do
                begin
                  newzr:=zr-zr*zr*zr+3*zr*zi*zi+cr;
                  newzi:=zi+zi*zi*zi-3*zi*zr*zr+ci;
                  zr:=newzr;
                  zi:=newzi;
                  if zr*zr+zi*zi>4 then begin member:=false;break;end;
                  if port[$60]=1 then halt;
                end;
            putpixel(x,y,i-1 mod 255,vga)
          end;
    end;
readln;
end.

