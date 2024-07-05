PROGRAM
       SCROLLER_DEMO;

USES
    DOS;

{$I sincos.inc}
{$I 3d.inc}
{$I modex.inc}
{$I scale.inc}

CONST
     XFontSize = 7;
     YFontSize = 7;
     Text : string[50] = '  S.C. PETROCONST  - BIROUL INFORMATICA ';

TYPE
    TFont = array[' '..'`'] of pointer;
    TLetter = array[1..YFontSize,1..XFontSize] of byte;

VAR
   YBall,RBall : pointer;
   MyFont      : TFont;
   i,j         : integer;
   Int1CSave   : Pointer;
   StartLetter : integer;
   CrtLetter   : integer;
   Index       : integer;
   Scale       : integer;
   SupIndex    : integer;
   Scroll      : array[1..YFontSize+2,1..50] of byte;

{$L yball.obj}
{$F+}
procedure YBallData;external;
{$F-}

{$L rball.obj}
{$F+}
procedure RBallData;external;
{$F-}

{$L font.obj}
{$F+}
procedure Font;external;
{$F-}

procedure InitFont;
var
   i : char;
begin
  for i:=' ' to '`' do MyFont[i] := ptr(seg(Font),ofs(Font)+XFontSize*YFontSize*(byte(i)-32));
end;

{$F+,S-,W-}
procedure TimerHandler; interrupt;
  begin
    { Timer ISR }
    {*** Refer to DDK and DPMI Specs for creating ISR's ***}
    DrawEnabled := true;
  end;
{$F-,S+}

procedure SetTimerFreq(freq : word);
var
   FreqValue : longint;
begin
  if freq <> 0
     then begin
            FreqValue := $1234DD div freq;
            port[$43] := $34;
            port[$40] := FreqValue mod 256;
            port[$40] := FreqValue div 256;
          end
     else begin
            port[$43] := $34;
            port[$40] := 0;
            port[$40] := 0;
          end;
end;

BEGIN
  Set320x240;
  InitSinCos;
  InitFont;

  SetTimerFreq(30);
  GetIntVec($1C,Int1CSave);
  SetIntVec($1C,Addr(TimerHandler));

  getmem(WorkPal,768);FillChar(WorkPal^,768,0);
  for i:=0 to 63 do
      begin
        TPal(WorkPal^)[i,1] := i;
        TPal(WorkPal^)[i,2] := i;
        TPal(WorkPal^)[i+64,1] := i;
      end;
  SetPal(WorkPal);

  YBall := Addr(YBallData);RBall := Addr(RBallData);

  new(Obj3D[1].ObjData);new(Pro);
  EyePos.Z := 180;
  with Vi do begin x:=63;y:= 0;z:= 0;end;
  with Vj do begin x:= 0;y:=63;z:= 0;end;
  with Vk do begin x:= 0;y:= 0;z:=-63;end;
  Inverter(vi,vj,vk);
  FillChar(Scroll,sizeof(Scroll),0);
  StartLetter := 1;Index := 1;SupIndex := 10;

  repeat
    SetActivePage(page);
    Cls(page,0);

    with Obj3D[1] do
         begin
           {SupAng.X := (SupAng.X+2) mod 360;}
           SupAng.Y := (SupAng.Y+1) mod 360;
           SupAng.Z := (SupAng.Z-1);
           if SupAng.Z<0 then SupAng.Z := 360+SupAng.Z;
           {Ang.X := 45*longint(sintab[SupAng.X]) shr 14;}
           Ang.Y := 25*longint(sintab[SupAng.Y]) shr 14;
           Ang.Z := 45*longint(costab[SupAng.Z]) shr 14;
           {if Ang.X<0 then Ang.X := 360+Ang.X;}
           if Ang.Y<0 then Ang.Y := 360+Ang.Y;
           if Ang.Z<0 then Ang.Z := 360+Ang.Z;
         end;

    inc(Index);
    if Index>XFontSize
       then begin
              inc(StartLetter);
              if StartLetter>length(Text) then StartLetter := 1;
              Index := 1;
            end;

    Obj3d[1].ObjData^.VC := 0;

    for j:=1 to YFontsize+2 do
        begin
          for i:=50 downto 2 do
            with Obj3D[1].ObjData^ do
                 begin
                   Vertex[1].X := (25-i)*7;
                   Vertex[1].Y := (j-5)*7;
                   Vertex[1].Z := 0;
                   RotatePoint(Vertex[1],Obj3d[1].Ang.X,Obj3d[1].Ang.Y,Obj3d[1].Ang.Z);
                   ProLookPoint(EyePos,Vertex[1]);
                   if Scroll[j,i] = 255 then XScale1(160+Pro^[1].X,120+Pro^[1].Y,7,7,7,7,ActStart,YBall)
                      else XScale1(160+Pro^[1].X,120+Pro^[1].Y,7,7,7,7,ActStart,RBall);
                   Scroll[j,i] := Scroll[j,i-1];
                 end;
          if j in [2..YFontSize+1]
             then Scroll[j,1] := TLetter(MyFont[Text[StartLetter]]^)[j-1,Index];
        end;
    repeat until DrawEnabled;
    DrawEnabled := false;
    SetVisiblePage(page);
    page := (page+1) mod 2;
  until port[$60]=1;

  asm
    mov ax,$0c02
    int $21
  end;

  SetIntVec($01C,Int1CSave);
  SetTimerFreq(0);

  TextMode;

  writeln('                              ScrollBalls by Karg');
  writeln('                         Contact me at pp709@cs.utt.ro');
END.