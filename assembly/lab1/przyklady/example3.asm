.386
.MODEL flat, STDCALL

stala equ 10

.data
	zmienna1 db 10h
	ALIGN 4
	zmienna2 dw 10h
	zmienna3 dd 10h
.code

main proc
	mov eax, stala
	add eax, 5
	add ax, 5
	add ax, zmienna2
	add ax, zmienna2
	add eax, zmienna3
	add al,5
	add ah,5
main endp

END