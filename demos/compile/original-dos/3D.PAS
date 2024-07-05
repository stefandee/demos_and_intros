program load3dv;
{$R-}
uses types3d,graphics,crt;
type comb = record
          point:integer;
          color:byte;
          end;
const fc=1;
var f:text;
    s:string;
    point : array[1..300] of point3d;
    linx  : array[1..250] of comb;
    points : integer;
    links  : integer;
    v : array[1..3] of real;
    inv,inb,inf:byte;
    i,ii,j:integer;
    fpr:real;
    first:integer;
    xb,yb,xf,yf:integer;
    core : point3d;

function rval(s:string):real;
var err:integer;
    v:real;
begin
val(s,v,err);
rval:=v;
end;

begin
assign(f,'2skulls.3d');
reset(f);
readln(f,s);
writeln(s);
points:=round(rval(s));
for i:=1 to points do
    begin
    readln(f,s);
    inb:=1;inv:=1;
    s:=s+' ';
    for j:=1 to length(s) do
        if (s[j]=' ')
           then begin
                v[inv]:=rval(copy(s,inb,j-inb));
                inb:=j;
                inc(inv);
                end;

    point[i].x:=v[1];
    point[i].y:=v[2];
    point[i].z:=v[3]+100;
    {with point[i] do writeln(x:5:5,' ',y:5:5,' ',z:5:5);}
    end;

readln(f,s);
writeln(s);
links:=round(rval(s));
for i:=1 to links do
    begin
    readln(f,s);inb:=1;inv:=1;s:=s+' ';
    for j:=1 to length(s) do
        if s[j]=' '
           then begin
                v[inv]:=rval(copy(s,inb,j-inb));
                inb:=j;
                inc(inv);
                end;
    linx[i].point:=round(v[1]);
    linx[i].color:=round(v[2]);
    {with linx[i] do writeln(point,' ',color);}
    end;
vga256;
loadpal('stand.pal');
setpal;
initvscreen;
core.z:=100;
repeat
cls(0,vaddr);
first:=linx[1].point;
center:=core;

for ii:=1 to points do rotatepoint(point[ii],10,5,0);


for ii:=2 to links do
    begin

    fpr:=z0/(z0+point[first].z);
    xb:=round(fpr*point[first].x)+orgx;
    yb:=round(fpr*point[first].y)+orgy;

    fpr:=z0/(z0+point[linx[ii].point].z);
    xf:=round(fpr*point[linx[ii].point].x)+orgx;
    yf:=round(fpr*point[linx[ii].point].y)+orgy;

    line(xb,yb,xf,yf,linx[ii].color,vaddr);
    first:=linx[ii].point;
    end;

flip;
until keypressed;
donevga256;
donevscreen;

end.