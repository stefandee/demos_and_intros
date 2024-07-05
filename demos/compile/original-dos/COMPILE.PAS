program DEMO_COMPILATION;
{$M 65520,0,655360}

uses graphics,types3d,dos,plasma,copper,crazy,cputype,stars,speech,morph,
     bitmap,fire,explode,scroll3d;

const side   = 36;
      source : array[1..1] of point3d=((x:0;y:0;z:-100));
      yspeed : shortint = 0;

var Cube : Obj;
    cnt  : integer;
    amp  : integer;
    f    : file;
    Wire : array[1..8] of Point3d;
    Link : array[1..12,1..2] of byte;
    soak : boolean;

procedure InitCube;
begin
with Cube do
     begin
     face:=6;
     with form[1] do
          begin
          p1.x:=-side div 2;p1.y:=side div 2;p1.z:=-side div 2;
          p2.x:=-side div 2;p2.y:=-side div 2;p2.z:=-side div 2;
          p3.x:=side div 2;p3.y:=-side div 2;p3.z:=-side div 2;
          p4.x:=side div 2;p4.y:=side div 2;p4.z:=-side div 2;
          color:=100;
          end;
     with form[2] do
          begin
          p1.x:=-side div 2;p1.y:=-side div 2;p1.z:=side div 2;
          p2.x:=side div 2;p2.y:=-side div 2;p2.z:=side div 2;
          p3.x:=-side div 2;p3.y:=side div 2;p3.z:=side div 2;
          p4.x:=side div 2;p4.y:=side div 2;p4.z:=side div 2;
          color:=100;
          end;
     with form[3] do
          begin
          p1.x:=-side div 2;p1.y:=-side div 2;p1.z:=side div 2;
          p2.x:=-side div 2;p2.y:=-side div 2;p2.z:=-side div 2;
          p3.x:=-side div 2;p3.y:=side div 2;p3.z:=side div 2;
          p4.x:=-side div 2;p4.y:=side div 2;p4.z:=-side div 2;
          color:=105;
          end;
     with form[4] do
          begin
          p1.x:=side div 2;p1.y:=side div 2;p1.z:=side div 2;
          p2.x:=side div 2;p2.y:=-side div 2;p2.z:=-side div 2;
          p3.x:=side div 2;p3.y:=-side div 2;p3.z:=side div 2;
          p4.x:=side div 2;p4.y:=side div 2;p4.z:=-side div 2;
          color:=105;
          end;
     with form[5] do
          begin
          p1.x:=-side div 2;p1.y:=-side div 2;p1.z:=side div 2;
          p2.x:=side div 2;p2.y:=-side div 2;p2.z:=-side div 2;
          p3.x:=side div 2;p3.y:=-side div 2;p3.z:=side div 2;
          p4.x:=-side div 2;p4.y:=-side div 2;p4.z:=-side div 2;
          color:=110;
          end;
     with form[6] do
          begin
          p1.x:=-side div 2;p1.y:=side div 2;p1.z:=side div 2;
          p2.x:=side div 2;p2.y:=side div 2;p2.z:=-side div 2;
          p3.x:=side div 2;p3.y:=side div 2;p3.z:=side div 2;
          p4.x:=-side div 2;p4.y:=side div 2;p4.z:=-side div 2;
          color:=110;
          end;
    with core do begin x:=0;y:=0;z:=0;end;
    end;
end;

procedure InitWire;
begin
  with wire[1] do begin x:=-side div 2;y:=-side div 2;z:=side div 2;end;
  with wire[2] do begin x:=side div 2;y:=-side div 2;z:=side div 2;end;
  with wire[3] do begin x:=side div 2;y:=side div 2;z:=side div 2;end;
  with wire[4] do begin x:=-side div 2;y:=side div 2;z:=side div 2;end;
  with wire[5] do begin x:=-side div 2;y:=-side div 2;z:=-side div 2;end;
  with wire[6] do begin x:=side div 2;y:=-side div 2;z:=-side div 2;end;
  with wire[7] do begin x:=side div 2;y:=side div 2;z:=-side div 2;end;
  with wire[8] do begin x:=-side div 2;y:=side div 2;z:=-side div 2;end;
end;

procedure InitLinks;
begin
  link[1,1]:=1;link[1,2]:=2;
  link[2,1]:=2;link[2,2]:=3;
  link[3,1]:=3;link[3,2]:=4;
  link[4,1]:=4;link[4,2]:=1;
  link[5,1]:=5;link[5,2]:=6;
  link[6,1]:=6;link[6,2]:=7;
  link[7,1]:=7;link[7,2]:=8;
  link[8,1]:=8;link[8,2]:=5;
  link[9,1]:=1;link[9,2]:=5;
  link[10,1]:=2;link[10,2]:=6;
  link[11,1]:=3;link[11,2]:=7;
  link[12,1]:=4;link[12,2]:=8;
end;

procedure Draw3D(var Psg : Obj);

var pro : PObj;
    i   : integer;
    expr : real;
    d1,d2,d3 : real;
    t : real;

begin
DepthSort(psg);

with viewplane do expr:=-(d+a*look.x+b*look.y+c*look.z);

with psg do
for i:=1 to face do
    with viewplane do
    begin
    with form[i] do
    EyeDist:= ROUND(SQRT(SQR((P1.X+P2.X+P3.X+P4.X)/4-source[1].x)+ SQR((P1.Y+P2.Y+P3.Y+P4.y)/4-source[1].y)+
              SQR((P1.Z+P2.Z+P3.Z+P4.Z)/4-source[1].z) ));
    {p1}
        form[i].p1.y:=form[i].p1.y+yspeed;
        d1:=form[i].p1.x-look.x;
        d2:=form[i].p1.y-look.y;
        d3:=form[i].p1.z-look.z;
        t:=expr/(a*d1+b*d2+c*d3+1.1119);
        pro[i].p1.x:=round(t*d1+look.x)+orgx;
        pro[i].p1.y:=round(t*d2+look.y)+orgy;
    {p2}
        form[i].p2.y:=form[i].p2.y+yspeed;
        d1:=form[i].p2.x-look.x;
        d2:=form[i].p2.y-look.y;
        d3:=form[i].p2.z-look.z;
        t:=expr/(a*d1+b*d2+c*d3+1.1119);
        pro[i].p2.x:=round(t*d1+look.x)+orgx;
        pro[i].p2.y:=round(t*d2+look.y)+orgy;
    {p3}
        form[i].p3.y:=form[i].p3.y+yspeed;
        d1:=form[i].p3.x-look.x;
        d2:=form[i].p3.y-look.y;
        d3:=form[i].p3.z-look.z;
        t:=expr/(a*d1+b*d2+c*d3+1.1119);
        pro[i].p3.x:=round(t*d1+look.x)+orgx;
        pro[i].p3.y:=round(t*d2+look.y)+orgy;
    {p4}
        form[i].p4.y:=form[i].p4.y+yspeed;
        d1:=form[i].p4.x-look.x;
        d2:=form[i].p4.y-look.y;
        d3:=form[i].p4.z-look.z;
        t:=expr/(a*d1+b*d2+c*d3+1.1119);
        pro[i].p4.x:=round(t*d1+look.x)+orgx;
        pro[i].p4.y:=round(t*d2+look.y)+orgy;
        if Not soak then form[i].color:=round(110+(form[i].eyedist/3)) mod 256;
        end;

FillSort(pro,psg.face);
for i:=1 to psg.face do
with psg.form[i] do
     begin
     DrawPoly(
     pro[i].p1.x,pro[i].p1.y,pro[i].p2.x,pro[i].p2.y,pro[i].p3.x,pro[i].p3.y,pro[i].p4.x,pro[i].p4.y,
     psg.form[i].color,vaddr);
     end;

end;

procedure DrawWire;

  var i    : integer;
      pro  : array[1..8] of point2d;
      expr : real;
      d1,d2,d3 : real;
      t : real;

begin
  with viewplane do expr:=-(d+a*look.x+b*look.y+c*look.z);

  for i:=1 to 8 do
      with Wire[i] do
           with viewplane do
                begin
                    wire[i].y:=wire[i].y+yspeed;
                    d1:=wire[i].x-look.x;
                    d2:=wire[i].y-look.y;
                    d3:=wire[i].z-look.z;
                    t:=expr/(a*d1+b*d2+c*d3+1.1119);
                    pro[i].x:=round(t*d1+look.x)+orgx;
                    pro[i].y:=round(t*d2+look.y)+orgy;
                end;
 for i:=1 to 12 do line(pro[link[i,1]].x,pro[link[i,1]].y,pro[link[i,2]].x,pro[link[i,2]].y,255,vaddr);
end;

procedure NormalCube;

var counter : integer;
    flic : boolean;
    dz   : shortint;
    i    : integer;

{starfield variables & procedures...}
const No=100;

var stars  : array[1..NO,1..3] of integer;
    x,y  : integer;
    col    : byte;

procedure InitAStar(i : integer);
begin
    stars[i,1]:=random(20);dec(stars[i,1],10);
    stars[i,2]:=random(20);dec(stars[i,2],10);
    stars[i,3]:=random(20)+30;
    x:=orgx+(stars[i,1] shl 7) div stars[i,3];
    y:=orgy+(stars[i,2] shl 7) div stars[i,3];
end;

begin

assign(f,'compile.dat');reset(f,1);seek(f,135662);blockread(f,message,819);close(f);
for i:=1 to 819 do message[i]:=char(255-byte(message[i]));
txt2scr:='                       ';
flic:=false;
dz:=2;msgcnt:=1;counter:=0;
Hlin:=Nhlin;
center:=cube.core;
for i:=1 to No do InitAStar(i);

repeat

cls(0,vaddr);

inc(counter);

case counter of
100 : begin flic:=true; end;
130 : begin flic:=false;Hlin:=Glare; end;
230 : begin flic:=false;Hlin:=Nhlin;counter:=0; end;
end;

if flic
   then begin
        inc(cnt);
        case cnt mod 3 of
        1 : setvisiblestart(80);
        2 : setvisiblestart(160);
        0 : setvisiblestart(0);
        end;
        end;

{scroll text...}
dtext:=dtext+4;
if dtext>=16 then begin
                for i:=1 to 19 do txt2scr[i]:=txt2scr[i+1];
                if message[msgcnt]<#32 then txt2scr[20]:=' '
                                       else txt2scr[20]:=message[msgcnt];
                inc(msgcnt);
                if msgcnt>=819 then msgcnt:=1;
                dtext:=0;
                end;
outtext(-dtext,180,txt2scr,1,254,vaddr);


for i:=1 to No do
    begin
    if (stars[i,3]<>0)
       then begin
            x:=orgx+(stars[i,1] shl 7) div stars[i,3];
            y:=orgy+(stars[i,2] shl 7) div stars[i,3];
            end;

    if (stars[i,3]<-30) or (x<LeftClip) or (x>RightClip)
       or (y<topClip) or (y>botClip) then InitAStar(i);

    col:=60;
    case stars[i,3] of
    -200..0 : col:=126;
    1..20   : col:=116;
    21..40  : col:=106;
    41..61  : col:=96;
    end;

    putpixel(x,y,col,vaddr);
    dec(stars[i,3]);
    end;

{rotate cube...}
RotateObj(Cube,4,11,9);
Draw3D(Cube);

{draw to screen...}
WaitRetrace;
Flip;

until port[$60]=1;

FadeOut(3);
cls(0,vga);
fillchar(workpal,768,0);
setpal;

end;

procedure DoSoak;
  var counter,i  : integer;
      auxbotclip : integer;
      dy         : shortint;
begin

  cls(0,vga);cls(0,vaddr);
  Loadpal('compile.dat',24158);Setpal;counter:=0;center:=cube.core;
  Hlin:=Nhlin;dy:=-4;auxbotclip:=120;yspeed:=2;topclip:=0;

  repeat
  cls(0,vaddr);

  auxbotclip:=auxbotclip+yspeed;
  cube.core.y:=cube.core.y+yspeed;

  case yspeed of
  2  : if cube.core.y>8 then  yspeed:=-2;
  -2 : if cube.core.y<-8 then yspeed:=2;
  end;

  center:=cube.core;
  BotClip:=200;
  for i:=1 to 8 do RotatePoint(Wire[i],4,5,9);
  DrawWire;

  BotClip:=auxbotclip;
  center:=cube.core;
  RotateObj(Cube,4,5,9);
  Draw3D(Cube);

  Flip;
  inc(counter);
  until counter>300;
  fadeout(4);
  cls(0,vga);
end;

BEGIN


Detect;
repeat until port[$60]=28;

TextFade;Randomize;
Vga256;InitVScreen;cls(0,vaddr);
Loadpal('compile.dat',24158);setpal;
assign(f,'compile.dat');reset(f,1);seek(f,560);blockread(f,small,18207);close(f);
assign(f,'compile.dat');reset(f,1);seek(f,18767);blockread(f,micro,3087);close(f);

with look do begin x:=0;y:=0;z:=-50; end;
viewplane.d:=-look.z-100;yspeed:=0;soak:=false;topclip:=10;botclip:=180;


InitCuBe;
NormalCube;

DoExplode;
DoMorph;
DoFire;
DoSail;
DoStars;
DoPlasma;
DoScroll3d;
DoBars;
DoBalls;

soak:=true;
InitCube;
InitWire;
InitLinks;
DoSoak;
DoWinter;
DoEnd;

DoneVga256;
DoneVScreen;

END.
