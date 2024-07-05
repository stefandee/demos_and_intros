program testparam;
uses graph,crt,dos;
const   nrfig=48;
        step=1;
        dim=15;
        path='';
	position:array[1..nrfig,1..2] of integer=((0,16),(0,75),(0,135),(0,195),(0,255),(0,315),
                                                  (80,15),(80,75),(80,135),(80,195),(80,255),(80,315),
                                                  (160,15),(160,75),(160,135),(160,195),(160,255),(160,315),
                                                  (240,15),(240,75),(240,135),(240,195),(240,255),(240,315),
                                                  (320,15),(320,75),(320,135),(320,195),(320,255),(320,315),
                                                  (400,15),(400,75),(400,135),(400,195),(400,255),(400,315),
                                                  (480,15),(480,75),(480,135),(480,195),(480,255),(480,315),
                                                  (560,15),(560,75),(560,135),(560,195),(560,255),(560,315));
      maxpro=100;
      maxpoint=100;
      maxlink=100;
      z0=320;
      p=pi/180;
type    buffer=array[1..512] of byte;
        sb=^buffer;
        buffer1=array[1..1024] of byte;
        sb1=^buffer1;

        obiect=record
            nrpoint:integer;
            nrlink:integer;
            point:array[1..maxpoint,1..3] of real;
            link:array[1..maxlink,1..2] of integer;
            name:string;
            end;

var fil:file;
    fig:sb;
    asp1,asp2,asp3,asp4,asp5,asp6:sb1;
    i,j,k,plane,sprite:integer;
    gm,gd,rd:integer;
    pro:array[1..maxpoint,1..2] of real;
    one:obiect;
    f:file of obiect;
    orgx,orgy:real;
    regs:registers;
{procedure copi;
begin
cleardevice;

assign(fil,'asp1.zpx');
reset(fil,1024);
blockread(fil,asp1^,1,rd);
close(fil);
putimage(0,0,asp1^,0);
for i:=0 to 60 do
for j:=0 to 30 do
putpixel(100+60-i,100+j,getpixel(i,j));
getimage(100,100,160,130,asp1^);
assign(fil,'c:\tp\phane\present\plot\asp4.zpx');
rewrite(fil,1024);
blockwrite(fil,asp1^,1,rd);
close(fil);

assign(fil,'c:\tp\phane\present\plot\asp2.zpx');
reset(fil,1024);
blockread(fil,asp2^,1,rd);
close(fil);
putimage(0,0,asp2^,0);
for i:=0 to 60 do
for j:=0 to 30 do
putpixel(100+60-i,100+j,getpixel(i,j));
getimage(100,100,160,130,asp1^);
assign(fil,'c:\tp\phane\present\plot\asp5.zpx');
rewrite(fil,1024);
blockwrite(fil,asp1^,1,rd);
close(fil);

assign(fil,'c:\tp\phane\present\plot\asp3.zpx');
reset(fil,1024);
blockread(fil,asp3^,1,rd);
close(fil);
putimage(0,0,asp3^,0);
for i:=0 to 60 do
for j:=0 to 30 do
putpixel(100+60-i,100+j,getpixel(i,j));
getimage(100,100,160,130,asp1^);
assign(fil,'c:\tp\phane\present\plot\asp6.zpx');
rewrite(fil,1024);
blockwrite(fil,asp1^,1,rd);
close(fil);

readln;
end;}
Procedure Rotate3D(a,b,c : real;var obj:obiect);
var sa,sb,sc   : real;
    ca,cb,cc,u : real;
begin
  a:=a*p; b:=b*p; c:=c*p;
  ca:=cos(a); sa:=sin(a);
  cb:=cos(b); sb:=sin(b);
  cc:=cos(c); sc:=sin(c);
  for i:=1 to obj.nrpoint do
  begin
    if a<>0 then
    begin
      u:=obj.point[i,2];
      obj.point[i,2]:=u*ca+obj.point[i,3]*sa;
      obj.point[i,3]:=obj.point[i,3]*ca-u*sa;
    end;
    if b<>0 then
    begin
      u:=obj.point[i,3];
      obj.point[i,3]:=u*cb+obj.point[i,1]*sb;
      obj.point[i,1]:=obj.point[i,1]*cb-u*sb;
    end;
    if c<>0 then
    begin
      u:=obj.point[i,1];
      obj.point[i,1]:=u*cc+obj.point[i,2]*sc;
      obj.point[i,2]:=obj.point[i,2]*cc-u*sc;
    end;
  end;
end;

Procedure Proiectie(var obj:obiect);

var fpr : real;

begin
  for i:=1 to obj.nrpoint do
  begin
    fpr:=z0/(z0-obj.point[i,3]);
    pro[i,1]:=fpr*obj.point[i,1]*GetMaxY/(2*z0*sin(10)/cos(10))+orgx;
    pro[i,2]:=fpr*obj.point[i,2]*GetMaxY/(2*z0*sin(10)/cos(10))+orgy;
  end;
end;

procedure DRAW(color:integer;var obj:obiect);

begin
setcolor(color);
for i:=1 to obj.nrlink do begin

line (round(pro[obj.link[i,1],1]),round(pro[obj.link[i,1],2]),
     round(pro[obj.link[i,2],1]),round(pro[obj.link[i,2],2]));
end;
end;

procedure MOV(mx,my,mz:integer;var obj:obiect);

begin

for i:=1 to obj.nrpoint do
begin
obj.point[i,1]:=obj.point[i,1]+mx;
obj.point[i,2]:=obj.point[i,2]+my;
obj.point[i,3]:=obj.point[i,3]+mz;
end;
end;

BEGIN

new(fig);new(asp1);new(asp2);new(asp3);new(asp4);new(asp5);new(asp6);
assign(fil,path+'computer.zpx');
reset(fil,512);
blockread(fil,fig^,1,rd);
close(fil);
assign(fil,path+'asp1.zpx');
reset(fil,1024);
blockread(fil,asp1^,1,rd);
close(fil);
assign(fil,path+'asp2.zpx');
reset(fil,1024);
blockread(fil,asp2^,1,rd);
close(fil);
assign(fil,path+'asp3.zpx');
reset(fil,1024);
blockread(fil,asp3^,1,rd);
close(fil);
assign(fil,path+'asp4.zpx');
reset(fil,1024);
blockread(fil,asp4^,1,rd);
close(fil);
assign(fil,path+'asp5.zpx');
reset(fil,1024);
blockread(fil,asp5^,1,rd);
close(fil);
assign(fil,path+'asp6.zpx');
reset(fil,1024);
blockread(fil,asp6^,1,rd);
close(fil);
orgx:=320;
orgy:=175;
assign(f,path+'obiecte.3dp');
reset(f);
read(f,one);
close(f);

gd:=vga;
gm:=vgamed;
initgraph(gd,gm,'c:\bin\bp\bgi');

rotate3d(0,90,0,one);
rotate3d(180,0,0,one);
mov(-100,0,0,one);

setfillstyle(1,black);
setrgbpalette(magenta,0,0,23);
plane:=0;k:=1;j:=0;sprite:=0;

repeat

setactivepage(plane);
setviewport(0,0,getmaxx,getmaxy,clipon);
clearviewport;

for i:=1 to nrfig do begin
case k of
1: begin
   inc(position[i,1],step);
   dec(position[i,2],step);
   if j>=dim then begin
                  j:=0;k:=2;
                  end;
  end;
2: begin
   inc(position[i,1],step);
   inc(position[i,2],step);
   if j>=dim then begin
                  j:=0;k:=3;
                  end;
  end;
3: begin
   dec(position[i,1],step);
   inc(position[i,2],step);
   if j>=dim then begin
                  j:=0;k:=4;
                  end;
  end;

4: begin
   dec(position[i,1],step);
   dec(position[i,2],step);
   if j>=dim then begin
                  j:=0;k:=1;
                  end;
  end;

end;{end case}
putimage(position[i,1],position[i,2],fig^,0);
end;{end for}
setbkcolor(magenta);
inc(j);
setfillstyle(1,green);
bar(50,125,590,225);
setfillstyle(1,black);
bar(60,135,580,215);

rotate3d(0,10,0,one);
proiectie(one);
draw(yellow,one);
inc(sprite);
case sprite of

1,4: begin
        putimage(60,165,asp3^,0);
        putimage(60,165,asp1^,0);
        putimage(510,165,asp4^,0);
     end;
2,5: begin
        putimage(60,165,asp1^,0);
        putimage(60,165,asp2^,0);
        putimage(510,165,asp5^,0);
     end;
3,6: begin
        putimage(60,165,asp2^,0);
        putimage(60,165,asp3^,0);
        putimage(510,165,asp6^,0);
     end;
end;
if sprite>5 then sprite:=0;
setvisualpage(plane);
inc(plane);
if plane>1 then plane:=0;
until keypressed;
regs.ah:=$0c;
regs.al:=$02;
intr($21,regs);
closegraph;
end.















