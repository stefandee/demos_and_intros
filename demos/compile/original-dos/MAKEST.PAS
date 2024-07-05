
type PTab    = array[0..360,1..2] of integer;

var t : ptab;
    i : integer;
    f : file of Ptab;

begin

for i:=0 to 360 do
    begin
    t[i,1]:=round(16384*sin(i*pi/180));
    t[i,2]:=round(16384*cos(i*pi/180));
    end;

assign(f,'speedtab.sc');rewrite(f);
write(f,t);
close(f);
end.

