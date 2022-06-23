@echo off
if exist %1.obj del %1.obj
if exist %1.exe del %1.exe
@echo %1
.\bin\ml /c /coff %1.asm