.386
.MODEL flat, STDCALL
;--- stale ---
STD_INPUT_HANDLE                     equ -10
STD_OUTPUT_HANDLE                    equ -11
;--- funkcje API Win32 ---
;--- z pliku  user32.inc ---
CharToOemA PROTO :DWORD,:DWORD
;--- z pliku kernel32.inc ---
GetStdHandle PROTO :DWORD
ReadConsoleA PROTO :DWORD,:DWORD,:DWORD,:DWORD,:DWORD
WriteConsoleA PROTO :DWORD,:DWORD,:DWORD,:DWORD,:DWORD
ExitProcess PROTO :DWORD
wsprintfA PROTO C :VARARG
lstrlenA PROTO :DWORD
;--- procedura w naszej bibliotece ----
SCANINT PROTO

_DATA SEGMENT
	hout	DD	?
	hinp	DD	?
	naglow	DB	"Autor aplikacji .... Jan Niedzi�ka.",0
	ALIGN	4	; przesuniecie do adresu podzielnego na 4
	rozmN	DD	$ - naglow	;liczba znak�w w tablicy
	zaprA	DB	0Dh,0Ah,"Prosz� wprowadzi� ci�g cyfr zako�czony 0: ",0
	ALIGN	4
	rozmA	DD	$ - zaprA	;liczba znak�w w tablicy
	zmA	DD	1	; argument A

	rout	DD	0 ;faktyczna liczba wyprowadzonych znak�w
	rinp	DD	0 ;faktyczna liczba wprowadzonych znak�w
	bufor	DB	128 dup(?)
	rbuf	DD	128

	wynik	DB	0Dh,0Ah,"Liczba zwr�cona przez ScanInt = %ld",0  ;%ld oznacza formatowanie w formacie dziesi�tnym
	ALIGN	4
	rozmW	DD	$ - wynik	;liczba znak�w w tablicy
_DATA ENDS
;------------
_TEXT SEGMENT
main proc
;--- wywo�anie funkcji GetStdHandle 
	push	STD_OUTPUT_HANDLE
	call	GetStdHandle	; wywo�anie funkcji GetStdHandle
	mov	hout, EAX	; deskryptor wyj�ciowego bufora konsoli
	push	STD_INPUT_HANDLE
	call	GetStdHandle	; wywo�anie funkcji GetStdHandle
	mov	hinp, EAX	; deskryptor wej�ciowego bufora konsoli
;--- nag��wek ---------
	push	OFFSET naglow
	push	OFFSET naglow
	call	CharToOemA	; konwersja polskich znak�w
;--- wy�wietlenie ---------
	push	0		; rezerwa, musi by� zero
	push	OFFSET rout	; wska�nik na faktyczn� liczba wyprowadzonych znak�w 
	push	rozmN		; liczba znak�w
	push	OFFSET naglow 	; wska�nik na tekst
 	push	hout		; deskryptor buforu konsoli
	call	WriteConsoleA	; wywo�anie funkcji WriteConsoleA
;--- zaproszenie A ---------
	push	OFFSET zaprA
	push	OFFSET zaprA
	call	CharToOemA	; konwersja polskich znak�w
;--- wy�wietlenie zaproszenia A ---
	push	0		; rezerwa, musi by� zero
	push	OFFSET rout 	; wska�nik na faktyczn� liczba wyprowadzonych znak�w 
	push	rozmA		; liczba znak�w
	push	OFFSET zaprA 	; wska�nik na tekst
 	push	hout		; deskryptor buforu konsoli
	call	WriteConsoleA	; wywo�anie funkcji WriteConsoleA   
;--- czekanie na wprowadzenie znak�w, koniec przez Enter ---
	push	0 		; rezerwa, musi by� zero
	push	OFFSET rinp 	; wska�nik na faktyczn� liczba wprowadzonych znak�w 
	push	rbuf 		; rozmiar bufora
	push	OFFSET bufor ;wska�nik na bufor
 	push	hinp		; deskryptor buforu konsoli
	call	ReadConsoleA	; wywo�anie funkcji ReadConsoleA
	lea   EBX,bufor
	mov   EDI,rinp
	mov   BYTE PTR [EBX+EDI-2],0 ;zero na ko�cu tekstu
;--- przekszta�cenie A
	push	OFFSET bufor
	call	ScanInt

;--- wyprowadzenie wyniku oblicze� ---
	push	EAX
	push	zmA
	push	OFFSET wynik
	push	OFFSET bufor
	call	wsprintfA	; zwraca liczb� znak�w w buforze 
	add	ESP, 12		; czyszczenie stosu
	mov	rinp, EAX	; zapami�tywanie liczby znak�w
;--- wy�wietlenie wyniku ---------
	push	0 		; rezerwa, musi by� zero
	push	OFFSET rout 	; wska�nik na faktyczn� liczb� wyprowadzonych znak�w 
	push	rinp		; liczba znak�w
	push	OFFSET bufor 	; wska�nik na tekst w buforze
 	push	hout		; deskryptor buforu konsoli
	call	WriteConsoleA	; wywo�anie funkcji WriteConsoleA

	push	0
	call	ExitProcess	
main endp


_TEXT	ENDS    

END