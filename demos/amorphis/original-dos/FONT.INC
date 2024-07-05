{$L font.obj}
{$F+}
procedure Font;external;
{$F-}

{$L fntscale.obj}
{$F+}
procedure FntScale ( DestX:WORD;DestY:WORD;DestWidth:WORD;DestHeight:WORD;SourceWidth:WORD;SourceHeight:WORD;
                     Start:Word;Bitmap:pointer);external;
{$F-}

CONST
     XFontSize = 11;
     YFontSize = 11;
TYPE
    TFont = array[' '..'`'] of pointer;
VAR
   MyFont : TFont;

procedure InitFont;
var
   i : char;
begin
  for i:=' ' to '`' do MyFont[i] := ptr(seg(Font),ofs(Font)+XFontSize*YFontSize*(byte(i)-32));
end;

procedure FontColor(color : byte);
begin
  mem[seg(fntscale):ofs(fntscale)+366] := color;
end;

