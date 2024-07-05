PROGRAM
       SMARTSNOW;

USES
    GRAPH,AUXDATA;

CONST
     MaxSnow = 400;
     Pi180   = 0.017453292;

TYPE
    TPal = array[0..255,0..2] of byte;
    TSnow = record
            x,y : single;
            incy: single;
            ang : integer;
            rad : integer;
            angdir : shortint;
          end;
VAR
   Back,Img,Pal,Svga : pointer;
   gd,gm,i : integer;
   Snow : array[1..MaxSnow] of TSnow;
   SnowState : byte;
   sintab,costab : array[0..359] of single;
   tempdx : single;

{$L snowpal.obj}
{$F+}
procedure SnowPal;external;
{$F-}

{$L petroct.obj}
{$F+}
procedure Petroct;external;
{$F-}

procedure UpDateSnow(index : integer);
begin
  Snow[index].x := random(640);
  if (SnowState=0) then Snow[index].y := random(350)
     else Snow[index].y := 0;
  Snow[index].ang := 0;
  Snow[index].incy := random(16384)/32768+0.4;
  Snow[index].rad := random(3)+2;
  if random(2)=0 then Snow[index].angdir := 1
     else Snow[index].angdir := -1;
end;

BEGIN
  Pal := Addr(SnowPal);Img := Addr(Petroct);Back := Addr(BackGnd);
  gd := installuserdriver('SVGA256',NIL);
  gm := 2;
  initgraph(gd,gm,'');
  for i:=0 to 255 do setrgbpalette(i,TPal(Pal^)[i,0],TPal(Pal^)[i,1],TPal(Pal^)[i,2]);
  for i:=1 to MaxSnow do UpDateSnow(i);inc(SnowState);
  for i:=0 to 359 do begin sintab[i] := sin(i*pi/180);costab[i] := cos(i*pi/180);end;
  putimage(320-147,300,Img^,NormalPut);
  putimage(0,390,Back^,NormalPut);
  repeat
    for i:=1 to MaxSnow do
        begin
	  putpixel(round(Snow[i].x),round(Snow[i].y),0);
	  if (getpixel(round(Snow[i].x),round(Snow[i].y+1))<>0)
	     then if (getpixel(round(Snow[i].x+1),round(Snow[i].y+1))<>0)
	          then if (getpixel(round(Snow[i].x-1),round(Snow[i].y+1))<>0)
                          then begin
		                 putpixel(round(Snow[i].x),round(Snow[i].y),254);
			         UpDateSnow(i);
                               end
		          else begin
		                 Snow[i].y := Snow[i].y+Snow[i].incy;
			         Snow[i].x := Snow[i].x-1;
                               end
	          else begin
		         Snow[i].y := Snow[i].y++Snow[i].incy;
			 Snow[i].x := Snow[i].x+1;
                       end
	      else  begin
	              Snow[i].y := Snow[i].y + Snow[i].incy;
                      Snow[i].ang := Snow[i].ang+Snow[i].angdir*10;
                      if Snow[i].ang<0 then Snow[i].ang := 360+Snow[i].ang;
                      if Snow[i].ang>360 then Snow[i].ang := Snow[i].ang mod 360;
                      tempdx := Snow[i].rad*costab[Snow[i].ang]*sintab[5];
		      Snow[i].x := Snow[i].x + tempdx;
		      if (getpixel(round(Snow[i].x),round(Snow[i].y))<>0)
                         then Snow[i].x:=Snow[i].x-tempdx;
                    end;
	  putpixel(round(Snow[i].x),round(Snow[i].y),255);
	  if (Snow[i].y>=getmaxy) then UpDateSnow(i);
        end;
  until port[$60]=1;
  asm
    mov ax,$0c02
    int $21
  end;
  closegraph;
  writeln('                                  Snow by Karg.');
  writeln('                         Contact me at pp709@cs.utt.ro');
END.