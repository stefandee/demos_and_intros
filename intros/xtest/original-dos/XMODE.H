#define _XMODEH
/*
	xxxxADDR defines the base port number used to access VGA component xxxx,
	and is defined for xxxx =
		ATTRCON		-	Attribute Controller
		MISC		-	Miscellaneous Register
		VGAENABLE	-	VGA Enable Register
		SEQ			-	Sequencer
		GRACON		-	Graphics Controller
		CRTC		-	Cathode Ray Tube Controller
		STATUS		-	Status Register
*/

#define ATTRCON_ADDR		0x3c0
#define MISC_ADDR		0x3c2
#define VGAENABLE_ADDR		0x3c3
#define SEQ_ADDR		0x3c4
#define GRACON_ADDR		0x3ce
#define CRTC_ADDR		0x3d4
#define STATUS_ADDR		0x3da

typedef struct
	{
	unsigned port;
	unsigned char index;
	unsigned char value;
	} Register;

typedef Register *RegisterPtr;

int InitXMode(int whatmode);
int TextMode();
void PutPixel(int x, int y, char color);
char GetPixel(int x, int y);
int GetWidth();
int GetHeight();
int GetScanLine();
void SetRGB(char index, char red, char green, char blue);
void ClearScreen();
void Line(int xstart, int ystart, int xend, int yend, char color);
void HLine(int xstart, int xend, int y, char color);
