@echo off
if exist %1.obj del %1.obj
@echo %1
.\bin\ml /c /coff /Cp /Cx /Fo%1.obj /Fl%1.lst /Zi /Zd %1.asm