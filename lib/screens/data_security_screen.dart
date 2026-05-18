import 'package:flutter/material.dart';
import '../services/encryption_service.dart';
import 'package:shared_preferences/shared_preferences.dart';

/// Veri güvenliği ayarları ekranı
class DataSecurityScreen extends StatefulWidget {
  const DataSecurityScreen({super.key});

  @override
  State<DataSecurityScreen> createState() => _DataSecurityScreenState();
}

class _DataSecurityScreenState extends State<DataSecurityScreen> {
  final _encryption = EncryptionService();
  bool _isLoading = false;
  bool _isEncryptionEnabled = true; // Varsayılan olarak açık

  @override
  void initState() {
    super.initState();
    _checkEncryptionStatus();
  }

  Future<void> _checkEncryptionStatus() async {
    setState(() => _isLoading = true);
    
    try {
      await _encryption.initialize();
      // Encryption her zaman aktif, bu sadece UI için
      setState(() => _isEncryptionEnabled = true);
    } catch (e) {
      setState(() => _isEncryptionEnabled = false);
    } finally {
      setState(() => _isLoading = false);
    }
  }

  Future<void> _resetEncryptionKeys() async {
    final confirm = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Şifreleme Anahtarlarını Sıfırla'),
        content: const Text(
          'Bu işlem yeni şifreleme anahtarları oluşturacak ve mevcut verilerinizi temizleyecek. '
          'Bu işlem geri alınamaz!\n\n'
          'Devam etmek istiyor musunuz?',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('İptal'),
          ),
          ElevatedButton(
            onPressed: () => Navigator.pop(context, true),
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.red,
            ),
            child: const Text('Sıfırla'),
          ),
        ],
      ),
    );

    if (confirm != true) return;

    setState(() => _isLoading = true);

    try {
      // Reset local storage encryption keys
      final prefs = await SharedPreferences.getInstance();
      await prefs.clear(); // Clear all local data
      await _encryption.initialize();
      
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('✓ Şifreleme anahtarları sıfırlandı'),
            backgroundColor: Colors.green,
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('✗ Hata: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    } finally {
      setState(() => _isLoading = false);
    }
  }

  Future<void> _clearSecureStorage() async {
    final confirm = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Güvenli Depolamayı Temizle'),
        content: const Text(
          'Tüm güvenli depolama verileriniz silinecek. '
          'Bu işlem geri alınamaz!\n\n'
          'Devam etmek istiyor musunuz?',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('İptal'),
          ),
          ElevatedButton(
            onPressed: () => Navigator.pop(context, true),
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.red,
            ),
            child: const Text('Temizle'),
          ),
        ],
      ),
    );

    if (confirm != true) return;

    setState(() => _isLoading = true);

    try {
      await _encryption.clearSecureStorage();
      
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('✓ Güvenli depolama temizlendi'),
            backgroundColor: Colors.green,
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('✗ Hata: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    } finally {
      setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Veri Güvenliği'),
        centerTitle: true,
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : ListView(
              padding: const EdgeInsets.all(16),
              children: [
                _buildSecurityStatusCard(),
                const SizedBox(height: 16),
                _buildInfoCard(),
                const SizedBox(height: 24),
                _buildFeaturesCard(),
                const SizedBox(height: 24),
                _buildDangerZone(),
              ],
            ),
    );
  }

  Widget _buildSecurityStatusCard() {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(
                  _isEncryptionEnabled ? Icons.lock : Icons.lock_open,
                  color: _isEncryptionEnabled ? Colors.green : Colors.red,
                  size: 32,
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        _isEncryptionEnabled ? 'Şifreleme Aktif' : 'Şifreleme Devre Dışı',
                        style: const TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      Text(
                        'Verileriniz AES-256 ile korunuyor',
                        style: TextStyle(
                          fontSize: 13,
                          color: Colors.grey[600],
                        ),
                      ),
                    ],
                  ),
                ),
                Icon(
                  Icons.verified_user,
                  color: Colors.green[700],
                  size: 28,
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildInfoCard() {
    return Card(
      color: Colors.blue.shade50,
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(Icons.info_outline, color: Colors.blue[700]),
                const SizedBox(width: 8),
                const Text(
                  'Veri Şifreleme Nedir?',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            _buildInfoRow('Tüm hassas verileriniz şifrelenir'),
            _buildInfoRow('Geçmiş kararlarınız güvenli bir şekilde saklanır'),
            _buildInfoRow('256-bit AES şifreleme standardı kullanılır'),
            _buildInfoRow('Şifreleme anahtarları cihazınızda güvenli depolama alanında saklanır'),
            _buildInfoRow('Kimse verilerinize erişemez (siz dahil, şifre kaybolursa)'),
          ],
        ),
      ),
    );
  }

  Widget _buildInfoRow(String text) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text('• ', style: TextStyle(fontSize: 16)),
          Expanded(
            child: Text(
              text,
              style: TextStyle(fontSize: 14, color: Colors.grey[700]),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildFeaturesCard() {
    return Card(
      child: Column(
        children: [
          _buildFeatureTile(
            icon: Icons.history,
            title: 'Geçmiş Şifreleme',
            subtitle: 'Tüm kararlar şifreli saklanır',
            color: Colors.purple,
          ),
          const Divider(height: 1),
          _buildFeatureTile(
            icon: Icons.favorite,
            title: 'Favori Koruması',
            subtitle: 'Favoriler güvenli depoda',
            color: Colors.pink,
          ),
          const Divider(height: 1),
          _buildFeatureTile(
            icon: Icons.vpn_key,
            title: 'Anahtar Yönetimi',
            subtitle: 'Otomatik anahtar oluşturma',
            color: Colors.orange,
          ),
          const Divider(height: 1),
          _buildFeatureTile(
            icon: Icons.verified,
            title: 'Veri Bütünlüğü',
            subtitle: 'Hash kontrolü ile doğrulama',
            color: Colors.green,
          ),
        ],
      ),
    );
  }

  Widget _buildFeatureTile({
    required IconData icon,
    required String title,
    required String subtitle,
    required Color color,
  }) {
    return ListTile(
      leading: Container(
        padding: const EdgeInsets.all(8),
        decoration: BoxDecoration(
          color: color.withValues(alpha: 0.1),
          borderRadius: BorderRadius.circular(8),
        ),
        child: Icon(icon, color: color),
      ),
      title: Text(
        title,
        style: const TextStyle(fontWeight: FontWeight.w600),
      ),
      subtitle: Text(subtitle),
      trailing: Icon(Icons.check_circle, color: Colors.green[700]),
    );
  }

  Widget _buildDangerZone() {
    return Card(
      color: Colors.red.shade50,
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(Icons.warning, color: Colors.red[700]),
                const SizedBox(width: 8),
                const Text(
                  'Tehlikeli İşlemler',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            
            // Şifreleme anahtarlarını sıfırla
            OutlinedButton.icon(
              onPressed: _isLoading ? null : _resetEncryptionKeys,
              icon: const Icon(Icons.refresh),
              label: const Text('Şifreleme Anahtarlarını Sıfırla'),
              style: OutlinedButton.styleFrom(
                foregroundColor: Colors.orange,
                side: const BorderSide(color: Colors.orange),
                minimumSize: const Size(double.infinity, 44),
              ),
            ),
            
            const SizedBox(height: 12),
            
            // Güvenli depolamayı temizle
            OutlinedButton.icon(
              onPressed: _isLoading ? null : _clearSecureStorage,
              icon: const Icon(Icons.delete_forever),
              label: const Text('Güvenli Depolamayı Temizle'),
              style: OutlinedButton.styleFrom(
                foregroundColor: Colors.red,
                side: const BorderSide(color: Colors.red),
                minimumSize: const Size(double.infinity, 44),
              ),
            ),
            
            const SizedBox(height: 12),
            
            Text(
              '⚠️ Bu işlemler geri alınamaz ve verilerinizi kaybetmenize neden olabilir!',
              style: TextStyle(
                fontSize: 12,
                color: Colors.red[900],
                fontStyle: FontStyle.italic,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
