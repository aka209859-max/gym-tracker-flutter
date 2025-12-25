import 'package:gym_match/gen/app_localizations.dart';
import 'package:flutter/material.dart';
import '../utils/strength_calculators.dart';

/// 筋力計算ツール画面
/// 
/// 1RM計算機とプレート計算機を提供します。
class CalculatorsScreen extends StatelessWidget {
  CalculatorsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return DefaultTabController(
      length: 2,
      child: Scaffold(
        appBar: AppBar(
          title: Text(AppLocalizations.of(context)!.workout_0052814d),
          bottom: TabBar(
            tabs: [
              Tab(icon: Icon(Icons.calculate), text: AppLocalizations.of(context)!.rmCalculator),
              Tab(icon: Icon(Icons.fitness_center), text: AppLocalizations.of(context)!.plateCalculator),
            ],
          ),
        ),
        body: TabBarView(
          children: [
            _OneRMCalculatorTab(),
            _PlateCalculatorTab(),
          ],
        ),
      ),
    );
  }
}

/// 1RM計算タブ
class _OneRMCalculatorTab extends StatefulWidget {
  _OneRMCalculatorTab();

  @override
  State<_OneRMCalculatorTab> createState() => _OneRMCalculatorTabState();
}

class _OneRMCalculatorTabState extends State<_OneRMCalculatorTab> {
  final _weightController = TextEditingController();
  final _repsController = TextEditingController();
  double? _calculatedOneRM;
  Map<int, double> _targetWeights = {};

  void _calculate() {
    final weight = double.tryParse(_weightController.text);
    final reps = int.tryParse(_repsController.text);

    if (weight == null || reps == null || weight <= 0 || reps <= 0) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(AppLocalizations.of(context)!.general_483508ec)),
      );
      return;
    }

    setState(() {
      _calculatedOneRM = StrengthCalculators.calculate1RM(weight, reps);
      
      // ターゲット回数での推奨重量を計算
      _targetWeights = {
        1: _calculatedOneRM!,
        3: StrengthCalculators.calculateWeight(_calculatedOneRM!, 3),
        5: StrengthCalculators.calculateWeight(_calculatedOneRM!, 5),
        8: StrengthCalculators.calculateWeight(_calculatedOneRM!, 8),
        10: StrengthCalculators.calculateWeight(_calculatedOneRM!, 10),
        12: StrengthCalculators.calculateWeight(_calculatedOneRM!, 12),
      };
    });
  }

  void _clear() {
    setState(() {
      _weightController.clear();
      _repsController.clear();
      _calculatedOneRM = null;
      _targetWeights.clear();
    });
  }

  @override
  void dispose() {
    _weightController.dispose();
    _repsController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          // 説明カード
          Card(
            color: Colors.blue[50],
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Icon(Icons.info_outline, color: Colors.blue[700]),
                      SizedBox(width: 8),
                      Text(
                        AppLocalizations.of(context)!.general_a35f8c38,
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                          color: Colors.blue[700],
                        ),
                      ),
                    ],
                  ),
                  SizedBox(height: 8),
                  Text(
                    AppLocalizations.of(context)!.generatedKey_7cf32853
                    AppLocalizations.of(context)!.general_f5fcce57,
                    style: TextStyle(fontSize: 14),
                  ),
                ],
              ),
            ),
          ),
          SizedBox(height: 24),

          // 入力フォーム
          Row(
            children: [
              Expanded(
                child: TextField(
                  controller: _weightController,
                  keyboardType: TextInputType.number,
                  decoration: InputDecoration(
                    labelText: '重量 (kg)',
                    border: OutlineInputBorder(),
                    prefixIcon: Icon(Icons.fitness_center),
                  ),
                ),
              ),
              SizedBox(width: 16),
              Expanded(
                child: TextField(
                  controller: _repsController,
                  keyboardType: TextInputType.number,
                  decoration: InputDecoration(
                    labelText: AppLocalizations.of(context)!.repsCount,
                    border: OutlineInputBorder(),
                    prefixIcon: Icon(Icons.repeat),
                  ),
                ),
              ),
            ],
          ),
          SizedBox(height: 16),

          // 計算ボタン
          Row(
            children: [
              Expanded(
                child: ElevatedButton(
                  onPressed: _calculate,
                  style: ElevatedButton.styleFrom(
                    padding: const EdgeInsets.symmetric(vertical: 16),
                  ),
                  child: Text(AppLocalizations.of(context)!.calculate, style: TextStyle(fontSize: 16)),
                ),
              ),
              SizedBox(width: 12),
              OutlinedButton(
                onPressed: _clear,
                style: OutlinedButton.styleFrom(
                  padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 24),
                ),
                child: Text(AppLocalizations.of(context)!.clear),
              ),
            ],
          ),
          SizedBox(height: 32),

          // 結果表示
          if (_calculatedOneRM != null) ...[
            // 1RM結果
            Card(
              elevation: 4,
              color: Colors.green[50],
              child: Padding(
                padding: const EdgeInsets.all(24),
                child: Column(
                  children: [
                    Text(AppLocalizations.of(context)!.estimatedMax,
                      style: TextStyle(fontSize: 16, color: Colors.grey),
                    ),
                    SizedBox(height: 8),
                    Text(
                      '${_calculatedOneRM!.toStringAsFixed(1)} kg',
                      style: TextStyle(
                        fontSize: 48,
                        fontWeight: FontWeight.bold,
                        color: Colors.green,
                      ),
                    ),
                  ],
                ),
              ),
            ),
            SizedBox(height: 24),

            // ターゲット重量表
            Card(
              child: Column(
                children: [
                  Container(
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: Colors.grey[100],
                      borderRadius: const BorderRadius.vertical(top: Radius.circular(4)),
                    ),
                    child: Row(
                      children: [
                        Icon(Icons.table_chart),
                        SizedBox(width: 8),
                        Text(
                          AppLocalizations.of(context)!.general_1840ca14,
                          style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                        ),
                      ],
                    ),
                  ),
                  Divider(height: 1),
                  ..._targetWeights.entries.map((entry) {
                    return ListTile(
                      leading: CircleAvatar(
                        child: Text('${entry.key}'),
                      ),
                      title: Text('${entry.key}回'),
                      trailing: Text(
                        '${entry.value.toStringAsFixed(1)} kg',
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    );
                  }),
                ],
              ),
            ),
          ],
        ],
      ),
    );
  }
}

/// プレート計算タブ
class _PlateCalculatorTab extends StatefulWidget {
  _PlateCalculatorTab();

  @override
  State<_PlateCalculatorTab> createState() => _PlateCalculatorTabState();
}

class _PlateCalculatorTabState extends State<_PlateCalculatorTab> {
  final _targetWeightController = TextEditingController();
  double _barWeight = 20.0; // デフォルト: 20kg
  Map<double, int>? _plates;
  double? _totalWeight;

  void _calculate() {
    final targetWeight = double.tryParse(_targetWeightController.text);

    if (targetWeight == null || targetWeight <= _barWeight) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(AppLocalizations.of(context)!.generatedKey_ef30a8d3)),
      );
      return;
    }

    setState(() {
      _plates = StrengthCalculators.calculatePlates(targetWeight, barWeight: _barWeight);
      _totalWeight = StrengthCalculators.getTotalWeightFromPlates(_plates!, barWeight: _barWeight);
    });
  }

  void _clear() {
    setState(() {
      _targetWeightController.clear();
      _plates = null;
      _totalWeight = null;
    });
  }

  @override
  void dispose() {
    _targetWeightController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          // 説明カード
          Card(
            color: Colors.orange[50],
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Icon(Icons.info_outline, color: Colors.orange[700]),
                      SizedBox(width: 8),
                      Text(
                        AppLocalizations.of(context)!.workout_ae263865,
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                          color: Colors.orange[700],
                        ),
                      ),
                    ],
                  ),
                  SizedBox(height: 8),
                  Text(
                    AppLocalizations.of(context)!.generatedKey_20458277
                    AppLocalizations.of(context)!.general_9d700689,
                    style: TextStyle(fontSize: 14),
                  ),
                ],
              ),
            ),
          ),
          SizedBox(height: 24),

          // バー重量選択
          Card(
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    AppLocalizations.of(context)!.general_d1efcee6,
                    style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                  ),
                  SizedBox(height: 12),
                  SegmentedButton<double>(
                    segments: [
                      ButtonSegment(value: 20.0, label: Text('20kg')),
                      ButtonSegment(value: 10.0, label: Text('10kg')),
                      ButtonSegment(value: 5.0, label: Text('5kg')),
                    ],
                    selected: {_barWeight},
                    onSelectionChanged: (Set<double> newSelection) {
                      setState(() {
                        _barWeight = newSelection.first;
                        _plates = null;
                        _totalWeight = null;
                      });
                    },
                  ),
                ],
              ),
            ),
          ),
          SizedBox(height: 16),

          // 目標重量入力
          TextField(
            controller: _targetWeightController,
            keyboardType: TextInputType.number,
            decoration: InputDecoration(
              labelText: '目標重量 (kg)',
              border: OutlineInputBorder(),
              prefixIcon: Icon(Icons.scale),
              helperText: AppLocalizations.of(context)!.generatedKey_56b65fc2,
            ),
          ),
          SizedBox(height: 16),

          // 計算ボタン
          Row(
            children: [
              Expanded(
                child: ElevatedButton(
                  onPressed: _calculate,
                  style: ElevatedButton.styleFrom(
                    padding: const EdgeInsets.symmetric(vertical: 16),
                  ),
                  child: Text(AppLocalizations.of(context)!.calculate, style: TextStyle(fontSize: 16)),
                ),
              ),
              SizedBox(width: 12),
              OutlinedButton(
                onPressed: _clear,
                style: OutlinedButton.styleFrom(
                  padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 24),
                ),
                child: Text(AppLocalizations.of(context)!.clear),
              ),
            ],
          ),
          SizedBox(height: 32),

          // 結果表示
          if (_plates != null && _totalWeight != null) ...[
            // 実際の総重量
            Card(
              elevation: 4,
              color: Colors.blue[50],
              child: Padding(
                padding: const EdgeInsets.all(24),
                child: Column(
                  children: [
                    Text(
                      AppLocalizations.of(context)!.general_c9083826,
                      style: TextStyle(fontSize: 16, color: Colors.grey),
                    ),
                    SizedBox(height: 8),
                    Text(
                      '${_totalWeight!.toStringAsFixed(1)} kg',
                      style: TextStyle(
                        fontSize: 48,
                        fontWeight: FontWeight.bold,
                        color: Colors.blue,
                      ),
                    ),
                    SizedBox(height: 8),
                    Text(
                      'バー: $_barWeight kg + プレート: ${(_totalWeight! - _barWeight).toStringAsFixed(1)} kg',
                      style: TextStyle(fontSize: 14, color: Colors.grey[700]),
                    ),
                  ],
                ),
              ),
            ),
            SizedBox(height: 24),

            // プレート構成 (片側)
            Card(
              child: Column(
                children: [
                  Container(
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: Colors.grey[100],
                      borderRadius: const BorderRadius.vertical(top: Radius.circular(4)),
                    ),
                    child: Row(
                      children: [
                        Icon(Icons.fitness_center),
                        SizedBox(width: 8),
                        Text(
                          'プレート構成 (片側)',
                          style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                        ),
                      ],
                    ),
                  ),
                  Divider(height: 1),
                  if (_plates!.isEmpty)
                    Padding(
                      padding: EdgeInsets.all(24),
                      child: Text(
                        AppLocalizations.of(context)!.generatedKey_201ea826,
                        style: TextStyle(fontSize: 16, color: Colors.grey),
                      ),
                    )
                  else
                    ..._plates!.entries.map((entry) {
                      return ListTile(
                        leading: Container(
                          width: 50,
                          height: 50,
                          decoration: BoxDecoration(
                            color: _getPlateColor(entry.key),
                            shape: BoxShape.circle,
                          ),
                          child: Center(
                            child: Text(
                              '${entry.key}',
                              style: TextStyle(
                                color: Colors.white,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ),
                        ),
                        title: Text('${entry.key} kg プレート'),
                        trailing: Text(
                          '× ${entry.value}枚',
                          style: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      );
                    }),
                ],
              ),
            ),
            SizedBox(height: 16),

            // 注意事項
            Card(
              color: Colors.amber[50],
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Row(
                  children: [
                    Icon(Icons.info_outline, color: Colors.amber[700]),
                    SizedBox(width: 12),
                    Expanded(
                      child: Text(
                        AppLocalizations.of(context)!.generatedKey_e9fe8032,
                        style: TextStyle(fontSize: 14),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ],
      ),
    );
  }

  Color _getPlateColor(double weight) {
    if (weight >= 20) return Colors.red;
    if (weight >= 10) return Colors.blue;
    if (weight >= 5) return Colors.green;
    if (weight >= 2.5) return Colors.orange;
    return Colors.grey;
  }
}
