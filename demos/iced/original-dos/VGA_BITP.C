/*****************************************************************************/
/*                              BITPLANE.C                                   */
/*****************************************************************************/
#include <dos.h>
#include <stdlib.h>
#include <mem.h>
#define BYTE unsigned char
#define PLANESIZE 38400
BYTE cur_plane = 0;

void setgraphicsmode(int mode)
{
  union REGS regs;

  regs.x.ax = mode % 256;
  int86(0x10,&regs,&regs);
}

void setpaletteregister(int registr,int value)
{
  union REGS regs;

  regs.x.ax = 0x1000;
  regs.x.bx = ((value % 64) << 8) + (registr % 16);
  int86(0x10,&regs,&regs);
}

void setcolorregister(int registr,int red,int green,int blue)
{
  union REGS regs;

  regs.x.ax = 0x1010;
  regs.x.bx = registr;
  regs.x.dx = ((red % 64) << 8) + (regs.x.dx & 0xFF);
  regs.x.cx = ((green % 64) << 8) + blue;
  int86(0x10,&regs,&regs);
}

void setupbitplane()
{
  int c4 = 63;	/* Full brightness	63	*/
  int c3 = 54;	/* 3/4  brightness	55	*/
  int c2 = 47;	/* Half brightness	48	*/
  int c1 = 40;	/* 1/4  brightness	40	*/
  int c0 =  0;	/* No   brightness	0	*/
  int i;

  setgraphicsmode(0x12);
  for (i=0;i<16;i++)
    setpaletteregister(i,i);
  setcolorregister(0,0,c0,c0);	/* For 0000	*/
  setcolorregister(1,0,c1,c1);	/* For 0001	*/
  setcolorregister(2,0,c1,c1);	/* For 0010	*/
  setcolorregister(4,0,c1,c1);	/* For 0100	*/
  setcolorregister(8,0,c1,c1);	/* For 1000	*/
  setcolorregister(3,0,c2,c2);	/* For 0011	*/
  setcolorregister(5,0,c2,c2);	/* For 0101	*/
  setcolorregister(6,0,c2,c2);	/* For 0110	*/
  setcolorregister(9,0,c2,c2);	/* For 1001	*/
  setcolorregister(10,0,c2,c2);	/* For 1010	*/
  setcolorregister(12,0,c2,c2);	/* For 1100	*/
  setcolorregister(11,0,c3,c3);	/* For 0111	*/
  setcolorregister(7,0,c3,c3);	/* For 1011	*/
  setcolorregister(13,0,c3,c3);	/* For 1101	*/
  setcolorregister(14,0,c3,c3);	/* For 1110	*/
  setcolorregister(15,0,c4,c4);	/* For 1111	*/
}

void plotdot(int x,int y)
{
  unsigned offset;
  BYTE plane,planemask,oldval;

  plane = cur_plane;
  /******** Select appropriate memory plane *******/
  planemask = 1 << plane;
  outportb(0x03CE,4);
  outportb(0x03CF,plane);	/* For reading	*/
  outportb(0x03C4,2);
  outportb(0x03C5,planemask);	/* For writing	*/
  /******* Set value in memory *******/
  offset = y * 80 + x / 8;
  oldval = peekb(0xA000,offset);
  pokeb(0xA000,offset,oldval | (0x80 >> (x % 8)));
}

void clearplane()
{
  BYTE plane,planemask,*video_ram;

  video_ram = MK_FP(0xA000,0x0000);
  plane = cur_plane;
  /******** Select appropriate memory plane *******/
  planemask = 1 << plane;
  outportb(0x03C4,2);
  outportb(0x03C5,planemask);	/* For writing	*/
  memset(video_ram,0,PLANESIZE);
}


void setplane(BYTE plane)
{
  cur_plane = plane % 4;
}

int sign(int x)
{
  (x<0) ? (x=-1) : (x=1);
  return(x);
}

int _abs(int x)
{
  if (x<0) x *=-1;
  return(x);
}

void swap(int *a,int *b)
{
  int c;

  c=*b;
  *b=*a;
  *a=c;
}

void _line(int x,int y,int x2,int y2)
{
  int i,steps,sx,sy,dx,dy,e,steep;

  dx = _abs(x2-x);
  sx = sign(x2-x);
  dy = _abs(y2-y);
  sy = sign(y2-y);
  steep = dy > dx;
  if (steep) {
    swap(&x,&y);
    swap(&dy,&dx);
    swap(&sx,&sy);
  }
  e = 2*dy-dx;
  for (i=0;i<dx;i++) {
    if (steep) plotdot(y,x);
    else plotdot(x,y);
    while (e > 0) {
      y += sy;
      e -= 2*dx;
    }
    x += sx;
    e += 2*dy;
  }
  plotdot(x2,y2);
}

void _circle(int xc,int yc,int radius)
{
  int x,y,d;

  x = 0;
  y = radius;
  d = 2 * (1-radius);
  while (y>x) {
    plotdot(xc+x,yc+y);
    plotdot(xc-x,yc+y);
    plotdot(xc+x,yc-y);
    plotdot(xc-x,yc-y);
    plotdot(xc,yc+y);
    plotdot(xc,yc-y);
    plotdot(xc+x,yc);
    plotdot(xc-x,yc);
    if (d+y>0) {
      y--;
      d = d - 2*y +1;
    }
    if (x>d) {
      x++;
      d = d + 2*x + 1;
    }
  }
}

main()
{
  int i;

  setupbitplane();
  setplane(0);
  for (i=1;i<20;i++)
    _line(100,100,400,i*20);
  getch();
  setplane(1);
  for (i=1;i<20;i++)
    _line(120,120,400,i*20);
  getch();
  setplane(2);
  for (i=1;i<20;i++)
    _line(130,130,400,i*20);
  getch();
  setplane(3);
  for (i=1;i<20;i++)
    _line(140,140,400,i*20);
  getch();
  setplane(0);
  clearplane();
  getch();
  setplane(1);
  clearplane();
  getch();
  setplane(2);
  clearplane();
  getch();
  setplane(3);
  clearplane();
  getch();
  setgraphicsmode(0x3);
}