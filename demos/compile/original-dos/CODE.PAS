var fs,fd : file;
    aux : byte;

begin
assign(fs,'greets.txt');reset(fs,1);
assign(fd,'greets.cod');rewrite(fd,1);
repeat
blockread(fs,aux,1);
aux:=255-aux;
blockwrite(fd,aux,1);
until eof(fs);

close(fs);close(fd);

end.