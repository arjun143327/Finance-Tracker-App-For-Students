import 'package:hive_flutter/hive_flutter.dart';
import '../models/transaction_model.dart';
import '../models/budget_model.dart';

class StorageService {
  static const String transactionBoxName = 'transactions';
  static const String budgetBoxName = 'budgets';

  late Box<Transaction> _transactionBox;
  late Box<Budget> _budgetBox;

  Future<void> init() async {
    // Register Adapters
    Hive.registerAdapter(TransactionAdapter());
    Hive.registerAdapter(BudgetAdapter());

    // Open Boxes
    _transactionBox = await Hive.openBox<Transaction>(transactionBoxName);
    _budgetBox = await Hive.openBox<Budget>(budgetBoxName);
  }

  // --- Transactions ---

  List<Transaction> getTransactions() {
    return _transactionBox.values.toList();
  }

  Future<void> addTransaction(Transaction transaction) async {
    await _transactionBox.put(transaction.id, transaction);
  }

  Future<void> deleteTransaction(String id) async {
    await _transactionBox.delete(id);
  }
  
  // Clear all transactions (useful for debugging/reset)
  Future<void> clearTransactions() async {
    await _transactionBox.clear();
  }

  // --- Budget ---

  Budget? getBudget(String monthId) {
    return _budgetBox.get(monthId);
  }

  Future<void> saveBudget(Budget budget) async {
    await _budgetBox.put(budget.id, budget);
  }
}
