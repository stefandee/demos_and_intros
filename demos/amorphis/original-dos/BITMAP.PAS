UNIT
    BitMap;
{ just a trick to ease the code segment of the main program}


INTERFACE

VAR
   Title       : pointer;
   KargLogo    : pointer;
   AnimFoot01  : pointer;

{$L title.obj}
{$F+}
procedure TitleData;
{$F-}

{$L karglogo.obj}
{$F+}
procedure KargLogoData;
{$F-}

{$L titlepal.obj}
{$F+}
procedure TitlePalData;
{$F-}

{$L animft01.obj}
{$F+}
procedure AnimFootData01;
{$F-}

{$L maskpal.obj}
{$F+}
procedure MaskPalData;
{$F-}

IMPLEMENTATION

procedure TitleData;external;
procedure KargLogoData;external;
procedure TitlePalData;external;
procedure AnimFootData01;external;
procedure MaskPalData;external;

BEGIN
END.