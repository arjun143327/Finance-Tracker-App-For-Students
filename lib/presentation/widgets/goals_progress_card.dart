import 'package:flutter/material.dart';
import '../../core/app_colors.dart';
import 'glass_card.dart';

class GoalsProgressCard extends StatelessWidget {
  final String goal;
  final double totalIncome;
  final double totalExpense;
  final String currency;

  const GoalsProgressCard({
    super.key,
    required this.goal,
    required this.totalIncome,
    required this.totalExpense,
    required this.currency,
  });

  @override
  Widget build(BuildContext context) {
    if (goal.isEmpty) return const SizedBox.shrink();

    String statusText = 'Keep tracking to see progress.';
    IconData statusIcon = Icons.track_changes_rounded;
    Color statusColor = AppColors.primary;
    double progress = 0.0;

    if (totalIncome > 0 || totalExpense > 0) {
      if (goal.toLowerCase().contains('save') || goal.toLowerCase().contains('wealth')) {
        if (totalIncome > totalExpense) {
          statusText = "You're saving effectively! Keep it up.";
          statusIcon = Icons.savings_rounded;
          statusColor = AppColors.income;
          progress = (totalIncome - totalExpense) / totalIncome;
        } else {
          statusText = "Expenses are exceeding income. Watch your savings!";
          statusIcon = Icons.warning_amber_rounded;
          statusColor = AppColors.expense;
          progress = 0.1;
        }
      } else if (goal.toLowerCase().contains('control') || goal.toLowerCase().contains('budget')) {
        if (totalExpense < (totalIncome * 0.8)) {
          statusText = "Great job! Spending is well under control.";
          statusIcon = Icons.verified_rounded;
          statusColor = AppColors.income;
          progress = 0.8;
        } else {
          statusText = "Spending is high relative to income.";
          statusIcon = Icons.trending_up_rounded;
          statusColor = AppColors.expense;
          progress = 0.9;
        }
      } else {
        statusText = "Consistent tracking helps you reach your goals.";
        statusIcon = Icons.insights_rounded;
        progress = 0.5;
      }
    }

    // Clamp progress between 0 and 1
    progress = progress.clamp(0.0, 1.0);

    return GlassCard(
      interactive: false,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: statusColor.withValues(alpha: 0.1),
                  shape: BoxShape.circle,
                ),
                child: Icon(statusIcon, color: statusColor, size: 20),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Primary Goal',
                      style: Theme.of(context).textTheme.bodySmall?.copyWith(
                        color: AppColors.textSecondary,
                        letterSpacing: 1.1,
                      ),
                    ),
                    Text(
                      goal,
                      style: Theme.of(context).textTheme.bodyLarge?.copyWith(fontWeight: FontWeight.bold),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          ClipRRect(
            borderRadius: BorderRadius.circular(4),
            child: LinearProgressIndicator(
              value: progress > 0 ? progress : null,
              backgroundColor: Colors.white.withValues(alpha: 0.05),
              valueColor: AlwaysStoppedAnimation<Color>(statusColor),
              minHeight: 6,
            ),
          ),
          const SizedBox(height: 12),
          Text(
            statusText,
            style: Theme.of(context).textTheme.bodySmall?.copyWith(
              color: AppColors.textSecondary,
            ),
          ),
        ],
      ),
    );
  }
}
