unit turtle;
interface
uses graphics,crt;
const
    midox=160;
    midoy=100;
    ox:real=160;
    oy:real=100;
    ang:real=270;
    color : byte=200;
procedure forw(i:integer);
procedure left(i:real);
procedure right(i:real);
implementation
procedure forw;
var x,y : real;
    begin
    line(round(ox),round(oy),round(ox+round(i*cos(pi*ang/180))),round(oy+round(i*sin(pi*ang/180))),color,vaddr);
    ox:=ox+round(i*cos(pi*ang/180));
    oy:=oy+round(i*sin(pi*ang/180));
    end;
procedure left;
begin
ang:=ang-i;
end;
procedure right;
begin
ang:=ang+i;
end;
end.

