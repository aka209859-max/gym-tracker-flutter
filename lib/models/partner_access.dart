import 'package:cloud_firestore/cloud_firestore.dart';

/// パートナーアクセス認証データモデル
class PartnerAccess {
  final String gymId;
  final String accessCode;        // 店舗専用パスコード (例: ANYTIME-SHINJUKU-2024)
  final String gymName;
  final String? ownerEmail;
  final DateTime createdAt;
  final DateTime? expiresAt;      // 有効期限 (nullの場合は無期限)
  final Map<String, bool> permissions; // 権限設定

  PartnerAccess({
    required this.gymId,
    required this.accessCode,
    required this.gymName,
    this.ownerEmail,
    required this.createdAt,
    this.expiresAt,
    this.permissions = const {
      'editFacilities': true,
      'uploadPhotos': true,
      'editCampaign': true,
      'editHours': true,
      'viewAnalytics': false,
    },
  });

  /// Firestoreからデータ生成
  factory PartnerAccess.fromFirestore(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>;
    return PartnerAccess(
      gymId: doc.id,
      accessCode: data['accessCode'] ?? '',
      gymName: data['gymName'] ?? '',
      ownerEmail: data['ownerEmail'],
      createdAt: (data['createdAt'] as Timestamp?)?.toDate() ?? DateTime.now(),
      expiresAt: (data['expiresAt'] as Timestamp?)?.toDate(),
      permissions: Map<String, bool>.from(data['permissions'] ?? {}),
    );
  }

  /// Firestore用にマップ形式に変換
  Map<String, dynamic> toMap() {
    return {
      'accessCode': accessCode,
      'gymName': gymName,
      'ownerEmail': ownerEmail,
      'createdAt': Timestamp.fromDate(createdAt),
      'expiresAt': expiresAt != null ? Timestamp.fromDate(expiresAt!) : null,
      'permissions': permissions,
    };
  }

  /// アクセスコードが有効かチェック
  bool get isValid {
    if (expiresAt == null) return true;
    return DateTime.now().isBefore(expiresAt!);
  }

  /// 特定の権限を持っているかチェック
  bool hasPermission(String permission) {
    return permissions[permission] ?? false;
  }
}
