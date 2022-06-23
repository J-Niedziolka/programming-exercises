.386
.MODEL FLAT,STDCALL

PUBLIC IncrementNumber
PUBLIC FillSpacebar

.code
	IncrementNumber PROC zm1:DWORD, zm2:DWORD, zm3:DWORD
		mov EAX, zm1
		add EAX, zm1
		sub EAX, zm2
		sub EAX, zm3
		ret

	IncrementNumber ENDP

	FillSpacebar PROC buffor:DWORD 
		mov EBX, buffor
		mov ECX, 1000h
		petla:
			mov byte ptr [EBX], 20h
		loop petla
		ret
	FillSpacebar ENDP

END