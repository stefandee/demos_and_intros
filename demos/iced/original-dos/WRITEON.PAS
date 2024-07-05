 GetIntVec($1C,@Int1CSave);
 SetIntVec($1C,Addr(TimerHandler));

 repeat
  setactivepage(page);
  cls(page);
  {DoScroll;}
  for i:=1 to 8 do ct^[Precision,i+Precision div 2-4]:=curentchar[i,ccol+1];
  for i:=1 to Precision-1 do for j:=Precision div 2-5 to Precision div 2+5 do ct^[i,j]:=ct^[i+1,j];
  for i := 0 to Precision-1 do
      for j := 0 to Precision-1 do
          if ct^[i,j]<>0 then {putpixel_x(st^[i,j].x,st^[i,j].y,ct^[i,j]);}
                              DrawPoly(st^[i,j].x,st^[i,j].y,st^[i+1,j].x,st^[i+1,j].y,
                                       st^[i,j+1].x,st^[i,j+1].y,st^[i+1,j+1].x,st^[i+1,j+1].y,
                                       ct^[i,j]);
  inc(ccol);
  if ccol>7
     then begin
           ccol := 0;
           inc(curchar);
           {sound(1000);delay(50);nosound;}
           if curchar>length(Greet) then curchar := 1;
           for i:=1 to 8 do for j:=1 to 8 do curentchar[i,j]:=0;
           ReadCurentChar(byte(Greet[curchar]));
          end;
  repeat
  until dodraw;
  waitretrace;
  setvisiblepage(page);
  page := (page+1) mod 2;
  asm cli end;
  dodraw := false;
  asm sti end;
 until port[$60]<128;

 SetIntVec($1C,@Int1CSave);
