#include <alloc.h>
#include <stdlib.h>
#include <dos.h>
#include <math.h>
#include <conio.h>
#include <io.h>
#include <fcntl.h>
#include <stdio.h>

#include "xmode.h"
#include "test.h"

// Simple test w/ gradients. Not too relevant for a resolution
// test. But hey ? who cares anyway :-)
void GradientTest()
{
   int color = 1;
   int j, i, width = GetWidth();
   int ystep = (256*64)/GetHeight();

   // create a nice (Red <-> Green) gradient - just for phun
   for(i=1; i<64; i++) SetRGB(i, 63-i, 0, i);

   for(i = 0; i < GetHeight(); i++)
   {
       HLine(0, width, i, color/256);
       color = color + ystep;
   }
   //for(int i=0; i<100; i++) PutPixel(random(GetWidth()), random(GetHeight()), 255);
}

// Damn bumping. Just too late...if I'd known 'bout 'em 2 or 3 years ago.
void BumpMap()
{
   char* bumpmap;
   char* vScreen;
   char* envmap;
   int i, j, width = GetWidth(), height = GetHeight(), scanline = GetScanLine();
   int lightx = 100, lighty = 100, radius = 40, degree = 0;
   int startoffset = (width/2-100)/4+(height/2-100)*(width/4);
   char crtplane = (width/2-100) & 3;
   char far* vga;
   vga = (char* far)MK_FP(0xA000, 0);

   if ((bumpmap = new char[40000]) == NULL) return;
   if ((vScreen = new char[40000]) == NULL) return;
   if ((envmap = new char[65535]) == NULL) return;

   int handle;
   if ((handle =_open("bumpmap.raw", O_RDWR | O_BINARY)) == -1) return;
   if (_read(handle, bumpmap, 40000) == -1) return;
   _close(handle);

   ClearScreen();
   // set a kool 256 blue gradient
   for(i = 0; i<256; i++) SetRGB(i, i/7, 0, i/4);

   //for(i = 0; i<255; i++) HLine(0, width, i, i);
   //getch();
  /*	for(i = 0; i<200; i++)
	  {
	     // set the plane
	     outportb(SEQ_ADDR, 0x02);
	     outportb(SEQ_ADDR+1, 0x01 << crtplane);
	     crtplane++;
	     crtplane = crtplane & 3;
	     // we have the plane - set the pixels on a column
	     for(j = 0; j<200; j++) vga[startoffset+i/4+scanline*j] = 128 + bumpmap[i+200*j]; // we can rotate the vScreen
	  }
   getch();
   */
   // compute the n-vironment map
   for(i=0; i<256; i++)
     for(j=0; j<256; j++)
       {
	  float nx = (i-128.0)/128.0;
	  float ny = (j-128.0)/128.0;
	  float nz = 1-sqrt(nx*nx+ny*ny);
	  if (nz < 0.0) nz = 0.0;
	  //envmap[i*256+j] = 256.0*nz;
	  float temp = 192*nz+63*pow(nz, 6);
	  if (temp>255) temp = 255;
	  envmap[i*256+j] = temp; // Phong illumination model !?
       }

  // main loopu'
  while(!kbhit())
    {
	lightx = radius*sin(degree*3.14/180)+100;
	lighty = radius*cos(degree*3.14/180)+100;
	degree += 4;
	degree %= 360;

	for(i = 0; i < 200; i++)
	  for(j = 0; j < 200; j++)
	    {
	       int nX=bumpmap[i+1+j*200]-bumpmap[i-1+j*200];
	       int nY=bumpmap[i+(j+1)*200]-bumpmap[i+(j-1)*200];
	       int lX=i-lightx;
	       int lY=j-lighty;
	       nX-=lX;
	       nY-=lY;
	       nX+=128;
	       nY+=128;
	       if (nX<0 || nX>255) nX=0;
	       if (nY<0 || nY>255) nY=0;
	       vScreen[i+j*200]=envmap[256*nX+nY];
	    }

	//splash the vScreen to screen
	crtplane = (width/2-100) & 3;

	for(i = 0; i<200; i++)
	  {
	     // set the plane
	     outportb(SEQ_ADDR, 0x02);
	     outportb(SEQ_ADDR+1, 0x01 << crtplane);
	     crtplane++;
	     crtplane = crtplane & 3;
	     // we have the plane - set the pixels on a column
	     for(j = 1; j<199; j++) vga[startoffset+i/4+scanline*j] = vScreen[i+j*200]; // we can rotate the vScreen
	  }
    }

    delete vScreen;
    delete bumpmap;
    delete envmap;
    getch();
    return;

}
