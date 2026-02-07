import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import 'providers/finance_providers.dart';
import 'theme/neo_colors.dart';

class TransactionHistoryScreen extends ConsumerStatefulWidget {
  const TransactionHistoryScreen({super.key});

  @override
  ConsumerState<TransactionHistoryScreen> createState() => _TransactionHistoryScreenState();
}

class _TransactionHistoryScreenState extends ConsumerState<TransactionHistoryScreen> {
  String selectedFilter = 'All';
  String currentMonth = 'January 2026';

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: NeoColors.cream,
      body: SafeArea(
        child: Column(
          children: [
            _buildTopBar(),
            Expanded(
              child: SingleChildScrollView(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const SizedBox(height: 16),
                    _buildMonthSummaryCard(),
                    const SizedBox(height: 16),
                    _buildFilterChips(),
                    const SizedBox(height: 24),
                    _buildTransactionList(),
                    const SizedBox(height: 24),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  // ... _buildTopBar ... (unchanged)

  Widget _buildTopBar() {
    return Container(
      height: 60,
      padding: const EdgeInsets.symmetric(horizontal: 16),
      decoration: const BoxDecoration(
        color: NeoColors.cream,
        border: Border(bottom: BorderSide(color: NeoColors.black, width: 2)),
      ),
      child: Row(
        children: [
          GestureDetector(
            onTap: () => Navigator.pop(context),
            child: Container(
              padding: const EdgeInsets.all(8),
              child: const Icon(Icons.arrow_back, size: 28, color: NeoColors.black),
            ),
          ),
          const Expanded(
            child: Text(
              'Transaction History',
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 22,
                fontWeight: FontWeight.w900,
                color: NeoColors.black,
              ),
            ),
          ),
          GestureDetector(
            onTap: () {
              // Show filter modal
            },
            child: Container(
              padding: const EdgeInsets.all(8),
              child: const Icon(Icons.filter_list, size: 24, color: NeoColors.black),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildMonthSummaryCard() {
    final transactions = ref.watch(transactionsProvider);
    double totalSpent = 0;
    
    for (var tx in transactions) {
      if (tx.type == 'expense') {
        if (selectedFilter == 'All' || tx.category == selectedFilter) {
           totalSpent += tx.amount;
        }
      }
    }

    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 24),
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: NeoColors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: NeoColors.black, width: 4),
        boxShadow: const [
          BoxShadow(
            color: NeoColors.black,
            offset: Offset(8, 8),
            blurRadius: 0,
          ),
        ],
      ),
      child: Row(
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    GestureDetector(
                      onTap: () {
                        // Previous month
                      },
                      child: const Icon(Icons.chevron_left, size: 20, color: NeoColors.darkGray),
                    ),
                    const SizedBox(width: 8),
                    Text(
                      currentMonth,
                      style: const TextStyle(
                        fontSize: 15,
                        fontWeight: FontWeight.w700,
                        color: NeoColors.darkGray,
                      ),
                    ),
                    const SizedBox(width: 8),
                    GestureDetector(
                      onTap: () {
                        // Next month
                      },
                      child: const Icon(Icons.chevron_right, size: 20, color: NeoColors.darkGray),
                    ),
                  ],
                ),
                const SizedBox(height: 12),
                Text(
                  'Total Spent: ₹${totalSpent.toStringAsFixed(0)}',
                  style: const TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.w900,
                    color: NeoColors.black,
                  ),
                ),
              ],
            ),
          ),
          Container(
            width: 50,
            height: 50,
            decoration: BoxDecoration(
              color: NeoColors.orange.withOpacity(0.1),
              shape: BoxShape.circle,
              border: Border.all(color: NeoColors.orange, width: 3),
            ),
            child: const Center(
              child: Icon(Icons.pie_chart, color: NeoColors.orange, size: 28),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildFilterChips() {
    final List<String> filters = ['All', 'Food', 'Transport', 'Income', 'Entertainment', 'Shopping', 'Education', 'Healthcare'];
    
    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      padding: const EdgeInsets.symmetric(horizontal: 24),
      child: Row(
        children: filters.map((filter) {
          final isSelected = selectedFilter == filter;
          return Padding(
            padding: const EdgeInsets.only(right: 8),
            child: GestureDetector(
              onTap: () {
                setState(() {
                  selectedFilter = filter;
                });
              },
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
                decoration: BoxDecoration(
                  color: isSelected ? NeoColors.orange : NeoColors.white,
                  borderRadius: BorderRadius.circular(20),
                  border: Border.all(color: NeoColors.black, width: 3),
                  boxShadow: [
                    BoxShadow(
                      color: NeoColors.black,
                      offset: Offset(isSelected ? 3 : 2, isSelected ? 3 : 2),
                      blurRadius: 0,
                    ),
                  ],
                ),
                child: Text(
                  filter,
                  style: TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w700,
                    color: isSelected ? NeoColors.white : NeoColors.black,
                  ),
                ),
              ),
            ),
          );
        }).toList(),
      ),
    );
  }

  Widget _buildTransactionList() {
    final transactions = ref.watch(transactionsProvider);
    
    // Group transactions by Date
    final Map<String, List<dynamic>> grouped = {};
    
    for (var tx in transactions) {
       // Filter first
       if (selectedFilter != 'All' && tx.category != selectedFilter) continue;
       if (selectedFilter == 'Income' && tx.type != 'income') continue; // Special case if Income acts as category

       final dateKey = DateFormat('MMM d').format(tx.date);
       if (grouped[dateKey] == null) grouped[dateKey] = [];
       grouped[dateKey]!.add(tx);
    }
    
    if (grouped.isEmpty) {
      return _buildEmptyState();
    }
    
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: grouped.entries.map((entry) {
        return _buildDateGroup(entry.key, entry.value);
      }).toList(),
    );
  }

  Widget _buildDateGroup(String date, List<dynamic> transactions) {
    double total = 0;
    for(var t in transactions) {
       if (t.type == 'expense') total += t.amount;
    }
    
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 8),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                date,
                style: const TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w700,
                  color: NeoColors.black,
                ),
              ),
              Text(
                'Expense: ₹${total.toStringAsFixed(0)}',
                style: const TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w600,
                  color: NeoColors.gray,
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: 8),
        ...transactions.map((transaction) {
          return Padding(
            padding: const EdgeInsets.only(bottom: 12, left: 24, right: 24),
            child: _buildTransactionCard(transaction),
          );
        }).toList(),
        const SizedBox(height: 8),
      ],
    );
  }

  Widget _buildTransactionCard(dynamic transaction) {
    final isPositive = transaction.type == 'income';
    final amount = transaction.amount;
    final title = transaction.title;
    final category = transaction.category;
    final time = DateFormat('h:mm a').format(transaction.date);
    
    // Icon selection logic
    String icon = "💰";
    if (category.startsWith("Food")) icon = "🍔";
    else if (category.startsWith("Transport")) icon = "🚌";
    else if (category.startsWith("Entertainment")) icon = "🎬";
    else if (category.startsWith("Shopping")) icon = "🛍️";
    else if (category.startsWith("Education")) icon = "📚";
    else if (category.startsWith("Healthcare")) icon = "💊";

    return Dismissible(
      key: Key(transaction.id), // Use ID
      background: Container(
        margin: const EdgeInsets.only(right: 4),
        padding: const EdgeInsets.symmetric(horizontal: 20),
        decoration: BoxDecoration(
          color: NeoColors.blue,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: NeoColors.black, width: 2),
        ),
        alignment: Alignment.centerLeft,
        child: const Icon(Icons.edit, color: NeoColors.white, size: 24),
      ),
      secondaryBackground: Container(
        margin: const EdgeInsets.only(left: 4),
        padding: const EdgeInsets.symmetric(horizontal: 20),
        decoration: BoxDecoration(
          color: NeoColors.red,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: NeoColors.black, width: 2),
        ),
        alignment: Alignment.centerRight,
        child: const Icon(Icons.delete, color: NeoColors.white, size: 24),
      ),
      confirmDismiss: (direction) async {
        if (direction == DismissDirection.startToEnd) {
          // Edit action
          // _showTransactionDetail(transaction);
          return false;
        } else {
          // Delete action
          final confirm = await _showDeleteConfirmation();
          if (confirm == true) {
             ref.read(transactionsProvider.notifier).deleteTransaction(transaction.id);
             return true;
          }
          return false;
        }
      },
      child: GestureDetector(
        onTap: () {
          // _showTransactionDetail(transaction);
        },
        child: Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: NeoColors.white,
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: NeoColors.black, width: 2),
            boxShadow: [
              BoxShadow(
                color: NeoColors.black.withOpacity(0.08),
                offset: const Offset(3, 3),
                blurRadius: 0,
              ),
            ],
          ),
          child: Row(
            children: [
              Text(icon, style: const TextStyle(fontSize: 24)),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      title,
                      style: const TextStyle(
                        fontWeight: FontWeight.w700,
                        fontSize: 16,
                        color: NeoColors.darkGray,
                      ),
                    ),
                    const SizedBox(height: 2),
                    Row(
                      children: [
                        Text(
                          category,
                          style: const TextStyle(
                            color: NeoColors.gray,
                            fontSize: 12,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                        const Text(' • ', style: TextStyle(color: NeoColors.gray)),
                        Text(
                          time,
                          style: const TextStyle(
                            color: NeoColors.gray,
                            fontSize: 12,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
              Text(
                '${isPositive ? '+' : '-'}₹${amount.toStringAsFixed(0)}',
                style: TextStyle(
                  fontWeight: FontWeight.w800,
                  fontSize: 16,
                  color: isPositive ? NeoColors.green : NeoColors.red,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildLoadMoreButton() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 24),
      child: GestureDetector(
        onTap: () {
          // Load more transactions
        },
        child: Container(
          height: 48,
          decoration: BoxDecoration(
            color: NeoColors.white,
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: NeoColors.black, width: 3),
            boxShadow: const [
              BoxShadow(
                color: NeoColors.black,
                offset: Offset(4, 4),
                blurRadius: 0,
              ),
            ],
          ),
          child: const Center(
            child: Text(
              'Load More',
              style: TextStyle(
                fontSize: 15,
                fontWeight: FontWeight.w800,
                color: NeoColors.black,
              ),
            ),
          ),
        ),
      ),
    );
  }

  void _showTransactionDetail(Map<String, dynamic> transaction) {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      isScrollControlled: true,
      builder: (context) => Container(
        padding: const EdgeInsets.all(24),
        decoration: const BoxDecoration(
          color: NeoColors.cream,
          borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
          border: Border(
            top: BorderSide(color: NeoColors.black, width: 4),
            left: BorderSide(color: NeoColors.black, width: 4),
            right: BorderSide(color: NeoColors.black, width: 4),
          ),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 40,
              height: 4,
              decoration: BoxDecoration(
                color: NeoColors.gray,
                borderRadius: BorderRadius.circular(2),
              ),
            ),
            const SizedBox(height: 24),
            Text(
              transaction['icon'],
              style: const TextStyle(fontSize: 48),
            ),
            const SizedBox(height: 16),
            Text(
              transaction['title'],
              style: const TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.w900,
                color: NeoColors.black,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              '${transaction['amount'] >= 0 ? '+' : '-'}₹${transaction['amount'].abs()}',
              style: TextStyle(
                fontSize: 32,
                fontWeight: FontWeight.w900,
                color: transaction['amount'] >= 0 ? NeoColors.green : NeoColors.red,
              ),
            ),
            const SizedBox(height: 24),
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: NeoColors.white,
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: NeoColors.black, width: 3),
              ),
              child: Column(
                children: [
                  _buildDetailRow('Category', transaction['category']),
                  const SizedBox(height: 12),
                  _buildDetailRow('Time', transaction['time']),
                  const SizedBox(height: 12),
                  _buildDetailRow('Payment Method', 'Cash'),
                ],
              ),
            ),
            const SizedBox(height: 24),
            Row(
              children: [
                Expanded(
                  child: GestureDetector(
                    onTap: () {
                      Navigator.pop(context);
                      // Edit transaction
                    },
                    child: Container(
                      height: 52,
                      decoration: BoxDecoration(
                        color: NeoColors.blue,
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(color: NeoColors.black, width: 3),
                        boxShadow: const [
                          BoxShadow(
                            color: NeoColors.black,
                            offset: Offset(4, 4),
                            blurRadius: 0,
                          ),
                        ],
                      ),
                      child: const Center(
                        child: Text(
                          'Edit',
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.w800,
                            color: NeoColors.white,
                          ),
                        ),
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: GestureDetector(
                    onTap: () async {
                      Navigator.pop(context);
                      final confirm = await _showDeleteConfirmation();
                      if (confirm == true) {
                        // Delete transaction
                      }
                    },
                    child: Container(
                      height: 52,
                      decoration: BoxDecoration(
                        color: NeoColors.red,
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(color: NeoColors.black, width: 3),
                        boxShadow: const [
                          BoxShadow(
                            color: NeoColors.black,
                            offset: Offset(4, 4),
                            blurRadius: 0,
                          ),
                        ],
                      ),
                      child: const Center(
                        child: Text(
                          'Delete',
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.w800,
                            color: NeoColors.white,
                          ),
                        ),
                      ),
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
          ],
        ),
      ),
    );
  }

  Widget _buildDetailRow(String label, String value) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          label,
          style: const TextStyle(
            fontSize: 14,
            color: NeoColors.gray,
            fontWeight: FontWeight.w600,
          ),
        ),
        Text(
          value,
          style: const TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.w700,
            color: NeoColors.black,
          ),
        ),
      ],
    );
  }

  Future<bool?> _showDeleteConfirmation() {
    return showDialog<bool>(
      context: context,
      builder: (context) => Dialog(
        backgroundColor: Colors.transparent,
        child: Container(
          padding: const EdgeInsets.all(24),
          decoration: BoxDecoration(
            color: NeoColors.white,
            borderRadius: BorderRadius.circular(16),
            border: Border.all(color: NeoColors.black, width: 4),
            boxShadow: const [
              BoxShadow(
                color: NeoColors.black,
                offset: Offset(8, 8),
                blurRadius: 0,
              ),
            ],
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Text(
                'Delete Transaction?',
                style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.w900,
                  color: NeoColors.black,
                ),
              ),
              const SizedBox(height: 12),
              const Text(
                'This action cannot be undone',
                style: TextStyle(
                  fontSize: 14,
                  color: NeoColors.gray,
                  fontWeight: FontWeight.w500,
                ),
              ),
              const SizedBox(height: 24),
              Row(
                children: [
                  Expanded(
                    child: GestureDetector(
                      onTap: () => Navigator.pop(context, false),
                      child: Container(
                        height: 48,
                        decoration: BoxDecoration(
                          color: NeoColors.white,
                          borderRadius: BorderRadius.circular(12),
                          border: Border.all(color: NeoColors.black, width: 3),
                        ),
                        child: const Center(
                          child: Text(
                            'Cancel',
                            style: TextStyle(
                              fontSize: 15,
                              fontWeight: FontWeight.w700,
                              color: NeoColors.black,
                            ),
                          ),
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: GestureDetector(
                      onTap: () => Navigator.pop(context, true),
                      child: Container(
                        height: 48,
                        decoration: BoxDecoration(
                          color: NeoColors.red,
                          borderRadius: BorderRadius.circular(12),
                          border: Border.all(color: NeoColors.black, width: 3),
                          boxShadow: const [
                            BoxShadow(
                              color: NeoColors.black,
                              offset: Offset(4, 4),
                              blurRadius: 0,
                            ),
                          ],
                        ),
                        child: const Center(
                          child: Text(
                            'Delete',
                            style: TextStyle(
                              fontSize: 15,
                              fontWeight: FontWeight.w800,
                              color: NeoColors.white,
                            ),
                          ),
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }



  // Empty state widget
  Widget _buildEmptyState() {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 60),
      child: Center(
        child: Column(
          children: [
            Container(
              width: 120,
              height: 120,
              decoration: BoxDecoration(
                color: NeoColors.gray.withOpacity(0.1),
                shape: BoxShape.circle,
                border: Border.all(color: NeoColors.black, width: 3),
              ),
              child: const Icon(
                Icons.receipt_long,
                size: 60,
                color: NeoColors.gray,
              ),
            ),
            const SizedBox(height: 24),
            const Text(
              'No transactions found',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.w700,
                color: NeoColors.black,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              'Try selecting a different filter',
              style: TextStyle(
                fontSize: 14,
                color: NeoColors.gray,
                fontWeight: FontWeight.w500,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
