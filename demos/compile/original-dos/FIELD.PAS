program starfield;

uses graphics;

const orgx = 160;
      orgy = 100;
      No         = 200;

var stars  : array[1..NO,1..3] of integer;
    pro    : array[1..No,1..2] of integer;
    i,x,y  : integer;
    col    : byte;

procedure InitAStar(i : integer);
begin
    stars[i,1]:=random(20);dec(stars[i,1],10);
    stars[i,2]:=random(20);dec(stars[i,2],10);
    stars[i,3]:=random(20)+30;
    pro[i,1]:=orgx+(stars[i,1] shl 7) div stars[i,3];
    pro[i,2]:=orgy+(stars[i,2] shl 7) div stars[i,3];
end;


begin

vga256;Initvscreen;
loadpal('blue.pal');setpal;

for i:=1 to No do InitAStar(i);
randomize;

repeat

cls(0,vaddr);
for i:=1 to No do
    begin
    if (stars[i,3]<>0)
       then begin
            pro[i,1]:=orgx+(stars[i,1] shl 7) div stars[i,3];
            pro[i,2]:=orgy+(stars[i,2] shl 7) div stars[i,3];
            end;

    if (stars[i,3]<-30) or (pro[i,1]<LeftClip) or (pro[i,1]>RightClip)
       or (pro[i,2]<topClip) or (pro[i,2]>botClip) then InitAStar(i);

    col:=60;
    case stars[i,3] of
    -200..0 : col:=255;
    1..20   : col:=210;
    21..40  : col:=140;
    41..61  : col:=90;
    end;

    putpixel(pro[i,1],pro[i,2],col,vaddr);

    dec(stars[i,3]);
    end;
flip;
until port[$60]=1;

end.