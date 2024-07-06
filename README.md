# Demos And Intros

Welcome my collection of demos and intros, developed between 1995-1997.

Back in those days, I've started to grew an interest for low level graphics programming. In 1995, university got internet and in that year, I've spent nights there scouring FTPs for graphic programming tutorials. While I eventually got to be good at it, demos also required music and I was absolutely dreadful at audio programming. Initial attempts at writing a mod player following docs didn't go very well and had to find ready-made mod players. This is why music integration/syncronization with the effects is virtually non-existent.

With a little exception, all of these were coded in a mix of Pascal and x86 assembler. Music support is provided from external/pre-compiled libraries.

Running the precompiled binaries require MS-DOS or emulator (DOSBox, FreeDOS, etc). If running in DOSBox, use cpu cycles in the 10-15k range (CTRL+F12)

You'll find below a detailed list of them and a brief story for each one, as much as I can remember.

## Amorphis
It's a 64k demo made in 1996, the best one I managed to make given my total lack of art direction (or art...anything)

It features a mix of 2D and 3D effects, all pretty standard and maybe a bit dated for that year. I'm proud of the credits effect, a pixel tornado, which I think it was original.

3D shapes could've used some Gouraud or Phong shading, but they're just plain shaded. Lazy 3D programming ;)

Just like the previous demos, starts with an unskippable scrolling message. Bad, bad, UX ;)

Title is a nod to one of my favorite metal bands of the 90s, Amorphis.

This one comes with a credit to my late graphics programming teacher at university, Mr Sorin Babii (PhD). Rest in pixels.

[Amorphis Title](.media/amorphis-title.gif)
[Amorphis Tunnel](.media/amorphis-tunnel.gif)
[Amorphis Moire Pattern](.media/amorphis-moire-pattern.gif)
[Amorphis Voxels](.media/amorphis-voxels.gif)
[Amorphis Tornado](.media/amorphis-tornado.gif)

## Iced
It's a 16k demo made in 1996, featuring a mix of 2D and 3D. The highlight is almost real-time ray tracing: it pre-renders a couple of animation frames in memory, hence "almost". Still pretty cool for 16k.

I was big fan of pixel effects from my ZX Spectrum days, so there's one. And the usual fractals + fancy 3D scrolling.

Credits shoud've been at the end and skippable. Bad UX ;)

Executable was obfuscated using a tool called Gardian Angel. Why? Smart kids use protection ;)

[ICED Raytracing](.media/iced-raytracing.gif)
[ICED Rose](.media/iced-rose.gif)

## Compile
My first demo, showing off a combination of 2D and 3D effects, all pretty standard. Developed in February-March 1996 on a 386-DX40 (heh)

Badly lacks art and direction, but at least you can use ESC to skip through scenes. Whew. Good UX.

[Compile Sailing](.media/compile-sailing.gif)

## Mercury Wind
A tiny intro for Traian Pop's birthday, features an animated fractal tree. Coded in an afternoon.

[Mercury Wind Intro](.media/mercury-wind.gif)

## Infelif
Small intro made as a digital present for my father to use as a screen-saver at his workplace, InfELIF Constanta. Developed in the summer of 1994.

InfELIF was the computer department of IELIF ("Intreprinderea pentru Exploatarea Lucrarilor de Imbunatatiri Funciare"), a Romanian state-own company which managed land improvement/reclamation projects. This included irigation, hence the cute pixel art water sprinklers sprinkling water in the intro :)

[Infelif Intro](.media/infelif.gif)

## Scroll Balls and Snow
Intro/gifts for my father to use as screensavers at his workplace, Petroconst, in 1996. 

Snow features a pixel snow effect, Scroll Balls a 3D scrolling effect, both developed previously for Compile demo.

[Scroll Balls Intro](.media/scrollballs.gif)
[Snow Intro](.media/snow.gif)

## Torent
Beach themed intro for a BBS that was running in my hometowm, Constanta in 1997. Not sure if the sysop ended up using it. Or if the BBS ever went online.

Sand effect was previously developed in Amorphis.

[Torent Intro](.media/torent.gif)

## XTest
A tester for various extended VESA graphics modes, featuring a bump map with real-time illumination and a 2D pallete effect. Made as a showcase for a lab at university.

[XTest Intro](.media/xtest.gif)

## Little
A full assembler (TASM dialect) intro, featuring.......lots...of...points........in...3D..........

[Little Intro](.media/little.gif)

## Harmony
An unfinished demo, developed together with a colleague, Marcel Hanches. Don't have a build for it, but the idea was projecting and animating multi-dimensional surfaces. Not even sure what this was supposed to mean, but we had some good times brain-storming about it.

## Setup&Install&Build (original, DOS)

They may only be built using Turbo/Borland Pascal. The full assembler ones require Turbo Assembler (TASM), part of the Borland tool suite.

## License

Code license:
https://opensource.org/licenses/MIT

Artwork license:
https://creativecommons.org/licenses/by-nc-sa/4.0/

