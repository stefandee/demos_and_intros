UNIT
    ObjData;

INTERFACE

procedure CityData;

VAR
   City : pointer;

IMPLEMENTATION

{$L city.obj}
{$F+}
procedure CityData;external;
{$F-}

BEGIN
END.