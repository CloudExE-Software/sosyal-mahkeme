@echo off
cd /d "C:\BuildTemp\SanalMahkeme"
del /f /q _push.bat
git add -A
git commit -m "Cleanup: remove temp push script"
git push
echo.
echo TEMIZLENDI!
pause
