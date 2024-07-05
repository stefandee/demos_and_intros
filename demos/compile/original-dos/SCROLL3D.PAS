unit scroll3d;

interface

procedure DoScroll3d;

implementation

uses graphics,types3d;

procedure DoScroll3d;

type scroll = array[1..7,1..50] of byte;
     pscroll = ^scroll;

const msg : string ='ANOTHER BORING SCROLLER ! JUST A TEST , NOTHING MORE . IF YOU LIKE IT , I''LL ADD MORE TEXT .';

var s        : pscroll;
    ip,jp,kp : point3d;
    x,y,z    : integer;
    x3d,y3d,z3d  : real;
    i,j      : integer;
    pro      : point2d;
    fpr      : real;
    msgcnt   : integer;
    cut      : integer;
    f        : file;

begin

 cls(0,vaddr);cls(0,vga);
 loadpal('compile.dat',23390);setpal;
 new(s);fillchar(s^,17*50,0);
 loadspr('compile.dat',1,54558);loadspr('compile.dat',2,135609);

 with ip do begin x:=1;y:=0;z:=0;end;
 with jp do begin x:=0;y:=1;z:=0;end;
 with kp do begin x:=0;y:=0;z:=1;end;
 rotatepoint(ip,0,180,0);rotatepoint(jp,0,180,0);rotatepoint(kp,0,180,0);

 center:=origin;
 topclip:=20;
 botclip:=180;
 leftclip:=10;
 rightclip:=310;
 cut:=7;msgcnt:=1;

 repeat
 cls(0,vaddr);

 rotatepoint(ip,2,2,0);
 rotatepoint(jp,2,2,0);
 rotatepoint(kp,2,2,0);
 dec(cut);

 if cut<=1 then begin
                inc(msgcnt);
                if msgcnt>length(msg) then msgcnt:=1;
                cut:=7;
               end;

 for i:=1 to 7 do
     begin
      for j:=50 downto 2 do
          begin
           s^[i,j]:=s^[i,j-1];
           x:=(j-25)*4;y:=(i-8)*5;z:=0;
           x3d:=x*ip.x+y*jp.x;y3d:=x*ip.y+y*jp.y;z3d:=x*ip.z+y*jp.z;
           fpr:=z0/(z0+z3d);
           {putpixel(round(x3d*fpr+orgx),round(y3d*fpr+orgy),255,vaddr);}
           pro.x:=round(x3d*fpr+orgx);pro.y:=round(y3d*fpr+orgy);
           with pro do
           if (x>leftclip) and (x<rightclip) and (y>topclip) and (y<botclip) then
           case s^[i,j] of
           0 : putspr(1,round(x3d*fpr+orgx),round(y3d*fpr+orgy),gameput,vaddr);
           else putspr(2,round(x3d*fpr+orgx),round(y3d*fpr+orgy),gameput,vaddr);
           end;
          end;
      s^[i,1]:=micro[msg[msgcnt]][i,7-cut+1];
     end;

 flip;
 until port[$60]=1;
 dispose(s);donespr(1);donespr(2);
 fadeout(3);
end;

begin
end.



