uses graphics;

const orgx = 160;
      orgy = 100;

var crl,crh,cih,cil,ci,cr,zr,zi,newzr,newzi : real;
    maxiter : integer;
    i,width,height : integer;
    xsize,ysize : real;
    x,y : integer;
    member : boolean;
    aux1,aux2 : real;

begin

vga256;
loadpal('green.pal');setpal;
width:=80;height:=50;
crh:=1.3232;crl:=-1;
cih:=-1.5437437;cil:=0;

xsize:=2*(crh-crl)/width;
ysize:=2*(cih-cil)/height;
maxiter:=255;ci:=cil;

for y:=0 to height-1 do
    begin
      cr:=crl;
      for x:=0 to width-1 do
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
                  if {(aux1>2) or (aux2>2) or} (aux1+aux2>4) then break;
                  if port[$60]=1 then halt;
                end;
            color := 255-i mod 255
						if color<>255 then putpixel(x+orgx,y+orgy,color,vga);
            cr:=xsize+cr;
          end;
      ci:=ysize+ci;
    end;

readln;
end.

