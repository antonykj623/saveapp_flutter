import 'dart:convert';

class PackListEntity {
  String? status;
  List<PackListPacks>? packs;

  PackListEntity({this.status, this.packs});

  factory PackListEntity.fromJson(Map<String, dynamic> json) {
    return PackListEntity(
      status: json['status'],
      packs: json['packs'] != null
          ? List<PackListPacks>.from(
              json['packs'].map((x) => PackListPacks.fromJson(x)))
          : [],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      "status": status,
      "packs": packs?.map((x) => x.toJson()).toList(),
    };
  }

  @override
  String toString() => jsonEncode(this);
}

class PackListPacks {
  int? id;
  String? name;
  String? type;
  List<String>? languages;
  String? pictureQuality;
  List<PackListPacksPrices>? prices;

  PackListPacks({
    this.id,
    this.name,
    this.type,
    this.languages,
    this.pictureQuality,
    this.prices,
  });

  factory PackListPacks.fromJson(Map<String, dynamic> json) {
    return PackListPacks(
      id: json['id'],
      name: json['name'],
      type: json['type'],
      languages: json['languages'] != null
          ? List<String>.from(json['languages'])
          : [],
      pictureQuality: json['pictureQuality'],
      prices: json['prices'] != null
          ? List<PackListPacksPrices>.from(
              json['prices'].map((x) => PackListPacksPrices.fromJson(x)))
          : [],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      "id": id,
      "name": name,
      "type": type,
      "languages": languages,
      "pictureQuality": pictureQuality,
      "prices": prices?.map((x) => x.toJson()).toList(),
    };
  }

  @override
  String toString() => jsonEncode(this);
}

class PackListPacksPrices {
  int? amount;
  int? validityMonths;
  int? effectiveMonthlyPrice;
  String? validity;
  bool? ncf;
  int? extraValidityDays;

  PackListPacksPrices({
    this.amount,
    this.validityMonths,
    this.effectiveMonthlyPrice,
    this.validity,
    this.ncf,
    this.extraValidityDays,
  });

  factory PackListPacksPrices.fromJson(Map<String, dynamic> json) {
    return PackListPacksPrices(
      amount: json['amount'],
      validityMonths: json['validityMonths'],
      effectiveMonthlyPrice: json['effectiveMonthlyPrice'],
      validity: json['validity'],
      ncf: json['ncf'],
      extraValidityDays: json['extraValidityDays'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      "amount": amount,
      "validityMonths": validityMonths,
      "effectiveMonthlyPrice": effectiveMonthlyPrice,
      "validity": validity,
      "ncf": ncf,
      "extraValidityDays": extraValidityDays,
    };
  }

  @override
  String toString() => jsonEncode(this);
}