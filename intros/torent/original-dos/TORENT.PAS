PROGRAM TORENT_BBS;
{$M 32768,0,250000}
USES
    Dos,Modules,Detect;
CONST
     { clipping variables }
     ClipLT   : word = 0;
     ClipRT   : word = 319;
     ClipTP   : word = 0;
     ClipBT   : word = 239;
     Height   : word = 320;
     Width    : word = 200;
     WidthBytes:word = 80;
     ActStart : word = 0;
     ViStart  : word = 0;
     OrgX     : word = 160;
     OrgY     : word = 120;
     Page     : word = 1;
     { video defs }
     SEQU_ADDR      = $3c4;
     CRTC_ADDR      = $3d4;
     INPUT_STATUS_0 = $3c2;
     INPUT_STATUS_1 = $3da;
     MapMask        =  $02;
     VGA            = $a000;
     LeftClipPlaneMask  : array[0..3] of byte = ( $0F, $0E, $0C, $08 );
     RightClipPlaneMask : array[0..3] of byte = ( $0F, $01, $03, $07 );
    { font }
    FontXSize  = 10;
    FontYSize  = 16;
    FontFactor = 1.75;
    { text }
    MaxText = 7;
    Text    : array[1..4,1..MaxText] of string[20] =
              ( ('TORENT',   'SYSOP:'      ,'RUNNING ON' ,'OVER 200 MEGS','OPENED DAILY','AND'          ,'CALL'),
                ('BBS',      'SCORPION'      ,'PENTIUM 133','ONLINE'       ,'FROM'        ,'16PM SATURDAY','831820'),
                ('CONSTANTA','AKA'           ,'28800 MODEM',''             ,'19PM TO 10AM','TILL'         ,'NOW !'),
                ('',         'DAN CARAGEA'   ,''           ,''             ,''            ,'10AM MONDAY'  ,''));
    LineUsed : array[1..MaxText] of byte = (3,4,3,2,3,4,3);
    TextX : integer = 0;
    TextY : integer = 0;
    ColumnCounter : integer = 1;
    LineCounter   : integer = 1;
    LetterIndex   : integer = 1;
    CurveIndex    : integer = 1;
    TParam        : single  = 0;
    Step          : single  = 1/18;
    FontXSpacing  : single  = 1.35;
    FontYSpacing  : single  = 8;
    WritePaused   : boolean = false;
    PauseCounter  : integer = 0;
    { freqventa }
    FreqValue : word = $1234DD div 133;
    { feet }
    FootX   : integer = -30;
    FootY   : integer = 208;
    whatstep: byte    = 0;
    StepDelay: byte   = 30;
    MaxDelay : byte   = 30;

TYPE
    Pal = array[0..255,1..3] of byte;
    Point2D = record
              x,y : longint;
            end;
    Point3D = record
              x,y,z : longint;
            end;
    TFontPoint = record
                 x,y : shortint;
               end;
    TCurve  = record
             P1,P2,P3,P4 : TFontPoint;
           end;
    TLetter = record
              Curves   : array[1..5] of TCurve;
              MaxCurve : integer;
            end;
    TFont   = array[' '..'Z'] of TLetter;
    PTFont  = ^TFont;
VAR
   workpal       : Pal;
   i,j           : longint;
   Font          : PTFont;
   Ball          : pointer;
   {f             : file of tfont;
   fp            : file of Pal;}
   Int1CSave     : Pointer;
   DrawEnabled   : boolean;
   Xpix,Ypix     : integer;
   Xbase,Ybase   : integer;
   UpZone,
   DownZone      : pointer;
   DarkZone      : pointer;
   LeftFoot,
   RightFoot     : pointer;
   AnyModule     : MODDataRec;

{$L font.obj}
{$F+}
procedure FontData;external;
{$F-}

{$L ball.obj}
{$F+}
procedure BallData;external;
{$F-}

{$L leftfoot.obj}
{$F+}
procedure LeftFootData;external;
{$F-}
{$L rightfoo.obj}
{$F+}
procedure RightFootData;external;
{$F-}

{$F+,S-,W-}
procedure TimerHandler; interrupt;
  begin
    { Timer ISR }
    {*** Refer to DDK and DPMI Specs for creating ISR's ***}
    DrawEnabled := true;
  end;
{$F-,S+}

{$I scale.inc}
{$I modex.inc}

{procedure InitS3M(filename : string);
const
  stereo_calc=false;
  _16bit_calc=false;
var
   Stereo        : Boolean;
   _16bit        : Boolean;
   samplerate    : word;
begin
  Samplerate:=45454;
  Stereo:=stereo_calc;
  _16bit:=_16bit_calc;
  if not Load_S3M(filename,0) then halt;
  writeln(' ''',songname,''' loaded ... (was saved with ST',savedunder:4:2,')');
  if not Init_S3Mplayer then halt;
  if not Init_Device(1) then begin writeln(' SoundBlaster not found sorry ... ');halt end;
  SetSampleRate(samplerate,stereo);
  Set_ST3order(true);
  loopS3M:=true;
end;}

procedure Letter;
var
   t1norm,t1square,t1cube,tcube,tsquare : single;
begin
  with Font^[Text[LineCounter,ColumnCounter][LetterIndex]] do
       begin
         with Curves[CurveIndex] do
              begin
                TParam := TParam+Step;
                t1norm := 1-TParam;
                t1square := t1norm*t1norm;
                t1cube := t1square*t1norm;
                tsquare := TParam*TParam;
                tcube := tsquare*TParam;
                Xpix := round(Xbase+
                        (LetterIndex-1)*FontXSpacing*FontXSize*FontFactor+
                        FontFactor*(P1.X*t1cube+3*TParam*t1square*P2.X+3*t1norm*tsquare*P3.X+tcube*P4.X));
                Ypix := round(Ybase+
                        (FontFactor*FontYSize+FontYSpacing)*(LineCounter-1)+
                        FontFactor*(P1.Y*t1cube+3*TParam*t1square*P2.Y+3*t1norm*tsquare*P3.Y+tcube*P4.Y));
              end;
       end;
end;

procedure GenPal;{a standard pallete}
var
   pseg,pofs : word;
begin
  pseg := seg(workpal);
  pofs := ofs(workpal);
  asm
    { clearing pallete }
    mov es,pseg
    mov di,pofs
    mov cx,384
    xor ax,ax
    rep stosw

    mov di,pofs

    { generating a 64 gray scale }
    xor al,al
    mov cx,64
    @l1:
      stosb
      stosb
      stosb
      inc al
    loop @l1

    { generating a 64 yellow scale }
    xor al,al
    mov cx,64
    @l2:
      stosb
      stosb
      inc di
      inc al
    loop @l2

    { generaring 64 red scale }
    xor al,al
    mov cx,64
    @l3:
      stosb
      inc di
      inc di
      inc al
    loop @l3

    { generating 64 green scale }
    xor al,al
    mov cx,64
    @l4:
      inc di
      stosb
      inc di
      inc al
    loop @l4
   end;
end;

procedure Sand;
type
    TLine     = array[0..319] of integer;
    TZone     = array[40..200,0..319] of byte;
    TUpZone   = array[0..39,0..319] of byte;
    TDownZone = array[201..239,0..319] of byte;
var
   Psg,PsgAnt : TLine;
   i,j : integer;
   color : byte;
begin
  randomize;
  getmem(DarkZone,sizeof(TZone));
  getmem(UpZone,sizeof(TUpZone));
  getmem(DownZone,sizeof(TDownZone));
  for i:=0 to 319 do PsgAnt[i] := random(63);
  for j:=0 to 239 do
      for i:=0 to 319 do
          begin
            Psg[i] := (2*PsgAnt[i]+7*PsgAnt[i+1]) div 9+random(2);
            if Psg[i]>63 then Psg[i] := 63-random(10);
            if Psg[i]<0 then Psg[i] := random(10);
            PsgAnt[i] := Psg[i];
            case j of
              0..39   : TUpZone(UpZone^)[j,i] := psg[i]+64;
              40..200 : begin
                          color := psg[i]-15;
                          if color<0 then color := 0;
                          inc(color,64);
                          TZone(DarkZone^)[j,i] := color;
                        end;
              201..239: TDownZone(DownZone^)[j,i] := psg[i]+64;
            end;
         end;
end;

BEGIN
  { initializations }
  {InitS3M('64mania.s3m');
  if not StartPlaying(stereo,_16bit,false) then halt;}
  LoadMOD('torent.exe', 11634, AnyModule);
  If ErrorInfo = 1
     Then Begin
            WriteLn('Error loading module.');
            WriteLn;
            Halt(1);
          End;
  if SBData.CardType <> None then PlayMOD(AnyModule);


  Font := Addr(FontData);
  Ball := Addr(BallData);
  LeftFoot := Addr(LeftFootData);
  RightFoot := Addr(RightFootData);

  Set320x240;
  GenPal;
  SetPal;
  Sand;
  { draw upper zone }
  SetActivePage(0);XScale1(0,0,320,40,320,40,ActStart,UpZone);
  SetActivePage(1);XScale1(0,0,320,40,320,40,ActStart,UpZone);
  { draw middle zone }
  SetActivePage(0);XScale1(0,40,320,160,320,160,ActStart,DarkZone);
  SetActivePage(1);XScale1(0,40,320,160,320,160,ActStart,DarkZone);
  { draw bottom zone }
  SetActivePage(0);XScale1(0,200,320,39,320,39,ActStart,DownZone);
  SetActivePage(1);XScale1(0,200,320,39,320,39,ActStart,DownZone);
  SetVisiblePage(0);

  port[$43] := $34;
  port[$40] := FreqValue mod 256;
  port[$40] := FreqValue div 256;

  GetIntVec($1C,Int1CSave);
  SetIntVec($1C,Addr(TimerHandler));

  Xbase := round((Width-length(Text[LineCounter,ColumnCounter])*FontXSize*
           FontXSpacing*FontFactor)/2);
  Ybase := round((Height-LineUsed[ColumnCounter]*FontYSize*FontFactor-
           (LineUsed[ColumnCounter]-1)*FontYSpacing)/2);

  Repeat
    if not WritePaused
       then begin
              if TParam>=1
                 then begin
                        TParam := 0;
                        inc(CurveIndex);
                        if CurveIndex>Font^[Text[LineCounter,ColumnCounter][LetterIndex]].MaxCurve
                           then begin
                                  CurveIndex := 1;
                                  inc(LetterIndex);
                                  if LetterIndex>length(Text[LineCounter,ColumnCounter])
                                     then begin
                                            LetterIndex := 1;
                                            inc(LineCounter);
                                            if LineCounter>LineUsed[ColumnCounter]
                                               then begin
                                                      LineCounter := 1;
                                                      inc(ColumnCounter);
                                                      if ColumnCounter>MaxText then ColumnCounter := 1;
                                                      WritePaused := true;
                                                    end;
                                          end;
                                  Xbase := round((Width-length(Text[LineCounter,ColumnCounter])*FontXSize*
                                           FontXSpacing*FontFactor)/2);
                                  Ybase := round((Height-LineUsed[ColumnCounter]*FontYSize*FontFactor-
                                           (LineUsed[ColumnCounter]-1)*FontYSpacing)/2);
                                end;
                      end;
              Letter;
            end
       else begin
              inc(PauseCounter);
              if PauseCounter>300
                 then begin
                        PauseCounter := 0;
                        WritePaused := false;
                        SetActivePage(0);XScale1(0,40,320,160,320,160,ActStart,DarkZone);
                        SetActivePage(1);XScale1(0,40,320,160,320,160,ActStart,DarkZone);
                      end;
            end;

    { wait for draw enable ... computer independent }

    repeat
    until DrawEnabled;
    DrawEnabled := false;

    SetActivePage(Page);
    { now we're ready to draw }

    { animate the feet }
    dec(StepDelay);
    if StepDelay=0
       then begin
              inc(FootX,40);
              if FootX>320
                 then begin
                        FootX := -40;
                        MaxDelay := (random(2)+1)*10;
                      end;
              inc(whatstep);
              whatstep := whatstep  mod 2;
              StepDelay := MaxDelay;
            end;

    XScale1(0,200,320,39,320,39,ActStart,DownZone);
    if whatstep=0
       then begin
              XScale1(FootX,FootY,20,10,20,10,ActStart,LeftFoot);
              XScale1(FootX+40,FootY+15,20,10,20,10,ActStart,RightFoot);
            end
       else begin
              XScale1(FootX+40,FootY,20,10,20,10,ActStart,LeftFoot);
              XScale1(FootX,FootY+15,20,10,20,10,ActStart,RightFoot);
            end;
    { draw letter }
    if (not WritePaused) and (Font^[Text[LineCounter,ColumnCounter][LetterIndex]].MaxCurve<>0)
       then begin
              XScale1(Xpix-2,Ypix-2,5,5,5,5,ActStart,Ball);
              XScale1(Xpix-2,Ypix-2,5,5,5,5,ViStart,Ball);
            end;

    SetVisiblePage(Page);
    inc(Page);
    Page := Page mod 2;
  Until (port[$60]=1);

  SetIntVec($01C,Int1CSave);

  port[$43] := $34;
  port[$40] := 0;
  port[$40] := 0;

  TextMode;

  {Stop_Play;
  Done_Module;
  Done_S3MPlayer;}
  if SBData.CardType <> None then StopMOD;
  FreeMOD(AnyModule);


  writeln('ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿');
  writeln('³This demo requires math coprocessor.                   ³');
  writeln('³To hear music, you must have a SoundBlaster compatible.³');
  writeln('³It is advisable that you should not run this demo under³');
  writeln('³Windows 95.                                            ³');
  writeln('ÃÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´');
  writeln('³         Demo coded by Karg, on late july''97.          ³');
  writeln('³              MOD player by TSC-Software.              ³');
  writeln('³         Karg is Dicu Stefan, pp709@cs.utt.ro.         ³');
  writeln('ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ');
  {´µ¶·¸¹º»¼½¾ ¿À Á Â Ã Ä Å Æ ¿ÆÇÈÉÊËÌÍÎÏĞÑÒ?ÔÕÖ×Ø Ù Ú}
END.