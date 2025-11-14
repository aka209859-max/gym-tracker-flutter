#!/bin/bash

API_KEY="AIzaSyDkNfRxLJIPYx1UFEIZqXvao7rgl2OVc6s"
MODEL="gemini-2.5-flash"

echo "🔍 Gemini APIキーテスト開始..."
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"

# テスト1: モデル情報取得
echo ""
echo "📋 テスト1: モデル情報取得"
echo "URL: https://generativelanguage.googleapis.com/v1beta/models/${MODEL}?key=${API_KEY}"
RESPONSE=$(curl -s -w "\n%{http_code}" "https://generativelanguage.googleapis.com/v1beta/models/${MODEL}?key=${API_KEY}")
HTTP_CODE=$(echo "$RESPONSE" | tail -n1)
BODY=$(echo "$RESPONSE" | sed '$d')

echo "HTTP Status: $HTTP_CODE"
echo "Response: $BODY" | head -c 500
echo ""

# テスト2: 簡単なテキスト生成
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
echo "📝 テスト2: テキスト生成テスト"
curl -s -X POST \
  "https://generativelanguage.googleapis.com/v1beta/models/${MODEL}:generateContent?key=${API_KEY}" \
  -H "Content-Type: application/json" \
  -d '{
    "contents": [{
      "parts": [{"text": "Say hello in Japanese"}]
    }]
  }' | head -c 800

echo ""
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"

# テスト3: 利用可能なモデル一覧取得
echo ""
echo "📚 テスト3: 利用可能なモデル一覧"
curl -s "https://generativelanguage.googleapis.com/v1beta/models?key=${API_KEY}" | grep -o '"name":"[^"]*"' | head -10

echo ""
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
echo "✅ テスト完了"
