program
       Moire_patterns;

{$I sincos.inc}
{$I 3d.inc}
{$I modex.inc}
{$I scale.inc}

type
    tdata = array[0..166,0..166] of byte;
    ptdata = ^Tdata;
var
   a,i,j,x,y : integer;
   c     : byte;
   midx,midy : integer;
   start : integer;
   adir,ydir,xdir,xrnd,yrnd : integer;
   ang : integer;
   ic,is,jc,js : longint;
   Data : PTData;
   mov1,mov2,mov3,mov4 : integer;
   plasmacos : array[0..255] of integer;
   f : file;

procedure FastMoire(a : integer);
var
   x,y,i,j : integer;
   c         : byte;
begin
  x := a;
  for i:=0 to 83 do
      begin
        x := x+a;
        y := x;
        for j:=i to 83 do
            begin
              y := y+a;
              asm
                db $66
                mov ax,x
                db $66
                mul ax
                db $66
                mov bx,ax
                db $66
                mov ax,y
                db $66
                mul ax
                db $66
                add bx,ax
                db $66
                shr bx,11
                and bl,63
                mov c,bl
              end;
              Data^[83+i,83+j] := c;
              Data^[83-i,83+j] := c;
              Data^[83+i,83-j] := c;
              Data^[83-i,83-j] := c;
              Data^[83+j,83+i] := c;
              Data^[83-j,83+i] := c;
              Data^[83+j,83-i] := c;
              Data^[83-j,83-i] := c;
            end;
      end;

end;

Procedure RealTimePlasma;
VAR loop1,loop2:integer;
    tmov1,tmov2,tmov3,tmov4:integer;
BEGIN
  mov1:=mov1-4;
  mov3:=mov3+4;
  mov1:=mov1+random (1);
  mov2:=mov2-random (2);
  mov3:=mov3+random (1);
  mov4:=mov4-random (2);   { Movement along the plasma + noise}

  tmov3:=mov3;
  tmov4:=mov4;
  For loop1:=0 to 166 do BEGIN
    tmov1:=mov1;
    tmov2:=mov2;
    for loop2:=0 to 166 do
        begin
          Data^[loop1,loop2] := abs(plasmacos[tmov1]+plasmacos[tmov2]+plasmacos[tmov3]+
                            plasmacos[tmov4]+plasmacos[loop1]+plasmacos[loop2]) mod 64+64;
          tmov1:=(tmov1+4) mod 360;
          tmov2:=(tmov2+5) mod 360;
        end;
    tmov3:=(tmov3+3) mod 360;
    tmov4:=(tmov4+6) mod 360;
  END;
END;

Function rad (theta : real) : real; { Converts degrees to radians }
  BEGIN
    rad := theta * pi / 180
  END;

begin
  midx := 160;
  midy := 120;
  InitSinCos;
  Set320x240;
  start := 20;
  for i:=0 to 31 do SetRGB(i,i*2,i*2,0);
  for i:=32 to 63 do SetRGB(i,(63-i)*2,(63-i)*2,0);
  for i:=0 to 31 do SetRGB(i+64,0,0,i*2);
  for i:=32 to 63 do SetRGB(i+64,0,0,(63-i)*2);

  {for i:=0 to 63 do SetRGB(i+64,i div 2,0,i);}
  SetRGB(128,63,63,63);
  a := 5;adir := 1;midx := 359;
  new(Data);
  FillChar(Data^,sizeof(Data^),0);
  ClipRt := 243;
  ClipLt := 77;
  For i:=0 to 255 do plasmacos[i]:=round (cos (rad(i/360*255*2))*31)+32;
  {assign(f,'plasma.dat');rewrite(f,1);blockwrite(f,plasmacos,sizeof(plasmacos));close(f);}

  repeat
    SetActivePage(page);
    Cls(page,0);
    inc(a,adir);
    if a>53 then adir := -1;
    if a<=5 then adir := 1;
    {ang := (ang + 3) mod 360;}
    dec(midx,3);
    if midx<-60 then midx := 380;
    {FastMoire(a);}
    RealtimePlasma;
    XScale1(midx-83,120-83,167,167,167,167,ActStart,Ptr(Seg(Data^),Ofs(Data^)));
    Line_X(77,37,243,37,128);
    Line_X(77,203,243,203,128);
    Line_X(77,37,77,203,128);
    Line_X(243,37,243,203,128);
    SetVisiblePage(page);
    page := (page+1) mod 2;
  until port[$60]<128;
  TextMode;
end.
