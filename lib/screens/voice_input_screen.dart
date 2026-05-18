import 'package:flutter/material.dart';
import 'package:speech_to_text/speech_to_text.dart' as stt;
import '../utils/theme.dart';
import '../services/language_service.dart';
import 'juri_selection_screen.dart';
import '../utils/page_transitions.dart';

/// Ses kaydı ile dava metni girişi
class VoiceInputScreen extends StatefulWidget {
  const VoiceInputScreen({super.key});

  @override
  State<VoiceInputScreen> createState() => _VoiceInputScreenState();
}

class _VoiceInputScreenState extends State<VoiceInputScreen>
    with SingleTickerProviderStateMixin {
  final stt.SpeechToText _speech = stt.SpeechToText();
  bool _isListening = false;
  bool _isInitialized = false;
  String _text = '';
  String _statusMessage = 'Mikrofona dokunarak konuşmaya başlayın';
  double _confidence = 0.0;
  
  late AnimationController _pulseController;
  late Animation<double> _pulseAnimation;

  @override
  void initState() {
    super.initState();
    _initSpeech();
    
    // Pulse animasyonu
    _pulseController = AnimationController(
      duration: const Duration(milliseconds: 1500),
      vsync: this,
    )..repeat(reverse: true);
    
    _pulseAnimation = Tween<double>(begin: 0.8, end: 1.2).animate(
      CurvedAnimation(parent: _pulseController, curve: Curves.easeInOut),
    );
  }

  @override
  void dispose() {
    _pulseController.dispose();
    _speech.stop();
    super.dispose();
  }

  Future<void> _initSpeech() async {
    try {
      final available = await _speech.initialize(
        onStatus: (status) {
          if (mounted) {
            setState(() {
              if (status == 'done') {
                _isListening = false;
                _statusMessage = 'Kayıt tamamlandı';
              } else if (status == 'listening') {
                _statusMessage = 'Dinliyorum...';
              }
            });
          }
        },
        onError: (error) {
          if (mounted) {
            setState(() {
              _isListening = false;
              _statusMessage = 'Hata: ${error.errorMsg}';
            });
          }
        },
      );

      if (mounted) {
        setState(() {
          _isInitialized = available;
          if (!available) {
            _statusMessage = 'Ses tanıma kullanılamıyor';
          }
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _statusMessage = 'Başlatılamadı: $e';
        });
      }
    }
  }

  /// Mevcut uygulama diline göre speech-to-text locale'i döndür
  String _getSpeechLocale() {
    final langCode = LanguageService().currentLocale.languageCode;
    switch (langCode) {
      case 'en':
        return 'en_US';
      case 'ar':
        return 'ar_AE';
      default:
        return 'tr_TR';
    }
  }

  Future<void> _toggleListening() async {
    if (!_isInitialized) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Ses tanıma başlatılamadı'),
          backgroundColor: Colors.red,
        ),
      );
      return;
    }

    if (_isListening) {
      await _speech.stop();
      setState(() => _isListening = false);
    } else {
      setState(() {
        _text = '';
        _confidence = 0.0;
      });
      
      final available = await _speech.listen(
        onResult: (result) {
          setState(() {
            _text = result.recognizedWords;
            _confidence = result.confidence;
          });
        },
        localeId: _getSpeechLocale(), // Mevcut dile göre dinamik
        listenOptions: stt.SpeechListenOptions(
          listenMode: stt.ListenMode.confirmation,
          cancelOnError: true,
          partialResults: true,
        ),
      );

      if (!available) {
        setState(() {
          _statusMessage = 'Mikrofon izni gerekli';
        });
        return;
      }

      setState(() => _isListening = true);
    }
  }

  void _continueWithText() {
    if (_text.trim().isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Lütfen önce bir şeyler kaydedin'),
          backgroundColor: Colors.orange,
        ),
      );
      return;
    }

    Navigator.push(
      context,
      PageTransitions.slideFromRight(
        JuriSelectionScreen(davaMetni: _text.trim()),
      ),
    );
  }

  void _clearText() {
    setState(() {
      _text = '';
      _confidence = 0.0;
      _statusMessage = 'Mikrofona dokunarak konuşmaya başlayın';
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Sesli Kayıt'),
        centerTitle: true,
        actions: [
          if (_text.isNotEmpty)
            IconButton(
              icon: const Icon(Icons.delete_outline),
              onPressed: _clearText,
              tooltip: 'Temizle',
            ),
        ],
      ),
      body: Column(
        children: [
          Expanded(
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  // Durum kartı
                  Container(
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        colors: _isListening
                            ? [Colors.red.shade50, Colors.red.shade100]
                            : [Colors.blue.shade50, Colors.blue.shade100],
                      ),
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(
                        color: _isListening
                            ? Colors.red.shade300
                            : Colors.blue.shade300,
                      ),
                    ),
                    child: Row(
                      children: [
                        Icon(
                          _isListening ? Icons.mic : Icons.mic_none,
                          color: _isListening ? Colors.red : Colors.blue,
                          size: 32,
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                _isListening ? 'Kaydediliyor...' : 'Hazır',
                                style: const TextStyle(
                                  fontSize: 18,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                              Text(
                                _statusMessage,
                                style: TextStyle(
                                  fontSize: 14,
                                  color: Colors.grey[700],
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 32),

                  // Mikrofon butonu
                  Center(
                    child: GestureDetector(
                      onTap: _toggleListening,
                      child: AnimatedBuilder(
                        animation: _pulseAnimation,
                        builder: (context, child) {
                          return Transform.scale(
                            scale: _isListening ? _pulseAnimation.value : 1.0,
                            child: Container(
                              width: 150,
                              height: 150,
                              decoration: BoxDecoration(
                                shape: BoxShape.circle,
                                gradient: RadialGradient(
                                  colors: _isListening
                                      ? [Colors.red.shade400, Colors.red.shade700]
                                      : [AppTheme.primaryColor, AppTheme.accentColor],
                                ),
                                boxShadow: [
                                  BoxShadow(
                                    color: (_isListening
                                            ? Colors.red
                                            : AppTheme.primaryColor)
                                        .withValues(alpha: 0.5),
                                    blurRadius: 20,
                                    spreadRadius: 5,
                                  ),
                                ],
                              ),
                              child: Icon(
                                _isListening ? Icons.stop : Icons.mic,
                                size: 64,
                                color: Colors.white,
                              ),
                            ),
                          );
                        },
                      ),
                    ),
                  ),
                  const SizedBox(height: 16),
                  
                  // Buton metni
                  Center(
                    child: Text(
                      _isListening
                          ? 'Durdurmak için dokun'
                          : 'Kaydetmeye başla',
                      style: TextStyle(
                        fontSize: 16,
                        color: Colors.grey[600],
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ),
                  
                  const SizedBox(height: 32),

                  // Metin kartı
                  if (_text.isNotEmpty) ...[
                    Container(
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        color: Colors.grey[100],
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(color: Colors.grey[300]!),
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            children: [
                              const Icon(Icons.text_snippet, size: 20),
                              const SizedBox(width: 8),
                              const Text(
                                'Kaydedilen Metin',
                                style: TextStyle(
                                  fontSize: 16,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                              const Spacer(),
                              if (_confidence > 0)
                                Container(
                                  padding: const EdgeInsets.symmetric(
                                    horizontal: 8,
                                    vertical: 4,
                                  ),
                                  decoration: BoxDecoration(
                                    color: _confidence > 0.8
                                        ? Colors.green.shade100
                                        : _confidence > 0.5
                                            ? Colors.orange.shade100
                                            : Colors.red.shade100,
                                    borderRadius: BorderRadius.circular(12),
                                  ),
                                  child: Text(
                                    '${(_confidence * 100).toInt()}%',
                                    style: TextStyle(
                                      fontSize: 12,
                                      fontWeight: FontWeight.bold,
                                      color: _confidence > 0.8
                                          ? Colors.green.shade900
                                          : _confidence > 0.5
                                              ? Colors.orange.shade900
                                              : Colors.red.shade900,
                                    ),
                                  ),
                                ),
                            ],
                          ),
                          const Divider(height: 24),
                          Text(
                            _text,
                            style: const TextStyle(
                              fontSize: 15,
                              height: 1.5,
                            ),
                          ),
                          const SizedBox(height: 12),
                          Text(
                            '${_text.split(' ').length} kelime',
                            style: TextStyle(
                              fontSize: 12,
                              color: Colors.grey[600],
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 16),
                  ],

                  // İpuçları
                  if (!_isListening && _text.isEmpty)
                    Container(
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        color: Colors.amber.shade50,
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(color: Colors.amber.shade200),
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            children: [
                              Icon(Icons.lightbulb, color: Colors.amber[700]),
                              const SizedBox(width: 8),
                              const Text(
                                'İpuçları',
                                style: TextStyle(
                                  fontWeight: FontWeight.bold,
                                  fontSize: 16,
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 12),
                          _buildTip('Sessiz bir ortamda kayıt yapın'),
                          _buildTip('Net ve anlaşılır konuşun'),
                          _buildTip('Tartışmanın her iki tarafını da anlatın'),
                          _buildTip('Duygularınızı ve olayların sırasını belirtin'),
                        ],
                      ),
                    ),
                ],
              ),
            ),
          ),

          // Alt buton
          if (_text.isNotEmpty)
            SafeArea(
              child: Container(
                width: double.infinity,
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: Colors.white,
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withValues(alpha: 0.1),
                      blurRadius: 8,
                      offset: const Offset(0, -2),
                    ),
                  ],
                ),
                child: ElevatedButton(
                  onPressed: _continueWithText,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppTheme.primaryColor,
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(vertical: 16),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                  child: const Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text(
                        'Devam Et',
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      SizedBox(width: 8),
                      Icon(Icons.arrow_forward),
                    ],
                  ),
                ),
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildTip(String text) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            '• ',
            style: TextStyle(fontSize: 16),
          ),
          Expanded(
            child: Text(
              text,
              style: TextStyle(
                fontSize: 14,
                color: Colors.grey[700],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
