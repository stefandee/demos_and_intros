{$M 64000,0,350000}
PROGRAM
       AMORPHIS;

USES
    MODULES,DOS,BITMAP,DETECT;

{$I SINCOS.INC}
{$I 3D.INC}
{$I MODEX.INC}
{$I FONT.INC}
{$I SCALE.INC}

TYPE
    TSpiral   = array[1..75,1..2] of integer;
    ProStyle  = (ProSimple,ProGeneral);
    TSandUp   = array[0..199,0..319] of byte; { just for overriding }
    TSandDown = array[200..239,0..319] of byte;
    PTMap     = ^TMap;
    TMap      = array[0..127,0..127] of byte;
    TPlasmaCos= array[0..255] of integer;
    PTPlasmaCos = ^TPlasmaCos;
    TData = array[0..166,0..166] of byte;
    PTData = ^TData;
    TWWParticle = record
                  ang,anginc : integer;
                  rad,radinc : single;
                  P          : point3d;
                  clr        : byte;
                end;

CONST
    { the first scroll }
    FirstScroll : string[200] = ' XEAH, HERE YE GO AGAIN, THIS TIME YITH A 64K DEMO. I HAD DECIDED TO LEAVE THE DEMO'+
                                ' SCENE AND START THE YORK FOR A GAME,BUT I''VE JUST FOUND SOME IDEAS...        ';
    LastText : array[1..4] of string[15] = ('PRODUCTION','AUGUST 1997.','CONTACT ME AT','PP709@CS.UTT.RO');
    ScrollIndex : integer = 1;
    ScanIndex   : integer = 0;
    ScrollStartX: integer = 0;
    CurrentX    : integer = 0;
    { the spiral }
    TubeColor   : byte    = 0;
    FirstColor  : byte    = 0;
    SpiralAngle : integer = 0;
    SpiralRing  : integer = 225;
    { 3D general defs }
    {RotAng      : array[1..1,1..3] of integer = ((90,0,0));}
    {RotDir      : array[1..1,1..3] of integer = ((1,1,1));}
    CrtObject   : byte = 0;
    { intermediate }
    XLen        : integer = 225;
    YLen        : integer = 39;
    { foot }
    FootDelay   : byte    = 1;
    FBSize      : byte    = 25;
    LRSize      : byte    = 13;
    StepSize    : byte    = 15;
    FootAhead   : boolean = true;
    MaskAction  : integer = 0;
    MaskRot     : array[1..3] of integer = (0,0,0);
    { map walk }
    ViewAng    : integer = 0;
    H          : integer = 0;
    W          : single  = 0.0;
    ShipAction : integer = 0;
    ShipRot : array[1..3] of integer = (0,0,0);
    StartMapY  : integer = 120;
    { transparency }
    TranAction : shortint = 0;
    { cube screes }
    CubeColor : array[0..2] of byte = (128,192,64);
    BackColor : array[0..2] of byte = (255,127,0);
    ScrAction : shortint = 0;
    { moire texture }
    MoireAction : integer = 0;
    MaxWWPart = 1000;
    LastPages : array[1..15,1..5] of string[30] =
    (('','','','BEST REGARDS TO:','BORLAND AKA VALER BOCAN'),
     ('','','','','JOHN'),
     ('HERE ENDS THIS DEMO...','THIS DEMO IS DEDICATED','-SCALING ROUTINE-','STELI','MARCEL HANCHES'),
     ('FROM NOY ON FOLLOYS THE','TO EVERXBODX THAT TORTURE','JOHN A. SLAGEL','SEBI','NELUTU PLESA'),
     ('CREDITS AND GREETINGS,','HIMSELF PROGRAMMING DATABASES,','-PLASMA FRACTAL ROUTINE-','MR. BABII,MR. DRAGOMIRESCU AND',
     'RADIO SKX CONSTANTA 101.1MHZ'),
     ('SO STAX TUNED. BUT BEFORE','IN FOWPRO,DBASE,PARADOW,DELPHI','THE STONE SOUP GROUP','EVERXONE OF BERG COMPUTERS',
     'DAN DANIEL'),
     ('HITTING ESC, XOU MUST KNOY','AND SO ON :-)','-SOUNDSXSTEM-','DORU TODINCA','THE FOOTBALL TEAM FC FARUL'),
     ('THAT I AM AVAILABLE FOR',' ','TSC SOFTYARE','BOGDAN OF TOTALDATA CONSTANTA','(GOOD LUCK, BOXS!)'),
     ('COMMERCIAL DEMOS, SO CALL','THE CREDITS:','''FAINTER'' THEME BX SOMEONE','ZOLX','CORINA'),
     ('041-623755 OR E-MAIL TO','-CODE,GFW,CONCEPTION & DESIGN-','ALSO MEGACREDITS TO KPT&ADOBE','PETER','STORM'),
     ('PP709@CS.UTT.RO IF XOU''RE','KARG (AKA DICU STEFAN)','PHOTOSHOP4,LIGHTYAVE&TRUSPACE','ADI POP',
     'MX PARENTS'),
     ('INTERESTED.AND ONE MORE THING:','-VIDEOCARD ACCES ROUTINES-','TASM&BORLAND PASCAL','TRAIAN',
     '...AND EVERXONE I FORGOT !'),
     ('THIS DEMO IS FREEYARE.','TRISTAN TARRANT','','PAUL POP THE SYEDE',''),
     ('','','','DIDIS',''),
     ('','','','ALEW',''));

VAR
   AnyModule   : MODDataRec;
   Int1CSave   : Pointer;
   Spiral      : pointer;
   Thorn       : pointer;
   Torus       : pointer;
   Mask        : pointer;
   Fighter     : pointer;
   Superq2     : pointer;
   Dod         : pointer;
   Cube        : pointer;
   Cone        : pointer;
   IcoDod      : pointer;
   SandUp      : ^TSandUp;
   SandDown    : ^TSandDown;
   i,j         : integer;
   xp,yp       : integer;
   x1,x2,x3,x4,
   y1,y2,y3,y4 : integer;
   midx,midy   : integer;
   dirx,diry   : integer;
   Lx,Ly,Rx,Ry : integer;
   C           : Point3D;
   Counter     : integer;
   WormRingColor : byte;
   Map         : PTMap;
   mapx,mapy   : integer;
   mx,my       : longint;
   Data        : PTData;
   a,adir      : integer;
   Whirl : array[1..MaxWWPart] of TWWParticle;
   TmpP  : point3d;
   DeltaInc : integer;
   TextColor : byte;
   PageLeft,PageRight : byte;

{$L spiral.obj}
{$F+}
procedure SpiralData;external;
{$F-}

{$L thorn.obj}
{$F+}
procedure ThornData;external;
{$F-}

{$L cube.obj}
{$F+}
procedure CubeData;external;
{$F-}

{$L cone.obj}
{$F+}
procedure ConeData;external;
{$F-}

{$L torus.obj}
{$F+}
procedure TorusData;external;
{$F-}

{$L dod.obj}
{$F+}
procedure DodData;external;
{$F-}

{$L icodod.obj}
{$F+}
procedure IcoDodData;external;
{$F-}

{$L superq2.obj}
{$F+}
procedure Superq2Data;external;
{$F-}

{$L mask.obj}
{$F+}
procedure MaskData;external;
{$F-}

{$L fighter.obj}
{$F+}
procedure FighterData;external;
{$F-}

{$F+,S-,W-}
procedure TimerHandler; interrupt;
  begin
    { Timer ISR }
    {*** Refer to DDK and DPMI Specs for creating ISR's ***}
    DrawEnabled := true;
  end;
{$F-,S+}

procedure SetTimerFreq(freq : word);
var
   FreqValue : longint;
begin
  if freq <> 0
     then begin
            FreqValue := $1234DD div freq;
            port[$43] := $34;
            port[$40] := FreqValue mod 256;
            port[$40] := FreqValue div 256;
          end
     else begin
            port[$43] := $34;
            port[$40] := 0;
            port[$40] := 0;
          end;
end;

procedure Render(index : integer;xv,yv,zv,xo,yo,zo : integer;cx,cy : integer;style : ProStyle;baseindex : byte);
var
   i : integer;
   tvi,tvj,tvk : TVector;
   Shade : longint;
begin
  {}
  tvi := vi;tvj := vj;tvk := vk;
  RotatePoint(Point3D(tvi),xv,yv,zv);
  RotatePoint(Point3D(tvj),xv,yv,zv);
  RotatePoint(Point3D(tvk),xv,yv,zv);
  Inverter(tvi,tvj,tvk);
  Move(Obj3D[index].ObjData^.Face,WorkObj^.Face,Obj3D[index].ObjData^.FC*sizeof(TFace3D));
  Move(Obj3D[index].ObjData^.Vertex,WorkObj^.Vertex,Obj3D[index].ObjData^.VC*sizeof(Point3D));
  RotateObj(xo,yo,zo,Obj3D[index].ObjData^.VC,Obj3D[index].ObjData^.FC);
  DepthSort(Obj3D[index].ObjData,EyePos,Obj3D[1].ObjPos);
  if style=ProSimple then ProLook(Obj3D[index].ObjData^.VC,EyePos,Obj3D[index].ObjPos);
  for i:=1 to Obj3D[index].ObjData^.FC do
      with WorkObj^.Face[i] do
           begin
             if DotProduct(N,tvk) >= 0
                then begin
                       Shade := DotProduct(N,LightDir);
                       if Shade>=0
                          then begin
                                 if Shade>63 then Shade := 63;
                                 Triangle(Pro^[p1].x+cx,Pro^[p1].y+cy,
                                          Pro^[p2].x+cx,Pro^[p2].y+cy,
                                          Pro^[p3].x+cx,Pro^[p3].y+cy,
                                          Shade+BaseIndex);
                                end;
                     end;
           end;
  {}
end;

procedure GenerateSand(basecolor : byte);
type
    TLine     = array[0..319] of integer;
var
   Psg,PsgAnt : TLine;
   i,j : integer;
begin
  randomize;
  getmem(SandUp,sizeof(TSandUp));
  getmem(SandDown,sizeof(TSandDown));
  for i:=0 to 319 do PsgAnt[i] := random(48);
  for j:=0 to 239 do
      for i:=0 to 319 do
          begin
            Psg[i] := (2*PsgAnt[i]+7*PsgAnt[i+1]) div 9+random(2);
            if Psg[i]>63 then Psg[i] := 63-random(5);
            if Psg[i]<0 then Psg[i] := random(5);
            PsgAnt[i] := Psg[i];
            case j of
              0..199   : TSandUp(SandUp^)[j,i] := psg[i]+basecolor;
              200..239 : TSandDown(SandDown^)[j,i] := psg[i]+basecolor;
            end;
         end;
end;

procedure GeneratePlasmaMap(grainess : integer);

procedure Adjust(xa,ya,x,y,xb,yb : integer);
var
   ps : single;
begin
  if Map^[x,y] <> 0 then exit;
  ps := (32767*random-16383)*grainess;
  ps := ps*(abs(xb-xa)+abs(yb-ya));
  ps := round(ps/262144);
  ps := longint(Map^[xa,ya]+Map^[xb,yb]+1) div 2 + ps;
  if ps>63 then ps := 63;
  if ps<1 then ps := 1;
  Map^[x,y] := round(ps);
end;

procedure SubDivide(x1,y1,x2,y2 : integer);
var
   x,y : integer;
begin
  if ((x2-x1)<2) and ((y2-y1)<2) then exit;
  x := (x1+x2) div 2;y := (y1+y2) div 2;
  Adjust(x1,y1,x ,y1,x2,y1);
  Adjust(x2,y1,x2,y ,x2,y2);
  Adjust(x1,y2,x ,y2,x2,y2);
  Adjust(x1,y1,x1,y ,x1,y2);
  if Map^[x,y] = 0 then
     begin
       Map^[x,y] := ((Map^[x1,y1]+Map^[x2,y1]+Map^[x2,y2]+Map^[x1,y2]+2) div 4);
       if Map^[x,y]>63 then Map^[x,y] := 63-random(Map^[x,y]-63);
     end;
  SubDivide(x1,y1,x ,y);
  SubDivide(x ,y1,x2,y);
  SubDivide(x ,y ,x2,y2);
  SubDivide(x1,y ,x ,y2);
end;

begin
  Map^[0,0] := 1+longint(longint(random(32768))*longint(63) div 64 div longint(128));
  Map^[0,127] := 1+longint(longint(random(32768))*longint(63) div 64 div longint(128));
  Map^[127,0] := 1+longint(longint(random(32768))*longint(63) div 64 div longint(128));
  Map^[127,127] := 1+longint(longint(random(32768))*longint(63) div 64 div longint(128));
  SubDivide(0,0,127,127);
end;

procedure FastMoire(a : integer);
var
   x,y,i,j : integer;
   c         : byte;
begin
  x := a;
  for i:=0 to 83 do
      begin
        x := x+a;
        y := x;
        for j:=i to 83 do
            begin
              y := y+a;
              asm
                db $66
                mov ax,x
                db $66
                mul ax
                db $66
                mov bx,ax
                db $66
                mov ax,y
                db $66
                mul ax
                db $66
                add bx,ax
                db $66
                shr bx,11
                and bl,63
                mov c,bl
              end;
              Data^[83+i,83+j] := c;
              Data^[83-i,83+j] := c;
              Data^[83+i,83-j] := c;
              Data^[83-i,83-j] := c;
              Data^[83+j,83+i] := c;
              Data^[83-j,83+i] := c;
              Data^[83+j,83-i] := c;
              Data^[83-j,83-i] := c;
            end;
      end;
end;

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

label
     theend,shunt,sh2;

BEGIN
  if MemAvail<200000
     then begin
            Writeln('Not enough memory.');
            Halt;
          end;
  { setup mod player }
  MixSpeed := 11025;
  LoadMOD('AMORPHIS.EXE', 43916, AnyModule);
  if ErrorInfo = 1
     then begin
            WriteLn('Error loading module.');
            WriteLn;
            Halt(1);
          end;
  {PlayMOD(AnyModule);}
  { end setup mod player - by now, music should be heard }

  { begin all kind of setups }
  InitSinCos;
  InitFont;
  Spiral := Addr(SpiralData);
  Title := Addr(TitleData);
  AnimFoot01 := Addr(AnimFootData01);
  Thorn := Addr(ThornData);Mask := Addr(MaskData);Dod := Addr(DodData);
  IcoDod := Addr(IcoDodData);Superq2 := Addr(Superq2Data);Torus := Addr(TorusData);
  Fighter := Addr(FighterData);Cube := Addr(CubeData);Cone := Addr(ConeData);
  new(Obj3D[1].ObjData);new(WorkObj);new(Pro);
  GetMem(workpal,768);
  GetMem(tmppal,768);
  Randomize;

  SetTimerFreq(60);
  GetIntVec($1C,Int1CSave);
  SetIntVec($1C,Addr(TimerHandler));

  Set320x240;
  { end }
  {goto shunt;}
  { do the preparings for the first roll }
  XRectFill(ClipRt-(ClipRt-ClipLt) div 2,ClipTp,ClipRt,ClipBt,1);
  XRectFill(ClipLt,ClipTp,ClipLt+(ClipRt-ClipLt) div 2+1,ClipBt,2);
  for i:=0 to 63 do
      begin
        SetRGB(1,i,i,i);
        SetRGB(2,i,i,i);
        repeat until DrawEnabled = true;
        DrawEnabled := false;
      end;

  for i:=63 downto 0 do
      begin
        SetRGB(1,i,i,i);
        repeat until DrawEnabled = true;
        DrawEnabled := false;
      end;

  SetRGB(255,63,63,63);
  repeat
    ScanIndex := ScrollIndex;
    CurrentX := ScrollStartX;
    SetActivePage(page);
    Cls(page,0);
    XRectFill(0,ClipTp,160,ClipBt,2);
    repeat
      ClipRt := 319;
      ClipLt := 160;
      FontColor(255);
      FntScale(CurrentX,120-88,16*11,16*11,11,11,ActStart,MyFont[FirstScroll[ScanIndex]]);

      FontColor(1);
      ClipLt := 0;
      ClipRt := 160;
      FntScale(CurrentX,120-88,16*11,16*11,11,11,ActStart,MyFont[FirstScroll[ScanIndex]]);
      ClipRt := 319;
      CurrentX := CurrentX + XFontSize*16;
      inc(ScanIndex);
    until CurrentX>=ClipRt;

    dec(ScrollStartX,14);
    if ScrollStartX<=-XFontSize*16
       then begin
              ScrollStartX := ScrollStartX+XFontSize*16;
              inc(ScrollIndex);
            end;

    repeat until DrawEnabled;
    DrawEnabled := false;
    SetVisiblePage(page);
    page := (page+1) mod 2;
  until ScrollIndex>=length(FirstScroll)-1;

  for i:=63 downto 0 do
      begin
        SetRGB(2,i,i,i);
        repeat until DrawEnabled = true;
        DrawEnabled := false;
      end;

  Cls(0,0);Cls(1,0);
  if SBData.CardType<>None then PlayMod(AnyModule);
  SetTimerFreq(45);
  SetRGB(255,0,15,63);
  SetRGB(254,63,63,63);
  SetRGB(253,0,0,0);
  repeat
    FirstColor := (FirstColor+1) mod 2;
    dec(SpiralAngle,10);
    if SpiralAngle<0 then SpiralAngle:= 360+SpiralAngle;
    TubeColor := FirstColor;
    SetActivePage(page);
    for i:=10 to 75 do
        begin
          xp := longint(longint(TSpiral(Spiral^)[i,1])*longint(costab[SpiralAngle])-
                longint(TSpiral(Spiral^)[i,2])*longint(sintab[SpiralAngle])) shr 14;
          yp := longint(longint(TSpiral(Spiral^)[i,1])*longint(sintab[SpiralAngle])+
                longint(TSpiral(Spiral^)[i,2])*longint(costab[SpiralAngle])) shr 14;
          x1 := 160+xp;y1:=120+yp;
          x2 := 160-yp;y2:=120+xp;
          x3 := 160-xp;y3:=120-yp;
          x4 := 160+yp;y4:=120-xp;
          if (SpiralRing<=75) and (i>=SpiralRing)
             then begin
                    Triangle(x1,y1,x2,y2,x3,y3,254);
                    Triangle(x1,y1,x3,y3,x4,y4,254);
                  end
             else if 75-i>225-SpiralRing
                     then begin
                            Triangle(x1,y1,x2,y2,x3,y3,253);
                            Triangle(x1,y1,x3,y3,x4,y4,253);
                          end
                     else begin
                            Triangle(x1,y1,x2,y2,x3,y3,255-TubeColor);
                            Triangle(x1,y1,x3,y3,x4,y4,255-TubeColor);
                          end;
          TubeColor := (TubeColor+1) mod 2;
        end;
    repeat until DrawEnabled;
    DrawEnabled := false;
    SetVisiblePage(page);
    page := (page+1) mod 2;
    dec(SpiralRing);
    asm
      in al,$60
      dec al
      je theend;
    end;
  until SpiralRing<=0;

{shunt:}
  FillChar(WorkPal^,768,63);
  SetPal(WorkPal);
  Cls(0,0);SetActivePage(0);SetVisiblePage(0);
  XScale1(48,100,225,39,225,39,ActStart,Title);
  FillChar(TmpPal^,768,63);
  PalMorph(TmpPal,Addr(TitlePalData),1);
  ScaleFactor := 4;
  InitObj(Thorn,Obj3D[1].ObjData);
  with EyePos do begin x := 0;y := 0;z := 256; end;
  {with EyeDir do begin x := 0;y := 0;z := -63; end;}
  with Center do begin x := 0;y := 0;z := 0;end;
  with LightPos do begin x:=0;y:=0;z:=-150;end;
  with LightDir do begin x:=0;y:=0;z:=-63;end;
  with Vi do begin x:=63;y:= 0;z:= 0;end;
  with Vj do begin x:= 0;y:=63;z:= 0;end;
  with Vk do begin x:= 0;y:= 0;z:=-63;end;
  Obj3D[1].ObjPos.z := 140;

  MidX := 400;Midy := 120;DirX := -3;

  repeat
    SetActivePage(page);
    Cls(page,0);
    Obj3D[1].Ang.X := (Obj3D[1].Ang.X+3) mod 360;
    Obj3D[1].Ang.Y := (Obj3D[1].Ang.X+2) mod 360;
    Render(1,0,0,0,Obj3D[1].Ang.X,Obj3D[1].Ang.Y,Obj3D[1].Ang.X,midx,midy,ProSimple,0);
    XScale1(48,100,225,39,225,39,ActStart,Title);
    repeat until DrawEnabled;
    DrawEnabled := false;
    SetVisiblePage(page);
    page := (page+1) mod 2;
    midx := midx + Dirx;
    if (midx<-100) or (midx>400)
       then begin
              inc(CrtObject);
              case CrtObject of
                1 : InitObj(Dod,Obj3D[1].ObjData);
                2 : InitObj(Torus,Obj3D[1].ObjData);
                3 : InitObj(Superq2,Obj3D[1].ObjData);
              end;
              dirx := dirx*(-1);
            end;
    asm
      in al,$60
      dec al
      je theend;
    end;
  until CrtObject>3;

  repeat
    SetActivePage(page);
    Cls(page,0);
    inc(XLen,64);
    inc(YLen,16);
    XScale1(160-XLen div 2,120-YLen div 2,XLen,YLen,225,39,ActStart,Title);
    repeat until DrawEnabled;
    DrawEnabled := false;
    SetVisiblePage(page);
    page := (page+1) mod 2;
    asm
      in al,$60
      dec al
      je theend;
    end;
  until XLen>8000;

  { mask in the sand }
  FillChar(TmpPal^,768,63);
  PalMorph(Addr(TitlePalData),TmpPal,1);
  Cls(0,0);SetActivePage(0);SetVisiblePage(0);page := 1;
  ScaleFactor := 2;
  InitObj(Mask,Obj3D[1].ObjData);
  {FillChar(RotAng,Sizeof(RotAng),0);}
  GenerateSand(0);
  XScale1(0,0,320,200,320,200,ActStart,SandUp);
  XScale1(0,200,320,40,320,40,ActStart,SandDown);
  FillChar(TmpPal^,768,63);
  PalMorph(TmpPal,Addr(MaskPalData),1);
  { steps on the sand }
  x1 := -20;y1 := 235;
  repeat
    SetActivePage(page);
    Cls(page,0);
    XScale1(0,0,320,200,320,200,ActStart,SandUp);
    XScale1(0,200,320,40,320,40,ActStart,SandDown);
    dec(FootDelay);
    if FootDelay<=0
       then begin
              inc(x1,StepSize);dec(y1,StepSize);
              FootDelay := 5;
              FootAhead := not FootAhead;
              case FootAhead of
                true  : begin Lx := x1;Ly:=y1;Rx := x1+LRSize+StepSize;Ry := y1+LRSize-StepSize; end;
                false : begin Lx := x1+StepSize;Ly:=y1-StepSize;Rx := x1+LRSize;Ry := y1+LRSize; end;
              end;
            end;
    XScale1(Lx,Ly,9,10,9,10,ActStart,AnimFoot01);
    XScale1(Lx-FBSize,Ly+FBSize,9,10,9,10,ActStart,AnimFoot01);
    XScale1(Rx,Ry,9,10,9,10,ActStart,AnimFoot01);
    XScale1(Rx-FBSize,Ry+FBSize,9,10,9,10,ActStart,AnimFoot01);

    repeat until DrawEnabled;
    DrawEnabled := false;
    SetVisiblePage(page);
    page := (page+1) mod 2;
    asm
      in al,$60
      dec al
      je theend;
    end;
  until (x1>380) or (y1<-100);

  { time for mask action ! }
  midx := 160;midy := 120;
  Obj3D[1].ObjPos.z := 0;Obj3D[1].Ang.X := 90;EyePos.Z := 256;
  Obj3D[1].Ang.Y:=0;Obj3D[1].Ang.Z := 180;Obj3D[1].Ang.X := 90;
  Obj3D[1].SupAng := Center;
  with Vi do begin x:=63;y:= 0;z:= 0;end;
  with Vj do begin x:= 0;y:=63;z:= 0;end;
  with Vk do begin x:= 0;y:= 0;z:=-63;end;
  Inverter(vi,vj,vk);

  repeat
    SetActivePage(page);
    Cls(page,0);
    XScale1(0,0,320,200,320,200,ActStart,SandUp);
    XScale1(0,200,320,40,320,40,ActStart,SandDown);
    Move(Obj3D[1].ObjData^.Face,WorkObj^.Face,Obj3D[1].ObjData^.FC*sizeof(TFace3D));
    Move(Obj3D[1].ObjData^.Vertex,WorkObj^.Vertex,Obj3D[1].ObjData^.VC*sizeof(Point3D));
    RotateObj(Obj3D[1].Ang.X,Obj3D[1].Ang.Y,Obj3D[1].Ang.Z,Obj3D[1].ObjData^.VC,Obj3D[1].ObjData^.FC);
    DepthSort(Obj3D[1].ObjData,Obj3D[1].ObjPos,EyePos);
    ProLook(Obj3D[1].ObjData^.VC,EyePos,Obj3D[1].ObjPos);
    for i:=1 to Obj3D[1].ObjData^.FC do
        with WorkObj^.Face[i] do
             begin
               if EyeDist<200
                 then begin
                        C.x := (Pro^[p1].x+Pro^[p2].x+Pro^[p3].x) div 3+midx;
                        C.y := (Pro^[p1].y+Pro^[p2].y+Pro^[p3].y) div 3+midy;
                        if C.y>=200 then Color := TSandDown(SandDown^)[C.y,C.x]
                           else Color := TSandUp(SandUp^)[C.y,C.x];
                        if (C.y>239) then Color := TSandDown(SandDown^)[239,C.x];
                        if (C.y<0) then Color := TSandUp(SandUp^)[0,C.x];
                        Triangle(Pro^[p1].x+midx,Pro^[p1].y+midy,
                                 Pro^[p2].x+midx,Pro^[p2].y+midy,
                                 Pro^[p3].x+midx,Pro^[p3].y+midy,
                                 Color+64);
                      end
             end;
    repeat until DrawEnabled;
    DrawEnabled := false;
    SetVisiblePage(page);
    page := (page+1) mod 2;
    case MaskAction of
      0 : begin
            inc(Obj3D[1].ObjPos.z,3);
            if Obj3D[1].ObjPos.z>120 then inc(MaskAction);
          end;
      1 : begin
            Obj3D[1].SupAng.Z := (Obj3D[1].SupAng.Z+5) mod 360;
            Obj3D[1].SupAng.X := (Obj3D[1].SupAng.X+9) mod 360;
            Obj3D[1].Ang.Z := 180+longint(longint(20)*longint(sintab[Obj3D[1].SupAng.Z])) shr 14;
            Obj3D[1].Ang.X := 90+longint(longint(30)*longint(sintab[Obj3D[1].SupAng.X])) shr 14;
            if Obj3D[1].Ang.Z<0 then Obj3D[1].Ang.Z := 360+Obj3D[1].Ang.Z;
            if Obj3D[1].Ang.X<0 then Obj3D[1].Ang.X := 360+Obj3D[1].Ang.X;
            inc(Counter);
            if Counter>150 then inc(MaskAction);
          end;
      2 : begin
            if Obj3D[1].SupAng.Z <>0 then Obj3D[1].SupAng.Z := (Obj3D[1].SupAng.Z+5) mod 360;
            if Obj3D[1].SupAng.X <>0 then Obj3D[1].SupAng.X := (Obj3D[1].SupAng.X+9) mod 360;
            Obj3D[1].Ang.Z := 180+longint(longint(20)*longint(sintab[Obj3D[1].SupAng.Z])) shr 14;
            Obj3D[1].Ang.X := 90+longint(longint(30)*longint(sintab[Obj3D[1].SupAng.X])) shr 14;
            if Obj3D[1].Ang.Z<0 then Obj3D[1].Ang.Z := 360+Obj3D[1].Ang.Z;
            if Obj3D[1].Ang.X<0 then Obj3D[1].Ang.X := 360+Obj3D[1].Ang.X;
            if (Obj3D[1].Ang.Z=180) and (Obj3D[1].Ang.X=90) then inc(MaskAction);
          end;
      3 : begin
            if Obj3D[1].Ang.X<270 then inc(Obj3D[1].Ang.X,5);
            if Obj3D[1].Ang.Y<180 then inc(Obj3D[1].Ang.Y,5);
            if (Obj3D[1].Ang.Y=180) and (Obj3D[1].Ang.X=270) then inc(MaskAction);
          end;
      4 : begin
            inc(Obj3D[1].ObjPos.z,4);
            if Obj3D[1].ObjPos.z>200 then inc(MaskAction);
          end;
    end;
    asm
      in al,$60
      dec al
      je theend;
    end;
  until MaskAction = 5;
  Dispose(SandUp);Dispose(SandDown);
{shunt:}
  FillChar(tmppal^,768,63);
  PalMorph(Addr(MaskPalData),tmppal,1);
  Cls(0,0);Cls(1,0);SetActivePage(0);SetVisiblePage(0);
  FillChar(TmpPal^,768,0);
  for i:=0 to 15 do
      begin
        TPal(TmpPal^)[i+96+1,1] := 63-i*4+3;
        TPal(TmpPal^)[i+16+1,2] := 63-i*4+3;
        TPal(TmpPal^)[i+32+1,3] := 63-i*4+3;
        TPal(TmpPal^)[i+48+1,1] := 63-i*4+3;TPal(TmpPal^)[i+48+1,2] := 63-i*4+3;
        TPal(TmpPal^)[i+64+1,1] := 63-i*4+3;TPal(TmpPal^)[i+64+1,3] := 63-i*4+3;
        TPal(TmpPal^)[i+80+1,2] := 63-i*4+3;TPal(TmpPal^)[i+80+1,3] := 63-i*4+3;
        TPal(TmpPal^)[i+1,1] := 63-i*4+3;TPal(TmpPal^)[i+1,3] := 63-i*4+3;TPal(TmpPal^)[i+1,2] := 63-i*4+3;
      end;

  SetPal(TmpPal);
  { time for wormie !!!}
  {SetTimerFreq(60);}
  midx := 28;midy := 28;dirx := 8; diry := 8;
  Counter := 500;WormRingColor := 0;

  repeat
    inc(WormRingColor);
    midx := midx + dirx;
    if midx-24<=8 then dirx := -dirx;
    if midx+24>=310 then dirx := -dirx;
    midy := midy + diry;
    if midy-24<=8 then diry := -diry;
    if midy+24>=231 then diry := -diry;
    XFilledCircle(midx-24,midy-24,48,WormRingColor);
    PalRot(TmpPal,1,108);
    SetPal(TmpPal);
    repeat until DrawEnabled;
    DrawEnabled := false;
    dec(Counter);
    if WormRingColor>107 then WormRingColor := 0;
    asm
      in al,$60
      dec al
      je theend;
    end;
  until Counter<=0;

  FillChar(WorkPal^,768,0);
  PalMorph(TmpPal,WorkPal,1);

{shunt:}
  { peisage walk }
  Cls(0,0);Cls(1,0);SetActivePage(0);page:=1;
  FillChar(WorkPal^,768,0);
  for i:=0 to 63 do
      begin
        TPal(WorkPal^)[i,2] := i;
        TPal(WorkPal^)[i+64,1] := i;TPal(WorkPal^)[i+64,2] := i;TPal(WorkPal^)[i+64,3] := i;
        TPal(WorkPal^)[i+192,1] := i;
        TPal(WorkPal^)[i+128,3] := i;
      end;
  SetPal(WorkPal);
  {goto sh2;}
  ScaleFactor := 2;
  InitObj(Fighter,Obj3D[1].ObjData);
  new(Map);FillChar(Map^,sizeof(Map^),0);
  GeneratePlasmaMap(32);

  Obj3D[1].ObjPos.z := -64;EyePos.Z := 256;
  with Vi do begin x:=63;y:= 0;z:= 0;end;
  with Vj do begin x:= 0;y:=63;z:= 0;end;
  with Vk do begin x:= 0;y:= 0;z:=-63;end;
  with LightDir do begin x:=0;y:=0;z:=-63;end;
  Inverter(vi,vj,vk);
  mapx := 64;mapy := 16;ViewAng := 270;
  ShipAction := 0;midx := 160;midy := -72;
  Obj3D[1].Ang.X := 190;Obj3D[1].Ang.Y := 0;Obj3D[1].Ang.Z := 0;
  Obj3D[1].SupAng := Center;

  repeat
    SetActivePage(page);
    Cls(page,0);
    XRectFill(0,0,320,StartMapY,191);
    case ShipAction of
      0 : begin
            inc(Obj3D[1].ObjPos.z,2);
            inc(midy,2);
            inc(Obj3D[1].Ang.X);
            if Obj3D[1].ObjPos.z>=128
               then begin
                      inc(ShipAction);
                      Obj3D[1].Ang.Y := 0;
                      Obj3D[1].Ang.Z := 359;
                    end;
          end;
      1 : begin
            if Obj3D[1].Ang.X>255 then dec(Obj3D[1].Ang.X);
            Obj3D[1].SupAng.Y := (Obj3D[1].SupAng.Y+5) mod 360;
            Obj3D[1].Ang.Y := longint(longint(40)*longint(sintab[Obj3D[1].SupAng.Y])) shr 14;
            if Obj3D[1].Ang.Y<0 then Obj3D[1].Ang.Y := 360+Obj3D[1].Ang.Y;
            {dec(Obj3D[1].Ang.Y);
            if Obj3D[1].Ang.Y<0 then Obj3D[1].Ang.Y := 360+Obj3D[1].Ang.Y;}
            inc(ViewAng,5);
            ViewAng := ViewAng mod 360;
            if ViewAng<0 then ViewAng := 360+ViewAng;
            mapy := mapy - longint(2)*longint(sintab[ViewAng]) shr 14;
            if mapy>80 then inc(ShipAction);
          end;
      2 : begin
            inc(Obj3D[1].Ang.X,5);
            if Obj3D[1].Ang.X>352 then inc(ShipAction);
            if not (Obj3D[1].Ang.Y in [179..181]) then inc(Obj3D[1].Ang.Y,2);
            if ((ViewAng<265) or (ViewAng>275)) then inc(ViewAng,3);
            ViewAng := ViewAng mod 360;
            dec(midy,3);
            inc(mapy);
          end;
      3 : begin
            inc(Obj3D[1].Ang.X,5);
            if Obj3D[1].Ang.X>450 then inc(ShipAction);
            if not (Obj3D[1].Ang.Y in [179..181]) then inc(Obj3D[1].Ang.Y,2);
            if ((ViewAng<265) or (ViewAng>275)) then inc(ViewAng,3);
            ViewAng := ViewAng mod 360;
            inc(midy,3);
            inc(mapy);
          end;
      4 : begin
            dec(mapy);
            if mapy<50 then inc(ShipAction);
            if not (Obj3D[1].Ang.Y in [179..181]) then inc(Obj3D[1].Ang.Y,2);
            if ((ViewAng<265) or (ViewAng>275)) then inc(ViewAng,3);
            ViewAng := ViewAng mod 360;
            dec(midy);
          end;
      5 : begin
            dec(Obj3D[1].ObjPos.z,8);
            dec(midy);
            if mapy>10 then dec(mapy);
            if midy<-30 then inc(ShipAction);
            Obj3D[1].Ang.X := Obj3D[1].Ang.X mod 360;
            if Obj3D[1].Ang.X>0 then dec(Obj3D[1].Ang.X,2);
            if Obj3D[1].Ang.X<0 then Obj3D[1].Ang.X := 0;
          end;
      6 : begin
            inc(StartMapY,3);
            if StartMapY>239+64 then inc(ShipAction);
          end;
    end;
    for j:=11 downto 0 do
        begin
          W := 320/(33+2*j)+1;
          for i:=(-16-j) to (16+j) do
              begin
                mx := longint(j)*longint(costab[ViewAng])-longint(i)*longint(sintab[ViewAng]);
                my := longint(j)*longint(sintab[ViewAng])+longint(i)*longint(costab[ViewAng]);
                mx := mx div 16384 + mapx;
                my := my div 16384 + mapy;
                if (mx<0) or (mx>127) or (my<0) or (my>127) then H := 0
                   else H := Map^[my,mx];
                XRectFill(160+round(i*W),StartMapY-H+(11-j)*10,160+round((i+1)*W),StartMapY+(11-j)*10,Map^[my,mx]);
              end;
       end;
    Render(1,0,0,0,Obj3D[1].Ang.X,Obj3D[1].Ang.Y,Obj3D[1].Ang.Z,midx,midy,ProSimple,64);
    repeat until DrawEnabled;
    DrawEnabled := false;
    SetVisiblePage(page);
    page := (page+1) mod 2;
    asm
      in al,$60
      dec al
      je theend;
    end;
  until ShipAction>6;

  dispose(Map);
  { transparency ! , the pallete is the same below}
{sh2:}
  new(Obj3D[2].ObjData);
  ScaleFactor := 5;
  InitObj(Cube,Obj3D[2].ObjData);
  InitObj(IcoDod,Obj3D[1].ObjData);
  Obj3D[1].ObjPos.Z := 110;Obj3D[2].ObjPos.Z := -500;
  Obj3D[1].Ang := Center;Obj3D[2].Ang := Center;
  MidY := -120;MidX := 160;
  EyePos.Z := 256;
  with Vi do begin x:=63;y:= 0;z:= 0;end;
  with Vj do begin x:= 0;y:=63;z:= 0;end;
  with Vk do begin x:= 0;y:= 0;z:=-63;end;
  with LightDir do begin x:=0;y:=0;z:=-63;end;
  Inverter(vi,vj,vk);
  Counter := 0;

  repeat
    SetActivePage(page);
    Cls(page,191);

    Obj3D[1].Ang.X := (Obj3D[1].Ang.X+2) mod 360;
    Obj3D[1].Ang.Y := (Obj3D[1].Ang.Y+1) mod 360;
    Obj3D[2].Ang.X := (Obj3D[2].Ang.X+1) mod 360;
    Obj3D[2].Ang.Z := (Obj3D[2].Ang.Z+2) mod 360;

    case TranAction of
      0 : begin
            inc(midy,2);
            if midy>=120 then inc(TranAction);
          end;
      1 : begin
            inc(Obj3D[2].ObjPos.Z,10);
            if Obj3D[2].ObjPos.Z>=80 then inc(TranAction);
          end;
      2 : begin
            inc(Counter);
            if Counter>850
               then begin
                      inc(TranAction);
                      Counter := 0;
                    end;
          end;
      3 : begin
            dec(Obj3D[2].ObjPos.Z,10);
            if Obj3D[2].ObjPos.Z<=-500
               then begin
                      InitObj(Cone,Obj3D[2].ObjData);
                      inc(TranAction);
                    end;
          end;
      4 : begin
            inc(Obj3D[2].ObjPos.Z,10);
            if Obj3D[2].ObjPos.Z>=80 then inc(TranAction);
          end;
      5 : begin
            inc(Counter);
            if Counter>850 then inc(TranAction);
          end;
      6 : begin
            dec(Obj3D[2].ObjPos.Z,10);
            if Obj3D[2].ObjPos.Z<=-500 then inc(TranAction);
          end;
      7 : begin
            inc(midy,2);
            if midy>=240+120 then inc(TranAction);
          end;
    end;

    if TranAction in [1..6] then Render(2,0,0,0,Obj3D[2].Ang.X,Obj3D[2].Ang.Y,Obj3D[2].Ang.Z,160,120,ProSimple,64);
    Render(1,0,0,0,Obj3D[1].Ang.X,Obj3D[1].Ang.Y,Obj3D[1].Ang.X,midx,midy,ProSimple,192);

    repeat until DrawEnabled;
    DrawEnabled := false;
    SetVisiblePage(page);
    page := (page+1) mod 2;
    asm
      in al,$60
      dec al
      je theend;
    end;
    inc(Counter);
  until TranAction>7;

  { bye bye !!! }
  InitObj(Cube,Obj3D[1].ObjData);
  Obj3D[1].ObjPos.Z := 175;Counter := 0;

  repeat
    SetActivePage(page);
    Cls(page,BackColor[ScrAction]);

    Obj3D[1].Ang.X := (Obj3D[1].Ang.X+2) mod 360;
    dec(Obj3D[1].ObjPos.Z);
    case ScrAction of
      0..1 : begin
            if Obj3D[1].ObjPos.Z<-100
               then begin
                      inc(ScrAction);
                      Obj3D[1].Ang.X := 0;
                      Obj3D[1].ObjPos.Z := 175;
                    end;
          end;
     1 : begin
           if (Obj3D[1].Ang.X = 90) then inc(ScrAction);
         end;
     2 : begin
           Line_X(77,37,243,37,127);
           Line_X(77,203,243,203,127);
           Line_X(77,37,77,203,127);
           Line_X(243,37,243,203,127);
           if Obj3D[1].ObjPos.Z<-400 then inc(ScrAction);
         end;
    end;
    Render(1,0,0,0,Obj3D[1].Ang.X,0,0,160,120,ProSimple,CubeColor[ScrAction]);
    repeat until DrawEnabled;
    DrawEnabled := false;
    SetVisiblePage(page);
    page := (page+1) mod 2;
    asm
      in al,$60
      dec al
      je theend;
    end;
  until ScrAction>2;

  { moire texture }
  for i:=0 to 31 do
      begin
        TPal(WorkPal^)[i,1]:=i*2;
        TPal(WorkPal^)[i,2]:=i*2;
        TPal(WorkPal^)[i,3]:=0;
        TPal(WorkPal^)[i+32,1]:=(32-i)*2;
        TPal(WorkPal^)[i+32,2]:=(32-i)*2;
        TPal(WorkPal^)[i+32,3]:=0;
      end;
  SetPal(WorkPal);
  MidX := 359;Counter := 0;Midy := 120-83;
  ClipRt := 243;ClipLt := 77;ClipTp:=37;ClipBt:=203;
  new(Data);

  repeat
    SetActivePage(page);
    Cls(page,0);

    inc(a,adir);
    if a>53 then adir := -1;
    if a<=5 then adir := 1;
    FastMoire(a);

    XScale1(midx,midy,167,167,167,167,ActStart,Ptr(Seg(Data^),Ofs(Data^)));
    Line_X(ClipLt,ClipTp,ClipRt,ClipTp,127);
    Line_X(ClipLt,ClipBt,ClipRt,ClipBt,127);
    Line_X(ClipLt,ClipTp,ClipLt,ClipBt,127);
    Line_X(ClipRt,ClipTp,ClipRt,ClipBt,127);

    case MoireAction of
     0 : begin
           dec(MidX,3);
           if MidX=77 then inc(MoireAction);
         end;
     1 : begin
           inc(Counter);
           if Counter=500 then inc(MoireAction);
         end;
     2 : begin
           inc(midy);
           if midy>ClipBt then inc(MoireAction);
         end;
     3 : begin
           inc(ClipLt);dec(ClipRt);
           inc(ClipTp);dec(ClipBt);
           if ClipLt=ClipRt then inc(MoireAction);
         end;
    end;

    repeat until DrawEnabled;
    DrawEnabled := false;
    SetVisiblePage(page);
    page := (page+1) mod 2;
    asm
      in al,$60
      dec al
      je theend;
    end;
  until MoireAction>3;
  dispose(Data);
  ClipLt := 0;ClipRt:=319;ClipTp := 0;ClipBt := 239;

  { ...and now,the final one - whirlwind & greetings !}
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

  EyePos.Z := 128;EyePos.Y := -10;
  with Vi do begin x:=63;y:= 0;z:= 0;end;
  with Vj do begin x:= 0;y:=63;z:= 0;end;
  with Vk do begin x:= 0;y:= 0;z:=-63;end;
  with LightDir do begin x:=0;y:=0;z:=-63;end;
  Inverter(vi,vj,vk);midx := 420;dirx := -2;
  PageLeft:=0;PageRight := 1;

  repeat
    SetActivePage(page);
    Cls(page,0);
    textcolor := 0;
    for i:=1 to 15 do
        begin
          FontColor(64+textcolor);
          textcolor := (textcolor+1) mod 3;
          ClipLt:=0;ClipRt := midx+longint(5)*longint(sintab[(i*32+deltainc) mod 360]) div 16384;
          if PageLeft>0 then
          for j:=1 to length(LastPages[i,PageLeft]) do
              FntScale(160-(10*length(LastPages[i,PageLeft])) div 2+10*(j-1),
                       120-15*11 div 2+(i-1)*12,11,11,
                       11,11,ActStart,MyFont[LastPages[i,PageLeft][j]]);

          ClipRt := 319;ClipLt := midx+longint(5)*longint(sintab[(i*32+deltainc) mod 360]) div 16384;
          if PageRight>0 then
          for j:=1 to length(LastPages[i,PageRight]) do
              FntScale(160-(10*length(LastPages[i,PageRight])) div 2+10*(j-1),
                       120-11*15 div 2+(i-1)*12,11,11,
                       11,11,ActStart,MyFont[LastPages[i,PageRight][j]]);
        end;

    ClipLt := 0;ClipRt := 319;
    midx := midx +dirx;
    if (midx<-300) or (midx>620)
       then begin
              dirx := -dirx;
              inc(PageLeft);
              inc(PageRight);
              if PageRight>5 then PageRight:=1;
              if PageLeft>5 then PageLeft:=1;
              i := PageLeft;
              PageLeft := PageRight;
              PageRight := i;
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
               PutPixel_X(midx+Pro^[1].x+longint(25)*longint(sintab[(2*p.y+deltainc) mod 360]) div 16384,
                         120+Pro^[1].y,clr);
             end;
    repeat until DrawEnabled;
    DrawEnabled := false;
    SetVisiblePage(page);
    page := (page+1) mod 2;
    asm
      in al,$60
      dec al
      je theend;
    end;
  until false;

  theend:
  { show the logo }
  ClipLt := 0;ClipRt:=319;ClipTp := 0;ClipBt := 239;
  KargLogo := Addr(KargLogoData);
  FillChar(WorkPal^,768,0);
  for i:=0 to 31 do
      if i mod 2=0
         then begin
                TPal(WorkPal^)[i+224,1] := i*2;
                TPal(WorkPal^)[i+224,2] := i*2;
                TPal(WorkPal^)[i+224,3] := i*2;
              end
         else TPal(WorkPal^)[i+224,1] := i*2;

  SetActivePage(0);Cls(0,0);SetVisiblePage(0);SetPal(WorkPal);FontColor(254);
  XScale1(132,85,56,70,56,70,ActStart,KargLogo);
  FntScale(154,72,11,11,11,11,ActStart,MyFont['A']);
  for j:=1 to 4 do
      for i:=1 to length(LastText[j]) do
          FntScale(160-(11*length(LastText[j])) div 2+(i-1)*11,160+(j-1)*14,11,11,11,11,ActStart,MyFont[LastText[j,i]]);

  asm
    mov ax,$0c01
    int $21
  end;

  { restore initial computer state }

  TextMode;

  SetIntVec($01C,Int1CSave);
  SetTimerFreq(0);

  if SBData.CardType<>None then StopMOD;
  FreeMOD(AnyModule);

END.