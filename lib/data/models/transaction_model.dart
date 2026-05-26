enum TransactionType { income, expense }

class TransactionModel {
  final int? id;
  final String title;
  final String category;
  final double amount;
  final DateTime date;
  final String method;
  final TransactionType type;

  TransactionModel({
    this.id,
    required this.title,
    required this.category,
    required this.amount,
    required this.date,
    required this.method,
    required this.type,
  });

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'title': title,
      'category': category,
      'amount': amount,
      'date': date.toIso8601String(),
      'method': method,
      'type': type.index,
    };
  }

  factory TransactionModel.fromMap(Map<String, dynamic> map) {
    return TransactionModel(
      id: map['id'],
      title: map['title'],
      category: map['category'],
      amount: (map['amount'] as num).toDouble(),
      date: DateTime.parse(map['date']),
      method: map['method'],
      type: TransactionType.values[map['type']],
    );
  }
}

