.386
.MODEL flat, STDCALL

stala equ 10

.data
	zmienna1 BYTE 10h

	zmienna2 WORD 10h
	
	zmienna4 DWORD 10,10,10,10
	zmienna5 DWORD 10 dup(0)
	zmienna6 BYTE 10 dup(0)
	text	 BYTE "ABCDE"
	zmienna3 DWORD  10h
	text2 	 BYTE 614, 624, 634, 644, 654
	
.code

main proc
	mov al, stala
	mov ax, stala
	mov eax, stala
	
	mov al, zmienna1
	mov ax, zmienna2
	mov eax, zmienna3

main endp

END