import 'package:cloud_firestore/cloud_firestore.dart';

/// 友達申請ステータス
enum FriendRequestStatus {
  pending,  // 承認待ち
  approved, // 承認済み
  rejected, // 拒否
}

/// 友達申請モデル
class FriendRequest {
  final String id;
  final String requesterId;
  final String targetId;
  final FriendRequestStatus status;
  final DateTime createdAt;
  final DateTime? respondedAt;

  FriendRequest({
    required this.id,
    required this.requesterId,
    required this.targetId,
    required this.status,
    required this.createdAt,
    this.respondedAt,
  });

  /// Firestoreから変換
  factory FriendRequest.fromFirestore(Map<String, dynamic> data, String id) {
    return FriendRequest(
      id: id,
      requesterId: data['requester_id'] as String,
      targetId: data['target_id'] as String,
      status: _parseStatus(data['status'] as String),
      createdAt: (data['created_at'] as Timestamp?)?.toDate() ?? DateTime.now(),
      respondedAt: (data['responded_at'] as Timestamp?)?.toDate(),
    );
  }

  /// Firestoreへ変換
  Map<String, dynamic> toFirestore() {
    return {
      'requester_id': requesterId,
      'target_id': targetId,
      'status': status.name,
      'created_at': Timestamp.fromDate(createdAt),
      'responded_at': respondedAt != null ? Timestamp.fromDate(respondedAt!) : null,
    };
  }

  /// ステータス文字列をEnumに変換
  static FriendRequestStatus _parseStatus(String status) {
    switch (status) {
      case 'pending':
        return FriendRequestStatus.pending;
      case 'approved':
        return FriendRequestStatus.approved;
      case 'rejected':
        return FriendRequestStatus.rejected;
      default:
        return FriendRequestStatus.pending;
    }
  }
}
