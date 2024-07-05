program DEMO_COMPILATION;

uses graphics,types3d,crt;

procedure MyMars;

type maptype = array[1..200,1..320] of byte;

var f   : file;
    map : ^maptype;
    sline : real;
    i,j   : integer;
    drlen : integer;

begin
  new(map);
  assign(f,'fraactal.spr');
  reset(f,1);
  blockread(f,map^,64000);
  close(f);
  loadpal('heat.pal');setpal;
  sline:=50;drlen:=5;
  repeat
  for i:=200 downto 1 do
      begin
      for j:=1 to 320 div drlen do
          rectangle(j*drlen+drlen,round(sline),j*drlen,round(sline-30*(map^[i,j*drlen]/256)),map^[i,j*drlen],vaddr);
      sline:=sline+0.25;
      flip;
      end;
  until keypressed;
  dispose(map);
end;

begin

Vga256;InitVScreen;
MyMars;
DoneVga256;DoneVScreen;

end.
