import 'dart:convert';

class Product {
  final String name;
  final String desc;
  final String img;
  final String price;
  final String original_price;
  final String color;
  final String gender;
  bool isFavorite;

  Product({
    required this.name,
    required this.desc,
    required this.img,
    required this.price,
    required this.original_price,
    required this.color,
    required this.gender,
    required this.isFavorite,
  });

  factory Product.fromJson(Map<String, dynamic> json) {
    return Product(
      name: json['type'],
      desc: json['desc'],
      img: json['img'],
      price: json['price'],
      original_price: json['original_price'],
      color: json['color'],
      gender: json['gender'],
      isFavorite: json['isFavorite'],
    );
  }
}
