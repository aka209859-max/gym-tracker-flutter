import 'package:flutter/material.dart';
import '../models/gym.dart';
import '../services/realtime_user_service.dart';
import '../services/favorites_service.dart';
import 'crowd_report_screen.dart';
import 'reservation_form_screen.dart';

/// ジム詳細画面
class GymDetailScreen extends StatefulWidget {
  final Gym gym;

  const GymDetailScreen({super.key, required this.gym});

  @override
  State<GymDetailScreen> createState() => _GymDetailScreenState();
}

class _GymDetailScreenState extends State<GymDetailScreen> {
  final RealtimeUserService _userService = RealtimeUserService();
  final FavoritesService _favoritesService = FavoritesService();
  bool _isCheckedIn = false;
  bool _isFavorite = false;

  @override
  void initState() {
    super.initState();
    _checkUserStatus();
    _checkFavoriteStatus();
  }

  Future<void> _checkUserStatus() async {
    try {
      final isCheckedIn = await _userService.isUserCheckedIn(widget.gym.id);
      if (mounted) {
        setState(() {
          _isCheckedIn = isCheckedIn;
        });
      }
    } catch (e) {
      // Firebase未設定時はデモモード
      if (mounted) {
        setState(() {
          _isCheckedIn = false;
        });
      }
    }
  }

  Future<void> _checkFavoriteStatus() async {
    final isFavorite = await _favoritesService.isFavorite(widget.gym.id);
    if (mounted) {
      setState(() {
        _isFavorite = isFavorite;
      });
    }
  }

  Future<void> _toggleFavorite() async {
    if (_isFavorite) {
      // お気に入りから削除
      final success = await _favoritesService.removeFavorite(widget.gym.id);
      if (success && mounted) {
        setState(() {
          _isFavorite = false;
        });
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('お気に入りから削除しました'),
            backgroundColor: Colors.grey,
          ),
        );
      }
    } else {
      // お気に入りに追加
      final success = await _favoritesService.addFavorite(widget.gym);
      if (success && mounted) {
        setState(() {
          _isFavorite = true;
        });
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('お気に入りに追加しました'),
            backgroundColor: Colors.pink,
          ),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: CustomScrollView(
        slivers: [
          // ヘッダー画像
          SliverAppBar(
            expandedHeight: 250,
            pinned: true,
            backgroundColor: Colors.blue[900],
            flexibleSpace: FlexibleSpaceBar(
              title: Text(
                widget.gym.name,
                style: const TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: Colors.white,
                  shadows: [
                    Shadow(color: Colors.black, blurRadius: 8, offset: Offset(0, 2)),
                    Shadow(color: Colors.black, blurRadius: 4, offset: Offset(0, 0)),
                  ],
                ),
              ),
              centerTitle: false,
              background: Stack(
                fit: StackFit.expand,
                children: [
                  Image.network(
                    widget.gym.imageUrl,
                    fit: BoxFit.cover,
                    errorBuilder: (context, error, stackTrace) {
                      // 画像読み込み失敗時は濃い青色の背景のみ表示（店舗名を邪魔しない）
                      return Container(
                        decoration: BoxDecoration(
                          gradient: LinearGradient(
                            begin: Alignment.topLeft,
                            end: Alignment.bottomRight,
                            colors: [
                              Colors.blue[800]!,
                              Colors.blue[900]!,
                            ],
                          ),
                        ),
                        child: Center(
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Icon(
                                Icons.fitness_center,
                                size: 48,
                                color: Colors.white.withValues(alpha: 0.3),
                              ),
                              const SizedBox(height: 8),
                              Text(
                                'ジム画像',
                                style: TextStyle(
                                  color: Colors.white.withValues(alpha: 0.3),
                                  fontSize: 12,
                                ),
                              ),
                            ],
                          ),
                        ),
                      );
                    },
                  ),
                  // グラデーションオーバーレイ（テキスト視認性向上）
                  Container(
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        begin: Alignment.topCenter,
                        end: Alignment.bottomCenter,
                        colors: [
                          Colors.transparent,
                          Colors.black.withValues(alpha: 0.7),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
          // コンテンツ
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // パートナーバッジ + キャンペーン情報（最優先表示）
                  if (widget.gym.isPartner) ...[
                    _buildPartnerCampaignCard(),
                    const SizedBox(height: 16),
                  ],
                  // ビジター予約ボタン（パートナー店舗のみ）
                  if (widget.gym.isPartner && widget.gym.acceptsVisitors) ...[
                    _buildReservationButton(),
                    const SizedBox(height: 16),
                  ],
                  // 基本情報
                  _buildInfoSection(),
                  const SizedBox(height: 16),
                  // アクションボタン（電話・地図）
                  _buildActionButtons(),
                  const SizedBox(height: 16),
                  // 混雑度カード（2番目に表示）
                  _buildCrowdCard(),
                  const SizedBox(height: 16),
                  // 設備情報
                  _buildFacilitiesSection(),
                  const SizedBox(height: 24),
                  // レビューセクション（プレースホルダー）
                  _buildReviewsSection(),
                ],
              ),
            ),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: _toggleFavorite,
        backgroundColor: _isFavorite ? Colors.pink : Colors.grey[300],
        foregroundColor: _isFavorite ? Colors.white : Colors.grey[700],
        icon: Icon(_isFavorite ? Icons.favorite : Icons.favorite_border),
        label: Text(_isFavorite ? 'お気に入り登録済み' : 'お気に入りに追加'),
      ),
    );
  }

  Widget _buildCrowdCard() {
    final gym = widget.gym;
    
    // 混雑度データが未実装の場合は「データ収集中」を表示
    if (gym.currentCrowdLevel == 0 || gym.lastCrowdUpdate == null) {
      return Card(
        color: Colors.blue.withValues(alpha: 0.05),
        child: Padding(
          padding: const EdgeInsets.all(20),
          child: Column(
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: const [
                  Icon(Icons.hourglass_empty, size: 32, color: Colors.blue),
                  SizedBox(width: 12),
                  Text(
                    '混雑度データ収集中',
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: Colors.blue,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 12),
              Text(
                'リアルタイム混雑度機能は近日公開予定です',
                textAlign: TextAlign.center,
                style: TextStyle(fontSize: 14, color: Colors.grey[600]),
              ),
              const SizedBox(height: 16),
              // 混雑状況報告ボタン（データ収集中でも表示）
              SizedBox(
                width: double.infinity,
                child: ElevatedButton.icon(
                  onPressed: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => CrowdReportScreen(gym: widget.gym),
                      ),
                    );
                  },
                  icon: const Icon(Icons.edit),
                  label: const Text('混雑度を報告する'),
                ),
              ),
            ],
          ),
        ),
      );
    }
    
    final minutesAgo = gym.lastCrowdUpdate != null
        ? DateTime.now().difference(gym.lastCrowdUpdate!).inMinutes
        : null;

    return Card(
      elevation: 4,
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text(
                  '現在の混雑度',
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                ),
                if (minutesAgo != null)
                  Text(
                    '$minutesAgo分前更新',
                    style: TextStyle(fontSize: 12, color: Colors.grey[600]),
                  ),
              ],
            ),
            const SizedBox(height: 16),
            Container(
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: Color(gym.crowdLevelColor).withValues(alpha: 0.2),
                borderRadius: BorderRadius.circular(12),
                border: Border.all(
                  color: Color(gym.crowdLevelColor),
                  width: 2,
                ),
              ),
              child: Column(
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(
                        Icons.people,
                        size: 32,
                        color: Color(gym.crowdLevelColor),
                      ),
                      const SizedBox(width: 12),
                      Text(
                        gym.crowdLevelText,
                        style: TextStyle(
                          fontSize: 24,
                          fontWeight: FontWeight.bold,
                          color: Color(gym.crowdLevelColor),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 12),
                  // リアルタイムユーザー数表示（デモモード対応）
                  StreamBuilder<int>(
                    stream: _userService.getUserCountStream(gym.id),
                    builder: (context, snapshot) {
                      // エラー時はデモデータ表示
                      if (snapshot.hasError) {
                        return Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 16,
                            vertical: 8,
                          ),
                          decoration: BoxDecoration(
                            color: Theme.of(context).colorScheme.primaryContainer,
                            borderRadius: BorderRadius.circular(20),
                          ),
                          child: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Icon(
                                Icons.person,
                                size: 18,
                                color: Theme.of(context).colorScheme.onPrimaryContainer,
                              ),
                              const SizedBox(width: 6),
                              Text(
                                'デモモード（Firebase未設定）',
                                style: TextStyle(
                                  fontSize: 12,
                                  fontWeight: FontWeight.bold,
                                  color: Theme.of(context).colorScheme.onPrimaryContainer,
                                ),
                              ),
                            ],
                          ),
                        );
                      }
                      
                      if (snapshot.connectionState == ConnectionState.waiting) {
                        return const SizedBox(
                          height: 20,
                          width: 20,
                          child: CircularProgressIndicator(strokeWidth: 2),
                        );
                      }
                      final userCount = snapshot.data ?? 0;
                      return Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 16,
                          vertical: 8,
                        ),
                        decoration: BoxDecoration(
                          color: Theme.of(context).colorScheme.primaryContainer,
                          borderRadius: BorderRadius.circular(20),
                        ),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Icon(
                              Icons.person,
                              size: 18,
                              color: Theme.of(context).colorScheme.onPrimaryContainer,
                            ),
                            const SizedBox(width: 6),
                            Text(
                              '$userCountがトレーニング中',
                              style: TextStyle(
                                fontSize: 14,
                                fontWeight: FontWeight.bold,
                                color: Theme.of(context).colorScheme.onPrimaryContainer,
                              ),
                            ),
                          ],
                        ),
                      );
                    },
                  ),
                ],
              ),
            ),
            const SizedBox(height: 16),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton.icon(
                onPressed: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => CrowdReportScreen(gym: widget.gym),
                    ),
                  );
                },
                icon: const Icon(Icons.edit),
                label: const Text('混雑度を報告する'),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildInfoSection() {
    final gym = widget.gym;
    return Card(
      elevation: 4,
      color: Colors.white,
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: const [
                Icon(Icons.info, color: Colors.blue, size: 24),
                SizedBox(width: 8),
                Text(
                  '基本情報',
                  style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                ),
              ],
            ),
            const Divider(thickness: 2),
            _buildInfoRow(Icons.star, '評価', '${gym.rating} (${gym.reviewCount}件)'),
            _buildInfoRow(Icons.location_on, '住所', gym.address),
            if (gym.phoneNumber.isNotEmpty)
              _buildInfoRow(Icons.phone, '電話番号', gym.phoneNumber),
            _buildInfoRow(Icons.access_time, '営業時間', gym.openingHours),
            const SizedBox(height: 8),
            // 月額料金は公式サイトで確認
            _buildInfoNotice(
              Icons.open_in_new,
              '料金・詳細情報',
              '最新の料金プランや設備情報は、ジムの公式サイトでご確認ください',
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildInfoRow(IconData icon, String label, String value) {
    // 住所と電話番号を強調表示
    final isImportant = icon == Icons.location_on || icon == Icons.phone;
    
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(
            icon, 
            size: isImportant ? 24 : 20, 
            color: isImportant ? Colors.red : Colors.grey[600],
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  label,
                  style: TextStyle(
                    fontSize: 12,
                    color: Colors.grey[600],
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  value,
                  style: TextStyle(
                    fontSize: isImportant ? 16 : 14,
                    fontWeight: isImportant ? FontWeight.bold : FontWeight.normal,
                    color: isImportant ? Colors.black87 : Colors.black,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildInfoNotice(IconData icon, String label, String notice) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Container(
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: Colors.blue.withValues(alpha: 0.05),
          borderRadius: BorderRadius.circular(8),
          border: Border.all(color: Colors.blue.withValues(alpha: 0.3)),
        ),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Icon(icon, size: 20, color: Colors.blue),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    label,
                    style: const TextStyle(
                      fontSize: 12,
                      color: Colors.blue,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    notice,
                    style: TextStyle(fontSize: 13, color: Colors.grey[700]),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildFacilitiesSection() {
    final gym = widget.gym;
    
    // パートナージムで設備情報がある場合は表示
    if (gym.isPartner && gym.equipment != null && gym.equipment!.isNotEmpty) {
      return Card(
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  const Text(
                    '設備・マシン情報',
                    style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(width: 8),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                    decoration: BoxDecoration(
                      color: Colors.blue[600],
                      borderRadius: BorderRadius.circular(4),
                    ),
                    child: const Text(
                      'オーナー提供',
                      style: TextStyle(
                        fontSize: 10,
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                      ),
                    ),
                  ),
                ],
              ),
              const Divider(),
              const SizedBox(height: 8),
              Wrap(
                spacing: 8,
                runSpacing: 8,
                children: gym.equipment!.entries.map((entry) {
                  return Container(
                    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                    decoration: BoxDecoration(
                      color: Colors.blue[50],
                      borderRadius: BorderRadius.circular(8),
                      border: Border.all(color: Colors.blue[200]!),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(Icons.fitness_center, size: 16, color: Colors.blue[700]),
                        const SizedBox(width: 6),
                        Text(
                          '${entry.key} × ${entry.value}台',
                          style: TextStyle(
                            fontSize: 13,
                            fontWeight: FontWeight.w600,
                            color: Colors.blue[900],
                          ),
                        ),
                      ],
                    ),
                  );
                }).toList(),
              ),
            ],
          ),
        ),
      );
    }
    
    // デフォルト: 公式サイトで確認
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              '設備・施設',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const Divider(),
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: Colors.grey.withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Row(
                children: [
                  Icon(Icons.info_outline, color: Colors.grey[600]),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Text(
                      '設備情報は公式サイトでご確認ください',
                      style: TextStyle(color: Colors.grey[700]),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildActionButtons() {
    return Column(
      children: [
        // チェックイン/チェックアウトボタン
        SizedBox(
          width: double.infinity,
          height: 50,
          child: ElevatedButton.icon(
            onPressed: () async {
              try {
                if (_isCheckedIn) {
                  // チェックアウト
                  await _userService.checkOutFromGym(widget.gym.id);
                  if (mounted) {
                    setState(() {
                      _isCheckedIn = false;
                    });
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(content: Text('チェックアウトしました')),
                    );
                  }
                } else {
                  // チェックイン
                  await _userService.checkInToGym(widget.gym.id);
                  if (mounted) {
                    setState(() {
                      _isCheckedIn = true;
                    });
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(content: Text('チェックインしました！')),
                    );
                  }
                }
              } catch (e) {
                // Firebase未設定時のエラーハンドリング
                if (mounted) {
                  showDialog(
                    context: context,
                    builder: (context) => AlertDialog(
                      title: const Text('Firebase設定が必要です'),
                      content: const Text(
                        'チェックイン機能を使用するには、Firebase Consoleで設定ファイルを取得し、firebase_options.dartを更新してください。',
                      ),
                      actions: [
                        TextButton(
                          onPressed: () => Navigator.pop(context),
                          child: const Text('了解'),
                        ),
                      ],
                    ),
                  );
                }
              }
            },
            icon: Icon(_isCheckedIn ? Icons.logout : Icons.login),
            label: Text(_isCheckedIn ? 'チェックアウト' : 'チェックイン'),
            style: ElevatedButton.styleFrom(
              backgroundColor: _isCheckedIn
                  ? Theme.of(context).colorScheme.error
                  : Theme.of(context).colorScheme.primary,
              foregroundColor: Colors.white,
            ),
          ),
        ),
        const SizedBox(height: 12),
        // シェアボタン
        SizedBox(
          width: double.infinity,
          child: OutlinedButton.icon(
            onPressed: _shareGym,
            icon: const Icon(Icons.share),
            label: const Text('このジムをシェア'),
            style: OutlinedButton.styleFrom(
              side: BorderSide(color: Colors.blue[600]!),
              foregroundColor: Colors.blue[600],
            ),
          ),
        ),
        const SizedBox(height: 12),
        Row(
          children: [
            Expanded(
              child: ElevatedButton.icon(
                onPressed: () {
                  // TODO: ルート案内機能
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('ルート案内機能は開発中です')),
                  );
                },
                icon: const Icon(Icons.directions),
                label: const Text('ルート案内'),
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: OutlinedButton.icon(
                onPressed: () {
                  // TODO: お気に入り機能
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('お気に入りに追加しました')),
                  );
                },
                icon: const Icon(Icons.favorite_border),
                label: const Text('お気に入り'),
              ),
            ),
          ],
        ),
      ],
    );
  }

  /// ジムをシェアする（正直な「作りました！」スタイル）
  Future<void> _shareGym() async {
    try {
      final gym = widget.gym;
      
      // シンプルで正直なツイート文
      final tweetText = '''GPS×混雑度でジム探しアプリ作りました💪

GYM MATCH

📍 ${gym.name}
⭐ ${gym.rating.toStringAsFixed(1)}/5.0 (${gym.reviewCount}件のレビュー)
📍 ${gym.address}

まだβ版ですが、使ってみてください！

#個人開発 #Flutter #GYM_MATCH #ジム''';

      // テキストのみシェア（画像生成は将来実装）
      await _shareService.shareText(
        tweetText,
        subject: 'GYM MATCH - ${gym.name}',
      );

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('シェアしました！'),
            backgroundColor: Colors.green,
            duration: Duration(seconds: 2),
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('シェアに失敗しました: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  Widget _buildReviewsSection() {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text(
                  'レビュー',
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                ),
                TextButton(
                  onPressed: () {
                    // TODO: レビュー一覧画面
                  },
                  child: const Text('すべて見る'),
                ),
              ],
            ),
            const Divider(),
            const Center(
              child: Padding(
                padding: EdgeInsets.all(24),
                child: Text(
                  'レビュー機能は準備中です',
                  style: TextStyle(color: Colors.grey),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  /// パートナーキャンペーンカード
  Widget _buildPartnerCampaignCard() {
    final gym = widget.gym;
    
    return Card(
      elevation: 4,
      color: Colors.amber[50],
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // パートナーバッジ
            Row(
              children: [
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                  decoration: BoxDecoration(
                    color: Colors.amber[700],
                    borderRadius: BorderRadius.circular(6),
                  ),
                  child: const Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text('🏆', style: TextStyle(fontSize: 14)),
                      SizedBox(width: 4),
                      Text(
                        '広告',
                        style: TextStyle(
                          fontSize: 12,
                          fontWeight: FontWeight.bold,
                          color: Colors.white,
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(width: 8),
                const Expanded(
                  child: Text(
                    'パートナージム',
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ],
            ),
            
            // 基本特典
            if (gym.partnerBenefit != null && gym.partnerBenefit!.isNotEmpty) ...[
              const SizedBox(height: 12),
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: Colors.green[50],
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(color: Colors.green[300]!, width: 1.5),
                ),
                child: Row(
                  children: [
                    Icon(Icons.local_offer, size: 20, color: Colors.green[700]),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Text(
                        gym.partnerBenefit!,
                        style: TextStyle(
                          fontSize: 14,
                          color: Colors.green[800],
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ],
            
            // キャンペーンバナー
            if (gym.campaignBannerUrl != null && gym.campaignBannerUrl!.isNotEmpty) ...[
              const SizedBox(height: 12),
              ClipRRect(
                borderRadius: BorderRadius.circular(8),
                child: Image.network(
                  gym.campaignBannerUrl!,
                  width: double.infinity,
                  height: 180,
                  fit: BoxFit.cover,
                  errorBuilder: (context, error, stackTrace) {
                    return Container(
                      height: 180,
                      color: Colors.grey[300],
                      child: const Center(
                        child: Icon(Icons.image, size: 48, color: Colors.grey),
                      ),
                    );
                  },
                ),
              ),
            ],
            
            // キャンペーン情報
            if (gym.campaignTitle != null && gym.campaignTitle!.isNotEmpty) ...[
              const SizedBox(height: 12),
              Row(
                children: [
                  Icon(Icons.campaign, size: 20, color: Colors.amber[900]),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      gym.campaignTitle!,
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                        color: Colors.amber[900],
                      ),
                    ),
                  ),
                ],
              ),
            ],
            
            if (gym.campaignDescription != null && gym.campaignDescription!.isNotEmpty) ...[
              const SizedBox(height: 8),
              Text(
                gym.campaignDescription!,
                style: TextStyle(
                  fontSize: 14,
                  color: Colors.grey[800],
                ),
              ),
            ],
            
            // キャンペーン期限
            if (gym.campaignValidUntil != null) ...[
              const SizedBox(height: 8),
              Row(
                children: [
                  Icon(Icons.access_time, size: 16, color: Colors.red[700]),
                  const SizedBox(width: 4),
                  Text(
                    '${gym.campaignValidUntil!.year}/${gym.campaignValidUntil!.month}/${gym.campaignValidUntil!.day}まで',
                    style: TextStyle(
                      fontSize: 13,
                      color: Colors.red[700],
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ],
              ),
            ],
            
            // クーポンコード
            if (gym.campaignCouponCode != null && gym.campaignCouponCode!.isNotEmpty) ...[
              const SizedBox(height: 12),
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(color: Colors.amber[700]!, width: 2),
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(Icons.confirmation_number, color: Colors.amber[700]),
                    const SizedBox(width: 8),
                    Text(
                      'クーポン: ${gym.campaignCouponCode!}',
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 16,
                        color: Colors.amber[900],
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }

  /// ビジター予約ボタン（パートナー店舗のみ）
  Widget _buildReservationButton() {
    return Card(
      elevation: 4,
      color: Colors.orange[50],
      child: InkWell(
        onTap: () {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => ReservationFormScreen(gym: widget.gym),
            ),
          );
        },
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Row(
            children: [
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: Colors.orange[700],
                  shape: BoxShape.circle,
                ),
                child: const Icon(
                  Icons.calendar_today,
                  color: Colors.white,
                  size: 28,
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        const Text(
                          'ビジター予約申込',
                          style: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const SizedBox(width: 8),
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                          decoration: BoxDecoration(
                            color: Colors.green[600],
                            borderRadius: BorderRadius.circular(4),
                          ),
                          child: const Text(
                            'ビジター可',
                            style: TextStyle(
                              fontSize: 10,
                              fontWeight: FontWeight.bold,
                              color: Colors.white,
                            ),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 4),
                    Text(
                      '店舗に直接予約申込ができます',
                      style: TextStyle(
                        fontSize: 13,
                        color: Colors.grey[700],
                      ),
                    ),
                  ],
                ),
              ),
              Icon(
                Icons.chevron_right,
                color: Colors.orange[700],
                size: 32,
              ),
            ],
          ),
        ),
      ),
    );
  }
}
