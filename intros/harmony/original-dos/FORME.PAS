unit Forme;

interface

uses types3d,objects,graphics;

type sline = record
          p1,p2 : point3d;
          end;
     pline = record
           p1,p2 : point2d;
           end;
     formtype = array[1..20] of sline;

type
     TNota = object(Tobject)
             nrvrf  : byte;
             core   : point3d;
             form   : formtype;
             color  : byte;
             p1 : point3d;
             lmare1,lmare2,inalt1,inalt2,lmic  : real;
             dx,dy,dz : real;
             constructor Init;
             procedure Draw;virtual;
             destructor Done;virtual;
             end;

implementation


procedure TNota.Draw;
var fpr:real;
    xb,yb,xf,yf : longint;
    i : integer;
begin
with core do begin x:=x+dx;y:=y+dy;z:=z+dz;end;
for i:=1 to nrvrf do
    begin
    form[i].p1.x:=form[i].p1.x+dx;form[i].p1.y:=form[i].p1.y+dy;form[i].p1.z:=form[i].p1.z+dz;
    form[i].p2.x:=form[i].p2.x+dx;form[i].p2.y:=form[i].p2.y+dy;form[i].p2.z:=form[i].p2.z+dz;
    fpr:=z0/(z0+form[i].p1.z);
    xb:=round(fpr*form[i].p1.x)+orgx;
    yb:=round(fpr*form[i].p1.y)+orgy;
    fpr:=z0/(z0+form[i].p2.z);
    xf:=round(fpr*form[i].p2.x)+orgx;
    yf:=round(fpr*form[i].p2.y)+orgy;
    line(xb,yb,xf,yf,color,vaddr);
    end;
end;

destructor Tnota.done;
begin
end;


constructor Tnota.Init;
begin
core.x:=p1.x+lmic/2;core.y:=p1.y-(inalt1+inalt2)/2;core.z:=p1.z-lmic/2;
nrvrf:=20;
form[1].p1:=p1;p1.z:=p1.z-lmic;form[1].p2:=p1;
form[2].p1:=p1;p1.x:=p1.x+lmic;form[2].p2:=p1;
form[3].p1:=p1;p1.z:=p1.z+lmic;form[3].p2:=p1;
form[4].p1:=p1;p1.x:=p1.x-lmic;form[4].p2:=p1;

form[5].p1:=p1;p1.y:=p1.y-inalt1;p1.x:=p1.x-(lmare1-lmic)/2;p1.z:=p1.z+(lmare1-lmic)/2;
form[5].p2:=p1;

form[6].p1:=p1;p1.z:=p1.z-lmare1;form[6].p2:=p1;
form[7].p1:=p1;p1.x:=p1.x+lmare1;form[7].p2:=p1;
form[8].p1:=p1;p1.z:=p1.z+lmare1;form[8].p2:=p1;
form[9].p1:=p1;p1.x:=p1.x-lmare1;form[9].p2:=p1;

form[10].p1:=form[6].p2;form[10].p2:=form[1].p2;
form[11].p1:=form[7].p2;form[11].p2:=form[2].p2;
form[12].p1:=form[8].p2;form[12].p2:=form[3].p2;

p1.y:=p1.y+inalt2+inalt1;
p1.x:=p1.x+(lmare1-lmare2)/2;
p1.z:=p1.z+(lmare2-lmare1)/2;

form[13].p1:=p1;p1.z:=p1.z-lmare2;form[13].p2:=p1;
form[14].p1:=p1;p1.x:=p1.x+lmare2;form[14].p2:=p1;
form[15].p1:=p1;p1.z:=p1.z+lmare2;form[15].p2:=p1;
form[16].p1:=p1;p1.x:=p1.x-lmare2;form[16].p2:=p1;

form[17].p1:=form[1].p1;
form[17].p2:=form[13].p1;

form[18].p1:=form[1].p2;form[18].p2:=form[13].p2;
form[19].p1:=form[2].p2;form[19].p2:=form[14].p2;
form[20].p1:=form[3].p2;form[20].p2:=form[15].p2;

end;

begin
end.