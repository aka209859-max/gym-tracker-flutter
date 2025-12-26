import 'package:gym_match/gen/app_localizations.dart';
import 'package:flutter/material.dart';
import '../../models/partner_profile.dart';
import '../../services/partner_search_service.dart';
import '../subscription_screen.dart';

/// パートナープロフィール詳細画面
/// 
/// 機能:
/// - プロフィール詳細表示
/// - マッチングリクエスト送信
class PartnerProfileDetailScreen extends StatefulWidget {
  final PartnerProfile profile;

  const PartnerProfileDetailScreen({
    super.key,
    required this.profile,
  });

  @override
  State<PartnerProfileDetailScreen> createState() => _PartnerProfileDetailScreenState();
}

class _PartnerProfileDetailScreenState extends State<PartnerProfileDetailScreen> {
  final PartnerSearchService _searchService = PartnerSearchService();
  final TextEditingController _messageController = TextEditingController();
  bool _isSending = false;
  bool _canSendRequest = true;
  String? _permissionMessage;

  final Map<String, String> _trainingGoals = {
    'muscle_gain': AppLocalizations.of(context)!.goalStrengthGain,
    'weight_loss': AppLocalizations.of(context)!.goalWeightLoss,
    'endurance': AppLocalizations.of(context)!.goalEndurance,
    'flexibility': AppLocalizations.of(context)!.goalFlexibility,
  };

  final Map<String, String> _experienceLevels = {
    'beginner': AppLocalizations.of(context)!.beginner,
    'intermediate': AppLocalizations.of(context)!.intermediate,
    'advanced': AppLocalizations.of(context)!.advanced,
    'expert': AppLocalizations.of(context)!.levelExpert,
  };

  final Map<String, String> _genders = {
    'male': AppLocalizations.of(context)!.male,
    'female': AppLocalizations.of(context)!.female,
    'other': AppLocalizations.of(context)!.other,
    'not_specified': AppLocalizations.of(context)!.profile_a479de60,
  };

  final Map<String, String> _weekDays = {
    'monday': '月',
    'tuesday': '火',
    'wednesday': AppLocalizations.of(context)!.wed,
    'thursday': '木',
    'friday': '金',
    'saturday': '土',
    'sunday': AppLocalizations.of(context)!.sun,
  };

  final Map<String, String> _timeSlots = {
    'morning': '朝',
    'afternoon': '昼',
    'evening': '夕',
    'night': AppLocalizations.of(context)!.night,
  };

  @override
  void initState() {
    super.initState();
    _checkPermissions();
  }
  
  /// ✅ Pro Plan権限チェック
  Future<void> _checkPermissions() async {
    try {
      final result = await _searchService.canSendMatchRequest();
      if (mounted) {
        setState(() {
          _canSendRequest = result['canSend'] == true;
          _permissionMessage = result['reason'];
        });
      }
    } catch (e) {
      // エラー時は無料ユーザーとして扱う（安全側に倒す）
      print('⚠️ 権限チェックエラー: $e');
      if (mounted) {
        setState(() {
          _canSendRequest = false;
          _permissionMessage = AppLocalizations.of(context)!.profile_e0342da8;
        });
      }
    }
  }

  @override
  void dispose() {
    _messageController.dispose();
    super.dispose();
  }

  Future<void> _sendMatchRequest() async {
    // ✅ Pro非対称可視性: Non-Proユーザーはアップグレード誘導
    if (!_canSendRequest) {
      _showProUpsellDialog();
      return;
    }
    
    if (_messageController.text.trim().isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(AppLocalizations.of(context)!.profile_5cd65c3e)),
      );
      return;
    }

    setState(() {
      _isSending = true;
    });

    try {
      await _searchService.sendMatchRequest(
        targetUserId: widget.profile.userId,
        message: _messageController.text.trim(),
      );

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(AppLocalizations.of(context)!.profile_5b16043c)),
        );
        Navigator.pop(context);
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(AppLocalizations.of(context)!.error)),
        );
      }
    } finally {
      if (mounted) {
        setState(() {
          _isSending = false;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    // 🔧 CRITICAL: 全体をエラーバウンダリでラップ
    return Scaffold(
      appBar: AppBar(
        title: Text(AppLocalizations.of(context)!.navProfile),
      ),
      body: _buildBody(),
    );
  }
  
  Widget _buildBody() {
    try {
      return SingleChildScrollView(
        child: Column(
          children: [
            // ヘッダー部分
            _buildHeader(),
            
            const Divider(height: 1),
            
            // 詳細情報
            Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _buildSection(AppLocalizations.of(context)!.bio, widget.profile.bio ?? AppLocalizations.of(context)!.profile_c1dcde32),
                  SizedBox(height: 24),
                  
                  _buildSection(
                    AppLocalizations.of(context)!.profile_c7511bf1,
                    widget.profile.trainingGoals.isNotEmpty
                        ? widget.profile.trainingGoals
                            .where((goal) => goal != null && goal.isNotEmpty)
                            .map((goal) => _trainingGoals[goal] ?? goal)
                            .join(', ')
                        : AppLocalizations.of(context)!.notSet,
                  ),
                  SizedBox(height: 24),
                  
                  _buildSection(
                    AppLocalizations.of(context)!.experienceLevel,
                    _experienceLevels[widget.profile.experienceLevel] ?? widget.profile.experienceLevel,
                  ),
                  SizedBox(height: 24),
                  
                  _buildSection(
                    AppLocalizations.of(context)!.profile_dfe6eee7,
                    widget.profile.preferredExercises.isNotEmpty
                        ? widget.profile.preferredExercises
                            .where((ex) => ex != null && ex.isNotEmpty)
                            .join(', ')
                        : AppLocalizations.of(context)!.notSet,
                  ),
                  SizedBox(height: 24),
                  
                  _buildSection(
                    AppLocalizations.of(context)!.profile_7db380c8,
                    widget.profile.availableDays.isNotEmpty
                        ? widget.profile.availableDays
                            .where((day) => day != null && day.isNotEmpty)
                            .map((day) => _weekDays[day] ?? day)
                            .join('、')
                        : AppLocalizations.of(context)!.notSet,
                  ),
                  SizedBox(height: 24),
                  
                  _buildSection(
                    AppLocalizations.of(context)!.profile_1cfba3aa,
                    widget.profile.availableTimeSlots.isNotEmpty
                        ? widget.profile.availableTimeSlots
                            .where((slot) => slot != null && slot.isNotEmpty)
                            .map((slot) => _timeSlots[slot] ?? slot)
                            .join('、')
                        : AppLocalizations.of(context)!.notSet,
                  ),
                  SizedBox(height: 24),
                  
                  if (widget.profile.preferredLocation != null)
                    _buildSection(
                      AppLocalizations.of(context)!.profile_6745b85b,
                      widget.profile.preferredLocation!,
                    ),
                  SizedBox(height: 32),
                  
                  // マッチングリクエスト送信フォーム
                  _buildMatchRequestForm(),
                ],
              ),
            ),
          ],
        ),
      );
    } catch (e, stackTrace) {
      print('❌ プロフィール詳細画面ビルドエラー: $e');
      print('スタックトレース: $stackTrace');
      return Center(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(Icons.error_outline, size: 64, color: Colors.red),
              SizedBox(height: 16),
              Text(AppLocalizations.of(context)!.error,
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                textAlign: TextAlign.center,
              ),
              SizedBox(height: 8),
              Text(
                e.toString(),
                style: const TextStyle(fontSize: 14, color: Colors.grey),
                textAlign: TextAlign.center,
              ),
              SizedBox(height: 24),
              ElevatedButton(
                onPressed: () => Navigator.pop(context),
                child: Text(AppLocalizations.of(context)!.back),
              ),
            ],
          ),
        ),
      );
    }
  }

  Widget _buildHeader() {
    return Container(
      padding: const EdgeInsets.all(24),
      child: Column(
        children: [
          // プロフィール画像
          CircleAvatar(
            radius: 60,
            backgroundImage: widget.profile.photoUrl != null
                ? NetworkImage(widget.profile.photoUrl!)
                : null,
            child: widget.profile.photoUrl == null
                ? Icon(Icons.person, size: 60)
                : null,
          ),
          SizedBox(height: 16),
          
          // 名前・年齢
          Text(
            widget.profile.displayName,
            style: const TextStyle(
              fontSize: 24,
              fontWeight: FontWeight.bold,
            ),
          ),
          SizedBox(height: 4),
          
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text(
                '${widget.profile.age}歳',
                style: TextStyle(
                  fontSize: 16,
                  color: Colors.grey[700],
                ),
              ),
              SizedBox(width: 8),
              Text('•'),
              SizedBox(width: 8),
              Text(
                _genders[widget.profile.gender] ?? widget.profile.gender,
                style: TextStyle(
                  fontSize: 16,
                  color: Colors.grey[700],
                ),
              ),
            ],
          ),
          SizedBox(height: 16),
          
          // レーティング
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(Icons.star, color: Colors.amber, size: 24),
              SizedBox(width: 4),
              Text(
                widget.profile.rating.toStringAsFixed(1),
                style: const TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                ),
              ),
              SizedBox(width: 8),
              Text(
                '(${widget.profile.matchCount}マッチ)',
                style: TextStyle(
                  fontSize: 14,
                  color: Colors.grey[600],
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  /// ✅ Proプランアップグレード誘導ダイアログ
  void _showProUpsellDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                gradient: const LinearGradient(
                  colors: [Color(0xFFFFD700), Color(0xFFFFA500)],
                ),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Icon(Icons.workspace_premium, color: Colors.white),
            ),
            SizedBox(width: 12),
            Text('Pro限定機能'),
          ],
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'マッチングリクエスト送信は\nProプラン限定機能です',
              style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
            ),
            SizedBox(height: 16),
            Text('✨ Proプランの特典'),
            SizedBox(height: 8),
            _buildBenefitRow(AppLocalizations.of(context)!.searchGym),
            _buildBenefitRow(AppLocalizations.of(context)!.profile_b2818710),
            _buildBenefitRow(AppLocalizations.of(context)!.profile_a980ca9f),
            _buildBenefitRow('AI機能 無制限使用'),
            _buildBenefitRow(AppLocalizations.of(context)!.profile_8fdc9d03),
            SizedBox(height: 8),
            Text(
              '月額¥980（年間プラン32% OFF）',
              style: TextStyle(fontSize: 14, color: Colors.grey),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text(AppLocalizations.of(context)!.cancel),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.pop(context);
              Navigator.push(
                context,
                MaterialPageRoute(builder: (_) => const SubscriptionScreen()),
              );
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.amber,
              foregroundColor: Colors.white,
            ),
            child: Text(AppLocalizations.of(context)!.viewProPlan),
          ),
        ],
      ),
    );
  }
  
  Widget _buildBenefitRow(String text) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        children: [
          Icon(Icons.check_circle, color: Colors.green, size: 20),
          SizedBox(width: 8),
          Text(text, style: const TextStyle(fontSize: 14)),
        ],
      ),
    );
  }

  Widget _buildSection(String title, String content) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          title,
          style: const TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.bold,
            color: Colors.grey,
          ),
        ),
        SizedBox(height: 8),
        Text(
          content,
          style: const TextStyle(
            fontSize: 16,
          ),
        ),
      ],
    );
  }

  Widget _buildMatchRequestForm() {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Text(
                  AppLocalizations.of(context)!.profile_0e655357,
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                SizedBox(width: 8),
                // ✅ Pro限定バッジ
                if (!_canSendRequest)
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                    decoration: BoxDecoration(
                      gradient: const LinearGradient(
                        colors: [Color(0xFFFFD700), Color(0xFFFFA500)],
                      ),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Text(
                      AppLocalizations.of(context)!.profile_3e89f30d,
                      style: TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                      ),
                    ),
                  ),
              ],
            ),
            SizedBox(height: 16),
            
            TextField(
              controller: _messageController,
              maxLines: 4,
              maxLength: 200,
              decoration: InputDecoration(
                hintText: AppLocalizations.of(context)!.profile_b78090c1,
                border: OutlineInputBorder(),
              ),
            ),
            SizedBox(height: 16),
            
            // ✅ Pro非対称可視性: Non-ProはアップグレードUIを表示
            if (!_canSendRequest)
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: Colors.amber[50],
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(color: Colors.amber[300]!),
                ),
                child: Column(
                  children: [
                    Icon(Icons.lock, color: Colors.amber, size: 32),
                    SizedBox(height: 8),
                    Text(
                      _permissionMessage ?? AppLocalizations.of(context)!.profile_35399a27,
                      style: const TextStyle(fontSize: 14),
                      textAlign: TextAlign.center,
                    ),
                  ],
                ),
              ),
            
            SizedBox(
              width: double.infinity,
              child: ElevatedButton.icon(
                onPressed: _isSending ? null : _sendMatchRequest,
                style: !_canSendRequest
                    ? ElevatedButton.styleFrom(
                        backgroundColor: Colors.amber,
                        foregroundColor: Colors.white,
                      )
                    : null,
                icon: _isSending
                    ? SizedBox(
                        width: 20,
                        height: 20,
                        child: CircularProgressIndicator(
                          strokeWidth: 2,
                          valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                        ),
                      )
                    : Icon(!_canSendRequest ? Icons.upgrade : Icons.send),
                label: Text(
                  _isSending
                      ? AppLocalizations.of(context)!.submitting
                      : !_canSendRequest
                          ? AppLocalizations.of(context)!.profile_7d5e513b
                          : AppLocalizations.of(context)!.profile_580ce520
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
