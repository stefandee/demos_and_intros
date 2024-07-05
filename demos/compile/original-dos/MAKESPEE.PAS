uses crt;

CONST msg : array[1..10] of string[32];

var f : file;
    s : array[1..32] of char;
    i : integer;

begin
assign(f,'speech.txt');
rewrite(f,1);
clrscr;
writeln('.................................');
repeat
for i:=1 to 32 do read(s[i]);
for i:=1 to 32 do write(s[i]);
writeln;

blockwrite(f,s,32);
until port[$60]=1;

close(f);
end.