import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:intl/intl.dart';
import '../../models/workout_note.dart';
import '../../services/workout_note_service.dart';

/// シンプルなトレーニング詳細画面（workout_logsデータ用）
class SimpleWorkoutDetailScreen extends StatefulWidget {
  final String workoutId;
  final Map<String, dynamic> workoutData;

  const SimpleWorkoutDetailScreen({
    super.key,
    required this.workoutId,
    required this.workoutData,
  });

  @override
  State<SimpleWorkoutDetailScreen> createState() => _SimpleWorkoutDetailScreenState();
}

class _SimpleWorkoutDetailScreenState extends State<SimpleWorkoutDetailScreen> {
  final WorkoutNoteService _noteService = WorkoutNoteService();
  WorkoutNote? _workoutNote;
  bool _isLoadingNote = true;

  @override
  void initState() {
    super.initState();
    _loadWorkoutNote();
  }

  // ワークアウトのメモを読み込み
  Future<void> _loadWorkoutNote() async {
    try {
      final note = await _noteService.getNoteByWorkoutSession(widget.workoutId);
      if (mounted) {
        setState(() {
          _workoutNote = note;
          _isLoadingNote = false;
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _isLoadingNote = false;
        });
      }
      debugPrint('⚠️ メモの読み込みエラー: $e');
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final data = widget.workoutData;
    
    // データ解析
    final muscleGroup = data['muscle_group'] as String? ?? '不明';
    final date = (data['date'] as Timestamp?)?.toDate() ?? DateTime.now();
    final startTime = (data['start_time'] as Timestamp?)?.toDate();
    final endTime = (data['end_time'] as Timestamp?)?.toDate();
    final sets = data['sets'] as List<dynamic>? ?? [];
    
    // トレーニング時間計算
    String durationText = '不明';
    if (startTime != null && endTime != null) {
      final duration = endTime.difference(startTime);
      durationText = '${duration.inMinutes}分';
    }
    
    // 種目ごとにセットをグループ化
    final exerciseMap = <String, List<Map<String, dynamic>>>{};
    for (final set in sets) {
      if (set is Map<String, dynamic>) {
        final exerciseName = set['exercise_name'] as String? ?? '不明';
        exerciseMap.putIfAbsent(exerciseName, () => []).add(set);
      }
    }

    return Scaffold(
      appBar: AppBar(
        title: const Text('トレーニング詳細'),
        actions: [
          IconButton(
            icon: const Icon(Icons.delete),
            onPressed: () => _confirmDelete(context),
          ),
        ],
      ),
      body: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // ヘッダー情報
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(24),
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: [theme.colorScheme.primary, theme.colorScheme.secondary],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    DateFormat('yyyy年MM月dd日 (E)', 'ja').format(date),
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Row(
                    children: [
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                        decoration: BoxDecoration(
                          color: Colors.white.withValues(alpha: 0.3),
                          borderRadius: BorderRadius.circular(16),
                        ),
                        child: Text(
                          muscleGroup,
                          style: const TextStyle(color: Colors.white, fontSize: 16),
                        ),
                      ),
                      const SizedBox(width: 12),
                      Text(
                        durationText,
                        style: const TextStyle(color: Colors.white70, fontSize: 14),
                      ),
                    ],
                  ),
                ],
              ),
            ),

            // トレーニングメモセクション
            Padding(
              padding: const EdgeInsets.all(16),
              child: _buildNoteSection(theme),
            ),

            // 種目リスト
            Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    '実施種目',
                    style: TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                      color: theme.colorScheme.primary,
                    ),
                  ),
                  const SizedBox(height: 16),
                  ...exerciseMap.entries.map((entry) {
                    return _buildExerciseCard(entry.key, entry.value, theme);
                  }).toList(),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  // メモセクション
  Widget _buildNoteSection(ThemeData theme) {
    return Card(
      elevation: 3,
      child: InkWell(
        onTap: _showNoteDialog,
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Icon(Icons.edit_note, size: 24, color: theme.colorScheme.primary),
                  const SizedBox(width: 8),
                  const Text(
                    'トレーニングメモ',
                    style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                  ),
                  const Spacer(),
                  if (_isLoadingNote)
                    const SizedBox(
                      width: 20,
                      height: 20,
                      child: CircularProgressIndicator(strokeWidth: 2),
                    )
                  else
                    Icon(
                      _workoutNote == null ? Icons.add_circle_outline : Icons.edit,
                      color: theme.colorScheme.primary,
                    ),
                ],
              ),
              if (_workoutNote != null) ...[
                const SizedBox(height: 12),
                const Divider(),
                const SizedBox(height: 12),
                Text(
                  _workoutNote!.content,
                  style: TextStyle(fontSize: 14, color: Colors.grey[800]),
                  maxLines: 3,
                  overflow: TextOverflow.ellipsis,
                ),
              ] else ...[
                const SizedBox(height: 8),
                Text(
                  'タップしてメモを追加',
                  style: TextStyle(fontSize: 14, color: Colors.grey[600]),
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }

  // 種目カード
  Widget _buildExerciseCard(String exerciseName, List<Map<String, dynamic>> sets, ThemeData theme) {
    return Card(
      margin: const EdgeInsets.only(bottom: 16),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(Icons.fitness_center, color: theme.colorScheme.primary),
                const SizedBox(width: 8),
                Text(
                  exerciseName,
                  style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                ),
              ],
            ),
            const SizedBox(height: 12),
            ...sets.asMap().entries.map((entry) {
              final index = entry.key;
              final set = entry.value;
              final weight = (set['weight'] as num?)?.toDouble() ?? 0.0;
              final reps = set['reps'] as int? ?? 0;
              
              return Padding(
                padding: const EdgeInsets.symmetric(vertical: 4),
                child: Row(
                  children: [
                    Container(
                      width: 32,
                      height: 32,
                      decoration: BoxDecoration(
                        color: theme.colorScheme.primaryContainer,
                        shape: BoxShape.circle,
                      ),
                      child: Center(
                        child: Text(
                          '${index + 1}',
                          style: TextStyle(
                            fontWeight: FontWeight.bold,
                            color: theme.colorScheme.onPrimaryContainer,
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(width: 16),
                    Text(
                      '${weight}kg × ${reps}回',
                      style: const TextStyle(fontSize: 16),
                    ),
                  ],
                ),
              );
            }).toList(),
          ],
        ),
      ),
    );
  }

  // メモダイアログ
  void _showNoteDialog() {
    final controller = TextEditingController(text: _workoutNote?.content ?? '');
    
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('トレーニングメモ'),
        content: TextField(
          controller: controller,
          maxLines: 5,
          decoration: const InputDecoration(
            hintText: 'メモを入力...',
            border: OutlineInputBorder(),
          ),
        ),
        actions: [
          if (_workoutNote != null)
            TextButton(
              onPressed: () async {
                await _deleteNote();
                if (mounted) Navigator.pop(context);
              },
              child: const Text('削除', style: TextStyle(color: Colors.red)),
            ),
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('キャンセル'),
          ),
          ElevatedButton(
            onPressed: () async {
              await _saveNote(controller.text);
              if (mounted) Navigator.pop(context);
            },
            child: const Text('保存'),
          ),
        ],
      ),
    );
  }

  // メモ保存
  Future<void> _saveNote(String content) async {
    if (content.trim().isEmpty) return;

    try {
      final userId = widget.workoutData['user_id'] as String? ?? '';
      
      if (_workoutNote == null) {
        final note = await _noteService.createNote(
          userId: userId,
          workoutSessionId: widget.workoutId,
          content: content,
        );
        setState(() {
          _workoutNote = note;
        });
      } else {
        final updatedNote = await _noteService.updateNote(_workoutNote!.id, content);
        setState(() {
          _workoutNote = updatedNote;
        });
      }

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('メモを保存しました'), backgroundColor: Colors.green),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('メモの保存に失敗しました: $e')),
        );
      }
    }
  }

  // メモ削除
  Future<void> _deleteNote() async {
    if (_workoutNote == null) return;

    try {
      await _noteService.deleteNote(_workoutNote!.id);
      setState(() {
        _workoutNote = null;
      });

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('メモを削除しました'), backgroundColor: Colors.green),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('メモの削除に失敗しました: $e')),
        );
      }
    }
  }

  // 削除確認
  void _confirmDelete(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('削除確認'),
        content: const Text('このトレーニング記録を削除しますか？'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('キャンセル'),
          ),
          ElevatedButton(
            onPressed: () async {
              Navigator.pop(context);
              await _deleteWorkout();
            },
            style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
            child: const Text('削除'),
          ),
        ],
      ),
    );
  }

  // ワークアウト削除
  Future<void> _deleteWorkout() async {
    try {
      await FirebaseFirestore.instance
          .collection('workout_logs')
          .doc(widget.workoutId)
          .delete();

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('トレーニング記録を削除しました'), backgroundColor: Colors.green),
        );
        Navigator.pop(context);
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('削除に失敗しました: $e')),
        );
      }
    }
  }
}
