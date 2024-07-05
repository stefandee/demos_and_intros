program morph3d;
{$R+}
uses graphics,types3d,crt,objects,forme;

type ssound=record
               Note:integer;
               Octave:integer;
               Instrument:string;
               Chanel:byte;
               A:byte;
           end;
const octava : byte=3;
      culoare: array[1..12,1..3] of byte=(
               (0,0,32),(32,63,63),(0,32,32),(32,32,32),(0,40,0),
               (63,0,0),(32,0,32),(40,40,40),(10,20,63),(63,63,63),
               (40,10,30),(10,10,10));
      h_culoare: array[1..12,1..3] of byte=(
               (0,0,32),(32,63,63),(0,32,32),(32,32,32),(0,40,0),
               (63,0,0),(32,0,32),(40,40,40),(10,20,63),(63,63,63),
               (40,10,30),(10,10,10));

      canale : array[1..16] of real=( 90,90,90,90,90,90,90,90,90,90,90,90,90,
                                      90,90,90);
      p = pi/180;
      tonuri : array[1..5] of real=(0.6,0.8,1,1.2,1.4);
{      dx:real=0.2;
      dy:real=0.2;
      dz:real=0.2;
}
const step:real=5;
var {destinatiile originale}

    nota                       :array[1..12] of tnota;
    notaant                    :array[1..12] of tnota;
    pro                        :array[1..12] of pline;
    p1                         :point3d;
    fpr                        :real;
    i,j,k,t,count,count1       :integer;
    cm                         :byte;
    param                      :array[1..16] of array[1..20,1..2] of real;
    traj                       :string;
    pt                         :integer;
    dstx,delta                 :integer;
{    dx,dy,dz:integer;}
    dsty,dstz,cdsty,cdstz,cdstx:integer;
    enable                     :boolean;
    err                        :integer;
    cpy                        :string;
    decr                       :boolean;
    playchanel                 :array[1..16] of ssound;
    dzmorph                    :array[1..20,1..2] of real;
    morph                      :array[1..16] of real;
    m3                         :array[1..16] of boolean;
    m1,m2                      :array[1..16] of formtype;
    m4                         :array[1..16,1..20,1..4] of boolean;
    s                          :ssound;

function ok:boolean;
var i,j,k:integer;
begin
  ok:=false;
  for j:=1 to 2 do for k:=1 to 20 do for i:=1 to 4 do if m4[j,k,i]=false then exit;
  ok:=true;
end;

procedure transformcolor(color:byte;rate:real);
begin

  culoare[color,1]:=trunc(rate*h_culoare[color,1]);
  culoare[color,2]:=trunc(rate*h_culoare[color,2]);
  culoare[color,3]:=trunc(rate*h_culoare[color,3]);
  setrgb(color,culoare[color,1],culoare[color,2],culoare[color,3]);
end;

procedure initsetofobj;
begin
for j:=1 to 12 do
case j of
1: begin

      with p1 do begin x:=0;y:=0;z:=canale[1] end;notaant[j].p1:=p1;
      notaant[j].lmare1:=30;
      notaant[j].lmare2:=30;
      notaant[j].lmic:=30;
      notaant[j].inalt1:=30;
      notaant[j].inalt2:=0;
                 {do=cub}
      notaant[j].color:=1;tnota(notaant[j]).init;
      {notant[j]:=nota[j];}
   end;
3:begin
     with p1 do begin x:=canale[3]*cos(p*2*22.5);y:=-30;z:=canale[3]*sin(p*22.5*2) end;notaant[j].p1:=p1;
     notaant[j].lmare1:=0;
     notaant[j].lmare2:=0;
     notaant[j].lmic:=20;
     notaant[j].inalt1:=30;
     notaant[j].inalt2:=30;
     {re=dubla piramida}
     notaant[j].color:=3;tnota(notaant[j]).init;
     {notant[j]:=nota[j];}
   end;
5:begin
    with p1 do begin x:=canale[6]*cos(p*4*22.5);y:=0;z:=canale[6]*sin(p*4*22.5) end;notaant[j].p1:=p1;
    notaant[j].lmare1:=10;
    notaant[j].lmare2:=30;
    notaant[j].lmic:=10;
    notaant[j].inalt2:=25;
    notaant[j].inalt1:=0;
    {mi=trunchi de con}
    notaant[j].color:=5;tnota(notaant[j]).init;
    {notaantnt[j]:=notaant[j];}
  end;
6:begin
    with p1 do begin x:=canale[6]*cos(p*5*22.5);y:=0;z:=canale[6]*sin(p*5*22.5) end;notaant[j].p1:=p1;
    notaant[j].lmare1:=0;
    notaant[j].lmare2:=30;
    notaant[j].lmic:=0;
    notaant[j].inalt1:=0;
    notaant[j].inalt2:=25;
    {fa=piramida}
    notaant[j].color:=6;tnota(notaant[j]).init;
    {notaantnt[j]:=notaant[j];}
  end;
8:begin
    with p1 do begin x:=canale[6]*cos(p*7*22.5);y:=0;z:=canale[6]*sin(p*7*22.5) end;notaant[j].p1:=p1;
    notaant[j].lmare1:=30;
    notaant[j].lmare2:=30;
    notaant[j].lmic:=30;
    notaant[j].inalt1:=0;
    notaant[j].inalt2:=50;
    {sol=paraleliped}
    notaant[j].color:=8;tnota(notaant[j]).init;
    {notaantnt[j]:=notaant[j];}
  end;
10:begin
    with p1 do begin x:=canale[6]*cos(p*9*22.5);y:=0;z:=canale[6]*sin(p*9*22.5) end;notaant[j].p1:=p1;
    notaant[j].lmare1:=30;
    notaant[j].lmare2:=30;
    notaant[j].lmic:=10;
    notaant[j].inalt1:=20;
    notaant[j].inalt2:=20;
    {la=trunchi de piramida rasturnat}
    notaant[j].color:=10;tnota(notaant[j]).init;
    {notaantnt[j]:=notaant[j];}
  end;
2:begin
    with p1 do begin x:=canale[6]*cos(p*22.5);y:=0;z:=canale[6]*sin(p*22.5) end;notaant[j].p1:=p1;
    notaant[j].lmare1:=0;
    notaant[j].lmare2:=30;
    notaant[j].lmic:=30;
    notaant[j].inalt1:=20;
    notaant[j].inalt2:=20;
    {do#=cub+piramida}
    notaant[j].color:=2;tnota(notaant[j]).init;
    {notaantnt[j]:=notaant[j];}
  end;
4:begin
    with p1 do begin x:=canale[6]*cos(p*3*22.5);y:=0;z:=canale[6]*sin(p*3*22.5) end;notaant[j].p1:=p1;
    notaant[j].lmare1:=0;
    notaant[j].lmare2:=20;
    notaant[j].lmic:=30;
    notaant[j].inalt1:=20;
    notaant[j].inalt2:=20;
    {re#=piramida+trunchi}
    notaant[j].color:=4;tnota(notaant[j]).init;
    {notaantnt[j]:=notaant[j];}
  end;
12:begin
    with p1 do begin x:=canale[6]*cos(p*11*22.5);y:=0;z:=canale[6]*sin(p*11*22.5) end;notaant[j].p1:=p1;
    notaant[j].lmare1:=30;
    notaant[j].lmare2:=30;
    notaant[j].lmic:=0;
    notaant[j].inalt1:=25;
    notaant[j].inalt2:=25;
    {fa=piramida}
    notaant[j].color:=12;tnota(notaant[j]).init;
    {notaantnt[j]:=notaant[j];}
  end;

7:begin
    with p1 do begin x:=canale[6]*cos(p*6*22.5);y:=0;z:=canale[6]*sin(p*6*22.5) end;notaant[j].p1:=p1;
    notaant[j].lmare1:=30;
    notaant[j].lmare2:=0;
    notaant[j].lmic:=30;
    notaant[j].inalt1:=50;
    notaant[j].inalt2:=20;
    {fa#=paralelipiped+piramida}
    notaant[j].color:=7;tnota(notaant[j]).init;
    {notaantnt[j]:=notaant[j];}
  end;
9:begin
    with p1 do begin x:=canale[6]*cos(p*8*22.5);y:=0;z:=canale[6]*sin(p*8*22.5) end;notaant[j].p1:=p1;
    notaant[j].lmare1:=30;
    notaant[j].lmare2:=10;
    notaant[j].lmic:=10;
    notaant[j].inalt1:=20;
    notaant[j].inalt2:=25;
    {sol#=trunchi de piramida+paralelipiped}
    notaant[j].color:=8;tnota(notaant[j]).init;
    {notaantnt[j]:=notaant[j];}
  end;
11:begin
    with p1 do begin x:=canale[6]*cos(p*10*22.5);y:=0;z:=canale[6]*sin(p*10*22.5) end;notaant[j].p1:=p1;
    notaant[j].lmare1:=10;
    notaant[j].lmare2:=10;
    notaant[j].lmic:=30;
    notaant[j].inalt1:=10;
    notaant[j].inalt2:=10;
    {la#=2 trunchiuri}
    notaant[j].color:=11;tnota(notaant[j]).init;
    {notaantnt[j]:=notaant[j];}
  end;


end;
end;

begin

initsetofobj;
vga256;
initvscreen;

for i:=1 to 12 do setrgb(i,culoare[i,1],culoare[i,2],culoare[i,3]);
randomize;
k:=0;
count1:=0;

repeat
     for j:=1 to 2 do begin
      {citire }

      playchanel[j].note:=s.note;
      playchanel[j].octave:=random(5)+1;
     end;


     for j:=1 to 2 do begin

     case playchanel[j].note of
     1: begin

           with p1 do begin x:=0;y:=0;z:=canale[1] end;nota[j].p1:=p1;
           nota[j].lmare1:=30;
           nota[j].lmare2:=30;
           nota[j].lmic:=30;
           nota[j].inalt1:=30;
           nota[j].inalt2:=0;
                      {do=cub}
           transformcolor(1,tonuri[playchanel[j].octave]);
           nota[j].color:=1;tnota(nota[j]).init;
           {notant[j]:=nota[j];}
        end;
     3:begin
          with p1 do begin x:=canale[3]*cos(p*2*22.5);y:=-30;z:=canale[3]*sin(p*22.5*2) end;nota[j].p1:=p1;
          nota[j].lmare1:=0;
          nota[j].lmare2:=0;
          nota[j].lmic:=20;
          nota[j].inalt1:=30;
          nota[j].inalt2:=30;
          {re=dubla piramida}
          transformcolor(3,tonuri[playchanel[j].octave]);
          nota[j].color:=3;tnota(nota[j]).init;
          {notant[j]:=nota[j];}
        end;
     5:begin
         with p1 do begin x:=canale[6]*cos(p*4*22.5);y:=0;z:=canale[6]*sin(p*4*22.5) end;nota[j].p1:=p1;
         nota[j].lmare1:=10;
         nota[j].lmare2:=30;
         nota[j].lmic:=10;
         nota[j].inalt2:=25;
         nota[j].inalt1:=0;
         {mi=trunchi de con}
         transformcolor(5,tonuri[playchanel[j].octave]);
         nota[j].color:=5;tnota(nota[j]).init;
         {notant[j]:=nota[j];}
       end;
     6:begin
         with p1 do begin x:=canale[6]*cos(p*5*22.5);y:=0;z:=canale[6]*sin(p*5*22.5) end;nota[j].p1:=p1;
         nota[j].lmare1:=0;
         nota[j].lmare2:=30;
         nota[j].lmic:=0;
         nota[j].inalt1:=0;
         nota[j].inalt2:=25;
         {fa=piramida}
         transformcolor(6,tonuri[playchanel[j].octave]);
         nota[j].color:=6;tnota(nota[j]).init;
         {notant[j]:=nota[j];}
       end;
     8:begin
         with p1 do begin x:=canale[6]*cos(p*7*22.5);y:=0;z:=canale[6]*sin(p*7*22.5) end;nota[j].p1:=p1;
         nota[j].lmare1:=30;
         nota[j].lmare2:=30;
         nota[j].lmic:=30;
         nota[j].inalt1:=0;
         nota[j].inalt2:=50;
         {sol=paraleliped}
         transformcolor(8,tonuri[playchanel[j].octave]);
         nota[j].color:=8;tnota(nota[j]).init;
         {notant[j]:=nota[j];}
       end;
     10:begin
         with p1 do begin x:=canale[6]*cos(p*9*22.5);y:=0;z:=canale[6]*sin(p*9*22.5) end;nota[j].p1:=p1;
         nota[j].lmare1:=30;
         nota[j].lmare2:=30;
         nota[j].lmic:=10;
         nota[j].inalt1:=20;
         nota[j].inalt2:=20;
         {la=trunchi de piramida rasturnat}
         transformcolor(10,tonuri[playchanel[j].octave]);
         nota[j].color:=10;tnota(nota[j]).init;
         {notant[j]:=nota[j];}
       end;
     2:begin
         with p1 do begin x:=canale[6]*cos(p*22.5);y:=0;z:=canale[6]*sin(p*22.5) end;nota[j].p1:=p1;
         nota[j].lmare1:=0;
         nota[j].lmare2:=30;
         nota[j].lmic:=30;
         nota[j].inalt1:=20;
         nota[j].inalt2:=20;
         {do#=cub+piramida}
         transformcolor(2,tonuri[playchanel[j].octave]);
         nota[j].color:=2;tnota(nota[j]).init;
         {notant[j]:=nota[j];}
       end;
     4:begin
         with p1 do begin x:=canale[6]*cos(p*3*22.5);y:=0;z:=canale[6]*sin(p*3*22.5) end;nota[j].p1:=p1;
         nota[j].lmare1:=0;
         nota[j].lmare2:=20;
         nota[j].lmic:=30;
         nota[j].inalt1:=20;
         nota[j].inalt2:=20;
         {re#=piramida+trunchi}
         transformcolor(4,tonuri[playchanel[j].octave]);
         nota[j].color:=4;tnota(nota[j]).init;
         {notant[j]:=nota[j];}
       end;
     12:begin
         with p1 do begin x:=canale[6]*cos(p*11*22.5);y:=0;z:=canale[6]*sin(p*11*22.5) end;nota[j].p1:=p1;
         nota[j].lmare1:=30;
         nota[j].lmare2:=30;
         nota[j].lmic:=0;
         nota[j].inalt1:=25;
         nota[j].inalt2:=25;
         {fa=piramida}
         transformcolor(12,tonuri[playchanel[j].octave]);
         nota[j].color:=12;tnota(nota[j]).init;
         {notant[j]:=nota[j];}
       end;

     7:begin
         with p1 do begin x:=canale[6]*cos(p*6*22.5);y:=0;z:=canale[6]*sin(p*6*22.5) end;nota[j].p1:=p1;
         nota[j].lmare1:=30;
         nota[j].lmare2:=0;
         nota[j].lmic:=30;
         nota[j].inalt1:=50;
         nota[j].inalt2:=20;
         {fa#=paralelipiped+piramida}
         transformcolor(7,tonuri[playchanel[j].octave]);
         nota[j].color:=7;tnota(nota[j]).init;
         {notant[j]:=nota[j];}
       end;
     9:begin
         with p1 do begin x:=canale[6]*cos(p*8*22.5);y:=0;z:=canale[6]*sin(p*8*22.5) end;nota[j].p1:=p1;
         nota[j].lmare1:=30;
         nota[j].lmare2:=10;
         nota[j].lmic:=10;
         nota[j].inalt1:=20;
         nota[j].inalt2:=25;
         {sol#=trunchi de piramida+paralelipiped}
         transformcolor(8,tonuri[playchanel[j].octave]);
         nota[j].color:=8;tnota(nota[j]).init;
         {notant[j]:=nota[j];}
       end;
     11:begin
         with p1 do begin x:=canale[6]*cos(p*10*22.5);y:=0;z:=canale[6]*sin(p*10*22.5) end;nota[j].p1:=p1;
         nota[j].lmare1:=10;
         nota[j].lmare2:=10;
         nota[j].lmic:=30;
         nota[j].inalt1:=10;
         nota[j].inalt2:=10;
         {la#=2 trunchiuri}
         transformcolor(11,tonuri[playchanel[j].octave]);
         nota[j].color:=11;tnota(nota[j]).init;
         {notant[j]:=nota[j];}
       end;


     end;
     end;
     t:=0;decr:=false;

     repeat   {transforms notaant[j] in nota[j] then put notaant[j] equal with
                the current value of nota[j]}

     cls(0,vaddr);
     case decr of
     true : begin
            dec(t);
            if t<-5 then begin
                          decr:=not decr;
                          for j:=1 to 12 do
                          with notaant[j] do begin dx:=10;
                                                dy:=1;
                                                dz:=1;
                                                end;
                          end;
            end;
     false : begin
            inc(t);
            if t>5 then begin
                          decr:=not decr;
                          for j:=1 to 12 do
                          with notaant[j] do begin dx:=10;
                                                dy:=1;
                                                dz:=1;
                                                end;
                          end;
            end;
     end;

     for j:=1 to 12 do begin
                      morph[j]:=0;
                      m3[j]:=true;{allow morphing}
                      for i:=1 to 20 do for k:=1 to 4 do m4[j,i,k]:=false;
                      end;
     repeat

     cls(0,vaddr);

     for j:=1 to 2 do
     begin
         if morph[j]=0 then begin
         center:=origin;
         for i:=1 to notaant[j].nrvrf do
             begin
             rotatepoint(notaant[j].form[i].p1,10,10,10);
             rotatepoint(notaant[j].form[i].p2,10,10,10);
             end;

         center:=notaant[j].core;
         for i:=1 to notaant[j].nrvrf do
             begin
             rotatepoint(notaant[j].form[i].p1,5,5,5);
             rotatepoint(notaant[j].form[i].p2,5,5,5);
             end;
         end;
       if (notaant[j].color<>nota[j].color) and (m3[j])
          then begin
               m1[j]:=notaant[j].form;
               m2[j]:=nota[j].form;
               m3[j]:=not m3[j];
               morph[j]:=0.25;
               for i:=1 to 20 do
                  begin
                  if notaant[j].form[i].p1.z>m2[j][i].p1.z then param[j,i,1]:=-step;
                  if notaant[j].form[i].p1.z<m2[j][i].p1.z then param[j,i,1]:=step;
                  if notaant[j].form[i].p1.z=m2[j][i].p1.z then param[j,i,1]:=0;
                  if notaant[j].form[i].p2.z>m2[j][i].p2.z then param[j,i,2]:=-step;
                  if notaant[j].form[i].p2.z<m2[j][i].p2.z then param[j,i,2]:=step;
                  if notaant[j].form[i].p2.z=m2[j][i].p2.z then param[j,i,2]:=0;
                  end;
               end;
       if morph[j]>=0.25
          then begin
           for i:=1 to 20 do
           begin
           if param[j,i,1]=-step then
           if (notaant[j].form[i].p1.z>=m2[j][i].p1.z) then
              with notaant[j].form[i] do
              begin
              p1.z:=p1.z+param[j,i,1];
              p1.x:=(m2[j][i].p1.x-m1[j][i].p1.x)*(p1.z-m1[j][i].p1.z)/(m2[j][i].p1.z-m1[j][i].p1.z)+m1[j][i].p1.x;
              p1.y:=(m2[j][i].p1.y-m1[j][i].p1.y)*(p1.z-m1[j][i].p1.z)/(m2[j][i].p1.z-m1[j][i].p1.z)+m1[j][i].p1.y;
              end
            else begin
                 m4[j,i,1]:=true;
                 m4[j,i,2]:=true;
                 end;

           if param[j,i,1]=step then
           if (notaant[j].form[i].p1.z<=m2[j][i].p1.z) then
              with notaant[j].form[i] do
              begin
              p1.z:=p1.z+param[j,i,1];
              p1.x:=(m2[j][i].p1.x-m1[j][i].p1.x)*(p1.z-m1[j][i].p1.z)/(m2[j][i].p1.z-m1[j][i].p1.z)+m1[j][i].p1.x;
              p1.y:=(m2[j][i].p1.y-m1[j][i].p1.y)*(p1.z-m1[j][i].p1.z)/(m2[j][i].p1.z-m1[j][i].p1.z)+m1[j][i].p1.y;
              end
           else begin
                m4[j,i,2]:=true;
                m4[j,i,1]:=true;
                end;

           if param[j,i,2]=-step then
           if (notaant[j].form[i].p2.z>=m2[j][i].p2.z) then
              with notaant[j].form[i] do
              begin
              p2.z:=p2.z+param[j,i,2];
              p2.x:=(m2[j][i].p2.x-m1[j][i].p2.x)*(p2.z-m1[j][i].p2.z)/(m2[j][i].p2.z-m1[j][i].p2.z)+m1[j][i].p2.x;
              p2.y:=(m2[j][i].p2.y-m1[j][i].p2.y)*(p2.z-m1[j][i].p2.z)/(m2[j][i].p2.z-m1[j][i].p2.z)+m1[j][i].p2.y;
              end
           else begin
                m4[j,i,3]:=true;
                m4[j,i,4]:=true;
                end;

           if param[j,i,2]=step then
           if (notaant[j].form[i].p2.z<=m2[j][i].p2.z) then
              with notaant[j].form[i] do
              begin
              p2.z:=p2.z+param[j,i,2];
              p2.x:=(m2[j][i].p2.x-m1[j][i].p2.x)*(p2.z-m1[j][i].p2.z)/(m2[j][i].p2.z-m1[j][i].p2.z)+m1[j][i].p2.x;
              p2.y:=(m2[j][i].p2.y-m1[j][i].p2.y)*(p2.z-m1[j][i].p2.z)/(m2[j][i].p2.z-m1[j][i].p2.z)+m1[j][i].p2.y;
              end
           else begin
                m4[j,i,4]:=true;
                m4[j,i,3]:=true;
                end;
           end;
     end;
         notaant[j].draw;

     end;
     flip;
     until ok;

     asm mov ax,0c02h
         int 21h
         end;

     until readkey=#13;

     for j:=1 to 12 do notaant[j]:=nota[j];

 inc(k);
until keypressed ;
donevga256;
end.

