import 'package:hive/hive.dart';

part 'budget_model.g.dart';

@HiveType(typeId: 1)
class Budget extends HiveObject {
  @HiveField(0)
  final String id; // Format: "YYYY_MM" e.g., "2026_01"

  @HiveField(1)
  final double totalBudget;

  @HiveField(2)
  final double spent; // Cache spent amount to avoid re-calculating always (optional, but good for quick access)

  @HiveField(3)
  final Map<String, double> categoryBudgets; // Per-category budgets

  Budget({
    required this.id,
    required this.totalBudget,
    this.spent = 0.0,
    this.categoryBudgets = const {},
  });
}
