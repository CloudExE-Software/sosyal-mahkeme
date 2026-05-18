import 'dart:convert';
import 'dart:typed_data';
import 'package:crypto/crypto.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:encrypt/encrypt.dart' as encrypt;
import 'logger_service.dart';

/// Şifreleme servisi
class EncryptionService {
  static final EncryptionService _instance = EncryptionService._internal();
  factory EncryptionService() => _instance;
  EncryptionService._internal();

  final FlutterSecureStorage _secureStorage = const FlutterSecureStorage(
    aOptions: AndroidOptions(
      encryptedSharedPreferences: true,
    ),
  );

  static const String _keyKey = 'encryption_key';
  static const String _ivKey = 'encryption_iv';

  String? _encryptionKey;
  String? _encryptionIv;

  /// Şifrelemeyi başlat
  Future<void> initialize() async {
    try {
      // Anahtarları storage'dan al veya oluştur
      _encryptionKey = await _secureStorage.read(key: _keyKey);
      _encryptionIv = await _secureStorage.read(key: _ivKey);

      if (_encryptionKey == null || _encryptionIv == null) {
        await _generateKeys();
      }

      LoggerService.info('Şifreleme servisi başlatıldı', tag: 'EncryptionService');
    } catch (e) {
      LoggerService.error('Şifreleme başlatılamadı', tag: 'EncryptionService', error: e);
      rethrow;
    }
  }

  /// Yeni anahtarlar oluştur
  Future<void> _generateKeys() async {
    final key = encrypt.Key.fromSecureRandom(32);
    final iv = encrypt.IV.fromSecureRandom(16);

    _encryptionKey = base64Encode(key.bytes);
    _encryptionIv = base64Encode(iv.bytes);

    await _secureStorage.write(key: _keyKey, value: _encryptionKey);
    await _secureStorage.write(key: _ivKey, value: _encryptionIv);
  }

  /// Metni şifrele
  String encryptText(String plainText) {
    if (_encryptionKey == null || _encryptionIv == null) {
      throw Exception('Şifreleme anahtarları başlatılmamış');
    }

    final key = encrypt.Key.fromBase64(_encryptionKey!);
    final iv = encrypt.IV.fromBase64(_encryptionIv!);
    final encrypter = encrypt.Encrypter(encrypt.AES(key));

    final encrypted = encrypter.encrypt(plainText, iv: iv);
    return encrypted.base64;
  }

  /// Şifrelenmiş metni çöz
  String decryptText(String encryptedText) {
    if (_encryptionKey == null || _encryptionIv == null) {
      throw Exception('Şifreleme anahtarları başlatılmamış');
    }

    final key = encrypt.Key.fromBase64(_encryptionKey!);
    final iv = encrypt.IV.fromBase64(_encryptionIv!);
    final encrypter = encrypt.Encrypter(encrypt.AES(key));

    final decrypted = encrypter.decrypt64(encryptedText, iv: iv);
    return decrypted;
  }

  /// Veri hash'i oluştur (bütünlük kontrolü için)
  String generateHash(String data) {
    final bytes = utf8.encode(data);
    final digest = sha256.convert(bytes);
    return digest.toString();
  }

  /// Hash doğrula
  bool verifyHash(String data, String hash) {
    return generateHash(data) == hash;
  }

  /// Anahtarları sıfırla
  Future<void> resetKeys() async {
    await _secureStorage.delete(key: _keyKey);
    await _secureStorage.delete(key: _ivKey);
    _encryptionKey = null;
    _encryptionIv = null;
    await _generateKeys();
  }

  /// Şifreleme aktif mi?
  bool get isEncryptionEnabled => _encryptionKey != null && _encryptionIv != null;
}