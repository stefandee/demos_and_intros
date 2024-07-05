#include <malloc.h>
#include <conio.h>
#include <dos.h>
typedef char tab[160][100];
//Fractal variables
float crl,crh,ci,cr,cih,cil,aux1,aux2,xsize,ysize,zr,zi,newzr,newzi;
int	  fractwidth=159,fractheight=99,maxiter=255;
tab* fractal;

//Video
int   SEQU_ADDR = 0x3c4,
			CRTC_ADDR = 0x3d4,
			VGA       = 0xa000; //constants
char pallete[255][2];

//General purpose vars
int x,y,i;

int width,height,widthbytes,actstart,vistart;

void setvisiblestart(int offset)
 {
	vistart = offset;
	asm{
	 mov dx, CRTC_ADDR
	 mov ax, 0ch
	 out dx, ax
	 inc dx
	 mov ax, vistart
	 shr ax, 8
	 out dx, ax
	 mov ax, 0dh
	 dec dx
	 out dx, ax
	 inc dx
	 mov ax, vistart
	 and ax, 0ffh
	}
 }

void setactivestart(int offset)
 {
	actstart = offset;
 }

void setactivepage(int page)
 {
	setactivestart(page * widthbytes * height);
 }

void setvisiblepage(int page)
 {
	setvisiblestart(page * widthbytes * height);
 }

void putpixel_x(int x,int y,unsigned char color)
 {
	unsigned char dummy;
	dummy = 0x01 << (x & 3);
	asm{
	 mov dx, SEQU_ADDR
	 mov al, 02h
	 out dx, al
	 inc dx
	 mov al, dummy
	 out dx, al
	 mov dx, VGA
	 mov es, dx
	 mov bx, [x]
	 shr bx, 2
	 mov di, [y]
	 mov ax, di
	 shl di, 6
	 shl ax, 4
	 add di,ax
	 add di, actstart
	 add di, bx
	 mov al, color
	 mov es:[di],al
	}
 }

void modex(void)
 {
	asm{
	 mov ax, 13h
	 int 10h
	 mov bx, SEQU_ADDR  //init chain-4
	 mov dx,bx
	 mov ax, 0604h
	 out dx, ax
	 mov dx, CRTC_ADDR  //turn off word mode
	 mov ax, 0e317h
	 out dx, ax
	 mov ax, 14h        //turn off double word mode
	 out dx, ax
	 mov dx, bx;        //clear video memory-select all four planes
	 mov ax, 0F02h
	 out dx, ax
	 xor di, di         // clear thy mem
	 xor ax, ax
	 mov dx, VGA
	 xor ax, ax
	 mov es, dx
	 mov cx, 32000
	 rep stosw
	}
	height     = 200;
	width      = 320;
	widthbytes = 80;
	actstart   = 0;
	vistart    = 0;
 }

void waitretrace(void)
 {
	 asm{
			 mov dx,3DAh
      }
	 l1:;
	 asm{
			 in al,dx
			 and al,08h
			 jnz l1
			}
	 l2:;
	 asm{
			 in al,dx
			 and al,08h
			 jz  l2
	 };
 }


void setpal(void)
 {
	 int pseg,pofs;
   pseg = FP_SEG(pallete);
	 pofs = FP_OFF(pallete);
	 asm{
			push ds
			mov ax,pseg
			mov ds,ax
			mov si,pofs
	 };
	 waitretrace();
	 asm{
			mov dx,3c8h
			mov al,0
			out dx,al
			inc dx
			mov cx,384
			rep outsb
	 };
	 waitretrace();
	 asm{
			mov dx,3c8h
			mov al,128
			out dx,al
			inc dx
			mov cx,384
			rep outsb
			pop ds
	 }
}

void totextmode(void)
 {
	asm{
	 mov ax,0003h
	 int 10h
	}
 }

void main()
{
 modex();
 setvisiblepage(0);
 setactivepage(0);

 //create pallete
 for(i=0;i<63;i++)
	{
		pallete[i][0]=i;pallete[i][1]=0;pallete[i][2]=0;
		pallete[i+64][0]=0;pallete[i+64][1]=i;pallete[i+64][2]=0;
		pallete[i+128][0]=0;pallete[i+128][1]=0;pallete[i+128][2]=i;
		pallete[i+192][0]=i;pallete[i+192][1]=i;pallete[i+192][2]=i;
	}

 setpal();
 fractal = (tab*)malloc(sizeof(tab));

 for(y=0;y<319;y++) putpixel_x(50,y,62);

 crh=1.3232;crl=-1;
 cih=-1.5437437;cil=0;

 ysize=2*(crh-crl)/fractwidth;
 xsize=2*(cih-cil)/fractheight;
 ci=cil;

 for(y = 0;y<fractheight;y++)
	{
		cr= crl;
		for(x= 0;x<fractwidth;x++)
		 {
			 zr= 0;zi= 0;
			 for(i= 1;i<maxiter;i++)
				{
					aux1= zr*zr;
					aux2= zi*zi;
					newzr= aux1-aux2+cr;
					newzi= 2*zr*zi+ci;
					zr= newzr;
					zi= newzi;
					if (aux1+aux2>4) break;
				};
				if (255-i<210) putpixel_x(x,y,255-i);
				cr= xsize+cr;
		 }
		ci= ysize+ci;
	}

 {for (x=0;x<fractheight;x++) for(y=0;y<fractwidth;y++) putpixel_x(80+x,50+y,*fractal[y][x]);}
 getch();
 totextmode();
}

