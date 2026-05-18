import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../models/karar.dart';
import '../utils/theme.dart';
import '../utils/constants.dart';

/// Mahkeme kararı sertifikası widget'ı (Screenshot için)
class CertificateWidget extends StatelessWidget {
  final Karar karar;

  const CertificateWidget({
    super.key,
    required this.karar,
  });

  Color get _kararRengi {
    if (karar.haksizlikOrani <= 30) return AppTheme.successColor;
    if (karar.haksizlikOrani <= 50) return AppTheme.warningColor;
    return AppTheme.errorColor;
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            AppTheme.backgroundColor,
            AppTheme.primaryColor,
            AppTheme.secondaryColor,
          ],
        ),
        borderRadius: BorderRadius.circular(AppTheme.cardRadius),
        border: Border.all(
          color: _kararRengi,
          width: 3,
        ),
        boxShadow: [
          BoxShadow(
            color: _kararRengi.withValues(alpha: 0.3),
            blurRadius: 20,
            spreadRadius: 2,
          ),
        ],
      ),
      child: Column(
        children: [
          // Üst başlık
          _buildHeader(),
          
          // Ana karar bölümü
          _buildMainVerdict(),
          
          // İstatistikler
          _buildStatistics(),
          
          // Hakim yorumu
          _buildJudgeComment(),
          
          // Alt bilgi
          _buildFooter(),
        ],
      ),
    );
  }

  Widget _buildHeader() {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 20, horizontal: 24),
      decoration: BoxDecoration(
        color: _kararRengi.withValues(alpha: 0.2),
        borderRadius: const BorderRadius.only(
          topLeft: Radius.circular(AppTheme.cardRadius - 3),
          topRight: Radius.circular(AppTheme.cardRadius - 3),
        ),
      ),
      child: Column(
        children: [
          const Text(
            'T.C.',
            style: TextStyle(
              color: AppTheme.textPrimary,
              fontSize: 14,
              fontWeight: FontWeight.w500,
              letterSpacing: 2,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            Constants.appName.toUpperCase(),
            style: const TextStyle(
              color: AppTheme.textPrimary,
              fontSize: 24,
              fontWeight: FontWeight.bold,
              letterSpacing: 3,
            ),
          ),
          const SizedBox(height: 4),
          const Text(
            'HAKLI KIM ?',
            style: TextStyle(
              color: AppTheme.textSecondary,
              fontSize: 12,
              letterSpacing: 2,
            ),
          ),
          const SizedBox(height: 16),
          const Text(
            '⚖️',
            style: TextStyle(fontSize: 48),
          ),
        ],
      ),
    );
  }

  Widget _buildMainVerdict() {
    return Padding(
      padding: const EdgeInsets.all(24),
      child: Column(
        children: [
          // HÜKÜM başlığı
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
            decoration: BoxDecoration(
              color: _kararRengi,
              borderRadius: BorderRadius.circular(8),
            ),
            child: const Text(
              'HÜKÜM',
              style: TextStyle(
                color: Colors.white,
                fontSize: 20,
                fontWeight: FontWeight.bold,
                letterSpacing: 4,
              ),
            ),
          ),
          
          const SizedBox(height: 24),
          
          // Haklı kişi
          RichText(
            textAlign: TextAlign.center,
            text: TextSpan(
              style: const TextStyle(
                color: AppTheme.textPrimary,
                fontSize: 18,
                height: 1.5,
              ),
              children: [
                const TextSpan(text: 'Mahkememizce yapılan inceleme sonucunda\n'),
                TextSpan(
                  text: karar.hakliKisi,
                  style: TextStyle(
                    color: _kararRengi,
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const TextSpan(text: '\ntarafının'),
              ],
            ),
          ),
          
          const SizedBox(height: 16),
          
          // Karar türü
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
            decoration: BoxDecoration(
              color: _kararRengi.withValues(alpha: 0.2),
              borderRadius: BorderRadius.circular(8),
              border: Border.all(color: _kararRengi),
            ),
            child: Text(
              karar.kararTuru.toUpperCase(),
              style: TextStyle(
                color: _kararRengi,
                fontSize: 22,
                fontWeight: FontWeight.bold,
                letterSpacing: 2,
              ),
            ),
          ),
          
          const SizedBox(height: 12),
          
          const Text(
            'olduğuna karar verilmiştir.',
            style: TextStyle(
              color: AppTheme.textSecondary,
              fontSize: 16,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildStatistics() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 24),
      child: Row(
        children: [
          Expanded(
            child: _buildStatCard(
              label: 'Haksızlık Oranı',
              value: '%${karar.haksizlikOrani}',
              color: AppTheme.errorColor,
            ),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: _buildStatCard(
              label: 'Haklılık Oranı',
              value: '%${karar.haklilikOrani}',
              color: AppTheme.successColor,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildStatCard({
    required String label,
    required String value,
    required Color color,
  }) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: color.withValues(alpha: 0.3)),
      ),
      child: Column(
        children: [
          Text(
            label,
            style: TextStyle(
              color: AppTheme.textSecondary,
              fontSize: 12,
            ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 8),
          Text(
            value,
            style: TextStyle(
              color: color,
              fontSize: 28,
              fontWeight: FontWeight.bold,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildJudgeComment() {
    return Container(
      margin: const EdgeInsets.all(24),
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: AppTheme.primaryColor.withValues(alpha: 0.5),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: AppTheme.accentColor.withValues(alpha: 0.3),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(
                Icons.format_quote,
                color: AppTheme.accentColor,
                size: 24,
              ),
              const SizedBox(width: 8),
              Text(
                karar.juriTipi,
                style: const TextStyle(
                  color: AppTheme.accentColor,
                  fontSize: 14,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Text(
            karar.hakimYorumu,
            style: const TextStyle(
              color: AppTheme.textPrimary,
              fontSize: 15,
              fontStyle: FontStyle.italic,
              height: 1.5,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildFooter() {
    final String tarih = DateFormat('dd MMMM yyyy', 'tr_TR').format(karar.kararTarihi);
    
    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: AppTheme.primaryColor.withValues(alpha: 0.3),
        borderRadius: const BorderRadius.only(
          bottomLeft: Radius.circular(AppTheme.cardRadius - 3),
          bottomRight: Radius.circular(AppTheme.cardRadius - 3),
        ),
      ),
      child: Column(
        children: [
          const Divider(color: AppTheme.textTertiary),
          const SizedBox(height: 12),
          Text(
            tarih,
            style: const TextStyle(
              color: AppTheme.textSecondary,
              fontSize: 12,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            Constants.shareWatermark,
            style: const TextStyle(
              color: AppTheme.textTertiary,
              fontSize: 10,
            ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 8),
          const Text(
            '* Bu karar yapay zeka tarafından oluşturulmuştur ve eğlence amaçlıdır.',
            style: TextStyle(
              color: AppTheme.textTertiary,
              fontSize: 9,
            ),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }
}
