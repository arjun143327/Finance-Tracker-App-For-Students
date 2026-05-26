import 'package:flutter/material.dart';
import 'package:fl_chart/fl_chart.dart';
import '../../core/app_colors.dart';
import '../../data/models/transaction_model.dart';
import 'glass_card.dart';

class CategoryPieChart extends StatelessWidget {
  final List<TransactionModel> transactions;
  final String currency;

  const CategoryPieChart({
    super.key,
    required this.transactions,
    required this.currency,
  });

  @override
  Widget build(BuildContext context) {
    final expenses = transactions.where((tx) => tx.type == TransactionType.expense).toList();
    
    if (expenses.isEmpty) {
      return const SizedBox.shrink();
    }

    final Map<String, double> categoryTotals = {};
    for (var tx in expenses) {
      categoryTotals[tx.category] = (categoryTotals[tx.category] ?? 0) + tx.amount;
    }

    final sortedEntries = categoryTotals.entries.toList()
      ..sort((a, b) => b.value.compareTo(a.value));

    // Limit to top 4 categories and sum the rest as "Other"
    final topEntries = sortedEntries.take(4).toList();
    double otherTotal = 0.0;
    if (sortedEntries.length > 4) {
      for (int i = 4; i < sortedEntries.length; i++) {
        otherTotal += sortedEntries[i].value;
      }
      topEntries.add(MapEntry('Other', otherTotal));
    }

    final colors = [
      AppColors.primary,
      AppColors.primaryLight,
      Colors.purple[300]!,
      Colors.orange[300]!,
      Colors.grey[400]!,
    ];

    double totalExpense = expenses.fold(0, (sum, tx) => sum + tx.amount);

    return GlassCard(
      interactive: false,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Spending Breakdown',
            style: Theme.of(context).textTheme.headlineMedium?.copyWith(fontSize: 18),
          ),
          const SizedBox(height: 24),
          Row(
            children: [
              SizedBox(
                height: 120,
                width: 120,
                child: PieChart(
                  PieChartData(
                    sectionsSpace: 2,
                    centerSpaceRadius: 40,
                    sections: List.generate(topEntries.length, (i) {
                      final entry = topEntries[i];
                      final value = entry.value;
                      return PieChartSectionData(
                        color: colors[i % colors.length],
                        value: value,
                        title: '',
                        radius: 16,
                      );
                    }),
                  ),
                ),
              ),
              const SizedBox(width: 24),
              Expanded(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: List.generate(topEntries.length, (i) {
                    final entry = topEntries[i];
                    final percentage = (entry.value / totalExpense) * 100;
                    return Padding(
                      padding: const EdgeInsets.only(bottom: 8.0),
                      child: Row(
                        children: [
                          Container(
                            width: 10,
                            height: 10,
                            decoration: BoxDecoration(
                              color: colors[i % colors.length],
                              shape: BoxShape.circle,
                            ),
                          ),
                          const SizedBox(width: 8),
                          Expanded(
                            child: Text(
                              entry.key,
                              style: Theme.of(context).textTheme.bodySmall,
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                            ),
                          ),
                          Text(
                            '${percentage.toStringAsFixed(0)}%',
                            style: Theme.of(context).textTheme.bodySmall?.copyWith(
                              fontWeight: FontWeight.bold,
                              color: AppColors.textPrimary,
                            ),
                          ),
                        ],
                      ),
                    );
                  }),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
