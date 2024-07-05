program
       Transformer;
CONST
      MaxFaces = 1152;
      MaxPoints = 1024;
      MaxObjects = 512;
TYPE
      TPoint3D = RECORD
             X,Y,Z : longint;
             END;
      TPoint2D = RECORD
             X,Y : longint;
             END;

      TPointedPlane = record
                   P1,P2,P3,Color : longint;
                   EyeDist : longint;
                   end;

      Scheme = ARRAY[1..MaxPoints] of TPoint3D;
      PNewObj = ^NewObj;
      NewObj = RECORD
             Points   : Scheme; {core if pointsno+1 point}
             Faces   : ARRAY[1..MaxFaces] of TPointedPlane;
             FacesNo   : longint;
             PointsNo : longint;
             END;

var
   f : file of NewObj;
   t : newobj;
   fd: file;
   x,y,z,i,j : integer;
   c : byte;
   pal : array[0..255,1..3] of byte;
begin
  assign(f,'cone.s3d');reset(f);read(f,t);close(f);
  assign(fd,'cone.var');rewrite(fd,1);
  x := t.Pointsno;blockwrite(fd,x,2);
  for i:=1 to t.PointsNo do
      begin
        x := t.Points[i].x;
        y := t.Points[i].y;
        z := t.Points[i].z;
        writeln(x,' ',y,' ',z);
        blockwrite(fd,x,2);
        blockwrite(fd,y,2);
        blockwrite(fd,z,2);
      end;
  x := t.FacesNo;blockwrite(fd,x,2);
  for i:=1 to t.FacesNo do
      with t.Faces[i] do
           begin
             x := p1;blockwrite(fd,x,2);
             y := p2;blockwrite(fd,y,2);
             z := p3;blockwrite(fd,z,2);
             c := (color and $FF) div 4;
             writeln(x,' ',y,' ',z);
             blockwrite(fd,c,1);
           end;
  close(fd);
  writeln('Faces : ',t.FacesNo);
  writeln('Vertex : ',t.PointsNo);
end.