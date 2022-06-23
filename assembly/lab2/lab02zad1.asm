;Aplikacja korzystająca z otwartego okna konsoli
.MODEL flat, STDCALL
;----------- stałe
STD_INPUT_HANDLE                     equ -10
STD_OUTPUT_HANDLE                    equ -11
;----------- koniec deklaracji stałych

;----------- prototypy metod
ExitProcess PROTO :DWORD
GetStdHandle PROTO :DWORD
CharToOemA	  PROTO :DWORD,:DWORD
WriteConsoleA PROTO :DWORD,:DWORD,:DWORD,:DWORD,:DWORD
ReadConsoleA PROTO :DWORD,:DWORD,:DWORD,:DWORD,:DWORD
lstrlenA PROTO :DWORD
wsprintfA PROTO C :VARARG
;----------- konieć prototypów metod

;------------- these are included by default in linker settings 
;includelib .\lib\user32.lib
;includelib .\lib\kernel32.lib
;-------------


;------------- początek segmentu danych w kótrym alokujemy miejsca w pamięci
.data
	printed			dword	0 ;bufor do przechowywania liczby wyświetlonych znaków
	inserted		dword	0 ;bufor do przechowywania liczby wprowadzonych znaków


	header			byte	"Autor: Kamil Skarżyński.",0
	sizeH			dword	$ - header

	introdution1	byte	0Dh,0Ah,"Wprowadź liczbę a",0
	sizeI1			dword	$ - introdution1

	introdution2	byte	0Dh,0Ah,"Wprowadź liczbę b",0
	sizeI2			dword	$ - introdution2

	function		byte	0Dh,0Ah,"Funkcja f(A,B) = A+B = %ld",0 
	sizeF			dword	$ - function

	varA			dword	0
	varB			dword	0

	cin				dword	?
	cout			dword	?

	bufor			byte	128 dup(?)
	rbuf			dword	128

;------------- koniec segmentu danych

;------------- początek segmentu kodu
.code
	main proc ;początek procedury głównej, której nazwe określiliśmy wcześniej w parametrach linkera
			
			;pobranie uchwytów do okna
			push STD_INPUT_HANDLE
			call GetStdHandle
			mov cin, eax 
	
			push STD_OUTPUT_HANDLE
			call GetStdHandle
			mov cout, eax 
			;konieć pobierania uchwytów

;----------- wyświetlanie informacji o autorze aplikacji
			push offset header
			push offset header
			call CharToOemA	

			push 0
			push offset printed
			push sizeH
			push offset header
			push cout
			call WriteConsoleA
;----------- koniec informacji o autorze aplikacji

;----------- wyświetlenie zaproszenia do wprowadzenia parametru A
			push offset introdution1
			push offset introdution1
			call CharToOemA	

			push 0
			push offset printed
			push sizeI1
			push offset introdution1
			push cout
			call WriteConsoleA
;----------- koniec wyświetlania zaproszenia

;----------- zczytanie parametru A z klawiatury 
			push	0 		; rezerwa, musi być zero
			push	OFFSET inserted 	; wskaźnik na faktyczną liczba wprowadzonych znaków 
			push	rbuf 		; rozmiar bufora
			push	OFFSET bufor ;wskażnik na bufor
 			push	cin		; deskryptor buforu konsoli
			call	ReadConsoleA	; wywołanie funkcji ReadConsoleA
			lea   EBX,bufor
			mov   EDI,inserted
			mov   BYTE PTR [EBX+EDI-2],0 ;zero na końcu tekstu
		;--- przekształcenie A
			push	OFFSET bufor
			call	ScanInt
			mov	varA, EAX
;----------- koniec zczytywania parametru A z klawiatury

;----------- wyświetlenie zaproszenia do wprowadzenia parametru B
			push offset introdution2
			push offset introdution2
			call CharToOemA	

			push 0
			push offset printed
			push sizeI2
			push offset introdution2
			push cout
			call WriteConsoleA
;----------- koniec wyświetlania zaproszenia

;----------- zczytanie parametru B z klawiatury 
			push	0 		; rezerwa, musi być zero
			push	OFFSET inserted 	; wskaźnik na faktyczną liczba wprowadzonych znaków 
			push	rbuf 		; rozmiar bufora
			push	OFFSET bufor ;wskażnik na bufor
 			push	cin		; deskryptor buforu konsoli
			call	ReadConsoleA	; wywołanie funkcji ReadConsoleA
			lea   EBX,bufor
			mov   EDI,inserted
			mov   BYTE PTR [EBX+EDI-2],0 ;zero na końcu tekstu
		;--- przekształcenie A
			push	OFFSET bufor
			call	ScanInt
			mov	varB, EAX
;----------- koniec zczytywania parametru B z klawiatury






;----------- Łączenie stringów
			push	EAX
			push	OFFSET function
			push	OFFSET bufor
			call	wsprintfA	; zwraca liczbę znaków w buforze 
			add	ESP, 12		; czyszczenie stosu, czemu?
			mov	inserted, EAX	; zapamiętywanie liczby znaków
;----------- koniec łączenia stringów

;----------- wyświetlenie wyniku 
	push	0 		; rezerwa, musi być zero
	push	OFFSET printed 	; wskaźnik na faktyczną liczbę wyprowadzonych znaków 
	push	inserted		; liczba znaków
	push	OFFSET bufor 	; wskaźnik na tekst w buforze
 	push	cout		; deskryptor buforu konsoli
	call	WriteConsoleA	; wywołanie funkcji WriteConsoleA
;----------- koniec wyświetlenia wyniku 



			push 0
			call ExitProcess

	main endp ;koniec procedury głównej

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

END