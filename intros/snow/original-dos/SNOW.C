//Smart snow, by Karg of WOS

#include <graphics.h>
#include <stdlib.h>
#include <dos.h>
#include <math.h>
#include <stdio.h>
#include <time.h>

#include "data.h"

void checkerrors(void);

#define MaxSnow 350
#define PI180 0.017453292

typedef struct{
		float x,y;
		float incy;
		int ang;
} TSnowPixel;

TSnowPixel Snow[MaxSnow];

int SnowState = 0;

void UpDateSnow(int index)
{
	Snow[index].x = random(640);
	if (SnowState==0) Snow[index].y = random(480);
		else Snow[index].y = 0;
	Snow[index].ang = 0;
	Snow[index].incy = (float)random(16384)/32767+0.4;
}

int main(void)
{
	 int gdriver=DETECT, gmode, i;
	 char* channelcomp;

	 randomize();
	 gdriver = installuserdriver("SVGA256", NULL);
	 gmode = 2;//this should be 640x480
	 checkerrors();
	 initgraph(&gdriver, &gmode, "");
	 checkerrors();

	 channelcomp = (char*)MK_FP(FP_SEG(_snowpal),FP_OFF(_snowpal));
	 for(i=0;i<255;i++,channelcomp+=3) setrgbpalette(i,*channelcomp,*(channelcomp+1),*(channelcomp+2));

	 //init pal
	 //setrgbpalette(255,63,63,63);
	 //setrgbpalette(254,63,0,0);
	 //init the snow
	 for(i=0;i<MaxSnow;i++) UpDateSnow(i);SnowState = 1;
	 setfillstyle(SOLID_FILL, 255);
	 pieslice(320, 400, 0, 360, 30);
	 setcolor(254);
	 settextjustify(CENTER_TEXT, CENTER_TEXT);
	 settextstyle(0,HORIZ_DIR,8);
	 outtextxy(320,300,"ZAPADA");

	 //main loop
	 while(inportb(0x60)>128){
		 for(i=0;i<MaxSnow;i++){
				putpixel(Snow[i].x,Snow[i].y,0);
				if (getpixel(Snow[i].x,Snow[i].y+1)!=0)
					 if (getpixel(Snow[i].x+1,Snow[i].y+1)!=0)
							if (getpixel(Snow[i].x-1,Snow[i].y+1)!=0){
									putpixel(Snow[i].x,Snow[i].y,255);
									UpDateSnow(i);
							 }
									else {
										 Snow[i].y++;
										 Snow[i].x--;
									}
							else {
								 Snow[i].y++;
								 Snow[i].x++;
							}
					 else {
							Snow[i].y = Snow[i].y + Snow[i].incy;
							Snow[i].ang += 5 % 360;
							Snow[i].x += 4*cos(Snow[i].ang*PI180)*sin(2.5*PI180);
							if (getpixel(Snow[i].x,Snow[i].y)!=0) Snow[i].x-=4*cos(Snow[i].ang*PI180)*sin(2.5*PI180);
					 }
				putpixel(Snow[i].x,Snow[i].y,255);
				if (Snow[i].y>=getmaxy()) UpDateSnow(i);
		 }
	 };
	 closegraph();
   return 0;
}

// comment : check for and report any graphics errors
void checkerrors(void)
{
	 int errorcode;
	 errorcode = graphresult();
	 if (errorcode != grOk)
	 {
			//cout.write("Graphics error occured.",24);
			printf("Graphics error: %s\n", grapherrormsg(errorcode));
			exit(1);
	 }
}
