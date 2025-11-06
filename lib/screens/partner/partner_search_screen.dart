import 'package:flutter/material.dart';
import '../../models/partner_profile.dart';
import '../../services/partner_search_service.dart';
import '../../services/location_service.dart';
import 'partner_profile_detail_screen.dart';
import 'partner_profile_edit_screen.dart';

/// パートナー検索画面（MVP）
/// 
/// 機能:
/// - パートナー検索フィルター（場所、目標、経験レベル）
/// - 検索結果一覧表示
/// - プロフィール詳細表示
/// - マッチングリクエスト送信
class PartnerSearchScreen extends StatefulWidget {
  const PartnerSearchScreen({super.key});

  @override
  State<PartnerSearchScreen> createState() => _PartnerSearchScreenState();
}

class _PartnerSearchScreenState extends State<PartnerSearchScreen> {
  final PartnerSearchService _searchService = PartnerSearchService();
  final LocationService _locationService = LocationService();

  List<PartnerProfile> _searchResults = [];
  bool _isLoading = false;
  bool _hasSearched = false;
  String? _errorMessage;

  // 検索フィルター
  double? _currentLatitude;
  double? _currentLongitude;
  double _maxDistanceKm = 10.0;
  List<String> _selectedGoals = [];
  String? _selectedExperienceLevel;
  List<String> _selectedGenders = [];

  // 利用可能なオプション
  final Map<String, String> _trainingGoals = {
    'muscle_gain': '筋力増強',
    'weight_loss': '減量',
    'endurance': '持久力向上',
    'flexibility': '柔軟性向上',
  };

  final Map<String, String> _experienceLevels = {
    'beginner': '初心者',
    'intermediate': '中級者',
    'advanced': '上級者',
    'expert': 'エキスパート',
  };

  final Map<String, String> _genders = {
    'male': '男性',
    'female': '女性',
    'other': 'その他',
  };

  @override
  void initState() {
    super.initState();
    _getCurrentLocation();
  }

  Future<void> _getCurrentLocation() async {
    try {
      final position = await _locationService.getCurrentLocation();
      if (mounted && position != null) {
        setState(() {
          _currentLatitude = position.latitude;
          _currentLongitude = position.longitude;
        });
      }
    } catch (e) {
      // 位置情報取得失敗時は続行（フィルターから距離を除外）
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('位置情報を取得できませんでした')),
        );
      }
    }
  }

  Future<void> _searchPartners() async {
    setState(() {
      _isLoading = true;
      _errorMessage = null;
      _hasSearched = true;
    });

    try {
      final results = await _searchService.searchPartners(
        latitude: _currentLatitude,
        longitude: _currentLongitude,
        maxDistanceKm: _maxDistanceKm,
        trainingGoals: _selectedGoals.isEmpty ? null : _selectedGoals,
        experienceLevel: _selectedExperienceLevel,
        genders: _selectedGenders.isEmpty ? null : _selectedGenders,
      );

      setState(() {
        _searchResults = results;
        _isLoading = false;
      });
    } catch (e) {
      setState(() {
        _errorMessage = e.toString();
        _isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('パートナー検索'),
        actions: [
          IconButton(
            icon: const Icon(Icons.person_add),
            onPressed: _navigateToProfileEdit,
            tooltip: 'プロフィール編集',
          ),
        ],
      ),
      body: Column(
        children: [
          // 検索フィルター
          _buildSearchFilters(),
          
          // 検索結果
          Expanded(
            child: _buildSearchResults(),
          ),
        ],
      ),
    );
  }

  Widget _buildSearchFilters() {
    return Card(
      margin: const EdgeInsets.all(16),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              '検索条件',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 16),
            
            // 距離フィルター
            if (_currentLatitude != null && _currentLongitude != null) ...[
              Text('検索範囲: ${_maxDistanceKm.toStringAsFixed(1)} km'),
              Slider(
                value: _maxDistanceKm,
                min: 1.0,
                max: 50.0,
                divisions: 49,
                label: '${_maxDistanceKm.toStringAsFixed(1)} km',
                onChanged: (value) {
                  setState(() {
                    _maxDistanceKm = value;
                  });
                },
              ),
              const SizedBox(height: 8),
            ],

            // トレーニング目標フィルター
            const Text('トレーニング目標', style: TextStyle(fontWeight: FontWeight.bold)),
            const SizedBox(height: 8),
            Wrap(
              spacing: 8,
              children: _trainingGoals.entries.map((entry) {
                final isSelected = _selectedGoals.contains(entry.key);
                return FilterChip(
                  label: Text(entry.value),
                  selected: isSelected,
                  onSelected: (selected) {
                    setState(() {
                      if (selected) {
                        _selectedGoals.add(entry.key);
                      } else {
                        _selectedGoals.remove(entry.key);
                      }
                    });
                  },
                );
              }).toList(),
            ),
            const SizedBox(height: 16),

            // 経験レベルフィルター
            const Text('経験レベル', style: TextStyle(fontWeight: FontWeight.bold)),
            const SizedBox(height: 8),
            Wrap(
              spacing: 8,
              children: _experienceLevels.entries.map((entry) {
                final isSelected = _selectedExperienceLevel == entry.key;
                return ChoiceChip(
                  label: Text(entry.value),
                  selected: isSelected,
                  onSelected: (selected) {
                    setState(() {
                      _selectedExperienceLevel = selected ? entry.key : null;
                    });
                  },
                );
              }).toList(),
            ),
            const SizedBox(height: 16),

            // 性別フィルター
            const Text('性別', style: TextStyle(fontWeight: FontWeight.bold)),
            const SizedBox(height: 8),
            Wrap(
              spacing: 8,
              children: _genders.entries.map((entry) {
                final isSelected = _selectedGenders.contains(entry.key);
                return FilterChip(
                  label: Text(entry.value),
                  selected: isSelected,
                  onSelected: (selected) {
                    setState(() {
                      if (selected) {
                        _selectedGenders.add(entry.key);
                      } else {
                        _selectedGenders.remove(entry.key);
                      }
                    });
                  },
                );
              }).toList(),
            ),
            const SizedBox(height: 16),

            // 検索ボタン
            SizedBox(
              width: double.infinity,
              child: ElevatedButton.icon(
                onPressed: _isLoading ? null : _searchPartners,
                icon: const Icon(Icons.search),
                label: const Text('検索'),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSearchResults() {
    if (_isLoading) {
      return const Center(child: CircularProgressIndicator());
    }

    if (_errorMessage != null) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(Icons.error_outline, size: 64, color: Colors.red),
            const SizedBox(height: 16),
            Text(
              'エラーが発生しました',
              style: Theme.of(context).textTheme.titleLarge,
            ),
            const SizedBox(height: 8),
            Text(_errorMessage!),
            const SizedBox(height: 16),
            ElevatedButton(
              onPressed: _searchPartners,
              child: const Text('再試行'),
            ),
          ],
        ),
      );
    }

    if (!_hasSearched) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.search,
              size: 64,
              color: Colors.grey[400],
            ),
            const SizedBox(height: 16),
            Text(
              '条件を設定して検索してください',
              style: TextStyle(
                fontSize: 16,
                color: Colors.grey[600],
              ),
            ),
          ],
        ),
      );
    }

    if (_searchResults.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.person_search,
              size: 64,
              color: Colors.grey[400],
            ),
            const SizedBox(height: 16),
            Text(
              '条件に一致するパートナーが見つかりませんでした',
              style: TextStyle(
                fontSize: 16,
                color: Colors.grey[600],
              ),
            ),
            const SizedBox(height: 8),
            Text(
              '検索条件を変更してみてください',
              style: TextStyle(
                fontSize: 14,
                color: Colors.grey[500],
              ),
            ),
          ],
        ),
      );
    }

    return ListView.builder(
      padding: const EdgeInsets.all(16),
      itemCount: _searchResults.length,
      itemBuilder: (context, index) {
        final profile = _searchResults[index];
        return _buildPartnerCard(profile);
      },
    );
  }

  Widget _buildPartnerCard(PartnerProfile profile) {
    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      child: InkWell(
        onTap: () => _navigateToProfileDetail(profile),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Row(
            children: [
              // プロフィール画像
              CircleAvatar(
                radius: 30,
                backgroundImage: profile.photoUrl != null
                    ? NetworkImage(profile.photoUrl!)
                    : null,
                child: profile.photoUrl == null
                    ? const Icon(Icons.person, size: 30)
                    : null,
              ),
              const SizedBox(width: 16),
              
              // プロフィール情報
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Text(
                          profile.displayName,
                          style: const TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const SizedBox(width: 8),
                        Text(
                          '${profile.age}歳',
                          style: TextStyle(
                            fontSize: 14,
                            color: Colors.grey[600],
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 4),
                    Text(
                      _experienceLevels[profile.experienceLevel] ?? profile.experienceLevel,
                      style: TextStyle(
                        fontSize: 14,
                        color: Colors.grey[700],
                      ),
                    ),
                    const SizedBox(height: 8),
                    Wrap(
                      spacing: 4,
                      runSpacing: 4,
                      children: profile.trainingGoals.take(3).map((goal) {
                        return Chip(
                          label: Text(
                            _trainingGoals[goal] ?? goal,
                            style: const TextStyle(fontSize: 12),
                          ),
                          materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
                        );
                      }).toList(),
                    ),
                  ],
                ),
              ),
              
              // レーティング
              Column(
                children: [
                  const Icon(Icons.star, color: Colors.amber, size: 20),
                  Text(
                    profile.rating.toStringAsFixed(1),
                    style: const TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _navigateToProfileDetail(PartnerProfile profile) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => PartnerProfileDetailScreen(profile: profile),
      ),
    );
  }

  void _navigateToProfileEdit() async {
    final result = await Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => const PartnerProfileEditScreen(),
      ),
    );

    // プロフィール編集後、検索を再実行
    if (result == true && _hasSearched) {
      _searchPartners();
    }
  }
}
