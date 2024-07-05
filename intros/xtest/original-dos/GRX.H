/*
   NAME:    GRP.H
   DESC:    Graphics header for true 3d-project
    VER:    0.1
     BY:    Aaru Koskensilta (Zaphod.B)
*/

#ifndef _GRP_H_
#define _GRP_H_

/* Data defines */
#define byte   unsigned char
#define word   unsigned short
#define dword  unsigned long


/* Double buffer */
extern byte dbuffer[64000];

/* RGB-colour structure */
struct RGBcolor
{
   byte r,g,b;
};

struct sprite
{
   int x,y;
   byte*image;
};

/* Current palette */
extern RGBcolor current_palette[256]; 

/* Load PCX-pic from file */
byte * load_pic_from_file(char*);

/* Load sprite from file */
sprite * load_sprite_from_file(char*);

/* Set graphics mode */
void gmode(short);

/* Load palette from PCX-file */
RGBcolor * load_pal_from_file(char*);

/* Set palette */
void setpal(RGBcolor*);

/* Plot a pixel */
void plot(short,short,byte);

/* Copy doublebuffer to screen */
void update_screen();

/* Draw a line */
void line(int,int,int,int,char);

/* Place sprite on screen */
void place_sprite(int,int,sprite*);

/* Place sprite as 1 colored on screen. Usefull for fonts and that kind o'
   stuff */
void place_sprite_1cl(int,int,sprite*,byte);

/* Place sprite as 1 colored and inverted on screen. */
void place_sprite_inv(int,int,sprite*,byte);

/* Draw a horizontal line */
void horiz_line(int,int,int,byte);

/* Draw a vertical line */
void vert_line(int,int,int,byte,int,int);

/* Draw a rectangle */
void rect(int,int,int,int,byte);

/* Draw a window (Embosed) */
void DrawWindow(int,int,int,int,byte clr=7);
/* PCX-header */
struct PCXheader
{
   char mfacturer;
   char version;
   char encoding;
   char bit_per_pixel;
   short Xmin;
   short Ymin;
   short Xmax;
   short Ymax;
   short Hres;
   short Vres;
   char hpalette[48];
   char reserved;
   char planes;
   short bpline;
   short headerpal;
   char filler[58];
};


#endif
