program
       Plasmap;

uses
    crt;

type
    PTMap     = ^TMap;
    TMap      = array[0..127,0..127] of byte;

var
   map : PTMap;
   i,j : integer;

{$I sincos.inc}
{$I 3d.inc}
{$I modex.inc}
{$I scale.inc}

procedure GeneratePlasmaMap(grainess : integer);

procedure Adjust(xa,ya,x,y,xb,yb : integer);
var
   ps : single;
begin
  if Map^[x,y] <> 0 then exit;
  ps := (32767*random-16383)*grainess;
  ps := ps*(abs(xb-xa)+abs(yb-ya));
  ps := round(ps/262144);
  ps := longint(Map^[xa,ya]+Map^[xb,yb]+1) div 2 + ps;
  if ps>63 then ps := 63;
  if ps<1 then ps := 1;
  Map^[x,y] := round(ps);
end;

procedure SubDivide(x1,y1,x2,y2 : integer);
var
   x,y : integer;
begin
  if ((x2-x1)<2) and ((y2-y1)<2) then exit;
  x := (x1+x2) div 2;y := (y1+y2) div 2;
  Adjust(x1,y1,x ,y1,x2,y1);
  Adjust(x2,y1,x2,y ,x2,y2);
  Adjust(x1,y2,x ,y2,x2,y2);
  Adjust(x1,y1,x1,y ,x1,y2);
  if Map^[x,y] = 0 then
     begin
       Map^[x,y] := ((Map^[x1,y1]+Map^[x2,y1]+Map^[x2,y2]+Map^[x1,y2]+2) div 4);
       if Map^[x,y]>63 then Map^[x,y] := 63-random(Map^[x,y]-63);
     end;
  SubDivide(x1,y1,x ,y);
  SubDivide(x ,y1,x2,y);
  SubDivide(x ,y ,x2,y2);
  SubDivide(x1,y ,x ,y2);
end;

begin
  Map^[0,0] := 1+longint(longint(random(32768))*longint(63) div 64 div longint(128));
  Map^[0,127] := 1+longint(longint(random(32768))*longint(63) div 64 div longint(128));
  Map^[127,0] := 1+longint(longint(random(32768))*longint(63) div 64 div longint(128));
  Map^[127,127] := 1+longint(longint(random(32768))*longint(63) div 64 div longint(128));
  SubDivide(0,0,127,127);
end;

begin
  new(map);
  Randomize;
  Set320x240;
  InitSinCos;
  getmem(workpal,768);FillChar(workPal^,768,0);
  for i:=0 to 63 do TPal(WorkPal^)[i,2] := i;
  SetPal(WorkPal);
  for i:=0 to 63 do
      begin
        PutPixel_x(i*4,1,i);
        PutPixel_x(i*4+1,1,i);
        PutPixel_x(i*4+2,1,i);
        PutPixel_x(i*4+3,1,i);
      end;
  FillChar(Map^,sizeof(Map^),0);
  GeneratePlasmaMap(32);
  XScale1(96,56,128,128,128,128,ActStart,Map);
  {repeat
    PalRot(WorkPal,1,63);
    SetPal(WorkPal);
  until port[$60]<128;}
  readln;
end.