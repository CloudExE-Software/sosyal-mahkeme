# 🏛️ Haklı Kim? - Sanal Mahkeme Uygulaması

[![Flutter](https://img.shields.io/badge/Flutter-3.10+-blue.svg)](https://flutter.dev/)
[![License](https://img.shields.io/badge/License-MIT-green.svg)](LICENSE)

**Haklı Kim?** yapay zeka destekli, eğlenceli bir sanal mahkeme uygulamasıdır. WhatsApp konuşmalarınızı, tartışmalarınızı analiz edip kimin haklı olduğuna AI ile karar verir!

## ✨ Özellikler

- 📸 **OCR ile Metin Çıkarma**: WhatsApp/Instagram konuşma görsellerinden otomatik metin okuma
- 🤖 **GPT-4o AI Analizi**: OpenAI ile güçlü tartışma analizi
- 👨‍⚖️ **5 Farklı Jüri Tipi**: 
  - Ağır Ceza Reisi (Ciddi, hukuki)
  - Mahalle Muhtarı (Babacan, akılcı)
  - Acımasız Komedyen (Eğlenceli, viral)
  - Toksik İlişki Koçu (Psikolojik analiz)
  - Dertli Baba (Duygusal, şiirsel) [PREMIUM]
- 📜 **Resmi Sertifika**: Paylaşılabilir mahkeme kararı belgesi
- 💰 **AdMob Entegrasyonu**: Banner, Interstitial, Rewarded reklamlar
- 📱 **Cross-Platform**: Android ve iOS desteği

## 🚀 Kurulum ve Çalıştırma

### Gereksinimler

- Flutter SDK 3.10+
- Dart 3.0+
- Android Studio / Xcode
- OpenAI API Key
- Google AdMob Hesabı (opsiyonel)

### Adım 1: Projeyi Klonlayın

```bash
git clone <repository-url>
cd "Sanal Mahkeme Haklı Kim"
```

### Adım 2: Bağımlılıkları Yükleyin

```bash
flutter pub get
```

### Adım 3: API Anahtarlarını Ekleyin

`lib/utils/constants.dart` dosyasını açın ve API anahtarlarınızı girin:

```dart
// OpenAI API Key
static const String openAIApiKey = 'sk-proj-...'; // OpenAI API anahtarınız

// AdMob App IDs
static const String adMobAppIdAndroid = 'ca-app-pub-XXXXX~XXXXX';
static const String adMobAppIdIOS = 'ca-app-pub-XXXXX~XXXXX';
```

#### OpenAI API Key Alma

1. [OpenAI Platform](https://platform.openai.com/) hesabı oluşturun
2. [API Keys](https://platform.openai.com/api-keys) sayfasına gidin
3. "Create new secret key" ile yeni anahtar oluşturun
4. Anahtarı kopyalayıp `constants.dart` dosyasına yapıştırın

#### AdMob Kurulumu (Opsiyonel)

1. [Google AdMob Console](https://apps.admob.com/) hesabı oluşturun
2. Yeni uygulama ekleyin
3. App ID'leri kopyalayıp aşağıdaki dosyalara yapıştırın:

**Android**: `android/app/src/main/AndroidManifest.xml`
```xml
<meta-data
    android:name="com.google.android.gms.ads.APPLICATION_ID"
    android:value="ca-app-pub-XXXXX~XXXXX"/>
```

**iOS**: `ios/Runner/Info.plist`
```xml
<key>GADApplicationIdentifier</key>
<string>ca-app-pub-XXXXX~XXXXX</string>
```

### Adım 4: Uygulamayı Çalıştırın

```bash
# Android
flutter run

# iOS (Mac gerekli)
flutter run -d ios

# Release mode
flutter run --release

- [Lab: Write your first Flutter app](https://docs.flutter.dev/get-started/codelab)
- [Cookbook: Useful Flutter samples](https://docs.flutter.dev/cookbook)

For help getting started with Flutter development, view the
[online documentation](https://docs.flutter.dev/), which offers tutorials,
samples, guidance on mobile development, and a full API reference.
