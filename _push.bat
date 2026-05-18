@echo off
cd /d "C:\BuildTemp\SanalMahkeme"
git add -A
git commit -m "Remove premium, add pre+post analysis ads, fix jury count to 11"
git push
echo.
echo TAMAMLANDI!
pause
