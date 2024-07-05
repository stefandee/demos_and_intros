unit Plasma;
{$R-}

interface

uses graphics;

procedure DoPlasma;

implementation

var
    tbl : Array [0..255] of byte; { cos table lookup }
    mov1,mov2,mov3,mov4 : byte;  { current positions }
    tmov1,tmov2,tmov3,tmov4:byte; { Temporary variables, so we dont destroy}
    inc1,inc2,inc3,inc4 : byte;
    tinc1,tinc2,tinc3,tinc4 : byte;

Procedure DrawPlasma;assembler;
  asm
    push  es
    push  ds

    mov   dh,mov1
    mov   dl,mov2
    mov   bh,mov3
    mov   bl,mov4
    add   dh,inc1
    add   dl,inc2
    sub   bh,inc3
    add   bl,inc4
    mov   mov1,dh
    mov   mov2,dl
    mov   mov3,bh
    mov   mov4,bl

    mov   tmov3,bh
    mov   tmov4,bl

    mov   ax,seg tbl
    mov   ds,ax
    mov   si,offset tbl

    mov   cx,50
    mov   ax,$A000
    mov   es,ax
    xor   di,di
    mov   bx,0
    cld

    @jmp1 :
          mov   tmov1,dh
          mov   tmov2,dl
          push  cx
          mov   cx,80

    @jmp2 :
          mov   bl,tmov1
          mov   al,ds:[si+bx]
          mov   bl,tmov2
          add   al,ds:[si+bx]
          mov   bl,tmov3
          add   al,ds:[si+bx]
          mov   bl,tmov4
          add   al,ds:[si+bx]
          add   al,cl
          mov   es:[di],al
          inc   di
          mov   al,tmov1
          add   al,tinc1
          mov   tmov1,al
          mov   al,tmov2
          add   al,tinc2
          mov   tmov2,al

          dec   cx
          jnz  @jmp2

          mov   al,tmov3
          add   al,tinc3
          mov   tmov3,al
          mov   al,tmov4
          add   al,tinc4
          mov   tmov4,al

          pop   cx

          dec   cx
          jnz   @jmp1

    pop   ds
    pop   es
    end;

Function rad (theta : real) : real; { Converts degrees to radians }
  BEGIN
    rad := theta * pi / 180
  END;

procedure DoPlasma;
  var i,j   : integer;

begin
  For i:=0 to 255 do tbl[i]:=round (sin (rad (i/360*255*2))*31)+32;
  InitUnChain;
  loadpal('compile.dat',23390);setpal;
  randomize;
  tinc1:=3;tinc2:=5;
  tinc3:=5;tinc4:=3;
  for i:=1 to 1500 do
      begin
        drawplasma;
        inc1:=1+random(9);inc2:=1+random(2);
        inc3:=1+random(2);inc4:=-1-random(9);
        waitretrace;
      end;
  fadeout(4);
  vga256;
end;

Begin
End.