.386
.MODEL FLAT, STDCALL

include grafika.inc

CSstyle equ CS_HREDRAW+CS_VREDRAW+CS_GLOBALCLASS
WNDstyle EQU WS_CLIPCHILDREN+WS_OVERLAPPEDWINDOW+WS_HSCROLL+WS_VSCROLL

.data 
	hinst	DD				0
	msg		MSGSTRUCT		<?> 
	wndc	WNDCLASS		<?>
	
	cname	DB				"MainClass", 0
	hwnd	DD				0
	hdc		DD				0
	tytul	DB				"Pyra",0
	naglow	DB				"Naglowek",0
	rozmN	DD				0
	nagl	DB				"Komunikat", 0
	terr	DB				"blad!", 0
	terr2	DB				"blad2!", 0
	ziemniaczek	DD				0
.code 

WndProc PROC uses EBX ESI EDI windowHandle:DWORD, uMsg:DWORD, wParam:DWORD, lParam:DWORD
 
	INVOKE DefWindowProcA, windowHandle, uMsg, wParam, lParam

ret 
WndProc ENDP

main proc

	;wypelnienie struktury wndc WNDClass
	;pdf 4.1
	mov DWORD PTR [wndc.clsLpszClassName], OFFSET cname

	;rejestracja okna z pomoc¹ struktury WNDClass
	;pdf 4.2
	;obsluga bledow
	.IF EAX == 0
		jmp err0
	.ENDIF

	;utworzenie okna glownego aplikacji
	;pdf 4.8
	

	;sprawdzenie rejestru eax czy nastapil blad podczas tworzenia okna aplikacji
	.IF EAX == 0
		jmp	err2
	.ENDIF
	;zapis uchwytu do okna glownego do zmiennej, uchwyt w eax
	mov	hwnd, EAX

	;wyswietlenie okna 
	;4.9
	

	;pobieramy uchwyt do kontekstu okna(kanwy) by bezposrednio na niej rysowac
	;pdf 4.10 w przykladzie odrazu wykorzstanie procedury TextOutA ktora rysuje bezposrednio tekst z bufora na kanwe, oraz UpdateWindow ktora przerysowywuje okno


	;ponizej wstawiamy breakpoint by okno nam sie nie zamknelo
	err0:
	 INVOKE MessageBoxA,0,OFFSET terr,OFFSET nagl,0
	 jmp	etkon
	err2:
	 INVOKE MessageBoxA,0,OFFSET terr2,OFFSET nagl,0	
	etkon:

	push 0
	call ExitProcess
main endp

END