/// 🔐 API Anahtarları — Şablon
///
/// Kullanım:
/// 1. Bu dosyayı api_keys.dart olarak kopyalayın
///    (veya api_keys.dart oluşturup içine yapıştırın)
/// 2. Anahtarları doldurun
/// 3. api_keys.dart .gitignore'da olduğu için güvende
///
/// Anahtarları almak için:
/// - Gemini (ücretsiz): https://aistudio.google.com/apikey
/// - OpenAI (ücretli):  https://platform.openai.com/api-keys
class ApiKeys {
  /// Gemini API Key (ana sağlayıcı — ücretsiz)
  /// Boş bırakırsanız demo modda çalışır
  static const String geminiApiKey = 'BURAYA_GEMINI_API_KEY_EKLE';

  /// OpenAI API Key (yedek — ücretli)
  static const String openAIApiKey = 'BURAYA_OPENAI_API_KEY_EKLE';
}
