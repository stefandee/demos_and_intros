Unit Snddrv;

Interface

uses Dos,Crt;

{
*************************************
*************************************
***** GENERAL VARIABLES & TYPES *****
*************************************
*************************************
}


const maxdigitalsounds=16;
      freqv  :   word = 11025;
      BLASTER = 7;
      PIT     = $42;
      LPT1    = $378;
      LPT2    = $278;
      NONE    = 255;
      Output  : Word = NONE;

type DigitalSound = record
                  len  : word;
                  psnd : pointer;
                  end;
var Sounds : array[1..maxdigitalsounds] of DigitalSound;

procedure LoadSound(fname : string;nr : byte);
procedure FreeSound(nr : byte);
procedure PlaySound(nr : byte);
procedure InternalSet;
procedure ReadCfg;

{
 The following procedures does not need to
 be here on interface part as you will never
 use them directly.
}

{
*************************************
*************************************
*****      SOUND BLASTER        *****
*************************************
*************************************
}


const
      Voltable : array[1..11] of byte=(0,17,51,85,136,153,187,204,221,238,254);
      Volcnt : integer = 7;

var
    Base   : word;

procedure SetMixerReg(index, value : byte);
function GetMixerReg(index : byte) : byte;
{ ResetDSP returns true if reset was successful
  base should be 1 for base address 210h, 2 for 220h etc... }
function ResetDSP(base : word) : boolean;
{ Write DAC sets the speaker output level }
procedure WriteDAC(level : byte);
{ ReadDAC reads the microphone input level }
function ReadDAC : byte;
{ SpeakerOn connects the DAC to the speaker }
function SpeakerOn: byte;
{ SpeakerOff disconnects the DAC from the speaker,
  but does not affect the DAC operation }
function SpeakerOff: byte;
{ Functions to pause DMA playback }
procedure DMAStop;
procedure DMAContinue;
{ Playback plays a sample of a given size back at a given frequency using
  DMA channel 1. The sample must not cross a page boundry }
{
*************************************
*************************************
*****      SPEAKER & DAC       ******
*************************************
*************************************
}

procedure Speak_Set(what : word);
procedure Speak_Stop;

implementation

{BLASTER}
var
    DSP_RESET : word;
    DSP_READ_DATA : word;
    DSP_WRITE_DATA : word;
    DSP_WRITE_STATUS : word;
    DSP_DATA_AVAIL : word;


{speaker&lpt}
const SPEAKER_PORT = $61;
      PIT_CONTROL = $43;
      PIT_FREQ = $1234DD;
      TIMERINTR = 8;
var q,clock_ticks,counter:longint;
    count_values:array[0..255] of byte;
    BIOSTimerHandler:procedure;
    note:longint;
    whatsound : word;

procedure InternalSet;
begin
GetIntVec(TIMERINTR,@BIOSTimerHandler);
if Output=Blaster
   then begin
        speakeron;
        resetdsp(base);
        setmixerreg(0,0);
        setmixerreg($04,voltable[volcnt]);
        setmixerreg($22,voltable[volcnt]);
        end;
end;

procedure ReadCfg;

var f  : file;
    ts : searchrec;
    aux: byte;

begin
findfirst('sound.cfg',anyfile,ts);
if doserror=0
   then begin
        assign(f,'sound.cfg');reset(f,1);
        blockread(f,aux,1);
        case aux of
        255 : output:=NONE;
        1   : output:=LPT1;
        2   : output:=LPT2;
        0   : output:=PIT;
        7   : begin
              blockread(f,aux,1);
              base:=aux*$10+$200;
              if resetdsp(base) then output:=BLASTER
                                else output:=NONE;
              end;
       end;
       InternalSet;
       end
   else output:=NONE;{no SOUND.CFG found,force to silence}
        {
                this is the procedure for games
                also , the sequence

                     . . . . .
                     output = Blaster;
                     InternalSet;
                     . . . . .

                is valid.
        }
end;

procedure Speak_Stop;
begin
  Port[$43] := $34;
  Port[$40] := 0;
  Port[$40] := 0;
  SetIntVec(TIMERINTR, @BIOSTimerHandler);
  Port[SPEAKER_PORT]:=Port[SPEAKER_PORT] and $FC;
  Port[PIT_CONTROL]:=$B6;
end;

{$F+}
procedure Speak_Intr;interrupt;
begin
  {asm cli end;}
  with sounds[whatsound] do
  Port[Output]:= count_values[mem[seg(psnd^):ofs(psnd^)+note]];
  {asm sti end;}
  inc(note);
  if note>sounds[whatsound].len
     then begin
          note:=1;
          Speak_Stop;
          end;

  clock_ticks := clock_ticks + counter;

  if clock_ticks >= $10000 then
     begin
          clock_ticks :=clock_ticks - $10000;
          asm pushf end;
          BIOSTimerHandler;
     end
     else
         Port[$20] := $20;
end;
{$F-}

procedure Speak_Set(what : word);
var i : integer;
begin
  q:=pit_freq div (2*freqv);
  for i := 0 to 255 do count_values[i] := byte((2*i*q) div 255);
  clock_ticks := 0;counter:=q;whatsound:=what;
  Port[$43] := $34;
  Port[$40] := (pit_freq div freqv) mod 255;
  Port[$40] := (pit_freq div freqv) div 255;
  note:=1;
  Port[PIT_CONTROL] := $90;
  Port[SPEAKER_PORT] := Port[SPEAKER_PORT] or 3;
  SetIntVec(TIMERINTR, @speak_intr);
end;


{ base = 220h, 230 or 240h }
procedure SetMixerReg(index, value : byte);
begin
if Output=BLASTER
   then begin
        Port[base + 4] := index;
        Port[base + 5] := value;
        end;
end;


function GetMixerReg(index : byte) : byte;
begin
  Port[base + 4] := index;
  GetMixerReg := Port[base + 5];
end;


function ResetDSP(base : word) : boolean;

var basenr : byte;

begin

  basenr := base-$200;

  { Calculate the port addresses }
  DSP_RESET := basenr + $206;
  DSP_READ_DATA := basenr + $20A;
  DSP_WRITE_DATA := basenr + $20C;
  DSP_WRITE_STATUS := basenr + $20C;
  DSP_DATA_AVAIL := basenr + $20E;

  { Reset the DSP, and give some nice long delays just to be safe }
  Port[DSP_RESET] := 1;
  Delay(10);
  Port[DSP_RESET] := 0;
  Delay(10);
  if (Port[DSP_DATA_AVAIL] And $80 = $80) And
     (Port[DSP_READ_DATA] = $AA) then
    ResetDSP := true
  else
    ResetDSP := false;
end;

procedure WriteDSP(value : byte);
begin
  while Port[DSP_WRITE_STATUS] And $80 <> 0 do;
  Port[DSP_WRITE_DATA] := value;
end;

function ReadDSP : byte;
begin
  while Port[DSP_DATA_AVAIL] and $80 = 0 do;
  ReadDSP := Port[DSP_READ_DATA];
end;

procedure WriteDAC(level : byte);
begin
  WriteDSP($10);
  WriteDSP(level);
end;

function ReadDAC : byte;
begin
  WriteDSP($20);
  ReadDAC := ReadDSP;
end;

function SpeakerOn: byte;
begin
  WriteDSP($D1);
end;

function SpeakerOff: byte;
begin
  WriteDSP($D3);
end;

procedure DMAContinue;
begin
  WriteDSP($D4);
end;

procedure DMAStop;
begin
  WriteDSP($D0);
end;

procedure LoadSound;
var f:file;
begin
assign(f,fname);
reset(f,1);
with sounds[nr] do
     begin
     len:=filesize(f);
     getmem(psnd,len);
     blockread(f,psnd^,len);
     end;
close(f);
end;

procedure PlaySound(nr:byte);
var time_constant : word;
     page, offset : word;
begin

case OutPut of

Lpt1,Pit,Lpt2 :
  Speak_Set(nr);

Blaster :
  with sounds[nr] do
       begin
       len := len - 1;
       { Set up the DMA chip }
       offset := Seg(psnd^) Shl 4 + Ofs(psnd^);
       page := (Seg(psnd^) + Ofs(psnd^) shr 4) shr 12;
       Port[$0A] := 5;
       Port[$0C] := 0;
       Port[$0B] := $49;
       Port[$02] := Lo(offset);
       Port[$02] := Hi(offset);
       Port[$83] := page;
       Port[$03] := Lo(len);
       Port[$03] := Hi(len);
       Port[$0A] := 1;
  {    Set the playback frequency }
       time_constant := 256 - 1000000 div freqv;
       WriteDSP($40);
       WriteDSP(time_constant);
  {    Set the playback type (8-bit) }
       WriteDSP($14);
       WriteDSP(Lo(len));
       WriteDSP(Hi(len));
       end;
end;
end;

procedure FreeSound;
begin
with sounds[nr] do
     begin
     freemem(psnd,len);
     len:=0;
     end;
end;

BEGIN
END.