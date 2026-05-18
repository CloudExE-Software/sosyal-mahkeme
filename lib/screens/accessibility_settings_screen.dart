import 'package:flutter/material.dart';
import '../services/accessibility_service.dart';
import '../utils/theme.dart';

class AccessibilitySettingsScreen extends StatefulWidget {
  const AccessibilitySettingsScreen({super.key});

  @override
  State<AccessibilitySettingsScreen> createState() =>
      _AccessibilitySettingsScreenState();
}

class _AccessibilitySettingsScreenState
    extends State<AccessibilitySettingsScreen> {
  final _accessibilityService = AccessibilityService();

  bool _voiceGuidanceEnabled = false;
  bool _highContrastEnabled = false;
  double _fontScale = 1.0;
  bool _reduceAnimations = false;
  double _ttsRate = 0.5;
  double _ttsPitch = 1.0;

  bool _loading = true;

  @override
  void initState() {
    super.initState();
    _loadSettings();
  }

  Future<void> _loadSettings() async {
    setState(() => _loading = true);

    _voiceGuidanceEnabled = _accessibilityService.voiceGuidanceEnabled;
    _highContrastEnabled = _accessibilityService.highContrastEnabled;
    _fontScale = _accessibilityService.fontScale;
    _reduceAnimations = _accessibilityService.reduceAnimations;

    setState(() => _loading = false);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Erişilebilirlik'),
        actions: [
          IconButton(
            icon: const Icon(Icons.volume_up),
            tooltip: 'Sesi Test Et',
            onPressed: _testTTS,
          ),
        ],
      ),
      body: _loading
          ? const Center(child: CircularProgressIndicator())
          : ListView(
              children: [
                _buildHeader(),
                const Divider(height: 32),
                _buildVoiceGuidanceSection(),
                const Divider(height: 32),
                _buildVisualSection(),
                const Divider(height: 32),
                _buildAnimationSection(),
                const SizedBox(height: 24),
              ],
            ),
    );
  }

  Widget _buildHeader() {
    return Container(
      margin: const EdgeInsets.all(16),
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            Colors.blue.withValues(alpha: 0.1),
            Colors.purple.withValues(alpha: 0.1),
          ],
        ),
        borderRadius: BorderRadius.circular(16),
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: Colors.blue.withValues(alpha: 0.2),
              borderRadius: BorderRadius.circular(12),
            ),
            child: const Icon(Icons.accessibility_new, size: 32, color: Colors.blue),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Erişilebilirlik',
                  style: Theme.of(context).textTheme.titleLarge?.copyWith(
                        fontWeight: FontWeight.bold,
                      ),
                ),
                const SizedBox(height: 4),
                Text(
                  'Uygulamayı herkes için erişilebilir yapın',
                  style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                        color: Colors.grey[600],
                      ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildVoiceGuidanceSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16),
          child: Text(
            'Sesli Rehber',
            style: Theme.of(context).textTheme.titleMedium?.copyWith(
                  fontWeight: FontWeight.bold,
                  color: AppTheme.primaryColor,
                ),
          ),
        ),
        const SizedBox(height: 8),
        SwitchListTile(
          title: const Text('Sesli Rehberi Etkinleştir'),
          subtitle: const Text('Ekran içeriğini sesli okur'),
          secondary: const Icon(Icons.record_voice_over),
          value: _voiceGuidanceEnabled,
          onChanged: (value) async {
            setState(() => _voiceGuidanceEnabled = value);
            await _accessibilityService.setVoiceGuidanceEnabled(value);
            
            if (value) {
              await _accessibilityService.speak('Sesli rehber etkinleştirildi');
            }

            if (mounted) {
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Text(
                    value ? 'Sesli rehber açıldı' : 'Sesli rehber kapatıldı',
                  ),
                ),
              );
            }
          },
        ),
        if (_voiceGuidanceEnabled) ...[
          ListTile(
            leading: const Icon(Icons.speed),
            title: const Text('Konuşma Hızı'),
            subtitle: Slider(
              value: _ttsRate,
              min: 0.1,
              max: 1.0,
              divisions: 9,
              label: _ttsRate.toStringAsFixed(1),
              onChanged: (value) async {
                setState(() => _ttsRate = value);
                await _accessibilityService.setTtsRate(value);
              },
            ),
          ),
          ListTile(
            leading: const Icon(Icons.graphic_eq),
            title: const Text('Ses Tonu'),
            subtitle: Slider(
              value: _ttsPitch,
              min: 0.5,
              max: 2.0,
              divisions: 15,
              label: _ttsPitch.toStringAsFixed(1),
              onChanged: (value) async {
                setState(() => _ttsPitch = value);
                await _accessibilityService.setTtsPitch(value);
              },
            ),
          ),
        ],
      ],
    );
  }

  Widget _buildVisualSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16),
          child: Text(
            'Görsel Ayarlar',
            style: Theme.of(context).textTheme.titleMedium?.copyWith(
                  fontWeight: FontWeight.bold,
                  color: AppTheme.primaryColor,
                ),
          ),
        ),
        const SizedBox(height: 8),
        SwitchListTile(
          title: const Text('Yüksek Kontrast'),
          subtitle: const Text('Renkleri daha belirgin yapar'),
          secondary: const Icon(Icons.contrast),
          value: _highContrastEnabled,
          onChanged: (value) async {
            setState(() => _highContrastEnabled = value);
            await _accessibilityService.setHighContrastEnabled(value);
            
            if (mounted) {
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Text(
                    value ? 'Yüksek kontrast açıldı' : 'Yüksek kontrast kapatıldı',
                  ),
                ),
              );
            }
          },
        ),
        ListTile(
          leading: const Icon(Icons.text_fields),
          title: const Text('Yazı Boyutu'),
          subtitle: Text(
            _accessibilityService.getFontScaleLabel(_fontScale),
          ),
          trailing: Text(
            '${(_fontScale * 100).toInt()}%',
            style: Theme.of(context).textTheme.titleMedium,
          ),
        ),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16),
          child: Slider(
            value: _fontScale,
            min: 0.7,
            max: 1.5,
            divisions: 8,
            label: '${(_fontScale * 100).toInt()}%',
            onChanged: (value) async {
              setState(() => _fontScale = value);
              await _accessibilityService.setFontScale(value);
            },
          ),
        ),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text('Küçük', style: TextStyle(fontSize: 12, color: Colors.grey[600])),
              Text('Orta', style: TextStyle(fontSize: 14, color: Colors.grey[600])),
              Text('Büyük', style: TextStyle(fontSize: 16, color: Colors.grey[600])),
            ],
          ),
        ),
        const SizedBox(height: 16),
        _buildPreviewText(),
      ],
    );
  }

  Widget _buildPreviewText() {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.grey[100],
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.grey[300]!),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Önizleme',
            style: Theme.of(context).textTheme.labelSmall?.copyWith(
                  color: Colors.grey[600],
                ),
          ),
          const SizedBox(height: 8),
          Text(
            'Bu bir örnek metindir. Yazı boyutunu test edebilirsiniz.',
            style: TextStyle(fontSize: 16 * _fontScale),
          ),
        ],
      ),
    );
  }

  Widget _buildAnimationSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16),
          child: Text(
            'Animasyonlar',
            style: Theme.of(context).textTheme.titleMedium?.copyWith(
                  fontWeight: FontWeight.bold,
                  color: AppTheme.primaryColor,
                ),
          ),
        ),
        const SizedBox(height: 8),
        SwitchListTile(
          title: const Text('Animasyonları Azalt'),
          subtitle: const Text('Görsel efektleri minimize eder'),
          secondary: const Icon(Icons.animation),
          value: _reduceAnimations,
          onChanged: (value) async {
            setState(() => _reduceAnimations = value);
            await _accessibilityService.setReduceAnimations(value);
            
            if (mounted) {
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Text(
                    value
                        ? 'Animasyonlar azaltıldı'
                        : 'Animasyonlar normale döndü',
                  ),
                ),
              );
            }
          },
        ),
      ],
    );
  }

  Future<void> _testTTS() async {
    await _accessibilityService.testTTS();
    
    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Test mesajı çalınıyor...'),
          duration: Duration(seconds: 2),
        ),
      );
    }
  }
}
