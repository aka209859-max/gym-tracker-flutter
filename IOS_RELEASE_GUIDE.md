# 📱 GYM MATCH iOS リリース完全ガイド

## 📋 アプリ情報

- **アプリ名**: GYM MATCH (Gymmap)
- **Bundle ID**: `com.nexa.gymmatch`
- **バージョン**: 1.0.0 (Build 1)
- **カテゴリ**: ヘルスケア＆フィットネス
- **対象**: iOS 13.0以上

---

## 🎯 リリース手順（8ステップ）

### ✅ Step 1: Apple Developer Program登録

**必須条件:**
- Apple Developer Program加入（年間12,980円）
- 登録URL: https://developer.apple.com/programs/

**登録内容:**
- 会社名: 株式会社NexaJP
- 担当者: CEO
- メール: 登録用メールアドレス

---

### ✅ Step 2: App Store Connect設定

#### 2-1. 新規アプリ作成
1. App Store Connect: https://appstoreconnect.apple.com/
2. 「マイApp」→「+」→「新規App」
3. 入力内容:
   - **プラットフォーム**: iOS
   - **名前**: GYM MATCH
   - **主言語**: 日本語
   - **Bundle ID**: com.nexa.gymmatch
   - **SKU**: com.nexa.gymmatch.ios.v1
   - **アクセス権限**: フルアクセス

#### 2-2. アプリ情報入力
- **カテゴリ**: ヘルスケア＆フィットネス
- **サブカテゴリ**: フィットネス
- **コンテンツ権利**: 自社開発
- **年齢制限**: 4+（すべての年齢）

#### 2-3. 価格設定
- **価格**: 無料
- **App内課金**: なし（将来的に有料プラン追加予定）

---

### ✅ Step 3: Firebase iOS設定

#### 3-1. Firebase Consoleでアプリ追加
1. https://console.firebase.google.com/
2. プロジェクト「gym-match-e560d」選択
3. 「アプリを追加」→「iOS」
4. Bundle ID: `com.nexa.gymmatch`
5. **GoogleService-Info.plist** をダウンロード

#### 3-2. ファイル配置
```bash
# GoogleService-Info.plist を配置
cp ~/Downloads/GoogleService-Info.plist /home/user/flutter_app/ios/Runner/
```

#### 3-3. Xcode設定（Macで実行）
1. Xcodeでプロジェクトを開く
2. `ios/Runner.xcworkspace` を開く（`.xcodeproj` ではない）
3. Runner → Runner → GoogleService-Info.plist が追加されていることを確認

---

### ✅ Step 4: アプリアイコン設定

**必要なアイコンサイズ:**
- 1024x1024 (App Store用)
- 180x180 (iPhone Pro Max)
- 120x120 (iPhone)
- 87x87 (iPhone Settings)
- 80x80 (iPad)
- 58x58 (iPhone Settings)
- 40x40 (iPad Spotlight)
- 29x29 (Settings)
- 20x20 (Notifications)

**配置場所:**
```
ios/Runner/Assets.xcassets/AppIcon.appiconset/
```

**ツール推奨:**
- https://appicon.co/ (自動生成)
- https://makeappicon.com/ (自動生成)

---

### ✅ Step 5: スクリーンショット準備

**必須サイズ:**
- iPhone 6.7" (1290x2796) - 3枚以上
- iPhone 6.5" (1242x2688) - 3枚以上
- iPad Pro 12.9" (2048x2732) - オプション

**内容例:**
1. ホーム画面（カレンダー表示）
2. ジム検索マップ画面
3. トレーニング記録画面
4. 写真取り込み機能
5. 統計・分析画面

**ツール:**
- iOS Simulator（Xcode内蔵）
- Screenshot Generator Tools

---

### ✅ Step 6: Provisioning Profile作成（Macで実行）

#### 6-1. Xcodeで自動署名設定
```bash
# Xcodeを開く
open ios/Runner.xcworkspace
```

**設定項目:**
1. Runner → Signing & Capabilities
2. Team: 株式会社NexaJP を選択
3. 「Automatically manage signing」にチェック
4. Bundle Identifier: com.nexa.gymmatch を確認

#### 6-2. 証明書の確認
- Development Certificate（開発用）
- Distribution Certificate（リリース用）

---

### ✅ Step 7: iOSアプリビルド（Macで実行）

#### 7-1. リリースビルド作成
```bash
# プロジェクトディレクトリに移動
cd /path/to/flutter_app

# Flutter依存関係を更新
flutter pub get

# iOSビルド（リリースモード）
flutter build ios --release

# または Archive作成（Xcode使用）
# 1. Xcode で ios/Runner.xcworkspace を開く
# 2. Product → Archive
# 3. Archiveが完了したら Organizer が開く
```

#### 7-2. App Store Connect へアップロード
```bash
# Xcode Organizerから
# 1. 作成したArchiveを選択
# 2. 「Distribute App」をクリック
# 3. 「App Store Connect」を選択
# 4. 「Upload」を選択
# 5. アップロード完了まで待機（5-10分）
```

---

### ✅ Step 8: App Store Connect で審査申請

#### 8-1. ビルド選択
1. App Store Connect → マイApp → GYM MATCH
2. 「App Store」タブ
3. 「ビルド」セクション → 先ほどアップロードしたビルドを選択

#### 8-2. アプリ情報入力

**アプリ説明文（日本語）:**
```
【GYM MATCHとは】
全国47都道府県のジム検索＆トレーニング記録アプリ。
GPSで近くのジムを検索し、詳細なトレーニング記録を管理できます。

【主な機能】
✅ GPS検索：現在地から近いジムを即座に表示
✅ 詳細記録：種目・重量・セット数を簡単入力
✅ 写真取り込み：他アプリの記録画像を自動データ化（AI搭載）
✅ 統計分析：部位別・期間別のトレーニング分析
✅ カレンダー：トレーニング履歴を一目で確認

【こんな方におすすめ】
・ジム通いを習慣化したい方
・トレーニング記録を詳細に管理したい方
・旅行先や出張先でもジムを探したい方
・筋トレの進捗を可視化したい方

【対応地域】
全国47都道府県

【サポート】
ご質問・ご要望は以下までお問い合わせください。
メール: support@nexa.jp
```

**キーワード:**
```
ジム,フィットネス,トレーニング,筋トレ,ワークアウト,記録,GPS,検索,ヘルスケア,フィットネス
```

**プライバシーポリシーURL:**
```
https://nexa.jp/gym-match/privacy-policy
```

**サポートURL:**
```
https://nexa.jp/gym-match/support
```

#### 8-3. 審査情報入力

**連絡先情報:**
- 名前: 株式会社NexaJP サポート担当
- 電話: +81-XX-XXXX-XXXX
- メール: support@nexa.jp

**審査用メモ:**
```
【テストアカウント】
不要（匿名ログインで自動的にアカウント作成されます）

【特記事項】
- 位置情報：ジム検索機能で使用
- カメラ・フォトライブラリ：トレーニング記録の写真取り込み機能で使用
- AdMob：広告表示に使用
```

#### 8-4. 審査提出
1. 「審査に提出」ボタンをクリック
2. 輸出コンプライアンス: 「いいえ」（暗号化なし）
3. 広告識別子（IDFA）: 「はい」（AdMob使用のため）
   - 「アプリ内の広告を配信」にチェック
4. 最終確認 → 「送信」

---

## 📱 審査期間

**通常の審査期間:**
- 平均: 24-48時間
- 最短: 数時間
- 最長: 1週間

**審査ステータス:**
1. 審査待ち（Waiting for Review）
2. 審査中（In Review）
3. 承認（Approved）または 却下（Rejected）

---

## ⚠️ 審査で注意すべきポイント

### 1. プライバシー設定
- ✅ Info.plistに権限説明を記載済み
- ✅ 位置情報、カメラ、フォトライブラリの使用目的を明確化

### 2. 広告表示
- ✅ AdMob統合済み
- ⚠️ 審査時にテスト広告が表示されるため問題なし

### 3. Firebase設定
- ⚠️ GoogleService-Info.plist の配置必須
- ⚠️ Bundle ID の一致確認

### 4. スクリーンショット
- ⚠️ 実機またはSimulatorで撮影
- ⚠️ ステータスバーの時刻を9:41に設定推奨

---

## 🚀 リリース後のタスク

### 1. App Store最適化（ASO）
- キーワード選定
- アプリ説明文の改善
- スクリーンショットの最適化

### 2. ユーザーフィードバック対応
- レビュー監視
- バグ報告への迅速な対応

### 3. アップデート計画
- 新機能追加
- バグ修正
- パフォーマンス改善

---

## 📞 サポート・問い合わせ

**Apple Developer Support:**
- https://developer.apple.com/support/

**Firebase Support:**
- https://firebase.google.com/support

**Flutter iOS Support:**
- https://docs.flutter.dev/deployment/ios

---

## ✅ リリースチェックリスト

- [ ] Apple Developer Program登録完了
- [ ] App Store Connect でアプリ作成
- [ ] Firebase iOS設定完了（GoogleService-Info.plist配置）
- [ ] Privacy設定完了（Info.plist更新済み ✅）
- [ ] アプリアイコン準備（1024x1024他）
- [ ] スクリーンショット準備（最低3枚）
- [ ] Provisioning Profile作成
- [ ] iOSビルド成功
- [ ] App Store Connect へアップロード
- [ ] アプリ説明文・キーワード入力
- [ ] 審査提出

---

## 🎉 リリース成功後

**祝🎊 App Store公開完了！**

次のステップ:
1. SNSで告知
2. プレスリリース配信
3. ユーザー獲得キャンペーン
4. アプリ改善サイクル開始

---

**作成日**: 2025-11-14
**最終更新**: 2025-11-14
**バージョン**: 1.0
