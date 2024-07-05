comment +

How to use the VIBRANTS play-driver
-----------------------------------

These cool drivers are ... cool!  The song included here is a TINY 3.1k, but
it sounds as good as most MODs.  And it only requires an AdLib!  And takes up
much less time to play!  Wow.

Anyway, JCH said he'd release a doc explaining how to use them.  Well, so far
... I haven't seen anything.  So, hacking into the drivers (and looking at the
KUKOO source code, :), I figured out how to use them.

One thing you should know:  The soundblaster driver (SBL-0103.P01) seems to
require some other initializations (probably the soundblaster port, IRQ, etc),
and I can't figure out how to do that.  So, the D01 songs don't work!  (The
digital intstruments are all garbled, yuck).

Anyway, here's the code!  Assemble it with TASM (MASM shmasm!), and ... have
fun! Heh.  Oh, don't forget to use forward references!  (/m)

If you want to get the whole Play-Driver package, call The Revelation Station
at 604-477-5337.  Please note!  That these drivers and songs are 100%
copyrighted by the authors, VIBRANTS.  DON'T USE THEM IN YOUR PROGRAMS WITHOUT
PERMISSION!  As this is not a 'program', but rather a 'tutorial', I hope they
won't get mad.  :)

comment end! +

; *****************************************************************************

.model  large, c

; *****************************************************************************

PDATA segment para public 'PDATA'

        ; Player and music segment

        include driver.inc                      ; driver include file
        MusicOffset = $-PDATA                   ; Offset for the music
        include song.inc                        ; the music!

PDATA ends

; *****************************************************************************
; Entry point!
; *****************************************************************************

.code

        push    cs
        pop     ds

        jmp     start

; *****************************************************************************

MusicDriver     proc

        ; General-purpose Music Driver call

MusicPatch      label
        nop

        call    dword ptr cs:[Player]
        ret

Player  DW      0,0

MusicDriver     endp

; *****************************************************************************

newint1c        proc

        ; New interrupt 1c!

        push    ax
        push    si

        mov     ah, 3                   ; Update music
        call    MusicDriver

        pop     si
        pop     ax

        pushf
        call    dword ptr [oldint1c]

        iret

        oldint1c        dd      0

newint1c        endp

; *****************************************************************************
; Main code!
; *****************************************************************************

start:
        mov     ax, PDATA
        mov     Player[2], ax

        mov     ah, 6
        call    MusicDriver

        jnc     InitializedOk           ; card was there, it's ok

        ; Card not there, so patch code to use a RET instead of NOP
        ; This way, no extra coding involved to cancel calls to
        ; the player.  This test program doesn't do anything BUT
        ; play music, so ... :)
        mov     byte ptr cs:[MusicPatch], 0C3h

InitializedOk:
        ; Initialize the music now
        mov     ah, 0                           ; funciton 0, init music
        mov     bx, PDATA                       ; segment of MUSIC
        mov     cx, MusicOffset                 ; offset of MUSIC
        call    MusicDriver

        mov     ah, 2                           ; Not sure what this one does, but it's required
        mov     bx, 0
        call    MusicDriver

        ; Music all initialized ...
        ; Note that si is destroyed in calls to MusicDriver, so if you're using it, you'd
        ; better save and restore it!

        ; *****************************************************************************
        ; Set the CPS of the song ...
        ; *****************************************************************************

        push    ds
        mov     ax, PDATA
        mov     ds, ax

        ; Which version of music file are we using?  If it's version > 01.14, then the
        ; CPS of the song is stored in the 9th byte.  < 01.14, and it's the second byte.
        mov     bx, MusicOffset
        cmp     word ptr [bx], 0434ah   ; "JC"
        jne     _old_vers

        mov     bx, MusicOffset+8
        jmp     _init_loc1

_old_vers:
        mov     bx, MusicOffset+1

_init_loc1:
        ; Get CPS
        mov     al, byte ptr [bx]
        xor     ah, ah
        pop     ds

        ; Set the calls to the timer to our CPS.
        mov     bx, ax                  ; Figure out 1193180/cycles to get
        mov     ax, 34DCh               ; proper divisor for timer
        mov     dx, 12h
	div	bx

        mov     al, 00110110b           ; Set timer interrupt 0 to the
        out     43h, al                 ; divisor
        out     40h, al
        mov     al, ah
        out     40h, al

        ; *****************************************************************************

        ; Save old interrupt
        mov     ax, 351ch
        int     21h
        mov     word ptr [oldint1c], bx
        mov     word ptr [oldint1c+2], es

        ; Put in new interrupt
        push    ds
        mov     ax, seg newint1c
        mov     ds, ax
        mov     dx, offset newint1c
        mov     ax, 251ch
        int     21h
        pop     ds

        ; Wait for a key
        mov     ah, 0
        int     16h

        ; Put in old interrupt
        push    ds
        mov     ax, word ptr [oldint1c+2]
        mov     ds, ax
        mov     dx, word ptr [oldint1c]
        mov     ax, 251ch
        int     21h
        pop     ds

        ; Shut down music
        mov     ah, 2
        mov     bx, 0
        call    MusicDriver

        ; Reset timer to standard ...
        mov     al, 00110110b
        out     43h, al
        mov     ax, 65535
        out     40h, al
        mov     al, ah
        out     40h, al

        ; Outta here!
        mov     ax, 4c00h
        int     21h

end
