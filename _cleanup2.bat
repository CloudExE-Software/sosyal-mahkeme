@echo off
cd /d "C:\BuildTemp\SanalMahkeme"
git add -A
git commit -m "Cleanup: remove temp deploy scripts"
git push
echo.
echo Token temizlendi, gecici dosyalar silindi.
pause
