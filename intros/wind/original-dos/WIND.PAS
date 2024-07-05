program Mercury_winds;
{$M 16384,0,160000}
uses turtle,graphics,crt;

const amp = 33;

var i:integer;
    bxi,byi,bxf,byf : integer;

var
    dev,mix,stat,pro,loop : integer;
    md : string;

{$L MOD-obj.OBJ} 	        { Link in Object file }
{$F+} 				{ force calls to be 'far'}
procedure modvolume(v1,v2,v3,v4:integer); external ; {Can do while playing}
procedure moddevice(var device:integer); external ;
procedure modsetup(var status:integer;device,mixspeed,pro,loop:integer;var str:string); external ;
procedure modstop; external ;
procedure modinit; external;
{$F-}

procedure DrawTree(ung:integer;initang:integer;tl1,tl2 : integer;cl : byte;yy:byte);

procedure RTree(dist:integer);
var x,y,u : real;
begin
x:=ox;y:=oy;u:=ang;
dist:=dist div 2;
if dist<7 then exit;
left(yy);
forw(dist);
rtree(dist);
ox:=x;oy:=y;u:=ang;
right(yy);
forw(dist);
rtree(dist);
end;

begin
ang:=initang;
color:=cl;
forw(tl1);
ang:=initang+ung+yy div 2;
Rtree(tl2);
end;

begin
asm mov ax,$0c02
    int $21
end;

vga256;
initvscreen;
cls(0,vaddr);cls(0,vga);
loadpal('wind.pal');setpal;
loadspr('wind.spr',1);
putspr(1,160-spr[1].xl div 2,199-spr[1].yl-3,normalput,vaddr);

bxf:=280;byf:=120;
bxi:=40;byi:=20;
modinit;
mix := 5050;   {use 5050 for fast gaming }
pro := 0; {Leave at 0}
dev:=7;
modvolume (255,255,255,255);    { Full volume }
md:='wind.mod';
loop:=4;
modsetup ( stat, dev, mix, pro, loop, md );


repeat
for i:=0 to amp do
    begin
    bar(bxi,byi,bxf,byf,0,vaddr);
    ox:=160;oy:=100;
    DrawTree(i,270,20,60,80,45);
    ox:=160;oy:=100;
    DrawTree(i,200,10,30,5,10);
    flip;
    end;
for i:=amp downto -amp do
    begin
    bar(bxi,byi,bxf,byf,0,vaddr);
    ox:=160;oy:=100;
    DrawTree(i,270,20,60,80,45);
    ox:=160;oy:=100;
    DrawTree(i,200,10,30,5,10);
    flip;
    end;
for i:=-amp to 0 do
    begin
    bar(bxi,byi,bxf,byf,0,vaddr);
    ox:=160;oy:=100;
    DrawTree(i,270,20,60,80,45);
    ox:=160;oy:=100;
    DrawTree(i,200,10,30,5,10);
    flip;
    end;
until keypressed;

donevga256;
donevscreen;
modstop;
end.