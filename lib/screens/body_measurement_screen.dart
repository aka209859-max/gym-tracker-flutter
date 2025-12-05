import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:intl/intl.dart';

/// 体重・体脂肪率記録画面
class BodyMeasurementScreen extends StatefulWidget {
  const BodyMeasurementScreen({super.key});

  @override
  State<BodyMeasurementScreen> createState() => _BodyMeasurementScreenState();
}

// ✅ v1.0.158: グラフ表示オプション追加
enum ChartType { weight, bodyFat }
enum ChartPeriod { recent, all }

class _BodyMeasurementScreenState extends State<BodyMeasurementScreen> {
  final TextEditingController _weightController = TextEditingController();
  final TextEditingController _bodyFatController = TextEditingController();
  DateTime _selectedDate = DateTime.now();
  bool _isLoading = false;
  List<Map<String, dynamic>> _measurements = [];
  
  // ✅ v1.0.158: グラフ設定
  ChartType _selectedChartType = ChartType.weight;
  ChartPeriod _selectedPeriod = ChartPeriod.recent;

  @override
  void initState() {
    super.initState();
    _loadMeasurements();
  }

  @override
  void dispose() {
    _weightController.dispose();
    _bodyFatController.dispose();
    super.dispose();
  }

  /// 記録を読み込み
  Future<void> _loadMeasurements() async {
    if (!mounted) return;
    setState(() => _isLoading = true);

    try {
      final user = FirebaseAuth.instance.currentUser;
      if (user == null) return;

      final querySnapshot = await FirebaseFirestore.instance
          .collection('body_measurements')
          .where('user_id', isEqualTo: user.uid)
          .orderBy('date', descending: true)
          .limit(30) // 最新30件
          .get();

      if (!mounted) return;
      setState(() {
        _measurements = querySnapshot.docs.map((doc) {
          final data = doc.data();
          return {
            'id': doc.id,
            'date': (data['date'] as Timestamp).toDate(),
            'weight': data['weight'] as double?,
            'body_fat_percentage': data['body_fat_percentage'] as double?,
          };
        }).toList();
      });
    } catch (e) {
      print('❌ 記録読み込みエラー: $e');
    } finally {
      if (!mounted) return;
      setState(() => _isLoading = false);
    }
  }

  /// 記録を保存
  Future<void> _saveMeasurement() async {
    final weight = double.tryParse(_weightController.text);
    final bodyFat = double.tryParse(_bodyFatController.text);

    if (weight == null && bodyFat == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('体重または体脂肪率を入力してください')),
      );
      return;
    }

    if (!mounted) return;
    setState(() => _isLoading = true);

    try {
      final user = FirebaseAuth.instance.currentUser;
      if (user == null) throw Exception('ユーザーが未ログイン');

      // ✅ v1.0.158: 日付 + 現在時刻を保存
      final now = DateTime.now();
      final dateTimeWithTime = DateTime(
        _selectedDate.year,
        _selectedDate.month,
        _selectedDate.day,
        now.hour,
        now.minute,
        now.second,
      );
      
      await FirebaseFirestore.instance.collection('body_measurements').add({
        'user_id': user.uid,
        'date': Timestamp.fromDate(dateTimeWithTime),  // ✅ 時刻を含める
        'weight': weight,
        'body_fat_percentage': bodyFat,
        'created_at': FieldValue.serverTimestamp(),
      });

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('記録を保存しました'), backgroundColor: Colors.green),
        );
        _weightController.clear();
        _bodyFatController.clear();
        _loadMeasurements();
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('エラー: $e'), backgroundColor: Colors.red),
        );
      }
    } finally {
      if (!mounted) return;
      setState(() => _isLoading = false);
    }
  }

  /// 日付選択
  Future<void> _selectDate() async {
    final picked = await showDatePicker(
      context: context,
      initialDate: _selectedDate,
      firstDate: DateTime(2020),
      lastDate: DateTime.now(),
    );

    if (picked != null) {
      setState(() => _selectedDate = picked);
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return GestureDetector(
      onTap: () => FocusScope.of(context).unfocus(),
      behavior: HitTestBehavior.translucent,
      child: Scaffold(
        appBar: AppBar(
          title: const Text('体重・体脂肪率'),
          backgroundColor: theme.colorScheme.primary,
          foregroundColor: Colors.white,
        ),
        body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : SingleChildScrollView(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  // 入力カード
                  Card(
                    child: Padding(
                      padding: const EdgeInsets.all(16),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text(
                            '今日の記録',
                            style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                          ),
                          const SizedBox(height: 16),
                          
                          // 日付選択
                          InkWell(
                            onTap: _selectDate,
                            child: InputDecorator(
                              decoration: const InputDecoration(
                                labelText: '日付',
                                border: OutlineInputBorder(),
                                prefixIcon: Icon(Icons.calendar_today),
                              ),
                              child: Text(
                                DateFormat('yyyy年MM月dd日').format(_selectedDate),
                              ),
                            ),
                          ),
                          const SizedBox(height: 16),
                          
                          // 体重入力
                          TextField(
                            controller: _weightController,
                            decoration: const InputDecoration(
                              labelText: '体重 (kg)',
                              border: OutlineInputBorder(),
                              prefixIcon: Icon(Icons.monitor_weight),
                            ),
                            keyboardType: const TextInputType.numberWithOptions(decimal: true),
                            textInputAction: TextInputAction.next,
                            onEditingComplete: () => FocusScope.of(context).nextFocus(),
                          ),
                          const SizedBox(height: 16),
                          
                          // 体脂肪率入力
                          TextField(
                            controller: _bodyFatController,
                            decoration: const InputDecoration(
                              labelText: '体脂肪率 (%)',
                              border: OutlineInputBorder(),
                              prefixIcon: Icon(Icons.analytics),
                            ),
                            keyboardType: const TextInputType.numberWithOptions(decimal: true),
                            textInputAction: TextInputAction.done,
                            onEditingComplete: () => FocusScope.of(context).unfocus(),
                          ),
                          const SizedBox(height: 16),
                          
                          // 保存ボタン
                          ElevatedButton(
                            onPressed: () {
                              FocusScope.of(context).unfocus();
                              _saveMeasurement();
                            },
                            style: ElevatedButton.styleFrom(
                              backgroundColor: theme.colorScheme.primary,
                              foregroundColor: Colors.white,
                              padding: const EdgeInsets.symmetric(vertical: 16),
                            ),
                            child: const Text('記録を保存', style: TextStyle(fontSize: 16)),
                          ),
                        ],
                      ),
                    ),
                  ),
                  
                  const SizedBox(height: 24),
                  
                  // グラフ
                  if (_measurements.isNotEmpty) ...[
                    _buildWeightChart(theme),
                    const SizedBox(height: 24),
                  ],
                  
                  // 履歴リスト
                  _buildHistoryList(theme),
                ],
              ),
            ),
      ),
    );
  }

  /// ✅ v1.0.158: 画像①風の体重グラフ
  Widget _buildWeightChart(ThemeData theme) {
    if (_measurements.isEmpty) return const SizedBox.shrink();

    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // ヘッダー（タイトルのみ）
            Text(
              _selectedChartType == ChartType.weight ? '体重' : '体脂肪率',
              style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
            ),
            
            const SizedBox(height: 24),
            
            // グラフ本体
            SizedBox(
              height: 250,  // ✅ 数値ラベル表示のため高さを確保
              child: _buildLineChart(theme),
            ),
            
            const SizedBox(height: 16),
            
            // 期間切り替えスイッチ
            Row(
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                Text('最近', style: TextStyle(fontSize: 14, color: Colors.grey.shade700)),
                Switch(
                  value: _selectedPeriod == ChartPeriod.all,
                  onChanged: (value) {
                    setState(() {
                      _selectedPeriod = value ? ChartPeriod.all : ChartPeriod.recent;
                    });
                  },
                  activeColor: Colors.grey.shade400,
                ),
                Text('全て', style: TextStyle(fontSize: 14, color: Colors.grey.shade700)),
              ],
            ),
          ],
        ),
      ),
    );
  }

  /// ✅ 折れ線グラフ（画像①完全再現）
  Widget _buildLineChart(ThemeData theme) {
    // データを古い順にソート
    final sorted = List<Map<String, dynamic>>.from(_measurements)
      ..sort((a, b) => (a['date'] as DateTime).compareTo(b['date'] as DateTime));
    
    // 期間フィルタリング
    final filtered = _selectedPeriod == ChartPeriod.recent
        ? sorted.take(10).toList()  // 最新10件
        : sorted;
    
    // スポットデータを生成
    final spots = <FlSpot>[];
    final values = <double>[];
    
    for (int i = 0; i < filtered.length; i++) {
      final value = _selectedChartType == ChartType.weight
          ? filtered[i]['weight'] as double?
          : filtered[i]['body_fat_percentage'] as double?;
      
      if (value != null) {
        spots.add(FlSpot(i.toDouble(), value));
        values.add(value);
      }
    }
    
    if (values.isEmpty) {
      return Center(child: Text('データがありません'));
    }
    
    // Y軸の範囲と間隔を計算（0.1刻み対応）
    final minValue = values.reduce((a, b) => a < b ? a : b);
    final maxValue = values.reduce((a, b) => a > b ? a : b);
    final range = maxValue - minValue;
    
    double interval;
    if (range <= 1.0) {
      interval = 0.1;
    } else if (range <= 2.0) {
      interval = 0.2;
    } else if (range <= 5.0) {
      interval = 0.5;
    } else if (range <= 10.0) {
      interval = 1.0;
    } else if (range <= 20.0) {
      interval = 2.0;
    } else {
      interval = 5.0;
    }
    
    final minY = ((minValue / interval).floor() * interval) - interval;
    final maxY = ((maxValue / interval).ceil() * interval) + interval;
    
    return LineChart(
      LineChartData(
        minY: minY,
        maxY: maxY,
        lineBarsData: [
          LineChartBarData(
            spots: spots,
            isCurved: true,
            color: Colors.grey.shade500,
            barWidth: 2,
            dotData: FlDotData(
              show: true,
              getDotPainter: (spot, percent, barData, index) {
                final isLatest = index == spots.length - 1;
                return FlDotCirclePainter(
                  radius: isLatest ? 7 : 5,
                  color: isLatest ? Colors.red : Colors.grey.shade700,
                  strokeWidth: 0,
                );
              },
            ),
            // ✅ データポイント上に数値を表示
            showingIndicators: List.generate(spots.length, (index) => index),
            belowBarData: BarAreaData(show: false),
          ),
        ],
        titlesData: FlTitlesData(
          rightTitles: AxisTitles(sideTitles: SideTitles(showTitles: false)),
          topTitles: AxisTitles(sideTitles: SideTitles(showTitles: false)),
          bottomTitles: AxisTitles(
            sideTitles: SideTitles(
              showTitles: true,
              reservedSize: 45,
              getTitlesWidget: (value, meta) {
                final index = value.toInt();
                if (index < 0 || index >= filtered.length) return Text('');
                
                final date = filtered[index]['date'] as DateTime;
                final dateStr = DateFormat('MM.dd').format(date);
                final timeStr = DateFormat('HH:mm').format(date);
                
                return Padding(
                  padding: EdgeInsets.only(top: 8),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text(dateStr, style: TextStyle(fontSize: 10, fontWeight: FontWeight.bold)),
                      Text(timeStr, style: TextStyle(fontSize: 9, color: Colors.grey.shade600)),
                    ],
                  ),
                );
              },
            ),
          ),
          leftTitles: AxisTitles(
            sideTitles: SideTitles(
              showTitles: false,  // ✅ 画像①では左側の目盛りが非表示
            ),
          ),
        ),
        gridData: FlGridData(show: false),  // ✅ グリッド線を非表示
        borderData: FlBorderData(show: false),  // ✅ 枠線を非表示
        // ✅ 各ポイント上に数値を常時表示
        extraLinesData: ExtraLinesData(
          horizontalLines: spots.asMap().entries.map((entry) {
            final index = entry.key;
            final spot = entry.value;
            final isLatest = index == spots.length - 1;
            
            return HorizontalLine(
              y: spot.y,
              color: Colors.transparent,
              strokeWidth: 0,
              label: HorizontalLineLabel(
                show: true,
                alignment: Alignment.topCenter,
                padding: EdgeInsets.only(bottom: 25),
                style: TextStyle(
                  color: isLatest ? Colors.red : Colors.grey.shade800,
                  fontSize: isLatest ? 14 : 11,
                  fontWeight: isLatest ? FontWeight.bold : FontWeight.normal,
                ),
                labelResolver: (line) => spot.y.toStringAsFixed(1),
              ),
            );
          }).toList(),
        ),
        lineTouchData: LineTouchData(
          touchTooltipData: LineTouchTooltipData(
            backgroundColor: Colors.black87,
            tooltipRoundedRadius: 8,
            getTooltipItems: (touchedSpots) {
              return touchedSpots.map((spot) {
                final index = spot.x.toInt();
                final date = filtered[index]['date'] as DateTime;
                final value = spot.y;
                
                final unit = _selectedChartType == ChartType.weight ? 'kg' : '%';
                
                return LineTooltipItem(
                  '${DateFormat('M/d').format(date)}\n${value.toStringAsFixed(1)}$unit',
                  TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 12),
                );
              }).toList();
            },
          ),
          handleBuiltInTouches: true,
          getTouchedSpotIndicator: (barData, spotIndexes) {
            return spotIndexes.map((index) {
              return TouchedSpotIndicatorData(
                FlLine(color: Colors.grey, strokeWidth: 1, dashArray: [3, 3]),
                FlDotData(
                  getDotPainter: (spot, percent, barData, index) {
                    return FlDotCirclePainter(
                      radius: 6,
                      color: Colors.red,
                      strokeWidth: 2,
                      strokeColor: Colors.white,
                    );
                  },
                ),
              );
            }).toList();
          },
        ),
      ),
    );
  }

  /// 履歴リスト
  Widget _buildHistoryList(ThemeData theme) {
    if (_measurements.isEmpty) {
      return Card(
        child: Padding(
          padding: const EdgeInsets.all(40),
          child: Column(
            children: [
              Icon(Icons.analytics_outlined, size: 48, color: Colors.grey[400]),
              const SizedBox(height: 16),
              Text(
                '記録がありません',
                style: TextStyle(fontSize: 16, color: Colors.grey[600]),
              ),
            ],
          ),
        ),
      );
    }

    return Card(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Padding(
            padding: EdgeInsets.all(16),
            child: Text(
              '記録履歴',
              style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
            ),
          ),
          ListView.separated(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            itemCount: _measurements.length,
            separatorBuilder: (context, index) => const Divider(height: 1),
            itemBuilder: (context, index) {
              final measurement = _measurements[index];
              final date = measurement['date'] as DateTime;
              final weight = measurement['weight'] as double?;
              final bodyFat = measurement['body_fat_percentage'] as double?;

              return ListTile(
                leading: CircleAvatar(
                  backgroundColor: theme.colorScheme.primaryContainer,
                  child: Icon(
                    Icons.calendar_today,
                    color: theme.colorScheme.onPrimaryContainer,
                    size: 20,
                  ),
                ),
                title: Text(DateFormat('yyyy年MM月dd日').format(date)),
                subtitle: Row(
                  children: [
                    if (weight != null) Text('体重: ${weight.toStringAsFixed(1)}kg'),
                    if (weight != null && bodyFat != null) const Text('  •  '),
                    if (bodyFat != null) Text('体脂肪率: ${bodyFat.toStringAsFixed(1)}%'),
                  ],
                ),
              );
            },
          ),
        ],
      ),
    );
  }
}
