enum TransactionType { income, expense }

class TransactionModel {
  final int? id;
  final String title;
  final String category;
  final double amount;
  final DateTime date;
  final String method;
  final TransactionType type;
  final bool isRecurring;

  TransactionModel({
    this.id,
    required this.title,
    required this.category,
    required this.amount,
    required this.date,
    required this.method,
    required this.type,
    this.isRecurring = false,
  });

  TransactionModel copyWith({
    int? id,
    String? title,
    String? category,
    double? amount,
    DateTime? date,
    String? method,
    TransactionType? type,
    bool? isRecurring,
  }) {
    return TransactionModel(
      id: id ?? this.id,
      title: title ?? this.title,
      category: category ?? this.category,
      amount: amount ?? this.amount,
      date: date ?? this.date,
      method: method ?? this.method,
      type: type ?? this.type,
      isRecurring: isRecurring ?? this.isRecurring,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'title': title,
      'category': category,
      'amount': amount,
      'date': date.toIso8601String(),
      'method': method,
      'type': type.index,
      'isRecurring': isRecurring ? 1 : 0,
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
      isRecurring: map['isRecurring'] == 1,
    );
  }
}

