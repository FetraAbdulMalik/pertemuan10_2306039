import 'dart:convert';

class ProductModel {
  final String name;
  final String description;
  final int price;

  ProductModel({
    required this.name,
    required this.description,
    required this.price,
  });

  // object ke map
  Map<String, dynamic> toMap() {
    return {'name': name, 'description': description, 'price': price};
  }

  // map ke object
  factory ProductModel.fromMap(Map<String, dynamic> map) {
    return ProductModel(
      name: map['name'] ?? '',
      description: map['description'] ?? '',
      price: map['price'] ?? 0,
    );
  }
  // object ke String
  String toJson() => json.encode(toMap());

  // String ke object
  factory ProductModel.fromJson(String source) {
    return ProductModel.fromMap(json.decode(source));
  }
}
