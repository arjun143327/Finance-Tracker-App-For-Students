import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'transaction_provider.dart';
import 'user_provider.dart';
import '../../services/database/database_service.dart';

// --- Currency Provider ---
// Reads currency from the loaded user profile. Falls back to '₹'.
final currencySymbolProvider = Provider<String>((ref) {
  final profileState = ref.watch(userProfileProvider);
  return profileState.valueOrNull?.currency ?? '\u20b9';
});

// --- Category Budget Provider ---
// Map of category name -> budget amount (0.0 means no limit set)
final categoryBudgetsProvider =
    StateNotifierProvider<CategoryBudgetNotifier, Map<String, double>>((ref) {
  final dbService = ref.watch(databaseServiceProvider);
  return CategoryBudgetNotifier(dbService);
});

class CategoryBudgetNotifier extends StateNotifier<Map<String, double>> {
  final DatabaseService _dbService;

  CategoryBudgetNotifier(this._dbService) : super({}) {
    _load();
  }

  Future<void> _load() async {
    final budgets = await _dbService.getCategoryBudgets();
    state = Map<String, double>.from(budgets);
  }

  Future<void> setBudgetForCategory(String category, double amount) async {
    await _dbService.saveCategoryBudget(category, amount);
    state = {...state, category: amount};
  }

  double getLimit(String category) => state[category] ?? 0.0;

  bool hasLimit(String category) => (state[category] ?? 0.0) > 0;
}

