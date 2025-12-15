# 🤖 GYM MATCH Android準備ガイド

**作成日**: 2025-12-15  
**対象バージョン**: v1.0.244+269

---

## 📋 **Android準備の現状**

### ✅ **完了済み項目**

1. ✅ **Androidディレクトリ構成** - 基本構造は既に存在
2. ✅ **build.gradle設定** - リリース署名設定済み
3. ✅ **AndroidManifest.xml** - アプリ名を"GYM MATCH"に変更済み
4. ✅ **key.properties** - 署名設定ファイル作成済み（パスワード設定済み）

### ❌ **要対応項目**

1. ❌ **Firebase Android設定** - `google-services.json`が必要
2. ❌ **リリース署名鍵** - `release-key.jks`ファイルの作成が必要
3. ❌ **firebase_options.dart** - Android設定を追加する必要あり
4. ⚠️ **GitHub Actions** - Android APK/AABビルドワークフローが未作成

---

## 🔧 **必須作業: Android署名鍵の作成**

### **署名鍵作成手順（ローカルMac/Windows環境で実行）**

```bash
# Androidディレクトリに移動
cd /path/to/gym_match/android

# リリース署名鍵を作成
keytool -genkey -v \
  -keystore release-key.jks \
  -keyalg RSA \
  -keysize 2048 \
  -validity 10000 \
  -alias release \
  -storepass gymmatch2025secure \
  -keypass gymmatch2025secure \
  -dname "CN=NexaJP, OU=Enable, O=Enable Inc., L=Tokyo, ST=Tokyo, C=JP"
```

### **重要事項**

- **`release-key.jks`** - このファイルは **絶対に紛失しないでください**
- **パスワード** - `gymmatch2025secure` をメモしてください
- **バックアップ** - 安全な場所に保管してください（例: 1Password、暗号化USB）

### **署名鍵の配置場所**

```
android/
├── release-key.jks          ← ここに配置（.gitignoreで除外済み）
└── key.properties           ← ここに配置（.gitignoreで除外済み）
```

---

## 🔥 **Firebase Android設定の追加**

### **Step 1: Firebaseコンソールでの作業**

1. **Firebase Console にアクセス**
   - URL: https://console.firebase.google.com/
   - プロジェクト: `gym-match-e560d`

2. **Androidアプリを追加**
   - プロジェクト設定 → 全般
   - 「アプリを追加」→「Android」を選択

3. **Androidアプリ情報を入力**
   ```
   Androidパッケージ名: jp.nexa.fitsync
   アプリのニックネーム: GYM MATCH Android
   デバッグ用の署名証明書（SHA-1）: [任意]
   ```

4. **`google-services.json`をダウンロード**
   - ダウンロードしたファイルを以下に配置:
   ```
   android/app/google-services.json
   ```

### **Step 2: `firebase_options.dart`の更新**

Firebase CLIを使用してAndroid設定を自動追加：

```bash
# Firebase CLI でAndroid設定を追加
flutter pub global activate flutterfire_cli
flutterfire configure --platforms=android
```

または、手動で`lib/firebase_options.dart`に以下を追加：

```dart
// Android Platform Configuration (GYM MATCH Production)
static const FirebaseOptions android = FirebaseOptions(
  apiKey: 'YOUR_ANDROID_API_KEY',  // google-services.json から取得
  appId: 'YOUR_ANDROID_APP_ID',   // google-services.json から取得
  messagingSenderId: '506175392633',
  projectId: 'gym-match-e560d',
  storageBucket: 'gym-match-e560d.firebasestorage.app',
);
```

そして、`currentPlatform`のswitch文を修正：

```dart
switch (defaultTargetPlatform) {
  case TargetPlatform.iOS:
    return ios;
  case TargetPlatform.macOS:
    return macos;
  case TargetPlatform.android:
    return android;  // ← 追加
  case TargetPlatform.windows:
  case TargetPlatform.linux:
  default:
    throw UnsupportedError(
      'DefaultFirebaseOptions are configured for iOS, macOS, Android, and Web platforms.',
    );
}
```

---

## 🏗️ **Androidビルドの作成**

### **デバッグビルド（開発用）**

```bash
# デバッグAPKビルド
flutter build apk --debug

# 生成場所
# build/app/outputs/flutter-apk/app-debug.apk
```

### **リリースビルド（本番用）**

#### **1. App Bundle（AAB）作成（推奨）**

Google Playストアに提出する際の標準フォーマット。

```bash
# リリースAABビルド
flutter build appbundle --release

# 生成場所
# build/app/outputs/bundle/release/app-release.aab
```

**サイズ目安**: 約15〜30MB

#### **2. APKビルド作成（代替手段）**

直接インストール可能なフォーマット。

```bash
# リリースAPKビルド
flutter build apk --release

# 生成場所
# build/app/outputs/flutter-apk/app-release.apk
```

**サイズ目安**: 約30〜50MB

### **ビルド後の確認**

```bash
# ファイルサイズ確認
ls -lh build/app/outputs/bundle/release/app-release.aab
ls -lh build/app/outputs/flutter-apk/app-release.apk

# 署名確認
keytool -printcert -jarfile build/app/outputs/flutter-apk/app-release.apk

# インストールして動作確認
adb install build/app/outputs/flutter-apk/app-release.apk
```

---

## 📦 **Google Play Console準備**

### **必要な費用**

| 項目 | 金額 | 頻度 |
|------|------|------|
| **Google Play Console登録料** | **$25** (約3,500円) | **1回のみ** |
| **年間維持費** | **$0** | 無料 |

**合計**: **$25（約3,500円）** - 1回限り

### **アカウント登録手順**

1. **Google Play Console にアクセス**
   - URL: https://play.google.com/console
   - Googleアカウントでログイン

2. **$25 登録料の支払い**
   - クレジットカード/デビットカード必要

3. **開発者プロフィール設定**
   ```
   開発者名: 株式会社Enable
   メールアドレス: [CEOのメールアドレス]
   ```

---

## 📱 **ストア掲載情報**

### **必須項目**

1. **アプリ名**
   ```
   GYM MATCH - 科学的トレーニング管理
   ```

2. **簡単な説明**（80文字以内）
   ```
   筋トレ記録・AIコーチ・成長予測分析アプリ
   ```

3. **詳細な説明**（4,000文字以内）
   ```
   【GYM MATCHとは】
   科学的根拠に基づいたトレーニング管理アプリです。
   
   【主な機能】
   ✅ トレーニング記録管理
   ✅ AI科学的コーチング
   ✅ 成長予測分析
   ✅ 効果分析レポート
   ✅ テンプレート機能
   ✅ ワークアウト履歴追跡
   
   【対象ユーザー】
   - 科学的にトレーニングを管理したい方
   - データに基づいた成長を実感したい方
   
   【開発元】
   株式会社Enable
   ```

4. **スクリーンショット** - 最低2枚、推奨8枚
5. **アイコン** - 512x512px PNG
6. **フィーチャーグラフィック** - 1024x500px PNG/JPEG

---

## 🔄 **GitHub Actions - Android自動ビルド**

### **ワークフロー作成**

`.github/workflows/android-release.yml`を作成：

```yaml
name: Android Release Build

on:
  workflow_dispatch:
  push:
    tags:
      - 'v*-android'

jobs:
  build:
    runs-on: ubuntu-latest
    
    steps:
      - name: Checkout code
        uses: actions/checkout@v4
      
      - name: Setup Java
        uses: actions/setup-java@v4
        with:
          distribution: 'temurin'
          java-version: '17'
      
      - name: Setup Flutter
        uses: subosito/flutter-action@v2
        with:
          flutter-version: '3.35.4'
          channel: 'stable'
      
      - name: Install dependencies
        run: flutter pub get
      
      - name: Decode keystore
        run: |
          echo "\${{ secrets.ANDROID_KEYSTORE_BASE64 }}" | base64 -d > android/release-key.jks
      
      - name: Create key.properties
        run: |
          cat > android/key.properties <<EOF
          storePassword=\${{ secrets.ANDROID_KEYSTORE_PASSWORD }}
          keyPassword=\${{ secrets.ANDROID_KEY_PASSWORD }}
          keyAlias=release
          storeFile=release-key.jks
          EOF
      
      - name: Build APK
        run: flutter build apk --release
      
      - name: Build App Bundle
        run: flutter build appbundle --release
      
      - name: Upload APK
        uses: actions/upload-artifact@v4
        with:
          name: app-release.apk
          path: build/app/outputs/flutter-apk/app-release.apk
      
      - name: Upload AAB
        uses: actions/upload-artifact@v4
        with:
          name: app-release.aab
          path: build/app/outputs/bundle/release/app-release.aab
```

### **GitHub Secretsの設定**

リポジトリの Settings → Secrets → Actions で以下を登録：

```
ANDROID_KEYSTORE_BASE64: [release-key.jksをBase64エンコードした値]
ANDROID_KEYSTORE_PASSWORD: gymmatch2025secure
ANDROID_KEY_PASSWORD: gymmatch2025secure
```

**Base64エンコード方法**:
```bash
# Macの場合
base64 -i android/release-key.jks -o keystore.txt

# Linuxの場合
base64 android/release-key.jks > keystore.txt
```

---

## 📊 **現在の設定情報**

### **アプリケーション情報**

```
パッケージ名: jp.nexa.fitsync
アプリ名: GYM MATCH
バージョンコード: 207
バージョン名: 1.0.207
```

### **現在のバージョン（Flutter）**

```
version: 1.0.244+269  (pubspec.yaml)
```

**注意**: `build.gradle`のバージョンを更新する必要があります：

```gradle
defaultConfig {
    versionCode = 269
    versionName = "1.0.244"
}
```

---

## ✅ **作業チェックリスト**

### **Firebase設定**
- [ ] Firebaseコンソールで Android アプリ追加
- [ ] `google-services.json`をダウンロードして配置
- [ ] `firebase_options.dart`にAndroid設定を追加

### **署名設定**
- [ ] `release-key.jks`を作成（keytool使用）
- [ ] `key.properties`を確認（パスワード設定）
- [ ] 署名鍵を安全にバックアップ

### **ビルド**
- [ ] デバッグビルドで動作確認
- [ ] リリースビルドで動作確認
- [ ] APK/AABファイルのサイズ確認

### **Google Play準備**
- [ ] Google Play Console アカウント登録（$25）
- [ ] ストア掲載情報準備（説明文、スクリーンショット）
- [ ] プライバシーポリシーURL準備

### **GitHub Actions**
- [ ] android-release.yml ワークフローファイル作成
- [ ] GitHub Secrets 設定（ANDROID_KEYSTORE_BASE64等）
- [ ] ワークフロー動作確認

---

## 🚀 **次のステップ**

1. **Firebase設定** - `google-services.json`の取得と配置
2. **署名鍵作成** - `keytool`でリリース鍵を作成
3. **ローカルビルドテスト** - デバッグビルドで動作確認
4. **GitHub Actions設定** - 自動ビルドワークフローの作成
5. **Google Play準備** - アカウント登録とストア情報準備

---

## 📞 **トラブルシューティング**

### **問題: ビルドエラー**

```bash
flutter clean
flutter pub get
flutter build apk --release
```

### **問題: 署名エラー**

```bash
# key.properties を確認
cat android/key.properties

# 署名鍵の存在確認
ls -l android/release-key.jks
```

### **問題: Firebase接続エラー**

- `google-services.json`が正しく配置されているか確認
- `firebase_options.dart`のAndroid設定を確認

---

**🚀 Android版準備完了に向けて！**
