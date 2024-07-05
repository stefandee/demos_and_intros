 IntSphere := false;
 asm
  finit
  fld x2
  fmul st(0),st
  fst p1
  fld y2
  fmul st(0),st
  fst p2
  fld z2
  fmul st(0),st
  fadd p1
  fadd p2
  fst a

  finit
  fld x1
  fsub xc
  fmul x2
  fst p1
  fld y1
  fsub yc
  fmul y2
  fst p2
  fld z1
  fsub zc
  fmul z2
  fadd p1
  fadd p2
  fst b

  fwait
  fld x1
  fsub xc
  fmul st(0),st
  fst p1
  fld y1
  fsub yc
  fmul st(0),st
  fst p2
  fld z1
  fsub zc
  fmul st(0),st
  fadd p1
  fadd p2
  fsub radp
  fst c

  finit
  fld b
  fmul st(0),st
  fst p1
  fld a
  fmul c
  fsub p1
  fchs
  fst delta
 end;
 if delta<0 then exit;{ no intersection with sphere }
 asm
  fwait
  fld delta
  fsqrt
  fdiv a
  fst p2
  fld b
  fchs
  fdiv a
  fst p1
  fadd p2
  fst sol1

  finit
  fld x2
  fmul sol1
  fadd x1
  fst xj
  fld y2
  fmul sol1
  fadd y1
  fst yj
  fld z2
  fmul sol1
  fadd z1
  fst zj

  finit
  fld xj
  fsub xc
  fst p3
  fmul st(0),st
  fst p1
  fld yj
  fsub yc
  fst p4
  fmul st(0),st
  fst p2
  fld zj
  fsub zc
  fst p5
  fmul st(0),st
  fadd p1
  fadd p2
  fsqrt
  fst modul
  fld p3
  fdiv modul
  fst xr
  fld p4
  fdiv modul
  fst yr
  fld p5
  fdiv modul
  fst zr

  finit
  fld x2
  fmul st(0),st
  fst p1
  fld y2
  fmul st(0),st
  fst p2
  fld z2
  fmul st(0),st
  fadd p1
  fadd p2
  fsqrt
  fst modul
  fld x2
  fdiv modul
  fst x2
  fld y2
  fdiv modul
  fst y2
  fld z2
  fdiv modul
  fst z2

  finit
  fld z2
  fmul zr
  fst p1
  fld x2
  fmul xr
  fst p2
  fld y2
  fmul yr
  fadd p1
  fadd p2
  fadd st(0),st
  fst modul
 end;

 {xj := x1+sol1*x2;yj:=y1+sol1*y2;zj:=z1+sol1*z2;}
 { normalizare normala }
 {modul := sqrt(sqr(xj-xc)+sqr(yj-yc)+sqr(zj-zc));}
 {xr := (xj-xc)/modul;yr := (yj-yc)/modul;zr := (zj-zc)/modul;
 { normalizare vector incident... }
 {modul := sqrt(x2*x2+y2*y2+z2*z2);
 x2:=x2/modul;y2:=y2/modul;z2:=z2/modul;
 modul := 2*(x2*xr+y2*yr+z2*zr);}
 if modul>0
    then begin
          asm
           finit
           fld x2
           fdiv modul
           fchs
           fadd xr
           fst x2
           fld y2
           fdiv modul
           fchs
           fadd yr
           fst y2
           fld z2
           fdiv modul
           fchs
           fadd zr
           fst z2
          end;
         end
    else if modul=0
            then begin
                  asm
                   finit
                   fld x2
                   fchs
                   fst x2
                   fld y2
                   fchs
                   fst y2
                   fld z2
                   fchs
                   fst z2
                  end;
                  {x2 := -x2;
                  y2 := -y2;
                  z2 := -z2;}
                 end
           else begin
                asm
                 finit
                 fld x2
                 fdiv modul
                 fsub xr
                 fst x2
                 fld y2
                 fdiv modul
                 fsub yr
                 fst y2
                 fld z2
                 fdiv modul
                 fsub zr
                 fst z2
                end;
                 {
                 x2 := -xr+x2/modul;
                 y2 := -yr+y2/modul;
                 z2 := -zr+z2/modul;
                 }
                end;
 asm
  finit
  fld x2
  fmul st(0),st
  fst p1
  fld y2
  fmul st(0),st
  fst p2
  fld z2
  fmul st(0),st
  fadd p2
  fadd p1
  fsqrt
  fst modul
  fld x2
  fdiv modul
  fst x2
  fld y2
  fdiv modul
  fst y2
  fld z2
  fdiv modul
  fst z2

  finit
  fld xj
  fst x1
  fld yj
  fst y1
  fld zj
  fst z1
 end;
 {modul := x2*x2+y2*y2+z2*z2;
 x2 := x2/modul;y2 := y2/modul;z2 := z2/modul;
 x1:=xj;y1:=yj;z1:=zj;}
 IntSphere := true;
end;
