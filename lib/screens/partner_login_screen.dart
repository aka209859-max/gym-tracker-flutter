import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/partner_access.dart';
import 'partner_dashboard_screen.dart';
import 'po/po_dashboard_screen.dart';

/// パートナージムオーナー用ログイン画面
class PartnerLoginScreen extends StatefulWidget {
  const PartnerLoginScreen({super.key});

  @override
  State<PartnerLoginScreen> createState() => _PartnerLoginScreenState();
}

class _PartnerLoginScreenState extends State<PartnerLoginScreen> {
  final TextEditingController _accessCodeController = TextEditingController();
  bool _isLoading = false;
  String? _errorMessage;

  @override
  void dispose() {
    _accessCodeController.dispose();
    super.dispose();
  }

  /// デモモード用アクセスコード定義
  final Map<String, Map<String, dynamic>> _demoAccessCodes = {
    'ROYAL-YAMATOTEN-2025': {
      'gymId': 'demo_royal_yamato',
      'gymName': 'ROYAL WASH & FITNESS 大和店',
      'type': 'partner',
    },
    'ROYAL-TOSUTEN-2025': {
      'gymId': 'demo_royal_tosu',
      'gymName': 'ROYAL FITNESS鳥栖店',
      'type': 'partner',
    },
    'ROYAL-KURUMETSUBUKU-2025': {
      'gymId': 'demo_royal_kurume',
      'gymName': 'ROYALFITNESS&CAFE 久留米津福店',
      'type': 'partner',
    },
    'ROYAL-SAGATEN-2025': {
      'gymId': 'demo_royal_saga',
      'gymName': 'ROYAL FITNESS 佐賀店',
      'type': 'partner',
    },
    // PO管理ダッシュボード用（パーソナルトレーニング管理）
    'RF-AKA-2024': {
      'partnerId': 'royal_fitness_akasaka',
      'partnerName': 'ROYAL FITNESS 赤坂店',
      'type': 'po',
    },
    'RF-ROP-2024': {
      'partnerId': 'royal_fitness_roppongi',
      'partnerName': 'ROYAL FITNESS 六本木店',
      'type': 'po',
    },
  };

  /// アクセスコード検証
  Future<void> _verifyAccessCode() async {
    final accessCode = _accessCodeController.text.trim().toUpperCase();
    
    // 🔍 診断ログ1: 関数実行開始
    print('════════════════════════════════════════════════════════');
    print('🔍 [DIAGNOSTIC] _verifyAccessCode() 実行開始');
    print('🔍 [DIAGNOSTIC] 入力されたアクセスコード: "$accessCode"');
    print('🔍 [DIAGNOSTIC] デモコードマップに含まれているか: ${_demoAccessCodes.containsKey(accessCode)}');
    print('🔍 [DIAGNOSTIC] デモコードマップのキー: ${_demoAccessCodes.keys.toList()}');
    print('════════════════════════════════════════════════════════');

    if (accessCode.isEmpty) {
      setState(() {
        _errorMessage = 'アクセスコードを入力してください';
      });
      return;
    }

    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });

    try {
      if (kDebugMode) {
        print('🔐 アクセスコード検証中: $accessCode');
      }

      // デモモードチェック（Firebase未設定時）
      print('🔍 [DIAGNOSTIC] デモモードチェック開始...');
      if (_demoAccessCodes.containsKey(accessCode)) {
        print('✅ [DIAGNOSTIC] デモモードヒット！このブロックが実行されています');
        if (kDebugMode) {
          print('🎭 デモモードで認証: $accessCode');
        }
        
        await Future.delayed(const Duration(milliseconds: 500)); // ローディング演出
        
        final demoData = _demoAccessCodes[accessCode]!;
        final type = demoData['type'] as String;
        
        if (mounted) {
          setState(() {
            _isLoading = false;
          });
          
          if (type == 'po') {
            // PO管理ダッシュボードへ遷移
            print('✅ [DIAGNOSTIC] PO管理ダッシュボードへ遷移します');
            Navigator.pushReplacement(
              context,
              MaterialPageRoute(
                builder: (context) => PODashboardScreen(
                  partnerId: demoData['partnerId'] as String,
                  partnerName: demoData['partnerName'] as String,
                ),
              ),
            );
          } else {
            // 通常のパートナーダッシュボードへ遷移
            final demoPartnerAccess = PartnerAccess(
              gymId: demoData['gymId']!,
              gymName: demoData['gymName']!,
              accessCode: accessCode,
              ownerEmail: null,
              createdAt: DateTime.now(),
              expiresAt: null,
              permissions: {
                'editCampaign': true,
                'uploadPhotos': true,
                'editFacilities': true,
                'editHours': true,
                'viewAnalytics': true,
              },
            );
            
            print('✅ [DIAGNOSTIC] デモ認証成功！ダッシュボードへ遷移します');
            
            Navigator.pushReplacement(
              context,
              MaterialPageRoute(
                builder: (context) => PartnerDashboardScreen(
                  partnerAccess: demoPartnerAccess,
                ),
              ),
            );
          }
        }
        return;
      }

      // デモモードに該当しない場合
      print('⚠️ [DIAGNOSTIC] デモコードに該当せず、Firestore検証に進みます');
      
      // Firestoreでパスコード検証（デモコード以外の場合のみ）
      final snapshot = await FirebaseFirestore.instance
          .collection('partner_access')
          .where('accessCode', isEqualTo: accessCode)
          .limit(1)
          .get();

      if (snapshot.docs.isEmpty) {
        print('❌ [DIAGNOSTIC] Firestoreに該当コードなし → "無効なアクセスコードです"表示');
        setState(() {
          _errorMessage = '無効なアクセスコードです';
          _isLoading = false;
        });
        return;
      }

      final accessDoc = snapshot.docs.first;
      final partnerAccess = PartnerAccess.fromFirestore(accessDoc);

      // 有効期限チェック
      if (!partnerAccess.isValid) {
        setState(() {
          _errorMessage = 'アクセスコードの有効期限が切れています';
          _isLoading = false;
        });
        return;
      }

      if (kDebugMode) {
        print('✅ 認証成功: ${partnerAccess.gymName}');
      }

      // ダッシュボード画面へ遷移
      if (mounted) {
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(
            builder: (context) => PartnerDashboardScreen(
              partnerAccess: partnerAccess,
            ),
          ),
        );
      }
    } catch (e) {
      print('🔥 [DIAGNOSTIC] catch ブロック実行: エラーが発生しました');
      print('🔥 [DIAGNOSTIC] エラー内容: $e');
      print('🔥 [DIAGNOSTIC] エラー型: ${e.runtimeType}');
      
      if (kDebugMode) {
        print('❌ 認証エラー: $e');
      }

      setState(() {
        _errorMessage = '認証に失敗しました: $e';
        _isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('パートナージム管理'),
        elevation: 2,
      ),
      body: SafeArea(
        child: Center(
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(24),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                // ロゴ・アイコン
                Icon(
                  Icons.fitness_center,
                  size: 80,
                  color: Theme.of(context).colorScheme.primary,
                ),
                const SizedBox(height: 24),

                // タイトル
                Text(
                  'パートナーオーナー専用',
                  style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                        fontWeight: FontWeight.bold,
                      ),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 8),

                // サブタイトル
                Text(
                  '店舗情報・キャンペーンをリアルタイム更新',
                  style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                        color: Colors.grey[600],
                      ),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 48),

                // アクセスコード入力欄
                TextField(
                  controller: _accessCodeController,
                  decoration: InputDecoration(
                    labelText: 'アクセスコード',
                    hintText: 'ANYTIME-SHINJUKU-2024',
                    prefixIcon: const Icon(Icons.vpn_key),
                    border: const OutlineInputBorder(),
                    errorText: _errorMessage,
                  ),
                  textCapitalization: TextCapitalization.characters,
                  enabled: !_isLoading,
                  onSubmitted: (_) => _verifyAccessCode(),
                ),
                const SizedBox(height: 24),

                // ログインボタン
                ElevatedButton(
                  onPressed: _isLoading ? null : _verifyAccessCode,
                  style: ElevatedButton.styleFrom(
                    padding: const EdgeInsets.symmetric(vertical: 16),
                    backgroundColor: Theme.of(context).colorScheme.primary,
                    foregroundColor: Colors.white,
                  ),
                  child: _isLoading
                      ? const SizedBox(
                          height: 20,
                          width: 20,
                          child: CircularProgressIndicator(
                            strokeWidth: 2,
                            valueColor:
                                AlwaysStoppedAnimation<Color>(Colors.white),
                          ),
                        )
                      : const Text(
                          'ログイン',
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                ),
                const SizedBox(height: 32),

                // ヘルプテキスト
                Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: Colors.blue[50],
                    borderRadius: BorderRadius.circular(8),
                    border: Border.all(color: Colors.blue[200]!),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Icon(Icons.info_outline,
                              size: 20, color: Colors.blue[700]),
                          const SizedBox(width: 8),
                          Text(
                            'アクセスコードについて',
                            style: TextStyle(
                              fontWeight: FontWeight.bold,
                              color: Colors.blue[900],
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 8),
                      Text(
                        'パートナー契約時に発行されたアクセスコードを入力してください。',
                        style: TextStyle(
                          fontSize: 14,
                          color: Colors.blue[900],
                        ),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        'コードをお持ちでない場合は、GYM MATCH運営までお問い合わせください。',
                        style: TextStyle(
                          fontSize: 12,
                          color: Colors.blue[700],
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
