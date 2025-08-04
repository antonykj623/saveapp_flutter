class BillDetails {
  final int? id;
  final String companyName;
  final String address;
  final String mobile;

  BillDetails({
    this.id,
    required this.companyName,
    required this.address,
    required this.mobile,
  });

  Map<String, dynamic> toJson() {
    return {
      'companyName': companyName,
      'address': address,
      'mobile': mobile,
    };
  }

  factory BillDetails.fromJson(Map<String, dynamic> json, {int? id}) {
    return BillDetails(
      id: id,
      companyName: json['companyName'] ?? '',
      address: json['address'] ?? '',
      mobile: json['mobile'] ?? '',
    );
  }
}