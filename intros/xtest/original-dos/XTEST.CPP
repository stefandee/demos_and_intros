#include <alloc.h>
#include <string.h>
#include <conio.h>
#include <stdio.h>
#include <stdlib.h>
#include <dos.h>

#include "xmode.h"
#include "test.h"

#define MaxModes 10

char resolution[MaxModes][40] =
	{"320x200 (chained)",
	 "320x240 (square aspect ratio)",
	 "256x256 (Q mode)",
	 "360x270",
	 "320x400 (does they call this Y mode ?)",
	 "400x300 (alternative to SVGA)",
	 "360x400",
	 "360x480",
	 "360x360",
	 "376x564 (humm)"
	 };

void select()
{
  printf("[*]");
}

void unselect()
{
  printf("[ ]");
}

void menu(int option)
{
   clrscr();
   printf("This program will test the so called Mode-Xs.\n");
   printf("Many thanx to Robert Schmidt for the xcelent Tweak prg.\n");
   printf("No greets this time ;-) \n\n");
   printf("Press UP/DOWN to select a resolution.\n");
   printf("ENTER/SPACE to go.\n");
   printf("ESC to blast to your beloved OS.\n\n");

   for (int i = 0; i < MaxModes; i++)
   {
	if (i==option) select();
	else unselect();
	printf(" %s\n", resolution[i]);
   }
}

void main()
{
  int option = 0;
  char key;

  menu(option);

  while((key=getch()) != 27)
  {
    if (key == 80)
    {
	++option;
	if (option >= MaxModes) option = 0;
	menu(option);
    }
    if (key == 72)
    {
	--option;
	if (option < 0) option = (MaxModes-1);
	menu(option);
    }
    if ((key == 13) || (key == 32))
    {
       InitXMode(option);
       GradientTest();
       getch();
       BumpMap();
       TextMode();
       menu(option);
    }
  }
}