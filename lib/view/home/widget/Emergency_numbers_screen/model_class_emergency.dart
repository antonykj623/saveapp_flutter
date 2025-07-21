class EmergencyContact {
  final int? id;
  final String name;
  final String phoneNumber;
  final String? category;
  final bool isCustom;

  EmergencyContact({
    this.id,
    required this.name,
    required this.phoneNumber,
    this.category,
    this.isCustom = false,
  });

  Map<String, dynamic> toJson() {
    return {
      'name': name,
      'phoneNumber': phoneNumber,
      'category': category,
      'isCustom': isCustom,
    };
  }

  factory EmergencyContact.fromJson(Map<String, dynamic> json, {int? id}) {
    return EmergencyContact(
      id: id,
      name: json['name'],
      phoneNumber: json['phoneNumber'],
      category: json['category'],
      isCustom: json['isCustom'] ?? false,
    );
  }
}