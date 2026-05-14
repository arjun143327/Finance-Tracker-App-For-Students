import 'package:flutter/material.dart';
import '../../core/app_colors.dart';
import '../widgets/glass_card.dart';

class BudgetScreen extends StatelessWidget {
  const BudgetScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 60),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Budget',
            style: Theme.of(context).textTheme.displayLarge,
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
            totalBudget: 24000,
            totalSpent: 15320,
            remaining: 8680,
          ),
          const SizedBox(height: 20),
          _BudgetCategoryTile(
            category: 'Food & Dining',
            spent: 6200,
            limit: 7000,
            accent: AppColors.warning,
          ),
          const SizedBox(height: 14),
          _BudgetCategoryTile(
            category: 'Transport',
            spent: 2600,
            limit: 4500,
            accent: AppColors.primary,
          ),
          const SizedBox(height: 14),
          _BudgetCategoryTile(
            category: 'Shopping',
            spent: 4100,
            limit: 4000,
            accent: AppColors.expense,
          ),
          const SizedBox(height: 14),
          _BudgetCategoryTile(
            category: 'Bills & Utilities',
            spent: 2420,
            limit: 3000,
            accent: AppColors.income,
          ),
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
