{ scaling & putsprite }
{$L xscale1.obj}
{$F+}
procedure XSCALE1 ( DestX:WORD;DestY:WORD;DestWidth:WORD;DestHeight:WORD;SourceWidth:WORD;SourceHeight:WORD;
                    Start:Word;Bitmap:pointer);external;
{$F-}
