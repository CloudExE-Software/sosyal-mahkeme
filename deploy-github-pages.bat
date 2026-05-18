@echo off
echo ============================================
echo   Sosyal Mahkeme - GitHub Pages Deploy
echo ============================================
echo.

cd /d "%~dp0"

echo [1/6] Git repo kontrol ediliyor...
if not exist ".git" (
    echo Git repo yok, olusturuluyor...
    git init
    echo.
)

echo [2/6] Git config ayarlaniyor...
git config user.name "CloudExe-Software"
git config user.email "destek@sosyalmahkeme.com"
echo.

echo [3/6] Dosyalar hazirlaniyor...
git add docs/
echo.

echo [4/6] Commit olusturuluyor...
git commit -m "GitHub Pages: Legal docs + landing page" || (
    echo Ilk commit yapiliyor...
    git add .
    git commit -m "Initial commit: GitHub Pages legal docs + landing page"
)
echo.

echo [5/6] GitHub'a push ediliyor...
echo.
echo ONEMLI: Asagidaki komutlari sirayla calistirin:
echo.
echo   1. Remote ekleyin (ilk kez):
echo      git remote add origin https://github.com/CloudExe-Software/sosyal-mahkeme.git
echo.
echo   2. GitHub'da repo olusturun:
echo      https://github.com/new
echo      Repo adi: sosyal-mahkeme
echo      Public olsun!
echo.
echo   3. Push yapin:
echo      git branch -M main
echo      git push -u origin main
echo.

echo [6/6] GitHub Pages aktif edin:
echo   - GitHub repo ^> Settings ^> Pages
echo   - Source: Deploy from a branch
echo   - Branch: main / folder: /docs
echo   - Save
echo.
echo ============================================
echo   LINKLER (aktif oldugunda):
echo   Ana Sayfa: https://CloudExe-Software.github.io/sosyal-mahkeme/
echo   Gizlilik:  https://CloudExe-Software.github.io/sosyal-mahkeme/privacy-policy.html
echo   Sartlar:   https://CloudExe-Software.github.io/sosyal-mahkeme/terms-of-service.html
echo ============================================
pause
