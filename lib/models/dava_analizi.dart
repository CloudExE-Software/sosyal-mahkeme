// API isteği ve yanıtı için model
class DavaAnalizi {
  final String metin;
  final String juriTipiId;
  final String? imageBase64; // Opsiyonel: OCR'dan gelen görüntü

  DavaAnalizi({
    required this.metin,
    required this.juriTipiId,
    this.imageBase64,
  });

  Map<String, dynamic> toJson() {
    return {
      'metin': metin,
      'juri_tipi_id': juriTipiId,
      if (imageBase64 != null) 'image_base64': imageBase64,
    };
  }
}

// API yanıt modeli
class AIResponse {
  final bool success;
  final String? errorMessage;
  final Map<String, dynamic>? data;

  AIResponse({
    required this.success,
    this.errorMessage,
    this.data,
  });

  factory AIResponse.success(Map<String, dynamic> data) {
    return AIResponse(
      success: true,
      data: data,
    );
  }

  factory AIResponse.error(String message) {
    return AIResponse(
      success: false,
      errorMessage: message,
    );
  }
}
