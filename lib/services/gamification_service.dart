import 'package:shared_preferences/shared_preferences.dart';
import 'logger_service.dart';

class GamificationService {
  static final GamificationService _instance = GamificationService._internal();
  factory GamificationService() => _instance;
  GamificationService._internal();

  static const String _pointsKey = 'user_points';
  static const String _levelKey = 'user_level';
  static const String _totalCasesKey = 'total_cases';
  static const String _totalWinsKey = 'total_wins';
  static const String _streakKey = 'daily_streak';
  static const String _lastPlayDateKey = 'last_play_date';

  SharedPreferences? _prefs;

  Future<void> initialize() async {
    _prefs ??= await SharedPreferences.getInstance();
    LoggerService.info('Gamification initialized');
  }

  int get userPoints => _prefs?.getInt(_pointsKey) ?? 0;
  int get userLevel => _prefs?.getInt(_levelKey) ?? 1;
  int get totalCases => _prefs?.getInt(_totalCasesKey) ?? 0;
  int get totalWins => _prefs?.getInt(_totalWinsKey) ?? 0;
  int get dailyStreak => _prefs?.getInt(_streakKey) ?? 0;

  int get pointsToNextLevel => (userLevel * 100) - (userPoints % (userLevel * 100));

  String get levelTitle {
    if (userLevel < 5) return 'Acemi';
    if (userLevel < 10) return 'Juniör Hakem';
    if (userLevel < 20) return 'Kıdemli Hakem';
    if (userLevel < 30) return 'Uzman';
    if (userLevel < 50) return 'Master';
    return 'Efsane';
  }

  Future<void> addPoints(int points) async {
    await initialize();
    final newPoints = userPoints + points;
    await _prefs?.setInt(_pointsKey, newPoints);
    
    final newLevel = (newPoints / 100).floor() + 1;
    if (newLevel > userLevel) {
      await _prefs?.setInt(_levelKey, newLevel);
      LoggerService.info('Level up! New level: $newLevel');
    }
  }

  Future<void> incrementTotalCases() async {
    await initialize();
    await _prefs?.setInt(_totalCasesKey, totalCases + 1);
    await _updateStreak();
    await addPoints(10);
  }

  Future<void> incrementWins() async {
    await initialize();
    await _prefs?.setInt(_totalWinsKey, totalWins + 1);
    await addPoints(20);
  }

  Future<void> _updateStreak() async {
    final today = DateTime.now().toIso8601String().split('T')[0];
    final lastPlay = _prefs?.getString(_lastPlayDateKey);

    if (lastPlay == today) return;

    final yesterday = DateTime.now().subtract(const Duration(days: 1)).toIso8601String().split('T')[0];
    
    if (lastPlay == yesterday) {
      await _prefs?.setInt(_streakKey, dailyStreak + 1);
    } else {
      await _prefs?.setInt(_streakKey, 1);
    }
    
    await _prefs?.setString(_lastPlayDateKey, today);
  }

  Future<void> shareBonus() async {
    await addPoints(50);
  }

  Map<String, dynamic> getStats() {
    return {
      'points': userPoints,
      'level': userLevel,
      'title': levelTitle,
      'totalCases': totalCases,
      'totalWins': totalWins,
      'streak': dailyStreak,
      'pointsToNext': pointsToNextLevel,
    };
  }

  List<Map<String, dynamic>> getLeaderboard() {
    return [
      {'name': 'Sen', 'points': userPoints, 'isMe': true},
      {'name': 'Ahmet', 'points': 1250, 'isMe': false},
      {'name': 'Zeynep', 'points': 980, 'isMe': false},
      {'name': 'Mehmet', 'points': 750, 'isMe': false},
      {'name': 'Ayşe', 'points': 520, 'isMe': false},
    ];
  }
}

class AchievementService {
  static final AchievementService _instance = AchievementService._internal();
  factory AchievementService() => _instance;
  AchievementService._internal();

  final List<Achievement> _achievements = [
    Achievement(id: 'first_case', title: 'İlk Dava', description: 'İlk davanı açtın', icon: '🎯', points: 10),
    Achievement(id: 'streak_3', title: '3 Gün Üst Üste', description: '3 gün boyunca analiz yaptın', icon: '🔥', points: 30),
    Achievement(id: 'streak_7', title: 'Haftalık', description: '7 gün boyunca analiz yaptın', icon: '💪', points: 70),
    Achievement(id: 'share_5', title: 'Sosyal Kelebek', description: '5 kez paylaştın', icon: '🦋', points: 50),
    Achievement(id: 'win_10', title: 'Avukat', description: '10 kez "haklı" oldun', icon: '⚖️', points: 100),
  ];

  List<Achievement> get availableAchievements => _achievements;
}

class Achievement {
  final String id;
  final String title;
  final String description;
  final String icon;
  final int points;

  Achievement({
    required this.id,
    required this.title,
    required this.description,
    required this.icon,
    required this.points,
  });
}