class WishModel {
  final String id;
  final String name;
  final double value;
  final String category;
  final String observation;
  final double savedAmount;
  final DateTime lastModified;

  WishModel({
    required this.id,
    required this.name,
    required this.value,
    required this.category,
    this.observation = '',
    this.savedAmount = 0.0,
    required this.lastModified,
  });

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'name': name,
      'value': value,
      'category': category,
      'observation': observation,
      'savedAmount': savedAmount,
      'lastModified': lastModified.toIso8601String(),
    };
  }

  factory WishModel.fromMap(Map<String, dynamic> map) {
    return WishModel(
      id: map['id'] ?? '',
      name: map['name'] ?? '',
      value: (map['value'] ?? 0.0).toDouble(),
      category: map['category'] ?? '',
      observation: map['observation'] ?? '',
      savedAmount: (map['savedAmount'] ?? 0.0).toDouble(),
      lastModified: map['lastModified'] != null
          ? DateTime.parse(map['lastModified'])
          : DateTime.now(),
    );
  }
}