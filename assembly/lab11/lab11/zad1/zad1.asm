ExitProcess PROTO :QWORD
Powit		PROTO :DB

_DATA SEGMENT
	zmA	QWORD 1

	zaprA	DB	0Dh,0Ah,"Witamy w architekturze 64 bitowej ",0
	ALIGN	4
	rozmA	DD	$ - zaprA	;liczba znaków w tablicy

	imie QWORD 0Dh, 0Ah,"%ld",0
	ALIGN 8
	rozmI DD $ - imie
	rout	DD	0 ;faktyczna liczba wyprowadzonych znaków
	rinp	DD	0 ;faktyczna liczba wprowadzonych znaków
	bufor	DB	128 dup(?)
	rbuf	DD	128
_DATA ENDS

_TEXT SEGMENT
	
main proc
;
;
;
;mov EAX offset 
;call Powit

mov RCX, 0
;push RCX
call ExitProcess
main endp

_TEXT ENDS
END