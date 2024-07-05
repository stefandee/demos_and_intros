#include "grx.h"
#include <stdlib.h>
#include <stdio.h>
#include <conio.h>
#include "mouse.h"
#include <time.h>
#include <iostream.h>
#include <math.h>

void Bump();
void Init();

byte *hmap;
byte litemap[256*256];
int frames=0;
void main()
{
   RGBcolor*p=load_pal_from_file("palette.pcx");
   hmap=load_pic_from_file("height.pcx");
   gmode(0x13);
   setpal(p);
   Init();
   clock_t start,finish;
   start=clock();
   while(!kbhit()) {Bump();};
   finish=clock();
   gmode(0x3);
   cout << "FPS = "<<frames*CLK_TCK/(finish-start);
};

void Init()
{
   float nX,nY,nZ;
   for (int y=0;y<256;y++)
   for (int x=0;x<256;x++)
   {
      nX=(x-128)/128.0;
      nY=(y-128)/128.0;
      nZ=1-sqrt(nX*nX+nY*nY);
      if (nZ<0) nZ=0;
      litemap[x+y*256]=(byte)(255<?(nZ*191+nZ*nZ*nZ*nZ*nZ*nZ*nZ*nZ*nZ*64));
   };

};



void Bump()
{
   frames++;
   int nx,ny;
   int rx,ry;
   int i=320*1;
   mouse_info mi=get_m_info();
   for (int y=1;y<198;y++)
   for (int x=0;x<320;x++)
   {
      nx=hmap[i+1]-hmap[i-1];
      ny=hmap[i+320]-hmap[i-320];

      rx=x - mi.x;
      ry=y - mi.y;

      nx-=rx;
      ny-=ry;

      nx+=128;
      ny+=128;
      if (nx>255 || nx<0) nx=255;
      if (ny>255 || ny<0) ny=255;
      dbuffer[i]=litemap[nx+ny*256];
      i++;
   };
   update_screen();
};
