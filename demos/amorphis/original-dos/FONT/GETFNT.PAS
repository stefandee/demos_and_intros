program get_sprites;

uses graph,crt,pcxr;
const xl=12;
      yl=12;
type buf=array[1..xl,1..yl] of byte;
     pbuf=^buf;
var  i,j,drv,drvm,x,y,size:integer;
     ch:char;
     f:file;
     p:pbuf;
     b:byte;
     adrx,adry,nr:word;
     xxl,yyl:word;
     strfile:string;
     v : byte absolute $a000:0;
     workpal : array[0..767] of byte;
     crtchar : char;

procedure LoadPal(numef : string;readpos : longint);

var
    result:word;
    fs:file;
begin

   assign(fs,numef);
   reset(fs,1);
   seek(fs,readpos);
   blockread(fs,workpal,768,result);
   close(fs);
end;

procedure WaitRetrace;assembler;
label l1,l2;
asm
    mov dx,3DAh
l1:
    in al,dx
    and al,08h
    jnz l1
l2:
    in al,dx
    and al,08h
    jz  l2
end;


procedure Setpal;assembler;
asm

   push ds
   mov ax,seg workpal
   mov ds,ax
   mov si,offset workpal
   call WaitRetrace

   mov dx,3c8h
   mov al,0
   out dx,al
   inc dx
   mov cx,384
   rep outsb
   call WaitRetrace
   mov dx,3c8h
   mov al,128
   out dx,al
   inc dx
   mov cx,384
   rep outsb

   pop ds
end;


Begin

drv:=installuserdriver('vga256',nil);
initgraph(drv,drvm,'');
{loadpal('setup.pal',0);setpal;
assign(f,'setup.spr');reset(f,1);seek(f,4);blockread(f,v,64000);close(f);}
readpcx('font.pcx');
assign(f,'amorphis.fnt');
rewrite(f,1);
new(p);
x:=100;
y:=100;
nr:=0;
setwritemode(xorput);
setcolor(255);
rectangle(x,y,x+xl,y+yl);
crtchar := ' ';
outtextxy(300,0,crtchar);
repeat
if keypressed then ch:=readkey
              else ch:=#0;
case ch of
#75 : begin
      rectangle(x,y,x+xl,y+yl);
      dec(x);
      rectangle(x,y,x+xl,y+yl);
      end;
#77 : begin
      rectangle(x,y,x+xl,y+yl);
      inc(x);
      rectangle(x,y,x+xl,y+yl);
      end;
#72 : begin
      rectangle(x,y,x+xl,y+yl);
      dec(y);
      rectangle(x,y,x+xl,y+yl);
      end;
#80 : begin
      rectangle(x,y,x+xl,y+yl);
      inc(y);
      rectangle(x,y,x+xl,y+yl);
      end;
#32 : begin
      setcolor(0);
      outtextxy(300,0,crtchar);
      inc(byte(crtchar));
      setcolor(255);
      outtextxy(300,0,crtchar);
      for i:=y+1 to y+yl-1 do
          for j:=x+1 to x+xl-1 do
              begin
              b:=getpixel(j,i);
              blockwrite(f,b,1);
              end;
      end;
end;
until ch=#27;
close(f);
end.





