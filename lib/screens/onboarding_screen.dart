import 'package:flutter/material.dart';
import '../utils/theme.dart';
import '../utils/page_transitions.dart';
import '../services/user_preferences_service.dart';
import 'home_screen.dart';
import 'package:smooth_page_indicator/smooth_page_indicator.dart';

/// Swipeable Onboarding ekranı
class OnboardingScreen extends StatefulWidget {
  const OnboardingScreen({super.key});

  @override
  State<OnboardingScreen> createState() => _OnboardingScreenState();
}

class _OnboardingScreenState extends State<OnboardingScreen> {
  final PageController _pageController = PageController();
  int _currentPage = 0;
  final int _totalPages = 4;

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  Future<void> _completeOnboarding() async {
    await UserPreferencesService().completeOnboarding();
    
    if (mounted) {
      Navigator.pushReplacement(
        context,
        PageTransitions.fadeTransition(const HomeScreen()),
      );
    }
  }

  void _skipOnboarding() {
    _completeOnboarding();
  }

  void _nextPage() {
    if (_currentPage < _totalPages - 1) {
      _pageController.nextPage(
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeInOut,
      );
    } else {
      _completeOnboarding();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.backgroundColor,
      body: SafeArea(
        child: Column(
          children: [
            // Skip butonu
            if (_currentPage < _totalPages - 1)
              Align(
                alignment: Alignment.topRight,
                child: TextButton(
                  onPressed: _skipOnboarding,
                  child: const Text(
                    'Atla',
                    style: TextStyle(
                      color: AppTheme.textSecondary,
                      fontSize: 16,
                    ),
                  ),
                ),
              )
            else
              const SizedBox(height: 48),

            // Sayfa içeriği
            Expanded(
              child: PageView(
                controller: _pageController,
                onPageChanged: (index) {
                  setState(() {
                    _currentPage = index;
                  });
                },
                children: [
                  _buildPage1(),
                  _buildPage2(),
                  _buildPage3(),
                  _buildPage4(),
                ],
              ),
            ),

            // Progress indicator
            Padding(
              padding: const EdgeInsets.symmetric(vertical: 24),
              child: SmoothPageIndicator(
                controller: _pageController,
                count: _totalPages,
                effect: WormEffect(
                  dotColor: AppTheme.textTertiary,
                  activeDotColor: AppTheme.accentColor,
                  dotHeight: 12,
                  dotWidth: 12,
                  spacing: 16,
                ),
              ),
            ),

            // İleri/Başla butonu
            Padding(
              padding: const EdgeInsets.all(24),
              child: SizedBox(
                width: double.infinity,
                height: 56,
                child: ElevatedButton(
                  onPressed: _nextPage,
                  child: Text(
                    _currentPage == _totalPages - 1 ? 'Başla' : 'İleri',
                    style: const TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  // Sayfa 1: Hoşgeldin
  Widget _buildPage1() {
    return Padding(
      padding: AppTheme.pagePadding,
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Text(
            '⚖️',
            style: TextStyle(fontSize: 120),
          ),
          const SizedBox(height: 32),
          Text(
            'Haklı Kim ?',
            style: Theme.of(context).textTheme.displayLarge?.copyWith(
              color: AppTheme.textPrimary,
            ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 16),
          Text(
            'AI destekli tartışma analiz uygulaması',
            style: Theme.of(context).textTheme.titleLarge?.copyWith(
              color: AppTheme.textSecondary,
            ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 48),
          Text(
            'Tartışmalarınızı yapay zeka ile analiz edin\nMantık hatalarını tespit edin\nKimin haklı olduğunu öğrenin',
            style: Theme.of(context).textTheme.bodyLarge?.copyWith(
              color: AppTheme.textSecondary,
              height: 1.8,
            ),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }

  // Sayfa 2: Nasıl Çalışır
  Widget _buildPage2() {
    return Padding(
      padding: AppTheme.pagePadding,
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Text(
            '🤖',
            style: TextStyle(fontSize: 100),
          ),
          const SizedBox(height: 32),
          Text(
            'Nasıl Çalışır?',
            style: Theme.of(context).textTheme.displayMedium?.copyWith(
              color: AppTheme.textPrimary,
            ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 48),
          _buildStep('1', '📝', 'Tartışma Metnini Girin', 'WhatsApp ekran görüntüsü veya metin'),
          const SizedBox(height: 24),
          _buildStep('2', '👨‍⚖️', 'Jüri Seçin', '5 farklı jüri karakterinden birini seçin'),
          const SizedBox(height: 24),
          _buildStep('3', '⚡', 'AI Analizi', 'Yapay zeka tartışmayı detaylı analiz eder'),
          const SizedBox(height: 24),
          _buildStep('4', '🎯', 'Sonuç', 'Kimin haklı olduğunu ve gerekçeyi görün'),
        ],
      ),
    );
  }

  // Sayfa 3: Jüri Karakterleri
  Widget _buildPage3() {
    return Padding(
      padding: AppTheme.pagePadding,
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Text(
            '5 Farklı Jüri',
            style: Theme.of(context).textTheme.displayMedium?.copyWith(
              color: AppTheme.textPrimary,
            ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 48),
          _buildJuryCard('⚖️', 'Ağır Ceza Reisi', 'Hukuki ve resmi'),
          const SizedBox(height: 16),
          _buildJuryCard('👴', 'Mahalle Muhtarı', 'Babacan ve akılcı'),
          const SizedBox(height: 16),
          _buildJuryCard('😈', 'Acımasız Komedyen', 'İğneleyici ve komik'),
          const SizedBox(height: 16),
          _buildJuryCard('🚩', 'Toksik İlişki Koçu', 'Red flag tespit uzmanı'),
          const SizedBox(height: 16),
          _buildJuryCard('🎭', 'Dertli Baba', 'Derin ve duygusal'),
        ],
      ),
    );
  }

  // Sayfa 4: Cinsiyet Seçimi ve Disclaimer
  Widget _buildPage4() {
    String? selectedGender = UserPreferencesService().userGender;

    return Padding(
      padding: AppTheme.pagePadding,
      child: SingleChildScrollView(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const SizedBox(height: 32),
            Text(
              'Son Adım',
              style: Theme.of(context).textTheme.displayMedium?.copyWith(
                color: AppTheme.textPrimary,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 32),
            
            // Cinsiyet seçimi
            Text(
              'Cinsiyetiniz',
              style: Theme.of(context).textTheme.titleLarge?.copyWith(
                color: AppTheme.textPrimary,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              'AI daha kişiselleştirilmiş yanıtlar verebilir',
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                color: AppTheme.textSecondary,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 24),
            StatefulBuilder(
              builder: (context, setStateLocal) {
                return Row(
                  children: [
                    Expanded(
                      child: _buildGenderCard(
                        '👨',
                        'Erkek',
                        selectedGender == 'male',
                        () {
                          UserPreferencesService().setUserGender('male');
                          setStateLocal(() {
                            selectedGender = 'male';
                          });
                        },
                      ),
                    ),
                    const SizedBox(width: 16),
                    Expanded(
                      child: _buildGenderCard(
                        '👩',
                        'Kadın',
                        selectedGender == 'female',
                        () {
                          UserPreferencesService().setUserGender('female');
                          setStateLocal(() {
                            selectedGender = 'female';
                          });
                        },
                      ),
                    ),
                  ],
                );
              },
            ),
            const SizedBox(height: 48),
            
            // Disclaimer
            Container(
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: AppTheme.warningColor.withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(16),
                border: Border.all(
                  color: AppTheme.warningColor.withValues(alpha: 0.3),
                  width: 2,
                ),
              ),
              child: Column(
                children: [
                  const Row(
                    children: [
                      Icon(Icons.warning_amber, color: AppTheme.warningColor),
                      SizedBox(width: 12),
                      Expanded(
                        child: Text(
                          'Önemli Uyarı',
                          style: TextStyle(
                            color: AppTheme.warningColor,
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),
                  Text(
                    '• Bu uygulama eğlence amaçlıdır\n'
                    '• Gerçek hukuki tavsiye değildir\n'
                    '• AI yanıtları kesin doğru olmayabilir\n'
                    '• Kişisel verileriniz korunur\n'
                    '• 18+ kullanıcılar için uygundur',
                    style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                      color: AppTheme.textSecondary,
                      height: 1.8,
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 32),
          ],
        ),
      ),
    );
  }

  Widget _buildStep(String number, String emoji, String title, String subtitle) {
    return Row(
      children: [
        Container(
          width: 50,
          height: 50,
          decoration: BoxDecoration(
            color: AppTheme.accentColor.withValues(alpha: 0.2),
            borderRadius: BorderRadius.circular(25),
          ),
          child: Center(
            child: Text(
              number,
              style: const TextStyle(
                color: AppTheme.accentColor,
                fontSize: 20,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
        ),
        const SizedBox(width: 16),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Text(emoji, style: const TextStyle(fontSize: 24)),
                  const SizedBox(width: 8),
                  Text(
                    title,
                    style: const TextStyle(
                      color: AppTheme.textPrimary,
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 4),
              Text(
                subtitle,
                style: const TextStyle(
                  color: AppTheme.textSecondary,
                  fontSize: 14,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildJuryCard(String emoji, String name, String description) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppTheme.primaryColor,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: AppTheme.accentColor.withValues(alpha: 0.2),
        ),
      ),
      child: Row(
        children: [
          Text(emoji, style: const TextStyle(fontSize: 32)),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  name,
                  style: const TextStyle(
                    color: AppTheme.textPrimary,
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  description,
                  style: const TextStyle(
                    color: AppTheme.textSecondary,
                    fontSize: 12,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildGenderCard(String emoji, String label, bool isSelected, VoidCallback onTap) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(16),
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 24),
        decoration: BoxDecoration(
          color: isSelected 
              ? AppTheme.accentColor.withValues(alpha: 0.2)
              : AppTheme.primaryColor,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
            color: isSelected ? AppTheme.accentColor : AppTheme.textTertiary,
            width: 2,
          ),
        ),
        child: Column(
          children: [
            Text(emoji, style: const TextStyle(fontSize: 48)),
            const SizedBox(height: 12),
            Text(
              label,
              style: TextStyle(
                color: isSelected ? AppTheme.accentColor : AppTheme.textPrimary,
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
