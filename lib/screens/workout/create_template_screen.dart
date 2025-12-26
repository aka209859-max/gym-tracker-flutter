import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import '../../models/workout_template.dart';

/// テンプレート作成画面
class CreateTemplateScreen extends StatefulWidget {
  const CreateTemplateScreen({super.key});

  @override
  State<CreateTemplateScreen> createState() => _CreateTemplateScreenState();
}

class _CreateTemplateScreenState extends State<CreateTemplateScreen> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _descriptionController = TextEditingController();
  
  late String _selectedMuscleGroup; // didChangeDependenciesで初期化
  final List<TemplateExerciseBuilder> _exercises = [];
  bool _isSaving = false;

  late List<String> _muscleGroups; // didChangeDependenciesで初期化
  
  @override
  void initState() {
    super.initState();
    _autoLoginIfNeeded();
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    // 🔧 Phase 2 Fix: context依存の初期化はここで実行
    _selectedMuscleGroup = '胸';
    _muscleGroups = ['胸', AppLocalizations.of(context)!.bodyPartBack, '脚', '肩', AppLocalizations.of(context)!.bodyPartBiceps, AppLocalizations.of(context)!.bodyPartTriceps];
    _muscleGroupExercises = {
      '胸': [AppLocalizations.of(context)!.exerciseBenchPress, AppLocalizations.of(context)!.exerciseDumbbellPress, AppLocalizations.of(context)!.exerciseInclinePress, AppLocalizations.of(context)!.exerciseCableFly, AppLocalizations.of(context)!.exerciseDips],
      '脚': [AppLocalizations.of(context)!.exerciseSquat, AppLocalizations.of(context)!.exerciseLegPress, AppLocalizations.of(context)!.exerciseLegExtension, AppLocalizations.of(context)!.exerciseLegCurl, AppLocalizations.of(context)!.exerciseCalfRaise],
      AppLocalizations.of(context)!.bodyPartBack: [AppLocalizations.of(context)!.exerciseDeadlift, AppLocalizations.of(context)!.exerciseLatPulldown, AppLocalizations.of(context)!.exerciseBentOverRow, AppLocalizations.of(context)!.exerciseSeatedRow, AppLocalizations.of(context)!.exercisePullUp],
      '肩': [AppLocalizations.of(context)!.exerciseShoulderPress, AppLocalizations.of(context)!.exerciseSideRaise, AppLocalizations.of(context)!.exerciseFrontRaise, AppLocalizations.of(context)!.exerciseRearDeltFly, AppLocalizations.of(context)!.exerciseUprightRow],
      AppLocalizations.of(context)!.bodyPartBiceps: [AppLocalizations.of(context)!.exerciseBarbellCurl, AppLocalizations.of(context)!.exerciseDumbbellCurl, AppLocalizations.of(context)!.exerciseHammerCurl, AppLocalizations.of(context)!.exercisePreacherCurl, AppLocalizations.of(context)!.exerciseCableCurl],
      AppLocalizations.of(context)!.bodyPartTriceps: [AppLocalizations.of(context)!.exerciseTricepsExtension, AppLocalizations.of(context)!.exerciseSkullCrusher, AppLocalizations.of(context)!.workout_22752b72, AppLocalizations.of(context)!.exerciseDips, AppLocalizations.of(context)!.exerciseKickback],
    };
  }
  
  /// 未ログイン時に自動的に匿名ログイン
  Future<void> _autoLoginIfNeeded() async {
    final user = FirebaseAuth.instance.currentUser;
    if (user == null) {
      try {
        await FirebaseAuth.instance.signInAnonymously();
        debugPrint('✅ テンプレート作成: 匿名認証成功');
      } catch (e) {
        debugPrint('❌ テンプレート作成: 匿名認証エラー: $e');
      }
    }
  }
  
  late Map<String, List<String>> _muscleGroupExercises; // didChangeDependenciesで初期化

  @override
  void dispose() {
    _nameController.dispose();
    _descriptionController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Scaffold(
      appBar: AppBar(
        title: Text(AppLocalizations.of(context)!.createTemplate),
        backgroundColor: theme.colorScheme.primary,
        foregroundColor: Colors.white,
        actions: [
          TextButton.icon(
            onPressed: _isSaving ? null : _saveTemplate,
            icon: _isSaving
                ? SizedBox(
                    width: 16,
                    height: 16,
                    child: CircularProgressIndicator(
                      strokeWidth: 2,
                      valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                    ),
                  )
                : Icon(Icons.check, color: Colors.white),
            label: Text(
              AppLocalizations.of(context)!.save,
              style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
            ),
          ),
        ],
      ),
      body: Form(
        key: _formKey,
        child: ListView(
          padding: const EdgeInsets.all(16),
          children: [
            // テンプレート名
            TextFormField(
              controller: _nameController,
              decoration: InputDecoration(
                labelText: AppLocalizations.of(context)!.templateName,
                hintText: '例: 胸トレーニング A',
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
                prefixIcon: Icon(Icons.label),
              ),
              validator: (value) {
                if (value == null || value.isEmpty) {
                  return AppLocalizations.of(context)!.workout_e4a17e51;
                }
                return null;
              },
            ),
            
            SizedBox(height: 16),
            
            // 説明（オプション）
            TextFormField(
              controller: _descriptionController,
              decoration: InputDecoration(
                labelText: '説明（オプション）',
                hintText: '例: 胸を集中的に鍛えるメニュー',
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
                prefixIcon: Icon(Icons.description),
              ),
              maxLines: 2,
            ),
            
            SizedBox(height: 24),
            
            // 部位選択
            Text(
              AppLocalizations.of(context)!.workout_9b2523e6,
              style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
            ),
            SizedBox(height: 8),
            Wrap(
              spacing: 8,
              runSpacing: 8,
              children: _muscleGroups.map((group) {
                final isSelected = _selectedMuscleGroup == group;
                return ChoiceChip(
                  label: Text(group),
                  selected: isSelected,
                  onSelected: (selected) {
                    setState(() {
                      _selectedMuscleGroup = group;
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
            
            SizedBox(height: 24),
            
            // 種目リスト
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  AppLocalizations.of(context)!.workout_6e8a7475,
                  style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                ),
                TextButton.icon(
                  onPressed: _addExercise,
                  icon: Icon(Icons.add),
                  label: Text(AppLocalizations.of(context)!.workout_c3a95268),
                ),
              ],
            ),
            
            if (_exercises.isEmpty)
              Container(
                padding: const EdgeInsets.all(32),
                decoration: BoxDecoration(
                  color: Colors.grey[100],
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: Colors.grey[300]!),
                ),
                child: Column(
                  children: [
                    Icon(Icons.fitness_center, size: 48, color: Colors.grey[400]),
                    SizedBox(height: 8),
                    Text(
                      AppLocalizations.of(context)!.workout_d90b7b6b,
                      style: TextStyle(color: Colors.grey[600]),
                    ),
                  ],
                ),
              )
            else
              ..._exercises.asMap().entries.map((entry) {
                final index = entry.key;
                final exercise = entry.value;
                return _buildExerciseCard(index, exercise);
              }),
            
            SizedBox(height: 80), // FAB用スペース
          ],
        ),
      ),
    );
  }

  /// 種目カード
  Widget _buildExerciseCard(int index, TemplateExerciseBuilder exercise) {
    final theme = Theme.of(context);

    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(4),
                  decoration: BoxDecoration(
                    color: theme.colorScheme.primary.withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(4),
                  ),
                  child: Text(
                    '${index + 1}',
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                      color: theme.colorScheme.primary,
                    ),
                  ),
                ),
                SizedBox(width: 8),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // ドロップダウンまたはカスタム入力を表示
                      if (exercise.isCustomExercise)
                        TextFormField(
                          initialValue: exercise.exerciseName,
                          decoration: InputDecoration(
                            labelText: 'カスタム種目名',
                            border: const OutlineInputBorder(),
                            contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                            suffixIcon: IconButton(
                              icon: Icon(Icons.list, size: 20),
                              tooltip: AppLocalizations.of(context)!.workout_16dc7c2c,
                              onPressed: () {
                                setState(() {
                                  exercise.isCustomExercise = false;
                                  exercise.exerciseName = _muscleGroupExercises[_selectedMuscleGroup]![0];
                                });
                              },
                            ),
                          ),
                          onChanged: (value) {
                            setState(() {
                              exercise.exerciseName = value;
                            });
                          },
                        )
                      else
                        DropdownButtonFormField<String>(
                          value: exercise.exerciseName,
                          decoration: const InputDecoration(
                            labelText: AppLocalizations.of(context)!.exercise,
                            border: OutlineInputBorder(),
                            contentPadding: EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                          ),
                          items: [
                            // プリセット種目
                            ..._muscleGroupExercises[_selectedMuscleGroup]!
                                .map((name) => DropdownMenuItem(
                                      value: name,
                                      child: Text(name),
                                    )),
                            // カスタム種目追加オプション
                            const DropdownMenuItem(
                              value: '___custom___',
                              child: Row(
                                children: [
                                  Icon(Icons.add_circle_outline, size: 18, color: Colors.blue),
                                  SizedBox(width: 8),
                                  Text(AppLocalizations.of(context)!.addCustomExercise, style: TextStyle(color: Colors.blue, fontWeight: FontWeight.bold)),
                                ],
                              ),
                            ),
                          ],
                          onChanged: (value) {
                            if (value == '___custom___') {
                              // カスタム種目モードに切り替え
                              setState(() {
                                exercise.isCustomExercise = true;
                                exercise.exerciseName = '';
                              });
                            } else {
                              setState(() {
                                exercise.exerciseName = value!;
                              });
                            }
                          },
                        ),
                    ],
                  ),
                ),
                IconButton(
                  icon: Icon(Icons.delete, color: Colors.red),
                  onPressed: () {
                    setState(() {
                      _exercises.removeAt(index);
                    });
                  },
                ),
              ],
            ),
            
            SizedBox(height: 12),
            
            Row(
              children: [
                Expanded(
                  child: TextFormField(
                    initialValue: exercise.targetSets.toString(),
                    decoration: const InputDecoration(
                      labelText: AppLocalizations.of(context)!.setsCount,
                      border: OutlineInputBorder(),
                      contentPadding: EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                    ),
                    keyboardType: TextInputType.number,
                    onChanged: (value) {
                      exercise.targetSets = int.tryParse(value) ?? 3;
                    },
                  ),
                ),
                SizedBox(width: 12),
                Expanded(
                  child: TextFormField(
                    initialValue: exercise.targetReps.toString(),
                    decoration: const InputDecoration(
                      labelText: AppLocalizations.of(context)!.repsCount,
                      border: OutlineInputBorder(),
                      contentPadding: EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                    ),
                    keyboardType: TextInputType.number,
                    onChanged: (value) {
                      exercise.targetReps = int.tryParse(value) ?? 10;
                    },
                  ),
                ),
                SizedBox(width: 12),
                Expanded(
                  child: TextFormField(
                    initialValue: exercise.targetWeight?.toString() ?? '',
                    decoration: const InputDecoration(
                      labelText: '重量(kg)',
                      border: OutlineInputBorder(),
                      contentPadding: EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                    ),
                    keyboardType: const TextInputType.numberWithOptions(decimal: true),
                    onChanged: (value) {
                      exercise.targetWeight = double.tryParse(value);
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

  /// 種目追加
  void _addExercise() {
    setState(() {
      _exercises.add(TemplateExerciseBuilder(
        exerciseName: _muscleGroupExercises[_selectedMuscleGroup]!.first,
        targetSets: 3,
        targetReps: 10,
      ));
    });
  }

  /// テンプレート保存
  Future<void> _saveTemplate() async {
    if (!_formKey.currentState!.validate()) {
      return;
    }

    if (_exercises.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(AppLocalizations.of(context)!.workout_bf13cb6c)),
      );
      return;
    }

    setState(() => _isSaving = true);

    try {
      final user = FirebaseAuth.instance.currentUser;
      if (user == null) {
        // 匿名ログイン実装により、この状態には通常到達しない
        throw Exception(AppLocalizations.of(context)!.workout_07d18a44);
      }

      final template = WorkoutTemplate(
        id: '',
        userId: user.uid,
        name: _nameController.text,
        description: _descriptionController.text.isNotEmpty
            ? _descriptionController.text
            : null,
        muscleGroup: _selectedMuscleGroup,
        exercises: _exercises
            .map((e) => TemplateExercise(
                  exerciseName: e.exerciseName,
                  targetSets: e.targetSets,
                  targetReps: e.targetReps,
                  targetWeight: e.targetWeight,
                ))
            .toList(),
        createdAt: DateTime.now(),
      );

      await FirebaseFirestore.instance
          .collection('workout_templates')
          .add(template.toFirestore());

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(AppLocalizations.of(context)!.workout_dff9ccc1)),
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
        setState(() => _isSaving = false);
      }
    }
  }
}

/// テンプレート種目ビルダー（編集用）
class TemplateExerciseBuilder {
  String exerciseName;
  int targetSets;
  int targetReps;
  double? targetWeight;
  bool isCustomExercise;  // カスタム種目フラグ

  TemplateExerciseBuilder({
    required this.exerciseName,
    required this.targetSets,
    required this.targetReps,
    this.targetWeight,
    this.isCustomExercise = false,  // デフォルトはプリセット種目
  });
}
