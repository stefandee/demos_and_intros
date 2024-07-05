program initialisation;

uses dos,crt;
const maxpoint=100;
      maxlink=100;

type obiect =record
            nrpoint:integer;
            nrlink:integer;
            point:array[1..maxpoint,1..3] of real;
            link:array[1..maxlink,1..2] of integer;
            name:string;
            end;
var fil:file of obiect;
    obj:obiect;
    i,j,k,yi,yf,zi:integer;

begin

assign(fil,'obiecte.3dp');
rewrite(fil);

obj.name:='infelif';
j:=1;k:=1;
yi:=25;yf:=-25;
zi:=0;

for i:=1 to length(obj.name) do

case obj.name[i] of

'i': begin
    obj.point[j,1]:=0;obj.point[j,2]:=yi;obj.point[j,3]:=zi;
    obj.point[j+1,1]:=0;obj.point[j+1,2]:=yi;obj.point[j+1,3]:=zi-10;
    obj.point[j+2,1]:=0;obj.point[j+2,2]:=yf;obj.point[j+2,3]:=zi-10;
    obj.point[j+3,1]:=0;obj.point[j+3,2]:=yf;obj.point[j+3,3]:=zi;
    obj.link[k,1]:=j;obj.link[k,2]:=j+1;
    obj.link[k+1,1]:=j+1;obj.link[k+1,2]:=j+2;
    obj.link[k+2,1]:=j+2;obj.link[k+2,2]:=j+3;
    obj.link[k+3,1]:=j+3;obj.link[k+3,2]:=j;
    inc(j,4);inc(k,4);
    dec(zi,15);
    end;

'n': begin
     obj.point[j,1]:=0;obj.point[j,2]:=yi;obj.point[j,3]:=zi;
     obj.point[j+1,1]:=0;obj.point[j+1,2]:=yi-25;obj.point[j+1,3]:=zi-25;
     obj.point[j+2,1]:=0;obj.point[j+2,2]:=yi;obj.point[j+2,3]:=zi-25;
     obj.point[j+3,1]:=0;obj.point[j+3,2]:=yi;obj.point[j+3,3]:=zi-35;
     obj.point[j+4,1]:=0;obj.point[j+4,2]:=yf;obj.point[j+4,3]:=zi-35;
     obj.point[j+5,1]:=0;obj.point[j+5,2]:=yi-25;obj.point[j+5,3]:=zi-10;
     obj.point[j+6,1]:=0;obj.point[j+6,2]:=yf;obj.point[j+6,3]:=zi-10;
     obj.point[j+7,1]:=0;obj.point[j+7,2]:=yf;obj.point[j+7,3]:=zi;
     obj.link[k,1]:=j;obj.link[k,2]:=j+1;
    obj.link[k+1,1]:=j+1;obj.link[k+1,2]:=j+2;
    obj.link[k+2,1]:=j+2;obj.link[k+2,2]:=j+3;
    obj.link[k+3,1]:=j+3;obj.link[k+3,2]:=j+4;
    obj.link[k+4,1]:=j+4;obj.link[k+4,2]:=j+5;
    obj.link[k+5,1]:=j+5;obj.link[k+5,2]:=j+6;
    obj.link[k+6,1]:=j+6;obj.link[k+6,2]:=j+7;
    obj.link[k+7,1]:=j+7;obj.link[k+7,2]:=j;
    inc(j,8);inc(k,8);dec(zi,45);
    end;

'f': begin
     obj.point[j,1]:=0;obj.point[j,2]:=yi;obj.point[j,3]:=zi;
     obj.point[j+1,1]:=0;obj.point[j+1,2]:=yi;obj.point[j+1,3]:=zi-35;
     obj.point[j+2,1]:=0;obj.point[j+2,2]:=yi-10;obj.point[j+2,3]:=zi-35;
     obj.point[j+3,1]:=0;obj.point[j+3,2]:=yi-10;obj.point[j+3,3]:=zi-10;
     obj.point[j+4,1]:=0;obj.point[j+4,2]:=yi-20;obj.point[j+4,3]:=zi-10;
     obj.point[j+5,1]:=0;obj.point[j+5,2]:=yi-20;obj.point[j+5,3]:=zi-35;
     obj.point[j+6,1]:=0;obj.point[j+6,2]:=yi-30;obj.point[j+6,3]:=zi-35;
     obj.point[j+7,1]:=0;obj.point[j+7,2]:=yi-30;obj.point[j+7,3]:=zi-10;
     obj.point[j+8,1]:=0;obj.point[j+8,2]:=yf;obj.point[j+8,3]:=zi-10;
     obj.point[j+9,1]:=0;obj.point[j+9,2]:=yf;obj.point[j+9,3]:=zi;
     obj.link[k,1]:=j;obj.link[k,2]:=j+1;
    obj.link[k+1,1]:=j+1;obj.link[k+1,2]:=j+2;
    obj.link[k+2,1]:=j+2;obj.link[k+2,2]:=j+3;
    obj.link[k+3,1]:=j+3;obj.link[k+3,2]:=j+4;
    obj.link[k+4,1]:=j+4;obj.link[k+4,2]:=j+5;
    obj.link[k+5,1]:=j+5;obj.link[k+5,2]:=j+6;
    obj.link[k+6,1]:=j+6;obj.link[k+6,2]:=j+7;
    obj.link[k+7,1]:=j+7;obj.link[k+7,2]:=j+8;
    obj.link[k+8,1]:=j+8;obj.link[k+8,2]:=j+9;
    obj.link[k+9,1]:=j+9;obj.link[k+9,2]:=j;
    inc(j,10);inc(k,10);dec(zi,45);
    end;

'e': begin
     obj.point[j,1]:=0;obj.point[j,2]:=yi;obj.point[j,3]:=zi;
     obj.point[j+1,1]:=0;obj.point[j+1,2]:=yi;obj.point[j+1,3]:=zi-35;
     obj.point[j+2,1]:=0;obj.point[j+2,2]:=yi-10;obj.point[j+2,3]:=zi-35;
     obj.point[j+3,1]:=0;obj.point[j+3,2]:=yi-10;obj.point[j+3,3]:=zi-10;
     obj.point[j+4,1]:=0;obj.point[j+4,2]:=yi-20;obj.point[j+4,3]:=zi-10;
     obj.point[j+5,1]:=0;obj.point[j+5,2]:=yi-20;obj.point[j+5,3]:=zi-35;
     obj.point[j+6,1]:=0;obj.point[j+6,2]:=yi-30;obj.point[j+6,3]:=zi-35;
     obj.point[j+7,1]:=0;obj.point[j+7,2]:=yi-30;obj.point[j+7,3]:=zi-10;
     obj.point[j+8,1]:=0;obj.point[j+8,2]:=yi-40;obj.point[j+8,3]:=zi-10;
     obj.point[j+9,1]:=0;obj.point[j+9,2]:=yi-40;obj.point[j+9,3]:=zi-35;
     obj.point[j+10,1]:=0;obj.point[j+10,2]:=yf;obj.point[j+10,3]:=zi-35;
     obj.point[j+11,1]:=0;obj.point[j+11,2]:=yf;obj.point[j+11,3]:=zi;
     obj.link[k,1]:=j;obj.link[k,2]:=j+1;
    obj.link[k+1,1]:=j+1;obj.link[k+1,2]:=j+2;
    obj.link[k+2,1]:=j+2;obj.link[k+2,2]:=j+3;
    obj.link[k+3,1]:=j+3;obj.link[k+3,2]:=j+4;
    obj.link[k+4,1]:=j+4;obj.link[k+4,2]:=j+5;
    obj.link[k+5,1]:=j+5;obj.link[k+5,2]:=j+6;
    obj.link[k+6,1]:=j+6;obj.link[k+6,2]:=j+7;
    obj.link[k+7,1]:=j+7;obj.link[k+7,2]:=j+8;
    obj.link[k+8,1]:=j+8;obj.link[k+8,2]:=j+9;
    obj.link[k+9,1]:=j+9;obj.link[k+9,2]:=j+10;
    obj.link[k+10,1]:=j+10;obj.link[k+10,2]:=j+11;
    obj.link[k+11,1]:=j+11;obj.link[k+11,2]:=j;
    inc(j,12);inc(k,12);dec(zi,45);
    end;

'l': begin
     obj.point[j,1]:=0;obj.point[j,2]:=yi;obj.point[j,3]:=zi;
     obj.point[j+1,1]:=0;obj.point[j+1,2]:=yi;obj.point[j+1,3]:=zi-10;
     obj.point[j+2,1]:=0;obj.point[j+2,2]:=yf+10;obj.point[j+2,3]:=zi-10;
     obj.point[j+3,1]:=0;obj.point[j+3,2]:=yf+10;obj.point[j+3,3]:=zi-35;
     obj.point[j+4,1]:=0;obj.point[j+4,2]:=yf;obj.point[j+4,3]:=zi-35;
     obj.point[j+5,1]:=0;obj.point[j+5,2]:=yf;obj.point[j+5,3]:=zi;
     obj.link[k,1]:=j;obj.link[k,2]:=j+1;
    obj.link[k+1,1]:=j+1;obj.link[k+1,2]:=j+2;
    obj.link[k+2,1]:=j+2;obj.link[k+2,2]:=j+3;
    obj.link[k+3,1]:=j+3;obj.link[k+3,2]:=j+4;
    obj.link[k+4,1]:=j+4;obj.link[k+4,2]:=j+5;
    obj.link[k+5,1]:=j+5;obj.link[k+5,2]:=j;
    inc(j,6);inc(k,6);dec(zi,45);
    end;

end;
obj.nrpoint:=j-1;
obj.nrlink:=k-1;
write(fil,obj);
{obj.name:='brand';
obj.point[1,1]:=-20;obj.point[1,2]:=-20;obj.point[1,3]:=0;
obj.point[2,1]:=20;obj.point[2,2]:=-20;obj.point[2,3]:=0;
obj.point[3,1]:=20;obj.point[3,2]:=0;obj.point[3,3]:=0;
obj.point[4,1]:=-20;obj.point[4,2]:=0;obj.point[4,3]:=0;
obj.point[5,1]:=-12;obj.point[5,2]:=-17;obj.point[5,3]:=0;
obj.point[6,1]:=12;obj.point[6,2]:=-17;obj.point[6,3]:=0;
obj.point[7,1]:=12;obj.point[7,2]:=-3;obj.point[7,3]:=0;
obj.point[8,1]:=-12;obj.point[8,2]:=-3;obj.point[8,3]:=0;
obj.point[9,1]:=32;obj.point[9,2]:=0;obj.point[9,3]:=0;
obj.point[10,1]:=-32;obj.point[10,2]:=0;obj.point[10,3]:=0;
obj.point[11,1]:=-32;obj.point[11,2]:=12;obj.point[11,3]:=0;
obj.point[12,1]:=32;obj.point[12,2]:=12;obj.point[12,3]:=0;
obj.point[13,1]:=-40;obj.point[13,2]:=20;obj.point[13,3]:=0;
obj.point[14,1]:=40;obj.point[14,2]:=20;obj.point[14,3]:=0;
obj.link[1,1]:=1;obj.link[1,2]:=2;
obj.link[2,1]:=2;obj.link[2,2]:=3;
obj.link[3,1]:=3;obj.link[3,2]:=4;
obj.link[4,1]:=4;obj.link[4,2]:=1;
obj.link[5,1]:=5;obj.link[5,2]:=6;
obj.link[6,1]:=6;obj.link[6,2]:=7;
obj.link[7,1]:=7;obj.link[7,2]:=8;
obj.link[8,1]:=8;obj.link[8,2]:=5;
obj.link[9,1]:=9;obj.link[9,2]:=10;
obj.link[10,1]:=10;obj.link[10,2]:=11;
obj.link[11,1]:=11;obj.link[11,2]:=12;
obj.link[12,1]:=12;obj.link[12,2]:=9;
obj.link[13,1]:=11;obj.link[13,2]:=13;
obj.link[14,1]:=13;obj.link[14,2]:=14;
obj.link[15,1]:=14;obj.link[15,2]:=12;
obj.nrpoint:=14;
obj.nrlink:=15;
write(fil,obj);}
close(fil);
end.








