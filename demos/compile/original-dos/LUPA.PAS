program RT_Lupa;

uses Graphics, Crt;

const step=4;

var f     : file;
    cx,cy : integer;
    dx,dy : integer;
    x,y   : word;
    i,j   : integer;

procedure Rectangle(xi,yi,xf,yf:integer;color:byte);
var i:integer;
begin
for i:=yi to yf do hlin(xi,xf,i,color,vaddr);
end;

function SprColor(nr:byte;x,y:word):byte;
var s,o:word;
begin
with spr[nr] do
     begin
     s:=seg(pspr^);
     o:=ofs(pspr^);
     sprcolor:=mem[s:o+y*xl+x];
     end;
end;

procedure Lupa(cx,cy,dx,dy,radius : integer);
var i,j :integer;
    rp  : integer;
begin
     rp:=radius*radius;
     getimage(2,cx-dx,cy-dy,dx*2,dy*2,vaddr);
     cls(0,vaddr);
        for i:=-dx div 2 to dx div 2 do
            for j:=-dy div 2 to dy div 2 do
                if i*i+j*j<rp then
                    rectangle(cx+i*2,cy+j*2,cx+i*2+2,cy+j*2+2,sprcolor(2,cx+i,cy+j));
     flip;
     donespr(2);
end;

begin



vga256;
initvscreen;
loadpal('chess.pal');
cls(0,vga);
Setpal;
loadspr('chess.spr',1);

dx:=90;
dy:=90;
cx:=160;
cy:=30;
putspr(1,0,0,normalput,vaddr);

{Flip;}
hlin:=Nhlin;
{repeat

if keypressed
   then begin
        case readkey of
        'q' : dec(cy,4);
        'z' : inc(cy,4);
        'o' : dec(cx,4);
        'p' : inc(cx,4);
        end;
        Lupa;
        end;

until false;}

{repeat

for i:=1 to 65 div step do
    begin
    dec(cx,step);inc(cy,step);Lupa;
    end;
for i:=1 to 65 div step do
    begin
    inc(cx,step);inc(cy,step);Lupa;
    end;
for i:=1 to 65 div step do
    begin
    inc(cx,step);dec(cy,step);Lupa;
    end;
for i:=1 to 65 div step do
    begin
    dec(cx,step);dec(cy,step);Lupa;
    end;
until keypressed;
}
cx:=160;
cy:=100;
dx:=160;
dy:=100;
Lupa(160,100,160,100,40);
{cx:=160;
cy:=100;
dx:=160;
dy:=100;
Lupa;
}
repeat until readkey=#13;


donevga256;
donevscreen;

end.



