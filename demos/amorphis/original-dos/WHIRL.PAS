program
       Whirlwind;

{$I sincos.inc}
{$I 3d.inc}
{$I modex.inc}
{$I scale.inc}
{$I font.inc}

const
     MaxWWPart = 1000;
     LastPages : array[1..15,1..5] of string[30] =
     (('','','','BEST REGARDS TO:','BORLAND AKA VALER BOCAN'),
      ('','','','JULIE','JOHN'),
      ('HERE ENDS THIS DEMO...','THIS DEMO IS DEDICATED','-SCALING ROUTINE-','STELI','MARCEL HANCHES'),
      ('FROM NOW ON FOLLOWS THE','TO EVERYBODY THAT TORTURE','JOHN A. SLAGEL','SEBI','NELUTU PLESA'),
      ('CREDITS AND GREETINGS,','HIMSELF PROGRAMMING DATABASES,','-PLASMA FRACTAL ROUTINE-','MR. BABII,MR. DRAGOMIRESCU AND',
      'RADIO SKY CONSTANTA 101.1MHZ'),
      ('SO STAY TUNED. BUT BEFORE','IN FOXPRO,DBASE,PARADOX,DELPHI','THE STONE SOUP GROUP','EVERYONE OF BERG COMPUTERS',
      'DAN DANIEL'),
      ('HITTING ESC, YOU MUST KNOW','AND SO ON :-)','-SOUNDSYSTEM-','DORU TODINCA','THE FOOTBALL TEAM FC FARUL'),
      ('THAT I AM AVAILABLE FOR',' ','TSC SOFTWARE','BOGDAN OF TOTALDATA CONSTANTA','(GOOD LUCK, BOYS!'),
      ('COMMERCIAL DEMOS, SO CALL','THE CREDITS:','''FAINTER'' THEME BY SOMEONE','ZOLY','CORINA'),
      ('039-041623755 OR E-MAIL','-CODE,GFX,CONCEPTION & DESIGN-','ALSO MEGACREDITS TO KPT&ADOBE','PETER','MY PARENTS'),
      ('PP709@CS.UTT.RO IF YOU''RE','KARG (AKA DICU STEFAN)','PHOTOSHOP4,LIGHTWAVE&TRUSPACE','ADI POP',
      '...AND EVERYONE I FORGOT !'),
      ('INTERESTED.AND ONE MORE THING:','-VIDEOCARD ACCES ROUTINES-','TASM&BORLAND PASCAL','TRAIAN',''),
      ('THIS DEMO IS FREEWARE.','TRISTAN TARRANT','','PAUL POP THE SWEDE',''),
      ('','','','DIDIS',''),
      ('','','','ALEX',''));

type
    TWWParticle = record
                  ang,anginc : integer;
                  rad,radinc : single;
                  p          : point3d;
                  clr        : byte;
                end;

var
   Whirl : array[1..MaxWWPart] of TWWParticle;
   TmpP  : point3d;
   DeltaInc : integer;
   TextColor : byte;
   PageLeft,PageRight : byte;
   j,i,midx,xdir    : integer;
   clr : integer;
   CurentPage : integer;

procedure UpDateWW(index : integer);
begin
  with Whirl[index] do
       begin
         ang := random(360);
         anginc := random(5)+1;
         rad := 0;
         radinc := random/3;
         p.y := 0;
         clr := random(53)+10;
       end;
end;

begin
  randomize;
  new(Pro);getmem(workpal,768);FillChar(WorkPal^,768,0);InitFont;
  EyePos.Z := 128;EyePos.Y := -10;
  Set320x240;
  InitSinCos;
  for i:=0 to 63 do
      begin
        TPal(WorkPal^)[i,1] := i;
        TPal(WorkPal^)[i,2] := i;
        TPal(WorkPal^)[i,3] := i;
      end;

  TPal(WorkPal^)[64,1] := 63;
  TPal(WorkPal^)[65,1] := 63;TPal(WorkPal^)[65,2] := 63;
  TPal(WorkPal^)[66,3] := 63;

  SetPal(WorkPal);
  for i:=1 to MaxWWPart do
      with Whirl[i] do
           begin
             ang := random(360);
             anginc := random(15)+1;
             rad := random(20);
             radinc := random/3;
             p.y := random(180);
             clr := random(53)+10;
           end;
  with Vi do begin x:=63;y:= 0;z:= 0;end;
  with Vj do begin x:= 0;y:=63;z:= 0;end;
  with Vk do begin x:= 0;y:= 0;z:=-63;end;
  with LightDir do begin x:=0;y:=0;z:=-63;end;
  Inverter(vi,vj,vk);midx := 620;xdir := -2;
  CurentPage := 1;PageLeft:=1;PageRight := 2;

  repeat
    SetActivePage(page);
    Cls(page,0);
    textcolor := 0;
    for i:=1 to 15 do
        begin
          FontColor(64+textcolor);
          textcolor := (textcolor+1) mod 3;
          ClipLt:=0;ClipRt := midx+longint(5)*longint(sintab[(i*32+deltainc) mod 360]) div 16384;
          for j:=1 to length(LastPages[i,PageLeft]) do
              FntScale(160-(10*length(LastPages[i,PageLeft])) div 2+10*(j-1),
                       120-15*11 div 2+(i-1)*12,11,11,
                       11,11,ActStart,MyFont[LastPages[i,PageLeft][j]]);

          ClipRt := 319;ClipLt := midx+longint(5)*longint(sintab[(i*32+deltainc) mod 360]) div 16384;
          for j:=1 to length(LastPages[i,PageRight]) do
              FntScale(160-(10*length(LastPages[i,PageRight])) div 2+10*(j-1),
                       120-11*15 div 2+(i-1)*12,11,11,
                       11,11,ActStart,MyFont[LastPages[i,PageRight][j]]);
        end;

    ClipLt := 0;ClipRt := 319;
    midx := midx +xdir;
    if (midx<-300) or (midx>620)
       then begin
              xdir := -xdir;
              inc(PageLeft);
              inc(PageRight);
              if PageRight>5 then PageRight:=1;
              if PageLeft>5 then PageLeft:=1;
              CurentPage := PageLeft;
              PageLeft := PageRight;
              PageRight := CurentPage;
            end;
    deltainc := (deltainc+2) mod 360;
    for i:=1 to MaxWWPart do
        with Whirl[i] do
             begin
               ang := (ang+anginc) mod 360;
               rad := rad+radinc;
               p.x := round(rad*costab[ang]/16384);
               p.z := round(rad*sintab[ang]/16384);
               inc(p.y);
               TmpP.x := p.x;TmpP.y := -p.y+90;TmpP.Z := p.z;
               if p.y>180 then UpDateWW(i);
               ProLookPoint(EyePos,TmpP);
               {if p.z<0 then clr := abs(p.z)*32 div 12+31
                  else clr := p.z*31 div 12;
               case ang of
                 0..89 : clr := (ang*63) div 90;
                 90..270 : clr := (ang-90)*63 div 180;
                 270..359 : clr := (ang-270)*63 div 90;
               end;}
               PutPixel_X(midx+Pro^[1].x+longint(25)*longint(sintab[(2*p.y+deltainc) mod 360]) div 16384,
                         120+Pro^[1].y,clr);
             end;
    SetVisiblePage(page);
    page := (page+1) mod 2;
  until false;
end.