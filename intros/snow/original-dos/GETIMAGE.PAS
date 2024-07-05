PROGRAM
       GetImag;
{ This must be compile din real mode }
{ Apparently , external BGI are not  }
{ compatible with Protected mode     }
USES
    Graph,Crt,basic;
const
     Spr_File_ID  : ID = ('K','A','R','G',' ','X','S','P','R',' ');
     color = 15;
     savemode : array[1..4] of string = ('Normal','Left/Right','Up/Down','Quad');
     srcpath  = '';
     destpath = '';
     srcfilename = 'snowgfx';
     dstfilename = 'backgnd';

var
   gd,gm      : integer;
   s          : string;
   x,y,xl,yl  : longint;
   pal        : array[0..255,1..3] of byte;
   keystat    : byte absolute 0:$417;
   tempkeystat: byte;
   NUMLOCK    : boolean;
   imgsize    : longint;
   sm         : integer;
   fd         : FILE;
   i,j        : integer;
   tempstr    : Str08;
   pixel      : byte;
   tempx,tempy,tempxl,tempyl : integer;
   img        : pointer;

procedure LoadPcx(fname : string);
var
   fs    : file;
   len   : longint;
   i     : longint;
   data  : integer;
   count : integer;
   x,y   : integer;
   xmin,xmax,ymin,ymax,imgwidth,imgheight : integer;

begin
  assign(fs,fname);
  reset(fs,1);
  len := filesize(fs);
  seek(fs, len-768);
  blockread(fs, pal, 768);
  for i:= 0 to 255 do
      begin
        port[$3c8] := i;
        pal[i,1] := pal[i,1] div 4;
        pal[i,2] := pal[i,2] div 4;
        pal[i,3] := pal[i,3] div 4;
        port[$3c9] := pal[i,1];
        port[$3c9] := pal[i,2];
        port[$3c9] := pal[i,3];
      end;

  seek(fs,4);
  blockread(fs, xmin, 2);
  blockread(fs, ymin, 2);
  blockread(fs, xmax, 2);
  blockread(fs, ymax, 2);
  imgwidth := xmax -xmin +1;
  imgheight := ymax -ymin +1;

  seek(fs, 128);
  x := 0;y := 0;

  repeat
    blockread(fs, data, 1);
    if (data and $C0) = $C0
       then begin
              count := data and $3F;
              blockread(fs, data, 1);
              setcolor(data);
              for i:=0 to count-1 do
                  begin
                    if x>imgwidth-1 then begin x:=0;inc(y); end;
                    putpixel(x,y,data);
                    inc(x);
                  end;
            end
       else begin
              putpixel(x,y,data);
              inc(x);
              if x>imgwidth-1 then begin x:=0;inc(y); end;
            end;
  until (y=imgheight);
  close(fs);
end;

BEGIN
  gd := installuserdriver('svga256',nil);
  gm := 2;
  initgraph(gd,gm,'');

  loadpcx(srcpath+srcfilename+'.pcx');
  setwritemode(XORPut);
  setrgbpalette(color,63,63,63);
  setcolor(color);
  x := 10;y := 10;xl:=294;yl:=30;sm:=1;
  rectangle(x,y,x+xl,y+yl);
  outtextxy(550,10,savemode[sm]);

  repeat
    tempkeystat := keystat;
    NUMLOCK := (tempkeystat and 32) <> 0;
    setcolor(0);
    imgsize := xl*yl;
    str(imgsize,s);
    outtextxy(550,0,s);
    setcolor(color);

    case port[$60] of
      1  : break;
      {69 : NUMLOCK := not NUMLOCK;}
      16 : case NUMLOCK of
           true : begin
                    rectangle(x,y,x+xl,y+yl);
                    dec(y);
                    if y < 0 then y := 0;
                    rectangle(x,y,x+xl,y+yl);
                  end;
           false : begin
                     rectangle(x,y,x+xl,y+yl);
                     dec(yl);
                     if yl<2 then yl := 2;
                     rectangle(x,y,x+xl,y+yl);
                   end;
           end;
      44 : case NUMLOCK of
           true : begin
                    rectangle(x,y,x+xl,y+yl);
                    inc(y);
                    if y > getmaxy then y := getmaxy;
                    if y+yl > getmaxy then y := getmaxy-yl;
                    rectangle(x,y,x+xl,y+yl);
                  end;
           false : begin
                     rectangle(x,y,x+xl,y+yl);
                     inc(yl);
                     if y+yl>getmaxy then yl := getmaxy-y;
                     rectangle(x,y,x+xl,y+yl);
                   end;
           end;
      24 : case NUMLOCK of
           true : begin
                    rectangle(x,y,x+xl,y+yl);
                    dec(x);
                    if x < 0 then x := 0;
                    rectangle(x,y,x+xl,y+yl);
                  end;
           false : begin
                     rectangle(x,y,x+xl,y+yl);
                     dec(xl);
                     if xl<2 then xl := 2;
                     rectangle(x,y,x+xl,y+yl);
                   end;
           end;
      25 : case NUMLOCK of
           true : begin
                    rectangle(x,y,x+xl,y+yl);
                    inc(x);
                    if x > getmaxx then x := getmaxx;
                    if x+xl > getmaxx then x := getmaxx-xl;
                    rectangle(x,y,x+xl,y+yl);
                  end;
           false : begin
                     rectangle(x,y,x+xl,y+yl);
                     inc(xl);
                     if x+xl>getmaxx then xl := getmaxx-x;
                     rectangle(x,y,x+xl,y+yl);
                   end;
           end;
      57 : begin
             assign(fd,destpath+dstfilename+'.dat');
             rewrite(fd,1);
             getmem(Img,(xl-1)*(yl-1));
             getimage(x+1,y+1,x+xl-1,y+yl-1,Img^);
             blockwrite(fd,Img^,(xl-1)*(yl-1));
             close(fd);
           end;
     45 : begin
            setcolor(0);
            outtextxy(550,10,savemode[sm]);
            inc(sm);
            if sm>4 then sm := 1;
            delay(100);
            setcolor(color);
            outtextxy(550,10,savemode[sm]);
          end;
    end;
    setcolor(color);
    imgsize := xl*yl;
    str(imgsize,s);
    outtextxy(550,0,s);
    asm
      mov ax,$0c02
      int 21h
    end;
    delay(10);
  until false;
  closegraph;
END.