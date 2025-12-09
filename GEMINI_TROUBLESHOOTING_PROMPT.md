# Gemini に質問するプロンプト

## 📋 コピー&ペーストしてください

```
Google Cloud Platform で iOS アプリ用の API キーを作成しましたが、403 Forbidden エラーが発生して困っています。以下の状況で解決方法を教えてください。

【環境】
- プロジェクト: GYM MATCH (gym-match-e560d)
- iOS アプリの Bundle ID: com.nexa.gymmatch
- TestFlight でテスト中

【実施済みの設定】
1. ✅ Generative Language API を有効化済み
2. ✅ Places API を有効化済み
3. ✅ 請求先アカウントをリンク済み
4. ✅ 新しい API キーを作成（2個）:
   - Gemini API Key: アプリケーション制限「なし」、API制限「Generative Language API」のみ
   - Places API Key: アプリケーション制限「なし」、API制限「Places API」のみ

【エラー内容】
1. Places API のエラー:
   "Exception: Google Places API error: REQUEST_DENIED - This IP, site or mobile application is not authorized to use this API key. Request received from IP address 126.23.218.222"

2. Gemini API のエラー:
   "API Error: 403"

【試したこと】
- Bundle ID を com.nexa.gymmatch に設定（後に「なし」に変更）
- API キーを新規作成（制限なし版）
- 10分以上待機
- TestFlight アプリを再起動
- 請求先アカウントのリンク

【質問】
1. なぜ「アプリケーション制限: なし」でも 403 エラーが出るのでしょうか？
2. 「Google Auth Platform はまだ構成されていません」という警告が関係していますか？
3. OAuth 同意画面の設定が必要ですか？
4. API キーではなく、サービスアカウントを使用すべきですか？
5. iOS アプリから API を呼び出す場合、特別な設定が必要ですか？
6. 他に確認すべき設定項目はありますか？

具体的な解決手順を教えてください。
```

---

## 📝 追加情報（必要に応じて）

### エラーメッセージの詳細

```
【Places API エラー（マップ画面）】
検索に失敗しました: Exception: Failed to search nearby gyms: Exception: Google Places API error: REQUEST_DENIED - This IP, site or mobile application is not authorized to use this API key. Request received from IP address 126.23.218.222, with empty referer

【Gemini API エラー（AIコーチ画面）】
メニュー生成に失敗しました: Exception: API Error: 403
```

### API キーの詳細

```
- 作成日時: 2025年12月9日
- 名前: GYM MATCH - Gemini API (No Restrictions)
- 名前: GYM MATCH - Places API (No Restrictions)
- アプリケーション制限: なし
- API 制限: 各APIに制限済み
- HTTPリファラー: 未設定
- IPアドレス: 未設定
```

---

## 🎯 Gemini への質問ポイント

1. **OAuth同意画面が必要か？**
2. **API キーの「なし」設定で本当に動作するか？**
3. **iOS アプリ特有の設定が必要か？**
4. **REQUEST_DENIED エラーの具体的な原因**
5. **代替手段（サービスアカウントなど）**

---

コピーして Gemini に質問してください！
