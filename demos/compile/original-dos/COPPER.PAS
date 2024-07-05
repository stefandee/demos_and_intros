unit Copper;
{$R-}

interface

uses graphics;

procedure DoBars;

implementation

const Ybegin   = 10;
      Yfinal   = 190;
      Xbegin   = 60;
      Xfinal   = 240;
      Space    = 3;
      Width    = 10;
      FirstCol = 0;
      BarSize  = 20;
      NoBars   = 8;

      down     = 0;
      up       = 1;

type palentry = record
              r,g,b : byte;
              end;

type BarType = record
             pos : array[1..20] of integer;
             dir : array[1..20] of byte;
             col : array[1..20] of palentry;
             end;

var i,j : integer;
    PAL : paltype;
    Bars : array[1..40] of bartype;
    counter : integer;

procedure DrawBars2( where : word);
  var Y : integer;
begin
  for Y:=XBegin to Xfinal do Line(Y,Ybegin,Y,Yfinal,FirstCol+Y-Ybegin,where);
  for Y:=YBegin to Yfinal do Hlin(Xbegin,Xfinal,Y,FirstCol+Y-Ybegin,where);
end;

procedure DrawBars1( where : word);
  var Y : integer;
begin
  for Y:=YBegin to Yfinal do Hlin(Xbegin,Xfinal,Y,FirstCol+Y-Ybegin,where);
end;

procedure DrawBars3( where : word);
  var Y : integer;
begin
  for Y:=XBegin to Xfinal do Line(Y,Ybegin,Y,Yfinal,FirstCol+Y-Ybegin,where);
end;

procedure ColorBars;
  var i,j    : integer;
      mid    : integer;
      whatcolor : integer;
begin
  whatcolor:=0;
  mid:=barsize div 2;
  for i:=1 to NoBars do
      begin
        for j:=1 to mid do
            begin
              bars[i].pos[j]:=Ybegin + (i-1) * (BarSize+Space) + j -1;
              bars[i].dir[j]:=down;
              case whatcolor mod 4 of
              0 : begin
                   bars[i].col[j].r:=j*6;bars[i].col[j].g:=0;bars[i].col[j].b:=0;
                  end;
              1 : begin
                   bars[i].col[j].r:=0;bars[i].col[j].g:=j*6;bars[i].col[j].b:=0;
                  end;
              2 : begin
                   bars[i].col[j].r:=0;bars[i].col[j].g:=0;bars[i].col[j].b:=j*6;
                  end;
              3 : begin
                   bars[i].col[j].r:=j*6;bars[i].col[j].g:=j*6;bars[i].col[j].b:=0;
                  end;
              end;
            end;
        for j:=barsize downto mid do
            begin
              bars[i].pos[j]:=Ybegin + (i-1)*(BarSize+Space)+j-1;
              bars[i].dir[j]:=down;
              case whatcolor mod 4 of
              0 : begin
                   bars[i].col[j].r:=(barsize-j)*6;bars[i].col[j].g:=0;bars[i].col[j].b:=0;
                  end;
              1 : begin
                   bars[i].col[j].r:=0;bars[i].col[j].g:=(barsize-j)*6;bars[i].col[j].b:=0;
                  end;
              2 : begin
                   bars[i].col[j].r:=0;bars[i].col[j].g:=0;bars[i].col[j].b:=(barsize-j)*6;
                  end;
              3 : begin
                   bars[i].col[j].r:=(barsize-j)*6;bars[i].col[j].g:=(barsize-j)*6;bars[i].col[j].b:=0;
                  end;

              end;
            end;
       inc(whatcolor);
      end;
end;

procedure MoveBars;
  var count1,count2 : integer;
begin
  fillchar(workpal,768,0);
  for count1 := 1 to NoBars do
      for count2 := 1 to Barsize do
          with bars[count1] do
               begin
                 case dir[count2] of
                 up : begin
                        dec(bars[count1].pos[count2]);
                        if bars[count1].pos[count2]<Ybegin then dir[count2]:=down;
                      end;
                 down
                    : begin
                        inc(bars[count1].pos[count2]);
                        if bars[count1].pos[count2]>Yfinal then dir[count2]:=up;
                      end;
                 end;
               workpal[pos[count2],1]:=col[count2].r;
               workpal[pos[count2],2]:=col[count2].g;
               workpal[pos[count2],3]:=col[count2].b;
               end;
setpal;
end;


procedure DoBars;
begin

cls(0,vga);cls(0,vaddr);
asm
   mov ax,$0c02
   int $21
end;

Hlin:=NHlin;
ColorBars;
DrawBars1(vga);
counter:=0;

repeat
MoveBars;
inc(counter);
until (counter>1200) or (port[$60]=1);

fadeout(4);
asm
   mov ax,$0c02
   int $21
end;

ColorBars;
DrawBars3(vga);
counter:=0;

repeat
MoveBars;
inc(counter);
until (counter>1000) or (port[$60]=1);

fadeout(4);
asm
   mov ax,$0c02
   int $21
end;

Hlin:=Glare;
ColorBars;
DrawBars2(vga);
counter:=0;

repeat
MoveBars;
inc(counter);
until (counter>800) or (port[$60]=1);

Fadeout(4);
end;

Begin
End.