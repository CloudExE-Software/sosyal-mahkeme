import 'package:flutter/material.dart';
import '../models/history_item.dart';
import '../services/favorite_service.dart';
import '../utils/theme.dart';
import '../widgets/certificate_widget.dart';

/// Favoriler ekranı
class FavoritesScreen extends StatefulWidget {
  const FavoritesScreen({super.key});

  @override
  State<FavoritesScreen> createState() => _FavoritesScreenState();
}

class _FavoritesScreenState extends State<FavoritesScreen> {
  final FavoriteService _favoriteService = FavoriteService();
  List<HistoryItem> _favorites = [];
  bool _isLoading = true;
  String _searchQuery = '';

  @override
  void initState() {
    super.initState();
    _loadFavorites();
  }

  Future<void> _loadFavorites() async {
    setState(() => _isLoading = true);
    
    final favorites = _searchQuery.isEmpty
        ? await _favoriteService.getFavoritesSorted()
        : await _favoriteService.searchFavorites(_searchQuery);
    
    setState(() {
      _favorites = favorites;
      _isLoading = false;
    });
  }

  Future<void> _removeFromFavorites(HistoryItem item) async {
    await _favoriteService.removeFromFavorites(item.id);
    await _loadFavorites();
    
    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Favorilerden çıkarıldı'),
          duration: Duration(seconds: 2),
        ),
      );
    }
  }

  void _showDetail(HistoryItem item) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => DraggableScrollableSheet(
        initialChildSize: 0.9,
        minChildSize: 0.5,
        maxChildSize: 0.95,
        builder: (context, scrollController) => Container(
          decoration: const BoxDecoration(
            color: AppTheme.backgroundColor,
            borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
          ),
          child: Column(
            children: [
              // Sürükleme çubuğu
              Container(
                margin: const EdgeInsets.symmetric(vertical: 12),
                width: 40,
                height: 4,
                decoration: BoxDecoration(
                  color: AppTheme.textTertiary,
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
              
              // Başlık ve butonlar
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 20),
                child: Row(
                  children: [
                    const Expanded(
                      child: Text(
                        'Karar Detayı',
                        style: TextStyle(
                          color: AppTheme.textPrimary,
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                    IconButton(
                      icon: const Icon(Icons.delete_outline, color: Colors.red),
                      onPressed: () {
                        Navigator.pop(context);
                        _removeFromFavorites(item);
                      },
                    ),
                    IconButton(
                      icon: const Icon(Icons.close, color: AppTheme.textSecondary),
                      onPressed: () => Navigator.pop(context),
                    ),
                  ],
                ),
              ),
              
              const Divider(height: 1),
              
              // İçerik
              Expanded(
                child: SingleChildScrollView(
                  controller: scrollController,
                  padding: const EdgeInsets.all(20),
                  child: CertificateWidget(
                    karar: item.karar,
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Favorilerim'),
        actions: [
          if (_favorites.isNotEmpty)
            PopupMenuButton(
              icon: const Icon(Icons.sort),
              itemBuilder: (context) => [
                const PopupMenuItem(
                  value: 'date_new',
                  child: Text('Tarihe göre (Yeni → Eski)'),
                ),
                const PopupMenuItem(
                  value: 'date_old',
                  child: Text('Tarihe göre (Eski → Yeni)'),
                ),
              ],
              onSelected: (value) async {
                final ascending = value == 'date_old';
                final sorted = await _favoriteService.getFavoritesSorted(ascending: ascending);
                setState(() => _favorites = sorted);
              },
            ),
        ],
      ),
      body: Column(
        children: [
          // Arama çubuğu
          if (_favorites.isNotEmpty || _searchQuery.isNotEmpty)
            Padding(
              padding: const EdgeInsets.all(16),
              child: TextField(
                autofocus: false,
                keyboardType: TextInputType.text,
                decoration: InputDecoration(
                  hintText: 'Favorilerde ara...',
                  prefixIcon: const Icon(Icons.search),
                  suffixIcon: _searchQuery.isNotEmpty
                      ? IconButton(
                          icon: const Icon(Icons.clear),
                          onPressed: () {
                            setState(() => _searchQuery = '');
                            _loadFavorites();
                          },
                        )
                      : null,
                ),
                onChanged: (value) {
                  setState(() => _searchQuery = value);
                  _loadFavorites();
                },
              ),
            ),

          // İçerik
          Expanded(
            child: _isLoading
                ? const Center(child: CircularProgressIndicator())
                : _favorites.isEmpty
                    ? _buildEmptyState()
                    : RefreshIndicator(
                        onRefresh: _loadFavorites,
                        child: ListView.builder(
                          padding: const EdgeInsets.all(16),
                          itemCount: _favorites.length,
                          itemBuilder: (context, index) {
                            return _buildFavoriteCard(_favorites[index]);
                          },
                        ),
                      ),
          ),
        ],
      ),
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Text(
            '⭐',
            style: TextStyle(fontSize: 80),
          ),
          const SizedBox(height: 24),
          Text(
            _searchQuery.isEmpty
                ? 'Henüz favori yok'
                : 'Sonuç bulunamadı',
            style: const TextStyle(
              color: AppTheme.textPrimary,
              fontSize: 20,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            _searchQuery.isEmpty
                ? 'Beğendiğiniz kararları favorilere ekleyin'
                : 'Farklı bir arama yapın',
            style: const TextStyle(
              color: AppTheme.textSecondary,
              fontSize: 14,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildFavoriteCard(HistoryItem item) {
    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      child: InkWell(
        onTap: () => _showDetail(item),
        borderRadius: BorderRadius.circular(AppTheme.cardRadius),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Üst bar
              Row(
                children: [
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                    decoration: BoxDecoration(
                      color: item.karar.kararRengi.withValues(alpha: 0.2),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Text(
                          item.karar.kararEmoji,
                          style: const TextStyle(fontSize: 16),
                        ),
                        const SizedBox(width: 6),
                        Text(
                          item.karar.kararTuru,
                          style: TextStyle(
                            color: item.karar.kararRengi,
                            fontSize: 12,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ],
                    ),
                  ),
                  const Spacer(),
                  IconButton(
                    icon: const Icon(Icons.favorite, color: Colors.red, size: 20),
                    onPressed: () => _removeFromFavorites(item),
                  ),
                ],
              ),
              
              const SizedBox(height: 12),
              
              // Metin önizlemesi
              Text(
                item.onizleme,
                maxLines: 3,
                overflow: TextOverflow.ellipsis,
                style: const TextStyle(
                  color: AppTheme.textPrimary,
                  fontSize: 14,
                ),
              ),
              
              const SizedBox(height: 12),
              
              // Alt bar
              Row(
                children: [
                  const Icon(Icons.calendar_today, size: 14, color: AppTheme.textTertiary),
                  const SizedBox(width: 6),
                  Text(
                    _formatDate(item.tarih),
                    style: const TextStyle(
                      color: AppTheme.textTertiary,
                      fontSize: 12,
                    ),
                  ),
                  const Spacer(),
                  const Text(
                    'Detay için tıklayın',
                    style: TextStyle(
                      color: AppTheme.accentColor,
                      fontSize: 12,
                    ),
                  ),
                  const SizedBox(width: 4),
                  const Icon(Icons.arrow_forward_ios, size: 12, color: AppTheme.accentColor),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  String _formatDate(DateTime date) {
    final now = DateTime.now();
    final diff = now.difference(date);
    
    if (diff.inDays == 0) {
      return 'Bugün';
    } else if (diff.inDays == 1) {
      return 'Dün';
    } else if (diff.inDays < 7) {
      return '${diff.inDays} gün önce';
    } else {
      return '${date.day}.${date.month}.${date.year}';
    }
  }
}
