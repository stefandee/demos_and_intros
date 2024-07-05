for i:=1 to 31 do
    begin
    workpal[i,1]:=i+32;workpal[i,2]:=0;workpal[i,3]:=i+32;
    workpal[i+64,1]:=i+32;workpal[i+64,2]:=0;workpal[i+64,3]:=i+32;
    workpal[i+128,1]:=i+32;workpal[i+128,2]:=0;workpal[i+128,3]:=i+32;
    workpal[i+192,1]:=i+32;workpal[i+192,2]:=0;workpal[i+192,3]:=i+32;
    end;
for i:=32 to 63 do
    begin
    workpal[i,1]:=i;workpal[i,2]:=i;workpal[i,3]:=0;
    workpal[i+64,1]:=i;workpal[i+64,2]:=i;workpal[i+64,3]:=0;
    workpal[i+128,1]:=i;workpal[i+128,2]:=i;workpal[i+128,3]:=0;
    workpal[i+192,1]:=i;workpal[i+192,2]:=i;workpal[i+192,3]:=0;
    end;
