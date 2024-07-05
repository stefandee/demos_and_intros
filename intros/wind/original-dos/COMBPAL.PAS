uses graphics;
var p1,p2,p3 : paltype;
    i:integer;
    f:file;
begin
loadpal('sun.pal');p1:=workpal;
loadpal('green.pal');p2:=workpal;
for i:=128 to 255 do
    begin
    p3[i,1]:=p1[i,1];
    p3[i,2]:=p1[i,2];
    p3[i,3]:=p1[i,3];
    end;
for i:=0 to 127 do
    begin
    p3[i,1]:=p2[i+128,1];
    p3[i,2]:=p2[i+128,2];
    p3[i,3]:=p2[i+128,3];
    end;
for i:=1 to 3 do p3[0,i]:=0;

assign(f,'winds.pal');rewrite(f,1);blockwrite(f,p3,768);close(f);

end.