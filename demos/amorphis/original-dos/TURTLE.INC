CONST
   PenStatus : boolean = true;
   PenColor  : byte    = 255;
   Angle     : integer = 45;
   XTurtle   : longint = 160;
   YTurtle   : longint = 120;

procedure Right(rotang : integer);
begin
  Angle := Angle+rotang;
  if Angle<0 then Angle := 360+Angle;
  if Angle>359 then Angle := Angle-360;
end;

procedure Left(rotang : integer);
begin
  Right(-rotang);
end;

procedure Forwd(dist : integer);
var
   XNTurtle,YNTurtle : longint;
begin
  XNTurtle := XTurtle+longint(dist)*longint(costab[Angle]) div 16384;
  YNTurtle := YTurtle-longint(dist)*longint(sintab[Angle]) div 16384;
  if PenStatus then Line_X(XTurtle,YTurtle,XNTurtle,YNTurtle,PenColor);
  XTurtle := XNTurtle;
  YTurtle := YNTurtle;
end;

procedure Back(dist : integer);
begin
  Forwd(-dist);
end;

procedure SetReper(NewX,NewY : integer);
begin
  XTurtle := NewX;
  YTurtle := NewY;
end;