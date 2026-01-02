/// 🔬 トレーニング効果分析サービス
/// 
/// ユーザーのトレーニング履歴を分析し、
/// 最適なボリューム・頻度・回復時間を提案するサービス
library;

import 'dart:convert';
import 'package:http/http.dart' as http;
import 'scientific_database.dart';
import 'ai_response_optimizer.dart';

/// トレーニング効果分析サービスクラス
class TrainingAnalysisService {
  // Gemini API設定（AIコーチ専用キー）
  static const String _apiKey = 'AIzaSyAFVfcWzXDTtc9Rk3Zr5OGRx63FXpMAHqY';
  static const String _apiUrl =
      'https://generativelanguage.googleapis.com/v1beta/models/gemini-1.5-flash:generateContent';

  /// トレーニング履歴から効果を分析
  /// 
  /// [bodyPart] 対象部位
  /// [level] トレーニングレベル
  /// [currentSetsPerWeek] 現在の週あたりセット数
  /// [currentFrequency] 現在の週あたり頻度
  /// [recentHistory] 直近4週間のトレーニング履歴
  /// [gender] 性別
  /// [age] 年齢
  static Future<Map<String, dynamic>> analyzeTrainingEffect({
    required String bodyPart,
    required String level,
    required int currentSetsPerWeek,
    required int currentFrequency,
    required List<Map<String, dynamic>> recentHistory,
    required String gender,
    required int age,
    String locale = 'ja', // 🔄 Build #24.1 Hotfix10: Keep for future translation support
  }) async {
    try {
      // 推奨値の取得
      final recommendedVolume = ScientificDatabase.getRecommendedVolume(level);
      final recommendedFreq = ScientificDatabase.getRecommendedFrequency(level);
      final recommendedRest = ScientificDatabase.getRecommendedRestDays(level, bodyPart);

      // ボリューム評価
      final volumeAnalysis = _analyzeVolume(
        currentSetsPerWeek,
        recommendedVolume,
      );

      // 頻度評価
      final frequencyAnalysis = _analyzeFrequency(
        currentFrequency,
        recommendedFreq['frequency'],
      );

      // プラトー検出
      final plateauDetected = ScientificDatabase.detectPlateauFromHistory(recentHistory);
      final plateauSolutions = plateauDetected
          ? ScientificDatabase.getPlateauSolutions(level)
          : <String>[];

      // 成長トレンド分析
      final growthTrend = _analyzeGrowthTrend(recentHistory);

      // AIによる詳細な分析
      final aiAnalysis = await _getAIAnalysis(
        bodyPart: bodyPart,
        level: level,
        currentSetsPerWeek: currentSetsPerWeek,
        currentFrequency: currentFrequency,
        volumeAnalysis: volumeAnalysis,
        frequencyAnalysis: frequencyAnalysis,
        plateauDetected: plateauDetected,
        growthTrend: growthTrend,
        recommendedVolume: recommendedVolume,
        recommendedFreq: recommendedFreq,
        gender: gender,
        age: age,
        locale: locale, // 🆕 Build #24.1 Hotfix9: Pass locale

      );

      return {
        'success': true,
        'bodyPart': bodyPart,
        'level': level,
        'currentStatus': {
          'setsPerWeek': currentSetsPerWeek,
          'frequency': currentFrequency,
          'restDays': recommendedRest,
        },
        'volumeAnalysis': volumeAnalysis,
        'frequencyAnalysis': frequencyAnalysis,
        'plateauDetected': plateauDetected,
        'plateauSolutions': plateauSolutions,
        'growthTrend': growthTrend,
        'recommendations': _generateRecommendations(
          volumeAnalysis: volumeAnalysis,
          frequencyAnalysis: frequencyAnalysis,
          plateauDetected: plateauDetected,
          level: level,
          bodyPart: bodyPart,
        ),
        'aiAnalysis': aiAnalysis,
        'scientificBasis': _getScientificBasis(level),
      };
    } catch (e, stackTrace) {
      print('❌❌❌ analyzeTrainingEffect全体エラー: $e');
      print('スタックトレース: $stackTrace');
      return {
        'success': false,
        'error': 'トレーニング効果分析に失敗しました: $e',
      };
    }
  }

  /// ボリューム分析
  static Map<String, dynamic> _analyzeVolume(
    int currentSets,
    Map<String, int> recommended,
  ) {
    final optimalSets = recommended['optimal']!;
    final minSets = recommended['min']!;
    final maxSets = recommended['max']!;

    String status;
    String advice;
    int suggestedChange = 0;

    if (currentSets < minSets) {
      status = 'insufficient'; // 不足
      suggestedChange = minSets - currentSets;
      advice = '週${suggestedChange}セット追加で、+${(suggestedChange * 0.37).toStringAsFixed(1)}%の成長期待（Schoenfeld 2017）';
    } else if (currentSets < optimalSets) {
      status = 'suboptimal'; // 最適以下
      suggestedChange = optimalSets - currentSets;
      advice = '週${suggestedChange}セット追加で最適ボリューム到達';
    } else if (currentSets <= maxSets) {
      status = 'optimal'; // 最適
      suggestedChange = 0;
      advice = '現在のボリュームは最適範囲内です';
    } else {
      status = 'excessive'; // 過剰
      suggestedChange = maxSets - currentSets;
      advice = '疲労リスク：週${-suggestedChange}セット削減推奨';
    }

    return {
      'status': status,
      'currentSets': currentSets,
      'optimalSets': optimalSets,
      'minSets': minSets,
      'maxSets': maxSets,
      'suggestedChange': suggestedChange,
      'advice': advice,
    };
  }

  /// 頻度分析
  static Map<String, dynamic> _analyzeFrequency(
    int currentFrequency,
    int recommendedFrequency,
  ) {
    String status;
    String advice;

    if (currentFrequency < recommendedFrequency) {
      status = 'low';
      advice = '週+${recommendedFrequency - currentFrequency}回でボリューム増加可能（Grgic 2018）';
    } else if (currentFrequency == recommendedFrequency) {
      status = 'optimal';
      advice = '現在の頻度は最適です';
    } else {
      status = 'high';
      advice = '高頻度：回復時間に注意。ボリューム統制すれば問題なし';
    }

    return {
      'status': status,
      'currentFrequency': currentFrequency,
      'recommendedFrequency': recommendedFrequency,
      'advice': advice,
    };
  }

  /// 成長トレンド分析
  static Map<String, dynamic> _analyzeGrowthTrend(
    List<Map<String, dynamic>> history,
  ) {
    if (history.length < 2) {
      return {
        'trend': 'insufficient_data',
        'message': 'データ不足：2週間以上の履歴が必要',
      };
    }

    // 最新と最古のデータを比較
    final latest = history.first;
    final oldest = history.last;
    final weightChange = latest['weight'] - oldest['weight'];
    final weeksPassed = history.length;
    final weeklyGrowth = (weightChange / oldest['weight'] * 100) / weeksPassed;

    String trend;
    String message;

    if (weeklyGrowth > 2.0) {
      trend = 'excellent'; // 優秀
      message = '週+${weeklyGrowth.toStringAsFixed(1)}%：素晴らしい成長ペース！';
    } else if (weeklyGrowth > 1.0) {
      trend = 'good'; // 良好
      message = '週+${weeklyGrowth.toStringAsFixed(1)}%：順調に成長中';
    } else if (weeklyGrowth > 0) {
      trend = 'slow'; // 遅い
      message = '週+${weeklyGrowth.toStringAsFixed(1)}%：成長ペースが遅め';
    } else {
      trend = 'plateau'; // 停滞
      message = '成長停滞：プログラム変更を推奨';
    }

    return {
      'trend': trend,
      'weeklyGrowth': weeklyGrowth,
      'totalGrowth': weightChange,
      'weeksPassed': weeksPassed,
      'message': message,
    };
  }

  /// 推奨アクションの生成
  static List<Map<String, String>> _generateRecommendations({
    required Map<String, dynamic> volumeAnalysis,
    required Map<String, dynamic> frequencyAnalysis,
    required bool plateauDetected,
    required String level,
    required String bodyPart,
  }) {
    final recommendations = <Map<String, String>>[];

    // ボリューム推奨
    if (volumeAnalysis['status'] != 'optimal') {
      recommendations.add({
        'priority': 'high',
        'category': 'ボリューム',
        'action': volumeAnalysis['advice'],
        'basis': 'Schoenfeld et al. 2017',
      });
    }

    // 頻度推奨
    if (frequencyAnalysis['status'] != 'optimal') {
      recommendations.add({
        'priority': 'medium',
        'category': '頻度',
        'action': frequencyAnalysis['advice'],
        'basis': 'Grgic et al. 2018',
      });
    }

    // プラトー対策
    if (plateauDetected) {
      final solutions = ScientificDatabase.getPlateauSolutions(level);
      for (final solution in solutions) {
        recommendations.add({
          'priority': 'high',
          'category': 'プラトー対策',
          'action': solution,
          'basis': 'Kraemer & Ratamess 2004',
        });
      }
    }

    // 回復時間
    final restDays = ScientificDatabase.getRecommendedRestDays(level, bodyPart);
    recommendations.add({
      'priority': 'medium',
      'category': '回復',
      'action': '同一部位は${restDays}日空ける（MPS上昇期間：48時間）',
      'basis': 'Davies et al. 2024',
    });

    return recommendations;
  }

  /// AIによる詳細分析
  static Future<String> _getAIAnalysis({
    required String bodyPart,
    required String level,
    required int currentSetsPerWeek,
    required int currentFrequency,
    required Map<String, dynamic> volumeAnalysis,
    required Map<String, dynamic> frequencyAnalysis,
    required bool plateauDetected,
    required Map<String, dynamic> growthTrend,
    required Map<String, int> recommendedVolume,
    required Map<String, dynamic> recommendedFreq,
    required String gender,
    required int age,
    String locale = 'ja', // 🆕 Build #24.1 Hotfix9: Add locale support
  }) async {
    // キャッシュキーを生成
    final cacheKey = AIResponseOptimizer.generateCacheKey({
      'type': 'training_analysis',
      'bodyPart': bodyPart,
      'level': level,
      'currentSets': currentSetsPerWeek,
      'currentFreq': currentFrequency,
      'volumeStatus': volumeAnalysis['status'],
      'freqStatus': frequencyAnalysis['status'],
      'plateau': plateauDetected,
      'trend': growthTrend['trend'],
      'gender': gender,
      'age': age,
    });
    
    // キャッシュをチェック
    final cachedResponse = await AIResponseOptimizer.getCachedResponse(cacheKey);
    if (cachedResponse != null) {
      print('✅ トレーニング分析: キャッシュヒット（即座に応答）');
      return cachedResponse;
    }
    
    print('⏳ トレーニング分析: API呼び出し中...');
    
    // 🆕 Build #24.1 Hotfix9.4: Multilingual prompt construction for all languages
    final prompt = _buildMultilingualAnalysisPrompt(
        locale: locale,
        bodyPart: bodyPart,
        level: level,
        gender: gender,
        age: age,
        currentSetsPerWeek: currentSetsPerWeek,
        currentFrequency: currentFrequency,
        volumeAnalysis: volumeAnalysis,
        frequencyAnalysis: frequencyAnalysis,
        growthTrend: growthTrend,
        plateauDetected: plateauDetected,
        recommendedVolume: recommendedVolume,
        recommendedFreq: recommendedFreq);

    try {
      final response = await http.post(
        Uri.parse('$_apiUrl?key=$_apiKey'),
        headers: {
          'Content-Type': 'application/json',
          // Note: Gemini API does NOT support X-Ios-Bundle-Identifier header
        },
        body: jsonEncode({
          'contents': [
            {
              'parts': [
                {'text': prompt}
              ]
            }
          ],
          'generationConfig': {
            'temperature': 0.3,
            'maxOutputTokens': 1024,
            'topP': 0.8,
            'topK': 40,
          },
        }),
      ).timeout(const Duration(seconds: 10)); // 🆕 Build #24.1 Hotfix9.6: 10秒タイムアウト（安定性向上）

      if (response.statusCode == 200) {
        final data = jsonDecode(utf8.decode(response.bodyBytes));
        final text = data['candidates']?[0]?['content']?['parts']?[0]?['text'];
        if (text != null && text.toString().isNotEmpty) {
          final responseText = text.toString();
          // レスポンスをキャッシュに保存
          await AIResponseOptimizer.cacheResponse(cacheKey, responseText);
          print('✅ トレーニング分析: 成功（キャッシュ保存完了）');
          return responseText;
        } else {
          return _getFallbackAnalysis(bodyPart, level, volumeAnalysis, frequencyAnalysis, plateauDetected);
        }
      } else {
        print('❌ Gemini API エラー: ${response.statusCode} - ${response.body}');
        return _getFallbackAnalysis(bodyPart, level, volumeAnalysis, frequencyAnalysis, plateauDetected);
      }
    } catch (e) {
      print('❌ AI分析エラー: $e');
      return _getFallbackAnalysis(bodyPart, level, volumeAnalysis, frequencyAnalysis, plateauDetected);
    }
  }

  /// フォールバック分析（AI失敗時）
  static String _getFallbackAnalysis(
    String bodyPart,
    String level,
    Map<String, dynamic> volumeAnalysis,
    Map<String, dynamic> frequencyAnalysis,
    bool plateauDetected,
  ) {
    final buffer = StringBuffer();
    
    buffer.writeln('## トレーニング効果の評価');
    if (volumeAnalysis['status'] == 'optimal' && frequencyAnalysis['status'] == 'optimal') {
      buffer.writeln('現在のプログラムは科学的に最適な範囲内です。このまま継続することで効果的な成長が期待できます。');
    } else {
      buffer.writeln('改善の余地があります。以下の推奨事項に従うことで、より効果的なトレーニングが可能です。');
    }
    
    buffer.writeln('\n## 最優先改善ポイント');
    if (volumeAnalysis['status'] == 'insufficient') {
      buffer.writeln('週${volumeAnalysis['suggestedChange']}セット追加で、筋肥大効果が向上します（Schoenfeld 2017）。');
    } else if (volumeAnalysis['status'] == 'excessive') {
      buffer.writeln('現在のボリュームは過剰です。週${-volumeAnalysis['suggestedChange']}セット削減で回復時間を確保しましょう。');
    } else if (plateauDetected) {
      buffer.writeln('プラトー期を検出しました。プログラム変更（種目変更、強度変更）を推奨します。');
    } else {
      buffer.writeln('${volumeAnalysis['advice']}');
    }
    
    buffer.writeln('\n## 具体的アクションプラン');
    buffer.writeln('* 今週から: ${volumeAnalysis['advice']}');
    buffer.writeln('* トレーニング頻度: ${frequencyAnalysis['advice']}');
    buffer.writeln('* 回復時間: $bodyPartは${ScientificDatabase.getRecommendedRestDays(level, bodyPart)}日空ける');
    
    return buffer.toString();
  }

  /// 科学的根拠の取得
  static List<Map<String, String>> _getScientificBasis(String level) {
    return [
      {
        'citation': 'Schoenfeld et al. 2017',
        'finding': 'セット追加ごとに+0.37%の成長',
        'effectSize': 'N/A',
      },
      {
        'citation': 'Grgic et al. 2018',
        'finding': 'ボリュームが王様、頻度は手段',
        'effectSize': 'ES=0.88-1.08',
      },
      {
        'citation': 'Davies et al. 2024',
        'finding': 'MPS上昇期間：48時間',
        'effectSize': 'N/A',
      },
      {
        'citation': 'Baz-Valle et al. 2022',
        'finding': 'レベル別最適ボリューム',
        'effectSize': 'N/A',
      },
    ];
  }

  /// 週次ボリュームトレンドの生成（グラフ用）
  static List<Map<String, dynamic>> generateVolumeTrend(
    List<Map<String, dynamic>> history,
  ) {
    return history.map((record) {
      return {
        'week': record['week'] ?? 0,
        'sets': record['sets'] ?? 0,
        'weight': record['weight'] ?? 0,
      };
    }).toList();
  }
  
  /// 🆕 Build #24.1 Hotfix9.4: Multilingual analysis prompt construction
  static String _buildMultilingualAnalysisPrompt({
    required String locale,
    required String bodyPart,
    required String level,
    required String gender,
    required int age,
    required int currentSetsPerWeek,
    required int currentFrequency,
    required Map<String, dynamic> volumeAnalysis,
    required Map<String, dynamic> frequencyAnalysis,
    required Map<String, dynamic> growthTrend,
    required bool plateauDetected,
    required Map<String, int> recommendedVolume,
    required Map<String, dynamic> recommendedFreq,
  }) {
    final systemPrompt = ScientificDatabase.getSystemPrompt(locale: locale); // 🆕 Build #24.1 Hotfix9.7: Pass locale for multilingual system prompt
    
    switch (locale) {
      case 'ko':
        return '''
$systemPrompt

[분석 대상]
・부위：$bodyPart
・레벨：$level
・성별：$gender
・나이：${age}세

[현재 상황]
・$bodyPart 트레이닝：주 ${currentSetsPerWeek}세트 실행 중
・$bodyPart 트레이닝 빈도：주 ${currentFrequency}회
・볼륨 평가：${volumeAnalysis['status']}
・빈도 평가：${frequencyAnalysis['status']}
・성장 트렌드：${growthTrend['trend']}
・플래토 감지：${plateauDetected ? '있음' : '없음'}

[추천 프로그램]
・$bodyPart 볼륨：주 ${recommendedVolume['optimal']}세트 (${recommendedVolume['min']}-${recommendedVolume['max']}세트)
・$bodyPart 트레이닝 빈도：주 ${recommendedFreq['frequency']}회
・효과 크기：ES=${recommendedFreq['effectSize']}

[중요]
"주 ${recommendedFreq['frequency']}회" = 같은 부위($bodyPart)를 주에 ${recommendedFreq['frequency']}회 트레이닝하는 것
예: 월요일·수요일·금요일에 $bodyPart 트레이닝 실시 (주 3회)

다음 형식으로 간결하게 답변해주세요 (300자 이내):

## 트레이닝 효과 평가
(현재 프로그램의 과학적 평가)

## 최우선 개선 포인트
(가장 효과적인 개선책 1가지)

## 구체적 액션 플랜
(이번 주부터 실행할 수 있는 3가지 액션)
''';

      case 'es':
        return '''
$systemPrompt

[OBJETIVO DE ANÁLISIS]
・Parte del cuerpo：$bodyPart
・Nivel：$level
・Género：$gender
・Edad：$age años

[SITUACIÓN ACTUAL]
・Entrenamiento de $bodyPart：${currentSetsPerWeek} series/semana actualmente
・Frecuencia de entrenamiento de $bodyPart：${currentFrequency} veces/semana
・Evaluación de volumen：${volumeAnalysis['status']}
・Evaluación de frecuencia：${frequencyAnalysis['status']}
・Tendencia de crecimiento：${growthTrend['trend']}
・Detección de meseta：${plateauDetected ? 'Detectada' : 'No detectada'}

[PROGRAMA RECOMENDADO]
・Volumen de $bodyPart：${recommendedVolume['optimal']} series/semana (${recommendedVolume['min']}-${recommendedVolume['max']} series)
・Frecuencia de entrenamiento de $bodyPart：${recommendedFreq['frequency']} veces/semana
・Tamaño del efecto：ES=${recommendedFreq['effectSize']}

[IMPORTANTE]
"${recommendedFreq['frequency']} veces/semana" = Entrenar la misma parte del cuerpo ($bodyPart) ${recommendedFreq['frequency']} veces por semana
Ejemplo: Entrenar $bodyPart los lunes, miércoles y viernes (3 veces/semana)

Por favor responda concisamente en el siguiente formato (dentro de 300 palabras):

## Evaluación del Efecto del Entrenamiento
(Evaluación científica del programa actual)

## Punto de Mejora Prioritario
(La estrategia de mejora más efectiva - un elemento)

## Plan de Acción Específico
(Tres acciones para implementar a partir de esta semana)
''';

      case 'zh':
      case 'zh_TW':
        return '''
$systemPrompt

[分析对象]
・部位：$bodyPart
・水平：$level
・性别：$gender
・年龄：${age}岁

[当前情况]
・$bodyPart 训练：目前每周${currentSetsPerWeek}组
・$bodyPart 训练频率：每周${currentFrequency}次
・训练量评估：${volumeAnalysis['status']}
・频率评估：${frequencyAnalysis['status']}
・增长趋势：${growthTrend['trend']}
・平台期检测：${plateauDetected ? '检测到' : '未检测到'}

[推荐计划]
・$bodyPart 训练量：每周${recommendedVolume['optimal']}组（${recommendedVolume['min']}-${recommendedVolume['max']}组）
・$bodyPart 训练频率：每周${recommendedFreq['frequency']}次
・效应量：ES=${recommendedFreq['effectSize']}

[重要]
"每周${recommendedFreq['frequency']}次" = 每周训练同一部位（$bodyPart）${recommendedFreq['frequency']}次
例：周一·周三·周五进行$bodyPart训练（每周3次）

请按以下格式简要回答（300字以内）：

## 训练效果评估
（当前计划的科学评价）

## 最优先改进要点
（最有效的改进策略 - 一项）

## 具体行动计划
（从本周开始可以执行的3个行动）
''';

      case 'de':
        return '''
$systemPrompt

[ANALYSEZIEL]
・Körperteil：$bodyPart
・Niveau：$level
・Geschlecht：$gender
・Alter：$age Jahre

[AKTUELLE SITUATION]
・$bodyPart Training：Derzeit ${currentSetsPerWeek} Sätze/Woche
・$bodyPart Trainingshäufigkeit：${currentFrequency} Mal/Woche
・Volumenbewertung：${volumeAnalysis['status']}
・Häufigkeitsbewertung：${frequencyAnalysis['status']}
・Wachstumstrend：${growthTrend['trend']}
・Plateau-Erkennung：${plateauDetected ? 'Erkannt' : 'Nicht erkannt'}

[EMPFOHLENES PROGRAMM]
・$bodyPart Volumen：${recommendedVolume['optimal']} Sätze/Woche (${recommendedVolume['min']}-${recommendedVolume['max']} Sätze)
・$bodyPart Trainingshäufigkeit：${recommendedFreq['frequency']} Mal/Woche
・Effektgröße：ES=${recommendedFreq['effectSize']}

[WICHTIG]
"${recommendedFreq['frequency']} Mal/Woche" = Training des gleichen Körperteils ($bodyPart) ${recommendedFreq['frequency']} Mal pro Woche
Beispiel: Training von $bodyPart montags, mittwochs und freitags (3 Mal/Woche)

Bitte antworten Sie prägnant im folgenden Format (innerhalb von 300 Wörtern):

## Bewertung des Trainingseffekts
(Wissenschaftliche Bewertung des aktuellen Programms)

## Prioritäre Verbesserung
(Die effektivste Verbesserungsstrategie - ein Punkt)

## Spezifischer Aktionsplan
(Drei Aktionen, die ab dieser Woche umgesetzt werden können)
''';

      case 'en':
        return '''
$systemPrompt

[ANALYSIS TARGET]
・Body Part: $bodyPart
・Level: $level
・Gender: $gender
・Age: $age years old

[CURRENT SITUATION]
・$bodyPart training: ${currentSetsPerWeek} sets/week currently implemented
・$bodyPart training frequency: ${currentFrequency} times/week
・Volume assessment: ${volumeAnalysis['status']}
・Frequency assessment: ${frequencyAnalysis['status']}
・Growth trend: ${growthTrend['trend']}
・Plateau detection: ${plateauDetected ? 'Detected' : 'Not detected'}

[RECOMMENDED PROGRAM]
・$bodyPart volume: ${recommendedVolume['optimal']} sets/week (${recommendedVolume['min']}-${recommendedVolume['max']} sets)
・$bodyPart training frequency: ${recommendedFreq['frequency']} times/week
・Effect size: ES=${recommendedFreq['effectSize']}

[IMPORTANT]
"${recommendedFreq['frequency']} times/week" = Train the same body part ($bodyPart) ${recommendedFreq['frequency']} times per week
Example: Train $bodyPart on Monday, Wednesday, Friday (3 times/week)

Please respond concisely in the following format (within 300 words):

## Training Effect Assessment
(Scientific evaluation of current program)

## Top Priority Improvement
(Most effective improvement strategy - one item)

## Specific Action Plan
(Three actions to implement starting this week)
''';

      case 'ja':
      default:
        return '''
$systemPrompt

【分析対象】
・部位：$bodyPart
・レベル：$level
・性別：$gender
・年齢：${age}歳

【現在の状況】
・$bodyPart のトレーニング：週${currentSetsPerWeek}セット実施中
・$bodyPart のトレーニング頻度：週${currentFrequency}回
・ボリューム評価：${volumeAnalysis['status']}
・頻度評価：${frequencyAnalysis['status']}
・成長トレンド：${growthTrend['trend']}
・プラトー検出：${plateauDetected ? 'あり' : 'なし'}

【推奨プログラム】
・$bodyPart のボリューム：週${recommendedVolume['optimal']}セット（${recommendedVolume['min']}-${recommendedVolume['max']}セット）
・$bodyPart のトレーニング頻度：週${recommendedFreq['frequency']}回
・効果量：ES=${recommendedFreq['effectSize']}

【重要】
「週${recommendedFreq['frequency']}回」= 同一部位（$bodyPart）を週に${recommendedFreq['frequency']}回トレーニングすること
例：月曜・水曜・金曜に$bodyPart のトレーニングを実施（週3回）

以下の形式で簡潔に回答してください（300文字以内）：

## トレーニング効果の評価
（現在のプログラムの科学的評価）

## 最優先改善ポイント
（最も効果的な改善策を1つ）

## 具体的アクションプラン
（今週から実行できる3つのアクション）
''';
    }
  }
}
