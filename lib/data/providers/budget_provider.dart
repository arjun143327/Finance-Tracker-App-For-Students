import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import 'transaction_provider.dart';
import '../models/transaction_model.dart';
import '../../services/database/database_service.dart';

final monthlyBudgetProvider = StateNotifierProvider<BudgetNotifier, double>((ref) {
  final dbService = ref.watch(databaseServiceProvider);
  return BudgetNotifier(dbService);
});

class BudgetNotifier extends StateNotifier<double> {
  final DatabaseService _dbService;

  BudgetNotifier(this._dbService) : super(0.0) {
    loadBudget();
  }

  String get _currentMonth => DateFormat('yyyy-MM').format(DateTime.now());

  Future<void> loadBudget() async {
    double budget = await _dbService.getMonthlyBudget(_currentMonth);
    if (budget == 0.0) {
      final profile = await _dbService.getUserProfile();
      if (profile != null && profile.budget > 0) {
        budget = profile.budget;
        await _dbService.saveMonthlyBudget(_currentMonth, budget);
      }
    }
    state = budget;
  }

  Future<void> setBudget(double amount) async {
    await _dbService.saveMonthlyBudget(_currentMonth, amount);
    state = amount;
  }
}

final currentMonthTransactionsProvider = Provider<List<TransactionModel>>((ref) {
  final txState = ref.watch(transactionsListProvider);
  return txState.maybeWhen(
    data: (list) {
      final now = DateTime.now();
      return list.where((tx) => 
        tx.date.month == now.month && 
        tx.date.year == now.year &&
        tx.type == TransactionType.expense
      ).toList();
    },
    orElse: () => [],
  );
});

final currentMonthSpendingProvider = Provider<double>((ref) {
  final transactions = ref.watch(currentMonthTransactionsProvider);
  return transactions.fold(0, (sum, tx) => sum + tx.amount);
});

