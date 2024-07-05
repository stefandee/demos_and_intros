; Turbo Assembler    Copyright (c) 1988, 1991 By Borland International, Inc.

; COMPROG.ASM - Template for writing .COM files.

; From the Turbo Assembler Users Guide

P8086          ;select the processor
MODEL TINY     ;always must be TINY model

DATASEG
   ;<<Any initialized data is defined here>>
   errmsg db 'Cannot allocate$'

UDATASEG
   ;<<Any uninitialized data is defined here>>

   ;<<Set up room for user stack, if default stack is not desired>>
   DW 100H DUP (?)

CODESEG        ;this marks the start of executable code
   STARTUPCODE
   ;COM has all available memory allocated to it
     mov ah,48h
     mov bx,1
     int 21h
     jc  error
     jp  endprg
   error:
     mov dx,seg errmsg
     mov ds,dx	
     mov dx,offset errmsg
     mov ah,9
     int 21h

   ;Exit to DOS when complete
endprg:
   MOV AH,4CH
   INT 21H
   RET

END
