# Week 2 Day 1 - 未翻訳文字列分析レポート

**日付**: 2025-12-26  
**分析者**: Claude AI Assistant  
**Week 2目標**: 翻訳カバレッジ 79.2% → 100% (+20.8%)

---

## 📊 **Phase 1: 未翻訳文字列特定結果**

### **総数**

```
🔍 検出方法: grep -rE "Text\(.*['\"][ぁ-んァ-ヶ一-龯]" lib/ (AppLocalizations除外)

📊 未翻訳Text widget: 192件
   - ひらがな: 106件
   - カタカナ: 106件
   - 漢字: 199件
   (重複あり - 合計192件)

📊 Week 1実績との比較:
   - Week 1置換: 1,167件
   - Week 2残り (Text widget): 192件
   - 合計: 1,359件

📊 翻訳カバレッジ予測:
   - 現在: 79.2% (6,232/7,868)
   - Week 2追加: 192件 → 6,424/7,868 = 81.7%
   - 目標100%まで: 残り1,444件
```

**注意**: Text widget以外にも、以下のパターンがある可能性:
- `SnackBar(content: Text(...))`
- `AlertDialog(title: Text(...))`
- `TextField(labelText: '...')`
- `String変数への直接代入`
- `print()`, `debugPrint()`などのログ出力

---

## 📁 **Top 30 ファイル別分析**

### **優先度: 高 (10件以上)**

| ファイル | 未翻訳数 | カテゴリ | 優先度 |
|---------|---------|---------|--------|
| `lib/screens/workout/ai_coaching_screen_tabbed.dart` | 13 | Workout | 🔴 High |
| `lib/screens/workout/add_workout_screen.dart` | 10 | Workout | 🔴 High |
| `lib/screens/profile_screen.dart` | 10 | Profile | 🔴 High |

**合計**: 33件 (17.2%)

---

### **優先度: 中 (5-9件)**

| ファイル | 未翻訳数 | カテゴリ | 優先度 |
|---------|---------|---------|--------|
| `lib/screens/home_screen.dart` | 9 | Home | 🟡 Medium |
| `lib/screens/goals_screen.dart` | 9 | Goals | 🟡 Medium |
| `lib/screens/developer_menu_screen.dart` | 8 | Developer | 🟢 Low |
| `lib/screens/body_measurement_screen.dart` | 7 | Health | 🟡 Medium |
| `lib/widgets/reward_ad_dialog.dart` | 6 | Widget | 🟡 Medium |
| `lib/screens/workout/ai_coaching_screen.dart` | 6 | Workout | 🟡 Medium |
| `lib/screens/workout/simple_workout_detail_screen.dart` | 5 | Workout | 🟡 Medium |
| `lib/screens/subscription_screen.dart` | 5 | Subscription | 🟡 Medium |
| `lib/screens/gym_review_screen.dart` | 5 | Gym | 🟡 Medium |

**合計**: 60件 (31.3%)

---

### **優先度: 低 (3-4件)**

| ファイル | 未翻訳数 | カテゴリ | 優先度 |
|---------|---------|---------|--------|
| `lib/screens/po/po_analytics_screen.dart` | 4 | PO | 🟢 Low |
| `lib/screens/partner_photos_screen.dart` | 4 | Partner | 🟡 Medium |
| `lib/screens/partner/partner_detail_screen.dart` | 4 | Partner | 🟡 Medium |
| `lib/screens/partner/chat_screen_partner.dart` | 4 | Chat | 🟡 Medium |
| `lib/screens/redeem_invite_code_screen.dart` | 3 | Campaign | 🟢 Low |
| `lib/screens/po/po_dashboard_screen.dart` | 3 | PO | 🟢 Low |
| `lib/screens/personal_training_screen.dart` | 3 | Training | 🟡 Medium |
| `lib/screens/partner_campaign_editor_screen.dart` | 3 | Campaign | 🟢 Low |
| `lib/screens/debug_log_screen.dart` | 3 | Developer | 🟢 Low |
| `lib/screens/calculators_screen.dart` | 3 | Tools | 🟡 Medium |
| `lib/screens/achievements_screen.dart` | 3 | Achievements | 🟡 Medium |

**合計**: 38件 (19.8%)

---

### **優先度: 最低 (2件)**

| ファイル | 未翻訳数 | カテゴリ | 優先度 |
|---------|---------|---------|--------|
| `lib/widgets/paywall_dialog.dart` | 2 | Widget | 🟡 Medium |
| `lib/widgets/install_prompt.dart` | 2 | Widget | 🟢 Low |
| `lib/services/workout_share_service.dart` | 2 | Service | 🟢 Low |
| `lib/services/review_request_service.dart` | 2 | Service | 🟢 Low |
| `lib/services/enhanced_share_service.dart` | 2 | Service | 🟢 Low |
| `lib/screens/workout/workout_memo_list_screen.dart` | 2 | Workout | 🟡 Medium |
| `lib/screens/workout/weekly_reports_screen.dart` | 2 | Workout | 🟡 Medium |
| その他30+ファイル (1件ずつ) | ~60 | Various | 🟢 Low |

**合計**: ~61件 (31.8%)

---

## 📋 **Phase 2: カテゴリ別分類**

### **カテゴリ1: Error Messages (エラーメッセージ)**

```
推定: 約50件 (26%)

パターン:
- SnackBar(content: Text('エラーメッセージ'))
- '...に失敗しました'
- '...できませんでした'
- '...が見つかりません'

例:
- 'バッジの読み込みに失敗しました'
- '購入処理に失敗しました'
- 'メッセージ送信に失敗しました'
- '体重または体脂肪率を入力してください'

優先度: 🔴 High (ユーザーエラー体験に直結)
```

---

### **カテゴリ2: Dynamic Content (動的コンテンツ)**

```
推定: 約60件 (31%)

パターン:
- Text('値: ${変数}')
- Text('${value}kg')
- Text('${percentage}%')
- 日付・時刻フォーマット

例:
- '体重: ${weight.toStringAsFixed(1)}kg'
- '体脂肪率: ${bodyFat.toStringAsFixed(1)}%'

優先度: 🟡 Medium (頻繁に使用される)
```

---

### **カテゴリ3: Static Labels (静的ラベル)**

```
推定: 約40件 (21%)

パターン:
- title: Text('タイトル')
- const Text('ラベル')
- label: const Text('...')

例:
- '達成バッジ'
- '計算ツール'
- '購入する'
- 'データ戦略フェーズ管理'

優先度: 🟡 Medium (画面タイトル・ボタンラベル)
```

---

### **カテゴリ4: Developer/Debug (開発者向け)**

```
推定: 約20件 (10%)

パターン:
- debugPrint('...')
- print('デバッグ: ...')
- Developer menu items

例:
- developer_menu_screen.dart: 8件
- debug_log_screen.dart: 3件

優先度: 🟢 Low (エンドユーザーに非表示)
```

---

### **カテゴリ5: Edge Cases (エッジケース)**

```
推定: 約22件 (11%)

パターン:
- 条件分岐内の文字列
- 複雑な文字列補間
- ビルダー内の動的生成

優先度: 🟡 Medium (見落としがち)
```

---

## 🎯 **Phase 3: 優先度付け**

### **Week 2 Day 1 ターゲット: 350件**

**問題**: Text widgetだけでは192件しかない！

**解決策**: 他のパターンも含める

```
1. Text widget: 192件
2. TextField labelText: 推定50件
3. SnackBar content: 推定30件 (一部重複)
4. AlertDialog title/content: 推定20件
5. String変数への代入: 推定30件
6. print/debugPrint: 推定20件
7. その他 (Tooltip, Placeholder, etc.): 推定50件

合計推定: 約392件
```

---

### **Week 2 Day 1 実行計画 (修正版)**

#### **Phase 4: High Priority 置換** (90分)

**ターゲット**: Error Messages + Static Labels  
**件数**: 約90件  
**コミット**: 2回 (45件/コミット)

**対象ファイル (Top 3)**:
1. `ai_coaching_screen_tabbed.dart` (13件)
2. `add_workout_screen.dart` (10件)
3. `profile_screen.dart` (10件)

---

#### **Phase 5: Medium Priority 置換** (90分)

**ターゲット**: Dynamic Content + 中規模ファイル  
**件数**: 約100件  
**コミット**: 2回 (50件/コミット)

**対象ファイル (5-9件)**:
- `home_screen.dart` (9件)
- `goals_screen.dart` (9件)
- `body_measurement_screen.dart` (7件)
- `reward_ad_dialog.dart` (6件)
- `ai_coaching_screen.dart` (6件)

---

#### **Phase 6: ビルド & 検証** (30分)

```
✅ Git commit & push
✅ Build #14 トリガー
✅ ビルド結果確認
✅ エラー修正 (if any)
```

---

## 📊 **Week 2 Day 1 目標 (修正)**

```
🎯 Text widget置換: 90-100件
📊 進捗予測: 79.2% → 80.5% (+1.3%)
⏱️ 所要時間: 約3.5時間
📝 コミット数: 4回
🏗️ ビルド: Build #14

※ 初日は控えめに設定
※ Text widget以外のパターンは Day 2以降で対応
```

---

## 🚨 **重要な発見**

### **問題点**

```
Week 2全体で1,636件の置換が必要と予測していたが、
Text widgetのみでは192件しか検出されていない。

差分: 1,636 - 192 = 1,444件 はどこに？
```

### **可能性**

1. **Week 1で既に対応済み**
   - Week 1で1,167件置換済み
   - 残りの文字列は既にAppLocalizations化されている可能性

2. **他のパターンに存在**
   - TextField, SnackBar, AlertDialog など
   - 文字列補間パターン
   - ログ出力文字列

3. **翻訳カバレッジの計算方法**
   - 79.2% = 6,232/7,868
   - 7,868は総ARBキー数
   - すべての文字列がコードに明示的に存在するわけではない
   - 一部は動的生成や条件分岐内

---

## 🎯 **Week 2 Day 1 実行方針**

### **現実的な目標設定**

```
Day 1目標: Text widget 90-100件置換
- High priority files: Top 3 (33件)
- Medium priority files: Next 5 (60件)
- 合計: 約93件

進捗: 79.2% → 80.5%
残り: Week 2 Day 2-5 で残りを対応
```

### **次のステップ**

1. **Top 3ファイルの詳細分析**
   - 実際の文字列内容確認
   - ARBキー選定
   - 置換スクリプト作成

2. **Phase 4実行** (High Priority)
   - ai_coaching_screen_tabbed.dart
   - add_workout_screen.dart
   - profile_screen.dart

3. **Phase 5実行** (Medium Priority)
   - home_screen.dart以下5ファイル

4. **Phase 6検証**
   - Build #14トリガー
   - SUCCESS確認

---

## 📅 **Week 2 全体計画 (修正版)**

```
Day 1 (今日): Text widget 90-100件 (High + Medium)
Day 2: TextField, SnackBar, AlertDialog 等 100件
Day 3: String変数, print/debugPrint 等 80件
Day 4: 残りのText widget + Edge cases 80件
Day 5: 最終確認 + 追加分 50件 + TestFlight検証

合計: 400-410件 (現実的な目標)
```

---

**作成日時**: 2025-12-26 18:00 JST  
**ステータス**: Phase 1 Complete - Ready for Phase 4  
**次のアクション**: Top 3ファイルの詳細分析

---
