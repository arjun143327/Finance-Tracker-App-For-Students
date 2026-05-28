import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../../data/models/transaction_model.dart';
import '../../data/models/category_model.dart';
import '../../data/models/user_profile_model.dart';
import 'package:flutter/material.dart' show Colors, Icons;

class DatabaseService {
  static final DatabaseService _instance = DatabaseService._internal();
  static Database? _database;
  static final List<Map<String, dynamic>> _webTransactionsStore = [];
  static Map<String, dynamic>? _webUserProfileStore;
  static int _webIdCounter = 0;

  factory DatabaseService() => _instance;

  DatabaseService._internal();

  Future<Database> get database async {
    if (_database != null) return _database!;
    _database = await _initDatabase();
    return _database!;
  }

  Future<void> initWeb() async {
    if (!kIsWeb) return;
    final prefs = await SharedPreferences.getInstance();
    
    final txString = prefs.getString('web_transactions');
    if (txString != null) {
      final List<dynamic> jsonList = jsonDecode(txString);
      _webTransactionsStore.clear();
      _webTransactionsStore.addAll(jsonList.cast<Map<String, dynamic>>());
      if (_webTransactionsStore.isNotEmpty) {
        _webIdCounter = _webTransactionsStore.map((e) => e['id'] as int).reduce((a, b) => a > b ? a : b);
      }
    }
    
    final upString = prefs.getString('web_user_profile');
    if (upString != null) {
      _webUserProfileStore = jsonDecode(upString);
    }
  }

  Future<void> _saveWebStore() async {
    if (!kIsWeb) return;
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('web_transactions', jsonEncode(_webTransactionsStore));
    if (_webUserProfileStore != null) {
      await prefs.setString('web_user_profile', jsonEncode(_webUserProfileStore));
    }
  }

  Future<Database> _initDatabase() async {
    if (kIsWeb) {
      throw UnsupportedError('Web uses in-memory fallback store.');
    }
    String path = join(await getDatabasesPath(), 'budgetrix.db');
    return await openDatabase(
      path,
      version: 5,
      onCreate: _onCreate,
      onUpgrade: _onUpgrade,
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
        type INTEGER,
        isRecurring INTEGER DEFAULT 0
      )
    ''');

    await db.execute('CREATE INDEX idx_transactions_date ON transactions(date)');

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

    await db.execute('''
      CREATE TABLE category_budgets(
        category TEXT PRIMARY KEY,
        amount REAL
      )
    ''');

    await db.execute('''
      CREATE TABLE user_profile(
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        name TEXT,
        balance REAL,
        income REAL,
        budget REAL,
        goal TEXT,
        onboarding_complete INTEGER,
        currency TEXT DEFAULT '₹'
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
      CategoryModel(name: 'Entertainment', icon: Icons.movie_rounded, color: Colors.pink),
      CategoryModel(name: 'Other', icon: Icons.category_rounded, color: Colors.grey),
    ];

    for (final cat in defaults) {
      await db.insert('categories', cat.toMap());
    }
  }

  Future<void> _onUpgrade(Database db, int oldVersion, int newVersion) async {
    if (oldVersion < 2) {
      // Add currency column to existing user_profile tables
      await db.execute("ALTER TABLE user_profile ADD COLUMN currency TEXT DEFAULT '₹'");
      // Add category_budgets table
      await db.execute('''
        CREATE TABLE IF NOT EXISTS category_budgets(
          category TEXT PRIMARY KEY,
          amount REAL
        )
      ''');
    }
    if (oldVersion < 3) {
      await db.execute("ALTER TABLE transactions ADD COLUMN isRecurring INTEGER DEFAULT 0");
    }
    if (oldVersion < 4) {
      // Add Entertainment category for users upgrading from earlier versions
      final existing = await db.query('categories', where: "name = 'Entertainment'");
      if (existing.isEmpty) {
        await db.insert('categories', CategoryModel(
          name: 'Entertainment',
          icon: Icons.movie_rounded,
          color: Colors.pink,
        ).toMap());
      }
    }
    if (oldVersion < 5) {
      // Add index to transactions.date to improve sorting performance
      await db.execute('CREATE INDEX IF NOT EXISTS idx_transactions_date ON transactions(date)');
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

  // --- Category Budget Methods ---

  Future<Map<String, double>> getCategoryBudgets() async {
    if (kIsWeb) return {};
    Database db = await database;
    final maps = await db.query('category_budgets');
    return {for (var m in maps) m['category'] as String: (m['amount'] as num).toDouble()};
  }

  Future<void> saveCategoryBudget(String category, double amount) async {
    if (kIsWeb) return;
    Database db = await database;
    await db.insert(
      'category_budgets',
      {'category': category, 'amount': amount},
      conflictAlgorithm: ConflictAlgorithm.replace,
    );
  }

  Future<int> insertTransaction(TransactionModel transaction) async {
    if (kIsWeb) {
      final map = transaction.toMap();
      _webIdCounter += 1;
      map['id'] = _webIdCounter;
      _webTransactionsStore.add(map);
      await _saveWebStore();
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
      await _saveWebStore();
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
      await _saveWebStore();
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

  // --- User Profile Methods ---

  Future<UserProfileModel?> getUserProfile() async {
    if (kIsWeb) {
      if (_webUserProfileStore != null) {
        return UserProfileModel.fromMap(_webUserProfileStore!);
      }
      return null;
    }
    Database db = await database;
    final List<Map<String, dynamic>> maps = await db.query('user_profile', limit: 1);
    if (maps.isEmpty) return null;
    return UserProfileModel.fromMap(maps.first);
  }

  Future<void> saveUserProfile(UserProfileModel profile) async {
    if (kIsWeb) {
      _webUserProfileStore = profile.toMap();
      await _saveWebStore();
      return;
    }
    Database db = await database;
    final existing = await db.query('user_profile');
    if (existing.isEmpty) {
      await db.insert('user_profile', profile.toMap());
    } else {
      await db.update('user_profile', profile.toMap());
    }
  }
}

