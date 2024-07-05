.386
.387
MODEL TINY     

DATASEG
   ;<<Any initialized data is defined here>>
   op1 dq 1.5
   op2 dq 0
CODESEG        
   FInit
   Fld op1
   FMUL st(0),st(0)
   FWAIT
   FST op2		
   MOV AH,4CH
   INT 21H
   RET

END
