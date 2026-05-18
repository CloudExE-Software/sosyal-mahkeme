import 'dart:io';
import 'dart:typed_data';
import 'package:flutter/material.dart';
import 'package:screenshot/screenshot.dart';
import 'package:share_plus/share_plus.dart';
import 'package:path_provider/path_provider.dart';
import 'package:in_app_review/in_app_review.dart';
import '../models/karar.dart';
import '../utils/theme.dart';
import '../utils/constants.dart';
import '../utils/error_handler.dart';
import '../widgets/certificate_widget.dart';
import '../services/history_service.dart';
import '../services/analytics_service.dart';
import '../services/favorite_service.dart';
import '../services/viral_export_service.dart';

/// Sonuç Ekranı - Kararın gösterildiği ekran
class ResultScreen extends StatefulWidget {
  final Karar karar;
  final String davaMetni;

  const ResultScreen({
    super.key,
    required this.karar,
    required this.davaMetni,
  });

  @override
  State<ResultScreen> createState() => _ResultScreenState();
}

class _ResultScreenState extends State<ResultScreen>
    with SingleTickerProviderStateMixin {
  final ScreenshotController _screenshotController = ScreenshotController();
  final FavoriteService _favoriteService = FavoriteService();
  final ViralExportService _viralService = ViralExportService();
  late AnimationController _animationController;
  late Animation<double> _fadeAnimation;
  late Animation<Offset> _slideAnimation;
  
  bool _isSharing = false;
  bool _isFavorite = false;
  String? _currentHistoryId;

  @override
  void initState() {
    super.initState();
    
    // Geçmişe kaydet (review isteği bunun tamamlanmasını bekler)
    _saveToHistory();
    
    // Favori durumunu kontrol et
    _checkFavoriteStatus();
    
    // Giriş animasyonu
    _animationController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 800),
    );
    
    _fadeAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(
        parent: _animationController,
        curve: Curves.easeIn,
      ),
    );
    
    _slideAnimation = Tween<Offset>(
      begin: const Offset(0, 0.3),
      end: Offset.zero,
    ).animate(
      CurvedAnimation(
        parent: _animationController,
        curve: Curves.easeOutCubic,
      ),
    );
    
    _animationController.forward();
  }

  Future<void> _saveToHistory() async {
    try {
      final historyId = await HistoryService().addDecision(
        davaMetni: widget.davaMetni,
        karar: widget.karar,
      );
      if (mounted) {
        setState(() => _currentHistoryId = historyId);
      }
      // Geçmiş kaydedildikten sonra in-app review iste (race condition önlenir)
      await _requestReview();
    } catch (e) {
      // Sessizce hata yakala, kullanıcıyı rahatsız etme
      ErrorHandler.logError(e, null);
    }
  }

  Future<void> _checkFavoriteStatus() async {
    if (_currentHistoryId != null) {
      final isFav = await _favoriteService.isFavorite(_currentHistoryId!);
      setState(() => _isFavorite = isFav);
    }
  }

  Future<void> _toggleFavorite() async {
    if (_currentHistoryId == null) return;

    try {
      // History item'ı bul
      final history = await HistoryService().getHistory();
      final item = history.firstWhere((h) => h.id == _currentHistoryId);

      final success = await _favoriteService.toggleFavorite(item);
      
      if (success) {
        setState(() => _isFavorite = !_isFavorite);
        
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(_isFavorite ? 'Favorilere eklendi' : 'Favorilerden çıkarıldı'),
              duration: const Duration(seconds: 2),
            ),
          );
        }
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('İşlem başarısız'),
            backgroundColor: AppTheme.errorColor,
          ),
        );
      }
    }
  }

  Future<void> _requestReview() async {
    try {
      final InAppReview inAppReview = InAppReview.instance;
      
      // Her 5 analizde bir yorum iste
      final historyCount = await HistoryService().getHistoryCount();
      if (historyCount % 5 == 0 && historyCount > 0) {
        if (await inAppReview.isAvailable()) {
          await inAppReview.requestReview();
        }
      }
    } catch (e) {
      // Sessizce hata yakala
      ErrorHandler.logError(e, null);
    }
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  /// Ekran görüntüsü al ve paylaş
  Future<void> _shareResult() async {
    setState(() => _isSharing = true);

    try {
      // Analytics
      await AnalyticsService().logDecisionShared(widget.karar.juriTipi);

      // Screenshot al
      final Uint8List? imageBytes = await _screenshotController.capture();
      
      if (imageBytes == null) {
        throw Exception('Ekran görüntüsü alınamadı');
      }

      // Geçici dosyaya kaydet
      final tempDir = await getTemporaryDirectory();
      final file = File('${tempDir.path}/hakli_kim_karar.png');
      await file.writeAsBytes(imageBytes);

      // Paylaş
      await Share.shareXFiles(
        [XFile(file.path)],
        text: '${Constants.shareWatermark}\n\n'
            'Jüri: ${widget.karar.juriTipi}\n'
            'Haklı: ${widget.karar.hakliKisi}\n'
            'Haksızlık Oranı: %${widget.karar.haksizlikOrani}',
      );

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Karar paylaşıldı!'),
            backgroundColor: AppTheme.successColor,
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Paylaşım hatası: $e'),
            backgroundColor: AppTheme.errorColor,
          ),
        );
      }
    } finally {
      if (mounted) {
        setState(() => _isSharing = false);
      }
    }
  }

  /// Ana sayfaya dön
  void _backToHome() {
    Navigator.popUntil(context, (route) => route.isFirst);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Mahkeme Kararı'),
        leading: IconButton(
          icon: const Icon(Icons.home),
          onPressed: _backToHome,
        ),
        actions: [
          IconButton(
            icon: Icon(
              _isFavorite ? Icons.favorite : Icons.favorite_border,
              color: _isFavorite ? Colors.red : null,
            ),
            onPressed: _toggleFavorite,
            tooltip: _isFavorite ? 'Favorilerden çıkar' : 'Favorilere ekle',
          ),
          if (_isSharing)
            const Padding(
              padding: EdgeInsets.all(16.0),
              child: SizedBox(
                width: 24,
                height: 24,
                child: CircularProgressIndicator(
                  strokeWidth: 2,
                  color: AppTheme.textPrimary,
                ),
              ),
            )
          else
            IconButton(
              icon: const Icon(Icons.share),
              onPressed: _shareResult,
              tooltip: 'Paylaş',
            ),
        ],
      ),
      body: FadeTransition(
        opacity: _fadeAnimation,
        child: SlideTransition(
          position: _slideAnimation,
          child: SingleChildScrollView(
            padding: AppTheme.pagePadding,
            child: Column(
              children: [
                // Sertifika (Screenshot alınacak alan)
                Screenshot(
                  controller: _screenshotController,
                  child: CertificateWidget(karar: widget.karar),
                ),
                
                const SizedBox(height: AppTheme.largeSpacing),
                
                // Aksiyon butonları
                _buildActionButtons(),
                
                const SizedBox(height: AppTheme.defaultSpacing),
                
                // Detaylı gerekçe
                _buildDetailedReasoning(),
                
                const SizedBox(height: AppTheme.defaultSpacing),
                
                // Ceza kartı
                _buildPunishmentCard(),
                
                const SizedBox(height: AppTheme.largeSpacing),
                
                // Disclaimer
                _buildDisclaimer(),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildActionButtons() {
    return Column(
      children: [
        Row(
          children: [
            Expanded(
              child: ElevatedButton.icon(
                onPressed: _isSharing ? null : _shareResult,
                icon: _isSharing
                    ? const SizedBox(
                        width: 20,
                        height: 20,
                        child: CircularProgressIndicator(
                          strokeWidth: 2,
                          color: AppTheme.textPrimary,
                        ),
                      )
                    : const Icon(Icons.share),
                label: Text(_isSharing ? 'Paylaşılıyor...' : 'Paylaş'),
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppTheme.successColor,
                  padding: const EdgeInsets.symmetric(vertical: 16),
                ),
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: OutlinedButton.icon(
                onPressed: _backToHome,
                icon: const Icon(Icons.home),
                label: const Text('Ana Sayfa'),
                style: OutlinedButton.styleFrom(
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  side: const BorderSide(color: AppTheme.accentColor),
                ),
              ),
            ),
          ],
        ),
        const SizedBox(height: AppTheme.defaultSpacing),
        _buildViralShareButtons(),
      ],
    );
  }

  Widget _buildViralShareButtons() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Text(
          'Viral Paylaş',
          style: Theme.of(context).textTheme.titleMedium?.copyWith(
                color: AppTheme.textSecondary,
              ),
        ),
        const SizedBox(height: 12),
        Row(
          children: [
            Expanded(
              child: _viralButton(
                icon: Icons.auto_awesome,
                label: 'Story',
                color: Colors.purple,
                onTap: () => _viralService.shareAsStory(context: context, karar: widget.karar),
              ),
            ),
            const SizedBox(width: 8),
            Expanded(
              child: _viralButton(
                icon: Icons.mood,
                label: 'Meme',
                color: Colors.orange,
                onTap: () => _viralService.shareAsMeme(context: context, karar: widget.karar),
              ),
            ),
            const SizedBox(width: 8),
            Expanded(
              child: _viralButton(
                icon: Icons.chat_bubble,
                label: 'WhatsApp',
                color: Colors.green,
                onTap: () => _viralService.shareAsWhatsAppStatus(context: context, karar: widget.karar),
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _viralButton({
    required IconData icon,
    required String label,
    required Color color,
    required VoidCallback onTap,
  }) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(12),
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 12),
        decoration: BoxDecoration(
          color: color.withValues(alpha: 0.1),
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: color.withValues(alpha: 0.3)),
        ),
        child: Column(
          children: [
            Icon(icon, color: color, size: 28),
            const SizedBox(height: 4),
            Text(
              label,
              style: TextStyle(
                fontSize: 12,
                color: color,
                fontWeight: FontWeight.w600,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildDetailedReasoning() {
    return Card(
      child: Padding(
        padding: AppTheme.cardPadding,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                const Icon(
                  Icons.article_outlined,
                  color: AppTheme.infoColor,
                ),
                const SizedBox(width: 12),
                Text(
                  'Detaylı Gerekçe',
                  style: Theme.of(context).textTheme.titleLarge,
                ),
              ],
            ),
            const Divider(height: 24),
            Text(
              widget.karar.gerekce,
              style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                height: 1.6,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildPunishmentCard() {
    return Card(
      color: AppTheme.errorColor.withValues(alpha: 0.1),
      child: Padding(
        padding: AppTheme.cardPadding,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                const Icon(
                  Icons.gavel,
                  color: AppTheme.errorColor,
                ),
                const SizedBox(width: 12),
                Text(
                  'Verilen Ceza',
                  style: Theme.of(context).textTheme.titleLarge?.copyWith(
                    color: AppTheme.errorColor,
                  ),
                ),
              ],
            ),
            const Divider(height: 24),
            Text(
              widget.karar.ceza,
              style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                height: 1.6,
                color: AppTheme.textPrimary,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildDisclaimer() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppTheme.warningColor.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: AppTheme.warningColor.withValues(alpha: 0.3),
        ),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Icon(
            Icons.info_outline,
            color: AppTheme.warningColor,
            size: 20,
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Text(
              'Bu karar yapay zeka tarafından oluşturulmuştur ve eğlence amaçlıdır. '
              'Gerçek hukuki bir bağlayıcılığı yoktur.',
              style: Theme.of(context).textTheme.bodySmall?.copyWith(
                color: AppTheme.textSecondary,
                fontSize: 12,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
