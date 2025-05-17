
import 'dart:convert';

Products productsFromJson(String str) => Products.fromJson(json.decode(str));

String productsToJson(Products data) => json.encode(data.toJson());

class Products {
    Products({
        required this.image,
        required this.price,
        required this.rating,
        required this.description,
        required this.id,
        required this.title,
        required this.category,
    });

    String image;
    double price;
    Rating rating;
    String description;
    int id;
    String title;
    String category;

    factory Products.fromJson(Map<dynamic, dynamic> json) => Products(
        image: json["image"],
        price: json["price"]?.toDouble(),
        rating: Rating.fromJson(json["rating"]),
        description: json["description"],
        id: json["id"],
        title: json["title"],
        category: json["category"],
    );

    Map<dynamic, dynamic> toJson() => {
        "image": image,
        "price": price,
        "rating": rating.toJson(),
        "description": description,
        "id": id,
        "title": title,
        "category": category,
    };
}

class Rating {
  Rating({
    required this.rate,
    required this.count,
  });

  double rate;
  int count;

  factory Rating.fromJson(Map<dynamic, dynamic> json) => Rating(
        rate: json["rate"]?.toDouble(),
        count: json["count"],
      );

  Map<dynamic, dynamic> toJson() => {
        "rate": rate,
        "count": count,
      };
}


