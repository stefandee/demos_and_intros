
program d3;

uses graph,crt;

type poligon = record
             t1x,t1y,t1z:real;
             t2x,t2y,t2z:real;
             t3x,t3y,t3z:real;
             color,stil:byte;
             end;
    obiect=array[1..4] of poligon;
const p=pi/180;
      z0=320;

var obj:obiect;
    gd,gm,i,j,pg:integer;
    orgx,orgy:real;
    eyex,eyey,eyez:integer;
    tan10:real;

Procedure Rotate3D(a,b,c : real;var obj:obiect);
var sa,sb,sc   : real;
    ca,cb,cc,u : real;
begin
  a:=a*p; b:=b*p; c:=c*p;
  ca:=cos(a); sa:=sin(a);
  cb:=cos(b); sb:=sin(b);
  cc:=cos(c); sc:=sin(c);
  for i:=1 to 4 do {}
  begin
    if a<>0 then
    begin
      u:=obj[i].t1y;{point[i,2];}
      obj[i].t1y{point[i,2]}:=u*ca+obj[i].t1z{point[i,3]}*sa;
      obj[i].t1z{point[i,3]}:=obj[i].t1z{point[i,3]}*ca-u*sa;
      u:=obj[i].t2y;{point[i,2];}
      obj[i].t2y{point[i,2]}:=u*ca+obj[i].t2z{point[i,3]}*sa;
      obj[i].t2z{point[i,3]}:=obj[i].t2z{point[i,3]}*ca-u*sa;
      u:=obj[i].t3y;{point[i,2];}
      obj[i].t3y{point[i,2]}:=u*ca+obj[i].t3z{point[i,3]}*sa;
      obj[i].t3z{point[i,3]}:=obj[i].t3z{point[i,3]}*ca-u*sa;
    end;
    if b<>0 then
    begin
      u:=obj[i].t1z;{point[i,3];}
      obj[i].t1z{point[i,3]}:=u*cb+obj[i].t1x{point[i,1]}*sb;
      obj[i].t1x{point[i,1]}:=obj[i].t1x{point[i,1]}*cb-u*sb;
      u:=obj[i].t2z;{point[i,3];}
      obj[i].t2z{point[i,3]}:=u*cb+obj[i].t2x{point[i,1]}*sb;
      obj[i].t2x{point[i,1]}:=obj[i].t2x{point[i,1]}*cb-u*sb;
      u:=obj[i].t3z;{point[i,3];}
      obj[i].t3z{point[i,3]}:=u*cb+obj[i].t3x{point[i,1]}*sb;
      obj[i].t3x{point[i,1]}:=obj[i].t3x{point[i,1]}*cb-u*sb;
    end;
    if c<>0 then
    begin
      u:=obj[i].t1x;{point[i,1];}
      obj[i].t1x{point[i,1]}:=u*cc+obj[i].t1y{point[i,2]}*sc;
      obj[i].t1y{point[i,2]}:=obj[i].t1y{point[i,2]}*cc-u*sc;
      u:=obj[i].t2x;{point[i,1];}
      obj[i].t2x{point[i,1]}:=u*cc+obj[i].t2y{point[i,2]}*sc;
      obj[i].t2y{point[i,2]}:=obj[i].t2y{point[i,2]}*cc-u*sc;
      u:=obj[i].t3x;{point[i,1];}
      obj[i].t3x{point[i,1]}:=u*cc+obj[i].t3y{point[i,2]}*sc;
      obj[i].t3y{point[i,2]}:=obj[i].t3y{point[i,2]}*cc-u*sc;
    end;
end;
end;
Procedure Proiectie(var obj:obiect);

type face = record
          t : array[1..3] of pointtype;
          x,y : real;
          dist:real;
          color:byte;
          stil:byte;
          end;

var fpr  : real;
    pro  : array[1..3,1..2] of real;
    f    : array [1..4] of face;
    midx,midy,midz  : real;
    dist : array[1..4] of real;
    xchg : face;
    m1,m2: string;

begin
  for i:=1 to 4 do
  begin
    fpr:=z0/(z0-obj[i].t1z);
    pro[1,1]:=fpr*obj[i].t1x*GetMaxY/(2*z0*tan10)+orgx;
    pro[1,2]:=fpr*obj[i].t1y*GetMaxY/(2*z0*tan10)+orgy;
    fpr:=z0/(z0-obj[i].t2z);
    pro[2,1]:=fpr*obj[i].t2x*GetMaxY/(2*z0*tan10)+orgx;
    pro[2,2]:=fpr*obj[i].t2y*GetMaxY/(2*z0*tan10)+orgy;
    fpr:=z0/(z0-obj[i].t3z);
    pro[3,1]:=fpr*obj[i].t3x*GetMaxY/(2*z0*tan10)+orgx;
    pro[3,2]:=fpr*obj[i].t3y*GetMaxY/(2*z0*tan10)+orgy;
    f[i].t[1].x:=round(pro[1,1]);
    f[i].t[1].y:=round(pro[1,2]);
    f[i].t[2].x:=round(pro[2,1]);
    f[i].t[2].y:=round(pro[2,2]);
    f[i].t[3].x:=round(pro[3,1]);
    f[i].t[3].y:=round(pro[3,2]);

    midx:=(obj[i].t1x+obj[i].t2x+obj[i].t3x)/3;
    midy:=(obj[i].t1y+obj[i].t2y+obj[i].t3y)/3;
    midz:=(obj[i].t1z+obj[i].t2z+obj[i].t3z)/3;
    f[i].dist:=midz;
    {sqrt(sqr(eyex-mid[i,1])+sqr(eyey-mid[i,2])+sqr(eyez-mid[i,3]));}
    f[i].color:=obj[i].color;
    f[i].stil:=obj[i].stil;
    fpr:=z0/(z0-midz);
    f[i].x:=fpr*midx*GetMaxY/(2*z0*tan10)+orgx;
    f[i].y:=fpr*midy*GetMaxY/(2*z0*tan10)+orgy;

  end;

    for i:=1 to 4 do
        for j:=1 to 4 do
            if f[i].dist<=f[j].dist then begin
                                    xchg:=f[i];
                                    f[i]:=f[j];
                                    f[j]:=xchg;
                                    end;
     setfillstyle(1,black);
     bar(300,300,400,400);
     for i:=1 to 4 do
         begin
             {str(f[i].color,m1);
             str(round(f[i].dist),m2);
             outtextxy(300,300+i*10-10,m1+' '+m2);}
             setfillstyle(f[i].stil,f[i].color);
             setcolor(f[i].color);
             line (round(f[i].t[1].x),round(f[i].t[1].y),round(f[i].t[2].x),round(f[i].t[2].y));
             line (round(f[i].t[2].x),round(f[i].t[2].y),round(f[i].t[3].x),round(f[i].t[3].y));
             line (round(f[i].t[3].x),round(f[i].t[3].y),round(f[i].t[1].x),round(f[i].t[1].y));
         {    repeat until readkey=#13;}
             floodfill(round(f[i].x),round(f[i].y),f[i].color);
         end;


end;

begin
orgx:=320;
orgy:=175;
eyex:=0;
eyey:=0;
eyez:=50;

{face 1}
obj[1].t1x:=0;obj[1].t1y:=80;obj[1].t1z:=0;
obj[1].t2x:=80;obj[1].t2y:=0;obj[1].t2z:=0;
obj[1].t3x:=0;obj[1].t3y:=0;obj[1].t3z:=80;
obj[1].color:=red;obj[1].stil:=1;
{face 2}
obj[2].t1x:=0;obj[2].t1y:=81;obj[2].t1z:=0;
obj[2].t2x:=81;obj[2].t2y:=0;obj[2].t2z:=0;
obj[2].t3x:=-81;obj[2].t3y:=0;obj[2].t3z:=0;
obj[2].color:=lightblue;obj[2].stil:=1;
{face 3}
obj[3].t1x:=79;obj[3].t1y:=0;obj[3].t1z:=0;
obj[3].t2x:=-79;obj[3].t2y:=0;obj[3].t2z:=0;
obj[3].t3x:=0;obj[3].t3y:=0;obj[3].t3z:=79;
obj[3].color:=lightgreen;obj[3].stil:=1;
{face 4}
obj[4].t1x:=0;obj[4].t1y:=82;obj[4].t1z:=0;
obj[4].t2x:=-82;obj[4].t2y:=0;obj[4].t2z:=0;
obj[4].t3x:=0;obj[4].t3y:=0;obj[4].t3z:=82;
obj[4].color:=yellow;obj[4].stil:=1;

gd:=vga;
gm:=vgamed;
initgraph(gd,gm,'c:\bin\bp\bgi');
pg:=0;
tan10:=sin(10)/cos(10);
setvisualpage(pg);
rotate3d(30,30,30,obj);
for i:=1 to 90 do
begin
inc(pg);
if pg>1 then pg:=0;
setactivepage(pg);
cleardevice;
rotate3d(5,10,4,obj);
proiectie(obj);
delay(100);
{repeat until readkey=#13;}
setvisualpage(pg);
end;
repeat until readkey=#13;

end.

























































































































































































































