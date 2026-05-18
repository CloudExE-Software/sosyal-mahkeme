import 'dart:io';
import 'package:google_mlkit_text_recognition/google_mlkit_text_recognition.dart';
import 'package:image_picker/image_picker.dart';
import 'logger_service.dart';

/// Google ML Kit ile OCR (Optical Character Recognition) servisi
class OCRService {
  // Singleton pattern
  static final OCRService _instance = OCRService._internal();
  factory OCRService() => _instance;
  OCRService._internal();

  final TextRecognizer _textRecognizer = TextRecognizer();
  final ImagePicker _imagePicker = ImagePicker();

  /// Galeriden veya kameradan görüntü seç
  Future<File?> pickImage({bool fromCamera = false}) async {
    try {
      final XFile? image = await _imagePicker.pickImage(
        source: fromCamera ? ImageSource.camera : ImageSource.gallery,
        imageQuality: 85, // Boyutu küçültmek için
      );

      if (image != null) {
        return File(image.path);
      }
      return null;
    } catch (e) {
      LoggerService.error('Görüntü seçme hatası', tag: 'OCRService', error: e);
      return null;
    }
  }

  /// Görüntüden metin çıkar
  Future<String?> extractTextFromImage(File imageFile) async {
    try {
      final inputImage = InputImage.fromFile(imageFile);
      final RecognizedText recognizedText = await _textRecognizer.processImage(inputImage);

      if (recognizedText.text.isEmpty) {
        return null;
      }

      // Tüm blokları birleştir
      StringBuffer fullText = StringBuffer();
      for (TextBlock block in recognizedText.blocks) {
        for (TextLine line in block.lines) {
          fullText.writeln(line.text);
        }
      }

      return fullText.toString().trim();
    } catch (e) {
      LoggerService.error('OCR Hatası', tag: 'OCRService', error: e);
      return null;
    }
  }

  /// Görüntü seç ve metin çıkar (tek fonksiyonda)
  Future<Map<String, dynamic>> processImage({bool fromCamera = false}) async {
    try {
      // 1. Görüntüyü seç
      final imageFile = await pickImage(fromCamera: fromCamera);
      if (imageFile == null) {
        return {
          'success': false,
          'error': 'Görüntü seçilmedi',
        };
      }

      // 2. OCR işlemi
      final extractedText = await extractTextFromImage(imageFile);
      if (extractedText == null || extractedText.isEmpty) {
        return {
          'success': false,
          'error': 'Görüntüde metin bulunamadı',
        };
      }

      return {
        'success': true,
        'text': extractedText,
        'imagePath': imageFile.path,
      };
    } catch (e) {
      return {
        'success': false,
        'error': 'Görüntü işleme hatası: $e',
      };
    }
  }

  /// Cleanup
  void dispose() {
    _textRecognizer.close();
  }
}
