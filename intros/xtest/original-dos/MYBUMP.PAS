Program twodbump;
{Brought to you by HELiX}
uses crt
    ,fpack; {This is a unit from the Asphyxia Trainers to
    load pcx images}

{Tha 2d bumper.. based on a French tutorial found somewhere in the net..}
{The purpose of this document is to help u understand the basic idea}
{It is not optimized but who cares anyway? :) }

TYPE Virtual = Array [1..64000] of byte;  { The size of our Virtual Screen }
     VirtPtr = ^Virtual;                  { Pointer to the virtual screen }

var    {Now I shall explain the variables used}

 x,y,            {These two are used in the main loop}
 vlx,vly,        {The Light Vector (Origin 0,0)}
 lx,ly,          {This is a point representing the position of the light source}
 Nx,ny:integer;  {This will be used to store the Pseudo-normal}
 l1:word;        {This is for general use}
 Virscr,virscr2 : VirtPtr;                     { Our first Virtual screen }
 Vaddr,vaddr2  : word;                        { The segment of our virtual screen}


Procedure Cls32 (Where:word;Col : Byte); assembler;
   { This clears the screen to the specified color }
asm
   push    es
   mov     cx, 16000;
   mov     es,[where]
   xor     di,di
   mov     al,[col]
   mov     ah,al
   mov     dx, ax
   db      $66, $C1, $E0, $10         {shl eax, 16}
   mov     ax, dx
   db      $F3, $66, $AB              {rep stosd}
   pop     es
End;

procedure flip32(source,dest:Word); assembler;
  { This copies the entire screen at "source" to destination }
asm
  push    ds
  mov     ax, [Dest]
  mov     es, ax
  mov     ax, [Source]
  mov     ds, ax
  xor     si, si
  xor     di, di
  mov     cx, 16000
  db      $F3, $66, $A5
  pop     ds
end;

Procedure Pal(Col,R,G,B : Byte); assembler;
  { This sets the Red, Green and Blue values of a certain color }
asm
   mov    dx,3c8h
   mov    al,[col]
   out    dx,al
   inc    dx
   mov    al,[r]
   out    dx,al
   mov    al,[g]
   out    dx,al
   mov    al,[b]
   out    dx,al
end;


Procedure SetUpVirtual;
   { This sets up the memory needed for the virtual screen }
BEGIN
  GetMem (VirScr,64000);
  vaddr := seg (virscr^);   {The segment for page 1}
  GetMem (VirScr2,64000);
  vaddr2 := seg (virscr2^); {The segment for page 2}
END; {Setupvirtual}

Procedure ShutDown;
   { This frees the memory used by the virtual screen }
BEGIN
  FreeMem (VirScr,64000);
  FreeMem (VirScr2,64000);
END;  {Shutdown}




procedure setuppal;
{We are using a linear pallete..this procedure creates the one we use}
{It looks better if you build one with the phong illumination model
but this is not a tutorial on how to setup palletes :)}
var l1:integer; {General purpose}
begin
  for l1:=0 to 255 do pal(l1,0,0,0); {this makes everything black}
  {We start from 128 and go all the way to 255..we dont light all
  256 colours cause it wont look much like a spotlight.. you can
  try it though}

  for l1:=128 to 255 do pal(l1,l1 div 2 ,0,l1 div 2);
                        {Choose the colours you prefer.. never should
                        you go more than 63 (128 div 2) though..}

end; {Setuppal}

procedure Lpcx(fn:string;where:word);
var bo:boolean;

begin
  total:=1;
  infodat[1]:=fn;
  bo:=loadpcx(1,where,true);
end;



procedure dobump; {Now u guess what this one does..hehehe}
var difx,   {The X axis difference}
    dify,   {The Y axis difference}
    col:byte; {Used in many points..}
    l1:integer; {General use}
begin
  lx:=160; {The starting position of the light source}
  ly:=100; {>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>}
  l1:=0;
  repeat
    inc(l1);
    lx:=round(cos(l1/13)*66+160);
    ly:=round(sin(l1/23)*66+100);
    {^^^^ those two make sure the light moves in a nice round path..}
    for x:=1 to 319 do
      for y:=1 to 190 do begin
      {This were the important stuff is done}
      {Here we will light the point x,y if lx,ly is the light position}

        vlx:=x-lx; {Calculate the L vector}
        vly:=y-ly; {>>>>>>>>>>>>>>>>>>>>>>}

        if (vlx<130) and (vlx>-130) and (vly>-130) and (vly<130 ) then begin
        {This is some stupid way to gain speed.. if the light vector is too
        far away from the point we want to light then don't bother..it
        will probably get no light..}
          nx:=mem[vaddr:x+y*320+1]-mem[vaddr:x+y*320-1];
          ny:=mem[vaddr:x+(y+1)*320]-mem[vaddr:x+(y-1)*320];
{Those two lines are the heart of bumping}
{We have a pixel, say x,y and we want to find how its normal vector
is facing.. (that is its slope...) normaly we would have to mess with
cos and sin and other shitty stuff but here we only care about something
like a pseudo-normal.. in other words we only care about the Sign.. that
is there are three possible pseudo normals:
1) nx<0 (Normal facing right)
   nx>0 (Normal facing left)
   nx=0 (Normal sticking out of the screen)
and its the same story with ny.. (it can be facing up,down or sticking out..}
{To find this orientation we get 2 pixels.. the one left and the one right (or
the one up and the one down for ny) and we sub.. the result is the N vector
for our point 10,10}

{The rest is easy.. we have two vectors now.. N,L.. we want their coordinates
to be as close as possible (the closer they are the more light gets the pixel}

          col:=abs(vlx-nx);
          {that is what I just said written in mathematics hehehe}
          if col>127 then col:=127;
          {Just not to overflow}
          difx:=127-col;
          {^^^^ that is the first component of the final color.. the
          light we get from the X axis}
          if difx<0 then difx:=1;

          {Now we do the same stuff for the Y axis }
          col:=abs(vly-ny);
         if col>127 then col:=127;
         dify:=127-col;
        if dify<0 then dify:=1;
        {finaly we add the two intensities and we're done..}
        col:=(difx+dify) ;
        if col>128 then
          mem[vaddr2:x+y*320]:=col;
          {That's it.. put the damn pixel}
       {putpixel(x,y,col,vaddr2);}
     end;
    end;
   flip32(vaddr2,sega000);
   cls32(vaddr2,0);
  until keypressed;
end;

begin
  writeln('The HELiX 2D Bump Tut');
  writeln;
  writeln('Based on some nice tutorial in French');
  writeln('Quite slow.. why dont u optimize it..? :)..');
  writeln;
  writeln('Orpheas/HELiX');
  writeln('Dec/96');
  readln;
  asm
    mov ax,13h
    int 10h
  end;
{  setmcga;}
  setupvirtual;
  cls32(vaddr,0);
  cls32(vaddr2,0);
  lpcx('remap2.pcx',vaddr);
  {This will add some noise to the picture.. enable it if u like}
  {for l1:=1 to 63999 do
  mem[vaddr:l1]:=mem[vaddr:l1]+random(20);}

  setuppal; {Set the pallete}
  dobump;   {do it.. :)}
  shutdown;
  asm
    mov ax,3h
    int 10h
  end;
  writeln('Thats all folks..');
  writeln;
  writeln('If you still have any questions/comments/money/girls for me');
  writeln('E-mail:helix@matrix.kapatel.gr');

end.
