program test_chain4;

uses Images,Graphics,Crt;

const Size : Byte = 80;

type scr  = array[1..200,1..320] of byte;

var i,j : integer;
    f   : file;
    s   : ^scr;
    xpos,ypos,xdir,ydir : integer;

Procedure InitChain4; ASSEMBLER;
  {  This procedure gets you into Chain 4 mode }
Asm
    mov    ax, 13h
    int    10h         { Get into MCGA Mode }

    mov    dx, 3c4h    { Port 3c4h = Sequencer Address Register }
    mov    al, 4       { Index 4 = memory mode }
    out    dx, al
    inc    dx          { Port 3c5h ... here we set the mem mode }
    in     al, dx
    and    al, not 08h
    or     al, 04h
    out    dx, al
    mov    dx, 3ceh
    mov    al, 5
    out    dx, al
    inc    dx
    in     al, dx
    and    al, not 10h
    out    dx, al
    dec    dx
    mov    al, 6
    out    dx, al
    inc    dx
    in     al, dx
    and    al, not 02h
    out    dx, al
    mov    dx, 3c4h
    mov    ax, (0fh shl 8) + 2
    out    dx, ax
    mov    ax, 0a000h
    mov    es, ax
    sub    di, di
    mov    ax, 0000h {8080h}
    mov    cx, 32768
    cld
    rep    stosw            { Clear garbage off the screen ... }

    mov    dx, 3d4h
    mov    al, 14h
    out    dx, al
    inc    dx
    in     al, dx
    and    al, not 40h
    out    dx, al
    dec    dx
    mov    al, 17h
    out    dx, al
    inc    dx
    in     al, dx
    or     al, 40h
    out    dx, al

    mov    dx, 3d4h
    mov    al, 13h
    out    dx, al
    inc    dx
    mov    al, [Size]      { Size * 8 = Pixels across. Only 320 are visible}
    out    dx, al
End;


{컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴}
Procedure C4PutPixel(X,Y : Word; Col : Byte); ASSEMBLER;
  { This puts a pixel on the chain 4 screen }
Asm
    mov    ax,[y]
    xor    bx,bx
    mov    bl,[size]
    imul   bx
    shl    ax,1
    mov    bx,ax
    mov    ax, [X]
    mov    cx, ax
    shr    ax, 2
    add    bx, ax
    and    cx, 00000011b
    mov    ah, 1
    shl    ah, cl
    mov    dx, 3c4h                  { Sequencer Register    }
    mov    al, 2                     { Map Mask Index        }
    out    dx, ax

    mov    ax, 0a000h
    mov    es, ax
    mov    al, [col]
    mov    es: [bx], al
End;

{컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴}
Procedure Plane(Which : Byte); ASSEMBLER;
  { This sets the plane to write to in Chain 4}
Asm
   mov     al, 2h
   mov     ah, 1
   mov     cl, [Which]
   shl     ah, cl
   mov     dx, 3c4h                  { Sequencer Register    }
   out     dx, ax
End;


{컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴}
procedure moveto(x, y : word);
  { This moves to position x*4,y on a chain 4 screen }
var o : word;
begin
  o := y*size*2+x;
  asm
    mov    bx, [o]
    mov    ah, bh
    mov    al, 0ch

    mov    dx, 3d4h
    out    dx, ax

    mov    ah, bl
    mov    al, 0dh
    mov    dx, 3d4h
    out    dx, ax
  end;
end;

procedure putimage(x,y : integer);
begin
for i:=1 to 200 do
    for j:=1 to 320 do
        begin
        c4putpixel(x+j,y+i,s^[i,j]);
        end;
end;

begin
initchain4;
new(s);
loadpal('blue.pal');setpal;
assign(f,'canvas3.spr');reset(f,1);seek(f,4);blockread(f,s^,64000);putimage(0,0);close(f);
assign(f,'canvas4.spr');reset(f,1);seek(f,4);blockread(f,s^,64000);putimage(320,0);close(f);
assign(f,'canvas3.spr');reset(f,1);seek(f,4);blockread(f,s^,64000);putimage(0,200);close(f);
assign(f,'canvas4.spr');reset(f,1);seek(f,4);blockread(f,s^,64000);putimage(320,200);close(f);
randomize;
xpos:=random(100);ypos:=random(78);xdir:=1;ydir:=1;
repeat
moveto(xpos,ypos);
inc(xpos,xdir);inc(ypos,ydir);
if (xpos>79) or (xpos<1) then xdir:=-xdir;
if (ypos>199) or (ypos<1) then ydir:=-ydir;  { Hit a boundry, change}
waitretrace;
until keypressed;
donevga256;
dispose(s);
end.