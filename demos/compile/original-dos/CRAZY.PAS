unit Crazy;

{two demo in one}
interface

uses graphics,types3d,crt;

procedure DoBalls;

implementation

procedure DoBalls;

const  Mid  = 15;
       No   = 20;
       Ball : array[1..no] of point3d=(
             (x:mid;y:mid;z:mid),(x:mid;y:-mid;z:mid),(x:mid;y:-mid;z:-mid),(x:mid;y:mid;z:-mid),
             (x:-mid;y:mid;z:mid),(x:-mid;y:-mid;z:mid),(x:-mid;y:-mid;z:-mid),(x:-mid;y:mid;z:-mid),
             (x:0;y:mid;z:mid),(x:0;y:-mid;z:mid),(x:0;y:-mid;z:-mid),(x:0;y:mid;z:-mid),
             (x:-mid;y:mid;z:0),(x:-mid;y:-mid;z:0),(x:mid;y:-mid;z:0),(x:mid;y:mid;z:0),
             (x:-mid;y:0;z:mid),(x:-mid;y:0;z:-mid),(x:mid;y:0;z:mid),(x:mid;y:0;z:-mid)
             );

const dz      : shortint =1;
      counter : integer = 0;

var fpr       : real;
    midx,midy : byte;
    i,j       : integer;
    basespr   : array[1..no] of byte;
    aux       : point3d;
    baux      : byte;

begin

cls(0,vga);cls(0,vaddr);
loadpal('compile.dat',22622);setpal;
loadspr('compile.dat',1,31706);midx:=spr[1].xl div 2;midy:=spr[1].yl div 2;
center:=origin;
Hlin:=Nhlin;

repeat

cls(0,vaddr);

center.z:=center.z+dz;
for i:=1 to no do
    begin
    ball[i].z:=ball[i].z+dz;
    rotatepoint(ball[i],0,10,0);
    end;
for i:=1 to no do
    for j:=1 to no do
    if ball[i].z>ball[j].z
       then begin
            aux:=ball[i];
            ball[i]:=ball[j];
            ball[j]:=aux;
            end;
for i:=1 to no do
    begin
    fpr:=z0/(z0+ball[i].z);
    putspr(1,round(fpr*ball[i].x+orgx)-midx,round(fpr*ball[i].y+orgy)-midy,gameput,vaddr);
    end;
case dz of
 1 : if center.z>0 then dz:=-1;
-1 : if center.z<-60 then dz:=1;
end;
waitretrace;
flip;
inc(counter);
until counter>200;

pal:=workpal;
fadeout(3);
donespr(1);
cls(0,vga);cls(0,vaddr);
workpal:=pal;
setpal;

loadspr('compile.dat',1,54611);loadspr('compile.dat',2,54904);loadspr('compile.dat',3,55269);
loadspr('compile.dat',4,55714);loadspr('compile.dat',5,56247);loadspr('compile.dat',6,56876);

loadspr('compile.dat',7,45464);loadspr('compile.dat',8,45757);loadspr('compile.dat',9,46122);
loadspr('compile.dat',10,46567);loadspr('compile.dat',11,47100);loadspr('compile.dat',12,47729);

loadspr('compile.dat',13,31012);loadspr('compile.dat',14,31322);loadspr('compile.dat',15,31706);
loadspr('compile.dat',16,32172);loadspr('compile.dat',17,32705);loadspr('compile.dat',18,33334);

loadspr('compile.dat',19,27902);loadspr('compile.dat',20,28195);loadspr('compile.dat',21,28560);
loadspr('compile.dat',22,29005);loadspr('compile.dat',23,29538);loadspr('compile.dat',24,30167);

for i:=1 to 10 do
    with ball[i] do
         begin
              x:=25*sin((i-1)*36*pi/180);
              z:=25*cos((i-1)*36*pi/180);
              y:=(-i+10)*8-40;
              basespr[i]:=i mod 4;
         end;
for i:=11 to 20 do
    with ball[i] do
         begin
              x:=25*sin((i-11)*36*pi/180);
              z:=25*cos((i-11)*36*pi/180);
              y:=-(-i+10)*8-40;
              basespr[i]:=i mod 4;
         end;


center:=origin;counter:=0;

repeat

for i:=1 to 200 do hlin(0,320,i,115+i mod 15,vaddr);
for i:=1 to no do rotatepoint(ball[i],1,16,0);
for i:=1 to no do
    for j:=1 to no do
    if ball[i].z>ball[j].z
       then begin
            aux:=ball[i];
            ball[i]:=ball[j];
            ball[j]:=aux;
            baux:=basespr[i];
            basespr[i]:=basespr[j];
            basespr[j]:=baux;
            end;
for i:=1 to no do
    begin
    fpr:=z0/(z0+ball[i].z);
    case round(ball[i].z) of
    -300..-15 : baux:=6;
    -14..-5   : baux:=5;
    -4..10  : baux:=4;
    11..25  : baux:=3;
    26..50  : baux:=2;
    51..300  : baux:=1;
    end;
    midx:=spr[baux+basespr[i]*4].xl shr 1;
    midy:=spr[baux+basespr[i]*4].yl shr 1;
    putspr(baux+3*(basespr[i] shl 1),round(fpr*ball[i].x+orgx)-midx,round(fpr*ball[i].y+orgy)-midy,gameput,vaddr);
    end;
waitretrace;
flip;
inc(counter);
until counter>200;

fadeout(4);

for i:=1 to 24 do donespr(i);

end;

Begin

End.

