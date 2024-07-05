uses graphics,crt;

begin

vga256;
initvscreen;
loadpal('default.pal');setpal;
randomize;
hlin:=NHlin;
repeat
drawpoly( random(320),random(199),random(320),random(199),
          random(320),random(199),random(320),random(199),
          100+random(155),vga);
until readkey=#13;
end.