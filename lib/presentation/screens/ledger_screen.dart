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
  final TextEditingController _searchController = TextEditingController();
  String _searchQuery = '';

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

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
          _buildSearchField(context),
          const SizedBox(height: 20),
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
              // Group by date string
              final Map<String, List<TransactionModel>> grouped = {};
              for (final t in filtered) {
                final now = DateTime.now();
                final today = DateTime(now.year, now.month, now.day);
                final yesterday = today.subtract(const Duration(days: 1));
                final txDate = DateTime(t.date.year, t.date.month, t.date.day);
                
                String header;
                if (txDate == today) {
                  header = 'Today';
                } else if (txDate == yesterday) {
                  header = 'Yesterday';
                } else {
                  header = DateFormat('dd MMM, yyyy').format(t.date);
                }
                
                grouped.putIfAbsent(header, () => []).add(t);
              }

              int tileIndex = 0;
              return Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: grouped.entries.map((entry) {
                  return Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Padding(
                        padding: const EdgeInsets.only(top: 16, bottom: 12),
                        child: Text(
                          entry.key,
                          style: Theme.of(context).textTheme.labelLarge?.copyWith(
                            color: AppColors.textSecondary,
                            letterSpacing: 1.2,
                          ),
                        ),
                      ),
                      ...entry.value.map((tx) {
                        final idx = tileIndex++;
                        return TweenAnimationBuilder<double>(
                          tween: Tween(begin: 0.0, end: 1.0),
                          duration: Duration(milliseconds: 250 + (idx * 50)),
                          builder: (context, value, child) => Opacity(
                            opacity: value,
                            child: Transform.translate(
                              offset: Offset(0, (1 - value) * 16),
                              child: child,
                            ),
                          ),
                          child: _buildTransactionTile(context, tx),
                        );
                      }),
                    ],
                  );
                }).toList(),
              );
            },
          ),
        ],
      ),
    );
  }

  List<TransactionModel> _applyFilter(List<TransactionModel> transactions) {
    List<TransactionModel> filtered = transactions;

    // Type Filter
    if (_filter == TransactionFilter.income) {
      filtered = filtered.where((t) => t.type == TransactionType.income).toList();
    } else if (_filter == TransactionFilter.expense) {
      filtered = filtered.where((t) => t.type == TransactionType.expense).toList();
    }

    // Search Filter
    if (_searchQuery.isNotEmpty) {
      filtered = filtered.where((t) => 
        t.title.toLowerCase().contains(_searchQuery.toLowerCase()) ||
        t.category.toLowerCase().contains(_searchQuery.toLowerCase())
      ).toList();
    }

    return filtered;
  }

  Widget _buildSearchField(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.03),
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: Colors.white.withValues(alpha: 0.06)),
      ),
      child: TextField(
        controller: _searchController,
        onChanged: (value) => setState(() => _searchQuery = value),
        style: Theme.of(context).textTheme.bodyLarge,
        decoration: InputDecoration(
          hintText: 'Search transactions...',
          hintStyle: Theme.of(context).textTheme.bodyLarge?.copyWith(color: AppColors.textMuted),
          prefixIcon: const Icon(Icons.search_rounded, color: AppColors.textMuted),
          suffixIcon: _searchQuery.isNotEmpty 
            ? IconButton(
                icon: const Icon(Icons.close_rounded, size: 20),
                onPressed: () {
                  _searchController.clear();
                  setState(() => _searchQuery = '');
                },
              ) 
            : null,
          border: InputBorder.none,
          contentPadding: const EdgeInsets.symmetric(vertical: 15),
        ),
      ),
    );
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
          color: isSelected ? AppColors.primary.withValues(alpha: 0.16) : Colors.transparent,
          borderRadius: BorderRadius.circular(24),
          border: Border.all(
            color: isSelected ? AppColors.primary : Colors.white.withValues(alpha: 0.1),
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

    return Dismissible(
      key: Key(transaction.id?.toString() ?? transaction.date.toIso8601String()),
      direction: DismissDirection.endToStart,
      background: Container(
        margin: const EdgeInsets.only(bottom: 14),
        padding: const EdgeInsets.only(right: 20),
        alignment: Alignment.centerRight,
        decoration: BoxDecoration(
          color: AppColors.expense.withValues(alpha: 0.2),
          borderRadius: BorderRadius.circular(18),
        ),
        child: const Icon(Icons.delete_outline_rounded, color: AppColors.expense),
      ),
      onDismissed: (_) {
        if (transaction.id != null) {
          ref.read(transactionsListProvider.notifier).deleteTransaction(transaction.id!);
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('"${transaction.title}" deleted'),
              backgroundColor: AppColors.bgGradientEnd,
              behavior: SnackBarBehavior.floating,
              action: SnackBarAction(
                label: 'Undo',
                textColor: AppColors.primary,
                onPressed: () {
                  ref.read(transactionsListProvider.notifier).addTransaction(transaction);
                },
              ),
            ),
          );
        }
      },
      child: Container(
        margin: const EdgeInsets.only(bottom: 14),
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: Colors.white.withValues(alpha: 0.03),
          borderRadius: BorderRadius.circular(18),
          border: Border.all(color: Colors.white.withValues(alpha: 0.06)),
        ),
        child: Row(
          children: [
            Container(
              width: 42,
              height: 42,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: AppColors.primary.withValues(alpha: 0.1),
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
      ),
    );
  }
}

