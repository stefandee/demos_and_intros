PROGRAM winter;

uses graphics,crt;

const nr=400;
      movear : array[0..2] of shortint =(-1,0,1);

var snow : array[1..nr,1..3] of integer;
    i : integer;

begin
vga256;
initvscreen;
loadpal('winter.pal');setpal;
loadspr('winter.spr',1);
cls(0,vaddr);
putspr(1,0,0,normalput,vaddr);

randomize;
for i:=1 to nr do begin snow[i,1]:=random(320);snow[i,2]:=random(150)+1;snow[i,3]:=random(3);end;
repeat
for i:=1 to nr do
    begin
    putpixel(snow[i,1],snow[i,2],0,vaddr);
    inc(snow[i,2]);
    if getpixel(snow[i,1],snow[i,2],vaddr)<>0
       then
           if getpixel(snow[i,1]+1,snow[i,2],vaddr)=0
              then inc(snow[i,1])
              else if getpixel(snow[i,1]-1,snow[i,2],vaddr)=0
                      then dec(snow[i,1])
                      else begin
                           putpixel(snow[i,1],snow[i,2]-1,255,vaddr);
                           snow[i,1]:=random(320);snow[i,2]:=random(5)+1;
                           end;
    {snow[i,1]:=movear[snow[i,3]]+snow[i,1];
    inc(snow[i,3]);
    if snow[i,3]>2 then snow[i,3]:=0;
    }

   putpixel(snow[i,1],snow[i,2],255,vaddr);
   end;
flip;
until keypressed;
donevga256;
end.