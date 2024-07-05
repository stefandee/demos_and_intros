unit Types3D;

interface

uses crt;

const MaxFace = 10;
      Orgx    = 160;
      Orgy    = 100;
      Z0      = 110.0193;
      alt:real= 10;

type  Point3D = record
             X,Y,Z : real;
             end;
      Point2D = record
             X,Y : longint;
             end;
      Plan3D  = record
             P1,P2,P3,P4 : Point3D;
             Color       : byte;
             EyeDist     : longint;
             end;

      Plan2D  = record
              P1,P2,P3,P4: Point2D;
              end;

      Obj     = record
                Form : array[1..MaxFace] of Plan3D;
                Face : byte;
                Core : Point3D;{the coordinator of objects movements}
                end;

      PObj    = array[1..maxface] of Plan2D;
      PTab    = array[-180..180] of real;

const origin : point3d=(x:0;y:0;z:0);

var sint,cost : PTab;
    f         : file of PTab;
    center    : point3d;

procedure RotatePoint (var P : Point3D;a,b,c:real);far;
procedure RotateObj   (var O : Obj;a,b,c:real);far;
procedure DepthSort   (var O : Obj);far;
procedure FillSort    (var P : Pobj;face:integer);far;


implementation

procedure RotatePoint (var P : Point3D;a,b,c:real);

const ps=pi/180;

var sa,sb,sc     : real;
    ca,cb,cc,u,v : real;

begin

  if a<>0 then
    begin
      a:=a*ps;
      ca:=cos(a); sa:=sin(a);
      u:=P.Y;v:=p.z;
      P.Y:=(u-center.y)*ca+(v-center.z)*sa+center.y;
      P.Z:=(v-center.z)*ca-(u-center.y)*sa+center.z;
    end;
    if b<>0 then
    begin
      b:=b*ps;
      cb:=cos(b); sb:=sin(b);
      u:=P.Z;v:=P.X;
      P.X:=(v-center.x)*cb-(u-center.z)*sb+center.x;
      P.Z:=(u-center.z)*cb+(v-center.x)*sb+center.z;
    end;
    if c<>0 then
    begin
      c:=c*ps;
      cc:=cos(c); sc:=sin(c);
      u:=P.X;v:=p.y;
      P.X:=(u-center.x)*cc+(v-center.y)*sc+center.x;
      P.Y:=(v-center.y)*cc-(u-center.x)*sc+center.y;
    end;

end;{end procedure rotate point}


procedure RotateObj   (var O : Obj;a,b,c:real);


var i : integer;

begin

for i:=1 to O.face do
    begin
    RotatePoint(O.Form[i].P1,a,b,c);
    RotatePoint(O.Form[i].P2,a,b,c);
    RotatePoint(O.Form[i].P3,a,b,c);
    RotatePoint(O.Form[i].P4,a,b,c);
    end;
RotatePoint(o.core,a,b,c);
end;{end procedure rotate obj}

procedure DepthSort   (var O : Obj);

var i,j   : integer;
    temp  : Plan3d;


procedure Kwik (first,last:integer);

var i,j   : integer;
    mid   : longint;
    temp  : Plan3d;

begin
i:=first;
j:=last;
mid:=O.Form[(i+j) div 2].EyeDist;
repeat
while O.Form[i].EyeDist<mid do inc(i);
while O.Form[j].EyeDist>mid do dec(j);
if i<=j
   then begin
        temp:=O.Form[i];
        O.Form[i]:=O.Form[j];
        O.Form[j]:=temp;
        dec(j);
        inc(i);
        end;
{if i<=j
   then begin
        dec(j);
        inc(i);
        end;
}
until i>=j;
if first<j then Kwik(first,j);
if i<last  then Kwik(i,last);
end;

begin
with O do
for i:=1 to Face do
    with Form[i] do
    EyeDist:= ROUND(SQRT(SQR((P1.X+P2.X+P3.X)/3)+SQR((P1.Y+P2.Y+P3.Y)/3)+
              SQR((P1.Z+P2.Z+P3.Z)/3)));
with O do
for i:=1 to face do
    for j:=1 to face do
        if Form[i].EyeDist<=Form[j].EyeDist
           then begin
                temp:=form[i];
                form[i]:=form[j];
                form[j]:=temp;
                end;
{Kwik(1,O.Face);}
end;

procedure FillSort    (var P : Pobj;face:integer);

var temp : Point2D;
    i,j  : integer;

begin
for i:=1 to face do
with P[i] do
     begin
     for j:=1 to 4 do
     begin
     if p1.y>p2.y then begin
                       temp:=p1;
                       p1:=p2;
                       p2:=temp;
                       end;
     if p2.y>p3.y then begin
                       temp:=p2;
                       p2:=p3;
                       p3:=temp;
                       end;
     if p3.y>p4.y then begin
                       temp:=p3;
                       p3:=p4;
                       p4:=temp;
                       end;
     end;
     end;
end;{procedure fill sort}


begin
with center do begin x:=0;y:=0;z:=0; end;
{assign(f,'fsincos.tab');
reset(f);
read(f,sint);
read(f,cost);
close(f);
}
end.