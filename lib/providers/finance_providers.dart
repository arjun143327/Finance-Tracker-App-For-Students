import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import 'package:uuid/uuid.dart';

import '../data/local_db/storage_service.dart';
import '../data/models/transaction_model.dart';
import '../data/models/budget_model.dart';
import '../main.dart'; // Import to access global storageService

// Service Provider - uses the globally initialized instance
final storageServiceProvider = Provider<StorageService>((ref) {
  return storageService;
});

// --- Transactions State ---

class TransactionsNotifier extends StateNotifier<List<Transaction>> {
  final StorageService _storage;

  TransactionsNotifier(this._storage) : super([]) {
    _loadTransactions();
  }

  void _loadTransactions() {
    state = _storage.getTransactions();
    // Sort by date descending
    state.sort((a, b) => b.date.compareTo(a.date));
  }

  Future<void> addTransaction({
    required String title,
    required double amount,
    required String category,
    required String type,
    required DateTime date,
  }) async {
    final transaction = Transaction(
      id: const Uuid().v4(),
      title: title,
      amount: amount,
      category: category,
      type: type,
      date: date,
    );

    await _storage.addTransaction(transaction);
    _loadTransactions();
  }

  Future<void> deleteTransaction(String id) async {
    await _storage.deleteTransaction(id);
    _loadTransactions();
  }
}

final transactionsProvider = StateNotifierProvider<TransactionsNotifier, List<Transaction>>((ref) {
  final storage = ref.watch(storageServiceProvider);
  return TransactionsNotifier(storage);
});

// --- Budget State ---

class BudgetNotifier extends StateNotifier<Budget?> {
  final StorageService _storage;
  final String currentMonthId; // e.g. "2024_02"

  BudgetNotifier(this._storage) 
      : currentMonthId = DateFormat('yyyy_MM').format(DateTime.now()),
        super(null) {
    _loadBudget();
  }

  void _loadBudget() {
    state = _storage.getBudget(currentMonthId);
  }

  Future<void> setBudget(double amount, {Map<String, double>? categoryBudgets}) async {
    final budget = Budget(
      id: currentMonthId,
      totalBudget: amount,
      spent: 0,
      categoryBudgets: categoryBudgets ?? {},
    );
    await _storage.saveBudget(budget);
    state = budget;
  }
}

final budgetProvider = StateNotifierProvider<BudgetNotifier, Budget?>((ref) {
  final storage = ref.watch(storageServiceProvider);
  return BudgetNotifier(storage);
});

// --- Computed Summary ---

class FinancialSummary {
  final double income;
  final double expense;
  final double balance;
  final double budgetTotal;
  final double budgetSpent;
  final double budgetRemaining;
  final double dailyAverage;

  FinancialSummary({
    required this.income,
    required this.expense,
    required this.balance,
    required this.budgetTotal,
    required this.budgetSpent,
    required this.budgetRemaining,
    required this.dailyAverage,
  });
}

final summaryProvider = Provider<FinancialSummary>((ref) {
  final transactions = ref.watch(transactionsProvider);
  final budget = ref.watch(budgetProvider);

  double income = 0;
  double expense = 0;

  final now = DateTime.now();
  final currentMonthId = DateFormat('yyyy_MM').format(now);

  for (var tx in transactions) {
     final txMonth = DateFormat('yyyy_MM').format(tx.date);
     if (txMonth == currentMonthId) {
        if (tx.type == 'income') {
          income += tx.amount;
        } else {
          expense += tx.amount;
        }
     }
  }

  final totalBudget = budget?.totalBudget ?? 0.0;
  
  // Daily Average
  final dayOfMonth = now.day;
  final dailyAvg = dayOfMonth > 0 ? expense / dayOfMonth : 0.0;

  return FinancialSummary(
    income: income,
    expense: expense,
    balance: income - expense,
    budgetTotal: totalBudget,
    budgetSpent: expense,
    budgetRemaining: totalBudget - expense,
    dailyAverage: dailyAvg,
  );
});

// --- Category Spending ---

class CategorySpending {
  final String category;
  final double amount;
  final String emoji;
  final double categoryBudget; // Budget allocated to this category

  CategorySpending({
    required this.category,
    required this.amount,
    required this.emoji,
    required this.categoryBudget,
  });
}

final categorySpendingProvider = Provider<List<CategorySpending>>((ref) {
  final transactions = ref.watch(transactionsProvider);
  final budget = ref.watch(budgetProvider);
  
  final now = DateTime.now();
  final currentMonthId = DateFormat('yyyy_MM').format(now);
  
  // Define categories with their emojis
  final categoryMap = {
    'Food & Dining': '🍕',
    'Transport': '🚌',
    'Entertainment': '🎬',
    'Shopping': '🛍️',
    'Education': '📚',
    'Healthcare': '💊',
    'Books & Study': '📚',
    'Savings': '💰',
  };
  
  // Calculate spending by category for current month
  final Map<String, double> spendingByCategory = {};
  
  for (var tx in transactions) {
    final txMonth = DateFormat('yyyy_MM').format(tx.date);
    if (txMonth == currentMonthId && tx.type == 'expense') {
      spendingByCategory[tx.category] = 
          (spendingByCategory[tx.category] ?? 0.0) + tx.amount;
    }
  }
  
  // Get category budgets from budget
  final categoryBudgets = budget?.categoryBudgets ?? {};
  
  // Convert to CategorySpending list, only include categories with spending OR budget
  final result = <CategorySpending>[];
  final allCategories = {...spendingByCategory.keys, ...categoryBudgets.keys};
  
  for (var category in allCategories) {
    if (categoryMap.containsKey(category)) {
      final spending = spendingByCategory[category] ?? 0.0;
      final catBudget = categoryBudgets[category] ?? 0.0;
      
      // Only show if there's budget allocated OR there's spending
      if (catBudget > 0 || spending > 0) {
        result.add(CategorySpending(
          category: category,
          amount: spending,
          emoji: categoryMap[category]!,
          categoryBudget: catBudget,
        ));
      }
    }
  }
  
  // Sort by amount descending
  result.sort((a, b) => b.amount.compareTo(a.amount));
  
  return result;
});
// --- Analytics ---

class AnalyticsSummary {
  final double totalSpent;
  final double totalIncome;
  final double budgetLeft;
  final double dailyAverage;
  final double budgetPerDay;
  final List<CategorySpending> categoryBreakdown;
  final List<String> smartInsights;
  final Map<int, double> dailySpending; // day-of-month → amount
  final Map<String, double> dayOfWeekSpending; // 'Mon'→amount etc.
  final double prevMonthSpent;
  final String prevMonthName;
  final String currentMonthName;
  final double budgetTotal;

  AnalyticsSummary({
    required this.totalSpent,
    required this.totalIncome,
    required this.budgetLeft,
    required this.dailyAverage,
    required this.budgetPerDay,
    required this.categoryBreakdown,
    required this.smartInsights,
    required this.dailySpending,
    required this.dayOfWeekSpending,
    required this.prevMonthSpent,
    required this.prevMonthName,
    required this.currentMonthName,
    required this.budgetTotal,
  });
}

final analyticsProvider = Provider<AnalyticsSummary>((ref) {
  final transactions = ref.watch(transactionsProvider);
  final budget = ref.watch(budgetProvider);
  final categoryBreakdown = ref.watch(categorySpendingProvider);

  final now = DateTime.now();
  final currentMonthId = DateFormat('yyyy_MM').format(now);
  final prevMonth = DateTime(now.year, now.month - 1);
  final prevMonthId = DateFormat('yyyy_MM').format(prevMonth);

  double totalSpent = 0;
  double totalIncome = 0;
  double prevMonthSpent = 0;
  final Map<int, double> dailySpending = {};
  final Map<String, double> dayOfWeekSpending = {
    'Mon': 0, 'Tue': 0, 'Wed': 0, 'Thu': 0, 'Fri': 0, 'Sat': 0, 'Sun': 0,
  };
  final dayNames = ['Mon', 'Tue', 'Wed', 'Thu', 'Fri', 'Sat', 'Sun'];

  for (var tx in transactions) {
    final txMonth = DateFormat('yyyy_MM').format(tx.date);
    if (txMonth == currentMonthId) {
      if (tx.type == 'expense') {
        totalSpent += tx.amount;
        dailySpending[tx.date.day] = (dailySpending[tx.date.day] ?? 0) + tx.amount;
        // weekday: Monday=1, Sunday=7
        final dayName = dayNames[tx.date.weekday - 1];
        dayOfWeekSpending[dayName] = (dayOfWeekSpending[dayName] ?? 0) + tx.amount;
      } else {
        totalIncome += tx.amount;
      }
    } else if (txMonth == prevMonthId && tx.type == 'expense') {
      prevMonthSpent += tx.amount;
    }
  }

  final budgetTotal = budget?.totalBudget ?? 0;
  final budgetLeft = budgetTotal - totalSpent;
  final daysInMonth = DateUtils.getDaysInMonth(now.year, now.month);
  final budgetPerDay = budgetTotal > 0 ? budgetTotal / daysInMonth : 0.0;
  final dailyAverage = now.day > 0 ? totalSpent / now.day : 0.0;

  // Generate smart insights
  final insights = <String>[];
  if (totalSpent == 0) {
    insights.add('💡 No expenses recorded yet this month.');
  } else {
    // Category over-budget warning
    for (var cat in categoryBreakdown) {
      if (cat.categoryBudget > 0) {
        final pct = cat.amount / cat.categoryBudget;
        if (pct >= 0.9) {
          insights.add('⚠️ ${cat.category} at ${(pct * 100).toStringAsFixed(0)}% of budget!');
          break;
        }
      }
    }
    // Daily average vs budget
    if (budgetPerDay > 0) {
      if (dailyAverage < budgetPerDay * 0.8) {
        insights.add('✅ Great pace! Spending ₹${dailyAverage.toStringAsFixed(0)}/day vs ₹${budgetPerDay.toStringAsFixed(0)} budgeted.');
      } else if (dailyAverage > budgetPerDay) {
        insights.add('⚠️ Spending ₹${dailyAverage.toStringAsFixed(0)}/day — exceeds daily budget of ₹${budgetPerDay.toStringAsFixed(0)}!');
      }
    }
    // Compare to last month
    if (prevMonthSpent > 0) {
      final diff = ((totalSpent - prevMonthSpent) / prevMonthSpent * 100).abs();
      if (totalSpent < prevMonthSpent) {
        insights.add('📉 ${diff.toStringAsFixed(0)}% less spending than last month. Nice!');
      } else {
        insights.add('📈 ${diff.toStringAsFixed(0)}% more spending than last month.');
      }
    }
    // Top category
    if (categoryBreakdown.isNotEmpty) {
      final top = categoryBreakdown.first;
      final pct = totalSpent > 0 ? (top.amount / totalSpent * 100).toStringAsFixed(0) : '0';
      insights.add('${top.emoji} ${top.category} is your biggest spend at $pct% of total.');
    }
  }

  return AnalyticsSummary(
    totalSpent: totalSpent,
    totalIncome: totalIncome,
    budgetLeft: budgetLeft,
    dailyAverage: dailyAverage,
    budgetPerDay: budgetPerDay,
    categoryBreakdown: categoryBreakdown,
    smartInsights: insights,
    dailySpending: dailySpending,
    dayOfWeekSpending: dayOfWeekSpending,
    prevMonthSpent: prevMonthSpent,
    prevMonthName: DateFormat('MMMM').format(prevMonth),
    currentMonthName: DateFormat('MMMM').format(now),
    budgetTotal: budgetTotal,
  );
});
