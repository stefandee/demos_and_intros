unit explode;

interface

procedure DoExplode;

implementation

uses graphics,types3d;

const N = 300;
      NF = 100;

type ray = record
         angle : integer;
         radb,rade,max : real;
         speed : real;
         color : byte;
         enable : boolean;
         end;

     fragment = record
              p : plan3d;
              xdir,ydir,zdir : shortint;
              enable : boolean;
              end;

     rmat = array[1..N] of ray;
     fmat = array[1..NF] of fragment;

var i     : integer;
    r     : ^rmat;
    ff    : ^fmat;
    still : boolean;
    fpr   : real;
    pro   : plan2d;
    a,b,c : integer;
    time  : integer;
    cnt   : integer;


procedure InitRays;
 var i : integer;
begin
 for i:=1 to N do
     with r^[i] do
          begin
           angle:=random(360);
           dec(angle,180);
           radb:=random(30)+10;
           rade:=random(10);
           max:=random(30)+43;
           speed:=random(4)+3;
           color:=250-random(20);
           enable:=true;
          end;
end;

{procedure InitFrag;
 var i,j   : integer;
     rx,ry : integer;
begin
 for i:=1 to NF do
     with ff[i] do
          begin
           with p do
                begin
                 a:=random(10)-5;b:=random(10)-5;c:=random(10)-5;if c=0 then c:=1;
                 with p1 do begin x:=0;y:=0;rx:=-random(10)-30;z:=rx;end;
                 with p2 do begin rx:=random(10)-5;ry:=random(10)-5;z:=(a*rx+b*ry)/c-40;x:=rx;y:=ry;end;
                 with p3 do begin rx:=random(10)-5;ry:=random(10)-5;z:=(a*rx+b*ry)/c-40;x:=rx;y:=ry;end;
                 with p4 do begin rx:=random(10)-5;ry:=random(10)-5;z:=(a*rx+b*ry)/c-40;x:=rx;y:=ry;end;
                 color:=random(128)+128;
                end;
           enable:=true;
           xdir:=2*(random(4)-2)+1;
           ydir:=2*(random(4)-2)+1;
           zdir:=2*(random(4)-2)+1;
          end;
end;}

procedure InitFrag2;
 const pi18 = pi/180;
       ang  = 36;
       rad  = 20;
       step = 2;
 var a,b : integer;
     sx,sy,sz : real;
     aa,ba : integer;
     stx,sty,stz : integer;
begin
 cnt:=0;
 for b:=-180 div ang to 180 div ang do
     for a:=0 to 180 div ang do
         begin
          inc(cnt);
          if cnt<NF
             then with ff^[cnt] do
                       begin
                        with p do
                         begin
                          sx:=rad*cost[a*ang]*cost[b*ang];
                          sy:=rad*cost[a*ang]*sint[b*ang];
                          sz:=rad*sint[a*ang];
                          with p1 do begin x:=sx;y:=sy-6;z:=sz;end;
                          with p2 do begin x:=sx;y:=sy+6;z:=sz;end;
                          with p3 do begin x:=sx-6;y:=sy;z:=sz;end;
                          with p4 do begin x:=sx+6;y:=sy;z:=sz;end;
                          color:=128+random(128);
                         end;
                        enable:=true;
                        stx:=1+random(4);sty:=1+random(4);stz:=1+random(4);
                        aa:=a*ang;ba:=b*ang;
                        if (aa>0) and (aa<90) then zdir:=-stz
                                              else zdir:=stz;
                        case ba of
                        -180..-90 : begin xdir:=stx;ydir:=sty;end;
                        -89..0    : begin xdir:=stx;ydir:=-sty;end;
                        1..90     : begin xdir:=-stx;ydir:=-sty;end;
                        91..180   : begin xdir:=-stx;ydir:=sty;end;
                        end;
                       end;
         end;
end;

procedure DoExplode;

begin

 cls(0,vaddr);cls(0,vga);
 loadpal('compile.dat',136481);setpal;
 loadspr('compile.dat',1,34208);

 putspr(1,160-spr[1].xl div 2,100-spr[1].yl div 2,normalput,vga);
 for i:=1 to 1000 do;
 new(r);new(ff);
 InitRays;
 InitFrag2;
 Hlin:=Nhlin;
 time:=0;

 repeat
  cls(0,vaddr);
  still:=false;
  inc(time);
  if time<2 then putspr(1,160-spr[1].xl div 2,100-spr[1].yl div 2,normalput,vaddr);
  for i:=1 to N do
      begin
      with r^[i] do
           begin
            if enable
            then begin
                  if radb<max then radb:=radb+speed
                              else if rade<radb then rade:=rade+speed
                                                else enable:=false;
                  dec(color);
                  line( orgx+round(radb*sint[angle]),orgy+round(radb*cost[angle]),
                        orgx+round(rade*sint[angle]),orgy+round(rade*cost[angle]),
                        color,vaddr);
                  still:=true;
                 end;
           end;
      end;
      for i:=1 to cnt do
               with ff^[i] do
               if enable
                  then begin
                        center.x:=(p.p1.x+p.p2.x+p.p3.x+p.p4.x) / 4;
                        center.y:=(p.p1.y+p.p2.y+p.p3.y+p.p4.y) / 4;
                        center.z:=(p.p1.z+p.p2.z+p.p3.z+p.p4.z) / 4;
                        rotatepoint(p.p1,11,14,8);rotatepoint(p.p2,11,14,8);
                        rotatepoint(p.p3,11,14,8);rotatepoint(p.p4,11,14,8);
                        with p do
                             begin
                              dec(color);
                              with p1 do
                                   begin
                                    x:=x+xdir;y:=y+ydir;z:=z+zdir;
                                    fpr:=z0/(z0+z);pro.p1.x:=round(fpr*x)+orgx;pro.p1.y:=round(fpr*y)+orgy;
                                   end;
                              with p2 do
                                   begin
                                    x:=x+xdir;y:=y+ydir;z:=z+zdir;
                                    fpr:=z0/(z0+z);pro.p2.x:=round(fpr*x)+orgx;pro.p2.y:=round(fpr*y)+orgy;
                                   end;
                              with p3 do
                                   begin
                                    x:=x+xdir;y:=y+ydir;z:=z+zdir;
                                    fpr:=z0/(z0+z);pro.p3.x:=round(fpr*x)+orgx;pro.p3.y:=round(fpr*y)+orgy;
                                   end;
                              with p4 do
                                   begin
                                    x:=x+xdir;y:=y+ydir;z:=z+zdir;
                                    fpr:=z0/(z0+z);pro.p4.x:=round(fpr*x)+orgx;pro.p4.y:=round(fpr*y)+orgy;
                                   end;
                              with p4 do if (z<-50) or (z>50) or (x<-60) or (x>60) then enable:=false;
                             end;
                        with pro do drawpoly(p1.x,p1.y,p2.x,p2.y,p3.x,p3.y,p4.x,p4.y,p.color,vaddr);
                       end;{enable end}

  flip;
  until (not still) or (port[$60]=1);
  fadeout(4);
  dispose(r);dispose(ff);donespr(1);
end;

begin
end.