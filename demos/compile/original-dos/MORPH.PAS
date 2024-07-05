unit morph;

interface

procedure DoMorph;


implementation

uses graphics,types3d;

const
      step = 1;
      N = 36;
      radius : integer = 45;

type mpoint2d = record
             x,y : real;
             col : byte;
             end;
     ptype = array[1..N] of mpoint2d;
     pptype = ^ptype;

var i : integer;
    aux,ant : byte;
    count : integer;
    time  : byte;
    source,dest : pptype;
    ip,jp : point3d;

procedure init_a_thang(thang : byte;var what : pptype);
var i  : integer;
    ct : real;
begin
ct:=2*(pi/N);
case thang of
1 :{init cerc ...}
    for i:=1 to N do
        with what^[i] do
             begin
             x:=radius*sin(ct*i);
             y:=radius*cos(ct*i);
             col:=1+random(254);
             end;
2 :{init card ...}
   for i:=1 to N do
       with what^[i] do
            begin
            x:=radius*(1-cos(ct*i))*sin(ct*i);
            y:=radius*(1-cos(ct*i))*cos(ct*i);
            col:=1+random(254);
            end;
3 :{init card ...}
   for i:=1 to N do
       with what^[i] do
            begin
            x:=radius*cos(ct*i)*cos(ct*i)*cos(ct*i);
            y:=radius*sin(ct*i)*sin(ct*i)*sin(ct*i);
            col:=1+random(254);
            end;
4 :{init card ...}
   for i:=1 to N do
       with what^[i] do
            begin
            x:=radius*cos(ct*i)*sqrt(abs(cos(2*ct*i)));
            y:=radius*sin(ct*i)*sqrt(abs(cos(2*ct*i)));
            col:=1+random(254);
            end;
5 :{init card ...}
   for i:=1 to N do
       with what^[i] do
            begin
            x:=radius*cos(3*ct*i)*cos(ct*i)*cos(ct*i);
            y:=radius*cos(3*ct*i)*cos(ct*i)*sin(ct*i);
            col:=1+random(254);
            end;

end;
end;

procedure DoMorph;

begin

cls(0,vaddr);cls(0,vga);
loadpal('compile.dat',23390);setpal;

count:=0;ant:=3;

with ip do begin x:=1;y:=0;z:=0; end;
with jp do begin x:=0;y:=1;z:=0; end;

time:=0;
new(source);new(dest);

init_a_thang(1,source);
init_a_thang(3,dest);
center:=origin;

repeat
cls(0,vaddr);
rotatepoint(ip,0,0,8);
rotatepoint(jp,0,0,8);

with source^[1] do
     begin
     if x>dest^[1].x then x:=x-1
                    else x:=x+1;
     if y>dest^[1].y then y:=y-1
                    else y:=y+1;
     end;

for i:=2 to N do
    with source^[i] do
         begin
         if x>dest^[i].x then x:=x-step
                        else x:=x+step;
         if y>dest^[i].y then y:=y-step
                        else y:=y+step;
         line(round(orgx+x*ip.x+y*jp.x),round(orgy+x*ip.y+y*jp.y),
              round(orgx+source^[i-1].x*ip.x+source^[i-1].y*jp.x),round(orgy+source^[i-1].x*ip.y+source^[i-1].y*jp.y)
              ,col,vaddr);
         end;

with source^[n] do
line(round(orgx+x*ip.x+y*jp.x),round(orgy+x*ip.y+y*jp.y),
              round(orgx+source^[1].x*ip.x+source^[1].y*jp.x),round(orgy+source^[1].x*ip.y+source^[1].y*jp.y)
              ,col,vaddr);
inc(count);
if count>110
   then begin
        count:=0;
        repeat
        aux:=random(5)+1;
        until ant<>aux;
        ant:=aux;
        init_a_thang(ant,dest);
        inc(time);
        end;
waitretrace;
flip;
until (port[$60]=1) or (time>15);
fadeout(4);
dispose(source);dispose(dest);
end;

Begin
end.
