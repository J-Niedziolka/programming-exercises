.386
.MODEL flat, STDCALL
;---prototypy ---
ExitProcess PROTO :DWORD
;--- procedura w naszej bibliotece ----
PROC1 PROTO

_DATA SEGMENT
	
_DATA ENDS
;------------
_TEXT SEGMENT
main proc

	call PROC1

	push	0
	call	ExitProcess	
main endp
_TEXT	ENDS    

END

