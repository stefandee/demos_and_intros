uses graphics;
{$R-}

var s : shortint;
    b : byte;
    w : word;
    i : integer;

function R2F(r : real) : integer;
var w : integer;
begin
if r>=0 then w:=256*(round(r)-1)+round((round(r)-r)*256);
if r<0 then w:=-(256*(round(abs(r))-1)+round((round(abs(r))-abs(r))*256));
r2f:=w;
end;

begin

i:=r2f(4.355)+r2f(2.5);
writeln(hi(i),' ',lo(i));
readln;
end.