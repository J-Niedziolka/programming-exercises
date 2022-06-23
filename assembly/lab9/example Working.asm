.586P
.MODEL flat, STDCALL
;--- pliki ---------
include grafika.inc

;--- sta³e ---
CSstyle EQU CS_HREDRAW+CS_VREDRAW+CS_GLOBALCLASS
BSstyle EQU BS_PUSHBUTTON+WS_VISIBLE+WS_CHILD+WS_TABSTOP
WNDstyle EQU WS_CLIPCHILDREN+WS_OVERLAPPEDWINDOW+WS_HSCROLL+WS_VSCROLL
EDTstyle EQU WS_VISIBLE+WS_CHILD+WS_TABSTOP+WS_BORDER
CBstyle EQU WS_VISIBLE+WS_CHILD+WS_TABSTOP+WS_BORDER+CBS_DROPDOWNLIST+CBS_HASSTRINGS
LBstyle EQU WS_VISIBLE+WS_CHILD+WS_TABSTOP+WS_BORDER+CBS_HASSTRINGS
STATstyle EQU WS_VISIBLE+WS_CHILD+WS_BORDER+SS_LEFT
kolor EQU 000000FFh ; czerwony  ; kolory: G B R
;--- sekcja danych ------
_DATA SEGMENT
 hwnd		DD	0
 hinst	DD	0
 hdc        DD	0
 hbutt	DD	0
 hedt 	DD	0
 hbrush     DD    0
 holdbrush  DD    0
 hcb     	DD	0
 hlb     	DD	0
 hmdi 	DD	0
 hstat 	DD	0
 ;---
 msg MSGSTRUCT <?> 
 wndc WNDCLASS <?>
 ;---
 naglow	DB	"Autor Jan Masztalski.",0
 rozmN	DD	$ - naglow	;iloœæ znaków w tablicy
 ALIGN	4	; przesuniecie do adresu podzielnego na 4
 puste	DB	"_____________________"	; spacje
 rozmP	DD	$ - puste	;iloœæ znaków w tablicy
 ALIGN	4	; przesuniecie do adresu podzielnego na 4
 tytul	DB "Aplikacja graficzna",0
 ALIGN 4
 cname	DB "MainClass", 0
 ALIGN 4
 MES1       DB "Lewy, myszy",0
 ALIGN 4
 tbutt	DB	"BUTTON", 0
 ALIGN 4
 tstart	DB	"Start", 0
 ALIGN 4
 tedt	      DB	"EDIT", 0
 ALIGN 4
 tnazwaedt	DB	" ", 0
 ALIGN 4
 tcb	      DB	"COMBOBOX", 0
 ALIGN 4
 tnazwacb	DB	" ", 0
 ALIGN 4
 tlb	      DB	"LISTBOX", 0
 ALIGN 4
 tnazwalb	DB	" ", 0
 ALIGN 4
 tstat	      DB	"STATIC", 0
 ALIGN 4
 tnazwastat	DB	"Test STATIC", 0
 ALIGN 4
 ttekst	DB	"tekst", 0
 ALIGN 4
 ttekst1	DB	"tekst1", 0
 ALIGN 4
 ttekst2	DB	"tekst2", 0
 ALIGN 4
 nagl		DB	"Komunikat", 0
 ALIGN 4
 terr		DB	"B³¹d!", 0
 ALIGN 4
 terr2	DB	"B³¹d 2!", 0
 ALIGN 4
 bufor	DB	128 dup(' ')	; bufor ze spacjami
 rbuf		DD	128	; rozmiar buforu
 znaczn     DD    0
 rt   RECT  <220,50,320,90>
 rr   DD    0
_DATA ENDS
;--- sekcja kodu ---------
_TEXT SEGMENT
;;;;;;;;;;;;;;;;;;;;;;;
WndProc PROC
;--- procedura okna ---
; DWORD PTR [EBP+14h] - parametr LPARAM komunikatu
; DWORD PTR [EBP+10h] - parametr WPARAM komunikatu
; DWORD PTR [EBP+0Ch] - ID = identyfikator komunikatu
; DWORD PTR [EBP+08h] - HWND = deskryptor okna
 ;------------------------------------
 push	EBP	; standardowy prolog
 mov	EBP, ESP	; standardowy prolog
;--- odk³adanie na stos
 push	EBX
 push	ESI
 push	EDI
 cmp	DWORD PTR [EBP+0Ch], WM_CREATE
 jne	@F
 jmp	wmCREATE
@@:	
 cmp	DWORD PTR [EBP+0Ch], WM_DESTROY
 jne	@F
 jmp	wmDESTROY
@@:	
 cmp DWORD PTR [EBP+0CH], WM_COMMAND
 jne	@F
 jmp	wmCOMMAND
@@:	
 cmp DWORD PTR [EBP+0CH], WM_LBUTTONDOWN
 jne	@F
 jmp	wmLBUTTON
@@:	
 cmp DWORD PTR [EBP+0CH], WM_RBUTTONDOWN
 jne	@F
 jmp	wmRBUTTON
@@:	
;--- komunikaty nieobs³ugiwane ---
 INVOKE DefWindowProcA, DWORD PTR [EBP+08h], DWORD PTR [EBP+0Ch], DWORD PTR [EBP+10h], DWORD PTR [EBP+14h]
 jmp	konWNDPROC
wmCREATE:
;--- utworzenie klawisza ---
 INVOKE CreateWindowExA, 0, OFFSET tbutt, OFFSET tstart,  BSstyle, 10, 50, 100, 40, DWORD PTR [EBP+08h], 0, hinst, 0
 mov	hbutt, EAX
;--- utworzenie okna edycyjnego ---
 INVOKE CreateWindowExA, 0, OFFSET tedt, OFFSET tnazwaedt,  EDTstyle, 10, 100, 100, 40, DWORD PTR [EBP+08h], 0, hinst, 0
 mov	hedt, EAX
 INVOKE SendMessageA, hedt,WM_SETTEXT,0,OFFSET ttekst
 INVOKE SetFocus,hedt
 INVOKE CreateSolidBrush,kolor
 mov hbrush,EAX
;--- utworzenie okna COMBOBOX ---
 INVOKE CreateWindowExA, 0, OFFSET tcb, OFFSET tnazwacb,  CBstyle, 120, 50, 100, 140, DWORD PTR [EBP+08h], 0, hinst, 0
 mov	hcb, EAX
 INVOKE SendMessageA, hcb,CB_ADDSTRING,0,OFFSET ttekst1
 INVOKE SendMessageA, hcb,CB_ADDSTRING,0,OFFSET ttekst2
 INVOKE SendMessageA, hcb,CB_SELECTSTRING,-1,OFFSET ttekst
;--- utworzenie okna LISTBOX ---
 INVOKE CreateWindowExA, 0, OFFSET tlb, OFFSET tnazwalb,  LBstyle, 220, 150, 100, 100, DWORD PTR [EBP+08h], 0, hinst, 0
 mov	hlb, EAX
 INVOKE SendMessageA, hlb,LB_ADDSTRING,0,OFFSET ttekst1
 INVOKE SendMessageA, hlb,LB_ADDSTRING,0,OFFSET ttekst2
 INVOKE SendMessageA, hlb,LB_SELECTSTRING,-1,OFFSET ttekst
 ;----
 INVOKE UpdateWindow, hcb
;--- utworzenie okna STATIC ---
 INVOKE CreateWindowExA, 0, OFFSET tstat, OFFSET tnazwastat,  STATstyle, 10, 150, 100, 40, DWORD PTR [EBP+08h], 0, hinst, 0
 mov	hstat, EAX
;---
 mov EAX,0
 jmp	konWNDPROC 
wmDESTROY:
 INVOKE DeleteObject, hbrush
 INVOKE PostQuitMessage, 0	; wysy³anie WM_QUIT
 mov	EAX, 0
 jmp	konWNDPROC 
wmCOMMAND:
 mov EAX,hbutt
 cmp EAX,DWORD PTR [EBP+14h] ;czy LPARAM komunikatu WM_COMMAND = hbutt?
 je @F
 jmp et1
@@:  
 cmp znaczn,1
 je @F
 mov znaczn,1
 INVOKE SelectObject,hDC,hbrush
 mov holdbrush,EAX
 INVOKE FillRect,hDC,OFFSET rt,hbrush
 mov	EAX, 0
 jmp konWNDPROC
@@:  		
 mov znaczn,0
 INVOKE SelectObject,hDC,holdbrush
 mov hbrush,EAX
 INVOKE FillRect,hDC,OFFSET rt,holdbrush
 mov	EAX, 0
 jmp konWNDPROC
et1:
 jmp konWNDPROC
wmRBUTTON:
 jmp wmDESTROY
wmLBUTTON:
 INVOKE SendMessageA,hedt,WM_GETTEXT,128,OFFSET bufor
 mov rr,EAX 
 INVOKE TextOutA,hDC,120,120,OFFSET bufor,rr 
 mov EAX,0
 jmp konWNDPROC
;--- zdejmowanie ze stosu
konWNDPROC:	
 pop	EDI
 pop	ESI
 pop	EBX
 pop	EBP	; standardowy epilog
 ret	16	; zwolnienie komórek stosu
WndProc	ENDP
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;--- start programu ---
main proc
;--- deskryptor aplikacji ----
 INVOKE GetModuleHandleA, 0
 mov	hinst, EAX
;--- wype³nienie struktury okna WNDCLASS
 mov EAX, hinst
 mov [wndc.clsHInstance], EAX
 mov [wndc.clsStyle], CSstyle
 mov [wndc.clsLpfnWndProc], OFFSET WndProc
 mov [wndc.clsCbClsExtra], 0 
 mov [wndc.clsCbWndExtra], 0 
 INVOKE LoadIconA, 0, IDI_APPLICATION	; ikona
 mov [wndc.clsHIcon], EAX
 INVOKE LoadCursorA, 0,	IDC_ARROW ; kursor
 mov	[wndc.clsHCursor], EAX
 INVOKE GetStockObject, WHITE_BRUSH	; t³o
 mov [wndc.clsHbrBackground], EAX
 mov [wndc.clsLpszMenuName], 0
 mov DWORD PTR [wndc.clsLpszClassName], OFFSET cname
;--- rejestracja okna --- 
 INVOKE RegisterClassA, OFFSET wndc
 cmp	EAX, 0
 jne @F
 jmp	err0
@@:
;--- utworzenie okna g³ównego ---
 INVOKE CreateWindowExA, 0, OFFSET cname, OFFSET tytul,  WNDstyle, 50, 50, 600, 400, 0, 0, hinst, 0
 cmp	EAX, 0
 jne @F
 jmp	err2
@@:
 mov	hwnd, EAX
 INVOKE ShowWindow, hwnd, SW_SHOWNORMAL 		
 INVOKE GetDC,hwnd
 mov hdc,EAX
 INVOKE lstrlenA,OFFSET naglow
 mov rozmN,EAX 		
 INVOKE TextOutA,hDC,10,20,OFFSET naglow,rozmN 		
 INVOKE UpdateWindow, hwnd
;--- pêtla obs³ugi komunikatów
msgloop:
 INVOKE GetMessageA, OFFSET msg, 0, 0, 0
 cmp EAX, 0
 jne @F
 jmp	etkon
@@:		
 cmp	EAX, -1
 jne @F
 jmp	err0
@@:		
 INVOKE TranslateMessage, OFFSET msg
 INVOKE DispatchMessageA, OFFSET msg
 jmp	msgloop
;--- obs³uga b³êdów ---------
err0:
;--- okno z komunikatem o b³êdzie----
 INVOKE MessageBoxA,0,OFFSET terr,OFFSET nagl,0
 jmp	etkon
err2:
;--- okno z komunikatem o b³êdzie----
 INVOKE MessageBoxA,0,OFFSET terr2,OFFSET nagl,0
 jmp	etkon
;--- zakoñczenie procesu ---------
etkon:
 INVOKE ExitProcess, [msg.msWPARAM]

 main endp
_TEXT	ENDS
END
