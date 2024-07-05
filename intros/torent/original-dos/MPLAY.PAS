 Program MPlay;

 Uses Crt, Modules;

 Var
  AnyModule: MODDataRec;

 Begin
  WriteLn;

  If ParamCount < 1 Then
  Begin
   WriteLn('MODule Player');
   WriteLn('Usage: MPLAY [module filename]');
   WriteLn;
   Halt(1);
  End;

  LoadMOD(ParamStr(1), 0, AnyModule);
  If ErrorInfo = 1 Then
  Begin
   WriteLn('Error loading module.');
   WriteLn;
   Halt(1);
  End;

  WriteLn('Playing...');
  PlayMOD(AnyModule);

  Repeat
  Until (KeyPressed) OR ((AnyModule^.OrderLen = OrderPos) AND (Row = 64));

  WriteLn('Done!');
  StopMOD;

  FreeMOD(AnyModule);
 End.