import 'package:cloud_firestore/cloud_firestore.dart';

/// バッジのカテゴリー
enum BadgeCategory {
  streak,      // 継続日数
  totalWeight, // 総重量
  prCount,     // PR達成回数
}

/// 達成バッジモデル
class Achievement {
  final String id;
  final String userId;
  final BadgeCategory category;
  final String title;
  final String description;
  final String iconName;
  final int threshold; // 達成に必要な値
  final bool isUnlocked;
  final DateTime? unlockedAt;

  Achievement({
    required this.id,
    required this.userId,
    required this.category,
    required this.title,
    required this.description,
    required this.iconName,
    required this.threshold,
    this.isUnlocked = false,
    this.unlockedAt,
  });

  /// Firestoreドキュメントから変換
  factory Achievement.fromFirestore(Map<String, dynamic> data, String docId) {
    return Achievement(
      id: docId,
      userId: data['user_id'] as String? ?? '',
      category: _categoryFromString(data['category'] as String? ?? 'streak'),
      title: data['title'] as String? ?? '',
      description: data['description'] as String? ?? '',
      iconName: data['icon_name'] as String? ?? 'star',
      threshold: data['threshold'] as int? ?? 0,
      isUnlocked: data['is_unlocked'] as bool? ?? false,
      unlockedAt: (data['unlocked_at'] as Timestamp?)?.toDate(),
    );
  }

  /// Firestoreドキュメントに変換
  Map<String, dynamic> toFirestore() {
    return {
      'user_id': userId,
      'category': category.name,
      'title': title,
      'description': description,
      'icon_name': iconName,
      'threshold': threshold,
      'is_unlocked': isUnlocked,
      'unlocked_at': unlockedAt != null ? Timestamp.fromDate(unlockedAt!) : null,
    };
  }

  /// 文字列からカテゴリーに変換
  static BadgeCategory _categoryFromString(String value) {
    switch (value) {
      case 'streak':
        return BadgeCategory.streak;
      case 'totalWeight':
        return BadgeCategory.totalWeight;
      case 'prCount':
        return BadgeCategory.prCount;
      default:
        return BadgeCategory.streak;
    }
  }

  /// バッジのコピーを作成
  Achievement copyWith({
    String? id,
    String? userId,
    BadgeCategory? category,
    String? title,
    String? description,
    String? iconName,
    int? threshold,
    bool? isUnlocked,
    DateTime? unlockedAt,
  }) {
    return Achievement(
      id: id ?? this.id,
      userId: userId ?? this.userId,
      category: category ?? this.category,
      title: title ?? this.title,
      description: description ?? this.description,
      iconName: iconName ?? this.iconName,
      threshold: threshold ?? this.threshold,
      isUnlocked: isUnlocked ?? this.isUnlocked,
      unlockedAt: unlockedAt ?? this.unlockedAt,
    );
  }
}

/// 定義済みバッジリスト
class PredefinedBadges {
  /// 継続日数バッジ
  static List<Map<String, dynamic>> streakBadges = [
    {
      'category': 'streak',
      'title': AppLocalizations.of(context)!.general_スタートダッシュ,
      'description': AppLocalizations.of(context)!.general_3日連続トレーニング達成,
      'icon_name': 'directions_run',
      'threshold': 3,
    },
    {
      'category': 'streak',
      'title': AppLocalizations.of(context)!.general_1週間の戦士,
      'description': AppLocalizations.of(context)!.general_7日連続トレーニング達成,
      'icon_name': 'military_tech',
      'threshold': 7,
    },
    {
      'category': 'streak',
      'title': AppLocalizations.of(context)!.general_習慣の達人,
      'description': AppLocalizations.of(context)!.general_30日連続トレーニング達成,
      'icon_name': 'emoji_events',
      'threshold': 30,
    },
    {
      'category': 'streak',
      'title': AppLocalizations.of(context)!.general_レジェンド,
      'description': AppLocalizations.of(context)!.general_100日連続トレーニング達成,
      'icon_name': 'workspace_premium',
      'threshold': 100,
    },
  ];

  /// 総重量バッジ
  static List<Map<String, dynamic>> totalWeightBadges = [
    {
      'category': 'totalWeight',
      'title': AppLocalizations.of(context)!.general_ビギナーリフター,
      'description': AppLocalizations.of(context)!.general_累計1000kg達成,
      'icon_name': 'fitness_center',
      'threshold': 1000,
    },
    {
      'category': 'totalWeight',
      'title': AppLocalizations.of(context)!.general_中級リフター,
      'description': AppLocalizations.of(context)!.general_累計5000kg達成,
      'icon_name': 'sports_gymnastics',
      'threshold': 5000,
    },
    {
      'category': 'totalWeight',
      'title': AppLocalizations.of(context)!.general_上級リフター,
      'description': AppLocalizations.of(context)!.general_累計10000kg達成,
      'icon_name': 'sports_martial_arts',
      'threshold': 10000,
    },
    {
      'category': 'totalWeight',
      'title': AppLocalizations.of(context)!.general_パワーマスター,
      'description': AppLocalizations.of(context)!.general_累計50000kg達成,
      'icon_name': 'star',
      'threshold': 50000,
    },
  ];

  /// PR達成回数バッジ
  static List<Map<String, dynamic>> prCountBadges = [
    {
      'category': 'prCount',
      'title': AppLocalizations.of(context)!.general_初PR,
      'description': AppLocalizations.of(context)!.general_初めての自己記録更新,
      'icon_name': 'celebration',
      'threshold': 1,
    },
    {
      'category': 'prCount',
      'title': AppLocalizations.of(context)!.general_PR狙撃手,
      'description': AppLocalizations.of(context)!.general_10回の自己記録更新,
      'icon_name': 'trending_up',
      'threshold': 10,
    },
    {
      'category': 'prCount',
      'title': AppLocalizations.of(context)!.general_PRコレクター,
      'description': AppLocalizations.of(context)!.general_50回の自己記録更新,
      'icon_name': 'auto_awesome',
      'threshold': 50,
    },
    {
      'category': 'prCount',
      'title': AppLocalizations.of(context)!.general_PR達成王,
      'description': AppLocalizations.of(context)!.general_100回の自己記録更新,
      'icon_name': 'diamond',
      'threshold': 100,
    },
  ];

  /// すべてのバッジを取得
  static List<Map<String, dynamic>> getAllBadges() {
    return [
      ...streakBadges,
      ...totalWeightBadges,
      ...prCountBadges,
    ];
  }
}
