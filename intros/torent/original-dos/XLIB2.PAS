{La procedura XTriangle am modificat-o sa cheme
 procedura HLineClipR2 in loc de HLineClipR}
{ษออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออป
 บ                                                                          บ
 บ               XLIB v1.0 for BORLAND/TURBO PASCAL 6.0/7.0                 บ
 บ                                                                          บ
 ฬออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออน
 บ 																																					บ
 บ 										   Original version written by				            		บ
 บ 			Themie Gouthas  (egg@dstos3.dsto.gov.au / teg@bart.dsto.gov.au)     บ
 บ 																																					บ
 บ 								  Conversion to Borland/Turbo Pascal by				  					บ
 บ 								Tristan Tarrant (tristant@cogs.susx.ac.uk)								บ
 บ 																																					บ
 ศออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผ}

Unit XLib2;

Interface

Type
	Vertex = record
		x, y : word;
	end;
	VBMInfoStruc = record
		Size, ImageWidth, ImageHeight : word;
	end;
	VBMAlignmentStruc = record
		ImagePtr, MaskPtr : word;
	end;
	AlignmentHeader = record
		size, ImageWidth, ImageHeight : word;
		alignments : array[0..3] of
		record
			 ImagePtr, MaskPtr : word;
		end;
	end;
	LBMHeader = record
		width, height : byte;
	end;
	PAlignmentHeader = ^AlignmentHeader;

Const
	XMode320x200	= 0;
	XMode320x240	= 1;
	XMode360x200  = 2;
	XMode360x240  = 3;
	XMode376x282  = 4;
	XMode320x400  = 5;
	XMode320x480  = 6;
	XMode360x400  = 7;
	XMode360x480  = 8;
	XMode360x360  = 9;
	XMode376x308  = 10;
	XMode376x564  = 11;
	XMode256x200  = 12;
	XMode256x240  = 13;

	RBackward			= 0;
	RForward      = 1;
	InvalidXMode	= -1;
	Error         = 1;
	AlignData		  = 6;
	TweakValues : array[0..180] of word =
		( $0200, $0014, $E317, 320, 200,
			$0AE3, $0D06, $3E07, $4109, $EA10, $AC11, $DF12, $0014, $E715, $0616,
				$E317, 320, 240,
			$08E7, $6B00, $5901, $5A02, $8E03, $5E04, $8A05, $0014, $E317, 360, 200,
			$11E7, $6b00, $5901, $5A02, $8E03, $5E04, $8A05, $0D06, $3E07, $4109,
				$EA10, $AC11, $DF12, $2D13, $0014, $E715, $0616, $E317, 360, 240,
			$12E7, $6E00, $5D01, $5E02, $9103, $06204, $8F05, $6206, $F007, $6109,
				$310F, $3710, $8911, $3312, $2F13, $0014, $3C15, $5C16, $E317, 376, 564,
			$03E3, $4009 ,$0014, $E317, 320, 400,
			$0AE3, $0D06, $3E07, $4009, $EA10, $AC11, $DF12, $0014, $E715, $0616,
				$E317, 320, 480,
			$09E7, $6B00, $5901, $5A02, $8E03, $5E04, $8A05, $4009, $0014, $E317,
				360, 400,
			$11E7, $6B00, $5901, $5A02, $8E03, $5E04, $8A05, $0D06, $3E07, $4009,
				$EA10, $AC11, $DF12, $2D13, $0014, $E715, $0616, $E317, 360, 480,
			$0FE7, $6b00, $5901, $5A02, $8E03, $5E04, $8A05, $4009, $8810, $8511,
				$6712, $2D13, $0014, $6D15, $BA16, $E317, 360, 360,
			$12E7, $6E00, $5D01, $5E02, $9103, $6204, $8F05, $6206, $0F07, $4009,
				$310F, $3710, $8911, $3312, $2F13, $0014, $3C15, $5C16, $E317, 376, 308,
			$12E7, $6E00, $5D01, $5E02, $9103, $6204, $8F05, $6206, $F007, $6009,
				$310F, $3710, $8911, $3312, $2F13, $0014, $3C15, $5C16, $E317, 376, 564 );

	ModeTable : array[0..11] of word =
		( Ofs(TweakValues[0]), Ofs(TweakValues[5]), Ofs(TweakValues[18]),
			Ofs(TweakValues[29]), Ofs(TweakValues[49]), Ofs(TweakValues[70]),
			Ofs(TweakValues[76]), Ofs(TweakValues[89]), Ofs(TweakValues[101]),
			Ofs(TweakValues[121]), Ofs(TweakValues[139]), Ofs(TweakValues[160]) );

	MirrorTable : array[0..255] of byte =
		( 0,128, 64,192, 32,160, 96,224, 16,144, 80,208, 48,176,112,240,
			8,136, 72,200, 40,168,104,232, 24,152, 88,216, 56,184,120,248,
			4,132, 68,196, 36,164,100,228, 20,148, 84,212, 52,180,116,244,
		 12,140, 76,204, 44,172,108,236, 28,156, 92,220, 60,188,124,252,
			2,130, 66,194, 34,162, 98,226, 18,146, 82,210, 50,178,114,242,
		 10,138, 74,202, 42,170,106,234, 26,154, 90,218, 58,186,122,250,
			6,134, 70,198, 38,166,102,230, 22,150, 86,214, 54,182,118,246,
		 14,142, 78,206, 46,174,110,238, 30,158, 94,222, 62,190,126,254,
			1,129, 65,193, 33,161, 97,225, 17,145, 81,209, 49,177,113,241,
			9,137, 73,201, 41,169,105,233, 25,153, 89,217, 57,185,121,249,
			5,133, 69,197, 37,165,101,229, 21,149, 85,213, 53,181,117,245,
		 13,141, 77,205, 45,173,109,237, 29,157, 93,221, 61,189,125,253,
			3,131, 67,195, 35,163, 99,227, 19,147, 83,211, 51,179,115,243,
		 11,139, 75,203, 43,171,107,235, 27,155, 91,219, 59,187,123,251,
			7,135, 71,199, 39,167,103,231, 23,151, 87,215, 55,183,119,247,
		 15,143, 79,207, 47,175,111,239, 31,159, 95,223, 63,191,127,255 );

	PelPanMask : array[0..3] of byte =
		( 0, 2, 4, 6 );
	LeftClipPlaneMask  : array[0..3] of byte =
		( $0F, $0E, $0C, $08 );
	RightClipPlaneMask : array[0..3] of byte =
		( $0F, $01, $03, $07 );
	ColumnMask : array[0..3] of byte =
		( $11, $22, $44, $88 );
	LeftMaskTable : array[0..8] of byte =
		( 0, $ff, $ee, 0, $cc, 0, 0, 0, $88 );
	RightMaskTable: array[0..8] of byte =
		(	0, $11, $33, 0, $77, 0, 0, 0, $ff );
	InitMouseDef : array[0..13] of byte =
		(1,3,7,15,31,63,127,255,31,27,48,48,96,96);
	LeftDelay : array[0..3] of byte =
		( 0, 1, 2, 4 );
	RightDelay : array[0..3] of byte =
		( 0, 4, 2, 1 );

	MaskedPointSize = 11;
	AcIndex       =  $03C0;
	MiscOutput    =  $03C2;
	ScIndex       =  $03C4;
	GcIndex       =  $03CE;
	CrtcIndex     =  $03D4;
	DACReadIndex  =  $03C7;
	DACWriteIndex =  $03C8;
	DACData       =  $03C9;
	InputStatus0  =  $03DA;
	ScreenSeg     =  $0A000;
	MapMask       =  $02;
	ReadMap       =  $04;
	BitMask       =  $08;
	Overflow      =  $07;
	MaxScanLine   =  $09;
	AddrHigh      =  $0C;
	AddrLow       =  $0D;
	CrtcOffset    =  $13;
	Underline     =  $14;
	ModeControl   =  $17;
	LineCompare   =  $18;
	AcModeControl =  $10;
	PelPanning    =  $13;
	PatternBuffer =  $0FFFC;
	OK            =  0;
	LastXMode     =  11;
	RolAl         =  $0C0D0;
	ShortStore8   =  $044C6;
	Store8        =  $084C6;
	ShortStore16  =  $044C7;
	Store16       =  $084C7;
	AdcSiImmed    =  $0D683;
	OutAl         =  $0EE;
	Return        =  $0CB;
	LowWord       =  0;
	HighWord      =  2;
	XCoord      	=  4;
	YCoord      	=  0;
	E1Src     	  =  48;
	C1Src  	  	  =  40;
	C2Src       	=  32;
	E2Src       	=  24;
	E1Dest      	=  48;
	P1Dest      	=  40;
	P4Dest      	=  32;
	P6Dest      	=  24;
	P5Dest      	=  16;
	P2Dest      	=  8;
	E2Dest      	=  0;
	E1Draw      	=  24;
	C1Draw      	=  16;
	C2Draw      	=  8;
	E2Draw      	=  0;
	LeftPressed   =  1;
	RightPressed  =  2;
	i86       = 0;
	i186      = 1;
	i286      = 2;
	i386sx    = 3;
	i386dx    = 4;
	i486      = 5;
	NONE      = 0;
	MDA       = 1;
	CGA       = 2;
	EGAMono   = 3;
	EGAColor  = 4;
	VGAMono   = 5;
	VGAColor  = 6;
	MCGAMono  = 7;
	MCGAColor = 8;
	PS2CARDS : array[0..12] of byte = ( 0,1,2,2,4,3,2,5,6,2,8,7,8 );
	TIMERVECT    = $08;
	PICCMD       = $20;
	NONSPECEOI   = $20;
	TIMERMODE    = $34;
	TIMERCONTROL = $43;
	TIMER0       = $40;
	LATCHCOUNT   = $00;
	INTINADVANCE = 100;
	DOSGETVECT   = $3500;
	DOSSETVECT   = $2500;


	

Var
	InGraphics,
	ErrorValue,
	FontDriverActive,
	CharHeight,
	CharWidth,
	FirstChar,
	UserChHeight,
	UserChWidth,
	UserFirstCh,
	DoubleScanFlag : Byte;
	CurrXMode,
	ScrnPhysicalByteWidth,
	ScrnPhysicalPixelWidth,
	ScrnPhysicalHeight,
	SplitScrnOffs,
	SplitScrnScanLine,
	SplitScrnVisibleHeight,
	SplitScrnActive,
	Page0Offs,
	Page1Offs,
	Page2Offs,
	ScrnLogicalByteWidth,
	ScrnLogicalPixelWidth,
	ScrnLogicalHeight,
	MaxScrollX,
	MaxScrollY,
	DoubleBufferActive,
	TripleBufferActive,
	VisiblePageIdx,
	HiddenPageOffs,
	VisiblePageOffs,
	WaitingPageOffs,
	NonVisualOffs,
	TopClip,
	BottomClip,
	LeftClip,
	RightClip,
	PhysicalStartPixelX,
	PhysicalStartByteX,
	PhysicalStartY,
	VsyncHandlerActive,
	MouseRefreshFlag,
	StartAddressFlag,
	WaitingStartLow,
	WaitingStartHigh,
	WaitingPelPan,
	VsyncPaletteStart,
	VsyncPaletteCount,
	MirrorTableOffs,
	MouseInstalled,
	MouseHidden,
	MouseButtonStatus,
	MouseButtonCount,
	MouseX,
	MouseY,
	OldHandlerSeg,
	OldHandlerOffs,
	OldHandlerMask,
	OldX,
	OldY,
	OldScrnOffs,
	BGSaveOffs,
	TopBound,
	BottomBound,
	LeftBound,
	RightBound,
	MouseVersion,
	TicksPerSecond,
	VsyncIntTicksLo,
	VsyncIntTicksHi,
	VsyncPeriod,
	ClockRate,
	ClockCounter,
	UserVsyncOffs,
	UserVsyncSeg,
	InUserHandler,
	StackSeg,
	StackPtr,
	ElapsedVrts,
	VrtsToSkip : word;
	MouseFrozen,
	MouseColor,
	MouseType,
	MouseIRQ,
	inhandler : byte;
	FontPtr,
	UserFontPtr,
	F8x8Ptr,
	F8x14Ptr,
	MouseVSyncHandler : pointer;
	MouseMask : array[0..167] of byte;
	VSyncPaletteBuffer : array[0..767] of byte;

Function  XSetMode( Mode, WidthInPixels : Word ) : Word; { works ! }
Procedure XSelectDefaultPlane( Plane : Byte ); { works ! }
Procedure XSetSplitscreen( Line : Word ); { works ! }
Procedure XSetStartAddr( X, Y : Word ); { works ! }
Procedure XHideSplitscreen; { works ! }
Procedure XShowSplitscreen; { works ! }
Procedure XAdjustSplitscreen( Line : Word ); { works ! }
Procedure XSetDoubleBuffer( PageHeight : Word ); { works ! }
Procedure XSetTripleBuffer( PageHeight : word );
Procedure XPageFlip( X, Y : Word ); { works ! }
Procedure XPageFlipFast( X, Y : Word ); { works ! Obs:Nu are WaitForR}
Procedure XSetClipRect( Left, Top, Right, Bottom : Word );
Procedure XTextMode; { works ! }
Procedure XWaitVsync; { works ! }
Procedure XLine( x1, y1, x2, y2, Color, PgOffs : word ); { works ! }
Procedure XPutPix( X,Y,PgOfs,Color:word ); { works ! }
Function  XGetPix( x,y,PageBase:word ) : word; { works ! }
Procedure XRectFill( StartX,StartY,EndX,EndY,PageBase,Color:word ); { works ! }
Procedure XRectPattern( StartX,StartY,EndX,EndY,PageBase:word;var Pattern); { works ! }
Procedure XCpVidRect( SrcStartX,SrcStartY,SrcEndX,SrcEndY,DestStartX,
											DestStartY,SrcPageBase,DestPageBase,SrcBitmapW,
											DestBitmapW:word );
Procedure XShiftRect( SrcLeft,SrcTop,SrcRight,SrcBottom,DestLeft,DestTop,
											ScreenOffs:word ); { works ! }
Procedure XCircle( Left, Top, Diameter, Color, ScreenOffs:word ); { works ! }
Procedure XFilledCircle( Left, Top, Diameter, Color, ScreenOffs:word ); { works ! }
Procedure XPbmToBm( var source, dest ); { works ! }
Procedure XBmToPbm( var source, dest ); { works ! }
Procedure XPutMaskedPbm( X, Y,ScrnOffs : word; var Bitmap ); { works ! }
Procedure XPutPbm( X,Y,ScrnOffs:word; var Bitmap ); { works ! }
Procedure XGetPbm( X,Y: word;SrcWidth,SrcHeight:byte;
									 ScrnOffs:word; var Bitmap );  { works ! }
Procedure XCompilePbm( LogicalWidth : word; var bitmap, output ); { works ! }
Function  XSizeOfCPbm( logicalwidth : word; var bitmap ) : word; { works ! }
Procedure XCompileBitmap( logicalwidth:word; var bitmap, output ); { works ! }
Function  XSizeOfCBitmap( logicalwidth:word; var bitmap ):word; { works ! }
Procedure XPutCBitmap( XPos,YPos,PageOffset:word; var Sprite ); { works ! }
Procedure XGetPalStruc( var PalBuff; NumColors,StartColor:word ); { works ! }
Procedure XGetPalRaw( Var PalBuff; NumColors,StartColor:word ); { works ! }
Procedure XPutPalStruc( Var CompPalBuff ); { works ! }
Procedure XTransposePalStruc( Var CompPalBuff; StartColor:word );
Procedure XPutPalRaw( Var PalBuff; NumColors,StartColor:word ); { works ! }
Procedure XSetRGB( ColorIndex,R,G,B:byte ); { works ! }
Procedure XRotPalStruc( Var PalBuff; Direction:word ); { works ! }
Procedure XRotPalRaw( Var PalBuff; Direction, NumColors:word ); { works ! }
Function  XCpContrastPalStruc( Var PalSrcBuff,PalDestBuff; Intensity:byte ) : word; { works ! }
Procedure XPutContrastPalStruc( Var CompPalBuff; Intensity:byte );
Function  XCharPut( Chr:char; X, Y, ScrnOffs, Color:word ) : byte; { works ! }
Procedure XSetFont( FontID : word ); { works ! }
Procedure XTextInit; { works ! }
Procedure XRegisterUserFont( var FontToRegister ); { works ! }
Procedure XPrintf( x, y, ScrnOffs, Color : word; s : string ); { works ! }
Procedure XBgPrintf( x, y, ScrnOffs, fgcolor, bgcolor : word; s : string ); { works ! }
Procedure XTriangle( X0, Y0, X1, Y1, X2, Y2, Color, PageOffset:word ); { works ! }
Procedure XPolygon( var vertices; numvertices, Color, PageOffset:word ); { works ! }
Procedure XPutCursor( X, Y, TopClip, BottomClip, ScrnOffs : word );
Procedure XDefineMouseCursor( var MouseDef; MouseColor:byte );
procedure XMouseInit; { works ! }
Procedure XMouseWindow( x0, y0, x1, y1:word ); { works ! }
procedure XShowMouse; { works ! }
Procedure XHideMouse; { works ! }
Procedure XMouseRemove; { works ! }
Procedure XPositionMouse( X, Y : word ); { works ! }
Procedure XUpdateMouse; { works ! }
Procedure XPutMaskedPBMClipX( X, Y, ScrnOffs:word; var Bitmap ); { works ! }
procedure XPutMaskedPBMClipY( X, Y, ScrnOffs:word; var Bitmap ); { works ! }
Procedure XPutMaskedPBMClipXY( X, Y, ScrnOffs:word; var Bitmap ); { works ! }
Procedure XPutPBMClipX( X, Y, ScrnOffs:word; var Bitmap ); { works ! }
Procedure XPutPBMClipY( X, Y, ScrnOffs : word; var Bitmap ); { works ! }
Procedure XPutPBMClipXY( X, Y, ScrnOffs:word; var Bitmap ); { works ! }
Procedure XStoreVBMImage( VramOffs,Align:word; var LBitmap ); { works ! }
Procedure XPutMaskedVBM( X, Y, ScrnOffs:word; var SrcVBM ); { works ! }
Procedure XPutMaskedVBMClipX( X, Y, ScrnOffs:word; var SrcVBM ); { works ! }
Procedure XPutMaskedVBMClipY( X, Y, ScrnOffs : word; var SrcVBM ); { works ! }
Procedure XPutMaskedVBMClipXY( X, Y, ScrnOffs:word; var SrcVBM ); { works ! }
Function  XMakeVBM( var lbm; var VramStart : word ) : PAlignmentHeader; { works ! }

Implementation

Function	XSetMode( Mode, WidthInPixels : Word ) : Word; assembler;
asm
	mov InGraphics,0
	mov ErrorValue,0
	mov DoubleScanFlag,0
	mov CurrXMode,0
	mov ScrnPhysicalByteWidth,0
	mov	ScrnPhysicalPixelWidth,0
	mov ScrnPhysicalHeight,0
	mov SplitScrnOffs,0
	mov SplitScrnScanLine,0
	mov SplitScrnVisibleHeight,0
	mov SplitScrnActive,0
	mov Page0Offs,0
	mov Page1Offs,0
	mov Page2Offs,0
	mov ScrnLogicalByteWidth,0
	mov ScrnLogicalPixelWidth,0
	mov ScrnLogicalHeight,0
	mov MaxScrollX,0
	mov MaxScrollY,0
	mov DoubleBufferActive,0
	mov VisiblePageIdx,0
	mov HiddenPageOffs,0
	mov VisiblePageOffs,0
	mov NonVisualOffs,0
	mov TopClip,0
	mov BottomClip,0
	mov LeftClip,0
	mov RightClip,0
	mov PhysicalStartPixelX,0
	mov PhysicalStartByteX,0
	mov PhysicalStartY,0
	cld
	mov   ax,ds
	mov   es,ax
	mov   cx,mode
	cmp   cx,13
	jle   @@ValidMode
	mov   InGraphics,0
	mov   ax,-1
	jmp @@Done

@@ValidMode:
	mov   CurrXMode,cx
	mov   InGraphics,1
	xor   al,al
	cmp   cx,3
	jg    @@SetDoubleScanFlag
	mov   al,1

@@SetDoubleScanFlag:
	mov   DoubleScanFlag,al
	push  cx
	mov   ax,13h
	int   10h
	pop   cx
	mov   dx,ScIndex
	mov   ax,0604h
	out   dx,ax
	mov   ax,0100h
	out   dx,ax
	mov   bx,offset ModeTable
	shl   cx,1
	add   bx,cx
	mov   si, word ptr [bx]
	lodsb
	or    al,al
	jz    @@DontSetDot
	mov   dx,MISCOUTPUT
	out   dx,al

@@DontSetDot:
	mov   dx,ScIndex
	mov   ax,0300h
	out   dx,ax
	mov   dx,CrtcIndex
	mov   al,11h
	out   dx,al
	inc   dx
	in    al,dx
	and   al,07fh
	out   dx,al
	dec   dx
	cld
	xor   cx,cx
	lodsb
	mov   cl,al

@@SetCRTParmsLoop:
	lodsw

	out   dx,ax
	loop  @@SetCRTParmsLoop
	mov   dx,ScIndex
	mov   ax,0f02h
	out   dx,ax
	mov   ax,ScreenSeg
	mov   es,ax
	sub   di,di
	sub   ax,ax
	mov   cx,8000h
	rep   stosw
	lodsw
	mov   ScrnPhysicalPixelWidth,ax
	mov   SplitScrnScanLine,ax
	mov   bx,ax
	shr   ax,2
	mov   ScrnPhysicalByteWidth,ax
	lodsw
	mov   ScrnPhysicalHeight,ax
	mov   cx,widthinpixels
	mov   dx,CrtcIndex
	mov   al,CRTCOFFSET
	out   dx,al
	inc   dx
	mov   ax,cx
	cmp   ax,ScrnPhysicalPixelWidth
	jge   @@ValidLogicalWidth
	mov   ax,bx

@@ValidLogicalWidth:
	shr   ax,3
	out   dx,al
	shl   ax,1
	mov   bx,ax
	mov   ScrnLogicalByteWidth,ax
	mov   RightClip,ax
	sub   ax,ScrnPhysicalByteWidth
	shl   ax,2
	mov   MaxScrollX,ax
	mov   ax,bx
	shl   ax,2
	mov   ScrnLogicalPixelWidth,ax
	mov   cx,ax
	mov   ax,0ffffh
	sub   dx,dx
	div   bx
	mov   ScrnLogicalHeight,ax
	mov   BottomClip,ax
	sub   ax,ScrnPhysicalHeight
	mov   MaxScrollY,ax
	mov   ax,cx
	mov   ax,ScrnLogicalByteWidth
	mul   ScrnPhysicalHeight
	mov   NonVisualOffs,ax

@@Done:
	mov		ax, 0CB00h
	int		10h

End;

Procedure XSelectDefaultPlane( Plane : Byte ); assembler;
asm
	mov  cl,Plane
	and  cl,011b
	mov  ax,0100h + MapMask
	shl  ah,cl
	mov  dx,ScIndex
	out  dx,ax
	mov  ah,cl
	mov  al,ReadMap
	mov  dx,GcIndex
	out  dx,ax
end;

Procedure XSetSplitscreen( Line : Word ); assembler;
asm
	xor  si,si
	cmp  DoubleBufferActive,0
	jne  @@error
	cmp  SplitScrnActive,0
	je   @@NotPreviouslyCalled

@@error:
	mov  ErrorValue,ERROR
	ret

@@NotPreviouslyCalled:
	mov  dx,InputStatus0
	in   al,dx
	mov  al,ACMODECONTROL+20h
	mov  dx,ACINDEX
	out  dx,al
	inc  dx
	in   al,dx
	or   al,20h
	dec  dx
	out  dx,al
	mov  PhysicalStartByteX,ax
	mov  PhysicalStartPixelX,ax
	mov  PhysicalStartY,ax
	mov  SplitScrnActive,1
	mov  ax,Line
	jns  @@NotNeg
	mov  ax,0

@@NotNeg:
	mov  SplitScrnScanLine,ax
	or   DoubleScanFlag,0
	jz   @@NotDoubleScanned
	shl  ax,1
	dec  ax

@@NotDoubleScanned:
	mov  bx,ax
	mov  dx,InputStatus0

@@WaitNotVsync:
	in   al,dx
	test al,08h
	jnz  @@WaitNotVsync

@@WaitVsync:
	in   al,dx
	test al,08h
	jz   @@WaitVsync
	{cli}
	mov  dx,CrtcIndex
	mov  ah,bl
	mov  al,LINECOMPARE
	out  dx,ax
	mov  ah,bh
	and  ah,1
	shl  ah,4
	mov  al,Overflow
	out  dx,al
	inc  dx
	in   al,dx
	and  al, not 10h
	or   al,ah
	out  dx,al
	dec  dx
	mov  ah,bh
	and  ah,2
	ror  ah,3
	mov  al,MAXSCANLINE
	out  dx,al
	inc  dx
	in   al,dx
	and  al, not 40h
	or   al,ah
	out  dx,al
	{sti}
	mov  ax,ScrnPhysicalHeight
	sub  ax,SplitScrnScanLine
	mov  SplitScrnVisibleHeight,bx
	mov  bx,ScrnLogicalByteWidth
	mul  bx
	mov  Page0Offs,ax
	mov  Page1Offs,ax
	mov  Page2Offs,ax
	mov  cx,0ffffh
	sub  cx,ax
	xchg cx,ax
	sub  dx,dx
	div  bx
	mov  ScrnLogicalHeight,ax
	cmp  ax,BottomClip
	jle  @@BottomClipOK
	mov  BottomClip,ax

@@BottomClipOK:
	sub  ax,SplitScrnScanLine
	mov  MaxScrollY,ax
	xchg cx,ax
	mov  bh,al
	mov  ch,ah
	mov  bl,ADDRLOW
	mov  cl,ADDRHIGH
	and  si,0003h
	mov  ah,byte ptr PelPanMask[si]
	mov  al,PELPANNING+20h
	mov  si,ax
	mov  dx,InputStatus0

@@WaitDE:
	in   al,dx
	test al,01h
	jnz  @@WaitDE
	mov  dx,CrtcIndex
	mov  ax,bx
	out  dx,ax
	mov  ax,cx
	out  dx,ax
	mov  dx,ACINDEX
	mov  ax,si
	out  dx,al
	mov  al,ah
	out  dx,al
	mov  dx,InputStatus0

@@WaitVS:
	in   al,dx
	test al,08h
	jz @@WaitVS
	mov  ErrorValue,OK
end;

Procedure XSetStartAddr( X, Y : Word ); assembler;
asm
	mov  si,x
	mov  ax,ScrnLogicalByteWidth
	mov  cx,y
	mul  cx
	cmp  DoubleBufferActive,1
	je   @@PageResolution
	cmp  TripleBufferActive,1
	je   @@PageResolution

@@PageFlipEntry1:
	add  ax,Page0Offs
	jmp  @@AddColumn

@@PageFlipEntry2:
	mov  PhysicalStartPixelX,si
	mov  PhysicalStartY,cx

@@PageResolution:
	add  ax,VisiblePageOffs

@@AddColumn:
	mov  cx,si
	shr  cx,2
	mov  PhysicalStartByteX,cx
	add  ax,cx
	mov  bh,al
	mov  ch,ah

@@StartAddrEntry:
	mov  bl,ADDRLOW
	mov  cl,ADDRHIGH
	and  si,0003h
	mov  ah,byte ptr PelPanMask[si]
	mov  al,PELPANNING+20h
	mov  si,ax

	mov  dx,InputStatus0
@@WaitDE:
	in   al,dx
	test al,01h
	jnz  @@WaitDE

	mov  dx,CrtcIndex
	mov  ax,bx
	{cli}
	out  dx,ax
	mov  ax,cx
	out  dx,ax
	{sti}
	mov  dx,InputStatus0

@@WaitVS:
	in   al,dx
	test al,08h
	jz @@WaitVS
	mov  dx,ACINDEX
	mov  ax,si
	{cli}
	out  dx,al
	mov  al,ah
	out  dx,al
	{sti}
	mov  ErrorValue,OK
end;

Procedure XHideSplitscreen; assembler;
asm
	cmp  SplitScrnActive,1
	je   @@SplitScreenEnabled

@@error:
	mov  ErrorValue,ERROR
	jmp  @@Done

@@SplitScreenEnabled:
	cmp  CurrXMode,4
	jg   @@error
	mov  bx,ScrnPhysicalHeight
	mov  ax,ScrnLogicalHeight
	sub  ax,bx
	mov  MaxScrollY,ax
	xor  ax,ax
	mov  SplitScrnVisibleHeight,ax
	or   DoubleScanFlag,0
	jz   @@NotDoubleScanned
	shl  bx,1
	dec  bx

@@NotDoubleScanned:

	mov  dx,InputStatus0

@@WaitNotVsync:
	in   al,dx
	test al,08h
	jnz  @@WaitNotVsync

@@WaitVsync:
	in   al,dx
	test al,08h
	jz   @@WaitVsync
	{cli}
	mov  dx,CrtcIndex
	mov  ah,bl
	mov  al,LINECOMPARE
	out  dx,ax
	mov  ah,bh
	and  ah,1
	shl  ah,4
	mov  al,Overflow
	out  dx,al
	inc  dx
	in   al,dx
	and  al, not 10h
	or   al,ah
	out  dx,al
	dec  dx
	mov  ah,bh
	and  ah,2
	ror  ah,3
	mov  al,MAXSCANLINE
	out  dx,al
	inc  dx
	in   al,dx
	and  al, not 40h
	or   al,ah
	out  dx,al
	{sti}

@@done:
	mov  ErrorValue,OK
end;

Procedure XShowSplitscreen; assembler;
asm
	cmp  SplitScrnActive,1
	je   @@SplitScreenEnabled

@@error:
	mov  ErrorValue,ERROR
	jmp  @@Done

@@SplitScreenEnabled:
	cmp  CurrXMode,4
	jg   @@error
	mov  bx,SplitScrnScanLine
	mov  ax,ScrnLogicalHeight
	sub  ax,bx
	mov  MaxScrollY,ax
	mov  ax,ScrnPhysicalHeight
	sub  ax,bx
	mov  SplitScrnVisibleHeight,ax
	or   DoubleScanFlag,0
	jz   @@NotDoubleScanned
	shl  bx,1
	dec  bx

@@NotDoubleScanned:
	mov  dx,InputStatus0

@@WaitNotVsync:
	in   al,dx
	test al,08h
	jnz  @@WaitNotVsync

@@WaitVsync:
	in   al,dx
	test al,08h
	jz   @@WaitVsync
	{cli}
	mov  dx,CrtcIndex
	mov  ah,bl
	mov  al,LINECOMPARE
	out  dx,ax
	mov  ah,bh
	and  ah,1
	shl  ah,4
	mov  al,Overflow
	out  dx,al
	inc  dx
	in   al,dx
	and  al, not 10h
	or   al,ah
	out  dx,al
	dec  dx
	mov  ah,bh
	and  ah,2
	ror  ah,3
	mov  al,MAXSCANLINE
	out  dx,al
	inc  dx
	in   al,dx
	and  al, not 40h
	or   al,ah
	out  dx,al
	{sti}

@@Done:
	mov  ErrorValue,0
end;

Procedure XAdjustSplitScreen( Line : Word ); assembler;
asm
	cmp  SplitScrnActive,1
	je   @@SplitScreenEnabled

@@error:
	mov  ErrorValue,ERROR
	jmp  @@Done

@@SplitScreenEnabled:
	cmp  CurrXMode,4
	jg   @@error
	mov  bx,Line
	cmp  bx,SplitScrnScanLine
	js   @@Done

@@ValidScanLine:
	mov  ax,ScrnLogicalHeight
	sub  ax,bx
	mov  MaxScrollY,ax
	mov  ax,ScrnPhysicalHeight
	sub  ax,bx
	mov  SplitScrnVisibleHeight,ax
	or   DoubleScanFlag,0
	jz   @@NotDoubleScanned
	shl  bx,1
	dec  bx

@@NotDoubleScanned:
	mov  dx,InputStatus0

@@WaitNotVsync:
	in   al,dx
	test al,08h
	jnz  @@WaitNotVsync

@@WaitVsync:
	in   al,dx
	test al,08h
	jz   @@WaitVsync
	{cli}
	mov  dx,CrtcIndex
	mov  ah,bl
	mov  al,LINECOMPARE
	out  dx,ax
	mov  ah,bh
	and  ah,1
	shl  ah,4
	mov  al,Overflow
	out  dx,al
	inc  dx
	in   al,dx
	and  al, not 10h
	or   al,ah
	out  dx,al
	dec  dx
	mov  ah,bh
	and  ah,2
	ror  ah,3
	mov  al,MAXSCANLINE
	out  dx,al
	inc  dx
	in   al,dx
	and  al, not 40h
	or   al,ah
	out  dx,al
	{sti}

@@Done:
	mov  ErrorValue,OK
end;
Procedure XSetDoubleBuffer( PageHeight : Word ); assembler;
asm
	cmp   DoubleBufferActive,0
	je    @@OkToContinue
@error:
	mov   ErrorValue,ERROR
	ret

@@OkToContinue:
	mov  VisiblePageIdx,0
	mov  ax,ScrnLogicalHeight
	shr  ax,1
	mov  bx,PageHeight
	cmp  ax,bx
	js   @@InvalidHeight
	mov  ax,bx

@@InvalidHeight:
	mov   ScrnLogicalHeight,ax
	cmp   ax,BottomClip
	jle   @@BottomClipOK
	mov   BottomClip,ax
@@BottomClipOK:
	mov   dx,ax
	mul   ScrnLogicalByteWidth
	mov   cx,ax
	mov   bx,Page0Offs
	mov   VisiblePageOffs,bx
	add   ax,bx
	mov   Page1Offs,ax
	mov   HiddenPageOffs,ax
	add   ax,cx
	mov   NonVisualOffs,ax
	mov   DoubleBufferActive,1
	mov   ax,dx
	sub   ax,ScrnPhysicalHeight
	add   ax,SplitScrnVisibleHeight
	mov   MaxScrollY,ax
	mov   ax,dx
	mov   ErrorValue,OK
end;

Procedure XSetTripleBuffer( PageHeight : word ); assembler;
asm
	cmp   DoubleBufferActive,0
	jne   @@Error
	cmp   TripleBufferActive,0
	je    @@OkToContinue

@@Error:
	mov   ErrorValue,ERROR
	jmp @@Done

@@OkToContinue:
	mov   VisiblePageIdx,0
	mov   ax,ScrnLogicalHeight
	mov   bx,3
	xor   dx,dx
	idiv  bx
	mov   bx,PageHeight
	cmp   ax,bx
	js    @@InvalidHeight
	mov   ax,bx


@@InvalidHeight:
	mov   ScrnLogicalHeight,ax

	cmp   ax,BottomClip
	jle   @@BottomClipOK
	mov   BottomClip,ax
@@BottomClipOK:
	push  ax
	mul   ScrnLogicalByteWidth
	mov   cx,ax
	mov   bx,Page0Offs
	mov   VisiblePageOffs,bx
	add   ax,bx
	mov   Page1Offs,ax
	mov   HiddenPageOffs,ax
	add   ax,cx
	mov   Page2Offs,ax
	mov   WaitingPageOffs,ax
	add   ax,cx
	mov   NonVisualOffs,ax
	mov   TripleBufferActive,1
	pop   ax
	sub   ax,ScrnPhysicalHeight
	add   ax,SplitScrnVisibleHeight
	mov   MaxScrollY,ax
	mov   ax,dx
	mov   ErrorValue,OK

@@Done:

end;

Procedure XPageFlip( X, Y : Word ); assembler;
asm
	mov  si,x
	mov  ax,ScrnLogicalByteWidth
	mov  cx,y
	mul  cx
	cmp  DoubleBufferActive,1
	je   @@DoubleBuffer
	cmp  TripleBufferActive,1
	jne  @@PageFlipEntry1
	mov  bx,HiddenPageOffs
	xchg bx,VisiblePageOffs
	xchg bx,WaitingPageOffs
	mov  HiddenPageOffs,bx
	mov  bx, VisiblePageIdx
	inc  bx
	cmp  bx,3
	jne  @@IdxOk
	xor  bx,bx
@@IdxOk:
	mov  VisiblePageIdx,bx
	jmp  @@PageFlipEntry2

@@DoubleBuffer:
	mov  bx,HiddenPageOffs
	xchg bx,VisiblePageOffs
	xchg HiddenPageOffs,bx
	xor  VisiblePageIdx,01h
	jmp  @@PageFlipEntry2

@@PageFlipEntry1:
	add  ax,Page0Offs
	jmp  @@AddColumn

@@PageFlipEntry2:
	mov  PhysicalStartPixelX,si
	mov  PhysicalStartY,cx

@@PageResolution:
	add  ax,VisiblePageOffs

@@AddColumn:
	mov  cx,si
	shr  cx,2
	mov  PhysicalStartByteX,cx
	add  ax,cx
	mov  bh,al
	mov  ch,ah

@@StartAddrEntry:
	mov  bl,ADDRLOW
	mov  cl,ADDRHIGH
	and  si,0003h
	mov  ah,byte ptr PelPanMask[si]
	mov  al,PELPANNING+20h
	mov  si,ax
	mov  dx,InputStatus0

@@WaitDE:
	in   al,dx
	test al,01h
	jnz  @@WaitDE
	mov  dx,CrtcIndex
	mov  ax,bx
	out  dx,ax
	mov  ax,cx
	out  dx,ax
	mov  dx,ACINDEX
	mov  ax,si
	out  dx,al
	mov  al,ah
	out  dx,al
	mov  dx,InputStatus0

@@WaitVS:
	in   al,dx
	test al,08h
	jz @@WaitVS
	mov  ErrorValue,OK
end;

Procedure XPageFlipFast( X, Y : Word ); assembler;
asm
	mov  si,x
	mov  ax,ScrnLogicalByteWidth
	mov  cx,y
	mul  cx
	cmp  DoubleBufferActive,1
	je   @@DoubleBuffer
	cmp  TripleBufferActive,1
	jne  @@PageFlipEntry1
	mov  bx,HiddenPageOffs
	xchg bx,VisiblePageOffs
	xchg bx,WaitingPageOffs
	mov  HiddenPageOffs,bx
	mov  bx, VisiblePageIdx
	inc  bx
	cmp  bx,3
	jne  @@IdxOk
	xor  bx,bx
@@IdxOk:
	mov  VisiblePageIdx,bx
	jmp  @@PageFlipEntry2

@@DoubleBuffer:
	mov  bx,HiddenPageOffs
	xchg bx,VisiblePageOffs
	xchg HiddenPageOffs,bx
	xor  VisiblePageIdx,01h
	jmp  @@PageFlipEntry2

@@PageFlipEntry1:
	add  ax,Page0Offs
	jmp  @@AddColumn

@@PageFlipEntry2:
	mov  PhysicalStartPixelX,si
	mov  PhysicalStartY,cx

@@PageResolution:
	add  ax,VisiblePageOffs

@@AddColumn:
	mov  cx,si
	shr  cx,2
	mov  PhysicalStartByteX,cx
	add  ax,cx
	mov  bh,al
	mov  ch,ah

@@StartAddrEntry:
	mov  bl,ADDRLOW
	mov  cl,ADDRHIGH
	and  si,0003h
	mov  ah,byte ptr PelPanMask[si]
	mov  al,PELPANNING+20h
	mov  si,ax
	mov  dx,InputStatus0

	mov  dx,CrtcIndex
	mov  ax,bx
	out  dx,ax
	mov  ax,cx
	out  dx,ax
	mov  dx,ACINDEX
	mov  ax,si
	out  dx,al
	mov  al,ah
	out  dx,al
	mov  dx,InputStatus0

	mov  ErrorValue,OK
end;

Procedure XSetClipRect( Left, Top, Right, Bottom : Word ); assembler;
asm
	mov   ax,left
	mov   bx,right
	cmp   bx,ax
	jns   @@CorrectXOrder
	xchg  bx,ax
@@CorrectXOrder:
	mov   LeftClip,ax
	mov   RightClip,bx
	mov   ax,top
	mov   bx,bottom
	cmp   bx,ax
	jns   @@CorrectYOrder
	xchg  bx,ax
@@CorrectYOrder:
	mov   TopClip,ax
	mov   BottomClip,bx
end;

Procedure XTextMode; assembler;
asm
	mov   ax,03h
	int   10h
end;

Procedure XWaitVsync; assembler;
asm
	mov   dx,InputStatus0
@@WaitNotVsync:
	in    al,dx
	test  al,08h
	jnz   @@WaitNotVsync

@@WaitVsync:
	in    al,dx
	test  al,08h
	jz    @@WaitVsync
end;

Procedure XLine( x1, y1, x2, y2, Color, PgOffs : word ); assembler;
Var
	vertincr, incr1, incr2, routine:word;
asm
	mov ax,0a000h
	mov es,ax

	mov dx,ScIndex
	mov si,ScrnLogicalByteWidth
	mov cx,x2
	sub cx,x1
	jz  @@VertLine
	jns @@L01

	neg cx

	mov bx,x2
	xchg  bx,x1
	mov x2,bx

	mov bx,y2
	xchg  bx,y1
	mov y2,bx

@@L01:
	mov bx,y2
	sub bx,y1
	jnz @@skip
	jmp @@HorizLine

@@skip:
	jns @@L03
	neg bx
	neg si

@@L03:
	mov vertincr,si
	mov routine,offset @@LoSlopeLine
	cmp bx,cx
	jle @@L04
	mov routine,offset @@HiSlopeLine
	xchg  bx,cx


@@L04:
	shl bx,1
	mov incr1,bx
	sub bx,cx
	mov si,bx
	sub bx,cx
	mov incr2,bx

	push  cx
	mov ax,y1
	mov bx,x1
	mov cl,bl
	push dx
	mov dx,ScrnLogicalByteWidth
	mul dx
	pop dx
	shr bx,2
	add bx,ax
	add bx,PgOffs
	and cl,3
	mov di,bx
	mov al,1
	shl al,cl
	mov ah,al
	shl al,4
	add ah,al
	mov bl,ah
	pop cx
	inc cx
	jmp routine

@@VertLine:
	mov ax,y1
	mov bx,y2
	mov cx,bx
	sub cx,ax
	jge @@L31
	neg cx
	mov ax,bx

@@L31:
	inc cx
	mov bx,x1
	push  cx
	mov cl,bl
	push dx
	mov dx,ScrnLogicalByteWidth
	mul dx
	pop dx
	shr bx,2
	add bx,ax
	add bx,PgOffs
	and cl,3

	mov ah,1
	shl ah,cl
	mov al,MapMask
	out dx,ax
	pop cx
	mov ax, word ptr [Color]

@@L32:
	mov es:[bx],al
	add bx,si
	loop  @@L32
	jmp @@Lexit

@@HorizLine:
	push  ds

	mov ax,y1
	mov bx,x1
	mov cl,bl
	push dx
	mov dx,ScrnLogicalByteWidth
	mul dx
	pop dx
	shr bx,2
	add bx,ax
	add bx,PgOffs
	and cl,3

	mov di,bx
	mov dl,00fh
	shl dl,cl

	mov cx,x2
	and cl,3
	mov dh,00eh
	shl dh,cl
	not dh

	mov ax,x2
	mov bx,x1

	shr ax,2
	shr bx,2
	mov cx,ax
	sub cx,bx

	mov ax,dx
	mov dx,SCINDEX
	mov bx, [Color]
	or  cx,cx
	jnz @@L42
	and ah,al
	jmp @@L44

@@L42:
	push ax
	mov ah,al
	mov al,MAPMASK
	out dx,ax
	mov al,bl
	stosb
	dec cx

@@L43:
	mov ah,0Fh
	mov al,MAPMASK
	out dx,ax
	mov al,bl
	rep stosb
	pop     ax

@@L44:
	mov al,MAPMASK
	out dx, ax
	mov     byte ptr es:[di],bl
	pop ds
	jmp @@Lexit


@@LoSlopeLine:
	mov al,MAPMASK
	mov bh,byte ptr [Color]
@@L10:
	mov ah,bl

@@L11:
	or  ah,bl
	rol bl,1
	jc  @@L14

	or  si,si
	jns @@L12
	add si,incr1
	loop  @@L11

	out dx,ax
	mov es:[di],bh
	jmp @@Lexit

@@L12:
	add si,incr2
	out dx,ax
	mov es:[di],bh
	add di,vertincr
	loop  @@L10
	jmp @@Lexit

@@L14:
	out dx,ax
	mov es:[di],bh
	inc di
	or  si,si
	jns @@L15
	add si,incr1
	loop  @@L10
	jmp @@Lexit

@@L15:
	add si,incr2
	add di,vertincr
	loop  @@L10
	jmp @@Lexit

@@HiSlopeLine:
	mov bx,vertincr
	mov al,MAPMASK
@@L21:
	out dx,ax
	push  ax
	mov ax,Color
	mov es:[di],al
	pop ax
	add di,bx

@@L22:
	or  si,si
	jns @@L23

	add si,incr1
	loop  @@L21
	jmp @@Lexit

@@L23:
	add si,incr2
	rol ah,1
	adc di,0
@@lx21: loop  @@L21


@@Lexit:
end;

Procedure XPutPix( X,Y,PgOfs,Color:word ); assembler;
asm
	mov  ax,ScrnLogicalByteWidth
	mul  Y
	mov  bx,X
	shr  bx,2
	add  bx,ax
	add  bx,PgOfs
	mov  ax,SCREENSEG
	mov  es,ax

	mov  cl,byte ptr X
	and  cl,011b
	mov  ax,0100h + MAPMASK
	shl  ah,cl
	mov  dx,SCINDEX
	out  dx,ax
	mov  al,byte ptr Color
	mov  es:[bx],al
end;

Function XGetPix( x,y,PageBase:word ) : word; assembler;
asm
	mov  ax,ScrnLogicalByteWidth
	mul  Y
	mov  bx,X
	shr  bx,1
	shr  bx,1
	add  bx,ax
	add  bx,PageBase
	mov  ax,SCREENSEG
	mov  es,ax

	mov  ah,byte ptr X
	and  ah,011b
	mov  al,READMAP
	mov  dx,GCINDEX
	out  dx,ax
	mov  al,es:[bx]
	sub  ah,ah
end;

Procedure XRectFill( StartX,StartY,EndX,EndY,
						PageBase,Color:word ); assembler;
asm
	push bp
	cld
	mov  ax,ScrnLogicalByteWidth
	mul  StartY
	mov  di,StartX
	shr  di,1
	shr  di,1
	add  di,ax
	add  di,PageBase
	mov  ax,SCREENSEG
	mov  es,ax
	mov  dx,SCINDEX
	mov  al,MAPMASK
	out  dx,al
	inc  dx
	mov  si,StartX
	and  si,0003h
	mov  bh,byte ptr LeftClipPlaneMask[si]
	mov  si,EndX
	and  si,0003h
	mov  bl,byte ptr RightClipPlaneMask[si]
	mov  cx,EndX
	mov  si,StartX
	cmp  cx,si
	jle  @@FillDone
	dec  cx
	and  si,not 011b
	sub  cx,si
	shr  cx,1
	shr  cx,1
	jnz  @@MasksSet
	and  bh,bl

@@MasksSet:
	mov  si,EndY
	sub  si,StartY
	jle  @@FillDone
	mov  ah,byte ptr Color
	mov  bp,ScrnLogicalByteWidth
	sub  bp,cx
	dec  bp
@@FillRowsLoop:
	push cx
	mov  al,bh
	out  dx,al
	mov  al,ah
	stosb
	dec  cx
	js   @@FillLoopBottom
	jz   @@DoRightEdge
	mov  al,00fh
	out  dx,al
	mov  al,ah
	rep  stosb
@@DoRightEdge:
	mov  al,bl
	out  dx,al
	mov  al,ah
	stosb
@@FillLoopBottom:
	add  di,bp
	pop  cx
	dec  si
	jnz  @@FillRowsLoop
@@FillDone:
	pop bp
end;



Procedure XRectPattern( StartX,StartY,EndX,EndY,PageBase:word;
												var Pattern); assembler;
Var
	NextScanOffset,RectAddrWidth,Height:word;
asm
	push ds
	cld
	mov  ax,SCREENSEG
	mov  es,ax
	lds  si,Pattern
	mov  di,PATTERNBUFFER
	mov  dx,SCINDEX
	mov  al,MAPMASK
	out  dx,al
	inc  dx
	mov  cx,4
@@DownloadPatternLoop:
	mov  al,1
	out  dx,al
	movsb
	dec  di
	mov  al,2
	out  dx,al
	movsb
	dec  di
	mov  al,4
	out  dx,al
	movsb
	dec  di
	mov  al,8
	out  dx,al
	movsb
	loop @@DownloadPatternLoop
	pop  ds

	mov  dx,GCINDEX
	mov  ax,00000h+BITMASK
	out  dx,ax

	mov  ax,StartY
	mov  si,ax
	and  si,011b
	add  si,PATTERNBUFFER

	mov  dx,ScrnLogicalByteWidth
	mul  dx
	mov  di,StartX
	mov  bx,di
	shr  di,1
	shr  di,1
	add  di,ax
	add  di,PageBase

	and  bx,0003h
	mov  ah,byte ptr LeftClipPlaneMask[bx]
	mov  bx,EndX
	and  bx,0003h
	mov  al,byte ptr RightClipPlaneMask[bx]
	mov  bx,ax

	mov  cx,EndX
	mov  ax,StartX
	cmp  cx,ax
	jle  @@FillDone
	dec  cx
	and  ax,not 011b
	sub  cx,ax
	shr  cx,1
	shr  cx,1
	jnz  @@MasksSet
	and  bh,bl

@@MasksSet:
	mov  ax,EndY
	sub  ax,StartY
	jle  @@FillDone
	mov  Height,ax
	mov  ax,ScrnLogicalByteWidth
	sub  ax,cx
	dec  ax
	mov  NextScanOffset,ax
	mov  RectAddrWidth,cx
	mov  dx,SCINDEX+1

@@FillRowsLoop:
	mov  cx,RectAddrWidth
	mov  al,es:[si]
	inc  si
	jnz  @@NoWrap
	sub  si,4
@@NoWrap:
	mov  al,bh
	out  dx,al
				stosb

	dec  cx
	js   @@FillLoopBottom
	jz   @@DoRightEdge
	mov  al,00fh
	out  dx,al
	rep  stosb

@@DoRightEdge:
	mov  al,bl
	out  dx,al
	stosb

@@FillLoopBottom:
	add  di,NextScanOffset
	dec  word ptr Height
	jnz  @@FillRowsLoop
@@FillDone:
	mov  dx,GCINDEX+1
	mov  al,0ffh
	out  dx,al
end;

Procedure XCpVidRect( SrcStartX,SrcStartY,SrcEndX,SrcEndY,DestStartX,
											DestStartY,SrcPageBase,DestPageBase,SrcBitmapW,
											DestBitmapW:word ); assembler;
var
	SrcNextOffs,DestNextOffs,RectAddrW,Height:word;
asm
	push    ds
	cld
	mov     dx,GCINDEX
	mov     ax,BITMASK
	out dx,ax
	mov     ax,SCREENSEG
				mov     es,ax
	mov     ax,DestBitmapW
	shr     ax,2
	mul     DestStartY
	mov     di,DestStartX
	shr     di,2
	add     di,ax
	add     di,DestPageBase
	mov     ax,SrcBitmapW
	shr     ax,2
	mul     SrcStartY
	mov     si,SrcStartX
	mov     bx,si
	shr     si,2
	add     si,ax
	add     si,SrcPageBase
	and     bx,0003h
	mov     ah,byte ptr LeftClipPlaneMask[bx]
	mov     bx,SrcEndX
	and     bx,0003h
	mov     al,byte ptr RightClipPlaneMask[bx]
	mov     bx,ax
	mov     cx,SrcEndX
	mov     ax,SrcStartX
	cmp     cx,ax
	jle     @@CopyDone
	dec     cx
	and     ax,not 011b
	sub     cx,ax
	shr     cx,2
	jnz     @@MasksSet
	and     bh,bl
@@MasksSet:
	mov     ax,SrcEndY
	sub     ax,SrcStartY
	jle     @@CopyDone
	mov     Height,ax
	mov     ax,DestBitmapW
	shr     ax,2
	sub     ax,cx
	dec     ax
	mov     DestNextOffs,ax
	mov     ax,SrcBitmapW
	shr     ax,2
	sub     ax,cx
	dec     ax
	mov     SrcNextOffs,ax
	mov     RectAddrW,cx
	mov     dx,SCINDEX+1
	mov     ax,es
	mov     ds,ax
@@CopyRowsLoop:
	mov     cx,RectAddrW
	mov     al,bh
	out     dx,al
	movsb
	dec     cx
	js      @@CopyLoopBottom
	jz      @@DoRightEdge
	mov     al,00fh
	out     dx,al
	rep     movsb
@@DoRightEdge:
	mov     al,bl
	out     dx,al
	movsb
@@CopyLoopBottom:
	add     si,SrcNextOffs
	add     di,DestNextOffs
	dec     word ptr Height
	jnz     @@CopyRowsLoop
@@CopyDone:
	mov     dx,GCINDEX+1
	mov     al,0ffh
	out     dx,al
	pop     ds
End;

Procedure XShiftRect( SrcLeft,SrcTop,SrcRight,SrcBottom,DestLeft,DestTop,
											ScreenOffs:word ); assembler;
Var
	widthtemp:word;
asm
	push ds
	mov si, SrcLeft
	shr si, 2

	mov di, DestLeft
	shr di, 2

	mov bx, SrcRight
	add bx, 3
	shr bx, 2
	sub bx, si
	mov ax, bx
	inc bx
	mov widthtemp, bx

	cld

	cmp si, di
	jge @@MovingLeft

	add si, ax
	add di, ax
	neg bx
	std

@@MovingLeft:

	mov cx, ScrnLogicalByteWidth
	mov ax, SrcTop
	mov dx, DestTop
	cmp ax, dx
	jge @@MovingUp

	mov ax, SrcBottom
	add dx, ax
	sub dx, SrcTop
	neg cx

@@MovingUp:
	push dx
	mul ScrnLogicalByteWidth
	add si, ax
	pop ax
	mul ScrnLogicalByteWidth
	add di, ax

	sub cx, bx

	add si, ScreenOffs
	add di, ScreenOffs

	mov dx, SCINDEX
	mov ax, 00f02h
	out dx, ax

	mov dx, GCINDEX
	mov ax, BITMASK
	out dx, ax

	mov ax, SCREENSEG
	mov es, ax
	mov ds, ax

	mov ah, byte ptr widthtemp

	mov bx, SrcBottom
	sub bx, SrcTop

	mov dx, cx

	xor ch, ch

@@LineLoop:
	mov cl, ah
	rep movsb

	add si, dx
	add di, dx

	dec bx
	jge @@LineLoop

	mov dx, GCINDEX + 1
	mov al, 0ffh
	out dx, al
	pop ds
End;




Procedure XCircle( Left, Top, Diameter, Color, ScreenOffs:word ); assembler;
Var
	offset0,offset1,offset2,offset3,offset4,offset5,offset6,offset7,mask0n1,
	mask2n3,mask4n5,mask6n7,shrunkradius,diametereven,error:word;
asm
	push ds
	mov di, ScrnLogicalByteWidth
	xor dx, dx
	mov ax, Diameter
	dec ax
	shr ax, 1
	adc dx, 0
	mov shrunkradius, ax
	mov diametereven, dx
	add ax, Top
	mul di
	add ax, ScreenOffs

	mov bx, Left
	mov cx, bx
	mov si, bx
	shr si, 2
	add si, ax
	mov offset6, si
	and bx, 3
	mov bl, byte ptr ColumnMask[bx]
	mov mask6n7, bx

	add cx, Diameter
	dec cx
	mov bx, cx
	shr cx, 2
	add cx, ax
	mov offset2, cx
	and bx, 3
	mov bl, byte ptr ColumnMask[bx]
	mov mask2n3, bx

	cmp diametereven, 1
	jne @@MiddlePlotsOverlap
	add si, di
	add cx, di
@@MiddlePlotsOverlap:
	mov offset7, si
	mov offset3, cx

	mov bx, Left
	add bx, shrunkradius

	mov ax, Top
	mul di
	add ax, ScreenOffs
	mov si, ax

	mov ax, Diameter
	dec ax
	mul di
	add ax, si

	mov di, bx
	shr di, 2
	add si, di
	mov offset4, si
	add di, ax
	mov offset5, di
	and bx, 3
	mov bl, byte ptr ColumnMask[bx]
	mov mask4n5, bx

	cmp diametereven, 1
	jne @@TopAndBottomPlotsOverlap
	rol bl, 1
	jnc @@TopAndBottomPlotsOverlap
	inc si
	inc di
@@TopAndBottomPlotsOverlap:
	mov offset0, si
	mov offset1, di
	mov mask0n1, bx
	mov bx, ScrnLogicalByteWidth

	mov dx, SCREENSEG
	mov ds, dx

	mov dx, SCINDEX
	mov al, MAPMASK
	out dx, al
	inc dx

	mov si, Diameter
	inc si

	mov cx, si
	neg cx
	add cx, 2
	mov error, cx

	xor cx, cx
	mov ah, byte ptr Color
	jmp @@CircleCalc

@@NoAdvance:
	mov al, byte ptr mask0n1
	out dx, al
	mov di, offset0
	mov [di], ah
	rol al, 1
	mov byte ptr mask0n1, al
	adc di, 0
	mov offset0, di
	mov di, offset1
	mov [di], ah
	ror al, 1
	adc di, 0
	mov offset1, di

	mov al, byte ptr mask2n3
	out dx, al
	mov di, offset2
	mov [di], ah
	sub di, bx
	mov offset2, di
	mov di, offset3
	mov [di], ah
	add di, bx
	mov offset3, di

	mov al, byte ptr mask4n5
	out dx, al
	mov di, offset4
	mov [di], ah
	ror al, 1
	mov byte ptr mask4n5, al
	sbb di, 0
	mov offset4, di
	mov di, offset5
	mov [di], ah
	rol al, 1
	sbb di, 0
	mov offset5, di

	mov al, byte ptr mask6n7
	out dx, al
	mov di, offset6
	mov [di], ah
	sub di, bx
	mov offset6, di
	mov di, offset7
	mov [di], ah
	add di, bx
	mov offset7, di

	jmp @@CircleCalc

@@Advance:
	mov al, byte ptr mask0n1
	out dx, al
	mov di, offset0
	mov [di], ah
	rol al, 1
	mov byte ptr mask0n1, al
	adc di, bx
	mov offset0, di
	mov di, offset1
	mov [di], ah
	ror al, 1
	adc di, 0
	sub di, bx
	mov offset1, di

	mov al, byte ptr mask2n3
	out dx, al
	mov di, offset2
	mov [di], ah
	ror al, 1
	mov byte ptr mask2n3, al
	sbb di, bx
	mov offset2, di
	mov di, offset3
	mov [di], ah
	rol al, 1
	sbb di, 0
	add di, bx
	mov offset3, di

	mov al, byte ptr mask4n5
	out dx, al
	mov di, offset4
	mov [di], ah
	ror al, 1
	mov byte ptr mask4n5, al
	sbb di, 0
	add di, bx
	mov offset4, di
	mov di, offset5
	mov [di], ah
	rol al, 1
	sbb di, bx
	mov offset5, di

	mov al, byte ptr mask6n7
	out dx, al
	mov di, offset6
	mov [di], ah
	rol al, 1
	mov byte ptr mask6n7, al
	adc di, 0
	sub di, bx
	mov offset6, di
	mov di, offset7
	mov [di], ah
	ror al, 1
	adc di, bx
	mov offset7, di

@@CircleCalc:
	add cx, 2
	mov di, error
	add di, cx
	inc di
	jl @@CircleNoError
	cmp cx, si
	ja @@FleeFlyFlowFum
	sub si, 2
	sub di, si
	mov error, di
	jmp @@Advance
@@CircleNoError:
	mov error, di
	jmp @@NoAdvance

@@FleeFlyFlowFum:
	pop ds
end;




Procedure XFilledCircle( Left, Top, Diameter, Color, ScreenOffs:word ); assembler;
Var
	offset0,offset1,offset2,offset3,offset4,offset5,offset6,offset7,mask0n1,
	mask2n3,mask4n5,mask6n7,shrunkradius,diametereven,error,jumpvector:word;
asm
	cld
	mov di, ScrnLogicalByteWidth
	xor dx, dx
	mov ax, Diameter
	dec ax
	shr ax, 1
	adc dx, 0
	mov shrunkradius, ax
	mov diametereven, dx
	add ax, Top
	mul di
	add ax, ScreenOffs

	mov bx, Left
	mov cx, bx
	mov si, bx
	shr si, 2
	add si, ax
	mov offset6, si
	and bx, 3
	mov bl, byte ptr ColumnMask[bx]
	mov mask6n7, bx

	add cx, Diameter
	dec cx
	mov bx, cx
	shr cx, 2
	add cx, ax
	mov offset2, cx
	and bx, 3
	mov bl, byte ptr ColumnMask[bx]
	mov mask2n3, bx

	cmp diametereven, 1
	jne @@MiddlePlotsOverlap
	add si, di
	add cx, di
@@MiddlePlotsOverlap:
	mov offset7, si
	mov offset3, cx

	mov bx, Left
	add bx, shrunkradius

	mov ax, Top
	mul di
	add ax, ScreenOffs
	mov si, ax

	mov ax, Diameter
	dec ax
	mul di
	add ax, si

	mov di, bx
	shr di, 2
	add si, di
	mov offset4, si
	add di, ax
	mov offset5, di
	and bx, 3
	mov bl, byte ptr ColumnMask[bx]
	mov mask4n5, bx

	cmp diametereven, 1
	jne @@TopAndBottomPlotsOverlap
	rol bl, 1
	jnc @@TopAndBottomPlotsOverlap
	inc si
	inc di
@@TopAndBottomPlotsOverlap:
	mov offset0, si
	mov offset1, di
	mov mask0n1, bx

	mov bx, ScrnLogicalByteWidth

	mov dx, SCREENSEG
	mov es, dx

	mov dx, SCINDEX
	mov al, MAPMASK
	out dx, al
	inc dx
	mov si, Diameter
	inc si

	mov cx, si
	neg cx
	add cx, 2
	mov error, cx
	xor cx, cx
	mov ah, byte ptr Color
	jmp @@FilledCircleCalc
@@PlotLines:
	push cx

	mov di, mask0n1
	and di, 0000fh
	mov al, byte ptr RightMaskTable[di]
	mov di, offset0
	cmp di, offset4
	jne @@PlotXMajorNontrivial
	mov di, mask4n5
	and di, 0000fh
	and al, byte ptr LeftMaskTable[di]
	out dx, al
	mov di, offset4
	mov es:[di], ah
	mov di, offset5
	mov es:[di], ah
	jmp @@PlotYMajor
@@PlotXMajorNontrivial:
	out dx, al
	mov es:[di], ah
	mov di, offset1
	mov es:[di], ah

	mov di, mask4n5
	and di, 0000fh
	mov al, byte ptr LeftMaskTable[di]
	out dx, al
	mov di, offset4
	mov es:[di], ah
	mov di, offset5
	mov es:[di], ah

	mov al, 0ffh
	out dx, al
	mov al, ah
	inc di
	mov cx, offset1
	sub cx, di
	push cx
	shr cx, 1
	rep stosw
	adc cx, 0
	rep stosb

	mov di, offset4
	inc di
	pop cx
	shr cx, 1
	rep stosw
	adc cx, 0
	rep stosb

@@PlotYMajor:
	mov di, mask2n3
	and di, 0000fh
	mov al, byte ptr RightMaskTable[di]
	mov di, offset2
	cmp di, offset6
	jne @@PlotYMajorNontrivial
	mov di, mask6n7
	and di, 0000fh
	and al, byte ptr LeftMaskTable[di]
	out dx, al
	mov di, offset6
	mov es:[di], ah
	mov di, offset7
	mov es:[di], ah
	jmp @@ClimaxOfPlot
@@PlotYMajorNontrivial:
	out dx, al
	mov es:[di], ah
	mov di, offset3
	mov es:[di], ah

	mov di, mask6n7
	and di, 0000fh
	mov al, byte ptr LeftMaskTable[di]
	out dx, al
	mov di, offset6
	mov es:[di], ah
	mov di, offset7
	mov es:[di], ah

	mov al, 0ffh
	out dx, al
	mov al, ah

	inc di
	mov cx, offset3
	sub cx, di
	push cx
	shr cx, 1
	rep stosw
	adc cx, 0
	rep stosb

	mov di, offset6
	inc di
	pop cx
	shr cx, 1
	rep stosw
	adc cx, 0
	rep stosb

@@ClimaxOfPlot:
	pop cx
	jmp [jumpvector]


@@NoAdvance:
	mov al, byte ptr mask0n1
	mov di, offset0
	rol al, 1
	mov byte ptr mask0n1, al
	adc di, 0
	mov offset0, di
	mov di, offset1
	ror al, 1
	adc di, 0
	mov offset1, di

	mov al, byte ptr mask4n5
	mov di, offset4
	ror al, 1
	mov byte ptr mask4n5, al
	sbb di, 0
	mov offset4, di
	mov di, offset5
	rol al, 1
	sbb di, 0
	mov offset5, di

	mov al, byte ptr mask2n3
	mov di, offset2
	sub di, bx
	mov offset2, di
	mov di, offset3
	add di, bx
	mov offset3, di

	mov al, byte ptr mask6n7
	mov di, offset6
	sub di, bx
	mov offset6, di
	mov di, offset7
	add di, bx
	mov offset7, di

	jmp @@FilledCircleCalc

@@Advance:
	mov al, byte ptr mask0n1
	mov di, offset0
	rol al, 1
	mov byte ptr mask0n1, al
	adc di, bx
	mov offset0, di
	mov di, offset1
	ror al, 1
	adc di, 0
	sub di, bx
	mov offset1, di

	mov al, byte ptr mask2n3
	mov di, offset2
	ror al, 1
	mov byte ptr mask2n3, al
	sbb di, bx
	mov offset2, di
	mov di, offset3
	rol al, 1
	sbb di, 0
	add di, bx
	mov offset3, di

	mov al, byte ptr mask4n5
	mov di, offset4
	ror al, 1
	mov byte ptr mask4n5, al
	sbb di, 0
	add di, bx
	mov offset4, di
	mov di, offset5
	rol al, 1
	sbb di, bx
	mov offset5, di

	mov al, byte ptr mask6n7
	mov di, offset6
	rol al, 1
	mov byte ptr mask6n7, al
	adc di, 0
	sub di, bx
	mov offset6, di
	mov di, offset7
	ror al, 1
	adc di, bx
	mov offset7, di

@@FilledCircleCalc:
	add cx, 2
	mov di, error
	add di, cx
	inc di
	jl @@FilledCircleNoError
	cmp cx, si
	ja @@FleeFlyFlowFum
	sub si, 2
	sub di, si
	mov error, di
	mov jumpvector, offset @@Advance
	jmp @@PlotLines
@@FilledCircleNoError:
	mov error, di
	mov jumpvector, offset @@NoAdvance
	jmp @@PlotLines

@@FleeFlyFlowFum:
end;

Procedure XPbmToBm( var source, dest ); assembler;
asm
	push ds
	les  di,dest
	lds  si,source
	lodsb
	mov  bl,al
	xor  ah,ah
	shl  ax,2
	cmp  ax,255
	ja   @@WidthError
	stosb
	lodsb
	stosb
	xor  ah,ah
	mul  bl
	mov  dx,di
	mov  bl,3

@@PlaneLoop:
	mov  cx,ax

@@PixelLoop:
	movsb
	add  di,3
	loop @@PixelLoop

	inc  dx
	mov  di,dx
	dec  bl
	jns  @@PlaneLoop
	xor  ax,ax
	jmp  @@Done
@@WidthError:
	mov  ax,1

@@Done:
	pop  ds
end;

Procedure XBmToPbm( var source, dest ); assembler;
asm
	push ds
	les  di,dest
	lds  si,source
	lodsb
	test al,03h
	jnz  @@WidthIncompatible
	shr  al,2
	stosb
	mov  bl,al
	lodsb
	stosb
	xor  ah,ah
	mul  bl
	mov  dx,si
	mov  bl,3

@@PlaneLoop:
	mov  cx,ax

@@PixelLoop:
	movsb
	add  si,3
	loop @@PixelLoop

	inc  dx
	mov  si,dx
	dec  bl
	jns  @@PlaneLoop
	xor  ax,ax
	jmp  @@Done
@@WidthIncompatible:
	mov  ax,1

@@Done:
	pop  ds
end;

Procedure XPutMaskedPbm( X, Y,ScrnOffs : word; var Bitmap ); assembler;
var
	Plane,BMHeight:byte;
	LineInc:word;
asm
	push  ds
	cld
	mov   ax,SCREENSEG
	mov   es,ax
	mov   ax,Y
	mov   bx,ScrnLogicalByteWidth
	mul   bx
	mov   di,ScrnOffs
	add   di,ax
	mov   cx,X
	mov   dx,cx
	shr   dx,2
	add   di,dx
	lds   si,Bitmap
	lodsw

	mov   BMHeight,ah
	xor   ah,ah
	sub   bx,ax
	mov   LineInc,bx
	mov   bh,al
	and   cx,0003h

	mov   ah,11h
	shl   ah,cl
	mov   dx,SCINDEX
	mov   al,MAPMASK
	out   dx,al
	inc   dx
	mov   Plane,4
@@PlaneLoop:
	push  di
	mov   bl,BMHeight
	mov   al,ah
	out   dx,al
@@RowLoop:
	mov   cl,bh
@@ColLoop:
	lodsb
	or    al,al
	jz    @@NoPixel
	mov   es:[di],al
@@NoPixel:
	inc   di
	loop  @@ColLoop
	add   di,LineInc
	dec   bl
	jnz   @@RowLoop
	pop   di
	rol   ah,1
	adc   di,0
	dec   Plane
	jnz   @@PlaneLoop
	pop   ds
end;

Procedure XPutPbm( X,Y,ScrnOffs:word; var Bitmap ); assembler;
var
	Plane,BMHeight:byte;
	LineInc:word;
asm
	push  ds
	cld
	mov   ax,SCREENSEG
	mov   es,ax
	mov   ax,Y
	mov   bx,ScrnLogicalByteWidth
	mul   bx
	mov   di,ScrnOffs
	add   di,ax
	mov   cx,X
	mov   dx,cx
	shr   dx,2
	add   di,dx

	lds   si,Bitmap
	lodsw
	mov   BMHeight,ah
	xor   ah,ah
	sub   bx,ax
	mov   LineInc,bx
	mov   bh,al

	and   cx,0003h

	mov   ah,11h
	shl   ah,cl
	mov   dx,SCINDEX
	mov   al,MAPMASK
	out   dx,al
	inc   dx
	mov   [Plane],4
@@PlaneLoop:
	push  di
	mov   bl,BMHeight
	mov   al,ah
	out   dx,al
@@RowLoop:
	mov   cl,bh
	shr   cl,1
	rep   movsw
	adc   cl,0
	rep   movsb
	add   di,LineInc
	dec   bl
	jnz   @@RowLoop
	pop   di
	rol   ah,1
	adc   di,0
	dec   Plane
	jnz   @@PlaneLoop
	pop   ds
end;

Procedure XGetPbm( X,Y: word;SrcWidth,SrcHeight:byte;
									 ScrnOffs:word; var Bitmap ); assembler;
var
	Plane:byte;
	LineInc:word;
asm
	push  ds
	cld
	mov   ax,Y
	mov   bx,ScrnLogicalByteWidth
	mul   bx
	mov   si,ScrnOffs
	add   si,ax
	mov   cx,X
	mov   dx,cx
	shr   dx,2
	add   si,dx
	mov   ax,SCREENSEG
	mov   ds,ax
	les   di,Bitmap
	mov   al,SrcWidth
	mov   ah,SrcHeight
	stosw
	xor   ah,ah
	sub   bx,ax
	mov   LineInc,bx
	mov   bh,al
	and   cx,0003h
	mov   ah,11h
	shl   ah,cl
	mov   dx,GCINDEX
	mov   al,READMAP
	out   dx,al
	inc   dx
	mov   Plane,4
	mov   al,cl
@@PlaneLoop:
	push  si
	mov   bl,SrcHeight
	out   dx,al
@@RowLoop:
	mov   cl,bh
	shr   cl,1
	rep   movsw
	adc   cl,0
	rep   movsb
	add   si,LineInc
	dec   bl
	jnz   @@RowLoop
	pop   si
	inc   al
	and   al,3
	rol   ah,1
	adc   si,0
	dec   Plane
	jnz   @@PlaneLoop
	pop   ds
end;

Procedure XCompilePbm( LogicalWidth : word; var bitmap,output ); assembler;
Var
	bwidth,scanx,scany,
	outputx,outputy,column,
	setcolumn,inputsize:word;
asm
	push ds
	mov word ptr scanx,0
	mov word ptr scany,0
	mov word ptr outputx,0
	mov word ptr outputy,0
	mov word ptr column,0
	mov word ptr setcolumn,0
	lds si,bitmap
	les di,output
	lodsb
	xor ah, ah
	mov bwidth, ax
	mov bl, al
	lodsb
	mul bl
	mov inputsize, ax

@@MainLoop:
	mov bx, scanx
	add bx, scany
	mov al, [si+bx]
	or  al, al
	jnz @@NoAdvance
	jmp @@Advance

@@NoAdvance:
	mov dx, setcolumn
	cmp dx, column
	je @@SameColumn

@@ColumnLoop:
	mov word ptr es:[di],RolAl
	add di,2
	mov word ptr es:[di],AdcSiImmed
	add di,2
	mov byte ptr es:[di],0
	inc di
	inc dx
	cmp dx, column
	jl @@ColumnLoop
	mov byte ptr es:[di],OUTAL
	inc di
	mov setcolumn, dx

@@SameColumn:
	mov dx, outputy
	add dx, outputx
	sub dx, 128

	inc word ptr scanx
	mov cx, scanx
	cmp cx, bwidth
	jge @@OnePixel

	inc word ptr outputx
	mov ah, [si+bx+1]
	or ah, ah
	jnz @@TwoPixels
@@OnePixel:
	cmp dx, 127
	jg @@OnePixLarge
	cmp dx, -128
	jl @@OnePixLarge
	mov word ptr es:[di],ShortStore8
	add di,2
	mov byte ptr es:[di],dl
	inc di
	jmp @@EmitOnePixel
@@OnePixLarge:
	mov word ptr es:[di],Store8
	add di,2
	mov word ptr es:[di],dx
	add di,2
@@EmitOnePixel:
	mov byte ptr es:[di],al
	inc di
	jmp @@Advance
@@TwoPixels:
	cmp dx, 127
	jg @@TwoPixLarge
	cmp dx, -128
	jl @@TwoPixLarge
	mov word ptr es:[di],ShortStore16
	add di,2
	mov byte ptr es:[di],dl
	inc di
	jmp @@EmitTwoPixels
@@TwoPixLarge:
	mov word ptr es:[di],Store16
	add di,2
	mov word ptr es:[di],dx
	add di,2
@@EmitTwoPixels:
	mov word ptr es:[di],ax
	add di,2

@@Advance:
	inc word ptr outputx
	mov ax, scanx
	inc ax
	cmp ax, bwidth
	jl @@AdvanceDone
	mov dx, outputy
	add dx, logicalwidth
	mov cx, scany
	add cx, bwidth
	cmp cx, inputsize
	jl @@NoNewColumn
	inc word ptr column
	mov cx, column
	cmp cx, 4
	je @@Exit
	xor cx, cx
	mov dx, cx
	add si, inputsize
@@NoNewColumn:
	mov outputy, dx
	mov scany, cx
	xor ax, ax
	mov word ptr outputx, 0
@@AdvanceDone:
	mov scanx, ax
	jmp @@MainLoop

@@Exit:
	mov byte ptr es:[di],Return
	inc di
	mov ax,di
	sub ax,word ptr output
	pop ds
end;

Function XSizeOfCPbm( logicalwidth : word; var bitmap ) : word; assembler;
var
	bwidth,scanx,scany,outputx,outputy,
	column,setcolumn,inputsize:word;
asm
	push ds
	mov word ptr scanx, 0
	mov word ptr scany, 0
	mov word ptr outputx, 0
	mov word ptr outputy, 0
	mov word ptr column, 0
	mov word ptr setcolumn, 0
	lds si,bitmap
	mov di, 1
	lodsb
	xor ah, ah
	mov bwidth, ax
	mov bl, al
	lodsb
	mul bl
	mov inputsize, ax

@@MainLoop:
	mov bx, scanx
	add bx, scany

	mov al, [si+bx]
	or  al, al
	jnz @@NoAdvance
	jmp @@Advance
@@NoAdvance:

	mov dx, setcolumn
	cmp dx, column
	je @@SameColumn
@@ColumnLoop:
	add di, 5
	inc dx
	cmp dx,column
	jl @@ColumnLoop

	inc di
	mov setcolumn, dx
@@SameColumn:
	mov dx, outputy
	add dx, outputx
	sub dx, 128

	inc word ptr scanx
	mov cx, scanx
	cmp cx, bwidth
	jge @@OnePixel

	inc word ptr outputx
	mov ah,[si+bx+1]
	or ah, ah
	jnz @@TwoPixels
@@OnePixel:
	cmp dx, 127
	jg @@OnePixLarge
	cmp dx, -128
	jl @@OnePixLarge
	add di, 4
	jmp @@EmitOnePixel
@@OnePixLarge:
	add di, 5
@@EmitOnePixel:
	jmp @@Advance
@@TwoPixels:
	cmp dx, 127
	jg @@TwoPixLarge
	cmp dx, -128
	jl @@TwoPixLarge
	add di, 5
	jmp @@EmitTwoPixels
@@TwoPixLarge:
	add di, 6
@@EmitTwoPixels:

@@Advance:
	inc word ptr outputx
	mov ax, scanx
	inc ax
	cmp ax, bwidth
	jl @@AdvanceDone
	mov dx, outputy
	add dx, logicalwidth
	mov cx, scany
	add cx, bwidth
	cmp cx, inputsize
	jl @@NoNewColumn
	inc word ptr column
	mov cx, column
	cmp cx, 4
	je @@Exit
	xor cx,cx
	mov dx,cx
	add si, inputsize
@@NoNewColumn:
	mov outputy, dx
	mov scany, cx
	xor ax, ax
	mov word ptr outputx, ax
@@AdvanceDone:
	mov scanx, ax
	jmp @@MainLoop

@@Exit:
	mov ax, di
	pop ds
end;

Procedure XCompileBitmap( logicalwidth:word; var bitmap, output ); assembler;
var
	bwidth,scanx,scany,outputx,outputy,
	column,setcolumn,inputsize:word;
asm
	push ds
	mov word ptr scanx,0
	mov word ptr scany,0
	mov word ptr outputx,0
	mov word ptr outputy,0
	mov word ptr column,0
	mov word ptr setcolumn,0

	lds si,bitmap

	les di,output

	lodsb
	xor ah, ah
	mov bwidth, ax
	mov bl, al
	lodsb
	mul bl
	mov inputsize, ax

@@MainLoop:
	mov bx, scanx
	add bx, scany

	mov al, [si+bx]
	or  al, al
	jnz @@NoAdvance
	jmp @@Advance
@@NoAdvance:

	mov dx, setcolumn
	cmp dx, column
	je @@SameColumn
@@ColumnLoop:
	mov word ptr es:[di],RolAl
	add di,2
	mov word ptr es:[di],AdcSiImmed
	add di,2
	mov byte ptr es:[di],0
	inc di
	inc dx
	cmp dx, column
	jl @@ColumnLoop

	mov byte ptr es:[di],OutAl
	inc di
	mov setcolumn, dx
@@SameColumn:
	mov dx, outputy
	add dx, outputx
	sub dx, 128

	add word ptr scanx, 4
	mov cx, scanx
	cmp cx, bwidth
	jge @@OnePixel

	inc word ptr outputx
	mov ah, [si+bx+4]
	or ah, ah
	jnz @@TwoPixels
@@OnePixel:
	cmp dx, 127
	jg @@OnePixLarge
	cmp dx, -128
	jl @@OnePixLarge
	mov word ptr es:[di],ShortStore8
	add di,2
	mov byte ptr es:[di],dl
	inc di
	jmp @@EmitOnePixel
@@OnePixLarge:
	mov word ptr es:[di],Store8
	add di,2
	mov word ptr es:[di],dx
	add di,2
@@EmitOnePixel:
	mov byte ptr es:[di],al
	inc di
	jmp @@Advance
@@TwoPixels:
	cmp dx, 127
	jg @@TwoPixLarge
	cmp dx, -128
	jl @@TwoPixLarge
	mov word ptr es:[di],ShortStore16
	add di,2
	mov byte ptr es:[di],dl
	inc di
	jmp @@EmitTwoPixels
@@TwoPixLarge:
	mov word ptr es:[di],Store16
	add di,2
	mov word ptr es:[di],dx
	add di,2
@@EmitTwoPixels:
	mov word ptr es:[di],ax
	add di,2

@@Advance:
	inc word ptr outputx
	mov ax, scanx
	add ax, 4
	cmp ax, bwidth
	jl @@AdvanceDone
	mov dx, outputy
	add dx, logicalwidth
	mov cx, scany
	add cx, bwidth
	cmp cx, inputsize
	jl @@NoNewColumn
	inc word ptr column
	mov cx, column
	cmp cx, 4
	je @@Exit
	xor cx, cx
	mov dx, cx
@@NoNewColumn:
	mov outputy, dx
	mov scany, cx
	mov word ptr outputx, 0
	mov ax,column
@@AdvanceDone:
	mov scanx, ax
	jmp @@MainLoop

@@Exit:
	mov byte ptr es:[di],Return
	inc di
	mov ax,di
	sub ax,word ptr output
	pop ds
end;


Function XSizeOfCBitmap( logicalwidth:word; var bitmap ):word; assembler;
var
	bwidth,scanx,scany,outputx,outputy,
	column,setcolumn,inputsize:word;
asm
	push ds
	mov word ptr scanx, 0
	mov word ptr scany, 0
	mov word ptr outputx, 0
	mov word ptr outputy, 0
	mov word ptr column, 0
	mov word ptr setcolumn, 0
	lds si,bitmap

	mov di, 1

	lodsb
	xor ah, ah
	mov bwidth, ax
	mov bl, al
	lodsb
	mul bl
	mov inputsize, ax

@@MainLoop:
	mov bx, scanx
	add bx, scany

	mov al, [si+bx]
	or  al, al
	jnz @@NoAdvance
	jmp @@Advance
@@NoAdvance:

	mov dx, setcolumn
	cmp dx, column
	je @@SameColumn
@@ColumnLoop:
	add di, 5
	inc dx
	cmp dx,column
	jl @@ColumnLoop

	inc di
	mov setcolumn, dx
@@SameColumn:
	mov dx, outputy
	add dx, outputx
	sub dx, 128

	add word ptr scanx, 4
	mov cx, scanx
	cmp cx, bwidth
	jge @@OnePixel

	inc word ptr outputx
	mov ah,[si+bx+4]
	or ah, ah
	jnz @@TwoPixels
@@OnePixel:
	cmp dx, 127
	jg @@OnePixLarge
	cmp dx, -128
	jl @@OnePixLarge
	add di, 4
	jmp @@EmitOnePixel
@@OnePixLarge:
	add di, 5
@@EmitOnePixel:
	jmp @@Advance
@@TwoPixels:
	cmp dx, 127
	jg @@TwoPixLarge
	cmp dx, -128
	jl @@TwoPixLarge
	add di, 5
	jmp @@EmitTwoPixels
@@TwoPixLarge:
	add di, 6
@@EmitTwoPixels:

@@Advance:
	inc word ptr outputx
	mov ax, scanx
	add ax,4
	cmp ax, bwidth
	jl @@AdvanceDone
	mov dx, outputy
	add dx, logicalwidth
	mov cx, scany
	add cx, bwidth
	cmp cx, inputsize
	jl @@NoNewColumn
	inc word ptr column
	mov cx, column
	cmp cx, 4
	je @@Exit
	xor cx,cx
	mov dx,cx
@@NoNewColumn:
	mov outputy, dx
	mov scany, cx
	mov word ptr outputx, 0
	mov ax,column

@@AdvanceDone:
	mov scanx, ax
	jmp @@MainLoop

@@Exit:
	mov ax, di
	pop ds
end;


Procedure XPutCBitmap( XPos,YPos,PageOffset:word; var Sprite ); assembler;
asm
	push ds

	mov ax, ScrnLogicalByteWidth
	mul word ptr YPos
	mov si, XPos
	mov bx, si
	sar si, 2
	add si, ax
	add si, PageOffset
	add si, 128
	and bx, 3
	mov ah, byte ptr ColumnMask[bx]
	mov dx, SCINDEX
	mov al, MAPMASK
	out dx, ax
	inc dx
	mov al, ah
	mov bx, SCREENSEG
	mov ds, bx
	call Sprite
	pop ds
end;

Procedure XGetPalStruc( var PalBuff; NumColors,StartColor:word ); assembler;
asm
	cld
	les  di,PalBuff
	mov  si,StartColor
	mov  ax,si
	stosb
	mov  dx,NumColors
	mov  al,dl
	stosb
	mov  cx,dx
	cld
	mov  dx,INPUTSTATUS0
@@WaitNotVsync:
	in   al,dx
	test al,08h
	jnz  @@WaitNotVsync
@@WaitVsync:
	in   al,dx
	test al,08h
	jz   @@WaitVsync
	mov  ax, si
	mov  dx, DACREADINDEX
	{cli}
	out  dx, al
	mov  dx, DACDATA
	mov  bx, cx
	shl  bx, 1
	add  cx, bx
	rep  insb
	{sti}
end;

Procedure XGetPalRaw( Var PalBuff; NumColors,StartColor:word ); assembler;
asm
	les  di,PalBuff
	mov  si,StartColor
	mov  cx,NumColors
@@ReadPalEntry:
	cld
	mov     dx,INPUTSTATUS0
@@WaitNotVsync:
	in      al,dx
	test    al,08h
	jnz     @@WaitNotVsync
@@WaitVsync:
	in      al,dx
	test    al,08h
	jz      @@WaitVsync
	mov  ax,si
	mov  dx,DACREADINDEX
	{cli}
	out  dx,al
	mov  dx,DACDATA
	mov  bx,cx
	shl  bx,1
	add  cx,bx
	rep  insb
	{sti}
end;


Procedure XPutPalStruc( Var CompPalBuff ); assembler;
asm
	push ds
	cld
	lds  si,CompPalBuff
	lodsb
	mov  ah,0
	mov  bx,ax
	lodsb
	mov  ah,0
	mov	 cx,ax
	or   cx,cx
	jz   @@Done
	cld
	mov  dx,INPUTSTATUS0
@@WaitNotVsync:
	in   al,dx
	test al,08h
	jnz  @@WaitNotVsync
@@WaitVsync:
	in   al,dx
	test al,08h
	jz   @@WaitVsync
	mov  ax,bx
	mov  bx,60
@@SetLoop:
	mov  dx,DACWRITEINDEX
	out  dx,al
	mov  dx,DACDATA
	outsb
	outsb
	outsb
	inc  al
	dec  bx
	js   @@testvsync
	loop @@SetLoop
	jmp  @@Done
@@testvsync:
	mov  dx,INPUTSTATUS0
	push ax
@@Wait:
	in   al,dx
	test al,08h
	jz   @@Wait
	pop  ax
	mov  bx,60
	loop @@SetLoop
@@Done:
	pop ds
end;

Procedure XTransposePalStruc( Var CompPalBuff; StartColor:word ); assembler;
asm
	push ds
	cld
	lds  si,CompPalBuff
	mov  bx,StartColor
	mov  [si],bl
	inc  si
	lodsb
	mov  ah,0
	mov	cx,ax
	or   cx,cx
	jz   @@Done
	;{cli}
	cld
	mov  dx,INPUTSTATUS0
@@WaitNotVsync:
	in   al,dx
	test al,08h
	jnz  @@WaitNotVsync
@@WaitVsync:
	in   al,dx
	test al,08h
	jz   @@WaitVsync
	mov  ax,bx
	mov  bx,60
@@SetLoop:
	mov  dx,DACWRITEINDEX
	out  dx,al
	mov  dx,DACDATA
	outsb
	outsb
	outsb
	inc  al
	dec  bx
	js   @@testvsync
	loop @@SetLoop
	jmp  @@Done
@@testvsync:
	mov  dx,INPUTSTATUS0
	push ax
@@Wait:
	in   al,dx
	test al,08h
	jz   @@Wait
	pop  ax
	mov  bx,60
	loop @@SetLoop
@@Done:
	pop ds
end;


Procedure XPutPalRaw( Var PalBuff; NumColors,StartColor:word ); assembler;
asm
	push ds
	mov  cx,NumColors
	mov  bx,StartColor
	lds  si,PalBuff
@@WritePalEntry:
	or   cx,cx
	jz   @@Done
	{cli}
	cld
	mov  dx,INPUTSTATUS0
@@WaitNotVsync:
	in   al,dx
	test al,08h
	jnz  @@WaitNotVsync
@@WaitVsync:
	in   al,dx
	test al,08h
	jz   @@WaitVsync
	mov  ax,bx
	mov  bx,60
@@SetLoop:
	mov  dx,DACWRITEINDEX
	out  dx,al
	mov  dx,DACDATA
	outsb
	outsb
	outsb
	inc  al
	dec  bx
	js   @@testvsync
	loop @@SetLoop
	jmp  @@Done
@@testvsync:
	mov     dx,INPUTSTATUS0
	push    ax
@@Wait:
	in      al,dx
	test    al,08h
	jz      @@Wait
	pop     ax
	mov     bx,60
	loop @@SetLoop
@@Done:
	{sti}
	pop  ds
end;


Procedure XSetRGB( ColorIndex,R,G,B:byte ); assembler;
asm
	mov  al,ColorIndex
	mov  dx,DACWRITEINDEX
	out  dx,al
	mov  dx,DACDATA
	mov  al,R
	out  dx,al
	mov  al,G
	out  dx,al
	mov  al,B
	out  dx,al
end;

Procedure XRotPalStruc( Var PalBuff; Direction:word ); assembler;
asm
	push ds
	cld
	lds	 si,PalBuff
	lodsw
	xor  ch,ch
	mov  cl,ah
	mov	 ax,ds
	mov	 es,ax
	dec  cx
	mov	 bx,cx
	shl	 bx,1
	add  cx,bx
	cmp  Direction,0
	jne  @@forward
	std
	add  si,cx
	add  si,2
@@forward:
	mov	 ax,si
	mov	 di,ax
	lodsb
	mov  dl,al
	lodsb
	mov  dh,al
	lodsb
	mov  bl,al
	rep	 movsb
	mov  al,dl
	stosb
	mov  al,dh
	stosb
	mov  al,bl
	stosb
	pop	 ds
end;


Procedure XRotPalRaw( Var PalBuff; Direction, NumColors:word ); assembler;
asm
	push ds
	cld
	mov	 cx,NumColors
	lds	 si,PalBuff
@@RotatePalEntry:
	mov	 ax,ds
	mov	 es,ax
	dec  cx
	mov	 bx,cx
	shl	 bx,1
	add  cx,bx
	cmp  Direction,0
	jne  @@forward
	std
	add  si,cx
	add  si,2
@@forward:
	mov	 ax,si
	mov	 di,ax
	lodsb
	mov  dl,al
	lodsb
	mov  dh,al
	lodsb
	mov  bl,al
	rep	 movsb
	mov  al,dl
	stosb
	mov  al,dh
	stosb
	mov  al,bl
	stosb
	pop	 ds
end;

Function XCpContrastPalStruc( Var PalSrcBuff,PalDestBuff;
																Intensity:byte ):word; assembler;
asm
	push ds
	cld
	mov  bh,0ffh
	sub  bh,Intensity
	and  bh,07fh
	lds	 si,PalSrcBuff
	les	 di,PalDestBuff
	lodsw
	stosw
	xor  ch,ch
	mov  cl,ah
	mov  dx,0
@@MainLoop:
	lodsw
	sub  al,bh
	jns  @@DecrementOKR
	xor  al,al
@@DecrementOKR:
	sub  ah,bh
	jns  @@DecrementOKG
	xor  ah,ah
@@DecrementOKG:
	or   dx,ax
	or   dl,ah
	stosw
	lodsb
	sub  al,bh
	jns  @@DecrementOKB
	xor  al,al
@@DecrementOKB:
	or   dl,al
	stosb
	loop @@MainLoop
	mov  ax,dx
	pop	 ds
end;


Procedure XPutContrastPalStruc( Var CompPalBuff; Intensity:byte ); assembler;
asm
	push    ds
	cld
	mov     bh,0ffh
	sub     bh,Intensity
	and     bh,07fh
	mov     di,40
	lds     si,CompPalBuff
	lodsb
	mov     bl,al
	lodsb
	mov     ah,0
	mov	cx,ax
	or      cx,cx
	jz      @@Done

	mov     dx,INPUTSTATUS0
@@WaitNotVsync:
	in      al,dx
	test    al,08h
	jnz     @@WaitNotVsync
@@WaitVsync:
	in      al,dx
	test    al,08h
	jz      @@WaitVsync

@@MainLoop:
	mov  al,bl
	mov  dx,DACWRITEINDEX
	out  dx,al
	inc  dx
	lodsb
	sub  al,bh
	jns  @@DecrementOKR
	xor  al,al
@@DecrementOKR:
	out  dx,al

	lodsb
	sub  al,bh
	jns  @@DecrementOKG
	xor  al,al
@@DecrementOKG:
	out  dx,al

	lodsb
	sub  al,bh
	jns  @@DecrementOKB
	xor  al,al
@@DecrementOKB:
	out  dx,al

	inc  bl
	dec  di
	js   @@testvsync
	loop @@MainLoop
	jmp  @@Done


@@testvsync:
	mov     dx,INPUTSTATUS0
	push    ax
@@Wait:
	in      al,dx
	test    al,08h
	jz      @@Wait
	pop     ax
	mov     di,40
	loop    @@MainLoop
@@Done:
	;{sti}
	pop  ds
end;

Procedure XTextInit; assembler;
asm
	push bp
	mov  FontDriverActive,1
	mov  ax,1130h
	push ax
	mov  bh,3
	int  10h
	mov  word ptr F8x8Ptr,bp
	mov  word ptr F8x8Ptr+2,es

	mov  word ptr FontPtr,bp
	mov  word ptr FontPtr+2,es

	pop  ax
	mov  bh,2
	int  10h
	mov  word ptr F8x14Ptr,bp
	mov  word ptr F8x14Ptr+2,es


	mov  al,8
	mov  CharHeight,al
	mov  CharWidth ,al

	mov  dx,offset MirrorTable
	mov  MirrorTableOffs,dx
	pop  bp
end;


Procedure XSetFont( FontID : word ); assembler;
asm
	xor  dx,dx
	mov  cx,FontID
	cmp  cx,2

	jne  @@notuserfont
	mov  ax,word ptr UserFontPtr
	mov  word ptr FontPtr,ax

	mov  ax,word ptr UserFontPtr+2
	mov  word ptr FontPtr+2,ax

	mov  al,UserChHeight
	mov  CharHeight,al

	mov  al,UserChWidth
	mov  CharWidth,al

	mov  al,UserFirstCh
	mov  FirstChar,al
	jmp  @@done

@@notuserfont:

	mov  dx,offset MirrorTable
	mov  CharWidth,8
	mov  FirstChar,0
	cmp  cx,1
	jne  @@not8x14font

	mov  ax,word ptr F8x14Ptr
	mov  word ptr FontPtr,ax

	mov  ax,word ptr F8x14Ptr+2
	mov  word ptr FontPtr+2,ax

	mov  CharHeight,14
	jmp  @@done

@@not8x14font:
	mov  ax,word ptr F8x8Ptr
	mov  word ptr FontPtr,ax

	mov  ax,word ptr F8x8Ptr+2
	mov  word ptr FontPtr+2,ax

	mov  CharHeight,8

@@done:
	mov  MirrorTableOffs,dx
end;

Procedure XRegisterUserFont( var FontToRegister ); assembler;
asm
	mov  ax,word ptr FontToRegister
	mov  bx,word ptr FontToRegister+2
	add  ax,4
	mov  word ptr UserFontPtr,ax
	mov  word ptr UserFontPtr+2,bx

	push ds
	lds  si,FontToRegister
	lodsw
	mov  bx,ax
	lodsw
	pop  ds
	mov  UserChHeight,al
	mov  UserChWidth,ah
	mov  UserFirstCh,bl
end;

function XGetCharWidth( ACh : char ) : byte; assembler;
asm
	xor  ah,ah
	mov  al,CharWidth
	or   al,al
	jz   @@NotFixed
	jmp  @@Done

@@NotFixed:
	push si
	mov  al,CharHeight
	mov  bx,ax
	inc  al
	mov  dl, ACh
	sub  dl,FirstChar
	mul  dl
	add  ax,bx
	les  si,dword ptr FontPtr
	add  si,ax
	xor  ah,ah
	mov  al,byte ptr es:[si]
@@Done:
end;

function XCharPut( Chr:char; X, Y, ScrnOffs, Color:word ) : byte; assembler;
var
	ScreenInc,
	Hold:word;
asm
	push ds
	cld
	mov  ax,ScrnLogicalByteWidth
	mov  bx,ax
	sub  bx,3
	mov  ScreenInc,bx
	mul  Y
	mov  di,X
	mov  cx,di
	shr  di,2
	add  di,ax
	add  di,ScrnOffs

	mov  ax,SCREENSEG
	mov  es,ax

	and  cx,3

	mov  bx,MirrorTableOffs
	mov  al,CharHeight
	xor  ah,ah
	mov  ch,al

	cmp  CharWidth,0
	jne  @@NoWidthByte
	inc  al

@@NoWidthByte:
	mov  dl,Chr
	sub  dl,FirstChar
	mul  dl
	lds  si,dword ptr FontPtr
	add  si,ax

	mov  dx,SCINDEX

@@MainLoop:

	lodsb
	or   al,al
	jz   @@NoCharPixels

	or   bx,bx
	jz   @@DontMirror
	push ds
	mov  dx,seg @data
	mov  ds,dx
	xlat
	pop  ds
	mov  dx,SCINDEX

@@DontMirror:
	xor  ah,ah
	shl  ax,cl
	mov  Hold,ax

	mov  ah,al
	and  ah,0fh
	jnz  @@p1
	inc  di
	jmp  @@SecondNibble

@@p1:
	mov  al,MAPMASK
	out  dx,ax
	mov  al,byte ptr Color
	stosb

@@SecondNibble:
	mov  ax,Hold
	shl  ax,4
	and  ah,0fh
	jnz  @@p2
	inc  di
	jmp  @@ThirdNibble

@@p2:
	mov  al,MAPMASK
	out  dx,ax
	mov  al,byte ptr Color
	stosb

@@ThirdNibble:
	mov  ax,Hold
	and  ah,0fh
	jnz  @@p3
	inc  di
	jmp  @@NextCharRow

@@p3:
	mov  al,MAPMASK
	out  dx,ax
	mov  al,byte ptr Color
	stosb

@@NextCharRow:
	add  di,ScreenInc
	dec  ch
	jnz  @@MainLoop

@@done:
	pop  es
	mov  ah,0
	mov  al,es:CharWidth
	or   al,al
	jnz  @@FixedSpacing
	lodsb
@@FixedSpacing:

	mov  bx,es
	mov  ds,bx
	jmp @@TheEnd


@@NoCharPixels:
	add  di,3
	add  di,ScreenInc
	dec  ch
	jnz  @@MainLoop
	jmp  @@done

@@TheEnd:

end;

Procedure XPrintf( x, y, ScrnOffs, Color : word; s : string );
var
	i : integer;
begin
	for i := 1 to length(s) do
		x:=x+XCharPut( s[i], x, y, ScrnOffs, color );
end;

Procedure XBgPrintf( x, y, ScrnOffs, fgcolor, bgcolor : word; s : string );
var
	i : integer;
begin
	for i := 1 to length(s) do
	begin
		XRectFill( x, y, x+XGetCharWidth(s[i]),y+CharHeight,ScrnOffs,bgcolor);
		x := x + XCharPut( s[i], x, y, ScrnOffs, fgcolor);
	end;

end;


procedure HLineClipR; near; assembler;
asm
	push    di
	cmp     dx,ax
	jl      @@Invisible

	cmp     cx,TopClip
	jl      @@Invisible

	cmp     cx,BottomClip
	jg      @@Invisible

	mov     di,RightClip
	sal     di,2
	cmp     ax,di
	jg      @@Invisible
	cmp     dx,di
	jle     @@ClipLeft
	mov     dx,di

@@ClipLeft:
	mov     di,LeftClip
	sal     di,2
	cmp     dx,di
	jl      @@Invisible
	cmp     ax,di
	jge     @@DoLine
	mov     ax,di
	jmp     @@DoLine

@@Invisible:
	pop     di
	ret

@@DoLine:
	pop     di
	xchg    cx,ax
	mov     si,dx
	mul     ScrnLogicalByteWidth
	mov     dx,si
	add     ax,di
	mov     di,cx
	sar     di,2
	add     di,ax
	and     si,03h
	mov     ah,byte ptr RightClipPlaneMask[si]
	mov     si,cx
	and     si,03h
	mov     al,byte ptr LeftClipPlaneMask[si]
	cmp     dx,cx
	jle     @@Invisible2
	xchg    cx,dx
	dec     cx
	and     dx,not 03h
	sub     cx,dx
	js      @@Invisible2
	shr     cx,2
	jnz     @@MasksSet
	and     al,ah
@@MasksSet:
	mov     dl,bl
	mov     bx,ax
	mov     ah,dl
	mov     dx,SCINDEX+1
	mov     al,bl
	out     dx,al
	mov     al,ah
	stosb
	dec     cx
	js      @@Invisible2
	jz      @@RightEnd
	mov     al,0fh
	out     dx,al
	mov     al,ah
	shr     cx,1
	rep     stosw
	adc     cx,cx
	rep     stosb

@@RightEnd:
	mov     al,bh
	out     dx,al
	mov     al,ah
	stosb
@@Invisible2:
	ret
end;


procedure HLineClipR2; near; assembler;
asm
	push    di
        cmp cx,ScrnPhysicalHeight
        jae @@invisible
        cmp cx,0
        jb @@invisible
	cmp     dx,ax
	jl      @@Invisible

	cmp     cx,TopClip
	jl      @@Invisible

	cmp     cx,BottomClip
	jg      @@Invisible

	mov     di,RightClip
	sal     di,2
	cmp     ax,di
	jg      @@Invisible
	cmp     dx,di
	jle     @@ClipLeft
	mov     dx,di

@@ClipLeft:
	mov     di,LeftClip
	sal     di,2
	cmp     dx,di
	jl      @@Invisible
	cmp     ax,di
	jge     @@DoLine
	mov     ax,di
	jmp     @@DoLine

@@Invisible:
	pop     di
	ret

@@DoLine:
	pop     di
	xchg    cx,ax
	mov     si,dx
	mul     ScrnLogicalByteWidth
	mov     dx,si
	add     ax,di
	mov     di,cx
	sar     di,2
	add     di,ax
	and     si,03h
	mov     ah,byte ptr RightClipPlaneMask[si]
	mov     si,cx
	and     si,03h
	mov     al,byte ptr LeftClipPlaneMask[si]
	cmp     dx,cx
	jle     @@Invisible2
	xchg    cx,dx
	dec     cx
	and     dx,not 03h
	sub     cx,dx
	js      @@Invisible2
	shr     cx,2
	jnz     @@MasksSet
	and     al,ah
@@MasksSet:
	mov     dl,bl
	mov     bx,ax
	mov     ah,dl
	mov     dx,SCINDEX+1
	mov     al,bl
	out     dx,al
	mov     al,ah
	stosb
	dec     cx
	js      @@Invisible2
	jz      @@RightEnd
	mov     al,0fh
	out     dx,al
	mov     al,ah
	shr     cx,1
	rep     stosw
	adc     cx,cx
	rep     stosb

@@RightEnd:
	mov     al,bh
	out     dx,al
	mov     al,ah
	stosb
@@Invisible2:
	ret
end;

Procedure XTriangle( X0, Y0, X1, Y1, X2, Y2, Color, PageOffset:word ); assembler;
var
	DX01, DY01, DX02, DY02, DX12, DY12,	DP01, DP02, DP12, XA01, XA02, XA12 : word;
asm
	push 		di
	push    es
	push    ds
	mov     ax,X0
	mov     bx,Y0
	mov     cx,X1
	mov     dx,Y1
	cmp     bx,dx
	jl      @@triY0lY1
	je      @@triY0eY1
	xchg    ax,cx
	xchg    bx,dx

@@triY0lY1:
	cmp     dx,Y2
	jg      @@tria
	jmp     @@trisorted
@@tria:
	xchg    cx,X2
	xchg    dx,Y2
	cmp     bx,dx
	jge     @@trib
	jmp     @@trisorted
@@trib:
	je      @@tribot
	xchg    ax,cx
	xchg    bx,dx
	jmp     @@trisorted
@@triY0eY1:
	cmp     bx,Y2
	jl      @@tribot
	jg      @@tric
	jmp     @@tridone
@@tric:
	xchg    ax,X2
	xchg    bx,Y2
	jmp     @@trisorted

@@tribot:
	cmp     ax,cx
	jl      @@tribotsorted
	jg      @@tribota
	jmp     @@tridone
@@tribota:
	xchg    ax,cx
@@tribotsorted:
	cmp     bx,BottomClip
	jle     @@triboty0ok
	jmp     @@tridone
@@triboty0ok:
	mov     si,Y2
	cmp     si,TopClip
	jge     @@triboty2ok
	jmp     @@tridone
@@triboty2ok:
	mov     X0,ax
	mov     Y0,bx
	mov     X1,cx
	mov     Y1,dx

	mov     bx,Y2
	sub     bx,Y0
	mov     DY02,bx
	mov     ax,X2
	sub     ax,X0
	mov     DX02,ax
	mov     cx,ax
	cwd
	idiv    bx
	cmp     cx,0
	jge     @@tribot02
	dec     ax
@@tribot02:
	mov     XA02,ax
	imul    bx
	sub     cx,ax
	mov     DP02,cx

	mov     bx,Y2
	sub     bx,Y1
	mov     DY12,bx
	mov     ax,X2
	sub     ax,X1
	mov     DX12,ax
	mov     cx,ax
	cwd
	idiv    bx
	cmp     cx,0
	jge     @@tribot12
	dec     ax
@@tribot12:
	mov     XA12,ax
	imul    bx
	sub     cx,ax
	mov     DP12,cx

	mov     ax,0
	mov     bx,0
	mov     cx,Y0
	mov     si,X0
	mov     di,X1
	dec     di
@@tribotloop:
	inc     cx

	add     ax,DP02
	jle     @@tribotshortl
	sub     ax,DY02
	inc     si
@@tribotshortl:
	add     si,XA02

	add     bx,DP12
	jle     @@tribotshortr
	sub     bx,DY12
	inc     di
@@tribotshortr:
	add     di,XA12

	push    di
	push    si
	cmp     cx,Y2
	jl      @@tribotloop

	jmp     @@tridrawlines


@@trisorted:
	cmp     bx,BottomClip
	jle     @@triy0ok
	jmp     @@tridone
@@triy0ok:
	mov     si,Y2
	cmp     si,TopClip
	jge     @@triy2ok
	jmp     @@tridone
@@triy2ok:
	mov     X0,ax
	mov     Y0,bx
	mov     X1,cx
	mov     Y1,dx

	mov     bx,dx
	sub     bx,Y0
	mov     DY01,bx
	mov     ax,X1
	sub     ax,X0
	mov     DX01,ax
	mov     cx,ax
	cwd
	idiv    bx
	cmp     cx,0
	jge     @@tripsl01
	dec     ax
@@tripsl01:
	mov     XA01,ax
	imul    bx
	sub     cx,ax
	mov     DP01,cx

	mov     bx,Y2
	sub     bx,Y0
	mov     DY02,bx
	mov     ax,X2
	sub     ax,X0
	mov     DX02,ax
	mov     cx,ax
	cwd
	idiv    bx
	cmp     cx,0
	jge     @@tripsl02
	dec     ax
@@tripsl02:
	mov     XA02,ax
	imul    bx
	sub     cx,ax
	mov     DP02,cx

	mov     bx,Y2
	sub     bx,Y1
	jle     @@triconstcomputed
	mov     DY12,bx
	mov     ax,X2
	sub     ax,X1
	mov     DX12,ax
	mov     cx,ax
	cwd
	idiv    bx
	cmp     cx,0
	jge     @@tripsl12
	dec     ax
@@tripsl12:
	mov     XA12,ax
	imul    bx
	sub     cx,ax
	mov     DP12,cx

@@triconstcomputed:
	mov     ax,DX01
	imul    word ptr DY02
	mov     bx,ax
	mov     cx,dx

	mov     ax,DX02
	imul    word ptr DY01
	cmp     cx,dx
	jg      @@tript1rt
	jl      @@tript1lt
	cmp     bx,ax
	ja      @@tript1rt
	jb      @@tript1lt
	jmp     @@tridone

@@tript1lt:
	mov     ax,0
	mov     bx,0
	mov     cx,Y0
	mov     si,X0
	mov     di,si
	dec     si
@@triltloop:
	inc     cx

	add     ax,DP02
	jle     @@triltshortl
	sub     ax,DY02
	inc     si
@@triltshortl:
	add     si,XA02
	add     bx,DP01
	jle     @@triltshortr
	sub     bx,DY01
	inc     di
@@triltshortr:
	add     di,XA01
	push    si
	push    di
	cmp     cx,Y1
	jl      @@triltloop
	jmp     @@trilbstart
@@trilbloop:
	inc     cx
	add     ax,DP02
	jle     @@trilbshortl
	sub     ax,DY02
	inc     si
@@trilbshortl:
	add     si,XA02

	add     bx,DP12
	jle     @@trilbshortr
	sub     bx,DY12
	inc     di
@@trilbshortr:
	add     di,XA12

	push    si
	push    di
@@trilbstart:
	cmp     cx,Y2
	jl      @@trilbloop
	jmp     @@tridrawlines

@@tript1rt:
	mov     ax,0
	mov     bx,0
	mov     cx,Y0
	mov     si,X0
	mov     di,si
	dec     di
@@trirtloop:
	inc     cx

	add     ax,DP02
	jle     @@trirtshortl
	sub     ax,DY02
	inc     si
@@trirtshortl:
	add     si,XA02

	add     bx,DP01
	jle     @@trirtshortr
	sub     bx,DY01
	inc     di
@@trirtshortr:
	add     di,XA01

	push    di
	push    si
	cmp     cx,Y1
	jl      @@trirtloop
	jmp     @@trirbstart

@@trirbloop:
	inc     cx
	add     ax,DP02
	jle     @@trirbshortl
	sub     ax,DY02
	inc     si
@@trirbshortl:
	add     si,XA02

	add     bx,DP12
	jle     @@trirbshorts
	sub     bx,DY12
	inc     di
@@trirbshorts:
	add     di,XA12

	push    di
	push    si
@@trirbstart:
	cmp     cx,Y2
	jl      @@trirbloop

@@tridrawlines:
	mov     cx,SCREENSEG
	mov     es,cx
	mov     dx,SCINDEX
	mov     al,MAPMASK
	out     dx,al

@@lineloop:
	pop     ax
	pop     dx
	cmp     ax,dx
	jg      @@tridrawnext
	mov     bx,Color
	mov     cx,Y2
	add     dx,2
	mov     di,PageOffset
	call    HLineClipR2
@@tridrawnext:
	dec     word ptr Y2
	dec     word ptr DY02
	jnz     @@lineloop

@@tridone:
	pop     ds
	pop 	  es
	pop 	  di
end;

Procedure XPolygon( var vertices; numvertices, Color, PageOffset:word ); assembler;
var
	x0, y0, tricount : integer;
asm
	mov   cx,numvertices
	cmp   cx,3
	jl    @@Done
	sub   cx,3
	mov   tricount,cx
	les   di,vertices
	mov   ax,es:[di]
	mov   x0,ax
	mov   ax,es:[di+2]
	mov   y0,ax

@@NextTriangle:
	add   di, 4
	mov		ax, x0
	push  ax
	mov   ax, y0
	push  ax
	mov   ax, es:[di+4]
	push  ax
	mov   ax, es:[di+6]
	push  ax
	mov   ax,es:[di]
	push	ax
	mov   ax,es:[di+2]
	push  ax
	mov 	ax, color
	push  ax
	mov 	ax, pageoffset
	push  ax
	call  xtriangle
	dec   tricount
	jns   @@NextTriangle
@@Done:

end;

Procedure XPutCursor( X, Y, TopClip, BottomClip, ScrnOffs : word ); assembler;
var
	Height,TopRow,NextLineIncr:word;
asm
	push  si
	push  di
	push  ds
	mov   ax,seg @data
	mov   ds,ax
	cld
	mov   ax,14
	mov   bx,Y
	mov   dx,TopClip
	sub   dx,bx
	jle   @@NotTopClip
	cmp   dx,ax
	jnl   @@NotVisible
	mov   cx,dx
	sub   ax,dx
	add   bx,dx
	jmp   @@VertClipDone

@@NotVisible:
	pop   ds
	pop   di
	pop   si
	jmp 	@@Done

@@NotTopClip:
	mov   dx,BottomClip
	sub   dx,bx
	js    @@NotVisible
	mov   cx,0
	cmp   dx,ax
	jg    @@VertClipDone
	inc   dx
	mov   ax,dx

@@VertClipDone:
	mov   Height,ax
	mov   TopRow,cx
	mov   ax,SCREENSEG
	mov   es,ax
	mov   ax,bx
	mov   cx,ScrnLogicalByteWidth
	mul   cx
	mov   di,ax
	sub   cx,3
	mov   NextLineIncr,cx
	mov   cx,X
	mov   bx,cx
	shr   cx,2
	add   di,cx
	and   bx,3
	add   di,ScrnOffs
	mov   ax,42
	mul   bx
	mov   si,offset MouseMask
	add   si,ax
	mov   ax,3
	mul   TopRow
	add   si,ax
	mov   dx,SCINDEX
	mov   al,MAPMASK
	out   dx,al
	inc   dx
	mov   ah,byte ptr Height
	mov   bl,MouseColor

@@RowLoop:
	mov   cx,3

@@ColLoop:
	lodsb
	out   dx,al
	mov   es:[di],bl
	inc   di
	loop  @@ColLoop

	add   di,NextLineIncr
	dec   ah
	jnz   @@RowLoop

	pop   ds
	pop   di
	pop   si

@@Done:

end;

Procedure GetBG; near; assembler;
asm
	push  ds
	cld
	mov   cx,ScrnLogicalByteWidth
	mul   cx
	add   si,ax
	sub   cx,3
	shr   bx,2
	add   si,bx
	mov   bx,cx
	mov   di,BGSaveOffs
	mov   ax,SCREENSEG
	mov   es,ax
	mov   ds,ax
	mov   dx,GCINDEX
	mov   ax,BITMASK
	out   dx,ax
	mov   dx,SCINDEX
	mov   al,MAPMASK
	out   dx,al
	inc   dx
	mov   al,0fh
	out   dx,al
	mov   cx,14
@@Loop:
	movsb
	movsb
	movsb
	add si,bx
	loop @@Loop
	mov  dx,GCINDEX+1
	mov  al,0ffh
	out  dx,al
	pop  ds
end;

Procedure RestoreBG; near; assembler;
asm
	push  ds
	cld
	mov   cx,ScrnLogicalByteWidth
	mul   cx
	add   di,ax
	sub   cx,3
	shr   bx,2
	add   di,bx
	mov   si,BGSaveOffs
	mov   ax,SCREENSEG
	mov   es,ax
	mov   ds,ax
	mov   dx,GCINDEX
	mov   ax,BITMASK
	out   dx,ax
	mov   dx,SCINDEX
	mov   al,MAPMASK
	out   dx,al
	inc   dx
	mov   al,0fh
	out   dx,al
	mov   bx,cx
	mov   cx,14
@@Loop:
	movsb
	movsb
	movsb
	add di,bx
	loop @@Loop
	mov  dx,GCINDEX+1
	mov  al,0ffh
	out  dx,al
	pop   ds
end;

Procedure UpdateCursor; near; assembler;
asm
	mov dx,InputStatus0
@@WaitNotVsync:
	in  al,dx
	test al,08h
	jnz @@WaitNotVSync
@@WaitVSync:
	in  al,dx
	test al,08h
	jz  @@WaitVSync
	mov di,OldScrnOffs
	mov ax,OldY
	mov bx,OldX
	call restorebg
	mov si,VisiblePageOffs
	mov ax,MouseY
	mov bx,MouseX
	mov OldScrnOffs,si
	mov OldY,ax
	mov OldX,bx
	call getbg
	push OldX
	push OldY
	mov  ax,0
	push ax
	mov  ax,ScrnPhysicalHeight
	push ax
	push VisiblePageOffs
	call xputcursor
end;

Procedure MouseHandler; far; assembler;
asm
	push  ds
	mov   di,seg @data
	mov   ds,di
	cmp   inhandler,1
	jne   @@NotActive
	jmp 	@@Done2
@@NotActive:
	mov   inhandler,1
	mov   MouseButtonStatus,bx
	test  ax,1
	jz    @@Done
	shr   cx,1
	mov   MouseX,cx
	mov   MouseY,dx
	cmp   MouseHidden,1
	je    @@Done
	cmp   MouseFrozen,1
	je    @@Done
	call  updatecursor

@@Done:
	mov  inhandler,0
@@Done2:
	pop  ds
end;

Procedure XDefineMouseCursor( var MouseDef; MouseColor:byte ); assembler;
asm
	cmp   MouseInstalled,0
	je    @@Done
	mov   al,MouseColor
	mov   MouseColor,al
	push  si
	push  di
	push  ds
	mov   ax,ds
	mov   es,ax
	mov   di,offset MouseMask
	lds   si,MouseDef
	xor   cl,cl
@@AlignmentLoop:
	push  si
	mov   dh,14
@@RowLoop:
	lodsb
	xor   ah,ah
	shl   ax,cl
	mov   bl,al
	and   bl,0fh
	mov   es:[di],bl
	inc   di
	shr   al,4
	stosw
	dec   dh
	jnz   @@RowLoop
	pop   si
	inc   cl
	cmp   cl,4
	jne   @@AlignmentLoop
	pop   ds
	pop   di
	pop   si
@@Done:
end;


procedure XMouseInit; assembler;
asm
	mov   InHandler,0
	mov 	mousehidden,0
	mov 	BGSaveOffs,0
	mov 	MouseX,0
	mov 	MOuseY,0
	mov		MouseButtonStatus,0
	mov		MouseFrozen,0
	mov 	MouseColor,0
	mov 	MouseInstalled,0
	cmp   MouseButtonCount,0
	jne   @@DontInitialize
	xor   ax,ax
	int   33h
	or    ax,ax
	jz    @@Done
	mov   MouseButtonCount,bx

@@DontInitialize:
	mov   MouseInstalled,ax
	or    ax,ax
	jz    @@Done
	mov   ax,NonVisualOffs
	mov   BGSaveOffs,ax
	add   ax,42
	mov   NonVisualOffs,ax
	mov   ax,02
	int   33h
	mov   MouseInstalled,1
	mov   ax,07h
	mov   cx,0
	mov   dx,ScrnPhysicalPixelWidth
	shl   dx,1
	int   33h
	mov   ax,08h
	mov   cx,0
	mov   dx,ScrnPhysicalHeight
	int   33h
	mov   ax,0fh
	mov   cx,4
	mov   dx,8
	int   33h
	mov   ax,3
	int   33h
	mov   MouseY,dx
	shr   cx,1
	mov   MouseX,cx
	mov   ax,12
	mov   bx,seg mousehandler
	mov   es,bx
	mov   dx,offset mousehandler
	mov   cx,1fh
	int   33h
	mov   MouseHidden,1
	push  ds
	mov   ax,offset InitMouseDef
	push  ax
	mov   al, MouseColor
	push  ax
	call  xdefinemousecursor
	mov   ax,MouseInstalled
@@Done:
end;

Procedure XMouseWindow( x0, y0, x1, y1:word ); assembler;
asm
	mov   ax,7
	mov   cx,x0
	shl   cx,1
	mov   dx,x1
	shl   dx,1
	int   33h
	mov   ax,8
	mov   cx,y0
	mov   dx,y1
	int   33h
end;


procedure XShowMouse; assembler;
asm
	cmp   MouseInstalled,0
	je    @@Done
	cmp   MouseHidden,0
	je    @@Done
	push  si
	push  di

@@WaitEndOfHandler:
	mov   cl,inhandler
	or    cl,cl
	jnz   @@WaitEndOfHandler
	mov   si,VisiblePageOffs
	mov   ax,MouseY
	mov   bx,MouseX
	mov   OldScrnOffs,si
	mov   OldY,ax
	mov   OldX,bx
	call  getbg
	push  OldX
	push  OldY
	xor   ax,ax
	push  ax
	push  ScrnLogicalHeight
	push  VisiblePageOffs
	call  xputcursor
	mov   MouseHidden,0
	pop   di
	pop   si
@@Done:
end;

Procedure XHideMouse; assembler;
asm
	cmp   MouseInstalled,0
	je    @@Done
	cmp   MouseHidden,0
	jne   @@Done
	push  si
	push  di
@@WaitEndOfHandler:
	mov   cl,inhandler
	or    cl,cl
	jnz   @@WaitEndOfHandler
	mov   MouseHidden,TRUE
	mov   di,OldScrnOffs
	mov   ax,OldY
	mov   bx,OldX
	call  restorebg
	pop   di
	pop   si
@@Done:
end;

Procedure XMouseRemove; assembler;
asm
	cmp   MouseInstalled,0
	je    @@Done
	call  xhidemouse
	mov   ax,12
	xor   cx,cx
	int   33h
	mov   MouseInstalled,0
@@Done:
end;

Procedure XPositionMouse( X, Y : word ); assembler;
asm
@@WaitEndOfHandler:
	mov   bl,inhandler
	or    bl,bl
	jnz   @@WaitEndOfHandler
	mov   ax,4
	mov   cx,X
	mov   dx,Y
	mov   MouseX,cx
	mov   MouseY,dx
	shl   cx,1
	mov   inhandler,1
	int   33h
	cmp   MouseHidden,FALSE
	jne   @@NotVisible
	push  di
	push  si
	call  updatecursor
	pop   si
	pop   di
@@NotVisible:
	mov   inhandler,0
end;

Procedure XUpdateMouse; assembler;
asm
	cmp   MouseInstalled,0
	je    @@Done
	cmp   MouseHidden,0
	jne   @@Done
	push  si
	push  di
	mov   ax,03h
	int   33h
	shr   cx,1
	mov   MouseX,cx
	mov   MouseY,dx
	mov   MouseButtonStatus,bx
	call  updatecursor
	pop   di
	pop   si
@@Done:
end;

Procedure XPutMaskedPBMClipX( X, Y, ScrnOffs:word; var Bitmap ); assembler;
var
	Plane:byte;
	CType,LeftSkip,DataInc,Width,Height,TopRow,LineInc:word;
asm
	push  ds
	cld
	les   si,Bitmap
	xor   ax,ax
	mov   CType,ax
	mov   al,byte ptr es:[si]
	mov   di,X
	mov   cx,di
	sar   di,2
	mov   dx,LeftClip
	sub   dx,di
	jle   @@NotLeftClip
	cmp   dx,ax
	jnl   @@NotVisible
	add   di,dx
	mov   LeftSkip,dx
	mov   DataInc,dx
	sub   ax,dx
	mov   CType,1
	jmp   @@HorizClipDone

@@NotVisible:
	mov   ax,1
	jmp @@Bye

@@NotLeftClip:
	mov   dx,RightClip
	sub   dx,di
	js    @@NotVisible
	mov   LeftSkip,0
	mov   DataInc,0
	cmp   dx,ax
	jge   @@HorizClipDone
	inc   dx
	sub   ax,dx
	mov   DataInc,ax
	mov   ax,dx
	mov   CType,-1
@@HorizClipDone:
	xor   bh,bh
	mov   bl,byte ptr es:[si+1]
	mov   Width,ax
	mov   Height,bx
	add   si,2
	add   si,LeftSkip
	mov   bx,ScrnLogicalByteWidth
	mov   dx,bx
	sub   dx,ax
	mov   LineInc,dx
	mov   ax,Y
	mul   bx
	add   di,ax
	add   di,ScrnOffs
	mov   ax,es
	mov   ds,ax
	mov   ax,SCREENSEG
	mov   es,ax
	and   cx,3
	mov   ah,11h
	shl   ah,cl
	mov   dx,SCINDEX
	mov   al,MAPMASK
	out   dx,al
	inc   dx
	mov   Plane,4
	mov   bh,byte ptr Width
@@PlaneLoop:
	push  di
	mov   bl,byte ptr Height
	mov   al,ah
	out   dx,al
@@RowLoop:
	mov   cl,bh
	jcxz  @@NoWidth
@@ColLoop:
	lodsb
	or    al,al
	jz    @@NoPixel
	mov   es:[di],al
@@NoPixel:
	inc   di
	loop @@ColLoop
@@NoWidth:
	add   si,DataInc
	add   di,LineInc
	dec   bl
	jnz   @@RowLoop
	pop   di
	rol   ah,1
	jnb   @@Nocarry
	mov   bl,ah
	mov   ax,CType
	add   bh,al
	sub   DataInc,ax
	sub   LineInc,ax
	cmp   al,0
	mov   ah,bl
	jg    @@RightAdvance
	inc   di
	jmp   @@Nocarry
@@RightAdvance:
	dec si
@@Nocarry:
	dec   Plane
	jnz   @@PlaneLoop
	xor   ax,ax
@@Bye:
	pop   ds

end;

procedure XPutMaskedPBMClipY( X, Y, ScrnOffs:word; var Bitmap ); assembler;
var
	Width,Height,TopRow,LineInc,PlaneInc:word;
asm
	push  ds
	cld
	les   si,Bitmap
	xor   bh,bh
	mov   bl,byte ptr es:[si+1]
	xor   ah,ah
	mov   al,byte ptr es:[si]
	mov   cx,ax
	mul   bx
	mov   PlaneInc,ax
	mov   ax,cx
	mov   di,X
	mov   cx,di
	shr   di,2
	mov   dx,TopClip
	sub   dx,Y
	jle   @@NotTopClip
	cmp   dx,bx
	jnl   @@NotVisible
	mov   TopRow,dx
	sub   bx,dx
	add   Y,dx
	jmp   @@VertClipDone

@@NotVisible:
	mov   ax,1
	pop   ds
	pop   di
	pop   si
	mov   sp,bp
	pop   bp
	ret

@@NotTopClip:
	mov   dx,BottomClip
	sub   dx,Y
	js    @@NotVisible
	mov   TopRow,0
	cmp   dx,bx
	jg    @@VertClipDone
	inc   dx
	mov   bx,dx

@@VertClipDone:

	mov   Width,ax
	mov   Height,bx
	mul   TopRow
	add   ax,2
	add   si,ax


	mov   ax,Y
	mov   bx,ScrnLogicalByteWidth
	mul   bx
	add   di,ax
	add   di,ScrnOffs
	sub   bx,Width
	mov   LineInc,bx
	mov   ax,es
	mov   ds,ax
	mov   ax,SCREENSEG
	mov   es,ax

	mov   ah,11h
	and   cx,3
	shl   ah,cl

	mov   dx,SCINDEX
	mov   al,MAPMASK
	out   dx,al
	inc   dx
	mov   bh,4
@@PlaneLoop:
	push  di
	push  si
	mov   bl,byte ptr Height
	mov   al,ah
	out   dx,al
@@RowLoop:
	mov   cl,byte ptr Width
@@ColLoop:
	lodsb
	or    al,al
	jz    @@NoPixel
	mov   es:[di],al
@@NoPixel:
	inc   di
	loop  @@ColLoop
	add   di,LineInc
	dec   bl
	jnz   @@RowLoop
	pop   si
	add   si,PlaneInc
	pop   di
	rol   ah,1
	adc   di,0
	dec   bh
	jnz   @@PlaneLoop
	xor   ax,ax
	pop   ds
end;

Procedure XPutMaskedPBMClipXY( X, Y, ScrnOffs:word; var Bitmap ); assembler;
var
	Plane:byte;
	CType,LeftSkip,DataInc,Width,Height,TopRow,LineInc,PlaneInc:word;
asm
	push  ds
	cld
	les   si,Bitmap
	xor   ax,ax
	mov   CType,ax
	mov   al,byte ptr es:[si]
	xor   bh,bh
	mov   bl,byte ptr es:[si+1]
	mov   cx,ax
	mul   bx
	mov   PlaneInc,ax
	mov   ax,cx
	mov   di,X
	mov   cx,di
	sar   di,2
	mov   dx,TopClip
	sub   dx,Y
	jle   @@NotTopClip
	cmp   dx,bx
	jnl   @@NotVisible
	mov   TopRow,dx
	sub   bx,dx
	add   Y,dx
	jmp   @@VertClipDone

@@NotVisible:
	mov   ax,1
	jmp @@Bye

@@NotTopClip:
	mov   dx,BottomClip
	sub   dx,Y
	js    @@NotVisible
	mov   TopRow,0
	cmp   dx,bx
	jg    @@VertClipDone
	inc   dx
	mov   bx,dx

@@VertClipDone:
	mov   dx,LeftClip
	sub   dx,di
	jle   @@NotLeftClip
	cmp   dx,ax
	jnl   @@NotVisible
	add   di,dx
	mov   LeftSkip,dx
	mov   DataInc,dx
	sub   ax,dx
	mov   CType,1
	jmp   @@HorizClipDone

@@NotLeftClip:
	mov   dx,RightClip
	sub   dx,di
	js    @@NotVisible
	mov   LeftSkip,0
	mov   DataInc,0
	cmp   dx,ax
	jge   @@HorizClipDone
	inc   dx
	sub   ax,dx
	mov   DataInc,ax
	mov   ax,dx
	mov   CType,-1

@@HorizClipDone:
	mov   Width,ax
	mov   Height,bx
	add   ax,DataInc
	mul   TopRow
	add   si,ax
	add   si,2
	add   si,LeftSkip
	mov   bx,ScrnLogicalByteWidth
	mov   dx,bx
	sub   dx,Width
	mov   LineInc,dx
	mov   ax,Y
	mul   bx
	add   di,ax
	add   di,ScrnOffs
	mov   ax,es
	mov   ds,ax
	mov   ax,SCREENSEG
	mov   es,ax
	and   cx,3
	mov   ah,11h
	shl   ah,cl
	mov   dx,SCINDEX
	mov   al,MAPMASK
	out   dx,al
	inc   dx
	mov   Plane,4
	mov   bh,byte ptr Width
@@PlaneLoop:
	push  di
	push  si
	mov   bl,byte ptr Height
	mov   al,ah
	out   dx,al
@@RowLoop:
	mov   cl,bh
	jcxz   @@NoWidth
@@ColLoop:
	lodsb
	or    al,al
	jz    @@NoPixel
	mov   es:[di],al
@@NoPixel:
	inc   di
	loop @@ColLoop
@@NoWidth:
	add   si,DataInc
	add   di,LineInc
	dec   bl
	jnz   @@RowLoop
	pop   si
	add   si,PlaneInc
	pop   di
	rol   ah,1
	jnb   @@Nocarry
	mov   bl,ah
	mov   ax,CType
	add   bh,al
	sub   DataInc,ax
	sub   LineInc,ax
	cmp   al,0
	mov   ah,bl
	jg    @@RightAdvance
	inc   di
	jmp   @@Nocarry
@@RightAdvance:
	dec   si
@@Nocarry:
	dec   Plane
	jnz   @@PlaneLoop

	xor   ax,ax
@@Bye:
	pop   ds
end;

Procedure XPutPBMClipX( X, Y, ScrnOffs:word; var Bitmap ); assembler;
var
	Plane:byte;
	CType,LeftSkip,DataInc,Width,Height,TopRow,LineInc:word;
asm
	push  ds
	cld
	les   si,Bitmap
	xor   ax,ax
	mov   CType,ax
	mov   al,byte ptr es:[si]
	mov   di,X
	mov   cx,di
	sar   di,2
	mov   dx,LeftClip
	sub   dx,di
	jle   @@NotLeftClip
	cmp   dx,ax
	jnl   @@NotVisible
	add   di,dx
	mov   LeftSkip,dx
	mov   DataInc,dx
	sub   ax,dx
	mov   CType,1
	jmp   @@HorizClipDone

@@NotVisible:
	mov   ax,1
	jmp @@Bye

@@NotLeftClip:
	mov   dx,RightClip
	sub   dx,di
	js    @@NotVisible
	mov   LeftSkip,0
	mov   DataInc,0
	cmp   dx,ax
	jge   @@HorizClipDone
	inc   dx
	sub   ax,dx
	mov   DataInc,ax
	mov   ax,dx
	mov   CType,-1

@@HorizClipDone:
	xor   bh,bh
	mov   bl,byte ptr es:[si+1]
	mov   Width,ax
	mov   Height,bx
	add   si,2
	add   si,LeftSkip
	mov   bx,ScrnLogicalByteWidth
	mov   dx,bx
	sub   dx,ax
	mov   LineInc,dx
	mov   ax,Y
	mul   bx
	add   di,ax
	add   di,ScrnOffs
	mov   ax,es
	mov   ds,ax
	mov   ax,SCREENSEG
	mov   es,ax
	and   cx,3
	mov   ah,11h
	shl   ah,cl
	mov   dx,SCINDEX
	mov   al,MAPMASK
	out   dx,al
	inc   dx
	mov   Plane,4
	mov   bh,byte ptr Width
@@PlaneLoop:
	push  di
	mov   bl,byte ptr Height
	mov   al,ah
	out   dx,al
@@RowLoop:
	mov   cl,bh
	shr   cl,1
	rep   movsw
	adc   cl,0
	rep   movsb
	add   si,DataInc
	add   di,LineInc
	dec   bl
	jnz   @@RowLoop
	pop   di
	rol   ah,1
	jnb   @@Nocarry
	mov   bl,ah
	mov   ax,CType
	add   bh,al
	sub   DataInc,ax
	sub   LineInc,ax
	cmp   al,0
	mov   ah,bl
	jg    @@RightAdvance
	inc   di
	jmp   @@Nocarry
@@RightAdvance:
	dec si
@@Nocarry:
	dec   Plane
	jnz   @@PlaneLoop
	xor   ax,ax
@@Bye:
	pop   ds
end;


Procedure XPutPBMClipY( X, Y, ScrnOffs : word; var Bitmap ); assembler;
var
	Width,Height,TopRow,LineInc,PlaneInc:word;
asm
	push  ds
	cld
	les   si,Bitmap
	xor   bh,bh
	mov   bl,byte ptr es:[si+1]
	xor   ah,ah
	mov   al,byte ptr es:[si]
	mov   [Width],ax

	mov   cx,ax
	mul   bx
	mov   PlaneInc,ax
	mov   ax,cx

	mov   di,X
	mov   cx,di
	and   cx,3
	shr   di,2
	mov   dx,TopClip
	sub   dx,Y
	jle   @@NotTopClip
	cmp   dx,bx
	jnl   @@NotVisible
	mov   TopRow,dx
	sub   bx,dx
	add   Y,dx
	jmp   @@VertClipDone

@@NotVisible:
	mov   ax,1
	jmp @@Bye

@@NotTopClip:
	mov   dx,BottomClip
	sub   dx,Y
	js    @@NotVisible
	mov   TopRow,0
	cmp   dx,bx
	jg    @@VertClipDone
	inc   dx
	mov   bx,dx

@@VertClipDone:

	mov   Height,bx
	mul   TopRow
	add   ax,2
	add   si,ax
	mov   ax,Y
	mov   bx,ScrnLogicalByteWidth
	mul   bx
	add   di,ax
	add   di,ScrnOffs
	sub   bx,Width
	mov   LineInc,bx
	mov   ax,es
	mov   ds,ax
	mov   ax,SCREENSEG
	mov   es,ax
	mov   ah,11h
	shl   ah,cl
	mov   dx,SCINDEX
	mov   al,MAPMASK
	out   dx,al
	inc   dx
	mov   bh,4
@@PlaneLoop:
	push  di
	push  si
	mov   bl,byte ptr Height
	mov   al,ah
	out   dx,al
@@RowLoop:
	mov   cl,byte ptr Width
	shr   cl,1
	rep   movsw
	adc   cl,0
	rep   movsb
	add   di,LineInc
	dec   bl
	jnz   @@RowLoop
	pop   si
	add   si,PlaneInc
	pop   di
	rol   ah,1
	adc   di,0
	dec   bh
	jnz   @@PlaneLoop
	xor   ax,ax
@@Bye:
	pop   ds
end;

Procedure XPutPBMClipXY( X, Y, ScrnOffs:word; var Bitmap ); assembler;
var
	Plane:byte;
	CType,LeftSkip,DataInc,Width,Height,TopRow,LineInc,PlaneInc:word;
asm
	push  ds
	cld
	les   si,Bitmap
	xor   ax,ax
	mov   CType,ax
	mov   al,byte ptr es:[si]
	xor   bh,bh
	mov   bl,byte ptr es:[si+1]
	mov   cx,ax
	mul   bx
	mov   PlaneInc,ax
	mov   ax,cx
	mov   di,X
	mov   cx,di
	sar   di,2
	mov   dx,TopClip
	sub   dx,Y
	jle   @@NotTopClip
	cmp   dx,bx
	jnl   @@NotVisible
	mov   TopRow,dx
	sub   bx,dx
	add   Y,dx
	jmp   @@VertClipDone

@@NotVisible:
	mov   ax,1
	jmp @@Bye

@@NotTopClip:
	mov   dx,BottomClip
	sub   dx,Y
	js    @@NotVisible
	mov   TopRow,0
	cmp   dx,bx
	jg    @@VertClipDone
	inc   dx
	mov   bx,dx

@@VertClipDone:
	mov   dx,LeftClip
	sub   dx,di
	jle   @@NotLeftClip
	cmp   dx,ax
	jnl   @@NotVisible
	add   di,dx
	mov   LeftSkip,dx
	mov   DataInc,dx
	sub   ax,dx
	mov   CType,1
	jmp   @@HorizClipDone

@@NotLeftClip:
	mov   dx,RightClip
	sub   dx,di
	js    @@NotVisible
	mov   LeftSkip,0
	mov   DataInc,0
	cmp   dx,ax
	jge   @@HorizClipDone
	inc   dx
	sub   ax,dx
	mov   DataInc,ax
	mov   ax,dx
	mov   CType,-1

@@HorizClipDone:
	mov   Width,ax
	mov   Height,bx
	add   ax,DataInc
	mul   TopRow
	add   si,ax
	add   si,2
	add   si,LeftSkip
	mov   bx,ScrnLogicalByteWidth
	mov   dx,bx
	sub   dx,Width
	mov   LineInc,dx
	mov   ax,Y
	mul   bx
	add   di,ax
	add   di,ScrnOffs
	mov   ax,es
	mov   ds,ax
	mov   ax,SCREENSEG
	mov   es,ax
	and   cx,3
	mov   ah,11h
	shl   ah,cl
	mov   dx,SCINDEX
	mov   al,MAPMASK
	out   dx,al
	inc   dx
	mov   Plane,4
	mov   bh,byte ptr Width
@@PlaneLoop:
	push  di
	push  si
	mov   bl,byte ptr Height
	mov   al,ah
	out   dx,al
@@RowLoop:
	mov   cl,bh
	shr   cl,1
	rep   movsw
	adc   cl,0
	rep   movsb
	add   si,DataInc
	add   di,LineInc
	dec   bl
	jnz   @@RowLoop
	pop   si
	add   si,PlaneInc
	pop   di
	rol   ah,1
	jnb   @@Nocarry
	mov   bl,ah
	mov   ax,CType
	add   bh,al
	sub   DataInc,ax
	sub   LineInc,ax
	cmp   al,0
	mov   ah,bl
	jg    @@RightAdvance
	inc   di
	jmp   @@Nocarry

@@RightAdvance:
	dec si

@@Nocarry:
	dec   Plane
	jnz   @@PlaneLoop
	xor   ax,ax
@@Bye:
	pop   ds
end;

Procedure XStoreVBMImage( VramOffs,Align:word; var LBitmap ); assembler;
var
	BMWidth:byte;
asm
	push  si
	push  di
	push  ds
	cld
	mov   ax,SCREENSEG
	mov   es,ax
	mov   di,VramOffs
	mov   bx,Align
	and   bl,03h
	lds   si,LBitmap
	lodsw
	mov   bh,ah
	mov   BMWidth,al
	mov   dx,SCINDEX
	mov   al,MAPMASK
	out   dx,al
	inc   dx
	xor   ch,ch
@@RowLoop:
	mov   cl,bl
	mov   ah,11h
	shl   ah,cl
	mov   cl,BMWidth
@@ColLoop:
	mov   al,ah
	out   dx,al
	lodsb
	mov   es:[di],al
	shl   ah,1
	jnb   @@NoAddrIncr
	inc   di
	mov   ah,11h
@@NoAddrIncr:
	loop  @@ColLoop
	cmp   ah,11h
	inc   di
	dec   bh
	jnz   @@RowLoop
	mov   ax,di
	sub   ax,VramOffs
	pop   ds
	pop   di
	pop   si
end;

Procedure XPutMaskedVBM( X, Y, ScrnOffs:word; var SrcVBM ); assembler;
var
	VBMWidth, VBMHeight, NextLineIncr:word;
asm
	push  si
	push  di
	push  ds
	cld
	mov   ax,SCREENSEG
	mov   es,ax
	mov   ax,Y
	mov   cx,ScrnLogicalByteWidth
	mul   cx
	mov   di,ScrnOffs
	add   di,ax
	mov   si,X
	mov   bx,si
	shr   bx,2
	add   di,bx
	and   si,3
	lds   bx,SrcVBM
	shl   si,2
	mov 	ax,word ptr [bx+VBMInfoStruc.ImageHeight]
	mov   VBMHeight,ax
	mov 	ax,word ptr [bx+VBMInfoStruc.ImageWidth]
	mov   VBMWidth,ax
	sub   cx,ax
	mov   NextLineIncr,cx
	mov   dx,[bx+VBMAlignmentStruc.MaskPtr+AlignData+si]
	mov   bx,[bx+VBMAlignmentStruc.ImagePtr+AlignData+si]
	mov   si,dx
	mov   dx,GCINDEX
	mov   ax,BITMASK
	out   dx,ax
	mov   dx,SCINDEX
	mov   al,MAPMASK
	out   dx,al
	inc   dx
	mov   ah,byte ptr VBMHeight

@@RowLoop:
	mov   cx,VBMWidth

@@ColumnLoop:
	lodsb
	out   dx,al
	mov   al,es:[bx]
	stosb
	inc   bx
	loop  @@ColumnLoop
	add   di,NextLineIncr
	dec   ah
	jnz   @@RowLoop
	mov   dx,GCINDEX+1
	mov   al,0ffh
	out   dx,al
	pop   ds
	pop   di
	pop   si
end;

Procedure XPutMaskedVBMClipX( X, Y, ScrnOffs:word; var SrcVBM ); assembler;
var
	DataInc,LeftSkip,VBMWidth,VBMHeight,NextLineIncr:word;
asm
	push  si
	push  di
	push  ds
	cld
	mov   di,X
	mov   si,di
	sar   di,2
	and   si,3
	shl   si,2
	les   bx,SrcVBM
	mov   cx,es:[bx+VBMInfoStruc.ImageWidth]
	mov   dx,LeftClip
	sub   dx,di
	jle   @@NotLeftClip
	cmp   dx,cx
	jnl   @@NotVisible
	add   di,dx
	mov   LeftSkip,dx
	mov   DataInc,dx
	sub   cx,dx
	jmp   @@HorizClipDone

@@NotVisible:
	mov   ax,1
	jmp 	@@Bye

@@NotLeftClip:
	mov   dx,RightClip
	sub   dx,di
	js    @@NotVisible
	mov   LeftSkip,0
	mov   DataInc,0
	cmp   dx,cx
	jge   @@HorizClipDone
	inc   dx
	sub   cx,dx
	mov   DataInc,cx
	mov   cx,dx

@@HorizClipDone:
	add   di,ScrnOffs
	mov   VBMWidth,cx
	mov   ax,es:[bx+VBMInfoStruc.ImageHeight]
	mov   VBMHeight,ax
	mov   ax,Y
	mov   cx,ScrnLogicalByteWidth
	mul   cx
	add   di,ax
	sub   cx,VBMWidth
	mov   NextLineIncr,cx
	mov   ax,es
	mov   ds,ax
	mov   ax,SCREENSEG
	mov   es,ax
	mov   ax,[bx+VBMAlignmentStruc.MaskPtr+AlignData+si]
	mov   bx,[bx+VBMAlignmentStruc.ImagePtr+AlignData+si]
	mov   si,ax
	mov   ax,LeftSkip
	add   bx,ax
	add   si,ax
	mov   dx,GCINDEX
	mov   ax,BITMASK
	out   dx,ax
	mov   dx,SCINDEX
	mov   al,MAPMASK
	out   dx,al
	inc   dx
	mov   ah,byte ptr VBMHeight

@@RowLoop:
	mov   cx,VBMWidth

@@ColumnLoop:
	lodsb
	out   dx,al
	mov   al,es:[bx]
	stosb
	inc   bx
	loop  @@ColumnLoop
	add   bx,DataInc
	add   si,DataInc
	add   di,NextLineIncr
	dec   ah
	jnz   @@RowLoop

	mov   dx,GCINDEX+1
	mov   al,0ffh
	out   dx,al
	xor   ax,ax
@@Bye:
	pop   ds
	pop   di
	pop   si
end;

Procedure XPutMaskedVBMClipY( X, Y, ScrnOffs : word; var SrcVBM ); assembler;
var
	VBMWidth,VBMHeight,TopRow,NextLineIncr:word;
asm
	push  si
	push  di
	push  ds
	cld
	mov   di,X
	mov   si,di
	and   si,3
	shl   si,2
	les   bx,SrcVBM
	mov   ax,es:[bx+VBMInfoStruc.ImageHeight]
	mov   dx,TopClip
	sub   dx,Y
	jle   @@NotTopClip
	cmp   dx,ax
	jnl   @@NotVisible
	mov   TopRow,dx
	sub   ax,dx
	add   Y,dx
	jmp   @@VertClipDone

@@NotVisible:
	mov   ax,1
	jmp   @@Bye

@@NotTopClip:
	mov   dx,BottomClip
	sub   dx,Y
	js    @@NotVisible
	mov   TopRow,0
	cmp   dx,ax
	jg    @@VertClipDone
	inc   dx
	mov   ax,dx

@@VertClipDone:
	shr   di,2
	add   di,ScrnOffs
	mov   cx,es:[bx+VBMInfoStruc.ImageWidth]
	mov   VBMWidth,cx
	mov   VBMHeight,ax
	mov   ax,Y
	mov   cx,ScrnLogicalByteWidth
	mul   cx
	add   di,ax
	sub   cx,VBMWidth
	mov   NextLineIncr,cx
	mov   ax,es
	mov   ds,ax
	mov   ax,SCREENSEG
	mov   es,ax

	mov   ax,[bx+VBMAlignmentStruc.MaskPtr+AlignData+si]
	mov   bx,[bx+VBMAlignmentStruc.ImagePtr+AlignData+si]
	mov   si,ax
	mov   ax,VBMWidth
	mul   TopRow
	add   bx,ax
	add   si,ax
	mov   dx,GCINDEX
	mov   ax,BITMASK
	out   dx,ax
	mov   dx,SCINDEX
	mov   al,MAPMASK
	out   dx,al
	inc   dx
	mov   ah,byte ptr [VBMHeight]

@@RowLoop:
	mov   cx,VBMWidth

@@ColumnLoop:
	lodsb
	out   dx,al
	mov   al,es:[bx]
	stosb
	inc   bx
	loop  @@ColumnLoop
	add   di,NextLineIncr
	dec   ah
	jnz   @@RowLoop
	mov   dx,GCINDEX+1
	mov   al,0ffh
	out   dx,al
	xor   ax,ax
@@Bye:
	pop   ds
	pop   di
	pop   si
end;

Procedure XPutMaskedVBMClipXY( X, Y, ScrnOffs:word; var SrcVBM ); assembler;
var
	DataInc,LeftSkip,VBMWidth,VBMHeight,TopRow,NextLineIncr:word;
asm
	push  si
	push  di
	push  ds
	cld
	mov   di,X
	mov   si,di
	sar   di,2
	and   si,3
	shl   si,2
	les   bx,SrcVBM
	mov   cx,es:[bx+VBMInfoStruc.ImageWidth]
	mov   ax,es:[bx+VBMInfoStruc.ImageHeight]
	mov   dx,TopClip
	sub   dx,Y
	jle   @@NotTopClip
	cmp   dx,ax
	jnl   @@NotVisible
	mov   TopRow,dx
	sub   ax,dx
	add   Y,dx
	jmp   @@VertClipDone

@@NotVisible:
	mov   ax,1
	jmp   @@Bye

@@NotTopClip:
	mov   dx,BottomClip
	sub   dx,Y
	js    @@NotVisible
	mov   TopRow,0
	cmp   dx,ax
	jg    @@VertClipDone
	inc   dx
	mov   ax,dx

@@VertClipDone:
	mov   dx,LeftClip
	sub   dx,di
	jle   @@NotLeftClip
	cmp   dx,cx
	jnl   @@NotVisible
	add   di,dx
	mov   LeftSkip,dx
	mov   DataInc,dx
	sub   cx,dx
	jmp   @@HorizClipDone
@@NotLeftClip:
	mov   dx,RightClip
	sub   dx,di
	js    @@NotVisible
	mov   LeftSkip,0
	mov   DataInc,0
	cmp   dx,cx
	jge   @@HorizClipDone
	inc   dx
	sub   cx,dx
	mov   DataInc,cx
	mov   cx,dx

@@HorizClipDone:
	add   di,ScrnOffs
	mov   VBMWidth,cx
	mov   VBMHeight,ax
	mov   ax,Y
	mov   cx,ScrnLogicalByteWidth
	mul   cx
	add   di,ax
	sub   cx,VBMWidth
	mov   NextLineIncr,cx
	mov   ax,es
	mov   ds,ax
	mov   ax,SCREENSEG
	mov   es,ax

	mov   ax,[bx+VBMAlignmentStruc.MaskPtr+AlignData+si]
	mov   bx,[bx+VBMAlignmentStruc.ImagePtr+AlignData+si]
	mov   si,ax
	mov   ax,VBMWidth
	add   ax,DataInc
	mul   TopRow
	add   ax,LeftSkip
	add   bx,ax
	add   si,ax
	mov   dx,GCINDEX
	mov   ax,BITMASK
	out   dx,ax
	mov   dx,SCINDEX
	mov   al,MAPMASK
	out   dx,al
	inc   dx
	mov   ah,byte ptr VBMHeight

@@RowLoop:
	mov   cx,VBMWidth

@@ColumnLoop:
	lodsb
	out   dx,al
	mov   al,es:[bx]
	stosb
	inc   bx
	loop  @@ColumnLoop
	add   bx,DataInc
	add   si,DataInc
	add   di,NextLineIncr
	dec   ah
	jnz   @@RowLoop

	mov   dx,GCINDEX+1
	mov   al,0ffh
	out   dx,al
	xor   ax,ax
@@Bye:
	pop   ds
	pop   di
	pop   si
end;

function XMakeVBM( var lbm; var VramStart : word ) : PAlignmentHeader;
var
	LBMHeadr : ^LBMheader;
	VBMHeadr : PAlignmentHeader;
	VBMMaskPtr, p, LBMPixelPtr : ^byte;
	align,BitNum,TempImageWidth, scanline : integer;
	TempWidth,TempHeight,TempSize,MaskSize,VramOffs,MaskSpace : word;
	MaskTemp : byte;
begin
	VramOffs := VramStart;
	LBMHeadr := @lbm;
	TempWidth  := (LBMHeadr^.width+3) div 4+1;
	TempHeight := LBMHeadr^.height;
	TempSize   := TempWidth*TempHeight;
	getmem( VBMHeadr,22+TempSize*4);
	MaskSpace:=22;
	VBMHeadr^.ImageWidth  := TempWidth;
	VBMHeadr^.ImageHeight := TempHeight;
	VBMHeadr^.size := 22+TempSize*4;
	for align := 0 to 3 do
	begin
		VBMHeadr^.alignments[align].ImagePtr := VramOffs;
		XStoreVBMImage(VramOffs,align,lbm);
		MaskSpace := MaskSpace+TempSize;
		VramOffs := VramOffs+TempSize;
	end;
	VBMMaskPtr := ptr(Seg(VBMHeadr^),Ofs(VBMHeadr^)+22);
	for align:=0 to 3 do
	begin
		LBMPixelPtr := ptr(Seg(lbm),Ofs(lbm)+ 2);
		VBMHeadr^.alignments[align].MaskPtr := Ofs(VBMMaskPtr^);
		for scanline := 0 to TempHeight-1 do
		begin
			BitNum := align;
			MaskTemp := 0;
			TempImageWidth := LBMHeadr^.width;
			repeat
				MaskTemp := MaskTemp or (Ord(LBMPixelPtr^<>0) shl BitNum);
				LBMPixelPtr := Ptr(Seg(LBMPixelPtr^),Ofs(LBMPixelPtr^)+1);
				inc(BitNum);
				if BitNum > 3 then
				begin
					VBMMaskPtr^ := MaskTemp;
					VBMMaskPtr := Ptr(Seg(VBMMaskPtr^),Ofs(VBMMaskPtr^)+1);
					MaskTemp := 0;
					BitNum := 0;
				end;
				dec(TempImageWidth);
			until TempImageWidth=0;
			if BitNum<>0 then VBMMaskPtr^ := MaskTemp else VBMMaskPtr^ := 0;
			VBMMaskPtr := Ptr(Seg(VBMMaskPtr^),Ofs(VBMMaskPtr^)+1);
		end;
	end;
	VramStart :=VramOffs;
	XMakeVBM := VBMHeadr;
end;

End.