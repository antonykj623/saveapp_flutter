
class Dream {
  int? id; 
  String name;
  String category;
  String investment;
  double closingBalance;
  double addedAmount;
  double savedAmount;
  double targetAmount;
  DateTime targetDate;
  String notes;

  Dream({
    this.id, 
    required this.name,
    required this.category,
    required this.investment,
    this.closingBalance = 0.0,
    this.addedAmount = 0.0,
    required this.savedAmount,
    required this.targetAmount,
    required this.targetDate,
    required this.notes,
  });

  double get progressPercentage {
    if (targetAmount <= 0) return 0.0;
    return (savedAmount / targetAmount) * 100;
  }

  // Add the copyWith method
  Dream copyWith({
    int? id,
    String? name,
    String? category,
    String? investment,
    double? closingBalance,
    double? addedAmount,
    double? savedAmount,
    double? targetAmount,
    DateTime? targetDate,
    String? notes,
  }) {
    return Dream(
      id: id ?? this.id,
      name: name ?? this.name,
      category: category ?? this.category,
      investment: investment ?? this.investment,
      closingBalance: closingBalance ?? this.closingBalance,
      addedAmount: addedAmount ?? this.addedAmount,
      savedAmount: savedAmount ?? this.savedAmount,
      targetAmount: targetAmount ?? this.targetAmount,
      targetDate: targetDate ?? this.targetDate,
      notes: notes ?? this.notes,
    );
  }

  // Convert Dream to JSON for database storage
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'category': category,
      'investment': investment,
      'closingBalance': closingBalance,
      'addedAmount': addedAmount,
      'savedAmount': savedAmount,
      'targetAmount': targetAmount,
      'targetDate': targetDate.toIso8601String(),
      'notes': notes,
    };
  }

  // Create Dream from JSON
  factory Dream.fromJson(Map<String, dynamic> json) {
    return Dream(
      id: json['id'],
      name: json['name'] ?? '',
      category: json['category'] ?? '',
      investment: json['investment'] ?? 'My Saving',
      closingBalance: json['closingBalance']?.toDouble() ?? 0.0,
      addedAmount: json['addedAmount']?.toDouble() ?? 0.0,
      savedAmount: json['savedAmount']?.toDouble() ?? 0.0,
      targetAmount: json['targetAmount']?.toDouble() ?? 0.0,
      targetDate: DateTime.parse(json['targetDate']),
      notes: json['notes'] ?? '',
    );
  }

  // Optional: Add toString method for debugging
  @override
  String toString() {
    return 'Dream(id: $id, name: $name, category: $category, investment: $investment, closingBalance: $closingBalance, addedAmount: $addedAmount, savedAmount: $savedAmount, targetAmount: $targetAmount, targetDate: $targetDate, notes: $notes)';
  }

  // Optional: Add equality operators
  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is Dream &&
        other.id == id &&
        other.name == name &&
        other.category == category &&
        other.investment == investment &&
        other.closingBalance == closingBalance &&
        other.addedAmount == addedAmount &&
        other.savedAmount == savedAmount &&
        other.targetAmount == targetAmount &&
        other.targetDate == targetDate &&
        other.notes == notes;
  }

  @override
  int get hashCode {
    return id.hashCode ^
        name.hashCode ^
        category.hashCode ^
        investment.hashCode ^
        closingBalance.hashCode ^
        addedAmount.hashCode ^
        savedAmount.hashCode ^
        targetAmount.hashCode ^
        targetDate.hashCode ^
        notes.hashCode;
  }
}
 