import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../core/app_colors.dart';
import '../../data/models/transaction_model.dart';
import '../../data/providers/budget_provider.dart';
import '../widgets/glass_card.dart';

class BudgetScreen extends ConsumerWidget {
  const BudgetScreen({super.key});

  void _showSetBudgetDialog(BuildContext context, WidgetRef ref, double current) {
    final controller = TextEditingController(text: current.toStringAsFixed(0));
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: AppColors.bgGradientStart,
        title: const Text('Set Monthly Budget', style: TextStyle(color: Colors.white)),
        content: TextField(
          controller: controller,
          keyboardType: TextInputType.number,
          autofocus: true,
          style: const TextStyle(color: Colors.white),
          decoration: const InputDecoration(
            hintText: 'Enter amount',
            prefixText: '₹ ',
          ),
        ),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context), child: const Text('Cancel')),
          TextButton(
            onPressed: () {
              final amount = double.tryParse(controller.text) ?? 0;
              ref.read(monthlyBudgetProvider.notifier).setBudget(amount);
              Navigator.pop(context);
            },
            child: const Text('Save'),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final totalBudget = ref.watch(monthlyBudgetProvider);
    final totalSpent = ref.watch(currentMonthSpendingProvider);
    final transactions = ref.watch(currentMonthTransactionsProvider);

    // Group spending by category
    final categoryMap = <String, double>{};
    for (var tx in transactions) {
      categoryMap[tx.category] = (categoryMap[tx.category] ?? 0) + tx.amount;
    }

    return SingleChildScrollView(
      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 60),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'Budget',
                style: Theme.of(context).textTheme.displayLarge,
              ),
              IconButton(
                icon: const Icon(Icons.edit_note_rounded, color: AppColors.primary),
                onPressed: () => _showSetBudgetDialog(context, ref, totalBudget),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Text(
            'Track category limits and stay ahead of overspending.',
            style: Theme.of(context).textTheme.bodyLarge?.copyWith(
              color: AppColors.textSecondary,
            ),
          ),
          const SizedBox(height: 24),
          _BudgetSummaryCard(
            totalBudget: totalBudget > 0 ? totalBudget : 1, // Avoid division by zero
            totalSpent: totalSpent,
            remaining: (totalBudget - totalSpent).clamp(0.0, double.infinity),
          ),
          const SizedBox(height: 32),
          Text(
            'Category Spending',
            style: Theme.of(context).textTheme.headlineMedium,
          ),
          const SizedBox(height: 16),
          if (categoryMap.isEmpty)
            Padding(
              padding: const EdgeInsets.symmetric(vertical: 40),
              child: Center(
                child: Text(
                  'No expenses recorded this month.',
                  style: Theme.of(context).textTheme.bodyMedium?.copyWith(color: AppColors.textMuted),
                ),
              ),
            )
          else
            ...categoryMap.entries.map((entry) => Padding(
              padding: const EdgeInsets.only(bottom: 14),
              child: _BudgetCategoryTile(
                category: entry.key,
                spent: entry.value,
                limit: totalBudget / 4, // Simple dynamic limit for now
                accent: AppColors.primary,
              ),
            )),
        ],
      ),
    );
  }
}

class _BudgetSummaryCard extends StatelessWidget {
  final double totalBudget;
  final double totalSpent;
  final double remaining;

  const _BudgetSummaryCard({
    required this.totalBudget,
    required this.totalSpent,
    required this.remaining,
  });

  @override
  Widget build(BuildContext context) {
    final usage = (totalSpent / totalBudget).clamp(0.0, 1.0);

    return Container(
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(18),
        boxShadow: [
          BoxShadow(
            color: AppColors.primary.withOpacity(0.12),
            blurRadius: 26,
            spreadRadius: 1,
            offset: const Offset(-5, -7),
          ),
        ],
      ),
      child: GlassCard(
        interactive: false,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Monthly Overview',
              style: Theme.of(context).textTheme.headlineMedium,
            ),
            const SizedBox(height: 14),
            Text(
              '₹${totalSpent.toStringAsFixed(0)} / ₹${totalBudget.toStringAsFixed(0)} used',
              style: Theme.of(context).textTheme.bodyLarge,
            ),
            const SizedBox(height: 12),
            ClipRRect(
              borderRadius: BorderRadius.circular(100),
              child: LinearProgressIndicator(
                value: usage,
                minHeight: 10,
                backgroundColor: Colors.white.withOpacity(0.08),
                valueColor: const AlwaysStoppedAnimation<Color>(AppColors.primary),
              ),
            ),
            const SizedBox(height: 12),
            Text(
              'Remaining: ₹${remaining.toStringAsFixed(0)}',
              style: Theme.of(context).textTheme.labelLarge?.copyWith(
                color: AppColors.primaryLight,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _BudgetCategoryTile extends StatelessWidget {
  final String category;
  final double spent;
  final double limit;
  final Color accent;

  const _BudgetCategoryTile({
    required this.category,
    required this.spent,
    required this.limit,
    required this.accent,
  });

  @override
  Widget build(BuildContext context) {
    final ratio = (spent / limit).clamp(0.0, 1.3);
    final isNearLimit = ratio >= 0.85 && ratio <= 1.0;
    final isOverLimit = ratio > 1.0;

    String status = 'On track';
    Color statusColor = AppColors.income;

    if (isNearLimit) {
      status = 'Near limit';
      statusColor = AppColors.warning;
    }
    if (isOverLimit) {
      status = 'Limit exceeded';
      statusColor = AppColors.expense;
    }

    return GlassCard(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Expanded(
                child: Text(
                  category,
                  style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                    fontSize: 22,
                  ),
                ),
              ),
              Text(
                status,
                style: Theme.of(context).textTheme.labelLarge?.copyWith(
                  color: statusColor,
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Text(
            '₹${spent.toStringAsFixed(0)} of ₹${limit.toStringAsFixed(0)}',
            style: Theme.of(context).textTheme.bodyMedium,
          ),
          const SizedBox(height: 10),
          ClipRRect(
            borderRadius: BorderRadius.circular(100),
            child: LinearProgressIndicator(
              value: ratio > 1 ? 1 : ratio,
              minHeight: 8,
              backgroundColor: Colors.white.withOpacity(0.08),
              valueColor: AlwaysStoppedAnimation<Color>(
                isOverLimit ? AppColors.expense : accent,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
