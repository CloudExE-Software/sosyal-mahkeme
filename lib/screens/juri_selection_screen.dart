import 'package:flutter/material.dart';
import '../models/juri_type.dart';
import '../utils/theme.dart';
import '../utils/page_transitions.dart';
import 'analysis_screen.dart';

/// Jüri Seçim Ekranı
class JuriSelectionScreen extends StatefulWidget {
  final String davaMetni;

  const JuriSelectionScreen({
    super.key,
    required this.davaMetni,
  });

  @override
  State<JuriSelectionScreen> createState() => _JuriSelectionScreenState();
}

class _JuriSelectionScreenState extends State<JuriSelectionScreen> {
  String? selectedJuriId;

  /// Jüri seçimi ve analize gönder
  void _selectJuryAndProceed(JuriType jury) {
    _proceedToAnalysis(jury.id);
  }

  /// Analize devam et
  void _proceedToAnalysis(String juriId) {
    Navigator.push(
      context,
      PageTransitions.sharedAxisTransition(
        AnalysisScreen(
          davaMetni: widget.davaMetni,
          juriTipiId: juriId,
        ),
        duration: const Duration(milliseconds: 400),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Jüri Seçin'),
      ),
      body: SingleChildScrollView(
        padding: AppTheme.pagePadding,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // Bilgi kartı
            _buildInfoCard(),
            
            const SizedBox(height: AppTheme.largeSpacing),
            
            // Jüri kartları
            ...JuriType.getAllJuries().map((jury) => Padding(
              padding: const EdgeInsets.only(bottom: AppTheme.defaultSpacing),
              child: _buildJuryCard(jury),
            )),
          ],
        ),
      ),
    );
  }

  Widget _buildInfoCard() {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            AppTheme.accentColor.withValues(alpha: 0.3),
            AppTheme.infoColor.withValues(alpha: 0.3),
          ],
        ),
        borderRadius: BorderRadius.circular(AppTheme.cardRadius),
        border: Border.all(
          color: AppTheme.accentColor.withValues(alpha: 0.5),
        ),
      ),
      child: Column(
        children: [
          const Icon(
            Icons.gavel,
            size: 48,
            color: AppTheme.accentColor,
          ),
          const SizedBox(height: 12),
          Text(
            'Kimin Karar Vermesini İstersiniz?',
            style: Theme.of(context).textTheme.titleLarge,
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 8),
          Text(
            'Farklı jüri tipleri farklı yorumlar yapar. Size en uygun olanı seçin!',
            style: Theme.of(context).textTheme.bodyMedium,
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }

  Widget _buildJuryCard(JuriType jury) {
    final bool isSelected = selectedJuriId == jury.id;

    return Card(
      elevation: isSelected ? 8 : 4,
      child: InkWell(
        onTap: () => _selectJuryAndProceed(jury),
        borderRadius: BorderRadius.circular(AppTheme.cardRadius),
        child: Container(
          padding: AppTheme.cardPadding,
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(AppTheme.cardRadius),
            border: isSelected
                ? Border.all(color: AppTheme.accentColor, width: 2)
                : null,
            gradient: jury.isPremium
                ? LinearGradient(
                    colors: [
                      AppTheme.goldColor.withValues(alpha: 0.1),
                      AppTheme.goldColor.withValues(alpha: 0.05),
                    ],
                  )
                : null,
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  // İkon
                  Hero(
                    tag: 'jury_${jury.id}',
                    child: Container(
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        color: jury.isPremium
                            ? AppTheme.goldColor.withValues(alpha: 0.2)
                            : AppTheme.accentColor.withValues(alpha: 0.2),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Text(
                        jury.icon,
                        style: const TextStyle(fontSize: 32),
                      ),
                    ),
                  ),
                  
                  const SizedBox(width: 16),
                  
                  // İsim ve açıklama
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            Expanded(
                              child: Text(
                                jury.name,
                                style: const TextStyle(
                                  color: AppTheme.textPrimary,
                                  fontSize: 18,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ),
                            if (jury.isPremium)
                              Container(
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 8,
                                  vertical: 4,
                                ),
                                decoration: BoxDecoration(
                                  color: AppTheme.goldColor,
                                  borderRadius: BorderRadius.circular(12),
                                ),
                                child: const Text(
                                  'PRO',
                                  style: TextStyle(
                                    color: Colors.black,
                                    fontSize: 10,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                              ),
                          ],
                        ),
                        const SizedBox(height: 6),
                        Text(
                          jury.description,
                          style: Theme.of(context).textTheme.bodyMedium,
                        ),
                      ],
                    ),
                  ),
                  
                  // Ok ikonu
                  const Icon(
                    Icons.arrow_forward_ios,
                    color: AppTheme.textTertiary,
                    size: 20,
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}
