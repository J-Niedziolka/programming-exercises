.386
.MODEL flat, STDCALL
includelib .\lib\user32.lib
includelib .\lib\kernel32.lib

stala equ 10
STD_OUTPUT_HANDLE                    equ -11

GetStdHandle PROTO :DWORD
WriteConsoleA PROTO :DWORD,:DWORD,:DWORD,:DWORD,:DWORD
ExitProcess PROTO :DWORD

.data
	zmienna1 db 10h
	ALIGN 4
	zmienna2 dw 10h
	zmienna3 dd 10h
	
	zaprA	DB	0Dh,0Ah,"Hello this is dog ",0
	ALIGN	4
	rozmA	DD	$ - zaprA	;liczba znak�w w tablicy
	zmA	DD	1	; argument A

	rout	DD	0 ;faktyczna liczba wyprowadzonych znak�w
	hout 	DD 	0
	
.code

start:
	mov eax, stala
	add eax, 5
	add ax, 5
	add ax, 0FFAAh ;dlaczego warto�� natychmiastowa konwertowana jest do 1bajta
	add ax, zmienna2
	add ax, zmienna2
	add eax, zmienna3
	add al,5
	add ah,5
	
	push	STD_OUTPUT_HANDLE
	call	GetStdHandle	; wywo�anie funkcji GetStdHandle
	mov	hout, EAX	; deskryptor wyj�ciowego bufora konsoli
	
	push	0		; rezerwa, musi by� zero
	push	OFFSET rout 	; wska�nik na faktyczn� liczba wyprowadzonych znak�w 
	push	rozmA		; liczba znak�w
	push	OFFSET zaprA 	; wska�nik na tekst
 	push	hout		; deskryptor buforu konsoli
	call	WriteConsoleA	; wywo�anie funkcji WriteConsoleA   
	
	push 0 
	call ExitProcess
end start

END