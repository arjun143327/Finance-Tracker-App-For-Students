import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../models/category_model.dart';
import 'transaction_provider.dart';
import '../../services/database/database_service.dart';

final categoryListProvider = StateNotifierProvider<CategoryNotifier, AsyncValue<List<CategoryModel>>>((ref) {
  final dbService = ref.watch(databaseServiceProvider);
  return CategoryNotifier(dbService);
});

class CategoryNotifier extends StateNotifier<AsyncValue<List<CategoryModel>>> {
  final DatabaseService _dbService;

  CategoryNotifier(this._dbService) : super(const AsyncValue.loading()) {
    loadCategories();
  }

  Future<void> loadCategories() async {
    state = const AsyncValue.loading();
    try {
      final categories = await _dbService.getCategories();
      state = AsyncValue.data(categories);
    } catch (e, st) {
      state = AsyncValue.error(e, st);
    }
  }

  Future<void> addCategory(CategoryModel category) async {
    try {
      await _dbService.insertCategory(category);
      await loadCategories();
    } catch (e, st) {
      state = AsyncValue.error(e, st);
    }
  }

  Future<void> removeCategory(int id) async {
    try {
      await _dbService.deleteCategory(id);
      await loadCategories();
    } catch (e, st) {
      state = AsyncValue.error(e, st);
    }
  }
}

