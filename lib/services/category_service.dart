enum CaseCategory {
  relationship('İlişki', '💕', 'Sevgililik, evlilik, flört tartışmaları'),
  family('Aile', '👨‍👩‍👧', 'Aile içi sorunlar, kardeşler, ebeveynler'),
  work('İş', '💼', 'İş yeri, iş arkadaşları, patron'),
  friendship('Arkadaşlık', '🤝', 'Arkadaşlar arası tartışmalar'),
  social('Sosyal', '🌍', 'Genel konular, toplumsal tartışmalar');

  final String label;
  final String emoji;
  final String description;

  const CaseCategory(this.label, this.emoji, this.description);
}

class CategoryService {
  static final CategoryService _instance = CategoryService._internal();
  factory CategoryService() => _instance;
  CategoryService._internal();

  CaseCategory? _selectedCategory;
  
  CaseCategory? get selectedCategory => _selectedCategory;

  void setCategory(CaseCategory category) {
    _selectedCategory = category;
  }

  void clearCategory() {
    _selectedCategory = null;
  }

  String getCategoryContext(CaseCategory category) {
    switch (category) {
      case CaseCategory.relationship:
        return 'Bu tartışma bir ilişki bağlamında gerçekleşmiştir. Duygusal dinamikleri ve ilişki dinamiklerini göz önünde bulundurun.';
      case CaseCategory.family:
        return 'Bu tartışma aile içinde gerçekleşmiştir. Aile dinamikleri, kültürel değerleri ve nesiller arası ilişkileri göz önünde bulundurun.';
      case CaseCategory.work:
        return 'Bu tartışma iş ortamında gerçekleşmiştir. Profesyonel etik, hiyerarşi ve iş ilişkilerini göz önünde bulundurun.';
      case CaseCategory.friendship:
        return 'Bu tartışma arkadaşlar arasında gerçekleşmiştir. Eşitlik, samimiyet ve dostluk değerlerini göz önünde bulundurun.';
      case CaseCategory.social:
        return 'Bu tartışma sosyal bir bağlamda gerçekleşmiştir. Toplumsal normları ve genel perspektifleri göz önünde bulundurun.';
    }
  }
}