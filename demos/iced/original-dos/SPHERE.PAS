
 for i:= 0 to Precision div 2-1 do
     for j:= 0 to Precision div 2-1 do
         begin
          {
          if ct^[i,j]<>0 then
          DrawPoly( st^[i,j].x,     st^[i,j].y,     st^[(i+1),j].x,     st^[(i+1),j].y,
                    st^[i,(j+1)].x, st^[i,(j+1)].y, st^[(i+1),(j+1)].x, st^[(i+1),(j+1)].y,
                    ct^[i,j]);}
          if ct^[i,j]<>0 then
          DrawPoly( st^[i*2,j*2].x,     st^[i*2,j*2].y,     st^[(i+1)*2,j*2].x,     st^[(i+1)*2,j*2].y,
                    st^[i*2,(j+1)*2].x, st^[i*2,(j+1)*2].y, st^[(i+1)*2,(j+1)*2].x, st^[(i+1)*2,(j+1)*2].y,
                    ct^[i*2,j*2]);
          end;
 readln;
