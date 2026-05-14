import 'package:flutter/foundation.dart';
import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';
import '../../data/models/transaction_model.dart';
import '../../data/models/category_model.dart';
import 'package:flutter/material.dart' show Color, Colors, Icons, IconData;

class DatabaseService {
  static final DatabaseService _instance = DatabaseService._internal();
  static Database? _database;
  static final List<Map<String, dynamic>> _webTransactionsStore = [];
  static int _webIdCounter = 0;

  factory DatabaseService() => _instance;

  DatabaseService._internal();

  Future<Database> get database async {
    if (_database != null) return _database!;
    _database = await _initDatabase();
    return _database!;
  }

  Future<Database> _initDatabase() async {
    if (kIsWeb) {
      throw UnsupportedError('Web uses in-memory fallback store.');
    }
    String path = join(await getDatabasesPath(), 'budgetrix.db');
    return await openDatabase(
      path,
      version: 1,
      onCreate: _onCreate,
    );
  }

  Future<void> _onCreate(Database db, int version) async {
    await db.execute('''
      CREATE TABLE transactions(
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        title TEXT,
        category TEXT,
        amount REAL,
        date TEXT,
        method TEXT,
        type INTEGER
      )
    ''');

    await db.execute('''
      CREATE TABLE categories(
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        name TEXT UNIQUE,
        icon TEXT,
        color INTEGER
      )
    ''');

    await db.execute('''
      CREATE TABLE budgets(
        month TEXT PRIMARY KEY,
        amount REAL
      )
    ''');

    // Insert default categories with icons and colors
    final List<CategoryModel> defaults = [
      CategoryModel(name: 'Food', icon: Icons.restaurant_rounded, color: Colors.orange),
      CategoryModel(name: 'Transport', icon: Icons.directions_bus_rounded, color: Colors.blue),
      CategoryModel(name: 'Shopping', icon: Icons.shopping_bag_rounded, color: Colors.purple),
      CategoryModel(name: 'Bills', icon: Icons.receipt_long_rounded, color: Colors.red),
      CategoryModel(name: 'Health', icon: Icons.medical_services_rounded, color: Colors.green),
      CategoryModel(name: 'Education', icon: Icons.school_rounded, color: Colors.indigo),
      CategoryModel(name: 'Other', icon: Icons.category_rounded, color: Colors.grey),
    ];

    for (final cat in defaults) {
      await db.insert('categories', cat.toMap());
    }
  }

  // --- Category Methods ---

  Future<List<CategoryModel>> getCategories() async {
    if (kIsWeb) {
      return [
        CategoryModel(name: 'Food', icon: Icons.restaurant_rounded, color: Colors.orange),
        CategoryModel(name: 'Transport', icon: Icons.directions_bus_rounded, color: Colors.blue),
        CategoryModel(name: 'Shopping', icon: Icons.shopping_bag_rounded, color: Colors.purple),
        CategoryModel(name: 'Bills', icon: Icons.receipt_long_rounded, color: Colors.red),
        CategoryModel(name: 'Health', icon: Icons.medical_services_rounded, color: Colors.green),
        CategoryModel(name: 'Education', icon: Icons.school_rounded, color: Colors.indigo),
        CategoryModel(name: 'Other', icon: Icons.category_rounded, color: Colors.grey),
      ];
    }
    Database db = await database;
    final List<Map<String, dynamic>> maps = await db.query('categories');
    return maps.map(CategoryModel.fromMap).toList();
  }

  Future<int> insertCategory(CategoryModel category) async {
    if (kIsWeb) return 0;
    Database db = await database;
    return await db.insert('categories', category.toMap(), conflictAlgorithm: ConflictAlgorithm.ignore);
  }

  Future<int> deleteCategory(int id) async {
    if (kIsWeb) return 0;
    Database db = await database;
    return await db.delete('categories', where: 'id = ?', whereArgs: [id]);
  }

  // --- Budget Methods ---

  Future<double> getMonthlyBudget(String month) async {
    if (kIsWeb) return 20000.0;
    Database db = await database;
    final List<Map<String, dynamic>> maps = await db.query(
      'budgets',
      where: 'month = ?',
      whereArgs: [month],
    );
    if (maps.isEmpty) return 0.0;
    return maps.first['amount'] as double;
  }

  Future<void> saveMonthlyBudget(String month, double amount) async {
    if (kIsWeb) return;
    Database db = await database;
    await db.insert(
      'budgets',
      {'month': month, 'amount': amount},
      conflictAlgorithm: ConflictAlgorithm.replace,
    );
  }

  Future<int> insertTransaction(TransactionModel transaction) async {
    if (kIsWeb) {
      final map = transaction.toMap();
      _webIdCounter += 1;
      map['id'] = _webIdCounter;
      _webTransactionsStore.add(map);
      return _webIdCounter;
    }
    Database db = await database;
    return await db.insert('transactions', transaction.toMap());
  }

  Future<List<TransactionModel>> getTransactions() async {
    if (kIsWeb) {
      final copied = List<Map<String, dynamic>>.from(_webTransactionsStore);
      copied.sort((a, b) => (b['date'] as String).compareTo(a['date'] as String));
      return copied.map(TransactionModel.fromMap).toList();
    }
    Database db = await database;
    final List<Map<String, dynamic>> maps = await db.query('transactions', orderBy: 'date DESC');
    return List.generate(maps.length, (i) {
      return TransactionModel.fromMap(maps[i]);
    });
  }

  Future<int> deleteTransaction(int id) async {
    if (kIsWeb) {
      _webTransactionsStore.removeWhere((item) => item['id'] == id);
      return 1;
    }
    Database db = await database;
    return await db.delete('transactions', where: 'id = ?', whereArgs: [id]);
  }

  Future<int> updateTransaction(TransactionModel transaction) async {
    if (kIsWeb) {
      final index = _webTransactionsStore.indexWhere((item) => item['id'] == transaction.id);
      if (index == -1) return 0;
      _webTransactionsStore[index] = transaction.toMap();
      return 1;
    }
    Database db = await database;
    return await db.update(
      'transactions',
      transaction.toMap(),
      where: 'id = ?',
      whereArgs: [transaction.id],
    );
  }
}
