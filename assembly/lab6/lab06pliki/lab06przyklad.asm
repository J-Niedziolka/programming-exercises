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

;include \masm32\include\masm32rt.inc


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
;------------
;includelib .\lib\user32.lib
;includelib .\lib\kernel32.lib
;includelib .\lib\masm32.lib
;-------------
_DATA SEGMENT
bufor db 128 dup (0)
rbuf dd $-bufor
wylosowanaLiczba dd ?
hout dd ?
hinp dd ?
liczbaZnakow dd ?
rout  dd ?
rinp  dd ?
zakres dd 100
CRLF db 13,10,0
komunikat1 db 'Liczba wylosowana: ',0
komunikat2 db 'Podaj liczbê: ',0
komunikat3 db 'Suma liczb wynosi: ',0
_DATA ENDS
;------------
_TEXT SEGMENT
main proc
	invoke GetTickCount ;zwraca w czas w milisekundach od ostatniego uruchomienia systemu
	invoke nseed,EAX; ustawienie wartoœci inicuj¹cej generator liczb pseudolosowych
	
	invoke nrandom,zakres ;zwraca w eax liczbê z zakresu 0-zakres
	mov wylosowanaLiczba,EAX
	
	invoke dwtoa, EAX, offset bufor;konwersja liczby na ciag znakow
	mov liczbaZnakow, EAX
	
	invoke	StdOut,OFFSET komunikat1
	invoke	StdOut,OFFSET bufor; wyœwietlenie napisu zakoñczonego 0 
	invoke	StdOut,OFFSET CRLF; wyœwietlenie napisu zakoñczonego 0 
    
	invoke	CharToOemA,OFFSET komunikat2,OFFSET komunikat2
	invoke	StdOut,OFFSET komunikat2
	;przyk³ad u¿ycia atodw do wczytania liczby z klawiatury do bufora a nastêpnie do eax 
	invoke StdIn, OFFSET bufor, rbuf
	invoke StripLF, OFFSET bufor
	invoke atodw, offset bufor ; wynik w eax
	
	;dodajemy pobran¹ liczbê do liczby wylosowanej
	add EAX,wylosowanaLiczba
	
	invoke dwtoa, EAX, offset bufor;konwersja liczby na ciag znakow
	
	invoke	StdOut,OFFSET komunikat3
	invoke	StdOut,OFFSET bufor; wyœwietlenie napisu zakoñczonego 0 

    invoke ExitProcess, 0

main endp
_TEXT	ENDS
END

