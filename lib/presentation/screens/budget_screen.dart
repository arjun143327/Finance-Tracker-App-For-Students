import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../core/app_colors.dart';
import '../../data/providers/budget_provider.dart';
import '../../data/providers/category_provider.dart';
import '../../data/providers/currency_budget_provider.dart';
import '../widgets/glass_card.dart';

class BudgetScreen extends ConsumerWidget {
  const BudgetScreen({super.key});

  // --- Dialogs ---

  void _showSetCategoryBudgetDialog(
    BuildContext context,
    WidgetRef ref,
    String category,
    double current,
    String currency,
  ) {
    final controller = TextEditingController(
      text: current > 0 ? current.toStringAsFixed(0) : '',
    );
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: AppColors.bgGradientEnd,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(18)),
        title: Text(
          'Set limit for $category',
          style: GoogleFonts.cormorantGaramond(
            color: AppColors.textPrimary,
            fontSize: 22,
            fontWeight: FontWeight.w400,
            fontStyle: FontStyle.italic,
          ),
        ),
        content: TextField(
          controller: controller,
          keyboardType: TextInputType.number,
          autofocus: true,
          style: GoogleFonts.lato(color: AppColors.textPrimary, fontSize: 22),
          decoration: InputDecoration(
            hintText: '0',
            prefixText: '$currency ',
            prefixStyle: GoogleFonts.cormorantGaramond(
              color: AppColors.primary,
              fontSize: 22,
            ),
            hintStyle: GoogleFonts.lato(
              color: AppColors.textSecondary.withValues(alpha: 0.4),
            ),
            enabledBorder: const UnderlineInputBorder(
              borderSide: BorderSide(color: AppColors.primary, width: 1),
            ),
            focusedBorder: const UnderlineInputBorder(
              borderSide: BorderSide(color: AppColors.primaryLight, width: 2),
            ),
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: Text(
              'Cancel',
              style: GoogleFonts.lato(color: AppColors.textMuted),
            ),
          ),
          TextButton(
            onPressed: () {
              final amount = double.tryParse(controller.text.trim()) ?? 0;
              ref.read(categoryBudgetsProvider.notifier)
                  .setBudgetForCategory(category, amount);
              Navigator.pop(ctx);
            },
            child: Text(
              'Save',
              style: GoogleFonts.lato(
                color: AppColors.primary,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final totalSpent = ref.watch(currentMonthSpendingProvider);
    final transactions = ref.watch(currentMonthTransactionsProvider);
    final categoryBudgets = ref.watch(categoryBudgetsProvider);
    final currency = ref.watch(currencySymbolProvider);
    final categoriesState = ref.watch(categoryListProvider);

    // Group current month spending by category
    final categorySpending = <String, double>{};
    for (final tx in transactions) {
      categorySpending[tx.category] =
          (categorySpending[tx.category] ?? 0) + tx.amount;
    }

    // All user-defined categories (master list) — always shown regardless of spending
    final definedCategories = categoriesState.maybeWhen(
      data: (cats) => cats.map((c) => c.name).toSet(),
      orElse: () => <String>{},
    );

    // Merge: defined categories + any with spending + any with a saved budget
    final allCategories = {
      ...definedCategories,
      ...categorySpending.keys,
      ...categoryBudgets.keys,
    }.toList()
      ..sort();

    final totalBudgeted = categoryBudgets.values.fold(0.0, (a, b) => a + b);

    return SingleChildScrollView(
      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 60),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // --- Header ---
          Text(
            'Budget',
            style: Theme.of(context).textTheme.displayLarge,
          ),
          const SizedBox(height: 8),
          Text(
            'Set limits per category and track your spending.',
            style: GoogleFonts.lato(
              color: AppColors.textSecondary,
              fontSize: 14,
              fontWeight: FontWeight.w300,
            ),
          ),
          const SizedBox(height: 24),

          // --- Overview Summary Card ---
          if (totalBudgeted > 0) ...[
            _BudgetOverviewCard(
              currency: currency,
              totalBudgeted: totalBudgeted,
              totalSpent: totalSpent,
            ),
            const SizedBox(height: 32),
          ],

          // --- Section title ---
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'Categories',
                style: Theme.of(context).textTheme.headlineMedium,
              ),
              Text(
                'Tap to set limit',
                style: GoogleFonts.lato(
                  color: AppColors.textMuted,
                  fontSize: 11,
                  fontWeight: FontWeight.w300,
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),

          // --- Empty state ---
          if (allCategories.isEmpty)
            Padding(
              padding: const EdgeInsets.symmetric(vertical: 40),
              child: Center(
                child: Column(
                  children: [
                    const Icon(Icons.tune_rounded, color: AppColors.primary, size: 36),
                    const SizedBox(height: 12),
                     Text(
                      'No categories found.',
                      style: GoogleFonts.cormorantGaramond(
                        color: AppColors.textSecondary,
                        fontSize: 18,
                        fontStyle: FontStyle.italic,
                      ),
                    ),
                    const SizedBox(height: 6),
                    Text(
                      'Go to Settings → Manage Categories to add some.',
                      style: GoogleFonts.lato(
                        color: AppColors.textMuted,
                        fontSize: 12,
                        fontWeight: FontWeight.w300,
                      ),
                    ),
                  ],
                ),
              ),
            )
          else
            ...allCategories.map((category) {
              final spent = categorySpending[category] ?? 0.0;
              final limit = categoryBudgets[category] ?? 0.0;
              return Padding(
                padding: const EdgeInsets.only(bottom: 14),
                child: _CategoryBudgetTile(
                  category: category,
                  spent: spent,
                  limit: limit,
                  currency: currency,
                  onTap: () => _showSetCategoryBudgetDialog(
                    context,
                    ref,
                    category,
                    limit,
                    currency,
                  ),
                ),
              );
            }),
        ],
      ),
    );
  }
}

// --- Overview Summary Card ---

class _BudgetOverviewCard extends StatelessWidget {
  final String currency;
  final double totalBudgeted;
  final double totalSpent;

  const _BudgetOverviewCard({
    required this.currency,
    required this.totalBudgeted,
    required this.totalSpent,
  });

  @override
  Widget build(BuildContext context) {
    final usage = totalBudgeted > 0
        ? (totalSpent / totalBudgeted).clamp(0.0, 1.0)
        : 0.0;
    final isOverLimit = totalSpent > totalBudgeted;
    final isNearLimit = usage >= 0.85 && !isOverLimit;

    Color statusColor = AppColors.primary;
    if (isNearLimit) statusColor = AppColors.warning;
    if (isOverLimit) statusColor = AppColors.expense;

    return Container(
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(18),
        boxShadow: [
          BoxShadow(
            color: statusColor.withValues(alpha: 0.12),
            blurRadius: 26,
            offset: const Offset(-4, -6),
          ),
        ],
      ),
      child: GlassCard(
        interactive: false,
        borderColor: isOverLimit ? AppColors.expense.withValues(alpha: 0.3) : null,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  'Monthly Overview',
                  style: Theme.of(context).textTheme.headlineMedium,
                ),
                if (isOverLimit)
                  const Icon(Icons.warning_amber_rounded,
                      color: AppColors.expense, size: 22)
                else if (isNearLimit)
                  const Icon(Icons.info_outline_rounded,
                      color: AppColors.warning, size: 22),
              ],
            ),
            const SizedBox(height: 14),
            Text(
              '$currency${totalSpent.toStringAsFixed(0)} / $currency${totalBudgeted.toStringAsFixed(0)} used',
              style: GoogleFonts.lato(
                color: isOverLimit ? AppColors.expense : AppColors.textPrimary,
                fontSize: 15,
                fontWeight: isOverLimit ? FontWeight.w600 : FontWeight.w300,
              ),
            ),
            const SizedBox(height: 12),
            ClipRRect(
              borderRadius: BorderRadius.circular(100),
              child: LinearProgressIndicator(
                value: usage,
                minHeight: 10,
                backgroundColor: Colors.white.withValues(alpha: 0.08),
                valueColor: AlwaysStoppedAnimation<Color>(statusColor),
              ),
            ),
            const SizedBox(height: 12),
            Text(
              isOverLimit
                  ? 'Over budget by $currency${(totalSpent - totalBudgeted).toStringAsFixed(0)}'
                  : 'Remaining: $currency${(totalBudgeted - totalSpent).clamp(0, double.infinity).toStringAsFixed(0)}',
              style: GoogleFonts.lato(
                color: isOverLimit ? AppColors.expense : AppColors.primaryLight,
                fontSize: 12,
                fontWeight: FontWeight.w500,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// --- Per-Category Tile ---

class _CategoryBudgetTile extends StatelessWidget {
  final String category;
  final double spent;
  final double limit;
  final String currency;
  final VoidCallback onTap;

  const _CategoryBudgetTile({
    required this.category,
    required this.spent,
    required this.limit,
    required this.currency,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final hasLimit = limit > 0;
    final ratio = hasLimit ? (spent / limit).clamp(0.0, 1.3) : 0.0;
    final isNearLimit = hasLimit && ratio >= 0.85 && ratio <= 1.0;
    final isOverLimit = hasLimit && ratio > 1.0;

    String statusLabel = hasLimit ? 'On track' : 'No limit set';
    Color statusColor = hasLimit ? AppColors.income : AppColors.textMuted;
    if (isNearLimit) {
      statusLabel = 'Near limit';
      statusColor = AppColors.warning;
    }
    if (isOverLimit) {
      statusLabel = 'Exceeded';
      statusColor = AppColors.expense;
    }

    return GestureDetector(
      onTap: onTap,
      child: GlassCard(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Expanded(
                  child: Text(
                    category,
                    style: GoogleFonts.cormorantGaramond(
                      color: AppColors.textPrimary,
                      fontSize: 20,
                      fontWeight: FontWeight.w400,
                    ),
                  ),
                ),
                Row(
                  children: [
                    Text(
                      statusLabel,
                      style: GoogleFonts.lato(
                        color: statusColor,
                        fontSize: 11,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                    const SizedBox(width: 8),
                    const Icon(
                      Icons.edit_outlined,
                      color: AppColors.textMuted,
                      size: 14,
                    ),
                  ],
                ),
              ],
            ),
            const SizedBox(height: 8),
            Text(
              hasLimit
                  ? '$currency${spent.toStringAsFixed(0)} of $currency${limit.toStringAsFixed(0)}'
                  : '$currency${spent.toStringAsFixed(0)} spent — tap to set a limit',
              style: GoogleFonts.lato(
                color: AppColors.textSecondary,
                fontSize: 12,
                fontWeight: FontWeight.w300,
              ),
            ),
            if (hasLimit) ...[
              const SizedBox(height: 10),
              ClipRRect(
                borderRadius: BorderRadius.circular(100),
                child: LinearProgressIndicator(
                  value: ratio > 1 ? 1.0 : ratio,
                  minHeight: 6,
                  backgroundColor: Colors.white.withValues(alpha: 0.07),
                  valueColor: AlwaysStoppedAnimation<Color>(
                    isOverLimit ? AppColors.expense : AppColors.primary,
                  ),
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }
}


