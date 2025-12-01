// // File: pack_list_entity.dart
// // This is the ONLY correct version that works with your DTHPlansScreen

// class PackListEntity {
//   String? status;
//   List<PackListPacks>? packs;

//   PackListEntity({this.status, this.packs});

//   factory PackListEntity.fromJson(Map<String, dynamic> json) {
//     return PackListEntity(
//       status: json['status'] as String?,
//       packs: json['packs'] == null
//           ? null
//           : (json['packs'] as List)
//               .map((e) => PackListPacks.fromJson(e as Map<String, dynamic>))
//               .toList(),
//     );
//   }
// }

// class PackListPacks {
//   String? name;
//   List<Prices>? prices;          // ← uses Prices (not PackListPacksPrices)

//   PackListPacks({this.name, this.prices});

//   factory PackListPacks.fromJson(Map<String, dynamic> json) {
//     return PackListPacks(
//       name: json['name']?.toString(),
//       prices: json['prices'] == null
//           ? null
//           : (json['prices'] as List)
//               .map((e) => Prices.fromJson(e as Map<String, dynamic>))
//               .toList(),
//     );
//   }
// }

// // THIS IS THE CLASS YOU NEED – MUST BE NAMED "Prices"
// class Prices {
//   dynamic amount;       // can be int or String from API
//   String? validity;
//   String? description;

//   Prices({this.amount, this.validity, this.description});

//   factory Prices.fromJson(Map<String, dynamic> json) {
//     return Prices(
//       amount: json['amount'],
//       validity: json['validity']?.toString(),
//       description: json['description']?.toString(),
//     );
//   }

//   Map<String, dynamic> toJson() {
//     return {
//       'amount': amount,
//       'validity': validity,
//       'description': description,
//     };
//   }

//   @override
//   String toString() => '₹$amount • $validity';
// }