{
procedure movel(dela,la:word;tabs,len:word);
label l1;
var adrdela,adrla:word;
    sg,ooff:word;
begin

sg:=vaddr;
ooff:=0;

adrdela:=320*dela;
adrla:=320*la+tabs;

asm
   push ds
   push es
   mov cx,len
   shr cx,1
   mov ax,$a000
   mov es,ax
   mov ds,sg
   mov si,adrdela
   mov di,adrla
   cld
   rep movsw
   pop es
   pop ds
end;
end;

procedure valuri(x,y,xl,yl,amp:integer;offset : integer);
var
   c1,c2:real;
   i,j,k:integer;
   tab : shortint;
begin
c1:=3.14/20;
c2:=3.14/20;
if amp>0
   then begin
        for j:=0 to amp do for i:=0 to yl-1 do movel(y+i,y+i,x+round(j*sin(c1*offset+c2*i)),xl);
        for j:= amp downto 0 do for i:=yl-1 downto 0 do movel(y+i,y+i,x+round(j*sin(c1*offset+c2*i)),xl);
        end
   else begin
        for j:= amp to 0 do for i:=yl-1 downto 0 do movel(y+i,y+i,x+round(j*sin(c1*offset+c2*i)),xl);
        for j:=0 downto amp do for i:=0 to yl-1 do movel(y+i,y+i,x+round(j*sin(c1*offset+c2*i)),xl);
        end
end;
}
