# プライバシーポリシー恒久的ホスティング手順

## 🚨 重要: ポート5060の問題

**現在のURL**: `https://5060-i1wzdi6c2urpgehncb6jg-5c13a017.sandbox.novita.ai/privacy_policy.html`

**問題点**:
- ❌ 開発サンドボックス環境（一時的）
- ❌ サンドボックスが停止すると404エラー
- ❌ App Store審査で不適格と判定される可能性

## ✅ 推奨解決策: GitHub Pagesでの恒久的ホスティング

### **方法1: GitHubリポジトリでホスティング（推奨）**

#### **Step 1: GitHubにプライバシーポリシーをプッシュ**

```bash
# Flutter appリポジトリに追加
cd /home/user/flutter_app
git add web/privacy_policy.html
git commit -m "Add privacy policy for App Store"
git push origin main
```

#### **Step 2: GitHub Pagesを有効化**

1. GitHubリポジトリページを開く
2. **Settings** → **Pages**
3. **Source**: `main` ブランチ
4. **Folder**: `/` (root) または `/web`
5. **Save**をクリック

#### **Step 3: 公開URLを取得**

GitHub Pagesが有効になると、以下の形式のURLが発行されます：
```
https://<username>.github.io/<repository-name>/web/privacy_policy.html
```

**例**:
```
https://ikeuchi-hajime.github.io/gym-match/web/privacy_policy.html
```

#### **Step 4: App Store Connectに設定**

1. **App Store Connect** → **マイApp** → **GYM MATCH**
2. **アプリ情報** → **プライバシーポリシー**
3. GitHub Pages URLを入力
4. **保存**

---

### **方法2: 独自ドメインでホスティング（プロフェッショナル）**

#### **Option A: Cloudflare Pagesでホスティング**

1. **Cloudflare Pages**にログイン
2. **Create a project** → **Connect to Git**
3. リポジトリを選択
4. **Build settings**:
   - Framework preset: `None`
   - Build command: (空)
   - Build output directory: `web`
5. **Save and Deploy**

**結果URL例**: `https://gym-match-privacy.pages.dev`

#### **Option B: Vercel/Netlifyでホスティング**

同様の手順で静的ファイルをデプロイ可能。

---

### **方法3: Firebase Hostingでホスティング（Firebase利用中の場合）**

既にFirebaseを使用しているため、Firebase Hostingが最も統合しやすい：

```bash
# Firebase CLIインストール（必要に応じて）
npm install -g firebase-tools

# Firebase初期化
cd /home/user/flutter_app
firebase init hosting

# プライバシーポリシーをpublicディレクトリに配置
cp web/privacy_policy.html public/privacy_policy.html

# デプロイ
firebase deploy --only hosting
```

**結果URL例**: `https://<your-project-id>.web.app/privacy_policy.html`

---

## 📋 App Store Connectでの最終設定

### **推奨URL形式（優先順位順）**:

1. **Firebase Hosting** (最優先):
   ```
   https://gym-match-app.web.app/privacy_policy.html
   ```

2. **独自ドメイン**:
   ```
   https://privacy.gym-match.app/privacy_policy.html
   ```

3. **GitHub Pages**:
   ```
   https://ikeuchi-hajime.github.io/gym-match/web/privacy_policy.html
   ```

4. **Cloudflare Pages**:
   ```
   https://gym-match-privacy.pages.dev/privacy_policy.html
   ```

---

## 🎯 今すぐできる対応

### **緊急対応（今日中）**:

1. **GitHubにプッシュ** → GitHub Pages有効化（無料、5分で完了）
2. **Firebase Hosting** → 既存Firebase環境を活用（推奨）

### **長期対応**:

- 独自ドメイン取得（例: `gym-match.app`）
- プライバシーポリシー専用サブドメイン（`privacy.gym-match.app`）

---

## ✅ プライバシーポリシー内容（更新済み）

以下の情報が正しく反映されています：

- ✅ **開発者名**: 池内　一（個人開発者）
- ✅ **連絡先**: i.hajime1219@outlook.jp
- ✅ **法人表記**: 削除済み
- ✅ **データ収集内容**: 詳細記載
- ✅ **第三者サービス**: Firebase, AdMob, RevenueCat, Gemini API, Google Maps
- ✅ **ユーザーの権利**: 明記
- ✅ **セキュリティ対策**: 記載

---

## 🚀 次のアクション

1. **GitHub Pages または Firebase Hostingでホスティング** （推奨）
2. **App Store Connectに恒久的URLを設定**
3. **開発サンドボックスURLは使用しない**

**サポートが必要な場合は、いつでもお知らせください！**
