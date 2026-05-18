import 'package:flutter/material.dart';
import '../models/karar.dart';
import '../models/juri_type.dart';
import '../services/ai_service.dart';
import '../utils/theme.dart';
import 'package:shimmer/shimmer.dart';

/// Farklı jürilerle karşılaştırma ekranı
class ComparisonScreen extends StatefulWidget {
  final String davaMetni;
  final List<JuriType> selectedJuries;

  const ComparisonScreen({
    super.key,
    required this.davaMetni,
    required this.selectedJuries,
  });

  @override
  State<ComparisonScreen> createState() => _ComparisonScreenState();
}

class _ComparisonScreenState extends State<ComparisonScreen> {
  final _aiService = AIService();
  final Map<String, Karar?> _results = {};
  final Map<String, bool> _loading = {};
  final Map<String, String?> _errors = {};

  @override
  void initState() {
    super.initState();
    _analyzeAll();
  }

  Future<void> _analyzeAll() async {
    // Tüm jüriler için loading state'ini ayarla
    for (final jury in widget.selectedJuries) {
      setState(() {
        _loading[jury.id] = true;
        _results[jury.id] = null;
        _errors[jury.id] = null;
      });
    }

    // Tüm analizleri paralel çalıştır (skipRateLimit ile rate limiter'ı atla)
    await Future.wait(
      widget.selectedJuries.map((jury) async {
        try {
          final karar = await _aiService.analyzeText(
            metin: widget.davaMetni,
            juriTipiId: jury.id,
            skipRateLimit: true, // Karşılaştırma modu: rate limit yok
          );
          if (mounted && karar != null) {
            setState(() {
              _results[jury.id] = karar;
              _loading[jury.id] = false;
            });
          }
        } catch (e) {
          if (mounted) {
            setState(() {
              _errors[jury.id] = e.toString();
              _loading[jury.id] = false;
            });
          }
        }
      }),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Jüri Karşılaştırması'),
        centerTitle: true,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Dava metni özeti
            Card(
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'Dava Metni',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      widget.davaMetni.length > 200
                          ? '${widget.davaMetni.substring(0, 200)}...'
                          : widget.davaMetni,
                      style: TextStyle(
                        color: Theme.of(context).textTheme.bodyMedium?.color,
                        fontSize: 14,
                      ),
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 24),

            // Karşılaştırma başlığı
            const Text(
              'Jüri Kararları',
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 16),

            // Jüri kartları
            ...widget.selectedJuries.map((jury) => _buildJuryCard(jury)),

            const SizedBox(height: 24),

            // Karşılaştırma özeti
            if (_allCompleted) _buildComparisonSummary(),
          ],
        ),
      ),
    );
  }

  bool get _allCompleted {
    return widget.selectedJuries.every((jury) => 
      _results[jury.id] != null || _errors[jury.id] != null
    );
  }

  Widget _buildJuryCard(JuriType jury) {
    final isLoading = _loading[jury.id] ?? false;
    final result = _results[jury.id];
    final error = _errors[jury.id];

    return Card(
      margin: const EdgeInsets.only(bottom: 16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Jüri başlığı
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: jury.color.withValues(alpha: 0.1),
              borderRadius: const BorderRadius.only(
                topLeft: Radius.circular(12),
                topRight: Radius.circular(12),
              ),
            ),
            child: Row(
              children: [
                Text(
                  jury.emoji,
                  style: const TextStyle(fontSize: 32),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        jury.name,
                        style: const TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      Text(
                        jury.description,
                        style: TextStyle(
                          fontSize: 12,
                          color: Theme.of(context).textTheme.bodySmall?.color,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),

          // İçerik
          Padding(
            padding: const EdgeInsets.all(16),
            child: isLoading
                ? _buildLoadingState()
                : error != null
                    ? _buildErrorState(error)
                    : result != null
                        ? _buildResultState(result)
                        : const SizedBox.shrink(),
          ),
        ],
      ),
    );
  }

  Widget _buildLoadingState() {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return Shimmer.fromColors(
      baseColor: isDark ? Colors.grey[800]! : Colors.grey[300]!,
      highlightColor: isDark ? Colors.grey[600]! : Colors.grey[100]!,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            height: 20,
            width: double.infinity,
            decoration: BoxDecoration(
              color: isDark ? Colors.grey[900] : Colors.white,
              borderRadius: BorderRadius.circular(4),
            ),
          ),
          const SizedBox(height: 8),
          Container(
            height: 20,
            width: 200,
            decoration: BoxDecoration(
              color: isDark ? Colors.grey[900] : Colors.white,
              borderRadius: BorderRadius.circular(4),
            ),
          ),
          const SizedBox(height: 16),
          Container(
            height: 60,
            width: double.infinity,
            decoration: BoxDecoration(
              color: isDark ? Colors.grey[900] : Colors.white,
              borderRadius: BorderRadius.circular(4),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildErrorState(String error) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: isDark ? Colors.red.shade900.withValues(alpha: 0.3) : Colors.red.shade50,
        borderRadius: BorderRadius.circular(8),
      ),
      child: Row(
        children: [
          Icon(Icons.error_outline, color: isDark ? Colors.red.shade300 : Colors.red[700]),
          const SizedBox(width: 12),
          Expanded(
            child: Text(
              'Analiz başarısız: $error',
              style: TextStyle(color: isDark ? Colors.red.shade200 : Colors.red[900]),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildResultState(Karar karar) {
    final Color kararRengi = karar.haksizlikOrani <= 30
        ? AppTheme.successColor
        : karar.haksizlikOrani <= 50
            ? AppTheme.warningColor
            : AppTheme.errorColor;
    final gerekceBg = Theme.of(context).brightness == Brightness.dark
        ? AppTheme.secondaryColor
        : Colors.grey[100]!;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Haksızlık oranı
        Row(
          children: [
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
              decoration: BoxDecoration(
                color: kararRengi.withValues(alpha: 0.2),
                borderRadius: BorderRadius.circular(20),
              ),
              child: Text(
                '% ${karar.haksizlikOrani} Haksızlık',
                style: TextStyle(
                  color: kararRengi,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
            const Spacer(),
            Text(
              karar.hakliKisi,
              style: const TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.bold,
              ),
            ),
          ],
        ),
        const SizedBox(height: 12),

        // Gerekçe
        Container(
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            color: gerekceBg,
            borderRadius: BorderRadius.circular(8),
          ),
          child: Text(
            karar.gerekce,
            style: TextStyle(
              fontSize: 14,
              color: Theme.of(context).textTheme.bodyLarge?.color,
            ),
          ),
        ),
        const SizedBox(height: 8),

        // Ceza
        if (karar.ceza.isNotEmpty && karar.ceza != 'Yok')
          Row(
            children: [
              Icon(Icons.gavel, size: 16, color: Theme.of(context).textTheme.bodySmall?.color),
              const SizedBox(width: 4),
              Expanded(
                child: Text(
                  karar.ceza,
                  style: TextStyle(
                    fontSize: 13,
                    color: Theme.of(context).textTheme.bodyMedium?.color,
                  ),
                ),
              ),
            ],
          ),
      ],
    );
  }

  Widget _buildComparisonSummary() {
    // Başarılı sonuçları al
    final successfulResults = widget.selectedJuries
        .where((jury) => _results[jury.id] != null)
        .toList();

    if (successfulResults.isEmpty) {
      return const SizedBox.shrink();
    }

    // İstatistikler hesapla
    final results = successfulResults.map((j) => _results[j.id]!).toList();
    final avgHaksizlik = results
        .map((r) => r.haksizlikOrani)
        .reduce((a, b) => a + b) / results.length;

    // En sert ve en yumuşak jürileri bul
    final sortedByHaksizlik = [...successfulResults]
      ..sort((a, b) => (_results[b.id]?.haksizlikOrani ?? 0)
          .compareTo(_results[a.id]?.haksizlikOrani ?? 0));

    final mostStrict = sortedByHaksizlik.first;
    final leastStrict = sortedByHaksizlik.last;

    final isDark = Theme.of(context).brightness == Brightness.dark;
    return Card(
      color: isDark ? AppTheme.secondaryColor : AppTheme.infoColor.withValues(alpha: 0.1),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(Icons.analytics, color: AppTheme.infoColor),
                const SizedBox(width: 8),
                const Text(
                  'Karşılaştırma Özeti',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: AppTheme.textPrimary,
                  ),
                ),
              ],
            ),
            const Divider(height: 24),

            // Ortalama haksızlık
            _buildSummaryRow(
              '📊 Ortalama Haksızlık Oranı',
              '% ${avgHaksizlik.toStringAsFixed(1)}',
            ),
            const SizedBox(height: 12),

            // En sert jüri
            _buildSummaryRow(
              '⚖️ En Sert Jüri',
              '${mostStrict.emoji} ${mostStrict.name} (% ${_results[mostStrict.id]?.haksizlikOrani})',
            ),
            const SizedBox(height: 12),

            // En yumuşak jüri
            _buildSummaryRow(
              '🤝 En Yumuşak Jüri',
              '${leastStrict.emoji} ${leastStrict.name} (% ${_results[leastStrict.id]?.haksizlikOrani})',
            ),

            if (results.length >= 3) ...[
              const SizedBox(height: 12),
              _buildSummaryRow(
                '📈 Fikir Birliği',
                _getConsensusLevel(results),
              ),
            ],
          ],
        ),
      ),
    );
  }

  Widget _buildSummaryRow(String label, String value) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Expanded(
          flex: 2,
          child: Text(
            label,
            style: TextStyle(
              fontSize: 14,
              color: Theme.of(context).textTheme.bodyMedium?.color,
            ),
          ),
        ),
        Expanded(
          flex: 3,
          child: Text(
            value,
            style: TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.w600,
              color: Theme.of(context).textTheme.bodyLarge?.color,
            ),
          ),
        ),
      ],
    );
  }

  String _getConsensusLevel(List<Karar> results) {
    final oranlar = results.map((r) => r.haksizlikOrani).toList()..sort();
    final range = oranlar.last - oranlar.first;

    if (range <= 10) return 'Çok Yüksek (±$range)';
    if (range <= 20) return 'Yüksek (±$range)';
    if (range <= 30) return 'Orta (±$range)';
    return 'Düşük (±$range)';
  }
}
