import 'package:flutter/material.dart';
import 'package:package_info_plus/package_info_plus.dart';
import '../utils/theme.dart';
import '../utils/constants.dart';
import '../services/user_preferences_service.dart';
import '../services/subscription_service.dart';
import '../services/history_service.dart';
import '../services/cache_service.dart';
import '../services/rate_limiter.dart';
import '../services/theme_service.dart';
import 'data_security_screen.dart';
import 'accessibility_settings_screen.dart';
import 'language_switcher_screen.dart';

/// Ayarlar ekranı
class SettingsScreen extends StatefulWidget {
  const SettingsScreen({super.key});

  @override
  State<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends State<SettingsScreen> {
  bool _showAds = Constants.showAds;
  String _version = '';
  int _historyCount = 0;
  int _cacheCount = 0;
  double _cacheSize = 0.0;
  int _totalRequests = 0;

  @override
  void initState() {
    super.initState();
    _showAds = UserPreferencesService().showAds;
    _loadSettings();
  }

  Future<void> _loadSettings() async {
    final packageInfo = await PackageInfo.fromPlatform();
    final historyCount = await HistoryService().getHistoryCount();
    final cacheCount = await CacheService().getCacheCount();
    final cacheSize = await CacheService().getCacheSize();
    final totalRequests = await RateLimiter().getTotalRequests();

    setState(() {
      _version = packageInfo.version;
      _historyCount = historyCount;
      _cacheCount = cacheCount;
      _cacheSize = cacheSize;
      _totalRequests = totalRequests;
    });
  }

  Future<void> _clearHistory() async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Geçmişi Temizle'),
        content: const Text('Tüm karar geçmişi silinecek. Emin misiniz?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('İptal'),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context, true),
            style: TextButton.styleFrom(foregroundColor: Colors.red),
            child: const Text('Temizle'),
          ),
        ],
      ),
    );

    if (confirmed == true) {
      await HistoryService().clearHistory();
      await _loadSettings();
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Geçmiş temizlendi')),
        );
      }
    }
  }

  Future<void> _clearCache() async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Önbelleği Temizle'),
        content: const Text('Tüm önbellek temizlenecek. Emin misiniz?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('İptal'),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context, true),
            style: TextButton.styleFrom(foregroundColor: Colors.red),
            child: const Text('Temizle'),
          ),
        ],
      ),
    );

    if (confirmed == true) {
      await CacheService().clearCache();
      await _loadSettings();
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Önbellek temizlendi')),
        );
      }
    }
  }

  Future<void> _resetAllData() async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Tüm Verileri Sıfırla'),
        content: const Text(
          'Geçmiş, önbellek, tercihler ve istatistikler silinecek.\n\n'
          'Bu işlem geri alınamaz. Emin misiniz?',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('İptal'),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context, true),
            style: TextButton.styleFrom(foregroundColor: Colors.red),
            child: const Text('Sıfırla'),
          ),
        ],
      ),
    );

    if (confirmed == true) {
      await HistoryService().clearHistory();
      await CacheService().clearCache();
      await RateLimiter().reset();
      await UserPreferencesService().clear();

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Tüm veriler sıfırlandı')),
        );
        // Ana ekrana geri dön ve uygulamayı yeniden başlat
        Navigator.of(context).popUntil((route) => route.isFirst);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Ayarlar'),
      ),
      body: ListView(
        children: [
          // Tema ayarları
          _buildSectionHeader('Görünüm'),
          _buildThemeTile(),

          const Divider(height: 32),

          // Genel ayarlar
          _buildSectionHeader('Genel'),
          _buildSwitchTile(
            title: 'Reklamları Göster',
            subtitle: 'Uygulamayı desteklemek için reklamları açın',
            value: _showAds,
            icon: Icons.ads_click,
            onChanged: (value) async {
              setState(() => _showAds = value);
              await UserPreferencesService().setShowAds(value);
            },
          ),

          const Divider(height: 32),

          // Premium & Abonelik
          _buildSectionHeader('Premium'),
          _buildPremiumStatus(),
          
          const Divider(height: 32),

          // Veri yönetimi
          _buildSectionHeader('Veri Yönetimi'),
          
          // Data Security
          ListTile(
            leading: const Icon(Icons.security),
            title: const Text('Veri Güvenliği'),
            subtitle: const Text('Şifreleme ve güvenlik ayarları'),
            trailing: const Icon(Icons.arrow_forward_ios, size: 16),
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => const DataSecurityScreen(),
                ),
              );
            },
          ),
          
          // İstatistikler - Using local storage only
          ListTile(
            leading: const Icon(Icons.analytics),
            title: const Text('İstatistikler'),
            subtitle: const Text('Kullanım metrikleri'),
            trailing: const Icon(Icons.arrow_forward_ios, size: 16),
            onTap: () {
              _showStatsDialog();
            },
          ),
          
          // Erişilebilirlik
          ListTile(
            leading: const Icon(Icons.accessibility_new),
            title: const Text('Erişilebilirlik'),
            subtitle: const Text('Sesli rehber ve görsel ayarlar'),
            trailing: const Icon(Icons.arrow_forward_ios, size: 16),
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => const AccessibilitySettingsScreen(),
                ),
              );
            },
          ),
          
          // Dil Seçimi
          ListTile(
            leading: const Icon(Icons.language),
            title: const Text('Dil'),
            subtitle: const Text('Uygulama dilini değiştir'),
            trailing: const Icon(Icons.arrow_forward_ios, size: 16),
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => const LanguageSwitcherScreen(),
                ),
              );
            },
          ),
          
          _buildInfoTile(
            title: 'Geçmiş Kararlar',
            subtitle: '$_historyCount karar',
            icon: Icons.history,
            trailing: IconButton(
              icon: const Icon(Icons.delete_outline, color: Colors.red),
              onPressed: _historyCount > 0 ? _clearHistory : null,
            ),
          ),
          _buildInfoTile(
            title: 'Önbellek',
            subtitle: '$_cacheCount öğe (${_cacheSize.toStringAsFixed(2)} MB)',
            icon: Icons.storage,
            trailing: IconButton(
              icon: const Icon(Icons.delete_outline, color: Colors.red),
              onPressed: _cacheCount > 0 ? _clearCache : null,
            ),
          ),

          const Divider(height: 32),

          // İstatistikler
          _buildSectionHeader('İstatistikler'),
          _buildInfoTile(
            title: 'Toplam Analiz',
            subtitle: '$_totalRequests analiz yapıldı',
            icon: Icons.analytics,
          ),
          _buildInfoTile(
            title: 'Cinsiyet',
            subtitle: _getGenderText(),
            icon: Icons.person,
          ),

          const Divider(height: 32),

          // Tehlikeli işlemler
          _buildSectionHeader('Tehlikeli Bölge'),
          _buildActionTile(
            title: 'Tüm Verileri Sıfırla',
            subtitle: 'Uygulama ilk açılış haline döner',
            icon: Icons.restore,
            color: Colors.red,
            onTap: _resetAllData,
          ),

          const Divider(height: 32),

          // Hakkında
          _buildSectionHeader('Hakkında'),
          _buildInfoTile(
            title: 'Versiyon',
            subtitle: _version.isNotEmpty ? 'v$_version' : 'Yükleniyor...',
            icon: Icons.info_outline,
          ),
          _buildInfoTile(
            title: 'Geliştirici',
            subtitle: 'Yapay Zeka Destekli Uygulama',
            icon: Icons.code,
          ),

          const SizedBox(height: 32),

          // Footer
          Padding(
            padding: const EdgeInsets.all(20),
            child: Text(
              'Haklı Kim ? - AI Tartışma Analizi\n'
              '© 2026 Tüm hakları saklıdır',
              textAlign: TextAlign.center,
              style: TextStyle(
                color: AppTheme.textTertiary,
                fontSize: 12,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSectionHeader(String title) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 16, 20, 8),
      child: Text(
        title,
        style: TextStyle(
          color: AppTheme.accentColor,
          fontSize: 13,
          fontWeight: FontWeight.bold,
          letterSpacing: 1.2,
        ),
      ),
    );
  }

  Widget _buildThemeTile() {
    return ValueListenableBuilder<ThemeMode>(
      valueListenable: ThemeService().themeModeNotifier,
      builder: (context, themeMode, child) {
        String themeText = 'Koyu Tema';
        IconData themeIcon = Icons.dark_mode;
        
        if (themeMode == ThemeMode.light) {
          themeText = 'Açık Tema';
          themeIcon = Icons.light_mode;
        } else if (themeMode == ThemeMode.system) {
          themeText = 'Sistem Teması';
          themeIcon = Icons.brightness_auto;
        }

        return ListTile(
          leading: Icon(themeIcon, color: AppTheme.accentColor),
          title: const Text('Tema'),
          subtitle: Text(themeText, style: const TextStyle(fontSize: 12)),
          trailing: PopupMenuButton<ThemeMode>(
            icon: const Icon(Icons.palette),
            onSelected: (ThemeMode mode) async {
              await ThemeService().setThemeMode(mode);
            },
            itemBuilder: (context) => [
              const PopupMenuItem(
                value: ThemeMode.light,
                child: Row(
                  children: [
                    Icon(Icons.light_mode),
                    SizedBox(width: 12),
                    Text('Açık Tema'),
                  ],
                ),
              ),
              const PopupMenuItem(
                value: ThemeMode.dark,
                child: Row(
                  children: [
                    Icon(Icons.dark_mode),
                    SizedBox(width: 12),
                    Text('Koyu Tema'),
                  ],
                ),
              ),
              const PopupMenuItem(
                value: ThemeMode.system,
                child: Row(
                  children: [
                    Icon(Icons.brightness_auto),
                    SizedBox(width: 12),
                    Text('Sistem Teması'),
                  ],
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildSwitchTile({
    required String title,
    required String subtitle,
    required bool value,
    required IconData icon,
    required ValueChanged<bool> onChanged,
  }) {
    return ListTile(
      leading: Icon(icon, color: AppTheme.accentColor),
      title: Text(title),
      subtitle: Text(subtitle, style: const TextStyle(fontSize: 12)),
      trailing: Switch(
        value: value,
        onChanged: onChanged,
        activeTrackColor: AppTheme.accentColor,
      ),
    );
  }

  Widget _buildPremiumStatus() {
  Widget _buildSubscriptionSection() {
    // Freemium model - tüm özellikler ücretsiz, premium kaldırıldı
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            AppTheme.successColor,
            AppTheme.successColor.withValues(alpha: 0.7),
          ],
        ),
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: AppTheme.successColor.withValues(alpha: 0.3),
            blurRadius: 8,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Row(
        children: [
          const Icon(
            Icons.celebration,
            size: 40,
            color: Colors.white,
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'Tüm Özellikler Ücretsiz',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  '11 jüri tipi, sınırsız analiz — hepsi ücretsiz!',
                  style: TextStyle(
                    color: Colors.white.withValues(alpha: 0.9),
                    fontSize: 13,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
  }

  Widget _buildInfoTile({
    required String title,
    required String subtitle,
    required IconData icon,
    Widget? trailing,
  }) {
    return ListTile(
      leading: Icon(icon, color: AppTheme.textSecondary),
      title: Text(title),
      subtitle: Text(subtitle, style: const TextStyle(fontSize: 12)),
      trailing: trailing,
    );
  }

  Widget _buildActionTile({
    required String title,
    required String subtitle,
    required IconData icon,
    required Color color,
    required VoidCallback onTap,
  }) {
    return ListTile(
      leading: Icon(icon, color: color),
      title: Text(title, style: TextStyle(color: color)),
      subtitle: Text(subtitle, style: const TextStyle(fontSize: 12)),
      trailing: Icon(Icons.arrow_forward_ios, size: 16, color: color),
      onTap: onTap,
    );
  }

  String _getGenderText() {
    final gender = UserPreferencesService().userGender;
    if (gender == 'female') return 'Kadın 👩';
    if (gender == 'male') return 'Erkek 👨';
    return 'Belirtilmemiş';
  }

  Future<void> _showStatsDialog() async {
    final history = HistoryService();
    final allHistory = await history.getHistory();
    
    if (!mounted) return;
    
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('📊 İstatistikler'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Toplam Dava: ${allHistory.length}'),
            const SizedBox(height: 8),
            const Text('Tüm veriler yerel olarak saklanır.'),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Tamam'),
          ),
        ],
      ),
    );
  }
}
