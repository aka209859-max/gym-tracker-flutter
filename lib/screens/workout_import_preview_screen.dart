import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:provider/provider.dart';
import '../providers/navigation_provider.dart';

/// トレーニングデータインポートプレビュー画面
/// 
/// 画像から抽出したデータを確認し、部位を選択してFirestoreに登録
class WorkoutImportPreviewScreen extends StatefulWidget {
  final Map<String, dynamic> extractedData;

  const WorkoutImportPreviewScreen({
    super.key,
    required this.extractedData,
  });

  @override
  State<WorkoutImportPreviewScreen> createState() =>
      _WorkoutImportPreviewScreenState();
}

class _WorkoutImportPreviewScreenState
    extends State<WorkoutImportPreviewScreen> {
  late Map<int, String> _selectedBodyParts; // 種目インデックス → 選択された部位
  bool _isImporting = false;

  // 部位選択肢
  static const List<String> _bodyPartOptions = [
    '胸',
    '脚',
    '背中',
    '肩',
    '二頭',
    '三頭',
    '有酸素',
  ];

  @override
  void initState() {
    super.initState();
    _initializeBodyParts();
  }

  /// 部位の初期値を設定
  void _initializeBodyParts() {
    _selectedBodyParts = {};
    final exercises = widget.extractedData['exercises'] as List<dynamic>?;
    
    if (exercises != null) {
      for (int i = 0; i < exercises.length; i++) {
        final exercise = exercises[i] as Map<String, dynamic>;
        final exerciseName = exercise['name'] as String;
        
        // 既知の種目は自動設定、未知は「胸」をデフォルト
        _selectedBodyParts[i] = _estimateBodyPart(exerciseName);
      }
    }
  }

  /// 種目名から部位を推定
  String _estimateBodyPart(String exerciseName) {
    final mapping = {
      // 胸
      'ベンチプレス': '胸',
      'ダンベルプレス': '胸',
      'インクラインプレス': '胸',
      'ケーブルフライ': '胸',
      'ディップス': '胸',
      
      // 背中
      'ラットプルダウン': '背中',
      'チンニング': '背中',
      'チンニング（懸垂）': '背中',
      '懸垂': '背中',
      'ベントオーバーローイング': '背中',
      'デッドリフト': '背中',
      'シーテッドロウ': '背中',
      
      // 脚
      'スクワット': '脚',
      'レッグプレス': '脚',
      'レッグエクステンション': '脚',
      'レッグカール': '脚',
      'ランジ': '脚',
      
      // 肩
      'ショルダープレス': '肩',
      'サイドレイズ': '肩',
      'フロントレイズ': '肩',
      'リアレイズ': '肩',
      
      // 二頭
      'バーベルカール': '二頭',
      'ダンベルカール': '二頭',
      'ハンマーカール': '二頭',
      
      // 三頭
      'トライセプスダウン': '三頭',
      'トライセプスエクステンション': '三頭',
      'フレンチプレス': '三頭',
      
      // 有酸素
      'ランニング': '有酸素',
      'ウォーキング': '有酸素',
      'バイク': '有酸素',
      'エアロバイク': '有酸素',
    };
    
    return mapping[exerciseName] ?? '胸'; // デフォルト: 胸
  }

  /// データをFirestoreに登録
  Future<void> _importData() async {
    if (_isImporting) return;

    setState(() {
      _isImporting = true;
    });

    try {
      print('🔄 [IMPORT] データ取り込み開始...');
      
      final user = FirebaseAuth.instance.currentUser;
      if (user == null) {
        throw Exception('ユーザーが認証されていません');
      }
      print('✅ [IMPORT] ユーザー確認: ${user.uid}');

      // 日付をパース
      final dateString = widget.extractedData['date'] as String;
      final date = DateTime.parse(dateString);
      print('✅ [IMPORT] 日付パース: $date');

      // 種目データを変換（既存のworkout_logs形式に完全一致させる）
      final exercises = widget.extractedData['exercises'] as List<dynamic>;
      print('✅ [IMPORT] 種目数: ${exercises.length}');
      
      // すべての種目のセットを1つのリストに統合（既存形式: flat sets list）
      final allSets = <Map<String, dynamic>>[];

      for (int i = 0; i < exercises.length; i++) {
        final exercise = exercises[i] as Map<String, dynamic>;
        final exerciseName = exercise['name'] as String;
        final sets = exercise['sets'] as List<dynamic>;
        
        print('📝 [IMPORT] 種目${i + 1}: $exerciseName (${sets.length}セット)');
        
        // 各セットをflat list形式で追加
        for (final set in sets) {
          final setData = set as Map<String, dynamic>;
          allSets.add({
            'exercise_name': exerciseName,
            'weight': (setData['weight_kg'] as num).toDouble(),
            'reps': setData['reps'],
            'is_completed': true,
            'has_assist': false,
            'set_type': 'normal',
            'is_bodyweight_mode': (setData['weight_kg'] as num) == 0,
          });
        }
      }

      // 開始・終了時刻を日付から生成（デフォルト: 9:00-11:00）
      final startTime = DateTime(date.year, date.month, date.day, 9, 0);
      final endTime = DateTime(date.year, date.month, date.day, 11, 0);
      
      // 部位を決定（最初の種目の部位を使用）
      final muscleGroup = _selectedBodyParts[0] ?? '胸';
      print('✅ [IMPORT] 部位: $muscleGroup, セット総数: ${allSets.length}');

      print('🔄 [IMPORT] Firestoreに保存中...');
      // Firestoreに登録（既存のworkout_logs形式に完全一致）
      final docRef = await FirebaseFirestore.instance.collection('workout_logs').add({
        'user_id': user.uid,
        'muscle_group': muscleGroup,
        'date': Timestamp.fromDate(date),
        'start_time': Timestamp.fromDate(startTime),
        'end_time': Timestamp.fromDate(endTime),
        'sets': allSets,
        'created_at': FieldValue.serverTimestamp(),
      });
      
      print('✅ [IMPORT] Firestore保存完了: ${docRef.id}');

      if (mounted) {
        print('✅ [IMPORT] 成功メッセージ表示中...');
        // 成功メッセージ
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              '✅ ${exercises.length}種目のトレーニング記録を取り込みました',
              style: const TextStyle(fontWeight: FontWeight.bold),
            ),
            backgroundColor: Colors.green.shade700,
            duration: const Duration(seconds: 3),
          ),
        );

        print('🔙 [IMPORT] 画面遷移開始...');
        
        // 短いディレイで成功メッセージを表示
        await Future.delayed(const Duration(milliseconds: 300));
        
        if (!mounted) return;
        
        // すべてのダイアログ/プレビュー画面を閉じてルート画面に戻る
        Navigator.of(context).popUntil((route) => route.isFirst);
        print('✅ [IMPORT] ルート画面に戻りました');
        
        // NavigationProviderを使って記録タブに自動切り替え + 日付指定
        if (mounted) {
          await Future.delayed(const Duration(milliseconds: 200));
          
          final navigationProvider = Provider.of<NavigationProvider>(
            context, 
            listen: false,
          );
          
          // 記録画面（index=0）に切り替え + 該当日を指定
          navigationProvider.navigateToRecordWithDate(date);
          print('✅ [IMPORT] 記録タブに切り替え: ${date.year}/${date.month}/${date.day}');
          
          // 成功通知
          await Future.delayed(const Duration(milliseconds: 300));
          if (!mounted) return;
          
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    '✅ トレーニング記録を取り込みました',
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 15,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    '📅 ${date.month}/${date.day}の記録が表示されます',
                    style: const TextStyle(fontSize: 13),
                  ),
                ],
              ),
              backgroundColor: Colors.green.shade700,
              duration: const Duration(seconds: 3),
            ),
          );
        }
        
        print('✅ [IMPORT] 取り込み処理完了！記録画面に遷移しました');
      }
    } catch (e, stackTrace) {
      print('❌❌❌ [IMPORT] データ取り込みエラー: $e');
      print('📍 [IMPORT] スタックトレース:');
      print(stackTrace.toString());
      
      if (mounted) {
        final errorMsg = e.toString().length > 100 
            ? e.toString().substring(0, 100) 
            : e.toString();
            
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('❌ データ取り込みエラー: $errorMsg'),
            backgroundColor: Colors.red.shade700,
            duration: const Duration(seconds: 5),
          ),
        );
        
        // エラー時も画面を閉じる（白い画面を防ぐ）
        try {
          Navigator.of(context).pop();
          print('✅ [IMPORT] エラー後に画面を閉じました');
        } catch (navError) {
          print('❌ [IMPORT] Navigator.pop()エラー: $navError');
        }
      }
    } finally {
      if (mounted) {
        setState(() {
          _isImporting = false;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final dateString = widget.extractedData['date'] as String?;
    final date = dateString != null ? DateTime.parse(dateString) : DateTime.now();
    final exercises = widget.extractedData['exercises'] as List<dynamic>? ?? [];

    return Scaffold(
      appBar: AppBar(
        title: const Text('📸 トレーニング記録の取り込み'),
        backgroundColor: const Color(0xFF1A237E),
      ),
      body: Column(
        children: [
          // 日付表示
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(16),
            color: Colors.grey.shade100,
            child: Row(
              children: [
                const Icon(Icons.calendar_today, color: Color(0xFF1A237E)),
                const SizedBox(width: 12),
                Text(
                  '日付: ${date.year}年${date.month}月${date.day}日',
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
          ),
          
          // 種目リスト
          Expanded(
            child: ListView.builder(
              padding: const EdgeInsets.all(16),
              itemCount: exercises.length,
              itemBuilder: (context, index) {
                final exercise = exercises[index] as Map<String, dynamic>;
                final exerciseName = exercise['name'] as String;
                final sets = exercise['sets'] as List<dynamic>;

                return Card(
                  margin: const EdgeInsets.only(bottom: 16),
                  elevation: 2,
                  child: Padding(
                    padding: const EdgeInsets.all(16),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        // 種目名
                        Row(
                          children: [
                            const Icon(Icons.fitness_center, color: Color(0xFF1A237E)),
                            const SizedBox(width: 8),
                            Expanded(
                              child: Text(
                                exerciseName,
                                style: const TextStyle(
                                  fontSize: 18,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 12),
                        
                        // 部位選択ドロップダウン
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
                          decoration: BoxDecoration(
                            color: Colors.blue.shade50,
                            borderRadius: BorderRadius.circular(8),
                            border: Border.all(color: Colors.blue.shade200),
                          ),
                          child: Row(
                            children: [
                              const Text(
                                '部位: ',
                                style: TextStyle(
                                  fontSize: 14,
                                  fontWeight: FontWeight.w500,
                                ),
                              ),
                              Expanded(
                                child: DropdownButton<String>(
                                  value: _selectedBodyParts[index],
                                  isExpanded: true,
                                  underline: const SizedBox.shrink(),
                                  items: _bodyPartOptions.map((bodyPart) {
                                    return DropdownMenuItem(
                                      value: bodyPart,
                                      child: Text(
                                        bodyPart,
                                        style: const TextStyle(
                                          fontSize: 16,
                                          fontWeight: FontWeight.bold,
                                        ),
                                      ),
                                    );
                                  }).toList(),
                                  onChanged: (value) {
                                    if (value != null) {
                                      setState(() {
                                        _selectedBodyParts[index] = value;
                                      });
                                    }
                                  },
                                ),
                              ),
                            ],
                          ),
                        ),
                        const SizedBox(height: 12),
                        
                        // セット情報
                        ...sets.asMap().entries.map((entry) {
                          final setIndex = entry.key;
                          final set = entry.value as Map<String, dynamic>;
                          final weight = (set['weight_kg'] as num).toDouble();
                          final reps = set['reps'] as int;
                          
                          return Padding(
                            padding: const EdgeInsets.only(bottom: 4),
                            child: Text(
                              'セット${setIndex + 1}: ${weight == 0 ? '自重' : '${weight}kg'} × ${reps}回',
                              style: TextStyle(
                                fontSize: 14,
                                color: Colors.grey.shade700,
                              ),
                            ),
                          );
                        }),
                      ],
                    ),
                  ),
                );
              },
            ),
          ),
          
          // ボタンエリア
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: Colors.white,
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withValues(alpha: 0.1),
                  blurRadius: 4,
                  offset: const Offset(0, -2),
                ),
              ],
            ),
            child: Row(
              children: [
                Expanded(
                  child: OutlinedButton(
                    onPressed: _isImporting ? null : () => Navigator.of(context).pop(),
                    style: OutlinedButton.styleFrom(
                      padding: const EdgeInsets.symmetric(vertical: 16),
                      side: const BorderSide(color: Colors.grey),
                    ),
                    child: const Text(
                      'キャンセル',
                      style: TextStyle(fontSize: 16),
                    ),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  flex: 2,
                  child: ElevatedButton(
                    onPressed: _isImporting ? null : _importData,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFF1A237E),
                      padding: const EdgeInsets.symmetric(vertical: 16),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(8),
                      ),
                    ),
                    child: _isImporting
                        ? const SizedBox(
                            height: 20,
                            width: 20,
                            child: CircularProgressIndicator(
                              strokeWidth: 2,
                              valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                            ),
                          )
                        : const Text(
                            '承認して取り込む',
                            style: TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
