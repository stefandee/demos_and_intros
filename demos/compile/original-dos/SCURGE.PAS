uses graphics,crt;

var lin,c : byte;
    cnt       : byte;
    aline : array[1..320] of byte;

begin

vga256;
initvscreen;
loadpal('chess.pal');setpal;
loadspr('chess.spr',1);putspr(1,0,0,normalput,vaddr);flip;


lin:=199;

repeat

putspr(1,0,0,normalput,vaddr);

asm
   mov bl,lin
   xor bh,bh
   push es
   push ds

end;

asm
   mov ax,vaddr
   mov ds,ax
   mov ax,bx
   mov cx,320
   mul cx
   mov si,ax

   mov ax,seg aline
   mov es,ax
   mov di,offset aline
   mov cx,160
   cld
   rep movsw
end;

asm
   pop ds
   pop es
end;

cnt:=lin;

asm
   push es
   push ds
end;

repeat
    asm
       mov ax,vaddr
       mov es,ax
       xor ah,ah
       mov al,cnt
       mov cx,320
       mul cx
       mov di,ax

       mov ax,seg aline
       mov ds,ax
       mov si,offset aline

       mov cx,160
       cld
       rep movsw
    end;
inc(cnt);
until cnt=200;
asm
   pop ds
   pop es
end;
{for i:=0 to 319 do line(i,lin,i,0,getpixel(i,lin,vaddr),vaddr);}
flip;
lin:=lin-1;
until lin<=1;

readln;
donevga256;
donevscreen;
end.