import 'package:flutter/material.dart';

class RMCalculatorScreen extends StatefulWidget {
  const RMCalculatorScreen({super.key});

  @override
  State<RMCalculatorScreen> createState() => _RMCalculatorScreenState();
}

class _RMCalculatorScreenState extends State<RMCalculatorScreen> {
  final _weightController = TextEditingController();
  final _repsController = TextEditingController();
  Map<int, double>? _rmResults;  // 1～20RMの結果を保存

  @override
  void dispose() {
    _weightController.dispose();
    _repsController.dispose();
    super.dispose();
  }

  void _calculateRM() {
    final weight = double.tryParse(_weightController.text);
    final reps = int.tryParse(_repsController.text);

    if (weight != null && reps != null && reps > 0) {
      // Epley式: 1RM = 重量 × (1 + 回数 / 30)
      final oneRM = weight * (1 + reps / 30);
      
      // 1～20RMを計算
      final results = <int, double>{};
      for (int i = 1; i <= 20; i++) {
        // nRM = 1RM / (1 + n / 30)
        results[i] = oneRM / (1 + (i - 1) / 30);
      }
      
      setState(() {
        _rmResults = results;
      });
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('正しい数値を入力してください'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('RM計算機'),
        backgroundColor: Theme.of(context).colorScheme.primary,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            const Text(
              'RM (Repetition Maximum) 計算',
              style: TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.bold,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 8),
            const Text(
              '挙上した重量と回数から、1RMを計算します',
              style: TextStyle(
                fontSize: 14,
                color: Colors.grey,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 32),
            
            // 重量入力
            TextField(
              controller: _weightController,
              keyboardType: const TextInputType.numberWithOptions(decimal: true),
              decoration: InputDecoration(
                labelText: '重量 (kg)',
                hintText: '例: 100',
                prefixIcon: const Icon(Icons.fitness_center),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
                filled: true,
                fillColor: Colors.grey[50],
              ),
            ),
            
            const SizedBox(height: 16),
            
            // 回数入力
            TextField(
              controller: _repsController,
              keyboardType: TextInputType.number,
              decoration: InputDecoration(
                labelText: '回数',
                hintText: '例: 5',
                prefixIcon: const Icon(Icons.repeat),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
                filled: true,
                fillColor: Colors.grey[50],
              ),
            ),
            
            const SizedBox(height: 24),
            
            // 計算ボタン
            ElevatedButton(
              onPressed: _calculateRM,
              style: ElevatedButton.styleFrom(
                backgroundColor: Theme.of(context).colorScheme.primary,
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(vertical: 16),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
                elevation: 2,
              ),
              child: const Text(
                '1RMを計算',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
            
            const SizedBox(height: 32),
            
            // 計算結果（1～20RM一覧）
            if (_rmResults != null) ...[
              Container(
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(
                  color: Theme.of(context).colorScheme.primary.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(
                    color: Theme.of(context).colorScheme.primary.withValues(alpha: 0.3),
                    width: 2,
                  ),
                ),
                child: Column(
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(
                          Icons.emoji_events,
                          color: Theme.of(context).colorScheme.primary,
                          size: 28,
                        ),
                        const SizedBox(width: 8),
                        const Text(
                          'RM計算結果（1～20RM）',
                          style: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 16),
                    Container(
                      constraints: const BoxConstraints(maxHeight: 400),
                      child: ListView.builder(
                        shrinkWrap: true,
                        itemCount: 20,
                        itemBuilder: (context, index) {
                          final rm = index + 1;
                          final weight = _rmResults![rm]!;
                          return Container(
                            margin: const EdgeInsets.only(bottom: 8),
                            padding: const EdgeInsets.symmetric(
                              horizontal: 16,
                              vertical: 12,
                            ),
                            decoration: BoxDecoration(
                              color: rm == 1 
                                  ? Theme.of(context).colorScheme.primary.withValues(alpha: 0.15)
                                  : Colors.white,
                              borderRadius: BorderRadius.circular(8),
                              border: Border.all(
                                color: rm == 1
                                    ? Theme.of(context).colorScheme.primary
                                    : Colors.grey[300]!,
                                width: rm == 1 ? 2 : 1,
                              ),
                            ),
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Row(
                                  children: [
                                    if (rm == 1)
                                      Container(
                                        padding: const EdgeInsets.symmetric(
                                          horizontal: 8,
                                          vertical: 4,
                                        ),
                                        decoration: BoxDecoration(
                                          color: Theme.of(context).colorScheme.primary,
                                          borderRadius: BorderRadius.circular(4),
                                        ),
                                        child: const Text(
                                          '最大',
                                          style: TextStyle(
                                            fontSize: 10,
                                            color: Colors.white,
                                            fontWeight: FontWeight.bold,
                                          ),
                                        ),
                                      ),
                                    if (rm == 1) const SizedBox(width: 8),
                                    Text(
                                      '${rm}RM',
                                      style: TextStyle(
                                        fontSize: 16,
                                        fontWeight: rm == 1 ? FontWeight.bold : FontWeight.w600,
                                        color: rm == 1 
                                            ? Theme.of(context).colorScheme.primary
                                            : Colors.black87,
                                      ),
                                    ),
                                  ],
                                ),
                                Row(
                                  crossAxisAlignment: CrossAxisAlignment.baseline,
                                  textBaseline: TextBaseline.alphabetic,
                                  children: [
                                    Text(
                                      weight.toStringAsFixed(1),
                                      style: TextStyle(
                                        fontSize: rm == 1 ? 24 : 18,
                                        fontWeight: FontWeight.bold,
                                        color: rm == 1
                                            ? Theme.of(context).colorScheme.primary
                                            : Colors.black87,
                                      ),
                                    ),
                                    const SizedBox(width: 4),
                                    Text(
                                      'kg',
                                      style: TextStyle(
                                        fontSize: 14,
                                        color: Colors.grey[600],
                                      ),
                                    ),
                                  ],
                                ),
                              ],
                            ),
                          );
                        },
                      ),
                    ),
                  ],
                ),
              ),
            ],
            
            const SizedBox(height: 24),
            
            // 参考情報
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Colors.grey[50],
                borderRadius: BorderRadius.circular(12),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Icon(Icons.info_outline, color: Colors.grey[600]),
                      const SizedBox(width: 8),
                      const Text(
                        'RMについて',
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 12),
                  Text(
                    '• RM (Repetition Maximum)：特定の回数で挙上可能な最大重量\n'
                    '• 1RM：1回だけ挙上できる最大重量\n'
                    '• この計算はEpley式を使用しています\n'
                    '• 実際の1RMとは誤差がある可能性があります',
                    style: TextStyle(
                      fontSize: 14,
                      color: Colors.grey[700],
                      height: 1.5,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
