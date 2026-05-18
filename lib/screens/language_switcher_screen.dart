import 'package:flutter/material.dart';
import '../services/language_service.dart';
import '../utils/theme.dart';

class LanguageSwitcherScreen extends StatefulWidget {
  const LanguageSwitcherScreen({super.key});

  @override
  State<LanguageSwitcherScreen> createState() => _LanguageSwitcherScreenState();
}

class _LanguageSwitcherScreenState extends State<LanguageSwitcherScreen> {
  final _languageService = LanguageService();
  String _selectedLanguage = 'tr';

  @override
  void initState() {
    super.initState();
    _selectedLanguage = _languageService.currentLocale.languageCode;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Dil Seçimi'),
      ),
      body: ListView(
        children: [
          _buildHeader(),
          const Divider(height: 32),
          _buildLanguageOption('tr', 'Türkçe', '🇹🇷', 'Turkish'),
          _buildLanguageOption('en', 'English', '🇬🇧', 'English'),
          _buildLanguageOption('ar', 'العربية', '🇸🇦', 'Arabic'),
          const SizedBox(height: 24),
          _buildInfo(),
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
            AppTheme.primaryColor.withValues(alpha: 0.1),
            AppTheme.secondaryColor.withValues(alpha: 0.1),
          ],
        ),
        borderRadius: BorderRadius.circular(16),
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: AppTheme.primaryColor.withValues(alpha: 0.2),
              borderRadius: BorderRadius.circular(12),
            ),
            child: const Icon(Icons.language, size: 32),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Dil Seçimi',
                  style: Theme.of(context).textTheme.titleLarge?.copyWith(
                        fontWeight: FontWeight.bold,
                      ),
                ),
                const SizedBox(height: 4),
                Text(
                  'Tercih ettiğiniz dili seçin',
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

  Widget _buildLanguageOption(
    String code,
    String name,
    String flag,
    String englishName,
  ) {
    final isSelected = _selectedLanguage == code;
    
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
      decoration: BoxDecoration(
        color: isSelected ? AppTheme.primaryColor.withValues(alpha: 0.1) : null,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: isSelected ? AppTheme.primaryColor : Colors.grey[300]!,
          width: isSelected ? 2 : 1,
        ),
      ),
      child: ListTile(
        leading: Text(
          flag,
          style: const TextStyle(fontSize: 32),
        ),
        title: Text(
          name,
          style: TextStyle(
            fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
            color: isSelected ? AppTheme.primaryColor : null,
          ),
        ),
        subtitle: Text(englishName),
        trailing: isSelected
            ? Icon(Icons.check_circle, color: AppTheme.primaryColor)
            : const Icon(Icons.circle_outlined),
        onTap: () async {
          setState(() => _selectedLanguage = code);
          await _languageService.setLanguage(Locale(code));
          
          if (mounted) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text('Dil $name olarak değiştirildi'),
                action: SnackBarAction(
                  label: 'Yeniden Başlat',
                  onPressed: () {
                    // App restart için Navigator.pushReplacement kullanılabilir
                  },
                ),
              ),
            );
          }
        },
      ),
    );
  }

  Widget _buildInfo() {
    return Container(
      margin: const EdgeInsets.all(16),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.blue[50],
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.blue[200]!),
      ),
      child: Row(
        children: [
          Icon(Icons.info_outline, color: Colors.blue[700]),
          const SizedBox(width: 12),
          Expanded(
            child: Text(
              'Dil değişiklikleri uygulamayı yeniden başlattığınızda aktif olacaktır.',
              style: TextStyle(
                color: Colors.blue[900],
                fontSize: 13,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
