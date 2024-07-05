program
       psg3d;

{$I sincos.inc}
{$I 3d.inc}
{$I modex.inc}
{$I scale.inc}
type
    ProStyle  = (ProSimple,ProGeneral);

const
    RotAng      : array[1..1,1..3] of integer = ((90,0,0));
    RotDir      : array[1..1,1..3] of integer = ((1,1,1));

var
   Map : array[1..128,1..128] of byte;
   ViewAng,H  : integer;
   W          : single;
   mapx,mapy  : integer;
   mx,my      : longint;
   ShipAction : integer;
   ShipRot : array[1..3] of integer;

   i,j : integer;
   midx,midy : integer;
   f   : file;
   x1,y1,x2,y2 : integer;
   key : byte;
   p1,p2,p3,p4 : point2d;
   Ship : pointer;

{$L fighter.obj}
{$F+}
procedure FighterData;external;
{$F-}

procedure Render(Base,Work : PTObj3D;xv,yv,zv,xo,yo,zo : integer;cx,cy : integer;style : ProStyle;baseindex : byte);
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
  Move(Base^.Face,Work^.Face,Base^.FC*sizeof(TFace3D));
  Move(Base^.Vertex,Work^.Vertex,Base^.VC*sizeof(Point3D));
  RotateObj(xo,yo,zo,Base^.VC,Base^.FC);
  DepthSort(Obj3D,EyePos,ObjPos);
  if style=ProSimple then ProLook(Base^.VC,EyePos,ObjPos);
  for i:=1 to Base^.FC do
      with Work^.Face[i] do
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

begin
  new(Obj3D);new(WorkObj);new(Pro);getmem(workpal,768);FillChar(WorkPal^,768,0);
  assign(f,'map.raw');reset(f,1);blockread(f,Map,128*128);close(f);

  Set320x240;
  InitSinCos;
  for i:=0 to 63 do
      begin
        TPal(WorkPal^)[i,2] := i;
        TPal(WorkPal^)[i+64,1] := i;TPal(WorkPal^)[i+64,2] := i;TPal(WorkPal^)[i+64,3] := i;
      end;
  TPal(WorkPal^)[128,3] := 63;TPal(WorkPal^)[129,1] := 63;TPal(WorkPal^)[129,2] := 63;
  SetPal(WorkPal);
  Ship := Addr(FighterData);
  ScaleFactor := 2;
  InitObj(Ship,Obj3D);

  ObjPos.z := -64;EyePos.Z := 256;
  with Vi do begin x:=63;y:= 0;z:= 0;end;
  with Vj do begin x:= 0;y:=63;z:= 0;end;
  with Vk do begin x:= 0;y:= 0;z:=-63;end;
  with LightDir do begin x:=0;y:=0;z:=-63;end;
  Inverter(vi,vj,vk);
  mapx := 64;mapy := 16;ViewAng := 270;ShipAction := 0;midx := 160;midy := -72;
  RotAng[1,1] := 190;RotAng[1,2] := 0;RotAng[1,3] := 0;

  repeat
    SetActivePage(page);
    Cls(page);
    XRectFill(0,0,320,120,128);
    case ShipAction of
      0 : begin
            inc(ObjPos.z,2);
            inc(midy,2);
            inc(RotAng[1,1]);
            if ObjPos.z>=128
               then begin
                      inc(ShipAction);
                      RotAng[1,2] := 0;
                      RotAng[1,3] := 359;
                    end;
          end;
      1 : begin
            if RotAng[1,1]>255 then dec(RotAng[1,1]);
            ShipRot[2] := (ShipRot[2]+5) mod 360;
            RotAng[1,2] := longint(longint(40)*longint(sintab[ShipRot[2]])) shr 14;
            if RotAng[1,2]<0 then RotAng[1,2] := 360+RotAng[1,2];
            {dec(RotAng[1,3]);
            if RotAng[1,3]<0 then RotAng[1,3] := 360+RotAng[1,3];}
            inc(ViewAng,5);
            ViewAng := ViewAng mod 360;
            if ViewAng<0 then ViewAng := 360+ViewAng;
            mapy := mapy - longint(2)*longint(sintab[ViewAng]) shr 14;
            if mapy>80 then inc(ShipAction);
          end;
      2 : begin
            inc(RotAng[1,1],5);
            if RotAng[1,1]>352 then inc(ShipAction);
            if not (RotAng[1,2] in [179..181]) then inc(RotAng[1,2],2);
            if ((ViewAng<265) or (ViewAng>275)) then inc(ViewAng,3);
            ViewAng := ViewAng mod 360;
            dec(midy,3);
            inc(mapy);
          end;
      3 : begin
            inc(RotAng[1,1],5);
            if RotAng[1,1]>450 then inc(ShipAction);
            if not (RotAng[1,2] in [179..181]) then inc(RotAng[1,2],2);
            if ((ViewAng<265) or (ViewAng>275)) then inc(ViewAng,3);
            ViewAng := ViewAng mod 360;
            inc(midy,3);
            inc(mapy);
          end;
      4 : begin
            dec(mapy);
            if mapy<50 then inc(ShipAction);
            if not (RotAng[1,2] in [179..181]) then inc(RotAng[1,2],2);
            if ((ViewAng<265) or (ViewAng>275)) then inc(ViewAng,3);
            ViewAng := ViewAng mod 360;
            dec(midy);
          end;
      5 : begin
            dec(ObjPos.z,5);
            dec(midy,2);
            if mapy>5 then dec(mapy);
            if midy<-30 then inc(ShipAction);
            RotAng[1,1] := RotAng[1,1] mod 360;
            if RotAng[1,1]>0 then dec(RotAng[1,1],5);
            if RotAng[1,1]<0 then RotAng[1,1] := 0;
          end;
    end;
    key :=port[$60];
    asm
      mov ax,$0c02
      int $21
    end;
    case key of
      72 : begin
             mapx := mapx + longint(2)*longint(costab[ViewAng]) shr 14;
             mapy := mapy + longint(2)*longint(sintab[ViewAng]) shr 14;
           end;
      80 : begin
             mapx := mapx - longint(2)*longint(costab[ViewAng]) shr 14;
             mapy := mapy - longint(2)*longint(sintab[ViewAng]) shr 14;
           end;
      75 : ViewAng:= (ViewAng+5) mod 360;
      77 : begin
             dec(ViewAng,5);
             if ViewAng<0 then ViewAng:= 360+ViewAng;
           end;
      1  : break;
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
                if (j=11)
                   then if i=(-16-j) then begin p1.x := mx;p1.y:=my;end
                           else if i=(16+j) then begin p2.x:=mx;p2.y:=my;end;
                if j=0
                   then if i=(-16-j) then begin p3.x := mx;p3.y:=my;end
                           else if i=(16+j) then begin p4.x:=mx;p4.y:=my;end;
                if (mx<1) or (mx>128) or (my<1) or (my>128) then H := 0
                   else H := Map[my,mx];
                XRectFill(160+round(i*W),120-H+(11-j)*10,160+round((i+1)*W),120+(11-j)*10,Map[my,mx]);
              end;
       end;
    {XScale1(1,1,128,128,128,128,ActStart,ptr(seg(Map),ofs(Map)));
    Line_X(p1.x,p1.y,p2.x,p2.y,128);
    Line_X(p1.x,p1.y,p3.x,p3.y,128);
    Line_X(p2.x,p2.y,p4.x,p4.y,128);
    Line_X(p3.x,p3.y,p4.x,p4.y,128);}
    Render(Obj3D,WorkObj,0,0,0,RotAng[1,1],RotAng[1,2],RotAng[1,3],midx,midy,ProSimple,64);
    SetVisiblePage(page);
    page := (page+1) mod 2;
  until ShipAction>5;
  TextMode;
end.