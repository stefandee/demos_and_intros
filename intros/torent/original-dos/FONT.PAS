TYPE
    Point2D = record
              x,y : shortint;
            end;
    Point3D = record
              x,y,z : longint;
            end;
    TCurve  = record
             P1,P2,P3,P4 : Point2D;
           end;
    TLetter = record
              Curves   : array[1..5] of TCurve;
              MaxCurve : integer;
            end;
    TFont   = array[' '..'Z'] of TLetter;
VAR
   Font : TFont;
   F    : file of TFont;
BEGIN
  with Font['0'] do
       begin
         MaxCurve := 2;
         { curba 1 }
         with Curves[1] do
              begin
                P1.X := 5;P1.Y := 0;
                P4.X := 5;P4.Y := 16;
                P3.X := 0;P3.Y := 16;
                P2.X := 0;P2.Y := 0;
              end;
         { curba 2 }
         with Curves[2] do
              begin
                P4.X := 5;P4.Y := 0;
                P1.X := 5;P1.Y := 16;
                P3.X := 10;P3.Y := 0;
                P2.X := 10;P2.Y := 16;
              end;
       end;
  with Font['1'] do
       begin
         MaxCurve := 2;
         { curba 1 }
         with Curves[1] do
              begin
                P4.X := 5;P4.Y := 0;
                P1.X := 0;P1.Y := 8;
                P2.X := 3;P2.Y := 8;
                P3.X := 5;P3.Y := 3;
              end;
         { curba 2 }
         with Curves[2] do
              begin
                P1.X := 5;P1.Y := 0;
                P4.X := 5;P4.Y := 16;
                P3.X := 5;P3.Y := 8;
                P2.X := 5;P2.Y := 8;
              end;
       end;
  with Font['2'] do
       begin
         MaxCurve := 3;
         { curba 1 }
         with Curves[1] do
              begin
                P1.X := 0;P1.Y := 5;
                P2.X := 0;P2.Y := 0;
                P3.X := 10;P3.Y := 0;
                P4.X := 10;P4.Y := 4;
              end;
         { curba 2 }
         with Curves[2] do
              begin
                P1.X := 10;P1.Y := 4;
                P2.X := 7;P2.Y := 4;
                P3.X := 0;P3.Y := 10;
                P4.X := 0;P4.Y := 16;
              end;
         { curba 3 }
         with Curves[3] do
              begin
                P1.X := 0;P1.Y := 16;
                P2.X := 0;P2.Y := 13;
                P3.X := 10;P3.Y := 13;
                P4.X := 10;P4.Y := 16;
              end;
       end;
  with Font['3'] do
       begin
         MaxCurve := 2;
         { curba 1 }
         with Curves[1] do
              begin
                P1.X := 3;P1.Y := 0;
                P2.X := 10;P2.Y := 0;
                P3.X := 10;P3.Y := 8;
                P4.X := 5;P4.Y := 8;
              end;
         { curba 2 }
         with Curves[2] do
              begin
                P1.X := 5;P1.Y := 8;
                P2.X := 10;P2.Y := 8;
                P3.X := 10;P3.Y := 16;
                P4.X := 3;P4.Y := 16;
              end;
       end;
  with Font['4'] do
       begin
         MaxCurve := 2;
         { curba 1 }
         with Curves[1] do
              begin
                P1.X := 10;P1.Y := 0;
                P2.X := 0;P2.Y := 0;
                P3.X := 0;P3.Y := 12;
                P4.X := 10;P4.Y := 8;
              end;
         { curba 2 }
         with Curves[2] do
              begin
                P1.X := 10;P1.Y := 8;
                P2.X := 8;P2.Y := 8;
                P3.X := 8;P3.Y := 8;
                P4.X := 8;P4.Y := 16;
              end;
       end;
  with Font['5'] do
       begin
         MaxCurve := 3;
         { curba 1 }
         with Curves[1] do
              begin
                P1.X := 10;P1.Y := 0;
                P2.X := 3;P2.Y := 0;
                P3.X := 3;P3.Y := 0;
                P4.X := 3;P4.Y := 0;
              end;
         { curba 2 }
         with Curves[2] do
              begin
                P1.X := 3;P1.Y := 0;
                P2.X := 0;P2.Y := 5;
                P3.X := 0;P3.Y := 5;
                P4.X := 0;P4.Y := 5;
              end;
         { curba 3 }
         with Curves[3] do
              begin
                P1.X := 0;P1.Y := 5;
                P2.X := 10;P2.Y := 6;
                P3.X := 10;P3.Y := 16;
                P4.X := 0;P4.Y := 16;
              end;
       end;
  with Font['6'] do
       begin
         MaxCurve := 2;
         { curba 1 }
         with Curves[1] do
              begin
                P1.X := 10;P1.Y := 0;
                P2.X := 0;P2.Y := 0;
                P3.X := 0;P3.Y := 16;
                P4.X := 10;P4.Y := 14;
              end;
         { curba 2 }
         with Curves[2] do
              begin
                P1.X := 10;P1.Y := 14;
                P2.X := 10;P2.Y := 5;
                P3.X := 0;P3.Y := 5;
                P4.X := 3;P4.Y := 10;
              end;
       end;
  with Font['7'] do
       begin
         MaxCurve := 3;
         { curba 1 }
         with Curves[1] do
              begin
                P1.X := 0;P1.Y := 0;
                P2.X := 0;P2.Y := 2;
                P3.X := 10;P3.Y := 2;
                P4.X := 10;P4.Y := 0;
              end;
         { curba 2 }
         with Curves[2] do
              begin
                P1.X := 10;P1.Y := 0;
                P2.X := 9;P2.Y := 9;
                P3.X := 7;P3.Y := 9;
                P4.X := 7;P4.Y := 16;
              end;
         { curba 3 }
         with Curves[3] do
              begin
                P1.X := 3;P1.Y := 8;
                P2.X := 5;P2.Y := 9;
                P3.X := 5;P3.Y := 9;
                P4.X := 10;P4.Y := 8;
              end;
       end;
  with Font['8'] do
       begin
         MaxCurve := 4;
         { curba 1 }
         with Curves[1] do
              begin
                P1.X := 5;P1.Y := 0;
                P2.X := 2;P2.Y := 0;
                P3.X := 2;P3.Y := 8;
                P4.X := 5;P4.Y := 8;
              end;
         { curba 2 }
         with Curves[3] do
              begin
                P1.X := 5;P1.Y := 16;
                P2.X := 0;P2.Y := 16;
                P3.X := 0;P3.Y := 8;
                P4.X := 5;P4.Y := 8;
              end;
         { curba 3 }
         with Curves[2] do
              begin
                P1.X := 5;P1.Y := 8;
                P2.X := 10;P2.Y := 8;
                P3.X := 10;P3.Y := 16;
                P4.X := 5;P4.Y := 16;
              end;
         { curba 4 }
         with Curves[4] do
              begin
                P1.X := 5;P1.Y := 8;
                P2.X := 10;P2.Y := 8;
                P3.X := 10;P3.Y := 0;
                P4.X := 5;P4.Y := 0;
              end;
       end;
  with Font['9'] do
       begin
         MaxCurve := 2;
         { curba 1 }
         with Curves[1] do
              begin
                P1.X := 10;P1.Y := 7;
                P2.X := -4;P2.Y := -4;
                P3.X := -4;P3.Y := 16;
                P4.X := 10;P4.Y := 8;
              end;
         { curba 2 }
         with Curves[2] do
              begin
                P1.X := 10;P1.Y := 7;
                P2.X := 10;P2.Y := 16;
                P3.X := 10;P3.Y := 16;
                P4.X := 3;P4.Y := 16;
              end;
       end;
  with Font['B'] do
       begin
         MaxCurve := 2;
         { curba 1 }
         with Curves[1] do
              begin
                P1.X := 0;P1.Y := 0;
                P2.X := 0;P2.Y := 0;
                P3.X := 0;P3.Y := 16;
                P4.X := 0;P4.Y := 16;
              end;
         { curba 2 }
         with Curves[2] do
              begin
                P1.X := 0;P1.Y := 8;
                P2.X := 8;P2.Y := 8;
                P3.X := 10;P3.Y := 16;
                P4.X := 0;P4.Y := 16;
              end;
       end;
  with Font['C'] do
       begin
         MaxCurve := 1;
         { curba 1 }
         with Curves[1] do
              begin
                P1.X := 10;P1.Y := 5;
                P2.X := 0;P2.Y := 10;
                P3.X := 0;P3.Y := 16;
                P4.X := 10;P4.Y := 16;
              end;
       end;
  with Font['E'] do
       begin
         MaxCurve := 2;
         { curba 1 }
         with Curves[1] do
              begin
                P1.X := 0;P1.Y := 16;
                P2.X := 7;P2.Y := 16;
                P3.X := 10;P3.Y := 5;
                P4.X := 5;P4.Y := 5;
              end;
         { curba 2 }
         with Curves[2] do
              begin
                P1.X := 5;P1.Y := 5;
                P2.X := 0;P2.Y := 5;
                P3.X := 3;P3.Y := 16;
                P4.X := 10;P4.Y := 16;
              end;
       end;
  with Font['A'] do
       begin
         MaxCurve := 3;
         { curba 1 }
         with Curves[1] do
              begin
                P1.X := 8;P1.Y := 5;
                P2.X := 0;P2.Y := 5;
                P3.X := 0;P3.Y := 16;
                P4.X := 3;P4.Y := 16;
              end;
         { curba 2 }
         with Curves[2] do
              begin
                P1.X := 3;P1.Y := 16;
                P2.X := 8;P2.Y := 16;
                P3.X := 8;P3.Y := 16;
                P4.X := 8;P4.Y := 5;
              end;
         { curba 3 }
         with Curves[3] do
              begin
                P1.X := 8;P1.Y := 5;
                P2.X := 8;P2.Y := 5;
                P3.X := 8;P3.Y := 5;
                P4.X := 10;P4.Y := 16;
              end;
       end;
  with Font['T'] do
       begin
         MaxCurve := 3;
         { curba 1 }
         with Curves[1] do
              begin
                P1.X := 5;P1.Y := 0;
                P2.X := 8;P2.Y := 0;
                P3.X := 8;P3.Y := 10;
                P4.X := 5;P4.Y := 10;
              end;
         { curba 2 }
         with Curves[2] do
              begin
                P1.X := 5;P1.Y := 10;
                P2.X := 0;P2.Y := 16;
                P3.X := 8;P3.Y := 16;
                P4.X := 8;P4.Y := 14;
              end;
         { curba 3 }
         with Curves[3] do
              begin
                P1.X := 4;P1.Y := 4;
                P2.X := 4;P2.Y := 4;
                P3.X := 4;P3.Y := 4;
                P4.X := 10;P4.Y := 4;
              end;
       end;
  with Font['O'] do
       begin
         MaxCurve := 3;
         { curba 1 }
         with Curves[1] do
              begin
                P1.X := 4;P1.Y := 5;
                P2.X := 0;P2.Y := 5;
                P3.X := 0;P3.Y := 16;
                P4.X := 4;P4.Y := 16;
              end;
         { curba 2 }
         with Curves[2] do
              begin
                P1.X := 4;P1.Y := 16;
                P2.X := 7;P2.Y := 16;
                P3.X := 7;P3.Y := 5;
                P4.X := 4;P4.Y := 5;
              end;
         { curba 3 }
         with Curves[3] do
              begin
                P1.X := 4;P1.Y := 5;
                P2.X := 4;P2.Y := 7;
                P3.X := 10;P3.Y := 7;
                P4.X := 10;P4.Y := 5;
              end;
       end;
  with Font['R'] do
       begin
         MaxCurve := 2;
         { curba 1 }
         with Curves[1] do
              begin
                P1.X := 2;P1.Y := 16;
                P2.X := 2;P2.Y := 7;
                P3.X := 2;P3.Y := 7;
                P4.X := 2;P4.Y := 7;
              end;
         { curba 2 }
         with Curves[2] do
              begin
                P1.X := 2;P1.Y := 7;
                P2.X := 2;P2.Y := 5;
                P3.X := 8;P3.Y := 7;
                P4.X := 8;P4.Y := 7;
              end;
       end;
  with Font['N'] do
       begin
         MaxCurve := 2;
         { curba 1 }
         with Curves[1] do
              begin
                P1.X := 0;P1.Y := 5;
                P2.X := 2;P2.Y := 7;
                P3.X := 2;P3.Y := 16;
                P4.X := 2;P4.Y := 16;
              end;
         { curba 2 }
         with Curves[2] do
              begin
                P1.X := 2;P1.Y := 7;
                P2.X := 5;P2.Y := 1;
                P3.X := 8;P3.Y := 16;
                P4.X := 8;P4.Y := 16;
              end;
       end;
  with Font['S'] do
       begin
         MaxCurve := 2;
         { curba 1 }
         with Curves[1] do
              begin
                P1.X := 8;P1.Y := 5;
                P2.X := 2;P2.Y := 5;
                P3.X := 2;P3.Y := 10;
                P4.X := 5;P4.Y := 10;
              end;
         { curba 2 }
         with Curves[2] do
              begin
                P1.X := 5;P1.Y := 10;
                P2.X := 8;P2.Y := 10;
                P3.X := 8;P3.Y := 16;
                P4.X := 2;P4.Y := 16;
              end;
       end;
  with Font['P'] do
       begin
         MaxCurve := 2;
         { curba 1 }
         with Curves[1] do
              begin
                P1.X := 2;P1.Y := 5;
                P2.X := 2;P2.Y := 5;
                P3.X := 2;P3.Y := 5;
                P4.X := 2;P4.Y := 20;
              end;
         { curba 2 }
         with Curves[2] do
              begin
                P1.X := 2;P1.Y := 5;
                P2.X := 8;P2.Y := 5;
                P3.X := 8;P3.Y := 16;
                P4.X := 2;P4.Y := 16;
              end;
       end;
  with Font['I'] do
       begin
         MaxCurve := 2;
         { curba 1 }
         with Curves[1] do
              begin
                P1.X := 3;P1.Y := 5;
                P2.X := 3;P2.Y := 5;
                P3.X := 3;P3.Y := 16;
                P4.X := 8;P4.Y := 13;
              end;
         { curba 2 }
         with Curves[2] do
              begin
                P1.X := 3;P1.Y := 2;
                P2.X := 3;P2.Y := 2;
                P3.X := 3;P3.Y := 2;
                P4.X := 3;P4.Y := 2;
              end;
       end;
  with Font['Y'] do
       begin
         MaxCurve := 2;
         { curba 1 }
         with Curves[1] do
              begin
                P1.X := 2;P1.Y := 5;
                P2.X := 2;P2.Y := 16;
                P3.X := 5;P3.Y := 13;
                P4.X := 8;P4.Y := 13;
              end;
         { curba 2 }
         with Curves[2] do
              begin
                P1.X := 8;P1.Y := 5;
                P2.X := 8;P2.Y := 16;
                P3.X := 5;P3.Y := 20;
                P4.X := 2;P4.Y := 18;
              end;
       end;
  with Font[':'] do
       begin
         MaxCurve := 2;
         { curba 1 }
         with Curves[1] do
              begin
                P1.X := 5;P1.Y := 5;
                P2.X := 5;P2.Y := 5;
                P3.X := 5;P3.Y := 5;
                P4.X := 5;P4.Y := 5;
              end;
         { curba 2 }
         with Curves[2] do
              begin
                P1.X := 5;P1.Y := 16;
                P2.X := 5;P2.Y := 16;
                P3.X := 5;P3.Y := 16;
                P4.X := 5;P4.Y := 16;
              end;
       end;
  with Font['L'] do
       begin
         MaxCurve := 2;
         { curba 1 }
         with Curves[1] do
              begin
                P1.X := 2;P1.Y := 10;
                P2.X := 8;P2.Y := 5;
                P3.X := 8;P3.Y := 5;
                P4.X := 5;P4.Y := 0;
              end;
         { curba 2 }
         with Curves[2] do
              begin
                P1.X := 5;P1.Y := 0;
                P2.X := 0;P2.Y := 5;
                P3.X := 5;P3.Y := 16;
                P4.X := 8;P4.Y := 15;
              end;
       end;
  with Font['M'] do
       begin
         MaxCurve := 2;
         { curba 1 }
         with Curves[1] do
              begin
                P1.X := 0;P1.Y := 18;
                P2.X := 0;P2.Y := 5;
                P3.X := 5;P3.Y := 5;
                P4.X := 5;P4.Y := 16;
              end;
         { curba 2 }
         with Curves[2] do
              begin
                P1.X := 5;P1.Y := 16;
                P2.X := 5;P2.Y := 5;
                P3.X := 10;P3.Y := 5;
                P4.X := 10;P4.Y := 16;
              end;
       end;
  with Font['U'] do
       begin
         MaxCurve := 2;
         { curba 1 }
         with Curves[1] do
              begin
                P1.X := 2;P1.Y := 5;
                P2.X := 2;P2.Y := 20;
                P3.X := 8;P3.Y := 20;
                P4.X := 8;P4.Y := 7;
              end;
         { curba 2 }
         with Curves[2] do
              begin
                P1.X := 8;P1.Y := 7;
                P2.X := 9;P2.Y := 10;
                P3.X := 5;P3.Y := 16;
                P4.X := 10;P4.Y := 16;
              end;
       end;
  with Font['D'] do
       begin
         MaxCurve := 2;
         { curba 1 }
         with Curves[1] do
              begin
                P1.X := 8;P1.Y := 8;
                P2.X := 0;P2.Y := 5;
                P3.X := 0;P3.Y := 17;
                P4.X := 8;P4.Y := 14;
              end;
         { curba 2 }
         with Curves[2] do
              begin
                P1.X := 8;P1.Y := 14;
                P2.X := 8;P2.Y := 14;
                P3.X := 8;P3.Y := 14;
                P4.X := 8;P4.Y := 0;
              end;
       end;
  with Font['F'] do
       begin
         MaxCurve := 3;
         { curba 1 }
         with Curves[1] do
              begin
                P1.X := 8;P1.Y := 3;
                P2.X := 8;P2.Y := 0;
                P3.X := 5;P3.Y := 0;
                P4.X := 5;P4.Y := 8;
              end;
         { curba 2 }
         with Curves[2] do
              begin
                P1.X := 5;P1.Y := 8;
                P2.X := 5;P2.Y := 16;
                P3.X := 2;P3.Y := 16;
                P4.X := 2;P4.Y := 13;
              end;
         { curba 3 }
         with Curves[3] do
              begin
                P1.X := 2;P1.Y := 8;
                P2.X := 2;P2.Y := 8;
                P3.X := 2;P3.Y := 8;
                P4.X := 8;P4.Y := 8;
              end;
       end;
  with Font['G'] do
       begin
         MaxCurve := 3;
         { curba 1 }
         with Curves[1] do
              begin
                P1.X := 8;P1.Y := 7;
                P2.X := 0;P2.Y := 0;
                P3.X := 0;P3.Y := 16;
                P4.X := 8;P4.Y := 8;
              end;
         { curba 2 }
         with Curves[2] do
              begin
                P1.X := 8;P1.Y := 7;
                P2.X := 8;P2.Y := 23;
                P3.X := 2;P3.Y := 23;
                P4.X := 2;P4.Y := 18;
              end;
         { curba 3 }
         with Curves[3] do
              begin
                P1.X := 2;P1.Y := 18;
                P2.X := 2;P2.Y := 16;
                P3.X := 2;P3.Y := 16;
                P4.X := 10;P4.Y := 16;
              end;
       end;
  with Font['K'] do
       begin
         MaxCurve := 3;
         { curba 1 }
         with Curves[1] do
              begin
                P1.X := 0;P1.Y := 0;
                P2.X := 0;P2.Y := 0;
                P3.X := 0;P3.Y := 16;
                P4.X := 0;P4.Y := 16;
              end;
         { curba 2 }
         with Curves[2] do
              begin
                P1.X := 0;P1.Y := 16;
                P2.X := 5;P2.Y := 0;
                P3.X := 10;P3.Y := 10;
                P4.X := 5;P4.Y := 13;
              end;
         { curba 3 }
         with Curves[3] do
              begin
                P1.X := 5;P1.Y := 13;
                P2.X := 5;P2.Y := 13;
                P3.X := 10;P3.Y := 16;
                P4.X := 10;P4.Y := 16;
              end;
       end;
  with Font['V'] do
       begin
         MaxCurve := 2;
         { curba 1 }
         with Curves[1] do
              begin
                P1.X := 2;P1.Y := 5;
                P2.X := 2;P2.Y := 5;
                P3.X := 5;P3.Y := 16;
                P4.X := 5;P4.Y := 16;
              end;
         { curba 2 }
         with Curves[2] do
              begin
                P1.X := 5;P1.Y := 16;
                P2.X := 5;P2.Y := 16;
                P3.X := 8;P3.Y := 5;
                P4.X := 8;P4.Y := 5;
              end;
       end;
  with Font['!'] do
       begin
         MaxCurve := 2;
         { curba 1 }
         with Curves[1] do
              begin
                P1.X := 5;P1.Y := 0;
                P2.X := 5;P2.Y := 0;
                P3.X := 5;P3.Y := 12;
                P4.X := 5;P4.Y := 12;
              end;
         { curba 2 }
         with Curves[2] do
              begin
                P1.X := 5;P1.Y := 16;
                P2.X := 5;P2.Y := 16;
                P3.X := 5;P3.Y := 16;
                P4.X := 5;P4.Y := 16;
              end;
       end;
  with Font['W'] do
       begin
         MaxCurve := 2;
         { curba 1 }
         with Curves[1] do
              begin
                P1.X := 0;P1.Y := 5;
                P2.X := 0;P2.Y := 18;
                P3.X := 5;P3.Y := 18;
                P4.X := 5;P4.Y := 5;
              end;
         { curba 2 }
         with Curves[2] do
              begin
                P1.X := 5;P1.Y := 5;
                P2.X := 5;P2.Y := 18;
                P3.X := 10;P3.Y := 18;
                P4.X := 10;P4.Y := 5;
              end;
       end;
  with Font[' '] do
       begin
         MaxCurve := 0;
       end;
  assign(f,'font.fnt');
  rewrite(f);
  write(f,Font);
  close(f);
END.