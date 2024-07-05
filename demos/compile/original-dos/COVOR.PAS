program covor;

uses graphics,crt;

const barsize = 20;

var i,j   : byte;
    aline : array[1..320] of byte;
    cline : array[1..320] of byte;
    aux   : integer;

begin

vga256;
initvscreen;
loadpal('sea.pal');setpal;
loadspr('sea.spr',1);putspr(1,0,0,normalput,vaddr);

for i:=0 to 199 do
    begin
      asm
       mov bl,i
       xor bh,bh
       push es
       push ds

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
       pop ds
       pop es
    end;

    for j:=1 to barsize do
        asm
           push es
           push ds

           mov dl,j
           xor dh,dh

           mov ax,vaddr
           mov ds,ax
           mov ax,bx
           add al,dl
           add al,barsize
           cmp ax,200
           jae @done

           mov cx,320
           push dx
           mul cx
           mov si,ax
           pop dx

           mov ax,seg cline
           mov es,ax
           mov di,offset cline
           mov cx,160
           cld
           rep movsw

           mov ax,vga
           mov es,ax
           mov ax,bx
           sub al,dl
           add al,barsize
           mov cx,320
           mul cx
           mov di,ax

           mov ax,seg cline
           mov ds,ax
           mov si,offset cline

           mov cx,160
           cld
           rep movsw
           @done:

           pop ds
           pop es
           end;
        asm
           mov ax,vga
           mov es,ax
           mov ax,bx
           mov cx,320
           mul cx
           mov di,ax

           mov ax,seg aline
           mov ds,ax
           mov si,offset aline

           call waitretrace;
           mov cx,160
           cld
           rep movsw

        end;
        delay(10);
     end;

{putspr(1,0,0,normalput,vga);}
readln;
end.