import 'package:gym_match/gen/app_localizations.dart';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../../models/workout_template.dart';
import 'create_template_screen.dart';
import 'add_workout_screen.dart';

/// テンプレート一覧画面
class TemplateScreen extends StatefulWidget {
  TemplateScreen({super.key});

  @override
  State<TemplateScreen> createState() => _TemplateScreenState();
}

class _TemplateScreenState extends State<TemplateScreen> with SingleTickerProviderStateMixin {
  late TabController _tabController;
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
    _autoLoginIfNeeded();
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  Future<void> _autoLoginIfNeeded() async {
    final user = FirebaseAuth.instance.currentUser;
    if (user == null) {
      try {
        await FirebaseAuth.instance.signInAnonymously();
      } catch (e) {
        debugPrint('Auto login failed: $e');
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<User?>(
      stream: FirebaseAuth.instance.authStateChanges(),
      builder: (context, authSnapshot) {
        if (authSnapshot.connectionState == ConnectionState.waiting) {
          return Scaffold(
            appBar: AppBar(title: Text(AppLocalizations.of(context)!.templates)),
            body: Center(child: CircularProgressIndicator()),
          );
        }

        final user = authSnapshot.data;
        if (user == null) {
          return Scaffold(
            appBar: AppBar(title: Text(AppLocalizations.of(context)!.templates)),
            body: Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(AppLocalizations.of(context)!.loginError),
                  SizedBox(height: 16),
                  ElevatedButton(
                    onPressed: _autoLoginIfNeeded,
                    child: Text(AppLocalizations.of(context)!.tryAgain),
                  ),
                ],
              ),
            ),
          );
        }

        return _buildMainContent(user);
      },
    );
  }

  Widget _buildMainContent(User user) {
    final theme = Theme.of(context);
    
    return Scaffold(
      appBar: AppBar(
        title: Text(AppLocalizations.of(context)!.workout_518d7cc7),
        backgroundColor: theme.colorScheme.primary,
        foregroundColor: Colors.white,
        bottom: TabBar(
          controller: _tabController,
          indicatorColor: Colors.white,
          labelColor: Colors.white,
          unselectedLabelColor: Colors.white.withValues(alpha: 0.7),
          tabs: [
            Tab(text: AppLocalizations.of(context)!.workout_912b6191, icon: Icon(Icons.folder, size: 20)),
            Tab(text: AppLocalizations.of(context)!.recommendation, icon: Icon(Icons.auto_awesome, size: 20)),
          ],
        ),
      ),
      body: TabBarView(
        controller: _tabController,
        children: [
          _buildMyTemplates(user),
          _buildDefaultTemplates(user),
        ],
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () async {
          final result = await Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => CreateTemplateScreen(),
            ),
          );
          if (result == true) {
            setState(() {}); // リフレッシュ
          }
        },
        icon: Icon(Icons.add),
        label: Text(AppLocalizations.of(context)!.createTemplate),
        backgroundColor: theme.colorScheme.primary,
        foregroundColor: Colors.white,
      ),
    );
  }

  /// マイテンプレート一覧
  Widget _buildMyTemplates(User user) {
    return StreamBuilder<QuerySnapshot>(
      stream: FirebaseFirestore.instance
          .collection('workout_templates')
          .where('user_id', isEqualTo: user.uid)
          .where('is_default', isEqualTo: false)
          .snapshots(),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting && !snapshot.hasData) {
          return Center(child: CircularProgressIndicator());
        }

        if (snapshot.hasError) {
          return Center(child: Text(AppLocalizations.of(context)!.snapshotError(snapshot.error.toString())));
        }

        final docs = snapshot.data?.docs ?? [];
        
        // テンプレートをリストに変換してソート
        final templates = docs.map((doc) {
          return WorkoutTemplate.fromFirestore(
            doc.data() as Map<String, dynamic>,
            doc.id,
          );
        }).toList();
        
        // 使用日時でソート（降順）
        templates.sort((a, b) {
          final aTime = a.lastUsedAt ?? a.createdAt;
          final bTime = b.lastUsedAt ?? b.createdAt;
          return bTime.compareTo(aTime);
        });
        
        if (templates.isEmpty) {
          return Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(Icons.folder_open, size: 64, color: Colors.grey[400]),
                SizedBox(height: 16),
                Text(
                  AppLocalizations.of(context)!.workout_156c3331,
                  style: TextStyle(fontSize: 16, color: Colors.grey[600]),
                ),
                SizedBox(height: 8),
                Text(
                  AppLocalizations.of(context)!.save,
                  style: TextStyle(fontSize: 14, color: Colors.grey[500]),
                ),
              ],
            ),
          );
        }

        return ListView.builder(
          padding: const EdgeInsets.all(16),
          itemCount: templates.length,
          itemBuilder: (context, index) {
            return _buildTemplateCard(templates[index], false);
          },
        );
      },
    );
  }

  /// デフォルトテンプレート一覧
  Widget _buildDefaultTemplates(User user) {
    final defaultTemplates = DefaultTemplates.getAll(user.uid);

    return ListView.builder(
      padding: const EdgeInsets.all(16),
      itemCount: defaultTemplates.length,
      itemBuilder: (context, index) {
        return _buildTemplateCard(defaultTemplates[index], true);
      },
    );
  }

  /// テンプレートカード
  Widget _buildTemplateCard(WorkoutTemplate template, bool isDefault) {
    final theme = Theme.of(context);

    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: InkWell(
        onTap: () => _useTemplate(template),
        borderRadius: BorderRadius.circular(12),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  // アイコン
                  Container(
                    padding: const EdgeInsets.all(8),
                    decoration: BoxDecoration(
                      color: theme.colorScheme.primary.withValues(alpha: 0.1),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Icon(
                      _getMuscleGroupIcon(template.muscleGroup),
                      color: theme.colorScheme.primary,
                      size: 24,
                    ),
                  ),
                  SizedBox(width: 12),
                  
                  // タイトル・説明
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            Expanded(
                              child: Text(
                                template.name,
                                style: TextStyle(
                                  fontSize: 16,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ),
                            if (isDefault)
                              Container(
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 8,
                                  vertical: 2,
                                ),
                                decoration: BoxDecoration(
                                  color: Colors.orange.withValues(alpha: 0.1),
                                  borderRadius: BorderRadius.circular(4),
                                  border: Border.all(color: Colors.orange),
                                ),
                                child: Text(AppLocalizations.of(context)!.recommendation,
                                  style: TextStyle(
                                    fontSize: 10,
                                    fontWeight: FontWeight.bold,
                                    color: Colors.orange,
                                  ),
                                ),
                              ),
                          ],
                        ),
                        if (template.description != null) ...[
                          SizedBox(height: 4),
                          Text(
                            template.description!,
                            style: TextStyle(
                              fontSize: 12,
                              color: Colors.grey[600],
                            ),
                          ),
                        ],
                      ],
                    ),
                  ),
                  
                  // メニューボタン
                  if (!isDefault)
                    PopupMenuButton<String>(
                      icon: Icon(Icons.more_vert),
                      onSelected: (value) {
                        if (value == 'delete') {
                          _deleteTemplate(template);
                        }
                      },
                      itemBuilder: (context) => [
                        PopupMenuItem(
                          value: 'delete',
                          child: Row(
                            children: [
                              Icon(Icons.delete, color: Colors.red, size: 20),
                              SizedBox(width: 8),
                              Text(AppLocalizations.of(context)!.remove),
                            ],
                          ),
                        ),
                      ],
                    ),
                ],
              ),
              
              const SizedBox(height: 12),
              const Divider(),
              const SizedBox(height: 8),
              
              // 種目リスト
              Wrap(
                spacing: 8,
                runSpacing: 4,
                children: template.exercises.map((exercise) {
                  return Container(
                    padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                    decoration: BoxDecoration(
                      color: Colors.grey[200],
                      borderRadius: BorderRadius.circular(6),
                    ),
                    child: Text(
                      '${exercise.exerciseName} ${exercise.targetSets}×${exercise.targetReps}',
                      style: const TextStyle(fontSize: 12),
                    ),
                  );
                }).toList(),
              ),
              
              const SizedBox(height: 8),
              
              // 使用回数
              if (!isDefault && template.usageCount > 0)
                Row(
                  children: [
                    Icon(Icons.check_circle, size: 14, color: Colors.grey[600]),
                    SizedBox(width: 4),
                    Text(
                      '使用回数: ${template.usageCount}回',
                      style: TextStyle(fontSize: 12, color: Colors.grey[600]),
                    ),
                  ],
                ),
            ],
          ),
        ),
      ),
    );
  }

  /// テンプレートを使用
  Future<void> _useTemplate(WorkoutTemplate template) async {
    setState(() => _isLoading = true);

    try {
      // 使用回数を更新（デフォルトテンプレート以外）
      if (!template.isDefault) {
        await FirebaseFirestore.instance
            .collection('workout_templates')
            .doc(template.id)
            .update({
          'usage_count': FieldValue.increment(1),
          'last_used_at': FieldValue.serverTimestamp(),
        });
      }

      // ワークアウト記録画面へ遷移（テンプレートデータを渡す）
      if (mounted) {
        // テンプレートデータを構築（targetSetsを含める）
        final templateData = {
          'muscle_group': template.muscleGroup,
          'exercises': template.exercises.map((exercise) {
            return {
              'exercise_name': exercise.exerciseName,
              'target_sets': exercise.targetSets,
              'target_reps': exercise.targetReps,
              'target_weight': exercise.targetWeight ?? 0.0,
            };
          }).toList(),
        };
        
        print(AppLocalizations.of(context)!.generatedKey_b714e319);
        
        final result = await Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => AddWorkoutScreen(templateData: templateData),
          ),
        );
        
        if (result == true && mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text(AppLocalizations.of(context)!.save)),
          );
        }
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(AppLocalizations.of(context)!.error)),
        );
      }
    } finally {
      if (mounted) {
        setState(() => _isLoading = false);
      }
    }
  }

  /// テンプレート削除
  Future<void> _deleteTemplate(WorkoutTemplate template) async {
    final confirm = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(AppLocalizations.of(context)!.deleteTemplate),
        content: Text(AppLocalizations.of(context)!.generatedKey_51ce78c9),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: Text(AppLocalizations.of(context)!.cancel),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context, true),
            style: TextButton.styleFrom(foregroundColor: Colors.red),
            child: Text(AppLocalizations.of(context)!.remove),
          ),
        ],
      ),
    );

    if (confirm == true) {
      try {
        await FirebaseFirestore.instance
            .collection('workout_templates')
            .doc(template.id)
            .delete();

        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text(AppLocalizations.of(context)!.delete)),
          );
        }
      } catch (e) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text(AppLocalizations.of(context)!.delete)),
          );
        }
      }
    }
  }

  /// 部位別アイコン
  IconData _getMuscleGroupIcon(String muscleGroup) {
    final l10n = AppLocalizations.of(context)!;
    
    if (muscleGroup == l10n.bodyPartChest) {
      return Icons.favorite;
    } else if (muscleGroup == l10n.bodyPartBack) {
      return Icons.backpack;
    } else if (muscleGroup == l10n.bodyPartLegs) {
      return Icons.directions_run;
    } else if (muscleGroup == l10n.bodyPartShoulders) {
      return Icons.fitness_center;
    } else if (muscleGroup == l10n.bodyPartBiceps || muscleGroup == l10n.bodyPartTriceps) {
      return Icons.front_hand;
    } else {
      return Icons.fitness_center;
    }
  }
}
