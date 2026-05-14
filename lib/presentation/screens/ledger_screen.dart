import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import '../../core/app_colors.dart';
import '../../data/models/transaction_model.dart';
import '../../data/providers/transaction_provider.dart';
import 'add_expense_screen.dart';

enum TransactionFilter { all, income, expense }

class LedgerScreen extends ConsumerStatefulWidget {
  const LedgerScreen({super.key});

  @override
  ConsumerState<LedgerScreen> createState() => _LedgerScreenState();
}

class _LedgerScreenState extends ConsumerState<LedgerScreen> {
  TransactionFilter _filter = TransactionFilter.all;

  @override
  Widget build(BuildContext context) {
    final state = ref.watch(transactionsListProvider);

    return SingleChildScrollView(
      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 60),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Transactions',
            style: Theme.of(context).textTheme.displayLarge?.copyWith(fontSize: 48),
          ),
          const SizedBox(height: 8),
          Text(
            'A chronological record of your financial movements.',
            style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                  color: AppColors.textSecondary,
                  height: 1.4,
                ),
          ),
          const SizedBox(height: 24),
          _buildFilters(context),
          const SizedBox(height: 24),
          state.when(
            loading: () => const Center(
              child: Padding(
                padding: EdgeInsets.all(30),
                child: CircularProgressIndicator(color: AppColors.primary),
              ),
            ),
            error: (error, _) => Text(
              'Unable to load transactions: $error',
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(color: AppColors.expense),
            ),
            data: (transactions) {
              final filtered = _applyFilter(transactions);
              if (filtered.isEmpty) {
                return Text(
                  'No transactions yet. Tap + to add your first expense.',
                  style: Theme.of(context).textTheme.bodyMedium,
                );
              }
              return Column(
                children: List.generate(
                  filtered.length,
                  (index) => TweenAnimationBuilder<double>(
                    tween: Tween(begin: 0, end: 1),
                    duration: Duration(milliseconds: 250 + (index * 80)),
                    builder: (context, value, child) => Opacity(
                      opacity: value,
                      child: Transform.translate(
                        offset: Offset(0, (1 - value) * 16),
                        child: child,
                      ),
                    ),
                    child: _buildTransactionTile(context, filtered[index]),
                  ),
                ),
              );
            },
          ),
        ],
      ),
    );
  }

  List<TransactionModel> _applyFilter(List<TransactionModel> transactions) {
    switch (_filter) {
      case TransactionFilter.income:
        return transactions.where((t) => t.type == TransactionType.income).toList();
      case TransactionFilter.expense:
        return transactions.where((t) => t.type == TransactionType.expense).toList();
      case TransactionFilter.all:
        return transactions;
    }
  }

  Widget _buildFilters(BuildContext context) {
    return Wrap(
      spacing: 10,
      children: [
        _filterChip(context, 'All', TransactionFilter.all),
        _filterChip(context, 'Income', TransactionFilter.income),
        _filterChip(context, 'Expenses', TransactionFilter.expense),
      ],
    );
  }

  Widget _filterChip(BuildContext context, String label, TransactionFilter value) {
    final isSelected = _filter == value;
    return InkWell(
      borderRadius: BorderRadius.circular(24),
      onTap: () => setState(() => _filter = value),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 9),
        decoration: BoxDecoration(
          color: isSelected ? AppColors.primary.withOpacity(0.16) : Colors.transparent,
          borderRadius: BorderRadius.circular(24),
          border: Border.all(
            color: isSelected ? AppColors.primary : Colors.white.withOpacity(0.1),
          ),
        ),
        child: Text(
          label,
          style: Theme.of(context).textTheme.labelLarge?.copyWith(
              color: isSelected ? AppColors.primary : AppColors.textSecondary,
          ),
        ),
      ),
    );
  }

  Widget _buildTransactionTile(BuildContext context, TransactionModel transaction) {
    final isIncome = transaction.type == TransactionType.income;
    final amountPrefix = isIncome ? '+' : '-';
    final amountColor = isIncome ? AppColors.income : AppColors.textPrimary;
    final dateText = DateFormat('dd MMM, hh:mm a').format(transaction.date);

    return Container(
      margin: const EdgeInsets.only(bottom: 14),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.03),
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: Colors.white.withOpacity(0.06)),
      ),
      child: Row(
        children: [
          Container(
            width: 42,
            height: 42,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: AppColors.primary.withOpacity(0.1),
            ),
            child: Icon(
              isIncome ? Icons.south_west_rounded : Icons.north_east_rounded,
              color: AppColors.primary,
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  transaction.title,
                  style: Theme.of(context).textTheme.bodyLarge?.copyWith(fontWeight: FontWeight.w600),
                ),
                const SizedBox(height: 3),
                Text(
                  '${transaction.category} • $dateText',
                  style: Theme.of(context).textTheme.bodySmall?.copyWith(color: AppColors.textSecondary),
                ),
              ],
            ),
          ),
          Column(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Text(
                '$amountPrefix₹${transaction.amount.toStringAsFixed(0)}',
                style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                      color: amountColor,
                      fontWeight: FontWeight.w700,
                    ),
              ),
              Text(
                transaction.method,
                style: Theme.of(context).textTheme.bodySmall,
              ),
            ],
          ),
          PopupMenuButton<String>(
            icon: const Icon(Icons.more_vert_rounded, color: AppColors.textMuted),
            onSelected: (value) async {
              if (value == 'edit') {
                await Navigator.of(context).push(
                  MaterialPageRoute(
                    builder: (_) => AddExpenseScreen(initialTransaction: transaction),
                  ),
                );
              }
              if (value == 'delete' && transaction.id != null) {
                await ref.read(transactionsListProvider.notifier).deleteTransaction(transaction.id!);
              }
            },
            itemBuilder: (context) => const [
              PopupMenuItem(value: 'edit', child: Text('Edit')),
              PopupMenuItem(value: 'delete', child: Text('Delete')),
            ],
          ),
        ],
      ),
    );
  }
}
