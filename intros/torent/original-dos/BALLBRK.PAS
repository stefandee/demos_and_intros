program Ball_Breaker;

var
   f : file;
   a : array[1..5,1..5] of byte;
   i,j : integer;
begin
  assign(f,'ball.raw');
  reset(f,1);
  blockread(f,a,25);
  for i:=1 to 5 do
      for j :=1 to 5 do
          if a[i,j]=255 then a[i,j] := 191;
  seek(f,0);
  blockwrite(f,a,25);
  close(f);
end.