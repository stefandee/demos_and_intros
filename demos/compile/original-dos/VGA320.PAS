{

       Unit for VGA 320x200x256 colors by Codres Daniel DanSoft(C)1992

Number version :         1.01

contents:
         - palette (contrast,fadding,inc registers etc...
         - sprites
         - popups
         - windows

}




unit
    vga320;

interface

uses    crt,dos,mouse,graph,col;



type
        componenta      = Record
                        r,g,b:byte
                        end;

        wstatus         = record
                          x,y,xl,yl:word;
                          xc,yc:byte;
                          end;
{
            tflx        = record
                          sign:array[1..3] of char;
                          NameFlx:string[8];
                          NoSpr:byte;
                          xi,yi:word;
                          SprNo:array[1..100] of byte;
                          SprTm:array[1..100] of byte;
                          reserved:word;
                          end;
}
        tspr            = record
                          x,y:word;
                          xl,yl:word;
                          hidden:boolean;
                          pspr:pointer
                          end;

        pp              = record
                        ofs,seg :word
                        end;
        bars              = array [1..10] of string[10];
        hots              = array[1..10] of byte;
        popup           = record
                          n_bars:byte;
                          x,y:byte;
                          bar:bars;
                          hot:hots;
                          end;


const

        SignLVM   = 'LVM92';
        Copyr     = 'Copyright DanSoft (C) 1992';

        NormalPut =  0    ;      {MOV}
        CopyPut   =  1    ;      {MOV}
        XORPut    =  3  ;      {XOR}
        OrPut     =  2  ;      {OR }
        AndPut    =  1  ;      {AND}
        NotPut    =  4    ;      {NOT}

        pscreen   = ptr($a000,$0000);

        rinc       = 0;
        rdec       = 1;

        shadow    = 32;

        ln        = #10 + #13;

        clstime:byte
                    = 2;

        up        = 1;
        down      = 2;
        right     = 3;
        left      = 4;

        bright     = 2;
        bleft      = 1;

        {Fileinfo Flags}

        fname      = 1;
        fdir       = 2;
        fext       = 3;
        fnameext   = 4;
        fdirname   = 5;


        {Color mask for Planes }

        all         = 255;
        low         = $04;
        high        = $f8;

        mcoor       = 10;

        winnrmax  = 15;

        xres      = 320;
        yres      = 200;

        mapspr    = 192;
        mapback   = 64;
        mapall    = 255;

        cselect   = 92;

        screen    = 0;

        cpopfore  = 111;

        kbF1       = 1;
        kbF2       = 2;
        kbF3       = 3;
        kbF4       = 4;
        kbF5       = 5;
        kbF6       = 6;
        kbF7       = 7;
        kbF8       = 8;
        kbF9       = 9;
        kbF10      = 10;
        kbUp       = 11;
        kbDown     = 12;
        kbLeft     = 13;
        kbRight    = 14;
        kbHome     = 15;
        kbEnd      = 16;
        kbEsc      = 17;
        kbEnt      = 18;
        kbSpace    = 19;



var

        m            : array [0..320,0..199] of byte absolute $a000:0;
        lvm          : array [0..64767] of byte absolute $a000-48:0;
        workpal      : palette absolute $a000-48:0;
        paux,celpal  : array [0..767] of byte;
        writemode    : byte;
        tab          : byte;

        regcul       : componenta;
        fs           : file;

        pal          : array[0..255] of componenta;

        scr          : pointer;

{        fflx         : file of tflx;}

        dirinfo      : searchrec;
        d            : dirstr;
        n            : namestr;
        e            : extstr;

        crntpop      : byte;

        spr          : array [1..50] of tspr;

        pwin         : array [1..winnrmax] of pointer;
        ws           : array [1..winnrmax] of wstatus;

        iors         : word;

        mo           : mousestatus;
        graphcx,graphcy: word;
        crtcx,crtcy  : word;
        but          : byte;
        kbev         : byte;
        crntwin      : byte;
        xw,yw,xlw,ylw: word;
        bord         : byte;
        wback        : byte;
        wfore        : byte;
        wbordb       : byte;
        wbordf       : byte;

        pop          : array [1..10] of popup;

           chseg,chofs:word;

        font         : array[0..2048] of byte;

procedure setpal;
procedure getpal;
procedure incr(var p:pointer;l:longint);
procedure loadlvm(nume:string);
procedure cluster(x,y,lx,ly,cul:word);
procedure selectplanes(plan:byte);
procedure printw(w:word;x,y:byte);
procedure print(sir:string;x,y:word;cul:byte);
procedure deactiwin;
procedure actiwin(nr:byte;x,y,wxl,wyl:word);
procedure movel(dela,la:word;tabs,len:word);
function getkey:byte;
procedure waitkey;
procedure wr(car:char;cul:byte;count:byte);
procedure setwritemode(md:byte);
procedure loadfont(nume:string);
procedure setoverscan(cul:byte);
procedure roll(x,y:word);
procedure cursorxy(x,y:byte);
procedure readpal(numef:string);
procedure writepal(numef:string);
procedure clearpal;
function fexist(numef:string):boolean;
procedure putimage(x,y,xl,yl:word;var p:pointer;md:byte);
procedure getimage(x,y,xl,yl:word;var p:pointer);
function imagesize(x,y,xl,yl:word):word;
procedure movef(s,d:pointer;count:word);
procedure pfade(n:byte;var s:pointer);
procedure cls(cul:byte);
procedure box(x,y,lx,ly:word;cul:byte);
procedure rectangle(x,y,xl,yl:word;cul:byte);
procedure lver(x,y,len:word;cul:byte);
procedure lhor(x,y,len:word;cul:byte);
function getpixel(x,y:word):byte;
procedure putpixel(x,y:word;cul:byte);
procedure buton(x,y,lx,ly:word);
procedure ofsto0(var p:pointer);
procedure clw(cul:byte);


procedure ioerr;
procedure beep;
procedure memerr(l:longint);
procedure sayerr(s:string);

procedure co80;
procedure vga256;

function actpopup(nrp:byte):byte;
procedure defpopup(nrp,nrb:byte;xp,yp:word;barp:bars;hotb:hots);

function event(x,y,xl,yl:word):byte;
function kbevent:word;
procedure putstr(c:string;x,y:word;back,fore:byte);

procedure ploaie;
procedure ploaiew(x,y,xl,yl:word);
procedure movelhor(dela,la:word;tabs,len:word);

procedure contrast(start:byte;c:byte;cit:byte);
procedure set1reg(n:byte;r,g,b:byte);
procedure quikpal(first:byte;count:word);
procedure stpal(start:byte;count:word);
procedure clpal(start:byte;count:word);
procedure dinc1reg(n:byte;flag:byte);

procedure loadspr(nume:string;nr:byte);
procedure putspr(nr:byte;x1,y1:word;mode:byte);
procedure defspr(nr:byte;x1,y1:word);
procedure movespr(nr:byte;x1,y1:word);
procedure showspr(nr:byte);
procedure hidespr(nr:byte);
procedure donespr(nr:byte);

procedure step(n:word);
procedure map(s:byte);
procedure read1reg(n:byte);
procedure readreg(n:byte);
function fileinfo(s:string;flag:byte):string;
function upstr(x:string):string;
function dechex(x:word):string;
procedure init320;
procedure valuri(x,y,xl,yl,amp:word);
procedure scurge(x,y,xl,yl,amp:word);
{function DetectVGA256 : integer;}

implementation

label change;

procedure VGA256DriverProc; external;
{$L vga256.OBJ }


{$F+}
function DetectVGA256 : integer;
var
  DetectedDriver : integer;
  SuggestedMode  : integer;
begin
  DetectedDriver:=Mcga;
  if (DetectedDriver = VGA) or (DetectedDriver = MCGA) then
    DetectVGA256 := 0        { Default video mode = 0 }
  else
    DetectVGA256 := grError; { Couldn't detect hardware }
end; { DetectVGA256 }
{$F-}

procedure Abort(Msg : string);
begin
  Writeln(Msg, ': ', GraphErrorMsg(GraphResult));
  Halt(1);
end;


procedure init320;
var
  driver,mode   :integer;
  AutoDetectPointer:pointer;
  ErrorCode:integer;
begin
  DirectVideo := false;
  AutoDetectPointer := @DetectVGA256; { Point to detection routine }
  Driver := InstallUserDriver('VGA256', AutoDetectPointer);
  if RegisterBGIdriver(@vga256DriverProc) < 0 then
  Abort('VGA256');

  Driver := Detect;
  InitGraph(Driver, Mode, '');
  ErrorCode := GraphResult;
  if ErrorCode <> grOK then
  begin
    Writeln('Error: ', GraphErrorMsg(ErrorCode));
    Halt;
  end;
end;


procedure vga256;
begin
asm

   mov ax,$0013
   int $10

end
end;

procedure beep;
begin
sound(1000);
delay(30);
nosound;
end;

procedure co80;
begin
asm
   MOV  AX,$1200
   MOV  BX,$0031
   INT  $10

   MOV  AX,$0003
   INT  $10
end
end;

procedure sayerr(s:string);
begin
co80;
writeln(ln+'Internal ERROR :'+s+ln);
halt(2);
end;

procedure memerr(l:longint);
begin
if l>=maxavail-5 then sayerr('No more memory . Release TSR ...');
end;

function dechexb(x:byte):string;
const
  tabl:string[16]='0123456789ABCDEF';
var
  y:string[2];
begin
  y:=tabl[x div 16+1];
  y:=y+tabl[x mod 16+1];
  dechexb:=y;
end;

function dechex(x:word):string;
begin
  dechex:=dechexb(hi(x))+dechexb(lo(x));
end;



procedure ioerr;
begin
if iors<>0 then sayerr('I/O Failure');
end;

procedure map(s:byte);
begin
port[$3c9]:=s;
end;

procedure setwritemode(md:byte);
var
   aux:byte;

begin
case md of
     xorput:mem[chseg:chofs+1]:=$32;
     andput:mem[chseg:chofs+1]:=$22;
      orput:mem[chseg:chofs+1]:=$0a;
end;
{
asm
   mov dx,$3ce
   mov al,05
   out dx,al
   mov al,md
   inc dx
   out dx,al
end;
}
end;

function upstr(x:string):string;
var
  i:byte;
  y:string;
begin
  y:='';
  for i:=1 to length(x) do
    y:=y+upcase(x[i]);
  upstr:=y;
end;


procedure putstr(c:string;x,y:word;back,fore:byte);
var
   i,j:word;
begin
print(c,x,y,fore);
for i:=0 to (8*length(c)) do
    for j:=0 to 7 do
    begin
    if getpixel(x*8+i,y*8+j)=0 then putpixel(x*8+i,y*8+j,back);
    end;
end;



procedure ofsto0(var p:pointer);
var
   ss,oo,oo1:word;
begin
ss:=pp(p).seg;
oo:=pp(p).ofs;
oo1:=oo;
oo:=oo mod 16;
ss:=ss+oo1 div 16;
p:=ptr(ss,oo);
end;

procedure movef(s,d:pointer;count:word);
var
   sgms,sgmd,ofsets,ofsetd      : word;
begin
       sgms:=pp(s).seg;
       ofsets:=pp(s).ofs;
       sgmd:=pp(d).seg;
       ofsetd:=pp(d).ofs;

asm
   pushf
     push ds
     push es
     cld
     mov ax,sgms
     mov ds,ax
     mov si,ofsets

     mov ax,sgmd
     mov es,ax
     mov di,ofsetd
     mov cx,count
     rep movsb
     pop es
     pop ds
    popf

end;

end;

function event(x,y,xl,yl:word):byte;
var
   prt:byte;
   ch:char;
begin

mset(mo);
graphcx:=mo.xc;
graphcy:=mo.yc;
but:=mo.bt;
with pop[crntpop] do
begin
crtcx:=1+graphcx div 8-x;
crtcy:=1+graphcy div 8-y;
end;


           print('     ',mcoor,23,0);
           print('     ',mcoor+6,23,0);
           printw(crtcx,mcoor,23);
           printw(crtcy,mcoor+6,23);

end;


function kbevent:word;
var   ch:char;
begin
if keypressed then
 begin
   ch:=readkey;
   if ch=#00 then
    begin
     ch:=readkey;
      case ch of
          #59:kbevent:=kbF1;
          #60:kbevent:=kbF2;
          #61:kbevent:=kbF3;
          #62:kbevent:=kbF4;
          #63:kbevent:=kbF5;
          #64:kbevent:=kbF6;
          #65:kbevent:=kbF7;
          #66:kbevent:=kbF8;
          #67:kbevent:=kbF9;
          #68:kbevent:=kbF10;
          #01:kbevent:=kbEsc;
          #72:kbevent:=kbUp;
          #80:kbevent:=kbDown;
          #75:kbevent:=kbLeft;
          #77:kbevent:=kbRight;
          #71:kbevent:=kbHome;
          #79:kbevent:=kbEnd;

         end;
   end
   else case ch of
        #27:kbevent:=KbEsc;
        #13:kbevent:=KbEnt;
        #32:kbevent:=KbSpace;
        end;
 end;
end;


procedure selectplanes(plan:byte);
const c16:word=16;
begin
{portw[$3ce]:=$0005;}
port[$3c6]:=plan;
end;


procedure loadfont(nume:string);
var r:registers;
    font:array[0..774] of byte;
    f:file;
begin
assign(f,nume);
reset(f,1);
blockread(f,font,775);
close(f);

r.ax:=$1121;
r.es:=seg(font);
r.bp:=ofs(font)-31*8-1;
r.cx:=8;
r.bl:=$19;
intr($10,r);

end;

procedure movepixel(x,y:word);
begin
end;


procedure pfade(n:byte;var s:pointer);
var
sgm,ofset:word;
i,j:word;
mv:pointer;
begin

mv:=ptr($a000,$0000);
case n of
     0:begin
     movef(s,mv,64000);
      end;
     1:begin
         for i:=0 to 9 do
             for j:=0 to 19 do
             begin
             movelhor(i+j*10,i+j*10,0,320);
             end;
       end;
     2:begin
            for i:=0 to 99 do
            begin
            delay(3);
            movelhor(100-i,100-i,160-i,2*i);
            movelhor(100+i,100+i,160-i,2*i)

            end;
            for i:=0 to 99 do
            begin
            movelhor(100-i,100-i,0,320);
            movelhor(100+i,100+i,0,320)

            end;
        end;
      3:ploaie;
      4:for j:= 0 to 15 do ploaiew(j*20,0,20,200);
      5:for i:=0 to 9 do
            for j:=0 to 6399 do
                movepixel(random(320),random(200));

end;
end;




procedure putpixel(x,y:word;cul:byte);
begin
case writemode of
     normalput :m[x,y]:=cul;
     orput     :m[x,y]:=m[x,y] or cul;
     xorput    :m[x,y]:=m[x,y] xor cul;
     andput    :m[x,y]:=m[x,y] and cul;
     notput    :m[x,y]:=not m[x,y];
     end;
end;

function getpixel(x,y:word):byte;
begin
getpixel:=m[x,y]
end;


procedure lhor(x,y,len:word;cul:byte);
label l3;
var
        adr:word;
begin

adr:=x+320*y;

asm
        push ds
        mov ax,$a000
        mov es,ax
        mov cx,len
        mov di,adr
        mov al,cul
        cld
        rep stosb
        pop ds
end;

end;


procedure lver(x,y,len:word;cul:byte);
label l4;
var
        adr:word;
begin

adr:=x+320*y;

asm
        push ds
        mov ax,$a000
        mov ds,ax
        mov cx,len
        mov si,adr
        mov al,cul
l4:
        mov ds:[si],al
        add si,320
        loop l4
        pop ds
end;

end;


procedure rectangle(x,y,xl,yl:word;cul:byte);

begin
lhor(x,y,xl,cul);
lhor(x,y+yl,xl,cul);
lver(x,y+1,yl-1,cul);
lver(x+xl,y,yl+1,cul);
end;

procedure box(x,y,lx,ly:word;cul:byte);
var
   j:word;
begin
for j:=0 to ly do
     lhor(x,y+j,lx,cul);
{lhor(x,y+ly+1,lx,0);}
end;


procedure cls(cul:byte);
begin
asm
   push es
   mov ax,$a000
   mov es,ax
   mov cx,64000
   mov di,0
   mov al,cul
   cld
   rep stosb
   pop es
end;
end;

function imagesize(x,y,xl,yl:word):word;
begin
if (x<0) or (y<0) or (x+xl>320) or (y+yl>200) then imagesize:=0
         else
         imagesize:=xl*yl;
end;

procedure getimage(x,y,xl,yl:word;var p:pointer);
label l1;
var
   s,o:word;
   adr:word;

begin
ofsto0(p);
s:=pp(p).seg;
o:=pp(p).ofs;
adr:=x+320*y;

asm

   push ds
   push es
   mov ax,s
   mov es,ax
   mov ax,$a000
   mov ds,ax
   mov si,adr
   mov di,o
   mov cx,yl
l1:
   push si
   push cx
   mov cx,xl
   rep movsb
   pop cx
   pop si

   add si,320
   loop l1
   pop es
   pop ds
end;

end;{proc}



procedure putimage(x,y,xl,yl:word;var p:pointer;md:byte);
var
   s,o:word;
   adr:word;
begin
ofsto0(p);
s:=pp(p).seg;
o:=pp(p).ofs;
adr:=x+320*y;
case md of
normalput:
asm
   push ax
   push bx
   push cx
   push dx
   push si
   push di
   push bp
   push ds
   push es
   mov ax,$a000
   mov es,ax
   mov ax,s
   mov ds,ax
   mov si,o
   mov di,adr
   mov cx,yl
   cld

@5:
   push di
   push cx
   mov cx,xl
   rep movsb
   pop cx
   pop di
   add di,320
   loop @5

   pop es
   pop ds
   pop bp
   pop di
   pop si
   pop dx
   pop cx
   pop bx
   pop ax


end;
copyput:
asm
   push ax
   push bx
   push cx
   push dx
   push si
   push di
   push bp
   push ds
   push es
   mov ax,$a000
   mov es,ax
   mov ax,s
   mov ds,ax
   mov si,o
   mov di,adr
   mov cx,yl
   cld
@7:
   push di
   push cx
   mov cx,xl
@6:
   lodsb
   cmp al,0
   je @8
   mov es:[di],al
@8:
   inc di
   loop @6
   pop cx
   pop di

   add di,320
   loop @7
   pop es
   pop ds
   pop bp
   pop di
   pop si
   pop dx
   pop cx
   pop bx
   pop ax


end;
xorput:
asm
   push ax
   push bx
   push cx
   push dx
   push si
   push di
   push bp
   push ds
   push es
   mov ax,$a000
   mov es,ax
   mov ax,s
   mov ds,ax
   mov si,o
   mov di,adr
   mov cx,yl
   cld
@10:
   push di
   push cx
   mov cx,xl
@9:
   lodsb
   xor es:[di],al
{   mov es:[di],al}
   inc di
   loop @9
   pop cx
   pop di

   add di,320
   loop @10
   pop es
   pop ds
   pop bp
   pop di
   pop si
   pop dx
   pop cx
   pop bx
   pop ax


end;
andput:
asm
   push ax
   push bx
   push cx
   push dx
   push si
   push di
   push bp
   push ds
   push es
   mov ax,$a000
   mov es,ax
   mov ax,s
   mov ds,ax
   mov si,o
   mov di,adr
   mov cx,yl
   cld
@2:
   push di
   push cx
   mov cx,xl
@1:
   lodsb
   and es:[di],al
{   mov es:[di],al}
   inc di
   loop @1
   pop cx
   pop di

   add di,320
   loop @2
   pop es
   pop ds
   pop bp
   pop di
   pop si
   pop dx
   pop cx
   pop bx
   pop ax


end;
orput:
asm
   push ax
   push bx
   push cx
   push dx
   push si
   push di
   push bp
   push ds
   push es
   mov ax,$a000
   mov es,ax
   mov ax,s
   mov ds,ax
   mov si,o
   mov di,adr
   mov cx,yl
   cld
@4:
   push di
   push cx
   mov cx,xl
@3:
   lodsb
   or es:[di],al
{   mov es:[di],al}
   inc di
   loop @3
   pop cx
   pop di

   add di,320
   loop @4
   pop es
   pop ds
   pop bp
   pop di
   pop si
   pop dx
   pop cx
   pop bx
   pop ax


end;


end;{case}
end;{proc}


function fexist(numef:string):boolean;

begin
fexist:=false;
findfirst(numef,archive+hidden,dirinfo);
if doserror=0 then fexist:=true;
end;


procedure writepal(numef:string);

var f:file;
    result:word;
begin
   asm
     mov ax,seg workpal
     mov es,ax
     mov dx,offset workpal
     mov bx,0
     mov cx,256
     mov ax,$1017
     int $10
   end;
   assign(f,numef);
   {$I-}
   rewrite(f,1);

   {$I+}
   iors:=ioresult;
   ioerr;

   blockwrite(f,workpal,768,result);
   close(f);
end;


procedure readpal(numef:string);

var f:file;
    result:word;
begin

   assign(f,numef);
   {$I-}
   reset(f,1);
   {$I+}
   iors:=ioresult;
   ioerr;
   blockread(f,workpal,768,result);
   if result<>768 then sayerr('Palette packed file corrupt ...');
   close(f);
   move(workpal,pal,768);
end;

procedure movelhor(dela,la:word;tabs,len:word);
label l1;
var adrdela,adrla:word;
    sg,ooff:word;
begin
ofsto0(scr);
sg:=pp(scr).seg;
ooff:=pp(scr).ofs;

adrdela:=320*dela;
adrla:=320*la+tabs;
asm
   push ds
   push es
   mov cx,len
   mov ax,$a000
   mov es,ax
   mov ds,sg
   mov si,adrdela
   mov di,adrla
   cld
   rep movsb
   pop es
   pop ds
end;
end;

procedure movel(dela,la:word;tabs,len:word);
label l1;
var adrdela,adrla:word;
    sg,ooff:word;
begin
ofsto0(scr);
sg:=pp(scr).seg;
ooff:=pp(scr).ofs;

adrdela:=320*dela;
adrla:=320*la+tabs;
asm
   push ds
   push es
   mov cx,len
   mov ax,$a000
   mov es,ax
   mov ds,sg
   mov si,adrdela
   mov di,adrla
   cld
   rep movsb
   pop es
   pop ds
end;
end;


procedure roll(x,y:word);
var
   start:word;

begin
start:=y*320+x;
port[$3d4]:=$0c;
port[$3d5]:=hi(start);
port[$3d4]:=$0d;
port[$3d5]:=lo(start);
end;

procedure setoverscan(cul:byte);
begin
asm
   mov ax,$1001
   mov bh,cul
   int $10
end;
end;

procedure wr(car:char;cul:byte;count:byte);
var r:registers;
begin
     r.ah:=$0e;
     r.al:=ord(car);
     r.bl:=cul;
     intr($10,r);
end;


procedure WaitKey;
var
  Ch : char;
begin
  repeat until KeyPressed;
  Ch := ReadKey;
  if Ch = #0 then
    Ch := ReadKey;
end;

function getkey:byte;
var r:registers;
begin
r.al:=7;
msdos(r);
getkey:=r.al
end;

procedure cursorxy(x,y:byte);
var r:registers;
begin
if (x>40) and (y>24) then
   else
       begin
        r.ah:=02;
        r.bh:=0;
        r.dh:=y;
        r.dl:=x;
        intr($10,r)
       end;

end;

procedure print(sir:string;x,y:word;cul:byte);
var
   i    : word;
   r    : registers;
begin

cursorxy(x,y);

for i:=1 to length(sir) do
    wr(sir[i],cul,1);
end;


procedure printw(w:word;x,y:byte);
var
   saux:string;
begin
str(w,saux);
print('000',x,y,15);
print(saux,x+3-length(saux),y,15);
end;


procedure cluster(x,y,lx,ly,cul:word);
var      a:word;
begin
for a:=0 to ly do
     lhor(x,y+a,lx,cul+a);

end;

procedure buton(x,y,lx,ly:word);
begin

box(x+2,y+1,lx-3,ly-2,105);

lhor(x,y,lx,shadow);
lver(x,y,ly,shadow);
lver(x+1,y,ly-1,shadow);

lhor(x+1,y+ly-1,lx-1,0);
lver(x+lx-1,y+1,ly-2,0);

end;

procedure border(x,y,xl,yl:word;cul:byte);
var i:word;
begin
for i:=0 to bord-2 do
    rectangle(x+i,y+i,xl-2*i,yl-2*i,cul+i);
end;

procedure actiwin(nr:byte;x,y,wxl,wyl:word);

begin
if crntwin<winnrmax then
begin
if (x<bord) or (y<bord) or (wxl+x>xres-bord) or (wyl+y>yres-bord) then
             begin
              xw:=80;
              yw:=50;
              xlw:=160;
              ylw:=100;
             end
           else
             begin
              xw:=x;
              yw:=y;
              xlw:=wxl;
              ylw:=wyl;
             end;
crntwin:=nr;
inc(crntwin);
memerr((xlw+2*bord)*(ylw+2*bord));
getmem(pwin[nr],(xlw+2*bord)*(ylw+2*bord));
getimage(xw-bord,yw-bord,xlw+2*bord,ylw+2*bord,pwin[nr]);
{ make win back}
if wbordb<>1 then box(xw-bord,yw-bord,xlw+2*bord,ylw+2*bord-1,wbordb);
if wback<>1 then box(xw,yw,xlw,ylw-1,wback);
buton(xw,yw-bord+1,xlw,bord-2);
buton(xw-bord+1,yw,bord-2,ylw);
buton(xw,yw+1+ylw,xlw,bord-2);
buton(xw+1+xlw,yw,bord-2,ylw);
buton(xw-bord+1,yw-bord+1,bord-2,bord-2);
buton(xw+xlw+1,yw-bord+1,bord-2,bord-2);
buton(xw+xlw+1,yw+ylw+1,bord-2,bord-2);
buton(xw-bord+1,yw+ylw+1,bord-2,bord-2);

with ws[crntwin] do
begin
x:=xw;
y:=yw;
xl:=xlw;
yl:=ylw;
xc:=0;
yc:=0;
end;


end;
end;


procedure deactiwin;

begin
if crntwin<>0 then
             begin
             with ws[crntwin] do
             begin
             dec(crntwin);
             putimage(x-bord,y-bord,xl+2*bord,yl+2*bord,pwin[crntwin],normalput);
             freemem(pwin[crntwin],(xl+2*bord)*(yl+2*bord));
             end;
             end
end;


procedure setpal;
label vp1;
VAR
   seg_w,ofs_w:word;
   r:registers;

begin
                               r.ax:=$1012;
                               r.es:=seg(workpal);
                               r.dx:=ofs(workpal);
                               r.bx:=0;
                               r.cx:=256;
                               intr($10,r);
                               move(workpal,pal,768);
end;

procedure getpal;
var
   r:registers;
begin
   r.ax:=$1017;
   r.es:=seg(workpal);
   r.dx:=ofs(workpal);
   r.bx:=0;
   r.cx:=256;
   intr($10,r);
end;

procedure incr(var p:pointer;l:longint);
var sseg,oofs:word;

begin

sseg:=pp(p).seg;
oofs:=pp(p).ofs;
inc(sseg,oofs div 16);
oofs:=oofs and $0f;
inc(oofs,word(l and $0f));
inc(sseg,l div 16);
p:=ptr(sseg,oofs);
end;


procedure loadlvm(nume:string);
var poz:word;
    f:file;
    NumRead, NumWritten: Word;
    buf: array[1..3200] of byte;
    ps,pd               :pointer;

begin
memerr(64000);
getmem(scr,64000);
ps:=ptr(seg(buf),ofs(buf));
pd:=ptr($a000-48,0);
ofsto0(ps);
ofsto0(pd);
if not fexist(nume) then sayerr(' File '+nume+' not found...');
assign(f,nume);
reset(f,1);
    BlockRead(F,buf,768,NumRead);
    movef(ps,pd,768);
setpal;
move(workpal,paux,768);
pd:=scr;
ofsto0(pd);
  repeat
     BlockRead(F,buf,SizeOf(buf),NumRead);
     movef(ps,pd,numread);
     incr(pd,numread);
   until (NumRead = 0);
  Close(F);
end;

procedure defpopup(nrp,nrb:byte;xp,yp:word;barp:bars;hotb:hots);
var i:byte;
begin
with pop[nrp] do
     begin
     x:=xp;
     y:=yp;
     n_bars:=nrb;
     for i:=1 to nrb do
         bar[i]:=barp[i];
     for i:=1 to nrb do
         hot[i]:=hotb[i];
end;
end;


function actpopup(nrp:byte):byte;
var i:byte;
    crntbar:byte;
    gatap:boolean;
begin
delay(100);
gatap:=false;
crntpop:=nrp;
with pop[nrp] do
begin

actiwin(nrp,x*8,y*8,9*8,n_bars*8);
mrange(x*16-bord*2+bord,y*8-bord div 2,x*16+144+2*bord-bord,y*8+n_bars*8+bord div 2);
for i:=1 to n_bars do
    print(bar[i],x,y+i-1,cpopfore);
end;
showm;
crntbar:=0;
with pop[nrp] do

repeat
if (mmove<>mnomove) and (crtcy>0) and (crtcy<=n_bars) then
   begin
   crntbar:=crtcy;
   hidem;
   putstr(bar[crntbar],x,y+crntbar-1,111,wfore);
{   buton(x*8+9*8+1,y*8,bord-2,n_bars*8);}
   delay(10);
   putstr(bar[crntbar],x,y+crntbar-1,wfore,111);
{   buton(x*8+9*8+1,y*8+8*(crtcy-1),5,7);}
   showm;
   end;



with pop[nrp] do
kbev:=event(x*4*8,y*8,9*8,n_bars*8);
if but=bleft then begin beep; gatap:=true;actpopup:=crntbar end;
until gatap;
hidem;
crntpop:=0;
end;

procedure ploaie;
var linie,job:byte;
begin
for linie:=199 downto 0 do
for job:=0 to linie do
   movelhor(linie,job,0,320);
end;

procedure ploaiew(x,y,xl,yl:word);
var linie,job:byte;
begin
for linie:=y+yl downto y do
for job:=y to linie do
   movelhor(linie,job,x,xl);
end;

procedure clw(cul:byte);
begin
with ws[crntwin] do
      box(x,y,xl,yl,cul);
end;


procedure decreg(reg:word);
begin
asm
   mov ax,1015h
   mov bx,reg
   int 10h
   dec ch
   dec dh
   dec dl
   mov ax,1010h
   mov bx,reg
   int 10h

end;
end;

procedure contrast(start:byte;c:byte;cit:byte);
var i1,j:word;
begin
move(workpal,paux,768);
for i1:=start to start+c do
for j:=1 to  cit do
    dinc1reg(i1,1);
end;

procedure set1reg(n:byte;r,g,b:byte);assembler;
asm
   mov dx,3c6h
   mov al,0ffh
   out dx,al

   mov dx,3c8h
   mov al,n
   out dx,al

   inc dx
   mov al,r
   out dx,al

   mov al,g
   out dx,al

   mov al,b
   out dx,al
end;

procedure read1reg(n:byte);
begin
asm
   mov dx,3c8h
   mov al,n
   out dx,al

   inc dx

   in al,dx
   mov cl,al

   in al,dx
   mov ch,al

   in al,dx
   mov bl,al

   mov ax,seg regcul
   mov es,ax
   mov si,offset regcul
   mov es:[si],cx
   inc si
   inc si
   mov es:[si],bl
end;
end;

procedure readreg(n:byte);
begin
regcul:=pal[n];
end;


procedure dinc1reg(n:byte;flag:byte);assembler;
asm
   mov dx,3c6h
   mov al,0ffh
   out dx,al

   mov dx,3c8h
   mov al,n
   out dx,al

   inc dx

   in al,dx
   mov cl,al
   in al,dx
   mov ch,al
   in al,dx
   mov bl,al
   mov al,flag
   cmp al,0
   jz @@2
   dec cl
   dec ch
   dec bl
   jmp @@4

@@2:
   inc cl
   inc ch
   inc bl

@@4:
   dec dx

   mov al,n
   out dx,al

   inc dx

   mov al,cl
   out dx,al
   mov al,ch
   out dx,al
   mov al,bl
   out dx,al

end;

procedure quikpal(first:byte;count:word);
var
   spal,opal:word;
   trei:word;
begin
opal:=ofs(workpal)+3*first;

asm
 push ds
  mov ax,seg workpal
  mov ds,ax
  mov si,opal
  mov cx,count
  mov bl,first
  cld

  mov dx,3c8h

@@1:

  mov al,bl
  out dx,al

  inc dx

  lodsb
  out dx,al

  lodsb
  out dx,al

  lodsb
  out dx,al

  inc bl
  dec dx

  loop @@1
  pop ds

end;

end;


procedure clpal(start:byte;count:word);
var ii,i:word;
    gata:boolean;

begin
move(workpal,paux,count*3);
repeat
gata:=true;
for i:=start*3 to (start+count)*3 do
begin
if workpal[i]<>0 then
                     begin
                     dec(workpal[i],1);
                     gata:=false;
                     end;
end;
delay(clstime);
quikpal(0,256);
until gata;

end;

procedure stpal(start:byte;count:word);
var ii,i:word;
    gata:boolean;

begin
repeat
gata:=true;
for i:=start*3 to (start+count)*3 do
begin
if workpal[i]<paux[i] then
                     begin
                     inc(workpal[i]);

                     gata:=false;
                     end;
end;
delay(clstime);
quikpal(0,64);
until gata;
end;

procedure loadspr(nume:string;nr:byte);
var
    sign  :string[4];
    xxl,yyl:word;
    xxxx         :word;
    res,cell:word;

begin
if not fexist(nume) then sayerr(' File '+nume+' missing .')
else
begin
    assign(fs,nume);
    reset(fs,1);
    blockread(fs,cell,2,res);
    if cell=$9119 then
        with spr[nr] do
        begin
         seek(fs,2);
         blockread(fs,xxl,2,res);
         blockread(fs,yyl,2,res);
         seek(fs,32);
         blockread(fs,workpal,768,res);
         getmem(pspr,xxl*yyl);
         blockread(fs,pspr^,xxl*yyl);
         xl:=xxl;
         yl:=yyl;
         x:=0;
         y:=0;
         hidden:=true;
        end
    else
    begin
    reset(fs,1);
    blockread(fs,sign,10,res);
    if pos('S:',sign)=0 then
    Sayerr(' Ooops ! This is not a Sprite structure !')
    else
     begin
        with spr[nr] do
        begin
         blockread(fs,xxl,2,res);
         blockread(fs,yyl,2,res);
         getmem(pspr,xxl*yyl);
         blockread(fs,pspr^,xxl*yyl);
         xl:=xxl;
         yl:=yyl;
         x:=0;
         y:=0;
         hidden:=true;
        end
     end
    end
end;
close(fs);

end;

procedure showspr(nr:byte);
begin
with spr[nr] do
begin
if hidden then putimage(x,y,xl,yl,pspr,xorput);
hidden:=false
end;
end;

procedure hidespr(nr:byte);
begin
with spr[nr] do
begin
if not hidden then putimage(x,y,xl,yl,pspr,xorput);
hidden:=true
end;
end;


procedure donespr(nr:byte);
begin
with spr[nr] do
 begin
  freemem(pspr,xl*yl);
{  if not hidden then hidespr(nr);}
  xl:=0;
  yl:=0;
  x:=0;
  y:=0;

 end;
end;


procedure putspr(nr:byte;x1,y1:word;mode:byte);
begin
with spr[nr] do
putimage(x1,y1,xl,yl,pspr,mode);
end;



procedure defspr(nr:byte;x1,y1:word);
begin
with spr[nr] do
begin
putimage(x1,y1,xl,yl,pspr,normalput);
hidden:=false;
x:=x1;
y:=y1
end;
end;

procedure movespr(nr:byte;x1,y1:word);
begin
with spr[nr] do
begin
putimage(x,y,xl,yl,pspr,xorput);
putimage(x1,y1,xl,yl,pspr,xorput);
x:=x1;
y:=y1;
end;
end;

procedure step(n:word);
var i:word;
begin
sound(10000-n*100);
delay(5);
nosound;
delay(n);
end;

function fileinfo(s:string;flag:byte):string;
var dd:dirstr;
    nn:namestr;
    ee:extstr;
begin
fsplit(s,dd,nn,ee);
fileinfo:='';
case flag of
     fname:fileinfo:=nn;
     fdir:fileinfo:=dd;
     fext:fileinfo:=ee;
     fnameext:fileinfo:=nn+ee;
     fdirname:fileinfo:=dd+nn;
     end;
end;

procedure clearpal;
begin
move(workpal,paux,768);
fillchar(workpal,768,0);
quikpal(0,256);
end;


{
procedure loadfli(s:string);
begin
if not fexist(s) then sayerr(' File '+nume+' missing .');

assign(fflx,s);
reset(fflx);
close
end;
}

procedure valuri(x,y,xl,yl,amp:word);
var
   c1,c2:real;
   i,j,k:integer;
begin
c1:=3.14/20;
c2:=3.14/20;
tab:=1;
for j:=0 to amp do
begin
for i:=0 to yl-1 do
     movel(y+i,y+i,x+round(tab*sin(c1*tab+c2*i)),xl);
inc(tab);
end;

for j:= amp downto 0 do
for i:=yl-1 to 0 do
     movel(y+i,y+i,x+round(tab*sin(c1*j+c2*i)),xl);
end;

procedure scurge(x,y,xl,yl,amp:word);
var
   i,j:integer;
begin
for j:=0 to amp-1 do
begin
delay(clstime);
for i:=0 to yl-1 do
    movel(y+i,y+i,x+i*j div 10,xl-i*j div 10)
end;

for j:=amp-1 downto 0 do
begin
delay(clstime);
for i:=0 to yl-1 do
    movel(y+i,y+i,x+i*j div 10,xl-i*j div 10)
end;

end;

begin
bord:=8;
crntwin:=screen;
workpal:=gray;
wback:=0;
wfore:=15;
wbordb:=5;
wbordf:=6;
clstime:=10;
end.
