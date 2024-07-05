program vgaregs_test;

uses graphics,crt;

var f : file;

procedure waithoriz;assembler;
asm
        MOV     DX,3DAh
@@vs1:
        IN      AL,DX
        TEST    AL,8
        JZ     @@vs1
END;


begin

vga256;
assign(f,'chess.cel');reset(f,1);seek(f,32);
blockread(f,workpal,768);setpal;
spr[1].xl:=320;
spr[1].yl:=200;
getmem(spr[1].pspr,64000);
blockread(f,spr[1].pspr^,64000);
close(f);
putspr(1,0,0,normalput,vga);

repeat

{waithoriz;}
setvisiblestart(80*random(3));

until keypressed;

end.


