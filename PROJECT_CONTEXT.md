# 🏋️ GYM MATCH - プロジェクトコンテキスト

**これは何か**: GYM MATCHエコシステムの**核心プロダクト**（メインアプリ）

---

## 🎯 エコシステムでの位置づけ

```
⭐️ GYM MATCH (これ!) - 最重要・事業の中心
├── 💼 GYM MATCH Manager - ジムオーナー管理パネル
└── 🏋️ GYM MATCH Coach - トレーナー向けアプリ
```

**この位置づけを忘れないこと！これが核心プロダクトです！**

---

## 📍 基本情報

| 項目 | 詳細 |
|-----|------|
| **ディレクトリ** | `/home/user/flutter_app/` |
| **技術スタック** | Flutter 3.35.4 + Dart 3.9.2 |
| **サーバー** | Port 5060（Python HTTP Server） |
| **アプリ名** | gym_match |
| **バージョン** | 1.0.0+1 |
| **ステータス** | β版運用中（85%完成） |

---

## 🎨 機能の二層構造

### 🌐 誰でも使える（非ログイン）

**目的**: ユーザー獲得・価値提供

1. **ジム検索** (Google Maps統合)
   - リアルタイムジム検索
   - 地図上でジム表示
   - エリア別検索

2. **混雑度表示**
   - リアルタイム混雑度
   - ユーザー投稿レポート
   - 時間帯別予測

3. **ジム情報閲覧**
   - 営業時間
   - 設備情報
   - レビュー閲覧

**実装ファイル**:
- `lib/screens/map_screen.dart`
- `lib/screens/gym_list_screen.dart`
- `lib/screens/gym_detail_screen.dart`
- `lib/screens/search_screen.dart`

### 🔐 会員限定（ログイン必要）

**目的**: マネタイズ・ロックイン

1. **詳細な筋トレ記録・トラッキング**
   - トレーニングカレンダー
   - セット・レップ・重量記録
   - 部位別トラッキング
   - 自己ベスト（PR）管理
   - 週次レポート
   - RM計算機

   **実装ファイル**:
   - `lib/screens/home_screen.dart` (メイン画面)
   - `lib/screens/workout/add_workout_screen.dart`
   - `lib/screens/workout/workout_log_screen.dart`
   - `lib/screens/workout/body_part_tracking_screen.dart`
   - `lib/screens/workout/personal_records_screen.dart`
   - `lib/screens/workout/weekly_reports_screen.dart`
   - `lib/screens/workout/rm_calculator_screen.dart`

2. **🤖 AIコーチ機能（プレミアム）**
   - トレーニングプラン提案
   - フォームアドバイス
   - パーソナライズドレコメンデーション
   - 進捗分析とフィードバック

   **実装ファイル**:
   - `lib/screens/workout/ai_coaching_screen.dart`

   **マネタイズポイント**: プレミアム会員限定

3. **セッション予約**
   - パーソナルトレーニング予約
   - トレーナー選択
   - 日時指定

   **実装ファイル**:
   - `lib/screens/reservation_form_screen.dart`

4. **お気に入り・ブックマーク**
   - よく行くジム登録
   - 予約管理

   **実装ファイル**:
   - `lib/screens/favorites_screen.dart`

5. **プロフィール・サブスクリプション**
   - ユーザー情報管理
   - 統計表示
   - プレミアムプラン管理

   **実装ファイル**:
   - `lib/screens/profile_screen.dart`
   - `lib/screens/subscription_screen.dart`

---

## 💰 マネタイズ戦略

### フリーミアムモデル

```
🆓 無料プラン
├── ジム検索
├── 混雑度表示
├── 基本的な筋トレ記録
└── 基本統計・グラフ

💎 プレミアムプラン（月額課金）
├── 🤖 AIコーチ機能
├── 📊 高度な分析・レポート
├── 🏋️ パーソナライズドトレーニングプラン
├── 📱 セッション予約優先アクセス
└── 🔔 高度な通知機能
```

---

## 📊 現在の開発状況

| 機能カテゴリ | 状態 | 完成度 |
|------------|------|--------|
| ジム検索（Google Maps） | ✅ 実装済み | 90% |
| 混雑度表示 | ✅ 実装済み | 85% |
| 筋トレ記録（基本） | ✅ 実装済み | 95% |
| 筋トレ記録（高度） | ✅ 実装済み | 90% |
| **AIコーチ** | ✅ 実装済み | **70%** |
| セッション予約 | ✅ 実装済み | 80% |
| プロフィール管理 | ✅ 実装済み | 85% |
| サブスクリプション | ✅ 実装済み | 75% |
| パートナージム機能 | ✅ 実装済み | 60% |

**総合完成度**: 約85%（β版運用可能レベル）

---

## 🚀 次のタスク（優先順位順）

### Priority: High

1. **🤖 AIコーチ機能の強化**
   - より高度なトレーニングプラン生成
   - 実際のAI統合（現在はデモ実装）
   - **ファイル**: `lib/screens/workout/ai_coaching_screen.dart`

2. **🔔 プッシュ通知実装**
   - トレーニングリマインダー
   - セッション予約通知
   - **パッケージ**: firebase_messaging追加必要

3. **💳 決済機能統合**
   - サブスクリプション課金
   - セッション予約決済
   - **パッケージ**: stripe_payment等の追加検討

### Priority: Medium

4. **🎨 UI/UX改善**
   - ユーザビリティテスト結果の反映
   - アニメーション追加

5. **📱 オフライン対応強化**
   - ローカルキャッシュ改善
   - オフライン時の記録保存

---

## 🔧 技術スタック

### Firebase
```yaml
firebase_core: 3.6.0
cloud_firestore: 5.4.3
firebase_auth: 5.3.1
firebase_storage: 12.3.2
```

### Google Maps
```yaml
google_maps_flutter: 2.10.0
google_maps_flutter_web: 0.5.10
geolocator: 13.0.2
geocoding: 3.0.0
```

### 状態管理
```yaml
provider: 6.1.5+1
```

### ローカルストレージ
```yaml
shared_preferences: 2.5.3
hive: 2.2.3
hive_flutter: 1.1.0
```

### UI/チャート
```yaml
fl_chart: ^0.69.0
table_calendar: ^3.1.2
flutter_rating_bar: ^4.0.1
cached_network_image: ^3.4.1
image_picker: ^1.1.2
```

---

## 📁 プロジェクト構造

```
flutter_app/
├── lib/
│   ├── main.dart                   # エントリーポイント
│   ├── firebase_options.dart       # Firebase設定
│   ├── models/                     # データモデル（12ファイル）
│   ├── screens/                    # 画面（20ファイル）
│   │   ├── workout/               # 筋トレ記録関連（8ファイル）
│   │   └── po/                    # パートナージム管理
│   ├── providers/                  # 状態管理
│   ├── services/                   # API・Firebase連携
│   ├── utils/                      # ユーティリティ
│   └── widgets/                    # 再利用可能コンポーネント
├── android/                        # Android設定
├── ios/                           # iOS設定
├── web/                           # Web設定
└── pubspec.yaml                   # 依存関係
```

**総ファイル数**: 60個のDartファイル

---

## 🔗 関連リンク

- **エコシステム全体**: `/home/user/GYM_MATCH_ECOSYSTEM.md`
- **Manager**: `/home/user/gym-match-po-admin/PROJECT_CONTEXT.md`
- **サーバー**: `http://localhost:5060`

---

## 📝 最終更新

**2025-01-03**: プロジェクトコンテキスト作成、全体構造整理

---

**⭐️ これがGYM MATCHエコシステムの核心プロダクトです！**
