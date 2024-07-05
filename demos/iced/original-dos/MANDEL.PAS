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
loadpal('blue.pal',0);setpal;
width:=160;height:=160;
crh:=0.9;crl:=-0.9;
cih:=0.9;cil:=-0.9;

xsize:=(crh-crl)/(width);
ysize:=(cih-cil)/(height);
maxiter:=20;ci:=cil;

for y:=0 to height-1 do
    begin
      ci:=ysize*y+cil;
      for x:=0 to width-1 do
          begin
            member:=true;
            zr:=0;zi:=0;
            cr:=xsize*x+crl;
            for i:=1 to maxiter do
                begin
                  newzr:=zr-zr*zr*zr+3*zr*zi*zi+cr;
                  newzi:=zi+zi*zi*zi-1.5*zi*zr*zr+ci;
                  zr:=newzr;
                  zi:=newzi;
                  if zr*zr+zi*zi>4 then begin member:=false;break;end;
                  if port[$60]=1 then halt;
                end;
            putpixel(x,y,i+128
            ,vga)
          end;
    end;
readln;
end.

