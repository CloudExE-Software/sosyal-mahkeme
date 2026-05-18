import 'package:flutter/material.dart';
import 'package:shimmer/shimmer.dart';
import '../services/ai_service.dart';
import '../services/ad_service.dart';
import '../models/karar.dart';
import '../models/juri_type.dart';
import '../utils/theme.dart';
import '../utils/constants.dart';
import '../utils/error_handler.dart';
import '../utils/page_transitions.dart';
import 'result_screen.dart';

/// Analiz Ekranı - AI işlemi ve loading
class AnalysisScreen extends StatefulWidget {
  final String davaMetni;
  final String juriTipiId;

  const AnalysisScreen({
    super.key,
    required this.davaMetni,
    required this.juriTipiId,
  });

  @override
  State<AnalysisScreen> createState() => _AnalysisScreenState();
}

class _AnalysisScreenState extends State<AnalysisScreen>
    with SingleTickerProviderStateMixin {
  final AIService _aiService = AIService();
  final AdService _adService = AdService();
  
  late AnimationController _animationController;
  late Animation<double> _scaleAnimation;
  
  bool _isAnalyzing = true;
  String _currentStatus = 'Deliller toplanıyor...';
  
  final List<String> _statusMessages = [
    'Deliller toplanıyor...',
    'Tanıklar sorgulanıyor...',
    'Mantık hataları tespit ediliyor...',
    'Safsatalar analiz ediliyor...',
    'Manipülasyon teknikleri inceleniyor...',
    'Karar hazırlanıyor...',
  ];
  
  int _currentMessageIndex = 0;

  @override
  void initState() {
    super.initState();
    
    // Animasyon
    _animationController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1500),
    )..repeat(reverse: true);
    
    _scaleAnimation = Tween<double>(begin: 0.8, end: 1.2).animate(
      CurvedAnimation(
        parent: _animationController,
        curve: Curves.easeInOut,
      ),
    );
    
    // Durum mesajlarını değiştir
    _startStatusRotation();
    
    // Analizi başlat
    _startAnalysis();
  }

  void _startStatusRotation() {
    Future.delayed(const Duration(seconds: 2), () {
      if (mounted && _isAnalyzing) {
        setState(() {
          _currentMessageIndex = (_currentMessageIndex + 1) % _statusMessages.length;
          _currentStatus = _statusMessages[_currentMessageIndex];
        });
        _startStatusRotation();
      }
    });
  }

  Future<void> _startAnalysis() async {
    try {
      // Minimum bekleme süresi (UX için)
      await Future.delayed(const Duration(seconds: 3));
      
      // API anahtarı varsa gerçek, yoksa demo analiz yap
      final karar = await _aiService.analyzeText(
        metin: widget.davaMetni,
        juriTipiId: widget.juriTipiId,
      );
      
      if (karar == null) {
        throw Exception('Analiz tamamlanamadı');
      }
      
      if (!mounted) return;
      
      setState(() {
        _isAnalyzing = false;
      });
      
      // Reklam göster (Interstitial - her durumda callback çalışır)
      await _adService.showInterstitialAd();
      
      // Sonuca git
      if (mounted) {
        _navigateToResult(karar);
      }
      
    } catch (e) {
      if (!mounted) return;
      
      setState(() {
        _isAnalyzing = false;
      });
      
      if (!mounted) return;
      ErrorHandler.showErrorDialog(context, e);
      Navigator.pop(context);
    }
  }

  void _navigateToResult(Karar karar) {
    Navigator.pushReplacement(
      context,
      PageTransitions.fadeTransition(
        ResultScreen(
          karar: karar,
          davaMetni: widget.davaMetni,
        ),
        duration: const Duration(milliseconds: 600),
      ),
    );
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return PopScope(
      canPop: false, // Geri tuşunu devre dışı bırak
      child: Scaffold(
        backgroundColor: AppTheme.backgroundColor,
        body: SafeArea(
          child: Center(
            child: Padding(
              padding: AppTheme.pagePadding,
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  // Animasyonlu ikon
                  Hero(
                    tag: 'jury_${widget.juriTipiId}',
                    child: ScaleTransition(
                      scale: _scaleAnimation,
                      child: Container(
                        padding: const EdgeInsets.all(32),
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          gradient: RadialGradient(
                            colors: [
                              AppTheme.accentColor.withValues(alpha: 0.3),
                              AppTheme.accentColor.withValues(alpha: 0.1),
                              Colors.transparent,
                            ],
                          ),
                        ),
                        child: Text(
                          JuriType.getById(widget.juriTipiId).icon,
                          style: const TextStyle(fontSize: 80),
                        ),
                      ),
                    ),
                  ),
                  
                  const SizedBox(height: 48),
                  
                  // Başlık
                  Text(
                    'Mahkeme Toplanıyor',
                    style: Theme.of(context).textTheme.displayMedium?.copyWith(
                      color: AppTheme.textPrimary,
                    ),
                    textAlign: TextAlign.center,
                  ),
                  
                  const SizedBox(height: 16),
                  
                  // Alt başlık
                  Text(
                    'Yapay zeka tartışmanızı analiz ediyor...',
                    style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                      color: AppTheme.textSecondary,
                    ),
                    textAlign: TextAlign.center,
                  ),
                  
                  const SizedBox(height: 48),
                  
                  // Shimmer progress indicator
                  Shimmer.fromColors(
                    baseColor: AppTheme.accentColor.withValues(alpha: 0.3),
                    highlightColor: AppTheme.accentColor,
                    period: const Duration(milliseconds: 1500),
                    child: const SizedBox(
                      width: 60,
                      height: 60,
                      child: CircularProgressIndicator(
                        strokeWidth: 6,
                        valueColor: AlwaysStoppedAnimation<Color>(
                          AppTheme.accentColor,
                        ),
                      ),
                    ),
                  ),
                  
                  const SizedBox(height: 32),
                  
                  // Durum mesajı
                  AnimatedSwitcher(
                    duration: const Duration(milliseconds: 500),
                    child: Text(
                      _currentStatus,
                      key: ValueKey<String>(_currentStatus),
                      style: Theme.of(context).textTheme.titleLarge?.copyWith(
                        color: AppTheme.accentColor,
                        fontWeight: FontWeight.w500,
                      ),
                      textAlign: TextAlign.center,
                    ),
                  ),
                  
                  const SizedBox(height: 48),
                  
                  // İpucu kutusu
                  Container(
                    padding: const EdgeInsets.all(20),
                    decoration: BoxDecoration(
                      color: AppTheme.primaryColor.withValues(alpha: 0.6),
                      borderRadius: BorderRadius.circular(16),
                      border: Border.all(
                        color: AppTheme.accentColor.withValues(alpha: 0.3),
                      ),
                    ),
                    child: Row(
                      children: [
                        const Icon(
                          Icons.lightbulb_outline,
                          color: AppTheme.warningColor,
                          size: 32,
                        ),
                        const SizedBox(width: 16),
                        Expanded(
                          child: Text(
                            'Sabırlı olun! AI tartışmadaki her detayı inceliyor.',
                            style: Theme.of(context).textTheme.bodyMedium,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
