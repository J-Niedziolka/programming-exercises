.386
.MODEL FLAT, STDCALL

include grafika.inc

CSstyle		EQU		CS_HREDRAW + CS_VREDRAW + CS_GLOBALCLASS
WNDstyle	EQU		WS_CLIPCHILDREN + WS_OVERLAPPEDWINDOW + WS_HSCROLL+WS_VSCROLL

.data 
	hinst		DWORD				0
	msg			MSGSTRUCT			<?> 
	wndc		WNDCLASS			<?>
	
	cname		BYTE				"MainClass", 0
	hwnd		DWORD				0
	hdc			DWORD				0
	tytul		BYTE				"Pyra",0
	naglow		BYTE				"Naglowek",0
	rozmN		DWORD				0
	nagl		BYTE				"Komunikat", 0
	terr		BYTE				"blad!", 0
	terr2		BYTE				"blad2!", 0
	ziemniaczek	DWORD				0
.code 

WndProc PROC uses EBX ESI EDI windowHandle:DWORD, uMsg:DWORD, wParam:DWORD, lParam:DWORD
 
	INVOKE DefWindowProcA, windowHandle, uMsg, wParam, lParam

ret 
WndProc ENDP

main proc

	;wypelnienie struktury wndc WNDClass
	;pdf 4.1 	

	mov [wndc.clsStyle], CSstyle				;ustawienie pierwszego pola struktury
	mov [wndc.clsLpfnWndProc], OFFSET WndProc	;ustawieinie drugiego pola struktury

	INVOKE GetModuleHandleA, 0
	mov	hinst, EAX
	mov [wndc.clsHInstance], EAX				;ustawieinie drugiego pola struktury
	;---------------ustaw reszte pol struktury
	;clsCbClsExtra   	DWORD     0
	;clsCbWndExtra   	DWORD     0
	;clsHIcon        	DWORD     0      
	;clsHCursor      	DWORD     0       
	;clsHbrBackground 	DWORD     0       
	;clsLpszMenuName 	DWORD     0      
	;clsLpszClassName 	DWORD     0  




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