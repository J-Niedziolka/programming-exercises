; ##########################################
  .586P
  .model flat, stdcall
  option casemap :none   ; case sensitive
;constants from fpu.inc
	SRC1_FPU    EQU   1
	SRC1_REAL   EQU   2
	SRC1_DMEM   EQU   4
	SRC1_DIMM   EQU   8
	SRC1_CONST  EQU   16

	ANG_DEG     EQU   0
	ANG_RAD     EQU   32

	DEST_MEM    EQU   0
	DEST_IMEM   EQU   64
	DEST_FPU    EQU   128

	SRC2_FPU    EQU   256
	SRC2_REAL   EQU   512
	SRC2_DMEM   EQU   1024
	SRC2_DIMM   EQU   2048
	SRC2_CONST  EQU   4096
; ##########################################
;prototypes from fpu.lib
	FpuAtoFL    PROTO :DWORD,:DWORD,:DWORD
	FpuFLtoA    PROTO :DWORD,:DWORD,:DWORD,:DWORD
;prototypes from masm32.lib
	StripLF      PROTO :DWORD
	StdIn        PROTO :DWORD,:DWORD
	StdOut       PROTO :DWORD
	CharToOemA   PROTO :DWORD, :DWORD
;others
	ExitProcess  PROTO :DWORD

	includelib masm32.lib
	includelib Fpu.lib
; ##########################################
.data
	x	REAL10	0.0
	y	REAL10  0.75
	z	REAL10  0.0
	wynik REAL10 0.0
	bufor        db    128 dup(0)
	rozmiarbufora dd 128
	komunikat1 db 'Podaj argument cosinusa x: ',0
	komunikat2 db '0.75 * x: ',0
	;komunikat3 db 'Podaj trzeci¹ liczbê: ',0
	;komunikatWynik db 'Liczba plus PI wynosi : ',0
	komunikatWynik db 'cos(0.75*x): ',0
.code

main proc
	invoke	CharToOemA,OFFSET komunikat1,OFFSET komunikat1
	invoke	StdOut,OFFSET komunikat1
	invoke StdIn, OFFSET bufor, rozmiarbufora
	invoke StripLF, OFFSET bufor
;konwresja bufora na typ REAL10 i zapis w zmiennnej x
    invoke FpuAtoFL, ADDR bufor, ADDR x, DEST_MEM
    fld x
	

	invoke StripLF, OFFSET bufor
	invoke FpuAtoFL, ADDR bufor, ADDR y, DEST_MEM
	fld y
	fmul st(0), st(1)
	invoke	CharToOemA,OFFSET komunikat2,OFFSET komunikat2
	invoke	StdOut,OFFSET komunikat2
	fcos
	fstp wynik
;kowersja wyninku na napis result z  6 cyframi po przecinku
	invoke	StdOut,OFFSET komunikatWynik
    invoke FpuFLtoA, ADDR wynik, 6, ADDR bufor, SRC1_REAL or SRC2_DIMM
    invoke StdOut,OFFSET bufor;
koniec:
    invoke ExitProcess, 0

main endp
END

