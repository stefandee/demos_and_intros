unit speech;

interface

uses graphics;

var message : array[1..820] of char;
    txt2scr : string;
    msgcnt  : integer;
    dtext   : shortint;

procedure DoEnd;

implementation

procedure DoEnd;
var
    f       : file;
    i,j     : integer;
    aux     : char;
    fnt     : byte;

begin

vga256;loadpal('compile.dat',23390);setpal;initvscreen;cls(0,vaddr);
assign(f,'compile.dat');reset(f,1);blockread(f,message,560);close(f);
txt2scr:='                                   ';
for i:=1 to 16 do
    begin
      for j:=1 to 35 do
          begin
          aux:=char(255-byte(message[(i-1)*35+j]));
          if aux='@' then begin fnt:=3;aux:=' ';end;
          if aux='#' then begin fnt:=4;aux:=' ';end;
          if (aux<#32) or (aux='.') then aux:=' ';
          txt2scr[j]:=aux;
          end;
      outtext(160-4*length(txt2scr),i*11,txt2scr,fnt,2*i,vaddr);
    end;

flip;
repeat rotatepal; for i:=1 to 500 do;until port[$60]=1;
fadeout(3);
end;


Begin
End.