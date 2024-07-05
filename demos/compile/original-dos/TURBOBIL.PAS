program turbobil;
{$R-}
uses graphics,crt;

type calc=function(t:integer):real;

const nrpct=35;
      p=pi/180;

var func : array[1..5,1..2] of calc;
    time,cnt : byte;

procedure Rectangle(xi,yi,xf,yf:integer;color:byte);
var i:integer;
begin
for i:=yi to yf do hlin(xi,xf,i,color,vaddr);
end;

function retx(t:integer):real;
var arg : real;
begin
arg:=t*p;
retx:=t div 2;{70*sqr(cos(arg))*cos(arg);}
end;

function rety(t:integer):real;
var arg : real;
begin
arg:=t*p;
rety:=70*cos(arg);
end;

function retx1(t:integer):real;
var arg : real;
begin
arg:=t*p;
retx1:=70*cos(arg);
end;

function rety1(t:integer):real;
var arg : real;
begin
arg:=t*p;
rety1:=40*sin(arg);
end;


var t,i,j:integer;
    rx,ry:integer;

begin

vga256;
initvscreen;
loadpal('demo.pal');
hlin:=Glare;
setpal;
cls(0,vga);

t:=10;
time:=1;cnt:=1;

repeat
inc(t,3);
cls(0,vaddr);
i:=t;
func[1,1]:=retx;func[1,2]:=rety;
func[2,1]:=retx1;func[2,2]:=rety1;

for j:=1 to nrpct do
    begin
    rx:=160+round(func[cnt,1](i mod 360));
    ry:=090+round(func[cnt,2](i mod 360));
    if rx>320 then rx:=rx mod 320;
    rectangle(rx,ry,rx+4,ry+4,random(254)+1);
    dec(i,7);
    end;
inc(time);
if time>50
   then begin
        inc(cnt);
        time:=1;
        if cnt>2 then cnt:=1;
        end;
Flip;
until keypressed;

donevga256;
donevscreen;

end.