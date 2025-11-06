import 'package:flutter/material.dart';
import '../../models/partner_profile.dart';
import '../../services/partner_search_service.dart';
import '../../services/location_service.dart';
import 'package:firebase_auth/firebase_auth.dart';

/// パートナープロフィール編集画面
/// 
/// 機能:
/// - プロフィール作成・編集
/// - トレーニング目標・経験レベル設定
/// - 利用可能日時設定
class PartnerProfileEditScreen extends StatefulWidget {
  const PartnerProfileEditScreen({super.key});

  @override
  State<PartnerProfileEditScreen> createState() => _PartnerProfileEditScreenState();
}

class _PartnerProfileEditScreenState extends State<PartnerProfileEditScreen> {
  final PartnerSearchService _searchService = PartnerSearchService();
  final LocationService _locationService = LocationService();
  final _formKey = GlobalKey<FormState>();

  bool _isLoading = true;
  bool _isSaving = false;
  PartnerProfile? _existingProfile;

  // フォームフィールド
  final TextEditingController _displayNameController = TextEditingController();
  final TextEditingController _bioController = TextEditingController();
  final TextEditingController _ageController = TextEditingController();
  final TextEditingController _preferredLocationController = TextEditingController();
  
  String _selectedGender = 'not_specified';
  List<String> _selectedGoals = [];
  String _selectedExperienceLevel = 'beginner';
  List<String> _selectedExercises = [];
  List<String> _selectedDays = [];
  List<String> _selectedTimeSlots = [];
  List<String> _preferredGenders = ['male', 'female', 'other'];
  double _searchRadiusKm = 10.0;
  bool _isVisible = true;

  double? _currentLatitude;
  double? _currentLongitude;

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
    'not_specified': '未指定',
  };

  final Map<String, String> _exercises = {
    'chest': '胸',
    'back': '背中',
    'legs': '脚',
    'shoulders': '肩',
    'arms': '腕',
    'core': 'コア',
  };

  final Map<String, String> _weekDays = {
    'monday': '月',
    'tuesday': '火',
    'wednesday': '水',
    'thursday': '木',
    'friday': '金',
    'saturday': '土',
    'sunday': '日',
  };

  final Map<String, String> _timeSlots = {
    'morning': '朝 (6-12時)',
    'afternoon': '昼 (12-18時)',
    'evening': '夕 (18-21時)',
    'night': '夜 (21時以降)',
  };

  @override
  void initState() {
    super.initState();
    _loadProfile();
    _getCurrentLocation();
  }

  @override
  void dispose() {
    _displayNameController.dispose();
    _bioController.dispose();
    _ageController.dispose();
    _preferredLocationController.dispose();
    super.dispose();
  }

  Future<void> _loadProfile() async {
    setState(() {
      _isLoading = true;
    });

    try {
      final profile = await _searchService.getMyProfile();
      
      if (profile != null) {
        setState(() {
          _existingProfile = profile;
          _displayNameController.text = profile.displayName;
          _bioController.text = profile.bio ?? '';
          _ageController.text = profile.age.toString();
          _selectedGender = profile.gender;
          _selectedGoals = List.from(profile.trainingGoals);
          _selectedExperienceLevel = profile.experienceLevel;
          _selectedExercises = List.from(profile.preferredExercises);
          _selectedDays = List.from(profile.availableDays);
          _selectedTimeSlots = List.from(profile.availableTimeSlots);
          _preferredLocationController.text = profile.preferredLocation ?? '';
          _searchRadiusKm = profile.searchRadiusKm;
          _isVisible = profile.isVisible;
          _preferredGenders = List.from(profile.preferredGenders);
          if (profile.latitude != null) _currentLatitude = profile.latitude;
          if (profile.longitude != null) _currentLongitude = profile.longitude;
        });
      } else {
        // 新規作成の場合、Firebase Authからデフォルト値を設定
        final user = FirebaseAuth.instance.currentUser;
        if (user != null) {
          _displayNameController.text = user.displayName ?? '';
        }
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('プロフィール読み込みエラー: $e')),
        );
      }
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  Future<void> _getCurrentLocation() async {
    try {
      final position = await _locationService.getCurrentLocation();
      if (position != null && mounted) {
        setState(() {
          _currentLatitude = position.latitude;
          _currentLongitude = position.longitude;
        });
      }
    } catch (e) {
      // 位置情報取得失敗時は続行
    }
  }

  Future<void> _saveProfile() async {
    if (!_formKey.currentState!.validate()) {
      return;
    }

    if (_selectedGoals.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('トレーニング目標を1つ以上選択してください')),
      );
      return;
    }

    if (_selectedDays.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('利用可能な曜日を1つ以上選択してください')),
      );
      return;
    }

    if (_selectedTimeSlots.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('利用可能な時間帯を1つ以上選択してください')),
      );
      return;
    }

    setState(() {
      _isSaving = true;
    });

    try {
      final userId = FirebaseAuth.instance.currentUser?.uid;
      if (userId == null) throw Exception('ログインが必要です');

      final profile = PartnerProfile(
        userId: userId,
        displayName: _displayNameController.text.trim(),
        bio: _bioController.text.trim().isEmpty ? null : _bioController.text.trim(),
        age: int.parse(_ageController.text),
        gender: _selectedGender,
        trainingGoals: _selectedGoals,
        experienceLevel: _selectedExperienceLevel,
        preferredExercises: _selectedExercises,
        availableDays: _selectedDays,
        availableTimeSlots: _selectedTimeSlots,
        latitude: _currentLatitude,
        longitude: _currentLongitude,
        preferredLocation: _preferredLocationController.text.trim().isEmpty 
            ? null 
            : _preferredLocationController.text.trim(),
        searchRadiusKm: _searchRadiusKm,
        isVisible: _isVisible,
        preferredGenders: _preferredGenders,
        createdAt: _existingProfile?.createdAt ?? DateTime.now(),
        updatedAt: DateTime.now(),
        matchCount: _existingProfile?.matchCount ?? 0,
        rating: _existingProfile?.rating ?? 0.0,
      );

      await _searchService.saveProfile(profile);

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('プロフィールを保存しました')),
        );
        Navigator.pop(context, true);
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('保存エラー: $e')),
        );
      }
    } finally {
      if (mounted) {
        setState(() {
          _isSaving = false;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(_existingProfile == null ? 'プロフィール作成' : 'プロフィール編集'),
        actions: [
          if (_isSaving)
            const Center(
              child: Padding(
                padding: EdgeInsets.all(16.0),
                child: SizedBox(
                  width: 20,
                  height: 20,
                  child: CircularProgressIndicator(strokeWidth: 2),
                ),
              ),
            )
          else
            TextButton(
              onPressed: _saveProfile,
              child: const Text('保存'),
            ),
        ],
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : SingleChildScrollView(
              padding: const EdgeInsets.all(16),
              child: Form(
                key: _formKey,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _buildBasicInfo(),
                    const SizedBox(height: 24),
                    _buildTrainingInfo(),
                    const SizedBox(height: 24),
                    _buildAvailability(),
                    const SizedBox(height: 24),
                    _buildPreferences(),
                    const SizedBox(height: 32),
                  ],
                ),
              ),
            ),
    );
  }

  Widget _buildBasicInfo() {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              '基本情報',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 16),
            
            TextFormField(
              controller: _displayNameController,
              decoration: const InputDecoration(
                labelText: '表示名',
                border: OutlineInputBorder(),
              ),
              validator: (value) {
                if (value == null || value.trim().isEmpty) {
                  return '表示名を入力してください';
                }
                return null;
              },
            ),
            const SizedBox(height: 16),
            
            TextFormField(
              controller: _bioController,
              maxLines: 3,
              maxLength: 200,
              decoration: const InputDecoration(
                labelText: '自己紹介',
                border: OutlineInputBorder(),
                hintText: 'トレーニング歴や目標を書いてください',
              ),
            ),
            const SizedBox(height: 16),
            
            Row(
              children: [
                Expanded(
                  child: TextFormField(
                    controller: _ageController,
                    keyboardType: TextInputType.number,
                    decoration: const InputDecoration(
                      labelText: '年齢',
                      border: OutlineInputBorder(),
                    ),
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return '年齢を入力してください';
                      }
                      final age = int.tryParse(value);
                      if (age == null || age < 18 || age > 100) {
                        return '18-100の範囲で入力してください';
                      }
                      return null;
                    },
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: DropdownButtonFormField<String>(
                    value: _selectedGender,
                    decoration: const InputDecoration(
                      labelText: '性別',
                      border: OutlineInputBorder(),
                    ),
                    items: _genders.entries.map((entry) {
                      return DropdownMenuItem(
                        value: entry.key,
                        child: Text(entry.value),
                      );
                    }).toList(),
                    onChanged: (value) {
                      if (value != null) {
                        setState(() {
                          _selectedGender = value;
                        });
                      }
                    },
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildTrainingInfo() {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'トレーニング情報',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 16),
            
            const Text('トレーニング目標 *', style: TextStyle(fontWeight: FontWeight.bold)),
            const SizedBox(height: 8),
            Wrap(
              spacing: 8,
              children: _trainingGoals.entries.map((entry) {
                return FilterChip(
                  label: Text(entry.value),
                  selected: _selectedGoals.contains(entry.key),
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
            
            const Text('経験レベル', style: TextStyle(fontWeight: FontWeight.bold)),
            const SizedBox(height: 8),
            Wrap(
              spacing: 8,
              children: _experienceLevels.entries.map((entry) {
                return ChoiceChip(
                  label: Text(entry.value),
                  selected: _selectedExperienceLevel == entry.key,
                  onSelected: (selected) {
                    if (selected) {
                      setState(() {
                        _selectedExperienceLevel = entry.key;
                      });
                    }
                  },
                );
              }).toList(),
            ),
            const SizedBox(height: 16),
            
            const Text('好きな部位', style: TextStyle(fontWeight: FontWeight.bold)),
            const SizedBox(height: 8),
            Wrap(
              spacing: 8,
              children: _exercises.entries.map((entry) {
                return FilterChip(
                  label: Text(entry.value),
                  selected: _selectedExercises.contains(entry.key),
                  onSelected: (selected) {
                    setState(() {
                      if (selected) {
                        _selectedExercises.add(entry.key);
                      } else {
                        _selectedExercises.remove(entry.key);
                      }
                    });
                  },
                );
              }).toList(),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildAvailability() {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              '利用可能日時',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 16),
            
            const Text('曜日 *', style: TextStyle(fontWeight: FontWeight.bold)),
            const SizedBox(height: 8),
            Wrap(
              spacing: 8,
              children: _weekDays.entries.map((entry) {
                return FilterChip(
                  label: Text(entry.value),
                  selected: _selectedDays.contains(entry.key),
                  onSelected: (selected) {
                    setState(() {
                      if (selected) {
                        _selectedDays.add(entry.key);
                      } else {
                        _selectedDays.remove(entry.key);
                      }
                    });
                  },
                );
              }).toList(),
            ),
            const SizedBox(height: 16),
            
            const Text('時間帯 *', style: TextStyle(fontWeight: FontWeight.bold)),
            const SizedBox(height: 8),
            Wrap(
              spacing: 8,
              children: _timeSlots.entries.map((entry) {
                return FilterChip(
                  label: Text(entry.value),
                  selected: _selectedTimeSlots.contains(entry.key),
                  onSelected: (selected) {
                    setState(() {
                      if (selected) {
                        _selectedTimeSlots.add(entry.key);
                      } else {
                        _selectedTimeSlots.remove(entry.key);
                      }
                    });
                  },
                );
              }).toList(),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildPreferences() {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'マッチング設定',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 16),
            
            TextFormField(
              controller: _preferredLocationController,
              decoration: const InputDecoration(
                labelText: '希望エリア',
                border: OutlineInputBorder(),
                hintText: '例: 東京都渋谷区',
              ),
            ),
            const SizedBox(height: 16),
            
            Text('検索範囲: ${_searchRadiusKm.toStringAsFixed(1)} km'),
            Slider(
              value: _searchRadiusKm,
              min: 1.0,
              max: 50.0,
              divisions: 49,
              label: '${_searchRadiusKm.toStringAsFixed(1)} km',
              onChanged: (value) {
                setState(() {
                  _searchRadiusKm = value;
                });
              },
            ),
            const SizedBox(height: 16),
            
            const Text('希望する性別', style: TextStyle(fontWeight: FontWeight.bold)),
            const SizedBox(height: 8),
            Wrap(
              spacing: 8,
              children: _genders.entries.where((e) => e.key != 'not_specified').map((entry) {
                return FilterChip(
                  label: Text(entry.value),
                  selected: _preferredGenders.contains(entry.key),
                  onSelected: (selected) {
                    setState(() {
                      if (selected) {
                        _preferredGenders.add(entry.key);
                      } else {
                        _preferredGenders.remove(entry.key);
                      }
                    });
                  },
                );
              }).toList(),
            ),
            const SizedBox(height: 16),
            
            SwitchListTile(
              title: const Text('プロフィールを公開'),
              subtitle: const Text('オフにすると検索結果に表示されません'),
              value: _isVisible,
              onChanged: (value) {
                setState(() {
                  _isVisible = value;
                });
              },
            ),
          ],
        ),
      ),
    );
  }
}
