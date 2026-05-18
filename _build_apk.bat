@echo off
REM ============================================
REM SanalMahkeme - Build APK Script
REM APK: build/app/outputs/flutter-apk/app-release.apk
REM ============================================

cd /d "C:\BuildTemp\SanalMahkeme"

echo ============================================
echo    SanalMahkeme APK Build
echo ============================================
echo.

REM CLEAN
echo [1/4] Temizlik yapiliyor...
flutter clean
echo.

REM PUB GET
echo [2/4] Bagimliliklar yukleniyor...
flutter pub get
echo.

REM BUILD RELEASE APK
echo [3/4] Release APK olusturuluyor...
flutter build apk --release
echo.

REM COPY TO OUTPUT FOLDER
echo [4/4] APK kopyalaniyor...
if exist "build\app\outputs\flutter-apk\app-release.apk" (
    copy /Y "build\app\outputs\flutter-apk\app-release.apk" "C:\Users\pc\Desktop\SanalMahkeme.apk"
    echo.
    echo ============================================
    echo    APK HAZIR!
    echo    Konum: C:\Users\pc\Desktop\SanalMahkeme.apk
    echo ============================================
) else (
    echo HATA: APK bulunamadi!
)

echo.
pause