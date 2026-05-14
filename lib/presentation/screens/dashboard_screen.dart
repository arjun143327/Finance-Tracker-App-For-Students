import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import '../widgets/glass_card.dart';
import '../widgets/custom_button.dart';
import '../../core/app_colors.dart';
import '../../data/models/transaction_model.dart';
import '../../data/providers/transaction_provider.dart';
import 'settings_screen.dart';

class DashboardScreen extends ConsumerWidget {
  const DashboardScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final txState = ref.watch(transactionsListProvider);
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
                  backgroundColor: Colors.white.withOpacity(0.08),
                  child: const Icon(Icons.person_outline, color: AppColors.textSecondary),
                ),
              ),
              Text(
                'Budgetrix',
                style: Theme.of(context).textTheme.displayMedium?.copyWith(
                  color: AppColors.primaryLight,
                  letterSpacing: 0.3,
                ),
              ),
              Stack(
                children: [
                  const Icon(Icons.notifications_none_rounded, color: AppColors.primary, size: 28),
                  Positioned(
                    right: 4,
                    top: 4,
                    child: Container(
                      width: 8,
                      height: 8,
                      decoration: const BoxDecoration(
                        color: AppColors.warning,
                        shape: BoxShape.circle,
                      ),
                    ),
                  ),
                ],
              ),
            ],
          ),
          const SizedBox(height: 40),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            decoration: BoxDecoration(
              color: Colors.white.withOpacity(0.05),
              borderRadius: BorderRadius.circular(20),
              border: Border.all(color: Colors.white.withOpacity(0.1)),
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
              '₹0',
              style: Theme.of(context).textTheme.displayLarge?.copyWith(
                fontSize: 44,
                letterSpacing: -1,
              ),
            ),
            data: (transactions) {
              final total = _calculateBalance(transactions);
              return TweenAnimationBuilder<double>(
                tween: Tween(begin: 0, end: total),
                duration: const Duration(milliseconds: 850),
                builder: (context, value, _) => Text(
                  '₹${value.toStringAsFixed(0)}',
                  style: Theme.of(context).textTheme.displayLarge?.copyWith(
                    fontSize: 44,
                    letterSpacing: -1,
                    shadows: [
                      Shadow(
                        color: AppColors.primary.withOpacity(0.25),
                        blurRadius: 22,
                        offset: const Offset(-3, -4),
                      ),
                    ],
                  ),
                ),
              );
            },
          ),
          const SizedBox(height: 12),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
            decoration: BoxDecoration(
              color: AppColors.primary.withOpacity(0.1),
              borderRadius: BorderRadius.circular(16),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                const Icon(Icons.trending_up_rounded, size: 16, color: AppColors.primary),
                const SizedBox(width: 4),
                Text(
                  'Today Overview',
                  style: Theme.of(context).textTheme.labelLarge?.copyWith(
                    color: AppColors.primary,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 50),
          Container(
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(18),
              boxShadow: [
                BoxShadow(
                  color: AppColors.primary.withOpacity(0.12),
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
                      color: AppColors.primary.withOpacity(0.1),
                      shape: BoxShape.circle,
                    ),
                    child: const Icon(Icons.restaurant_rounded, color: AppColors.primary, size: 32),
                  ),
                  const SizedBox(height: 24),
                  Text(
                    'Smart Insight',
                    style: Theme.of(context).textTheme.headlineMedium,
                  ),
                  const SizedBox(height: 16),
                  Text(
                    'You spent 15% more on dining this week. Adjusting your weekend budget slightly can keep your monthly wealth goals on track.',
                    textAlign: TextAlign.center,
                    style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                      height: 1.5,
                    ),
                  ),
                  const SizedBox(height: 32),
                  Container(
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(12),
                      boxShadow: [
                        BoxShadow(
                          color: AppColors.primary.withOpacity(0.15),
                          blurRadius: 24,
                          offset: const Offset(-4, -6),
                        ),
                      ],
                    ),
                    child: CustomButton(
                      label: 'Review Budget',
                      onPressed: () {},
                    ),
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 40),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'Recent Transactions',
                style: Theme.of(context).textTheme.headlineMedium,
              ),
              TextButton(
                onPressed: () {},
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
            data: (transactions) => Column(
              children: transactions
                  .take(3)
                  .map((tx) => _buildRecentTransaction(context, tx))
                  .toList(),
            ),
          ),
        ],
      ),
    );
  }

  double _calculateBalance(List<TransactionModel> transactions) {
    return transactions.fold<double>(0, (sum, item) {
      if (item.type == TransactionType.income) return sum + item.amount;
      return sum - item.amount;
    });
  }

  Widget _buildRecentTransaction(BuildContext context, TransactionModel tx) {
    final isIncome = tx.type == TransactionType.income;
    final amountText = '${isIncome ? '+' : '-'}₹${tx.amount.toStringAsFixed(0)}';
    final subtitle = '${tx.category} • ${DateFormat('dd MMM, hh:mm a').format(tx.date)}';
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.03),
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: Colors.white.withOpacity(0.05)),
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: Colors.white.withOpacity(0.05),
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
