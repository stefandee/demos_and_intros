program tunnel;
{$R-}
uses graphics,types3d,crt;

const xray = 10;
      yray = 5;
      no   = 20;
      angle =36;

var  i,j    : integer;
     init   : array[1..360 div angle,1..2] of integer;
     zbuf   : array[1..50] of integer;
     x,y,z  : integer;

procedure Generate;
begin
  for i:=1 to 360 div angle do
      begin
        init[i,1]:=round(xray*cost[(i*angle) mod 180]);
        init[i,2]:=round(yray*sint[(i*angle) mod 180]);
      end;
  for i:=1 to no do zbuf[i]:=100 div i;
end;

begin
  vga256;loadpal('blue.pal');setpal;initvscreen;cls(0,vaddr);
  Generate;

  repeat
    cls(0,vaddr);
    for j:=1 to no do
        begin
        dec(zbuf[j],3);
        if zbuf[j]<10 then zbuf[j]:=100;

        for i:=1 to no do
            begin
            if zbuf[j]<>0
               then begin
                    x:=orgx+(init[i,1] shl 6) div zbuf[j];
                    y:=orgy+(init[i,2] shl 6) div zbuf[j];
                    if (x>leftclip) and (x<rightclip) and
                       (y>topclip)  and (y<botclip)
                       then putpixel(x,y,255,vaddr);
                    end;
            end;
       end;

    delay(1000);
    flip;
    if port[$60]=24 then dec(orgx,2);
    if port[$60]=25 then inc(orgx,2);
    if port[$60]=44 then inc(orgy,2);
    if port[$60]=16 then dec(orgy,2);
    asm
       mov ax,$0c02
       int 21h
    end;
  until port[$60]=1;
end.


