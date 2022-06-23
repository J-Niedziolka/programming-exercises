.386							//dyrektywa dla kompilatora jak ma zostać przetłumaczony ten kod
.MODEL flat, STDCALL					//

.code
main:
	mov eax, 10					//do rejestru EAX przypisujemy wartosc 10
	mov ax, 10					//itd
	mov al, 10
	mov eax, 10d
	mov ecx, 10h
	mov edx, 10o
	mov ebx, 10b

	add eax, ebx
	add ecx, edx
END