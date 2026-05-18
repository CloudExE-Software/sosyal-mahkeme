import 'package:flutter/material.dart';
import '../models/juri_type.dart';
import '../utils/theme.dart';
import 'comparison_screen.dart';
import '../utils/page_transitions.dart';

/// Karşılaştırma için jüri seçim ekranı
class ComparisonJurySelectionScreen extends StatefulWidget {
  final String davaMetni;

  const ComparisonJurySelectionScreen({
    super.key,
    required this.davaMetni,
  });

  @override
  State<ComparisonJurySelectionScreen> createState() =>
      _ComparisonJurySelectionScreenState();
}

class _ComparisonJurySelectionScreenState
    extends State<ComparisonJurySelectionScreen> {
  final Set<String> _selectedJuryIds = {};

  void _toggleJury(String juryId) {
    setState(() {
      if (_selectedJuryIds.contains(juryId)) {
        _selectedJuryIds.remove(juryId);
      } else {
        _selectedJuryIds.add(juryId);
      }
    });
  }

  void _startComparison() {
    if (_selectedJuryIds.length < 2) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('En az 2 jüri seçmelisiniz'),
          backgroundColor: Colors.orange,
        ),
      );
      return;
    }

    if (_selectedJuryIds.length > 5) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('En fazla 5 jüri seçebilirsiniz'),
          backgroundColor: Colors.orange,
        ),
      );
      return;
    }

    final selectedJuries = JuriType.allJuries
        .where((jury) => _selectedJuryIds.contains(jury.id))
        .toList();

    Navigator.push(
      context,
      PageTransitions.slideFromRight(
        ComparisonScreen(
          davaMetni: widget.davaMetni,
          selectedJuries: selectedJuries,
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Jüri Seçimi'),
        centerTitle: true,
      ),
      body: Column(
        children: [
          // Bilgi kartı
          Container(
            margin: const EdgeInsets.all(16),
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [
                  AppTheme.infoColor.withValues(alpha: 0.15),
                  AppTheme.accentColor.withValues(alpha: 0.15),
                ],
              ),
              borderRadius: BorderRadius.circular(12),
              border: Border.all(
                color: AppTheme.infoColor.withValues(alpha: 0.3),
              ),
            ),
            child: Column(
              children: [
                Row(
                  children: [
                    Icon(Icons.compare_arrows, color: AppTheme.accentColor),
                    const SizedBox(width: 8),
                    const Expanded(
                      child: Text(
                        'Karşılaştırma Modu',
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                          color: AppTheme.textPrimary,
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 8),
                Text(
                  'Aynı davayı farklı jürilerin bakış açısından değerlendirin. 2-5 arası jüri seçebilirsiniz.',
                  style: TextStyle(
                    fontSize: 14,
                    color: AppTheme.textSecondary,
                  ),
                ),
                const SizedBox(height: 12),
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    _buildCounterChip(
                      '${_selectedJuryIds.length}',
                      'Seçildi',
                      _selectedJuryIds.isEmpty
                          ? Colors.grey
                          : Colors.green,
                    ),
                    const SizedBox(width: 12),
                    _buildCounterChip(
                      '${JuriType.allJuries.length - _selectedJuryIds.length}',
                      'Kaldı',
                      AppTheme.infoColor,
                    ),
                  ],
                ),
              ],
            ),
          ),

          // Jüri listesi
          Expanded(
            child: ListView.builder(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              itemCount: JuriType.allJuries.length,
              itemBuilder: (context, index) {
                final jury = JuriType.allJuries[index];
                final isSelected = _selectedJuryIds.contains(jury.id);

                return _buildJuryTile(jury, isSelected);
              },
            ),
          ),

          // Karşılaştır butonu
          SafeArea(
            child: Container(
              width: double.infinity,
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: AppTheme.primaryColor,
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withValues(alpha: 0.3),
                    blurRadius: 8,
                    offset: const Offset(0, -2),
                  ),
                ],
              ),
              child: ElevatedButton(
                onPressed: _selectedJuryIds.length >= 2 ? _startComparison : null,
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppTheme.accentColor,
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                  disabledBackgroundColor: AppTheme.textTertiary.withValues(alpha: 0.3),
                ),
                child: Text(
                  _selectedJuryIds.isEmpty
                      ? 'Jüri Seçin (Min 2)'
                      : 'Karşılaştırmayı Başlat (${_selectedJuryIds.length})',
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildCounterChip(String count, String label, Color color) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.2),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: color, width: 1.5),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(
            count,
            style: TextStyle(
              color: color,
              fontWeight: FontWeight.bold,
              fontSize: 16,
            ),
          ),
          const SizedBox(width: 4),
          Text(
            label,
            style: TextStyle(
              color: color,
              fontSize: 12,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildJuryTile(JuriType jury, bool isSelected) {
    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      elevation: isSelected ? 4 : 1,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
        side: BorderSide(
          color: isSelected ? jury.color : Colors.transparent,
          width: 2,
        ),
      ),
      child: InkWell(
        onTap: () => _toggleJury(jury.id),
        borderRadius: BorderRadius.circular(12),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Row(
            children: [
              // Checkbox
              AnimatedContainer(
                duration: const Duration(milliseconds: 200),
                width: 24,
                height: 24,
                decoration: BoxDecoration(
                  color: isSelected ? jury.color : Colors.transparent,
                  border: Border.all(
                    color: isSelected ? jury.color : Colors.grey,
                    width: 2,
                  ),
                  borderRadius: BorderRadius.circular(6),
                ),
                child: isSelected
                    ? const Icon(
                        Icons.check,
                        size: 16,
                        color: Colors.white,
                      )
                    : null,
              ),
              const SizedBox(width: 12),

              // Emoji
              Container(
                width: 50,
                height: 50,
                decoration: BoxDecoration(
                  color: jury.color.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(25),
                ),
                child: Center(
                  child: Text(
                    jury.emoji,
                    style: const TextStyle(fontSize: 28),
                  ),
                ),
              ),
              const SizedBox(width: 12),

              // Bilgiler
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      jury.name,
                      style: const TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      jury.description,
                      style: TextStyle(
                        fontSize: 13,
                        color: AppTheme.textSecondary,
                      ),
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ],
                ),
              ),

              // Seçim göstergesi
              if (isSelected)
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 8,
                    vertical: 4,
                  ),
                  decoration: BoxDecoration(
                    color: jury.color,
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: const Text(
                    '✓',
                    style: TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
            ],
          ),
        ),
      ),
    );
  }
}
