import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:encrypt/encrypt.dart' as encrypt_pkg;
import 'dart:convert';
import 'dart:math';
import 'dart:typed_data';
import 'package:crypto/crypto.dart';
import 'logger_service.dart';

/// Veri şifreleme servisi
/// Hassas kullanıcı verilerini şifreler ve güvenli bir şekilde saklar
class EncryptionService {
  static final EncryptionService _instance = EncryptionService._internal();
  factory EncryptionService() => _instance;
  EncryptionService._internal();

  final _secureStorage = const FlutterSecureStorage(
    aOptions: AndroidOptions(
      encryptedSharedPreferences: true,
    ),
    iOptions: IOSOptions(
      accessibility: KeychainAccessibility.first_unlock,
    ),
  );

  static const String _keyStorageKey = 'encryption_master_key';
  static const String _ivStorageKey = 'encryption_iv';
  
  encrypt_pkg.Key? _encryptionKey;
  encrypt_pkg.IV? _encryptionIV;
  bool _isInitialized = false;

  /// Şifreleme servisini başlat
  Future<void> initialize() async {
    if (_isInitialized) return;

    try {
      // Mevcut anahtar var mı kontrol et
      String? storedKey = await _secureStorage.read(key: _keyStorageKey);
      String? storedIV = await _secureStorage.read(key: _ivStorageKey);

      if (storedKey != null && storedIV != null) {
        // Mevcut anahtarı kullan
        _encryptionKey = encrypt_pkg.Key.fromBase64(storedKey);
        _encryptionIV = encrypt_pkg.IV.fromBase64(storedIV);
        LoggerService.info('Encryption keys loaded from secure storage');
      } else {
        // Yeni anahtar oluştur
        await _generateNewKeys();
        LoggerService.info('New encryption keys generated');
      }

      _isInitialized = true;
    } catch (e) {
      LoggerService.error('Failed to initialize EncryptionService', error: e);
      // Hata durumunda yeni anahtar oluşturmayı dene
      await _generateNewKeys();
      _isInitialized = true;
    }
  }

  /// Yeni şifreleme anahtarları oluştur
  Future<void> _generateNewKeys() async {
    // 256-bit AES key (32 byte)
    final keyBytes = Uint8List.fromList(
      List<int>.generate(32, (i) => Random.secure().nextInt(256)),
    );
    _encryptionKey = encrypt_pkg.Key(keyBytes);

    // 128-bit IV (16 byte)
    final ivBytes = Uint8List.fromList(
      List<int>.generate(16, (i) => Random.secure().nextInt(256)),
    );
    _encryptionIV = encrypt_pkg.IV(ivBytes);

    // Güvenli storage'a kaydet
    await _secureStorage.write(
      key: _keyStorageKey,
      value: _encryptionKey!.base64,
    );
    await _secureStorage.write(
      key: _ivStorageKey,
      value: _encryptionIV!.base64,
    );
  }

  /// String veriyi şifrele
  Future<String?> encryptString(String plainText) async {
    if (!_isInitialized) await initialize();

    try {
      if (_encryptionKey == null || _encryptionIV == null) {
        LoggerService.error('Encryption keys not initialized');
        return null;
      }

      final encrypter = encrypt_pkg.Encrypter(
        encrypt_pkg.AES(_encryptionKey!, mode: encrypt_pkg.AESMode.cbc),
      );

      final encrypted = encrypter.encrypt(plainText, iv: _encryptionIV);
      return encrypted.base64;
    } catch (e) {
      LoggerService.error('Encryption failed', error: e);
      return null;
    }
  }

  /// Şifreli veriyi çöz
  Future<String?> decryptString(String encryptedText) async {
    if (!_isInitialized) await initialize();

    try {
      if (_encryptionKey == null || _encryptionIV == null) {
        LoggerService.error('Encryption keys not initialized');
        return null;
      }

      final encrypter = encrypt_pkg.Encrypter(
        encrypt_pkg.AES(_encryptionKey!, mode: encrypt_pkg.AESMode.cbc),
      );

      final encrypted = encrypt_pkg.Encrypted.fromBase64(encryptedText);
      return encrypter.decrypt(encrypted, iv: _encryptionIV);
    } catch (e) {
      LoggerService.error('Decryption failed', error: e);
      return null;
    }
  }

  /// JSON objesini şifrele
  Future<String?> encryptJson(Map<String, dynamic> json) async {
    try {
      final jsonString = jsonEncode(json);
      return await encryptString(jsonString);
    } catch (e) {
      LoggerService.error('JSON encryption failed', error: e);
      return null;
    }
  }

  /// Şifreli JSON'ı çöz
  Future<Map<String, dynamic>?> decryptJson(String encryptedText) async {
    try {
      final decrypted = await decryptString(encryptedText);
      if (decrypted == null) return null;
      
      return jsonDecode(decrypted) as Map<String, dynamic>;
    } catch (e) {
      LoggerService.error('JSON decryption failed', error: e);
      return null;
    }
  }

  /// String listesini şifrele
  Future<String?> encryptList(List<String> list) async {
    try {
      final jsonString = jsonEncode(list);
      return await encryptString(jsonString);
    } catch (e) {
      LoggerService.error('List encryption failed', error: e);
      return null;
    }
  }

  /// Şifreli listeyi çöz
  Future<List<String>?> decryptList(String encryptedText) async {
    try {
      final decrypted = await decryptString(encryptedText);
      if (decrypted == null) return null;
      
      final decoded = jsonDecode(decrypted);
      return (decoded as List).cast<String>();
    } catch (e) {
      LoggerService.error('List decryption failed', error: e);
      return null;
    }
  }

  /// Verinin hash'ini oluştur (one-way, şifre kontrolü için)
  String hashString(String input) {
    final bytes = utf8.encode(input);
    final hash = sha256.convert(bytes);
    return hash.toString();
  }

  /// Güvenli random string oluştur
  String generateSecureToken(int length) {
    const chars = 'ABCDEFGHIJKLMNOPQRSTUVWXYZabcdefghijklmnopqrstuvwxyz0123456789';
    final random = Random.secure();
    return List.generate(length, (index) => chars[random.nextInt(chars.length)]).join();
  }

  /// Şifreleme anahtarlarını sıfırla (factory reset için)
  Future<void> resetKeys() async {
    try {
      await _secureStorage.delete(key: _keyStorageKey);
      await _secureStorage.delete(key: _ivStorageKey);
      await _generateNewKeys();
      LoggerService.info('Encryption keys reset');
    } catch (e) {
      LoggerService.error('Failed to reset encryption keys', error: e);
    }
  }

  /// Tüm güvenli storage'ı temizle
  Future<void> clearSecureStorage() async {
    try {
      await _secureStorage.deleteAll();
      _encryptionKey = null;
      _encryptionIV = null;
      _isInitialized = false;
      LoggerService.info('Secure storage cleared');
    } catch (e) {
      LoggerService.error('Failed to clear secure storage', error: e);
    }
  }

  /// Güvenli storage'a veri kaydet
  Future<void> secureWrite(String key, String value) async {
    try {
      await _secureStorage.write(key: key, value: value);
    } catch (e) {
      LoggerService.error('Secure write failed for key: $key', error: e);
    }
  }

  /// Güvenli storage'dan veri oku
  Future<String?> secureRead(String key) async {
    try {
      return await _secureStorage.read(key: key);
    } catch (e) {
      LoggerService.error('Secure read failed for key: $key', error: e);
      return null;
    }
  }

  /// Güvenli storage'dan veri sil
  Future<void> secureDelete(String key) async {
    try {
      await _secureStorage.delete(key: key);
    } catch (e) {
      LoggerService.error('Secure delete failed for key: $key', error: e);
    }
  }

  /// Veri güvenli mi kontrol et (hash ile)
  Future<bool> verifyIntegrity(String data, String expectedHash) async {
    try {
      final actualHash = hashString(data);
      return actualHash == expectedHash;
    } catch (e) {
      LoggerService.error('Integrity verification failed', error: e);
      return false;
    }
  }
}
