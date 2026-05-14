import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'transaction_provider.dart';
import '../models/transaction_model.dart';

class InsightMessage {
  final String title;
  final String message;
  final bool isPositive; // true if spending decreased or savings increased

  InsightMessage({required this.title, required this.message, required this.isPositive});
}

final insightsProvider = Provider<List<InsightMessage>>((ref) {
  final txState = ref.watch(transactionsListProvider);
  
  return txState.maybeWhen(
    data: (transactions) {
      if (transactions.isEmpty) return [];

      final now = DateTime.now();
      final last7Days = transactions.where((t) => t.date.isAfter(now.subtract(const Duration(days: 7)))).toList();
      final prev7Days = transactions.where((t) => 
        t.date.isAfter(now.subtract(const Duration(days: 14))) && 
        t.date.isBefore(now.subtract(const Duration(days: 7)))
      ).toList();

      List<InsightMessage> insights = [];

      // Overall spending trend
      final currentSpend = last7Days.where((t) => t.type == TransactionType.expense).fold(0.0, (sum, t) => sum + t.amount);
      final prevSpend = prev7Days.where((t) => t.type == TransactionType.expense).fold(0.0, (sum, t) => sum + t.amount);

      if (prevSpend > 0) {
        final diff = ((currentSpend - prevSpend) / prevSpend * 100).abs();
        if (currentSpend > prevSpend) {
          insights.add(InsightMessage(
            title: 'Overall Spending',
            message: 'Your spending increased by ${diff.toStringAsFixed(0)}% this week.',
            isPositive: false,
          ));
        } else {
          insights.add(InsightMessage(
            title: 'Overall Spending',
            message: 'Great job! You spent ${diff.toStringAsFixed(0)}% less than last week.',
            isPositive: true,
          ));
        }
      }

      // Top Category Insight
      final categorySpending = <String, double>{};
      for (var t in last7Days.where((t) => t.type == TransactionType.expense)) {
        categorySpending[t.category] = (categorySpending[t.category] ?? 0) + t.amount;
      }

      if (categorySpending.isNotEmpty) {
        final topCategory = categorySpending.entries.reduce((a, b) => a.value > b.value ? a : b);
        insights.add(InsightMessage(
          title: 'Top Category',
          message: '${topCategory.key} is your highest expense this week (₹${topCategory.value.toStringAsFixed(0)}).',
          isPositive: false,
        ));
      }

      // Income Insight
      final income = last7Days.where((t) => t.type == TransactionType.income).fold(0.0, (sum, t) => sum + t.amount);
      if (income > 0) {
        insights.add(InsightMessage(
          title: 'Weekly Income',
          message: 'You\'ve recorded ₹${income.toStringAsFixed(0)} in income this week.',
          isPositive: true,
        ));
      }

      return insights;
    },
    orElse: () => [],
  );
});
