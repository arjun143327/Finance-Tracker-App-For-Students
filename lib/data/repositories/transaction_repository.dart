import '../../services/database/database_service.dart';
import '../models/transaction_model.dart';

class TransactionRepository {
  final DatabaseService _dbService;

  TransactionRepository(this._dbService);

  Future<List<TransactionModel>> getAllTransactions() async {
    return await _dbService.getTransactions();
  }

  Future<void> addTransaction(TransactionModel transaction) async {
    await _dbService.insertTransaction(transaction);
  }

  Future<void> removeTransaction(int id) async {
    await _dbService.deleteTransaction(id);
  }

  Future<void> updateTransaction(TransactionModel transaction) async {
    await _dbService.updateTransaction(transaction);
  }
}
