program Vibrants_User;

uses snddrv,Crt,Dos;

var f : file;
    p : pointer;
    d : pointer;
    player : longint;
    callseg,callofs : word;
    dataseg,dataofs : word;
    error           : word;

var
  TimeIntVec : Procedure;
{$F+}
procedure Time; interrupt;
begin
  asm
     push ax
     push si

     mov ah,3
     call dword ptr cs:[player]

     pop si
     pop ax
  end;

  inline ($9C); { PUSHF -- Push flags }
  { Call old ISR using saved vector }
  TimeIntVec;
end;
{$F-}

begin

clrscr;
{Reading driver...}
assign(f,'adl-0114.p00');reset(f,1);
getmem(p,filesize(f));
blockread(f,p^,filesize(f));
callseg:=seg(p^);callofs:=ofs(p^);
player:=callofs+callseg*256;
if callofs<>0 then halt;
close(f);

{Reading data...}
assign(f,'music.dat');reset(f,1);
getmem(d,filesize(f));
blockread(f,d^,filesize(f));
dataseg:=seg(d^);dataofs:=ofs(d^);
close(f);


output:=blaster;
base:=$220;
InternalSet;
error:=0;


asm
   mov ah,6
   call dword ptr cs:[player]
   jnc @ok
   mov ax,1
   mov error,ax
@ok:
end;

if error<>0 then begin
                writeln('Error detecting...');
                halt;
                end;
error:=0;

asm
   MOV     Ah,0
   MOV     BX,dataseg
   MOV     Cx,dataofs
   CALL    dWord Ptr cs:[Player]
   jnc     @ok
   mov ax,1
   mov error,ax
@ok :
end;

if error<>0 then begin
                writeln('Error initalizing driver...');
                halt;
                end;

   asm
      mov bx,0
      CALL dWord Ptr cs:[Player]
   end;

Port[$43] := $34;
Port[$40] := ($1234dd div 11025) mod 255;
Port[$40] := ($1234dd div 11025) div 255;

writeln('Begin to play...');

GetIntVec($1c,@TimeIntVec);
SetIntVec($1c,Addr(Time));

readln;
SetIntVec($1c,@TimeIntVec);

end.


