procedure GenerateWormHole;
const
     Stretch = 15;
     DivS    = 120;
     Spokes  = 2400;
var
   x,y,z : single;
   i,j,c : integer;
begin
  for j:=1 to DivS+1 do
      for i:=1 to Spokes do
          begin
            z := -1+(ln(2*j/DIVS));
            x := 320*j/DIVS*cos(2*PI*i/SPOKES);
            y := 240*j/DIVS*sin(2*PI*i/SPOKES);
            y := y-STRETCH*z;
            x := x+160;
            y := y+120;
            color := (i div 8) mod 15+15*((j div 6) mod 15)+1;
            putpixel_x(round(x),round(y),color);
          end;
end;
