;Aplikacja korzystająca z otwartego okna konsoli
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
;-------------
;includelib .\lib\user32.lib
;includelib .\lib\kernel32.lib
;-------------
_DATA SEGMENT
	hout	DD	?
	hinp	DD	?
	naglow	DB	"Autor aplikacji .... Jan Masztalski.",0
	ALIGN	4	; przesuniecie do adresu podzielnego na 4
	rozmN	DD	$ - naglow	;liczba znaków w tablicy
	zaprA	DB	0Dh,0Ah,"Proszę wprowadzić argument A [+Enter]: ",0
	ALIGN	4
	rozmA	DD	$ - zaprA	;liczba znaków w tablicy
	zmA	DD	1	; argument A
	zaprB	DB	0Dh,0Ah,"Proszę wprowadzić argument B [+Enter]: ",0
	ALIGN	4
	rozmB	DD	$ - zaprB	;liczba znaków w tablicy
	zmB	DD	2	; argument B
	zaprC	DB	0Dh,0Ah,"Proszę wprowadzić argument C [+Enter]: ",0
	ALIGN	4
	rozmC	DD	$ - zaprC	;liczba znaków w tablicy
	zmC	DD	3	; argument C
	zaprD	DB	0Dh,0Ah,"Proszę wprowadzić argument D [+Enter]: ",0
	ALIGN	4
	rozmD	DD	$ - zaprD	;liczba znaków w tablicy
	zmD	DD	4	; argument D
	wzor	DB	0Dh,0Ah,"Funkcja f(A,B,C,D) = ...... = %ld",0  ;%ld oznacza formatowanie w formacie dziesiętnym
	ALIGN	4
	rozmW	DD	$ - wzor	;liczba znaków w tablicy
	rout	DD	0 ;faktyczna liczba wyprowadzonych znaków
	rinp	DD	0 ;faktyczna liczba wprowadzonych znaków
	bufor	DB	128 dup(?)
	rbuf	DD	128
_DATA ENDS
;------------
_TEXT SEGMENT
main PROC
;--- wywołanie funkcji GetStdHandle 
	push	STD_OUTPUT_HANDLE
	call	GetStdHandle	; wywołanie funkcji GetStdHandle
	mov	hout, EAX	; deskryptor wyjściowego bufora konsoli
	push	STD_INPUT_HANDLE
	call	GetStdHandle	; wywołanie funkcji GetStdHandle
	mov	hinp, EAX	; deskryptor wejściowego bufora konsoli
;--- nagłówek ---------
	push	OFFSET naglow
	push	OFFSET naglow
	call	CharToOemA	; konwersja polskich znaków
;--- wyświetlenie ---------
	push	0		; rezerwa, musi być zero
	push	OFFSET rout	; wskaźnik na faktyczną liczba wyprowadzonych znaków 
	push	rozmN		; liczba znaków
	push	OFFSET naglow 	; wskażnik na tekst
 	push	hout		; deskryptor buforu konsoli
	call	WriteConsoleA	; wywołanie funkcji WriteConsoleA
;--- zaproszenie A ---------
	push	OFFSET zaprA
	push	OFFSET zaprA
	call	CharToOemA	; konwersja polskich znaków
;--- wyświetlenie zaproszenia A ---
	push	0		; rezerwa, musi być zero
	push	OFFSET rout 	; wskaźnik na faktyczną liczba wyprowadzonych znaków 
	push	rozmA		; liczba znaków
	push	OFFSET zaprA 	; wskażnik na tekst
 	push	hout		; deskryptor buforu konsoli
	call	WriteConsoleA	; wywołanie funkcji WriteConsoleA   
;--- czekanie na wprowadzenie znaków, koniec przez Enter ---
	push	0 		; rezerwa, musi być zero
	push	OFFSET rinp 	; wskaźnik na faktyczną liczba wprowadzonych znaków 
	push	rbuf 		; rozmiar bufora
	push	OFFSET bufor ;wskażnik na bufor
 	push	hinp		; deskryptor buforu konsoli
	call	ReadConsoleA	; wywołanie funkcji ReadConsoleA
	lea   EBX,bufor
	mov   EDI,rinp
	mov   BYTE PTR [EBX+EDI-2],0 ;zero na końcu tekstu
;--- przekształcenie A
	push	OFFSET bufor
	call	ScanInt
	mov	zmA, EAX

;;;........ B, C, D ......................

;--- obliczenia ---
	mov	EAX, zmA
;;;;	................
;--- wyprowadzenie wyniku obliczeń ---
	push	EAX
	push	OFFSET wzor
	push	OFFSET bufor
	call	wsprintfA	; zwraca liczbę znaków w buforze 
	add	ESP, 12		; czyszczenie stosu
	mov	rinp, EAX	; zapamiętywanie liczby znaków
;--- wyświetlenie wyniku ---------
	push	0 		; rezerwa, musi być zero
	push	OFFSET rout 	; wskaźnik na faktyczną liczbę wyprowadzonych znaków 
	push	rinp		; liczba znaków
	push	OFFSET bufor 	; wskaźnik na tekst w buforze
 	push	hout		; deskryptor buforu konsoli
	call	WriteConsoleA	; wywołanie funkcji WriteConsoleA
;--- zakończenie procesu ---------
	push	0
	call	ExitProcess	; wywołanie funkcji ExitProcess

main endp
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
ScanInt   PROC 
;; funkcja ScanInt przekształca ciąg cyfr do liczby, którą jest zwracana przez EAX 
;; argument - zakończony zerem wiersz z cyframi 
;; rejestry: EBX - adres wiersza, EDX - znak liczby, ESI - indeks cyfry w wierszu, EDI - tymczasowy 
;--- początek funkcji 
   push   EBP 
   mov   EBP, ESP   ; wskaźnik stosu ESP przypisujemy do EBP 
;--- odkładanie na stos 
   push   EBX 
   push   ECX 
   push   EDX 
   push   ESI 
   push   EDI 
;--- przygotowywanie cyklu 
   mov   EBX, [EBP+8] 
   push   EBX 
   call   lstrlenA 
   mov   EDI, EAX   ;liczba znaków 
   mov   ECX, EAX   ;liczba powtórzeń = liczba znaków 
   xor   ESI, ESI   ; wyzerowanie ESI 
   xor   EDX, EDX   ; wyzerowanie EDX 
   xor   EAX, EAX   ; wyzerowanie EAX 
   mov   EBX, [EBP+8] ; adres tekstu
;--- cykl -------------------------- 
pocz: 
   cmp   BYTE PTR [EBX+ESI], 0h   ;porównanie z kodem \0 
   jne   @F 
   jmp   et4 
@@: 
   cmp   BYTE PTR [EBX+ESI], 0Dh   ;porównanie z kodem CR 
   jne   @F 
   jmp   et4 
@@: 
   cmp   BYTE PTR [EBX+ESI], 0Ah   ;porównanie z kodem LF 
   jne   @F 
   jmp   et4 
@@: 
   cmp   BYTE PTR [EBX+ESI], 02Dh   ;porównanie z kodem - 
   jne   @F 
   mov   EDX, 1 
   jmp   nast 
@@: 
   cmp   BYTE PTR [EBX+ESI], 030h   ;porównanie z kodem 0 
   jae   @F 
   jmp   nast 
@@: 
   cmp   BYTE PTR [EBX+ESI], 039h   ;porównanie z kodem 9 
   jbe   @F 
   jmp   nast 
;---- 
@@:    
    push   EDX   ; do EDX procesor może zapisać wynik mnożenia 
   mov   EDI, 10 
   mul   EDI      ;mnożenie EAX * EDI 
   mov   EDI, EAX   ; tymczasowo z EAX do EDI 
   xor   EAX, EAX   ;zerowani EAX 
   mov   AL, BYTE PTR [EBX+ESI] 
   sub   AL, 030h   ; korekta: cyfra = kod znaku - kod 0    
   add   EAX, EDI   ; dodanie cyfry 
   pop   EDX 
nast:   
    inc   ESI 
   loop   pocz 
;--- wynik 
   or   EDX, EDX   ;analiza znacznika EDX 
   jz   @F 
   neg   EAX 
@@:    
et4:;--- zdejmowanie ze stosu 
   pop   EDI 
   pop   ESI 
   pop   EDX 
   pop   ECX 
   pop   EBX 
;--- powrót 
   mov   ESP, EBP   ; przywracamy wskaźnik stosu ESP
   pop   EBP 
   ret	4
ScanInt   ENDP 
_TEXT	ENDS    

END 

