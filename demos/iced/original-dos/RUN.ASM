MODEL TINY
.386

EXTRN _main : PROC

.CODE
 	call far ptr _main
	mov ah, 4ch
	int 21h
end

