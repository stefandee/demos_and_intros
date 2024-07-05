program linker;

uses dos,crt;

var fs,fd : file;
    i : longint;
    aux : byte;
    ts : searchrec;
    ch : char;

begin
assign(fd,'compile.dat');rewrite(fd,1);
clrscr;
findfirst('*.*',$3f,ts);
repeat
write(ts.name,' ',ts.size,' bytes. ','Add it(Y/N) ? ');
repeat
ch:=upcase(readkey);
case ch of
'Y' : begin
       writeln('Yep');
       assign(fs,ts.name);
       reset(fs,1);
       for i:=1 to filesize(fs) do
           begin
            blockread(fs,aux,1);
            blockwrite(fd,aux,1);
           end;
       close(fs);
      end;
'N' : begin
       ch:='Y';
       writeln('Nope');
      end;
end;
until ch='Y';

findnext(ts);
until doserror<>0;
close(fd);
end.