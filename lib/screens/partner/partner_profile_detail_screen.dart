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
    'morning': '朝',
    'afternoon': '昼',
    'evening': '夕',
    'night': '夜',
  };

  @override
  void initState() {
    super.initState();
    _checkPermissions();
  }
  
  /// ✅ Pro Plan権限チェック
  Future<void> _checkPermissions() async {
    final result = await _searchService.canSendMatchRequest();
    if (mounted) {
      setState(() {
        _canSendRequest = result['canSend'] == true;
        _permissionMessage = result['reason'];
      });
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
        const SnackBar(content: Text('メッセージを入力してください')),
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
          const SnackBar(content: Text('マッチングリクエストを送信しました')),
        );
        Navigator.pop(context);
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('送信エラー: $e')),
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
    return Scaffold(
      appBar: AppBar(
        title: const Text('プロフィール詳細'),
      ),
      body: SingleChildScrollView(
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
                  _buildSection('自己紹介', widget.profile.bio ?? '自己紹介はありません'),
                  const SizedBox(height: 24),
                  
                  _buildSection(
                    'トレーニング目標',
                    widget.profile.trainingGoals
                        .map((goal) => _trainingGoals[goal] ?? goal)
                        .join(', '),
                  ),
                  const SizedBox(height: 24),
                  
                  _buildSection(
                    '経験レベル',
                    _experienceLevels[widget.profile.experienceLevel] ?? widget.profile.experienceLevel,
                  ),
                  const SizedBox(height: 24),
                  
                  _buildSection(
                    '好きな部位',
                    widget.profile.preferredExercises.join(', '),
                  ),
                  const SizedBox(height: 24),
                  
                  _buildSection(
                    '利用可能な曜日',
                    widget.profile.availableDays
                        .map((day) => _weekDays[day] ?? day)
                        .join('、'),
                  ),
                  const SizedBox(height: 24),
                  
                  _buildSection(
                    '利用可能な時間帯',
                    widget.profile.availableTimeSlots
                        .map((slot) => _timeSlots[slot] ?? slot)
                        .join('、'),
                  ),
                  const SizedBox(height: 24),
                  
                  if (widget.profile.preferredLocation != null)
                    _buildSection(
                      '希望エリア',
                      widget.profile.preferredLocation!,
                    ),
                  const SizedBox(height: 32),
                  
                  // マッチングリクエスト送信フォーム
                  _buildMatchRequestForm(),
                ],
              ),
            ),
          ],
        ),
      ),
    );
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
                ? const Icon(Icons.person, size: 60)
                : null,
          ),
          const SizedBox(height: 16),
          
          // 名前・年齢
          Text(
            widget.profile.displayName,
            style: const TextStyle(
              fontSize: 24,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 4),
          
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
              const SizedBox(width: 8),
              const Text('•'),
              const SizedBox(width: 8),
              Text(
                _genders[widget.profile.gender] ?? widget.profile.gender,
                style: TextStyle(
                  fontSize: 16,
                  color: Colors.grey[700],
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          
          // レーティング
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Icon(Icons.star, color: Colors.amber, size: 24),
              const SizedBox(width: 4),
              Text(
                widget.profile.rating.toStringAsFixed(1),
                style: const TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(width: 8),
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
              child: const Icon(Icons.workspace_premium, color: Colors.white),
            ),
            const SizedBox(width: 12),
            const Text('Pro限定機能'),
          ],
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'マッチングリクエスト送信は\nProプラン限定機能です',
              style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 16),
            const Text('✨ Proプランの特典'),
            const SizedBox(height: 8),
            _buildBenefitRow('パートナー検索 無制限'),
            _buildBenefitRow('マッチングリクエスト送信'),
            _buildBenefitRow('メッセージ機能'),
            _buildBenefitRow('AI機能 無制限使用'),
            _buildBenefitRow('全Premium機能'),
            const SizedBox(height: 8),
            const Text(
              '月額¥980（年間プラン32% OFF）',
              style: TextStyle(fontSize: 14, color: Colors.grey),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('キャンセル'),
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
            child: const Text('Proプランを見る'),
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
          const Icon(Icons.check_circle, color: Colors.green, size: 20),
          const SizedBox(width: 8),
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
        const SizedBox(height: 8),
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
                const Text(
                  'マッチングリクエスト',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(width: 8),
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
                    child: const Text(
                      'PRO限定',
                      style: TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                      ),
                    ),
                  ),
              ],
            ),
            const SizedBox(height: 16),
            
            TextField(
              controller: _messageController,
              maxLines: 4,
              maxLength: 200,
              decoration: const InputDecoration(
                hintText: '自己紹介やトレーニングの希望を書いてください',
                border: OutlineInputBorder(),
              ),
            ),
            const SizedBox(height: 16),
            
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
                    const Icon(Icons.lock, color: Colors.amber, size: 32),
                    const SizedBox(height: 8),
                    Text(
                      _permissionMessage ?? 'Pro限定機能です',
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
                    ? const SizedBox(
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
                      ? '送信中...'
                      : !_canSendRequest
                          ? 'Proプランにアップグレード'
                          : 'リクエストを送る'
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
