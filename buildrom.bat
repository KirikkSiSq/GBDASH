@echo off
if exist temp rmdir /s /q temp
if exist bin rmdir /s /q bin
call make clean
call make
if exist bin\MiJuego.gb (
    gbdk\bin\romusage.exe bin/MiJuego.gb
)
pause
