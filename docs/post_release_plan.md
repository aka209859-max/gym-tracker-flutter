# iOS リリース後の戦略 - Pro プラン即時有効化計画

**作成日**: 2025年1月  
**対象**: GYM MATCH iOS アプリ正式リリース後の運用体制

---

## 🎯 基本方針

### **CEO専用のPro プラン有効化**

**目的**:
- iOS リリース直後から、CEO自身が**Pro プラン全機能を使用可能**にする
- RevenueCat サブスクリプション実装は完了しているが、**開発者として即座にProプラン特典を享受**したい

**理由**:
1. **CEOの使命**: 4ヶ月でARR1000万円達成 → 自社アプリで高機能を実演する必要がある
2. **未来志向の実演**: 「過去の実績ゼロ」を補う手段として、Proプラン機能を使った「未来の実演」を提示
3. **戦略的明確化**: AI機能（月30回）、パートナー検索、メッセージング機能を最大限活用

---

## 📋 現在の課金体系（実装済み）

### **プラン一覧**

| プラン | 月額料金 | 主な機能 | AI使用回数 |
|--------|---------|---------|-----------|
| **無料プラン** | ¥0 | ジム検索 + トレーニング記録 + 広告表示 | 0回 |
| **プレミアムプラン** | ¥500 | AI機能 + お気に入り無制限 + レビュー投稿 + 広告非表示 | 月10回 |
| **プロプラン** | ¥980 | プレミアム全機能 + AI週次レポート + パートナー検索 + メッセージング | 月30回 |

### **実装状況**

- ✅ **RevenueCat SDK 統合完了** (`purchases_flutter: ^8.11.0`)
- ✅ **SubscriptionService 実装完了** (`lib/services/subscription_service.dart`)
- ✅ **3プラン定義完了** (free, premium, pro)
- ✅ **AI使用回数制限ロジック実装完了** (月次リセット機能含む)
- ✅ **プラン変更機能実装完了** (`setPlan()`, `changePlan()`)

---

## 🚀 リリース後即時実施：CEO専用Pro有効化

### **実施タイミング**

**Phase 3完了直後**（TestFlight インストール成功後）:

1. ✅ TestFlight からアプリをインストール
2. ✅ アカウント登録（rooodokanaroa@icloud.com）
3. **✅ Pro プラン手動有効化（以下の方法で実施）**

---

## 🔧 Pro プラン手動有効化の方法

### **方法1: アプリ内開発者メニューで有効化（推奨）**

**前提**: アプリに開発者メニューを追加する必要がある

**実装手順**:

#### **1. デバッグ用開発者メニュー画面を作成**

```dart
// lib/screens/developer_menu_screen.dart
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/user_provider.dart';
import '../services/subscription_service.dart';

class DeveloperMenuScreen extends StatelessWidget {
  const DeveloperMenuScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final userProvider = Provider.of<UserProvider>(context);
    final subscriptionService = SubscriptionService();

    return Scaffold(
      appBar: AppBar(
        title: const Text('開発者メニュー'),
        backgroundColor: Colors.deepPurple,
      ),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          const ListTile(
            leading: Icon(Icons.warning, color: Colors.orange),
            title: Text(
              '⚠️ 開発者専用',
              style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18),
            ),
            subtitle: Text('本番環境では表示されません'),
          ),
          const Divider(),
          
          // 現在のプラン表示
          FutureBuilder<SubscriptionType>(
            future: subscriptionService.getCurrentPlan(),
            builder: (context, snapshot) {
              if (!snapshot.hasData) {
                return const CircularProgressIndicator();
              }
              final currentPlan = snapshot.data!;
              return ListTile(
                leading: const Icon(Icons.account_circle),
                title: const Text('現在のプラン'),
                subtitle: Text(subscriptionService.getPlanName(currentPlan)),
                trailing: _getPlanBadge(currentPlan),
              );
            },
          ),
          
          const Divider(),
          const SizedBox(height: 16),
          
          // プラン変更ボタン
          _buildPlanButton(
            context,
            subscriptionService,
            SubscriptionType.free,
            '無料プランに変更',
            Colors.grey,
          ),
          const SizedBox(height: 8),
          _buildPlanButton(
            context,
            subscriptionService,
            SubscriptionType.premium,
            'プレミアムプランに変更',
            Colors.blue,
          ),
          const SizedBox(height: 8),
          _buildPlanButton(
            context,
            subscriptionService,
            SubscriptionType.pro,
            'Proプランに変更',
            Colors.deepPurple,
          ),
          
          const SizedBox(height: 32),
          
          // AI使用状況
          FutureBuilder<String>(
            future: subscriptionService.getAIUsageStatus(),
            builder: (context, snapshot) {
              if (!snapshot.hasData) {
                return const SizedBox();
              }
              return Card(
                color: Colors.purple.shade50,
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        'AI使用状況',
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 8),
                      Text(snapshot.data!),
                    ],
                  ),
                ),
              );
            },
          ),
          
          const SizedBox(height: 16),
          
          // AI使用回数リセットボタン
          ElevatedButton.icon(
            onPressed: () async {
              final prefs = await SharedPreferences.getInstance();
              await prefs.setInt('ai_usage_count', 0);
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('✅ AI使用回数をリセットしました')),
              );
            },
            icon: const Icon(Icons.refresh),
            label: const Text('AI使用回数をリセット'),
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.orange,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildPlanButton(
    BuildContext context,
    SubscriptionService service,
    SubscriptionType plan,
    String label,
    Color color,
  ) {
    return ElevatedButton(
      onPressed: () async {
        final success = await service.changePlan(plan);
        if (context.mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(
                success 
                  ? '✅ ${service.getPlanName(plan)}に変更しました'
                  : '❌ プラン変更に失敗しました',
              ),
            ),
          );
        }
      },
      style: ElevatedButton.styleFrom(
        backgroundColor: color,
        minimumSize: const Size.fromHeight(48),
      ),
      child: Text(label),
    );
  }

  Widget _getPlanBadge(SubscriptionType plan) {
    final color = switch (plan) {
      SubscriptionType.free => Colors.grey,
      SubscriptionType.premium => Colors.blue,
      SubscriptionType.pro => Colors.deepPurple,
    };
    
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(
        color: color,
        borderRadius: BorderRadius.circular(16),
      ),
      child: Text(
        switch (plan) {
          SubscriptionType.free => 'FREE',
          SubscriptionType.premium => 'PREMIUM',
          SubscriptionType.pro => 'PRO',
        },
        style: const TextStyle(
          color: Colors.white,
          fontWeight: FontWeight.bold,
          fontSize: 12,
        ),
      ),
    );
  }
}
```

#### **2. ホーム画面に開発者メニューへのアクセス追加**

```dart
// lib/screens/home_screen.dart の AppBar に追加

AppBar(
  title: const Text('GYM MATCH'),
  actions: [
    // 既存のコード...
    
    // 開発者メニュー（リリースビルドでは非表示）
    if (kDebugMode) // flutter/foundation.dart の import が必要
      IconButton(
        icon: const Icon(Icons.developer_mode),
        tooltip: '開発者メニュー',
        onPressed: () {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => const DeveloperMenuScreen(),
            ),
          );
        },
      ),
  ],
)
```

#### **3. リリースビルドでは非表示にする設定**

```dart
// flutter/foundation.dart をインポート
import 'package:flutter/foundation.dart';

// kDebugMode で判定
if (kDebugMode) {
  // 開発者メニュー表示
}
```

**この方法の利点**:
- ✅ アプリ内で即座にプラン変更可能
- ✅ TestFlight ビルドでも利用可能（デバッグモードで実行すれば表示される）
- ✅ リリースビルドでは自動的に非表示

---

### **方法2: SharedPreferences を直接編集（iOS の場合）**

**前提**: iOS シミュレータまたは脱獄済みiPhoneが必要

**手順**:

1. アプリをインストール
2. iOS の Settings.app または Xcode の Device Console でアプリの SharedPreferences にアクセス
3. キー `subscription_type` に値 `SubscriptionType.pro` を設定

**制約**: 通常のiPhoneユーザーには実施困難（方法1推奨）

---

### **方法3: Firebase Firestore で管理（将来的な拡張）**

**アイデア**: 
- ユーザーごとのプラン情報を Firestore に保存
- CEO のメールアドレス（rooodokanaroa@icloud.com）を特別扱いし、常に Pro プラン扱いにする

**実装イメージ**:

```dart
// lib/services/subscription_service.dart に追加

Future<SubscriptionType> getCurrentPlan() async {
  // Firebase Auth で現在のユーザーを取得
  final user = FirebaseAuth.instance.currentUser;
  
  // CEO アカウントなら強制的に Pro プラン
  if (user?.email == 'rooodokanaroa@icloud.com') {
    return SubscriptionType.pro;
  }
  
  // 既存のロジック...
}
```

**利点**:
- ✅ サーバー側で管理可能
- ✅ いつでもリモートで変更可能
- ✅ 将来的な拡張性が高い

**現時点の課題**:
- Firebase Auth 実装がまだ完了していない可能性

---

## 📅 実施タイミングと優先順位

### **Phase 3 完了直後（TestFlight インストール成功）**

**優先順位**:

1. **最優先**: **方法1（開発者メニュー）を実装** → 次回ビルドに含める
2. 代替案: **方法3（Firebase）を将来的に検討**
3. 非推奨: 方法2（iOS設定直接編集）は手間がかかるため避ける

---

## 🎯 Pro プラン有効化後の活用戦略

### **CEOの使命に沿った活用**

**目標**: 4ヶ月でARR1000万円達成

**Pro プラン機能を使った実演**:

1. **AI機能（月30回）**:
   - ワークアウト分析AIを積極的に利用
   - デモ動画・スクリーンショットを撮影
   - 「AI戦略家」としての実演素材を作成

2. **パートナー検索**:
   - ジムでのトレーニングパートナーを探す機能を実演
   - コミュニティ機能の価値を可視化

3. **メッセージング**:
   - ユーザー間コミュニケーション機能を実演
   - ネットワーク効果をアピール

4. **AI週次レポート**:
   - 毎週のトレーニング進捗レポートを受け取る
   - データドリブンな改善提案を実演

---

## 🚀 次のステップ

### **Phase 2 完了後（Windows PC帰宅後）**:

1. ✅ 手動コード署名設定（30分）
2. ✅ Build #31 トリガー
3. ✅ TestFlight アップロード確認

### **Phase 3 開始時（TestFlight配信後）**:

1. ✅ 開発者メニュー実装（次回ビルド用）
2. ✅ TestFlight からアプリインストール
3. ✅ 開発者メニューで Pro プラン有効化
4. ✅ 全機能動作確認

### **Phase 4（正式リリース後）**:

1. ✅ CEO自身がPro プラン全機能を使用
2. ✅ 実演素材（動画・スクリーンショット）を作成
3. ✅ NexaJP のマーケティング資料に活用
4. ✅ 「未来の実演」として顧客に提示

---

## 💡 重要な注意事項

### **開発者メニューのセキュリティ**

- ✅ **リリースビルドでは完全に非表示** → `kDebugMode` で制御
- ✅ **TestFlightビルドではデバッグモードで実行可能**
- ✅ **App Store 正式版では表示されない** → ユーザーに見えない

### **RevenueCat との共存**

- 現在の実装は SharedPreferences ベース
- 将来的に RevenueCat の実購入データと連携可能
- CEO専用の特別扱いロジックを追加しても問題なし

---

**作成者**: AI戦略家  
**最終更新**: Phase 1 完了時  
**次回更新予定**: Phase 3（TestFlight配信）直後
