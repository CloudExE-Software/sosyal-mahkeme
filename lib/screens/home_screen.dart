import 'package:flutter/material.dart';
import 'package:google_mobile_ads/google_mobile_ads.dart';
import '../utils/theme.dart';
import '../utils/constants.dart';
import '../utils/error_handler.dart';
import '../services/analytics_service.dart';
import '../services/gamification_service.dart';
import '../services/ad_service.dart';
import 'juri_selection_screen.dart';
import 'history_screen.dart';
import 'settings_screen.dart';
import 'favorites_screen.dart';
import 'comparison_jury_selection_screen.dart';
import 'voice_input_screen.dart';
import '../services/ocr_service.dart';

/// Ana Ekran - Dava açma seçenekleri
class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  final OCRService _ocrService = OCRService();
  final GamificationService _gamification = GamificationService();
  final AdService _adService = AdService();
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    _logScreenView();
    _gamification.initialize();
  }

  Future<void> _logScreenView() async {
    await AnalyticsService().logScreenView('home_screen');
  }

  /// Görüntüden metin çıkar ve jüri seçimine yönlendir
  Future<void> _pickImageAndExtractText({bool fromCamera = false}) async {
    setState(() => _isLoading = true);

    try {
      // Analytics
      await AnalyticsService().logOCRUsed(fromCamera ? 'camera' : 'gallery');

      final result = await _ocrService.processImage(fromCamera: fromCamera);

      if (result['success']) {
        final extractedText = result['text'] as String;
        
        if (!mounted) return;
        
        // Jüri seçimine yönlendir
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => JuriSelectionScreen(
              davaMetni: extractedText,
            ),
          ),
        );
      } else {
        if (!mounted) return;
        ErrorHandler.showErrorSnackbar(context, result['error']);
      }
    } catch (e, stackTrace) {
      ErrorHandler.logError(e, stackTrace);
      if (!mounted) return;
      ErrorHandler.showErrorSnackbar(context, e);
    } finally {
      if (mounted) {
        setState(() => _isLoading = false);
      }
    }
  }

  /// Manuel metin girişi için dialog
  void _showTextInputDialog() {
    final TextEditingController textController = TextEditingController();

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: AppTheme.primaryColor,
        title: const Text(
          'Davayı Anlat',
          style: TextStyle(color: AppTheme.textPrimary),
        ),
        content: TextField(
          controller: textController,
          maxLines: 10,
          autofocus: true,
          keyboardType: TextInputType.multiline,
          textInputAction: TextInputAction.newline,
          autocorrect: true,
          enableSuggestions: true,
          decoration: const InputDecoration(
            hintText: 'Tartışmayı buraya yazın...\n\nÖrnek:\nBen: Dün bulaşıkları sen yıkayacaktın\nO: Hayır senin sırandı...',
            border: OutlineInputBorder(),
          ),
          style: const TextStyle(color: AppTheme.textPrimary),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('İptal'),
          ),
          ElevatedButton(
            onPressed: () {
              final text = textController.text.trim();
              if (text.isNotEmpty) {
                Navigator.pop(context);
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => JuriSelectionScreen(
                      davaMetni: text,
                    ),
                  ),
                );
              }
            },
            child: const Text('Devam Et'),
          ),
        ],
      ),
    );
  }

  /// Karşılaştırma modu için dialog
  void _showComparisonDialog() {
    final TextEditingController textController = TextEditingController();

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: AppTheme.primaryColor,
        title: Row(
          children: [
            Icon(Icons.compare_arrows, color: Colors.purple[300]),
            const SizedBox(width: 8),
            const Expanded(
              child: Text(
                'Karşılaştırma Modu',
                style: TextStyle(color: AppTheme.textPrimary),
              ),
            ),
          ],
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Aynı davayı farklı jürilerin bakış açısından değerlendirin.',
              style: TextStyle(
                color: Colors.grey[300],
                fontSize: 14,
              ),
            ),
            const SizedBox(height: 16),
            TextField(
              controller: textController,
              maxLines: 8,
              autofocus: true,
              keyboardType: TextInputType.multiline,
              textInputAction: TextInputAction.newline,
              autocorrect: true,
              enableSuggestions: true,
              decoration: const InputDecoration(
                hintText: 'Davayı buraya yazın...\n\nÖrnek:\nBen: Bulaşıkları sen yıkayacaktın\nO: Hayır senin sırandı...',
                border: OutlineInputBorder(),
              ),
              style: const TextStyle(color: AppTheme.textPrimary),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('İptal'),
          ),
          ElevatedButton(
            onPressed: () {
              final text = textController.text.trim();
              if (text.isNotEmpty) {
                Navigator.pop(context);
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => ComparisonJurySelectionScreen(
                      davaMetni: text,
                    ),
                  ),
                );
              }
            },
            child: const Text('Devam Et'),
          ),
        ],
      ),
    );
  }


  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Column(
          children: [
            Text(
              Constants.appName,
              style: const TextStyle(fontWeight: FontWeight.bold),
            ),
            Text(
              Constants.appSlogan,
              style: TextStyle(
                fontSize: 12,
                color: AppTheme.textSecondary,
              ),
            ),
          ],
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.favorite),
            onPressed: () async {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => const FavoritesScreen()),
              );
            },
            tooltip: 'Favoriler',
          ),
          IconButton(
            icon: const Icon(Icons.history),
            onPressed: () async {
              final navigator = Navigator.of(context);
              await AnalyticsService().logHistoryViewed();
              if (mounted) {
                navigator.push(
                  MaterialPageRoute(builder: (context) => const HistoryScreen()),
                );
              }
            },
            tooltip: 'Geçmiş',
          ),
          IconButton(
            icon: const Icon(Icons.settings),
            onPressed: () async {
              final navigator = Navigator.of(context);
              await AnalyticsService().logSettingsOpened();
              if (mounted) {
                navigator.push(
                  MaterialPageRoute(builder: (context) => const SettingsScreen()),
                );
              }
            },
            tooltip: 'Ayarlar',
          ),
        ],
      ),
      body: Stack(
        children: [
          Column(
            children: [
              Expanded(
                child: SingleChildScrollView(
                  padding: AppTheme.pagePadding,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      // Başlık
                      _buildHeader(),
                      
                      const SizedBox(height: AppTheme.largeSpacing),
                      
                      // Demo mode uyarısı
                      if (Constants.isDemoMode) _buildDemoWarning(),
                      
                      const SizedBox(height: AppTheme.largeSpacing),
                      
                      // Seçenekler
                      _buildOptionCard(
                        icon: Icons.photo_library,
                        title: 'Ekran Görüntüsü Yükle',
                        subtitle: 'WhatsApp, Instagram konuşması',
                        color: AppTheme.accentColor,
                        onTap: () => _pickImageAndExtractText(fromCamera: false),
                      ),
                      
                      const SizedBox(height: AppTheme.defaultSpacing),
                      
                      _buildOptionCard(
                        icon: Icons.camera_alt,
                        title: 'Fotoğraf Çek',
                        subtitle: 'Kamera ile çek ve analiz et',
                        color: AppTheme.infoColor,
                        onTap: () => _pickImageAndExtractText(fromCamera: true),
                      ),
                      
                      const SizedBox(height: AppTheme.defaultSpacing),
                      
                      _buildOptionCard(
                        icon: Icons.mic,
                        title: 'Sesli Kayıt',
                        subtitle: 'Mikrofon ile anlatın',
                        color: Colors.red,
                        onTap: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) => const VoiceInputScreen(),
                            ),
                          );
                        },
                      ),
                      
                      const SizedBox(height: AppTheme.defaultSpacing),
                      
                      _buildOptionCard(
                        icon: Icons.compare_arrows,
                        title: 'Karşılaştırma Modu',
                        subtitle: 'Aynı davayı farklı jürilerle analiz et',
                        color: Colors.purple,
                        onTap: _showComparisonDialog,
                      ),
                      
                      const SizedBox(height: AppTheme.defaultSpacing),
                      
_buildOptionCard(
                        icon: Icons.edit_note,
                        title: 'Metin Olarak Yaz',
                        subtitle: 'Tartışmayı elle gir',
                        color: AppTheme.warningColor,
                        onTap: _showTextInputDialog,
                      ),
                      
                      const SizedBox(height: AppTheme.largeSpacing),
                    ],
                  ),
                ),
            ),
          ],
        ),
        
        // Loading overlay
        if (_isLoading)
          Container(
            color: Colors.black87,
            child: Center(
              child: Card(
                color: AppTheme.primaryColor,
                elevation: 8,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Padding(
                  padding: const EdgeInsets.all(32),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      const CircularProgressIndicator(
                        color: AppTheme.accentColor,
                        strokeWidth: 4,
                      ),
                      const SizedBox(height: 20),
                      Text(
                        'Görüntü taranıyor...',
                        style: Theme.of(context).textTheme.titleLarge?.copyWith(
                          color: AppTheme.textPrimary,
                        ),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        'Metin çıkarılıyor ve analiz için hazırlanıyor',
                        style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                          color: AppTheme.textSecondary,
                        ),
                        textAlign: TextAlign.center,
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
      ],
    ),
  );
}

  Widget _buildHeader() {
    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            AppTheme.primaryColor,
            AppTheme.secondaryColor,
          ],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(AppTheme.cardRadius),
        border: Border.all(
          color: AppTheme.accentColor.withValues(alpha: 0.3),
          width: 2,
        ),
      ),
      child: Column(
        children: [
          const Text(
            '⚖️',
            style: TextStyle(fontSize: 64),
          ),
          const SizedBox(height: 12),
          Text(
            'Kim Haklı?',
            style: Theme.of(context).textTheme.displayMedium,
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 8),
          Text(
            'Yapay zeka ile tartışmanızı analiz edin\nve tarafsız karar alın',
            style: Theme.of(context).textTheme.bodyMedium,
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 16),
          _buildLevelIndicator(),
        ],
      ),
    );
  }

  Widget _buildLevelIndicator() {
    final stats = _gamification.getStats();
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.15),
        borderRadius: BorderRadius.circular(16),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceAround,
        children: [
          _levelItem('📊', '${stats['level']}', 'Seviye'),
          _levelItem('⚡', '${stats['points']}', 'Puan'),
          _levelItem('🔥', '${stats['streak']}', 'Seri'),
          _levelItem('🏆', '${stats['totalCases']}', 'Dava'),
        ],
      ),
    );
  }

  Widget _levelItem(String icon, String value, String label) {
    return Column(
      children: [
        Text(icon, style: const TextStyle(fontSize: 20)),
        Text(
          value,
          style: const TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.bold,
            color: Colors.white,
          ),
        ),
        Text(
          label,
          style: const TextStyle(
            fontSize: 10,
            color: Colors.white70,
          ),
        ),
      ],
    );
  }

  Widget _buildDemoWarning() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppTheme.warningColor.withValues(alpha: 0.2),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppTheme.warningColor),
      ),
      child: Row(
        children: [
          const Icon(Icons.warning, color: AppTheme.warningColor),
          const SizedBox(width: 12),
          Expanded(
            child: Text(
              'DEMO MODU: OpenAI API anahtarı eklenmemiş. Örnek kararlar gösterilecek.',
              style: TextStyle(
                color: AppTheme.textPrimary,
                fontSize: 13,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildOptionCard({
    required IconData icon,
    required String title,
    required String subtitle,
    required Color color,
    required VoidCallback onTap,
  }) {
    return Card(
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(AppTheme.cardRadius),
        child: Padding(
          padding: AppTheme.cardPadding,
          child: Row(
            children: [
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: color.withValues(alpha: 0.2),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Icon(
                  icon,
                  size: AppSizes.largeIconSize,
                  color: color,
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      title,
                      style: Theme.of(context).textTheme.titleLarge,
                    ),
                    const SizedBox(height: 4),
                    Text(
                      subtitle,
                      style: Theme.of(context).textTheme.bodyMedium,
                    ),
                  ],
                ),
              ),
              const Icon(
                Icons.arrow_forward_ios,
                color: AppTheme.textTertiary,
                size: 20,
              ),
            ],
          ),
        ),
      ),
    );
  }
}
