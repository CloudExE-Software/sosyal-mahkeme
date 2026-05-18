# 📖 Haklı Kim? - Detaylı Kurulum Rehberi

Bu rehber, uygulamayı sıfırdan kurmak ve yayınlamak için adım adım talimatlar içerir.

## 📋 İçindekiler

1. [Geliştirme Ortamı Hazırlığı](#geliştirme-ortamı-hazırlığı)
2. [API Anahtarlarını Alma](#api-anahtarlarını-alma)
3. [Proje Yapılandırması](#proje-yapılandırması)
4. [Test Etme](#test-etme)
5. [Production Build](#production-build)
6. [Mağazalara Yükleme](#mağazalara-yükleme)

---

## 🛠️ Geliştirme Ortamı Hazırlığı

### Flutter SDK Kurulumu

1. [Flutter SDK](https://flutter.dev/docs/get-started/install) indirin
2. PATH'e ekleyin
3. Kurulumu doğrulayın:

```bash
flutter doctor
```

Tüm ✓ işaretlerini görmelisiniz (iOS kısmı sadece Mac için).

### IDE Kurulumu

**VS Code (Önerilen)**
- Flutter extension yükleyin
- Dart extension yükleyin

**Android Studio**
- Flutter plugin yükleyin
- Dart plugin yükleyin

---

## 🔑 API Anahtarlarını Alma

### 1. OpenAI API Key (ZORUNLU)

Uygulama çalışması için **mutlaka** gereklidir.

**Adımlar:**

1. [OpenAI Platform](https://platform.openai.com/) sayfasına gidin
2. Hesap oluşturun (veya giriş yapın)
3. Billing sayfasından kredi kartı ekleyin
   - İlk 5$ ücretsiz kullanım verilir
   - GPT-4o-mini çok ucuzdur (~$0.15 / 1000 istek)
4. [API Keys](https://platform.openai.com/api-keys) sayfasına gidin
5. "Create new secret key" butonuna tıklayın
6. Anahtar adı verin (örn: "Hakli Kim App")
7. Anahtarı kopyalayın (bir daha gösterilmeyecek!)

**Anahtarı Projeye Ekle:**

`lib/utils/constants.dart` dosyasını açın:

```dart
static const String openAIApiKey = 'sk-proj-xxxxxxxxxxxxxxxxx';
```

⚠️ **Güvenlik Uyarısı:** Bu dosyayı GitHub'a yüklemeyin! `.gitignore` dosyasına ekleyin.

---

### 2. Google AdMob (OPSIYONEL)

Reklam geliri için gereklidir.

**Adımlar:**

1. [Google AdMob Console](https://apps.admob.com/) gidin
2. Google hesabıyla giriş yapın
3. "Apps" menüsünden "Add App" tıklayın
4. Platform seçin (Android/iOS)
5. Uygulama bilgilerini girin:
   - App name: Haklı Kim?
   - Platform: Android/iOS
   - App store presence: No (henüz mağazada değil)
6. App ID'yi kopyalayın (örn: `ca-app-pub-1234567890123456~1234567890`)

**Android Kurulum:**

`android/app/src/main/AndroidManifest.xml` dosyasını açın:

```xml
<meta-data
    android:name="com.google.android.gms.ads.APPLICATION_ID"
    android:value="ca-app-pub-1234567890123456~1234567890"/>
```

**iOS Kurulum:**

`ios/Runner/Info.plist` dosyasını açın:

```xml
<key>GADApplicationIdentifier</key>
<string>ca-app-pub-1234567890123456~1234567890</string>
```

**Reklam Birimleri Oluştur:**

AdMob Console'da:
- Banner Ad Unit oluştur
- Interstitial Ad Unit oluştur
- Rewarded Ad Unit oluştur

ID'leri `lib/utils/constants.dart` dosyasına ekle:

```dart
static const String adMobBannerId = 'ca-app-pub-xxx/xxx';
static const String adMobInterstitialId = 'ca-app-pub-xxx/xxx';
static const String adMobRewardedId = 'ca-app-pub-xxx/xxx';
```

---

## ⚙️ Proje Yapılandırması

### Uygulama Adını Değiştir

**Android:**

`android/app/src/main/AndroidManifest.xml`:
```xml
<application
    android:label="Haklı Kim?"
```

**iOS:**

`ios/Runner/Info.plist`:
```xml
<key>CFBundleDisplayName</key>
<string>Haklı Kim?</string>
```

### Uygulama İkonunu Değiştir

1. 512x512 PNG ikon hazırlayın
2. [App Icon Generator](https://appicon.co/) kullanın
3. Çıktıları `android/app/src/main/res/` ve `ios/Runner/Assets.xcassets/` klasörlerine kopyalayın

### Paket Adını Değiştir (Opsiyonel)

Önerilen format: `com.yourcompany.haklikim`

```bash
flutter pub global activate rename
flutter pub global run rename --bundleId com.yourcompany.haklikim
```

---

## 🧪 Test Etme

### Emülatör/Simülatör Test

```bash
# Android emulator başlat
flutter emulators --launch <emulator_id>

# Uygulamayı çalıştır
flutter run
```

### Fiziksel Cihaz Test

**Android:**
1. USB Debugging'i aç (Geliştirici Seçenekleri)
2. Cihazı USB ile bağla
3. `flutter devices` ile cihazı kontrol et
4. `flutter run` ile çalıştır

**iOS:**
1. Mac gerekli
2. Xcode ile cihaza provisioning profile ekle
3. `flutter run -d <device_id>`

### Test Senaryoları

- ✅ OCR ile görüntüden metin okuma
- ✅ Manuel metin girişi
- ✅ Farklı jüri tiplerini seçme
- ✅ AI analiz sonucu görüntüleme
- ✅ Kararı paylaşma
- ✅ Reklam gösterimi
- ✅ Premium jüri kilidi (rewarded ad)

---

## 📦 Production Build

### Android APK

```bash
flutter build apk --release
```

Çıktı: `build/app/outputs/flutter-apk/app-release.apk`

### Android App Bundle (Google Play için önerilen)

```bash
flutter build appbundle --release
```

Çıktı: `build/app/outputs/bundle/release/app-release.aab`

### İmzalama (Android)

**Keystore Oluştur:**

```bash
keytool -genkey -v -keystore ~/haklikim-key.jks -keyalg RSA -keysize 2048 -validity 10000 -alias haklikim
```

**key.properties Oluştur:**

`android/key.properties`:

```properties
storePassword=<password>
keyPassword=<password>
keyAlias=haklikim
storeFile=/Users/yourname/haklikim-key.jks
```

**build.gradle Güncelle:**

`android/app/build.gradle.kts`:

```kotlin
// key.properties'i oku
val keystorePropertiesFile = rootProject.file("key.properties")
val keystoreProperties = Properties()
keystoreProperties.load(FileInputStream(keystorePropertiesFile))

android {
    ...
    signingConfigs {
        create("release") {
            storeFile = file(keystoreProperties["storeFile"] as String)
            storePassword = keystoreProperties["storePassword"] as String
            keyAlias = keystoreProperties["keyAlias"] as String
            keyPassword = keystoreProperties["keyPassword"] as String
        }
    }
    buildTypes {
        getByName("release") {
            signingConfig = signingConfigs.getByName("release")
        }
    }
}
```

### iOS Build

```bash
flutter build ios --release
```

Xcode'da:
1. Runner.xcworkspace'i aç
2. Product > Archive
3. Distribute App

---

## 🏪 Mağazalara Yükleme

### Google Play Store

1. [Google Play Console](https://play.google.com/console/) gidin
2. "Create app" ile yeni uygulama oluştur
3. App details doldurun:
   - Name: Haklı Kim?
   - Category: Entertainment
   - Content rating: Teen
4. Store listing hazırla:
   - Screenshots (en az 2, önerilen 8)
   - Feature graphic (1024x500)
   - Description (4000 karakter)
   - Short description (80 karakter)
5. Content rating anketi doldur
6. Privacy policy linki ekle
7. Production track'e AAB yükle
8. Review için gönder

**Bekleme Süresi:** 1-3 gün

### Apple App Store

1. [App Store Connect](https://appstoreconnect.apple.com/) gidin
2. Apple Developer Program üyeliği gerekli ($99/yıl)
3. "My Apps" > "+" > "New App"
4. App Information:
   - Name: Haklı Kim?
   - Primary Language: Turkish
   - Bundle ID: com.yourcompany.haklikim
   - SKU: unique identifier
5. Pricing: Free
6. App Privacy bilgileri doldur
7. Screenshots yükle (5.5", 6.5" ekranlar için)
8. Xcode'dan Archive edip Upload
9. Review için gönder

**Bekleme Süresi:** 1-7 gün

---

## 🚀 Yayın Sonrası

### Analytics Kurulumu

**Firebase Analytics (Önerilen):**

1. [Firebase Console](https://console.firebase.google.com/) gidin
2. Proje oluştur
3. Android/iOS app ekle
4. `google-services.json` / `GoogleService-Info.plist` indir
5. Flutter projesi `firebase_core` ve `firebase_analytics` paketi ekle

### Crash Reporting

**Firebase Crashlytics:**

```bash
flutter pub add firebase_crashlytics
```

### Remote Config (API Key Güvenliği)

API anahtarlarını Firebase Remote Config'de saklayın:

```dart
final remoteConfig = FirebaseRemoteConfig.instance;
await remoteConfig.fetchAndActivate();
final apiKey = remoteConfig.getString('openai_api_key');
```

---

## 🎯 Pazarlama ve Tanıtım

### ASO (App Store Optimization)

- **Keywords:** hakli kim, tartisma analizi, sanal mahkeme, ai yargic
- **Title:** Haklı Kim? - AI Sanal Mahkeme
- **Subtitle:** Tartışmayı AI Analiz Etsin
- **Description:** Viral potansiyel vurgusu

### Sosyal Medya Stratejisi

1. **Twitter/X:** Viral kararlar paylaş
2. **TikTok:** #HaklıKim akımı başlat
3. **Instagram:** Story formatında örnekler
4. **Reddit:** r/Turkey'de organik paylaşım

### PR ve Haber

- webrazzi.com
- shiftdelete.net
- teknoblog.com

---

## 📞 Destek

Herhangi bir sorun yaşarsanız:

- 📧 Email: destek@haklikim.com
- 💬 GitHub Issues: [Issues sayfası](https://github.com/...)
- 📱 Twitter: @haklikim

---

**İyi şanslar! 🚀**
