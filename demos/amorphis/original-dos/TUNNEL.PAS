type
    point2d = record
              x,y : integer;
            end;
var
   counter      : word;
   points       : array[1..75] of point2d;
   t            : single;
   f            : file;

begin
  t := 6;
  counter:=1;
  repeat
    with points[counter] do
         begin
           x := round(0.6*exp(1+t)*cos(t));
           y := round(0.6*exp(1+t)*sin(t));
         end;
    if t>4.5 then t := t-0.05
       else t := t-0.1;
    inc(counter);
  until t<=0;
  writeln('End generate.There are ',counter-1,' points.');
  assign(f,'spiral.dat');
  rewrite(f,1);
  blockwrite(f,points,sizeof(points));
  close(f);
end.