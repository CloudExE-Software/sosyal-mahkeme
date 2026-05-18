# 🔐 API Keys Yapılandırma Şablonu

Bu dosya API anahtarlarınızı güvenli şekilde saklamak için bir şablondur.

## 📝 Talimatlar

1. `lib/utils/api_keys_template.dart` dosyasını `lib/utils/api_keys.dart` olarak kopyalayın
2. `api_keys.dart` dosyasını düzenleyin ve anahtarlarınızı girin
3. `api_keys.dart` zaten `.gitignore`'da — GitHub'a yüklenmez ✅

---

## 🤖 Gemini API Key (ANA — Ücretsiz)

**Nereden Alınır:** https://aistudio.google.com/apikey

```
API Key: AIzaSy...
```

**Kullanım:**
`lib/utils/api_keys.dart` dosyasında:
```dart
static const String geminiApiKey = 'AIzaSy...';
```

**Maliyet:** Ücretsiz (15 istek/dakika, 1.5M token/gün)

---

## 🤖 OpenAI API Key (YEDEK — Ücretli)

**Nereden Alınır:** https://platform.openai.com/api-keys

```
API Key: sk-proj-xxxxxxxxxxxxxxxxxxxxxxxxxx
```

**Kullanım:**
`lib/utils/api_keys.dart` dosyasında:
```dart
static const String openAIApiKey = 'sk-proj-...';
```

**Maliyet:** GPT-4o-mini yaklaşık $0.15 / 1000 istek

---

## 📱 Google AdMob

**Nereden Alınır:** https://apps.admob.com/

### Android App ID

```
App ID: ca-app-pub-XXXXX~XXXXX
```

**Kullanım:**
`android/app/src/main/AndroidManifest.xml` dosyasında:
```xml
<meta-data
    android:name="com.google.android.gms.ads.APPLICATION_ID"
    android:value="ca-app-pub-XXXXX~XXXXX"/>
```

### iOS App ID

```
App ID: ca-app-pub-XXXXX~XXXXX
```

**Kullanım:**
`ios/Runner/Info.plist` dosyasında:
```xml
<key>GADApplicationIdentifier</key>
<string>ca-app-pub-XXXXX~XXXXX</string>
```

### Reklam Birimleri

```
Banner ID (Android): ca-app-pub-XXXXX/XXXXX
Banner ID (iOS): ca-app-pub-XXXXX/XXXXX

Interstitial ID (Android): ca-app-pub-XXXXX/XXXXX
Interstitial ID (iOS): ca-app-pub-XXXXX/XXXXX

Rewarded ID (Android): ca-app-pub-XXXXX/XXXXX
Rewarded ID (iOS): ca-app-pub-XXXXX/XXXXX
```

**Kullanım:**
`lib/utils/constants.dart` dosyasında:
```dart
static const String adMobBannerId = 'ca-app-pub-XXXXX/XXXXX';
static const String adMobInterstitialId = 'ca-app-pub-XXXXX/XXXXX';
static const String adMobRewardedId = 'ca-app-pub-XXXXX/XXXXX';
```

---

## 🔒 Güvenlik Notları

1. ❌ **API anahtarlarını asla GitHub'a yüklemeyin**
2. ✅ `api_keys.dart` zaten `.gitignore`'da
3. ✅ `api_keys_template.dart` şablon olarak commit edilir
4. ✅ Production'da Firebase Remote Config kullanın
5. ✅ API rate limiting uygulayın

---

## 📊 Test Mode

Geliştirme sırasında test reklamları kullanabilirsiniz:

**Android Test IDs:**
- Banner: `ca-app-pub-3940256099942544/6300978111`
- Interstitial: `ca-app-pub-3940256099942544/1033173712`
- Rewarded: `ca-app-pub-3940256099942544/5224354917`

**iOS Test IDs:**
- Banner: `ca-app-pub-3940256099942544/2934735716`
- Interstitial: `ca-app-pub-3940256099942544/4411468910`
- Rewarded: `ca-app-pub-3940256099942544/1712485313`

---

## ✅ Checklist

- [ ] Gemini API Key alındı
- [ ] api_keys.dart oluşturuldu
- [ ] AdMob hesabı oluşturuldu
- [ ] Android App ID eklendi
- [ ] iOS App ID eklendi
- [ ] Reklam birimleri oluşturuldu
- [ ] constants.dart güncellendi
- [ ] AndroidManifest.xml güncellendi
- [ ] Info.plist güncellendi
- [ ] api_keys.dart .gitignore'da
- [ ] Test edildi

---

**Son güncelleme:** Mayıs 2026
