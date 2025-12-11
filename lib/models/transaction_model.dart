class TransactionModel {
  final String id;
  final String description;
  final double amount;
  final DateTime date;
  final String category;
  final String monthRef;
  final bool isRecurring;

  TransactionModel({
    required this.id,
    required this.description,
    required this.amount,
    required this.date,
    required this.category,
    required this.monthRef,
    this.isRecurring = false,
  });

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'description': description,
      'amount': amount,
      'date': date.toIso8601String(),
      'category': category,
      'monthRef': monthRef,
      'isRecurring': isRecurring,
    };
  }

  factory TransactionModel.fromMap(Map<String, dynamic> map) {
    return TransactionModel(
      id: map['id'] ?? '',
      description: map['description'] ?? '',
      amount: (map['amount'] ?? 0.0).toDouble(),
      date: DateTime.parse(map['date']),
      category: map['category'] ?? '',
      monthRef: map['monthRef'] ?? '',
      isRecurring: map['isRecurring'] ?? false,
    );
  }
}