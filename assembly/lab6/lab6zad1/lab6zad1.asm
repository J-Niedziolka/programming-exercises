;Aplikacja z operacjami na plikach
.586P
.MODEL flat, STDCALL
;--- stale z pliku .\include\windows.inc ---
STD_INPUT_HANDLE                     equ -10
STD_OUTPUT_HANDLE                    equ -11
GENERIC_READ                         equ 80000000h
GENERIC_WRITE                        equ 40000000h
CREATE_NEW                           equ 1
CREATE_ALWAYS                        equ 2
OPEN_EXISTING                        equ 3
OPEN_ALWAYS                          equ 4
TRUNCATE_EXISTING                    equ 5
FILE_FLAG_WRITE_THROUGH              equ 80000000h
FILE_FLAG_OVERLAPPED                 equ 40000000h
FILE_FLAG_NO_BUFFERING               equ 20000000h
FILE_FLAG_RANDOM_ACCESS              equ 10000000h
FILE_FLAG_SEQUENTIAL_SCAN            equ 8000000h
FILE_FLAG_DELETE_ON_CLOSE            equ 4000000h
FILE_FLAG_BACKUP_SEMANTICS           equ 2000000h
FILE_FLAG_POSIX_SEMANTICS            equ 1000000h
FILE_ATTRIBUTE_READONLY              equ 1h
FILE_ATTRIBUTE_HIDDEN                equ 2h
FILE_ATTRIBUTE_SYSTEM                equ 4h
FILE_ATTRIBUTE_DIRECTORY             equ 10h
FILE_ATTRIBUTE_ARCHIVE               equ 20h
FILE_ATTRIBUTE_NORMAL                equ 80h
FILE_ATTRIBUTE_TEMPORARY             equ 100h
FILE_ATTRIBUTE_COMPRESSED            equ 800h
FORMAT_MESSAGE_ALLOCATE_BUFFER       equ 100h
FORMAT_MESSAGE_IGNORE_INSERTS        equ 200h
FORMAT_MESSAGE_FROM_STRING           equ 400h
FORMAT_MESSAGE_FROM_HMODULE          equ 800h
FORMAT_MESSAGE_FROM_SYSTEM           equ 1000h
FORMAT_MESSAGE_ARGUMENT_ARRAY        equ 2000h
FORMAT_MESSAGE_MAX_WIDTH_MASK        equ 0FFh
FILE_BEGIN							 equ 0h ;MoveMethod dla SetFilePointe
FILE_CURRENT                         equ 1h ;MoveMethod dla SetFilePointe
FILE_END                             equ 2h ;MoveMethod dla SetFilePointe

;--- funkcje API Win32 z pliku  .\include\user32.inc ---
CharToOemA PROTO :DWORD,:DWORD
;--- z pliku .\include\kernel32.inc ---
GetStdHandle PROTO :DWORD
ReadConsoleA PROTO :DWORD,:DWORD,:DWORD,:DWORD,:DWORD
WriteConsoleA PROTO :DWORD,:DWORD,:DWORD,:DWORD,:DWORD
ExitProcess PROTO :DWORD
wsprintfA PROTO C :VARARG     ;; int wsprintf(LPTSTR lpOut,// pointer to buffer for output 
                              ;; LPCTSTR lpFmt,// pointer to format-control string 
                              ;;    ...	// optional arguments  );
lstrlenA PROTO :DWORD
GetCurrentDirectoryA PROTO :DWORD,:DWORD  
      ;;nBufferLength, lpBuffer; zwraca length
CreateDirectoryA PROTO :DWORD,:DWORD      
      ;;lpPathName, lpSecurityAttributes; zwraca 0 jeœli b³ad
lstrcatA PROTO :DWORD,:DWORD              
      ;; lpString1, lpString2; zwraca lpString1
CreateFileA PROTO :DWORD,:DWORD,:DWORD,:DWORD,:DWORD,:DWORD,:DWORD 
      ;; LPCTSTR lpszName, DWORD fdwAccess, 
      ;; DWORD fdwShareMode, LPSECURITY_ATTRIBUTES lpsa, DWORD fdwCreate, 
      ;; DWORD fdwAttrsAndFlags, HANDLE hTemplateFile
lstrcpyA PROTO :DWORD,:DWORD  
      ;;LPTSTR lpString1 // address of buffer, LPCTSTR lpString2	// address of string to copy 
CloseHandle PROTO :DWORD      
      ;; BOOL CloseHandle(HANDLE hObject)
WriteFile PROTO :DWORD,:DWORD,:DWORD,:DWORD,:DWORD    
   ;; BOOL WriteFile(
   ;; HANDLE hFile,	// handle to file to write to
   ;; LPCVOID lpBuffer,	// pointer to data to write to file
   ;; DWORD nNumberOfBytesToWrite,	// number of bytes to write
   ;; LPDWORD lpNumberOfBytesWritten,	// pointer to number of bytes written
   ;; LPOVERLAPPED lpOverlapped 	// pointer to structure needed for overlapped I/O 
   ;;);
ReadFile PROTO :DWORD,:DWORD,:DWORD,:DWORD,:DWORD
    ;;BOOL ReadFile(
    ;;HANDLE hFile,	// handle of file to read 
    ;;LPVOID lpBuffer,	// address of buffer that receives data  
    ;;DWORD nNumberOfBytesToRead,	// number of bytes to read 
    ;;LPDWORD lpNumberOfBytesRead,	// address of number of bytes read 
    ;;LPOVERLAPPED lpOverlapped 	// address of structure for data 
    ;;);
CopyFileA PROTO :DWORD,:DWORD,:DWORD      
    ;; BOOL CopyFile(
    ;;LPCTSTR lpExistingFileName,	// pointer to name of an existing file 
    ;;LPCTSTR lpNewFileName,	// pointer to filename to copy to 
    ;;BOOL bFailIfExists 	// flag for operation if file exists  
    ;;);
GetLastError PROTO

GetTickCount PROTO
;--- z pliku ..\include\masm32.inc ---
nseed PROTO :DWORD
nrandom PROTO :DWORD


dwtoa PROTO dwValue:DWORD, lpBuffer:DWORD ;dwtoa convert a DWORD value to an ascii string.
;dwtoa proc dwValue:DWORD, lpBuffer:DWORD   
atodw  PROTO lpBuffer:DWORD ;atodw converts a decimal string to dword.
;atodw proc String:PTR BYTE
StripLF PROTO :DWORD ;StripLF is designed to remove the CRLF (ascii 13,10) by writing an ascii zero in the place of the first occurrence of ascii 13.
;StripLF proc strng:DWORD
StdIn PROTO :DWORD,:DWORD ;StdIn receives text input from the console and places it in the buffer required as a parameter. The function terminates when Enter is pressed.
;StdIn proc lpszBuffer:DWORD,bLen:DWORD
StdOut PROTO :DWORD ;StdOut will display a zero terminated string at the current position in the console.
;StdOut proc lpszText:DWORD
;--- funkcje
;------------s
;includelib .\lib\user32.lib
;includelib .\lib\kernel32.lib
;includelib .\lib\masm32.lib
;-------------
_DATA SEGMENT
    hout	DD	?
	hinp	DD	?
	naglow	DB	"Autor aplikacji .... Jan Niedzió³ka.",0
	ALIGN	4	; przesuniecie do adresu podzielnego na 4
	rozmN	DD	$ - naglow	;liczba znaków w tablicy
	zaprA	DB	0Dh,0Ah,"Podaj liczbê [+Enter]: ",0
	ALIGN	4
	rozmA	DD	$ - zaprA	;liczba znaków w tablicy
	zmA	DD	?	; argument A
	zakres DD 99;
	wylosowanaLiczba	DD	1	; argument A
	komunikatLiczba	DB	"%ld ",0  ;%ld oznacza formatowanie w formacie dziesiêtnym
	ALIGN	4
	rozmiarKomunikatLiczba	DD	$ - komunikatLiczba	;liczba znaków w tablicy
	rout	DD	0 ;faktyczna liczba wyprowadzonych znaków
	rinp	DD	0 ;faktyczna liczba wprowadzonych znaków

	bufor	DB	128 dup(?)
	rbuf	DD	128
	bufor2 DB 128 dup(?)
	rbuf2 DD 128
	bufor3 DB 128 dup(?)
	rbuf3 DD 128

    katalog   DB  "\Grupa2",0
	adreskat  DB  128 dup(?)
	adreskl   DD  128

    plikdat   DB  "\Niedzió³ka.dat",0
    adresdat  DB  128 dup(?)
    adresdl    DD  128

    pliktxt   DB  "\Niedzió³ka.txt",0
	adrestxt	DB	128 dup(?)
    adrestl    DD   128

    liczbaZapisanychBajtow  DD  128 dup(?)
    bytes_read  db  ?
_DATA ENDS
;------------
_TEXT SEGMENT
main proc
;--- wywo³anie funkcji GetStdHandle 
	push	STD_OUTPUT_HANDLE
	call	GetStdHandle	; wywo³anie funkcji GetStdHandle
	mov	hout, EAX	; deskryptor wyjœciowego bufora konsoli
	push	STD_INPUT_HANDLE
	call	GetStdHandle	; wywo³anie funkcji GetStdHandle
	mov	hinp, EAX	; deskryptor wejœciowego bufora konsoli
;--- nag³ówek ---------
	push	OFFSET naglow
	push	OFFSET naglow
	call	CharToOemA	; konwersja polskich znaków
;--- wyœwietlenie ---------
 	push	OFFSET naglow
	call lstrlenA
	mov rozmN,eax
	
	push	0		; rezerwa, musi byæ zero
	push	OFFSET rout	; wskaŸnik na faktyczn¹ liczba wyprowadzonych znaków 
	push	rozmN		; liczba znaków
	push	OFFSET naglow 	; wska¿nik na tekst
 	push	hout		; deskryptor buforu konsoli
	call	WriteConsoleA	; wywo³anie funkcji WriteConsoleA

;---BIE¯¥CY KATALOG-------------
	push OFFSET adresdat
	push adresdl
	call GetCurrentDirectoryA	;podaje bie¿¹cy katalog, zwraca œcie¿kê

	push OFFSET katalog
	push OFFSET adresdat
	call lstrcatA				;³¹czenie dwóch ³añcuchów(adres kopiowany, adres przeznaczenia)
	
	push 0
	push OFFSET adresdat
	call CreateDirectoryA		;tworzy katalog(nazwa nowego katalogu, dodatkowy atrybut 0)

	push OFFSET plikdat
	push OFFSET adresdat
	call lstrcatA				;³¹czenie dwóch ³añcuchów(adres kopiowany, adres przeznaczenia)

	push 0						;dod. atr.
	push 0						;dod. atr.
	push CREATE_ALWAYS			;kreacja nowego pliku/otwarcie istniej¹cego
	push 0						;
	push 0						;
	push GENERIC_WRITE OR GENERIC_READ		;tryb dostêpu, mo¿na po³¹czyæ oba
	push OFFSET adresdat					;adres nazwy pliku ze œcie¿k¹
	call CreateFileA				;otwarcie lub utworzenie pliku - f. zwraca uchwyt pliku
	mov ebx, eax

	mov ecx, 20					;przygotowanie pêtli do wylosowania 20 liczb

;--- wylosowanie liczby z zakresu 0-zakres ---
    call GetTickCount ;zwraca w czas w milisekundach od ostatniego uruchomienia systemu
	push eax ; 
	call nseed ; ustawienie wartoœci inicuj¹cej generator liczb pseudolosowych

	petla:
	push ecx

	push zakres
	call nrandom ;zwraca w eax liczbê z zakresu 0-zakres
	mov wylosowanaLiczba,EAX

	push EAX
	push OFFSET komunikatLiczba
	push OFFSET bufor
	call wsprintfA
	add  ESP, 12
	mov rinp, EAX

	push offset bufor
	call lstrlenA

	push 0
	push 0
	push EAX
	push offset bufor
	push ebx
	call WriteFile
	mov edx, eax

	pop ecx
	loop petla

	push EBX
	call CloseHandle

	push 0
	push 0
	push OPEN_EXISTING
	push 0
	push 0
	push GENERIC_READ
	push OFFSET adresdat
	call CreateFileA
	mov EBX, EAX

	read_file:
	push 0
	push offset bytes_read
	push 256
	push offset bufor2
	push ebx
	call ReadFile

	invoke StdOut, offset bufor2

	push ebx
	call CloseHandle

	push OFFSET adrestxt
	push adrestl
	call GetCurrentDirectoryA

	push OFFSET katalog
	push OFFSET adrestxt
	call lstrcatA

	push offset bufor
	call lstrlenA

	push 0
	push OFFSET adrestxt
	call CreateDirectoryA

	push OFFSET pliktxt
	push OFFSET adrestxt
	call lstrcatA

	push 0
	push 0
	push CREATE_ALWAYS
	push 0
	push 0
	push GENERIC_WRITE
	push OFFSET adrestxt
	call CreateFileA
	push EAX

	mov EDI, offset bufor2
	mov EBX, offset bufor3

	push offset bufor2
	call lstrlenA
	mov ECX, EAX

	przygotuj:
	mov AL, [EDI]
	cmp AL, 32
	jz spacja

	mov BYTE PTR [EBX], 44
	jmp koniec

	spacja:
	mov [EBX], AL

	koniec:
	inc EDI
	inc EBX

	loop przygotuj
	pop EBX
	push offset bufor3
	call lstrlenA

	push 0
	push 0
	push EAX
	push OFFSET bufor3
	push EBX
	call WriteFile
	mov EDX, EAX

	push 0
	call ExitProcess
main endp
ScanInt   PROC 
;; funkcja ScanInt przekszta³ca ci¹g cyfr do liczby, któr¹ jest zwracana przez EAX 
;; argument - zakoñczony zerem wiersz z cyframi 
;; rejestry: EBX - adres wiersza, EDX - znak liczby, ESI - indeks cyfry w wierszu, EDI - tymczasowy 
;--- pocz¹tek funkcji 
   push   EBP 
   mov   EBP, ESP   ; wskaŸnik stosu ESP przypisujemy do EBP 
;--- odk³adanie na stos 
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
   mov   ECX, EAX   ;liczba powtórzeñ = liczba znaków 
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
    push   EDX   ; do EDX procesor mo¿e zapisaæ wynik mno¿enia 
   mov   EDI, 10 
   mul   EDI      ;mno¿enie EAX * EDI 
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
   mov   ESP, EBP   ; przywracamy wskaŸnik stosu ESP
   pop   EBP 
   ret	4
ScanInt   ENDP 
  
_TEXT	ENDS
END

