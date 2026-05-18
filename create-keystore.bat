@echo off
echo ============================================
echo   Hakli Kim? - Keystore Olusturma
echo ============================================
echo.

set KEYSTORE_PATH=android\app\upload-keystore.jks
set KEY_ALIAS=upload
set STORE_PASS=HakliKim2026!
set KEY_PASS=HakliKim2026!
set VALIDITY=10000
set DNAME="CN=CloudExE, OU=Mobile, O=CloudExE, L=Istanbul, S=Istanbul, C=TR"

if exist "%KEYSTORE_PATH%" (
    echo [!] Keystore zaten mevcut: %KEYSTORE_PATH%
    echo [!] Silmek isterseniz: del %KEYSTORE_PATH%
    exit /b 0
)

echo [+] Keystore olusturuluyor...
keytool -genkey -v ^
    -keystore "%KEYSTORE_PATH%" ^
    -alias "%KEY_ALIAS%" ^
    -keyalg RSA ^
    -keysize 2048 ^
    -validity %VALIDITY% ^
    -storepass "%STORE_PASS%" ^
    -keypass "%KEY_PASS%" ^
    -dname %DNAME%

if %errorlevel% equ 0 (
    echo.
    echo [OK] Keystore basariyla olusturuldu: %KEYSTORE_PATH%
    echo [OK] Gecerlilik: %VALIDITY% gun (~27 yil)
    echo [OK] Firma: CloudExE
    echo.
    echo ONEMLI: Bu dosyayi ASLA kaybetmeyin!
    echo Google Play Console'a yuklemek icin bu keystore gerekli.
) else (
    echo.
    echo [HATA] Keystore olusturulamadi!
    echo Java JDK yuklu oldugundan emin olun.
)
pause
