import 'package:flutter/material.dart';
import 'package:flutter/cupertino.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart' as firebase_auth;

class AddWorkoutScreen extends StatefulWidget {
  const AddWorkoutScreen({super.key});

  @override
  State<AddWorkoutScreen> createState() => _AddWorkoutScreenState();
}

class _AddWorkoutScreenState extends State<AddWorkoutScreen> {
  DateTime _selectedDate = DateTime.now(); // 選択された日付
  String? _selectedMuscleGroup;
  int _startHour = 9;
  int _startMinute = 0;
  int _endHour = 11;
  int _endMinute = 0;
  final List<WorkoutSet> _sets = [];
  String? _customExerciseName;
  
  // 部位別の種目リスト
  final Map<String, List<String>> _muscleGroupExercises = {
    '胸': ['ベンチプレス', 'ダンベルプレス', 'インクラインプレス', 'ケーブルフライ', 'ディップス'],
    '脚': ['スクワット', 'レッグプレス', 'レッグエクステンション', 'レッグカール', 'カーフレイズ'],
    '背中': ['デッドリフト', 'ラットプルダウン', 'ベントオーバーロウ', 'シーテッドロウ', '懸垂'],
    '肩': ['ショルダープレス', 'サイドレイズ', 'フロントレイズ', 'リアデルトフライ', 'アップライトロウ'],
    '二頭': ['バーベルカール', 'ダンベルカール', 'ハンマーカール', 'プリチャーカール', 'ケーブルカール'],
    '三頭': ['トライセプスエクステンション', 'スカルクラッシャー', 'ケーブルプッシュダウン', 'ディップス', 'キックバック'],
  };
  
  // カスタム種目リスト（Firestoreから読み込み）
  Map<String, List<Map<String, dynamic>>> _customExercises = {};
  
  @override
  void initState() {
    super.initState();
    _loadCustomExercises();
  }
  
  // カスタム種目をFirestoreから読み込み
  Future<void> _loadCustomExercises() async {
    try {
      print('🔍 カスタム種目を読み込み開始...');
      final user = firebase_auth.FirebaseAuth.instance.currentUser;
      if (user == null) {
        print('❌ ユーザーが未ログイン - カスタム種目読み込みスキップ');
        return;
      }
      
      print('👤 User ID: ${user.uid}');
      
      final snapshot = await FirebaseFirestore.instance
          .collection('users')
          .doc(user.uid)
          .collection('custom_exercises')
          .get();
      
      print('📊 カスタム種目ドキュメント数: ${snapshot.docs.length}');
      
      final customExercises = <String, List<Map<String, dynamic>>>{};
      
      for (var doc in snapshot.docs) {
        final data = doc.data();
        final muscleGroup = data['muscle_group'] as String;
        final exerciseName = data['exercise_name'] as String;
        
        print('   種目発見: [$muscleGroup] $exerciseName (ID: ${doc.id})');
        
        if (!customExercises.containsKey(muscleGroup)) {
          customExercises[muscleGroup] = [];
        }
        
        customExercises[muscleGroup]!.add({
          'id': doc.id,
          'name': exerciseName,
        });
      }
      
      print('✅ カスタム種目読み込み完了: ${customExercises.length}部位');
      
      setState(() {
        _customExercises = customExercises;
      });
    } catch (e) {
      print('❌ カスタム種目の読み込みエラー: $e');
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    
    return Scaffold(
      appBar: AppBar(
        title: const Text('トレーニング記録'),
        backgroundColor: theme.colorScheme.primary,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // 日付表示
            _buildDateCard(),
            
            const SizedBox(height: 16),
            
            // 開始時間・終了時間
            _buildTimeSection(theme),
            
            const SizedBox(height: 16),
            
            // 部位選択
            _buildMuscleGroupSelector(theme),
            
            const SizedBox(height: 16),
            
            // 種目選択（部位が選択されている場合）
            if (_selectedMuscleGroup != null) ...[
              _buildExerciseSelector(theme),
              
              const SizedBox(height: 16),
              
              // セット入力
              _buildSetsSection(theme),
              
              const SizedBox(height: 16),
              
              // 保存ボタン
              ElevatedButton(
                onPressed: _saveWorkout,
                style: ElevatedButton.styleFrom(
                  backgroundColor: theme.colorScheme.primary,
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
                child: const Text(
                  '記録を保存',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }

  Widget _buildDateCard() {
    final isToday = _selectedDate.year == DateTime.now().year &&
        _selectedDate.month == DateTime.now().month &&
        _selectedDate.day == DateTime.now().day;
    
    print('🎨 日付カード表示: ${_selectedDate.year}/${_selectedDate.month}/${_selectedDate.day} (今日: $isToday)');
    
    return InkWell(
      onTap: _selectDate,
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(12),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.05),
              blurRadius: 8,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Row(
          children: [
            Icon(
              Icons.calendar_today,
              color: Theme.of(context).colorScheme.primary,
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    '${_selectedDate.year}年${_selectedDate.month}月${_selectedDate.day}日',
                    style: const TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  if (!isToday)
                    Text(
                      '予定のトレーニング',
                      style: TextStyle(
                        fontSize: 12,
                        color: Colors.orange[700],
                      ),
                    ),
                ],
              ),
            ),
            Icon(
              Icons.edit,
              size: 20,
              color: Theme.of(context).colorScheme.primary,
            ),
          ],
        ),
      ),
    );
  }
  
  Future<void> _selectDate() async {
    print('📅 日付選択ダイアログを開く - 現在の選択日: ${_selectedDate.year}/${_selectedDate.month}/${_selectedDate.day}');
    
    DateTime tempDate = _selectedDate;
    
    await showModalBottomSheet(
      context: context,
      backgroundColor: Colors.white,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (BuildContext context) {
        return Container(
          height: 350,
          padding: const EdgeInsets.all(16),
          child: Column(
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  TextButton(
                    onPressed: () {
                      print('📅 日付選択がキャンセルされました');
                      Navigator.pop(context);
                    },
                    child: const Text('キャンセル'),
                  ),
                  const Text(
                    '日付を選択',
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  TextButton(
                    onPressed: () {
                      print('📅 新しい日付が選択されました: ${tempDate.year}/${tempDate.month}/${tempDate.day}');
                      setState(() {
                        _selectedDate = tempDate;
                      });
                      print('📅 _selectedDate更新完了: ${_selectedDate.year}/${_selectedDate.month}/${_selectedDate.day}');
                      Navigator.pop(context);
                    },
                    child: const Text('完了'),
                  ),
                ],
              ),
              Expanded(
                child: CupertinoDatePicker(
                  mode: CupertinoDatePickerMode.date,
                  initialDateTime: _selectedDate,
                  minimumDate: DateTime(2020),
                  maximumDate: DateTime(2030),
                  dateOrder: DatePickerDateOrder.ymd, // 年月日の順序
                  onDateTimeChanged: (DateTime newDate) {
                    tempDate = newDate;
                    print('📅 日付変更中: ${newDate.year}/${newDate.month}/${newDate.day}');
                  },
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  // iOS風スクロールピッカーで時間選択
  void _showTimePicker(BuildContext context, bool isStartTime) {
    int selectedHour = isStartTime ? _startHour : _endHour;
    int selectedMinute = isStartTime ? _startMinute : _endMinute;

    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.white,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (BuildContext context) {
        return Container(
          height: 300,
          padding: const EdgeInsets.all(16),
          child: Column(
            children: [
              // ヘッダー
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  TextButton(
                    onPressed: () => Navigator.pop(context),
                    child: const Text('キャンセル'),
                  ),
                  Text(
                    isStartTime ? '開始時間' : '終了時間',
                    style: const TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  TextButton(
                    onPressed: () {
                      setState(() {
                        if (isStartTime) {
                          _startHour = selectedHour;
                          _startMinute = selectedMinute;
                        } else {
                          _endHour = selectedHour;
                          _endMinute = selectedMinute;
                        }
                      });
                      Navigator.pop(context);
                    },
                    child: const Text('完了'),
                  ),
                ],
              ),
              const Divider(),
              // iOS風スクロールピッカー
              Expanded(
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    // 時間ピッカー
                    Expanded(
                      child: CupertinoPicker(
                        scrollController: FixedExtentScrollController(
                          initialItem: selectedHour,
                        ),
                        itemExtent: 40,
                        onSelectedItemChanged: (int index) {
                          selectedHour = index;
                        },
                        children: List<Widget>.generate(24, (int index) {
                          return Center(
                            child: Text(
                              index.toString().padLeft(2, '0'),
                              style: const TextStyle(fontSize: 24),
                            ),
                          );
                        }),
                      ),
                    ),
                    const Text(':', style: TextStyle(fontSize: 32, fontWeight: FontWeight.bold)),
                    // 分ピッカー
                    Expanded(
                      child: CupertinoPicker(
                        scrollController: FixedExtentScrollController(
                          initialItem: selectedMinute,
                        ),
                        itemExtent: 40,
                        onSelectedItemChanged: (int index) {
                          selectedMinute = index;
                        },
                        children: List<Widget>.generate(60, (int index) {
                          return Center(
                            child: Text(
                              index.toString().padLeft(2, '0'),
                              style: const TextStyle(fontSize: 24),
                            ),
                          );
                        }),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildTimeSection(ThemeData theme) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.05),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const Text(
                'トレーニング時間',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(width: 8),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                decoration: BoxDecoration(
                  color: theme.colorScheme.primary.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(4),
                ),
                child: Text(
                  '全体',
                  style: TextStyle(
                    fontSize: 10,
                    fontWeight: FontWeight.bold,
                    color: theme.colorScheme.primary,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Row(
            children: [
              Expanded(
                child: _buildTimeButton(
                  label: '開始時間',
                  hour: _startHour,
                  minute: _startMinute,
                  onTap: () => _showTimePicker(context, true),
                  theme: theme,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: _buildTimeButton(
                  label: '終了時間',
                  hour: _endHour,
                  minute: _endMinute,
                  onTap: () => _showTimePicker(context, false),
                  theme: theme,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildTimeButton({
    required String label,
    required int hour,
    required int minute,
    required VoidCallback onTap,
    required ThemeData theme,
  }) {
    return InkWell(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          border: Border.all(color: theme.colorScheme.primary, width: 2),
          borderRadius: BorderRadius.circular(12),
          color: theme.colorScheme.primary.withValues(alpha: 0.05),
        ),
        child: Column(
          children: [
            Text(
              label,
              style: TextStyle(
                fontSize: 12,
                color: theme.colorScheme.primary,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              '${hour.toString().padLeft(2, '0')}:${minute.toString().padLeft(2, '0')}',
              style: TextStyle(
                fontSize: 32,
                fontWeight: FontWeight.bold,
                color: theme.colorScheme.primary,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildMuscleGroupSelector(ThemeData theme) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.05),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            '部位を選択',
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 12),
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: _muscleGroupExercises.keys.map((group) {
              final isSelected = _selectedMuscleGroup == group;
              return ChoiceChip(
                label: Text(group),
                selected: isSelected,
                onSelected: (selected) {
                  setState(() {
                    _selectedMuscleGroup = selected ? group : null;
                    _sets.clear();
                  });
                },
                selectedColor: theme.colorScheme.primary,
                labelStyle: TextStyle(
                  color: isSelected ? Colors.white : Colors.black,
                  fontWeight: FontWeight.bold,
                ),
              );
            }).toList(),
          ),
        ],
      ),
    );
  }

  Widget _buildExerciseSelector(ThemeData theme) {
    final exercises = _muscleGroupExercises[_selectedMuscleGroup!]!;
    final customExercises = _customExercises[_selectedMuscleGroup] ?? [];
    
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.05),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            '$_selectedMuscleGroupの種目',
            style: const TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 12),
          // デフォルト種目
          ...exercises.map((exercise) => ListTile(
            title: Text(exercise),
            trailing: const Icon(Icons.arrow_forward_ios, size: 16),
            onTap: () => _addExercise(exercise),
          )),
          // カスタム種目
          if (customExercises.isNotEmpty) ...[
            const Divider(),
            Padding(
              padding: const EdgeInsets.symmetric(vertical: 8),
              child: Text(
                'カスタム種目',
                style: TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.bold,
                  color: theme.colorScheme.primary,
                ),
              ),
            ),
            ...customExercises.map((customExercise) => ListTile(
              title: Text(customExercise['name']),
              trailing: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  IconButton(
                    icon: const Icon(Icons.delete, size: 20, color: Colors.red),
                    onPressed: () => _deleteCustomExercise(customExercise['id']),
                  ),
                  const Icon(Icons.arrow_forward_ios, size: 16),
                ],
              ),
              onTap: () => _addExercise(customExercise['name']),
            )),
          ],
          const Divider(),
          ListTile(
            leading: Icon(Icons.add, color: theme.colorScheme.primary),
            title: Text(
              '種目を追加（カスタム）',
              style: TextStyle(
                color: theme.colorScheme.primary,
                fontWeight: FontWeight.bold,
              ),
            ),
            onTap: _showAddCustomExerciseDialog,
          ),
        ],
      ),
    );
  }

  void _addExercise(String exerciseName) {
    setState(() {
      _sets.add(WorkoutSet(
        exerciseName: exerciseName,
        weight: 0,
        reps: 0,
      ));
    });
  }

  void _showAddCustomExerciseDialog() {
    final controller = TextEditingController();
    
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('カスタム種目を追加'),
        content: TextField(
          controller: controller,
          decoration: const InputDecoration(
            labelText: '種目名',
            hintText: '例: ケーブルクロスオーバー',
          ),
          autofocus: true,
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('キャンセル'),
          ),
          ElevatedButton(
            onPressed: () {
              if (controller.text.isNotEmpty) {
                _addExercise(controller.text);
                Navigator.pop(context);
                // Firestoreにカスタム種目を保存
                _saveCustomExercise(controller.text);
              }
            },
            child: const Text('追加'),
          ),
        ],
      ),
    );
  }

  Future<void> _saveCustomExercise(String exerciseName) async {
    try {
      final user = firebase_auth.FirebaseAuth.instance.currentUser;
      if (user != null) {
        await FirebaseFirestore.instance
            .collection('users')
            .doc(user.uid)
            .collection('custom_exercises')
            .add({
          'muscle_group': _selectedMuscleGroup,
          'exercise_name': exerciseName,
          'created_at': FieldValue.serverTimestamp(),
        });
        
        // カスタム種目リストを再読み込み
        _loadCustomExercises();
        
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('「$exerciseName」を保存しました')),
          );
        }
      }
    } catch (e) {
      print('カスタム種目の保存エラー: $e');
    }
  }
  
  Future<void> _deleteCustomExercise(String exerciseId) async {
    try {
      final user = firebase_auth.FirebaseAuth.instance.currentUser;
      if (user == null) return;
      
      // 確認ダイアログ
      final confirmed = await showDialog<bool>(
        context: context,
        builder: (context) => AlertDialog(
          title: const Text('カスタム種目を削除'),
          content: const Text('この種目を削除してもよろしいですか？'),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context, false),
              child: const Text('キャンセル'),
            ),
            ElevatedButton(
              onPressed: () => Navigator.pop(context, true),
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.red,
              ),
              child: const Text('削除'),
            ),
          ],
        ),
      );
      
      if (confirmed == true) {
        await FirebaseFirestore.instance
            .collection('users')
            .doc(user.uid)
            .collection('custom_exercises')
            .doc(exerciseId)
            .delete();
        
        // カスタム種目リストを再読み込み
        _loadCustomExercises();
        
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('カスタム種目を削除しました')),
          );
        }
      }
    } catch (e) {
      print('カスタム種目の削除エラー: $e');
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('削除エラー: $e')),
        );
      }
    }
  }

  Widget _buildSetsSection(ThemeData theme) {
    if (_sets.isEmpty) {
      return const SizedBox.shrink();
    }
    
    // 種目ごとにセットをグループ化
    final Map<String, List<WorkoutSet>> groupedSets = {};
    for (var set in _sets) {
      if (!groupedSets.containsKey(set.exerciseName)) {
        groupedSets[set.exerciseName] = [];
      }
      groupedSets[set.exerciseName]!.add(set);
    }
    
    // 現在選択中の種目名を取得
    final currentExercise = _sets.isNotEmpty ? _sets.last.exerciseName : '';
    
    return Column(
      children: [
        // 現在入力中のセット（履歴の上に配置）
        Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(12),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withValues(alpha: 0.05),
                blurRadius: 8,
                offset: const Offset(0, 2),
              ),
            ],
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // 選択中の種目名を表示
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: theme.colorScheme.primary.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Row(
                  children: [
                    Icon(
                      Icons.fitness_center,
                      color: theme.colorScheme.primary,
                      size: 20,
                    ),
                    const SizedBox(width: 8),
                    Text(
                      currentExercise,
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        color: theme.colorScheme.primary,
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 16),
              const Text(
                'セット',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 12),
              // 現在の種目のセットのみを表示
              ...groupedSets[currentExercise]!.asMap().entries.map((entry) {
                final index = entry.key;
                final set = entry.value;
                final globalIndex = _sets.indexOf(set);
                return Padding(
                  padding: const EdgeInsets.only(bottom: 12),
                  child: Row(
                    children: [
                      Text(
                        '${index + 1}',
                        style: const TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: TextField(
                          decoration: const InputDecoration(
                            labelText: '重量 (kg)',
                            border: OutlineInputBorder(),
                          ),
                          keyboardType: const TextInputType.numberWithOptions(decimal: true),
                          onChanged: (value) {
                            set.weight = double.tryParse(value) ?? 0;
                          },
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: TextField(
                          decoration: const InputDecoration(
                            labelText: '回数',
                            border: OutlineInputBorder(),
                          ),
                          keyboardType: TextInputType.number,
                          onChanged: (value) {
                            set.reps = int.tryParse(value) ?? 0;
                          },
                        ),
                      ),
                      IconButton(
                        icon: const Icon(Icons.delete, color: Colors.red),
                        onPressed: () {
                          setState(() {
                            _sets.removeAt(globalIndex);
                          });
                        },
                      ),
                    ],
                  ),
                );
              }),
              const SizedBox(height: 8),
              OutlinedButton.icon(
                onPressed: () {
                  if (_sets.isNotEmpty) {
                    _addExercise(_sets.last.exerciseName);
                  }
                },
                icon: const Icon(Icons.add),
                label: const Text('セットを追加'),
              ),
            ],
          ),
        ),
        
        // 入力済みセット履歴（現在の種目の下に配置）
        if (groupedSets.length > 1) ...[
          const SizedBox(height: 16),
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: Colors.blue[50],
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: Colors.blue[200]!),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Icon(Icons.history, color: Colors.blue[700], size: 20),
                    const SizedBox(width: 8),
                    Text(
                      '入力済みセット（保存前）',
                      style: TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.bold,
                        color: Colors.blue[700],
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 12),
                ...groupedSets.entries.where((entry) => entry.key != currentExercise).map((entry) {
                  final exerciseName = entry.key;
                  final sets = entry.value;
                  return Container(
                    margin: const EdgeInsets.only(bottom: 8),
                    padding: const EdgeInsets.all(8),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          exerciseName,
                          style: const TextStyle(
                            fontWeight: FontWeight.bold,
                            fontSize: 14,
                          ),
                        ),
                        const SizedBox(height: 4),
                        ...sets.asMap().entries.map((setEntry) {
                          final index = setEntry.key;
                          final set = setEntry.value;
                          final globalIndex = _sets.indexOf(set);
                          return Padding(
                            padding: const EdgeInsets.only(left: 8, top: 2, bottom: 2),
                            child: Row(
                              children: [
                                Expanded(
                                  child: Text(
                                    '${index + 1}セット目: ${set.weight}kg × ${set.reps}回',
                                    style: TextStyle(
                                      fontSize: 12,
                                      color: Colors.grey[700],
                                    ),
                                  ),
                                ),
                                InkWell(
                                  onTap: () {
                                    // ワンタップで即座に削除
                                    setState(() {
                                      _sets.removeAt(globalIndex);
                                    });
                                  },
                                  child: Container(
                                    padding: const EdgeInsets.all(4),
                                    child: Icon(
                                      Icons.delete_outline,
                                      size: 18,
                                      color: Colors.red[400],
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          );
                        }),
                      ],
                    ),
                  );
                }),
              ],
            ),
          ),
        ],
      ],
    );
  }

  Future<void> _saveWorkout() async {
    // 有効なセットのみをフィルタ（重量または回数が0より大きいもの）
    final validSets = _sets.where((set) => 
      set.weight > 0 || set.reps > 0
    ).toList();
    
    // バリデーション
    if (validSets.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('重量または回数を入力してください')),
      );
      return;
    }
    
    try {
      final user = firebase_auth.FirebaseAuth.instance.currentUser;
      if (user == null) {
        print('❌ ユーザーが未ログインです');
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('ログインしてください')),
        );
        return;
      }
      
      print('📝 トレーニング記録を保存開始...');
      print('👤 User ID: ${user.uid}');
      print('💪 部位: $_selectedMuscleGroup');
      print('🏋️ 全セット数: ${_sets.length}');
      print('✅ 有効セット数: ${validSets.length}');
      
      // 各有効セットの種目名を確認
      for (var i = 0; i < validSets.length; i++) {
        print('   セット${i + 1}: ${validSets[i].exerciseName} - ${validSets[i].weight}kg x ${validSets[i].reps}回');
      }
      
      // 時刻をHH:MM形式で保存
      final startTime = '${_startHour.toString().padLeft(2, '0')}:${_startMinute.toString().padLeft(2, '0')}';
      final endTime = '${_endHour.toString().padLeft(2, '0')}:${_endMinute.toString().padLeft(2, '0')}';
      
      // 選択された日付を使用
      final workoutDateTime = DateTime(
        _selectedDate.year,
        _selectedDate.month,
        _selectedDate.day,
        _startHour,
        _startMinute,
      );
      
      print('📅 選択日付: ${_selectedDate.year}/${_selectedDate.month}/${_selectedDate.day}');
      print('📅 保存日時: ${workoutDateTime.year}/${workoutDateTime.month}/${workoutDateTime.day} ${workoutDateTime.hour}:${workoutDateTime.minute}');
      print('📅 Timestamp: ${Timestamp.fromDate(workoutDateTime).toDate()}');
      
      final workoutData = {
        'user_id': user.uid,
        'date': Timestamp.fromDate(workoutDateTime),
        'muscle_group': _selectedMuscleGroup,
        'start_time': startTime,
        'end_time': endTime,
        'sets': validSets.map((set) => {
          'exercise_name': set.exerciseName,
          'weight': set.weight,
          'reps': set.reps,
        }).toList(),
        'created_at': FieldValue.serverTimestamp(),
      };
      
      print('📊 保存データ: $workoutData');
      
      final docRef = await FirebaseFirestore.instance
          .collection('workout_logs')
          .add(workoutData);
      
      print('✅ 保存成功！ Document ID: ${docRef.id}');
      
      if (mounted) {
        // ホーム画面（記録画面タブ）に戻る - trueを返して更新をトリガー
        Navigator.pop(context, true);
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('記録を保存しました')),
        );
      }
    } catch (e) {
      print('❌ 保存エラー: $e');
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('保存エラー: $e')),
      );
    }
  }
}

class WorkoutSet {
  final String exerciseName;
  double weight;
  int reps;
  
  WorkoutSet({
    required this.exerciseName,
    required this.weight,
    required this.reps,
  });
}
