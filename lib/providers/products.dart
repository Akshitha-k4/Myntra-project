import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';

import 'product.dart'; // Import your Product model

class CartItem {
  final Product product;
  int quantity;

  CartItem({required this.product, this.quantity = 1});
}

class ProductsProvider extends ChangeNotifier {
  late List<Product> _products;
  List<Product> _filteredProducts = [];
  List<CartItem> cartItems = [];

  List<Product> get products =>
      _filteredProducts.isNotEmpty ? _filteredProducts : _products;

  ProductsProvider() {
    _products = [];
    loadProducts();
  }

  Future<void> loadProducts() async {
    try {
      String jsonString = await rootBundle.loadString('assets/datare.json');
      List<dynamic> jsonList = json.decode(jsonString);
      _products = jsonList.map((json) => Product.fromJson(json)).toList();
      _filteredProducts =
          List.from(_products); // Initialize filteredProducts with all products
      notifyListeners();
    } catch (e) {
      print('Error loading products: $e');
    }
  }

  void toggleFavorite(Product product) {
    product.isFavorite = !product.isFavorite;
    notifyListeners();
  }

  void filterProducts(String color, String gender) {
    _filteredProducts = _products
        .where((product) =>
            product.color.toLowerCase() == color.toLowerCase() &&
            product.gender.toLowerCase() == gender.toLowerCase())
        .toList();
    notifyListeners();
  }

  void addToCart(Product product) {
    // Check if the product is already in the cart
    var existingCartItem = cartItems.firstWhere(
      (item) => item.product == product,
    );

    if (existingCartItem != null) {
      // Increase quantity if already in cart
      existingCartItem.quantity++;
    } else {
      // Add new item to cart
      cartItems.add(CartItem(product: product));
    }

    notifyListeners();
  }

  static ProductsProvider of(BuildContext context, {bool listen = true}) =>
      Provider.of<ProductsProvider>(context, listen: listen);
}
