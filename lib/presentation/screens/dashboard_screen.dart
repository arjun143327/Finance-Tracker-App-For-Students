import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import '../widgets/glass_card.dart';
import '../../core/app_colors.dart';
import '../../data/models/transaction_model.dart';
import '../widgets/category_pie_chart.dart';
import '../widgets/goals_progress_card.dart';
import '../../data/providers/transaction_provider.dart';
import '../../data/providers/insights_provider.dart';
import '../../data/providers/user_provider.dart';
import '../../data/providers/currency_budget_provider.dart';
import 'settings_screen.dart';

class DashboardScreen extends ConsumerWidget {
  const DashboardScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final txState = ref.watch(transactionsListProvider);
    final insights = ref.watch(insightsProvider);
    final profileState = ref.watch(userProfileProvider);
    final profile = profileState.valueOrNull;
    final userName = profile?.name ?? 'User';
    final initialBalance = profile?.balance ?? 0.0;
    final currency = ref.watch(currencySymbolProvider);

    final hour = DateTime.now().hour;
    String greeting = 'Good Evening';
    if (hour < 12) {
      greeting = 'Good Morning';
    } else if (hour < 17) {
      greeting = 'Good Afternoon';
    }

    return SingleChildScrollView(
      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 60),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              GestureDetector(
                onTap: () {
                  Navigator.of(context).push(
                    MaterialPageRoute(builder: (_) => const SettingsScreen()),
                  );
                },
                child: CircleAvatar(
                  radius: 20,
                  backgroundColor: Colors.white.withValues(alpha: 0.08),
                  child: const Icon(Icons.person_outline, color: AppColors.textSecondary),
                ),
              ),
              Expanded(
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        '$greeting,',
                        style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                          color: AppColors.textSecondary,
                        ),
                      ),
                      Text(
                        userName,
                        style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                          color: AppColors.primaryLight,
                          letterSpacing: 0.3,
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ],
                  ),
                ),
              ),
              const Icon(Icons.notifications_none_rounded, color: AppColors.primary, size: 28),
            ],
          ),
          const SizedBox(height: 40),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            decoration: BoxDecoration(
              color: Colors.white.withValues(alpha: 0.05),
              borderRadius: BorderRadius.circular(20),
              border: Border.all(color: Colors.white.withValues(alpha: 0.1)),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                const Icon(Icons.wallet_outlined, size: 16, color: AppColors.primary),
                const SizedBox(width: 8),
                Text(
                  'TOTAL WEALTH',
                  style: Theme.of(context).textTheme.bodySmall?.copyWith(
                    color: AppColors.textSecondary,
                    letterSpacing: 1.2,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(width: 6),
                Tooltip(
                  message: 'Starting Balance + Income - Expenses',
                  triggerMode: TooltipTriggerMode.tap,
                  child: Icon(Icons.info_outline_rounded, size: 14, color: AppColors.textSecondary.withValues(alpha: 0.6)),
                ),
              ],
            ),
          ),
          const SizedBox(height: 16),
          txState.when(
            loading: () => const SizedBox(
              height: 52,
              child: Center(
                child: CircularProgressIndicator(color: AppColors.primary),
              ),
            ),
            error: (_, __) => Text(
              '${currency}0',
              style: Theme.of(context).textTheme.displayLarge?.copyWith(
                fontSize: 44,
                letterSpacing: -1,
              ),
            ),
            data: (transactions) {
              final total = _calculateBalance(transactions, initialBalance);
              return TweenAnimationBuilder<double>(
                tween: Tween(begin: 0, end: total),
                duration: const Duration(milliseconds: 850),
                builder: (context, value, _) => Text(
                  '$currency${value.toStringAsFixed(0)}',
                  style: Theme.of(context).textTheme.displayLarge?.copyWith(
                    fontSize: 44,
                    letterSpacing: -1,
                    shadows: [
                      Shadow(
                        color: AppColors.primary.withValues(alpha: 0.25),
                        blurRadius: 22,
                        offset: const Offset(-3, -4),
                      ),
                    ],
                  ),
                ),
              );
            },
          ),
          // Smart Insight Card — dynamic from insightsProvider
          if (insights.isNotEmpty) ...[
            _buildInsightCard(context, insights.first),
            const SizedBox(height: 24),
          ],
          
          txState.maybeWhen(
            data: (transactions) {
              final currentMonthTx = transactions.where((t) => t.date.month == DateTime.now().month && t.date.year == DateTime.now().year).toList();
              final totalIncome = currentMonthTx.where((t) => t.type == TransactionType.income).fold(0.0, (sum, t) => sum + t.amount);
              final totalExpense = currentMonthTx.where((t) => t.type == TransactionType.expense).fold(0.0, (sum, t) => sum + t.amount);

              return Column(
                children: [
                  if (profile?.goal != null) ...[
                    GoalsProgressCard(
                      goal: profile!.goal,
                      totalIncome: totalIncome,
                      totalExpense: totalExpense,
                      currency: currency,
                    ),
                    const SizedBox(height: 24),
                  ],
                  if (currentMonthTx.any((t) => t.type == TransactionType.expense)) ...[
                    CategoryPieChart(
                      transactions: currentMonthTx,
                      currency: currency,
                    ),
                    const SizedBox(height: 40),
                  ],
                ],
              );
            },
            orElse: () => const SizedBox.shrink(),
          ),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'Recent Transactions',
                style: Theme.of(context).textTheme.headlineMedium,
              ),
              TextButton(
                onPressed: () {
                  // Navigate to the Ledger tab (index 1) via the AppShell
                  // Using a simple callback via DefaultTabController is not needed here
                  // since the user can tap the nav bar — this is acceptable UX
                },
                child: Row(
                  children: [
                    Text(
                      'VIEW ALL',
                      style: Theme.of(context).textTheme.labelLarge?.copyWith(fontSize: 12),
                    ),
                    const Icon(Icons.chevron_right_rounded, size: 18),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          txState.when(
            loading: () => const SizedBox.shrink(),
            error: (_, __) => const SizedBox.shrink(),
            data: (transactions) {
              if (transactions.isEmpty) {
                return _buildEmptyState(context);
              }
              return Column(
                children: transactions
                    .take(3)
                    .map((tx) => _buildRecentTransaction(context, tx, currency))
                    .toList(),
              );
            },
          ),
        ],
      ),
    );
  }

  Widget _buildInsightCard(BuildContext context, InsightMessage insight) {
    return Container(
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(18),
        boxShadow: [
          BoxShadow(
            color: AppColors.primary.withValues(alpha: 0.12),
            blurRadius: 28,
            spreadRadius: 1,
            offset: const Offset(-6, -8),
          ),
        ],
      ),
      child: GlassCard(
        interactive: false,
        child: Column(
          children: [
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: AppColors.primary.withValues(alpha: 0.1),
                shape: BoxShape.circle,
              ),
              child: Icon(
                insight.isPositive ? Icons.trending_down_rounded : Icons.trending_up_rounded,
                color: AppColors.primary,
                size: 32,
              ),
            ),
            const SizedBox(height: 24),
            Text(
              insight.title,
              style: Theme.of(context).textTheme.headlineMedium,
            ),
            const SizedBox(height: 16),
            Text(
              insight.message,
              textAlign: TextAlign.center,
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(height: 1.5),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildEmptyState(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 40),
      child: Column(
        children: [
          Icon(Icons.receipt_long_rounded, size: 56, color: AppColors.primary.withValues(alpha: 0.4)),
          const SizedBox(height: 16),
          Text(
            'No transactions yet',
            style: Theme.of(context).textTheme.headlineMedium?.copyWith(
              color: AppColors.textSecondary,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'Tap + to log your first expense.',
            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
              color: AppColors.textMuted,
            ),
          ),
        ],
      ),
    );
  }


  double _calculateBalance(List<TransactionModel> transactions, double initialBalance) {
    return transactions.fold<double>(initialBalance, (sum, item) {
      if (item.type == TransactionType.income) return sum + item.amount;
      return sum - item.amount;
    });
  }

  Widget _buildRecentTransaction(BuildContext context, TransactionModel tx, String currency) {
    final isIncome = tx.type == TransactionType.income;
    final amountText = '${isIncome ? '+' : '-'}$currency${tx.amount.toStringAsFixed(0)}';
    final subtitle = '${tx.category} • ${DateFormat('dd MMM, hh:mm a').format(tx.date)}';
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.03),
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: Colors.white.withValues(alpha: 0.05)),
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: Colors.white.withValues(alpha: 0.05),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Icon(
              isIncome ? Icons.south_west_rounded : Icons.north_east_rounded,
              color: AppColors.textSecondary,
              size: 24,
            ),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  tx.title,
                  style: Theme.of(context).textTheme.bodyLarge?.copyWith(fontWeight: FontWeight.w600),
                ),
                const SizedBox(height: 4),
                Text(
                  subtitle,
                  style: Theme.of(context).textTheme.bodySmall,
                ),
              ],
            ),
          ),
          Column(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Text(
                amountText,
                style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                  fontWeight: FontWeight.bold,
                  color: isIncome ? AppColors.income : AppColors.textPrimary,
                ),
              ),
              const SizedBox(height: 4),
              Text(
                tx.method,
                style: Theme.of(context).textTheme.bodySmall?.copyWith(fontSize: 10),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

