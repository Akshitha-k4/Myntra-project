import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import 'product.dart';

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
      _filteredProducts = List.from(_products);
      notifyListeners();
    } catch (e) {
      print('Error loading products: $e');
    }
  }

  void toggleFavorite(Product product) {
    final index = _products.indexWhere((p) => p.name == product.name);
    if (index != -1) {
      _products[index].isFavorite = !_products[index].isFavorite;
      notifyListeners();
    }
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
    final existingIndex =
        cartItems.indexWhere((item) => item.product.name == product.name);

    if (existingIndex != -1) {
      cartItems[existingIndex].quantity++;
    } else {
      cartItems.add(CartItem(product: product, quantity: 1));
    }
    notifyListeners();
  }

  void removeFromCart(Product product) {
    final index =
        cartItems.indexWhere((item) => item.product.name == product.name);

    if (index != -1) {
      if (cartItems[index].quantity > 1) {
        cartItems[index].quantity--;
      } else {
        cartItems.removeAt(index);
      }
      notifyListeners();
    }
  }

  CartItem? getCartItem(Product product) {
    try {
      return cartItems.firstWhere((item) => item.product.name == product.name);
    } catch (e) {
      return null;
    }
  }

  static ProductsProvider of(BuildContext context, {bool listen = true}) =>
      Provider.of<ProductsProvider>(context, listen: listen);
}
