import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:provider/provider.dart';
import 'product.dart';

class CartItem {
  final Product product;
  int quantity;

  CartItem({required this.product, this.quantity = 1});

  Map<String, dynamic> toMap() {
    return {
      'productName': product.name,
      'quantity': quantity,
    };
  }

  static CartItem fromMap(
      Map<dynamic, dynamic> map, List<Product> allProducts) {
    final productName = map['productName'] as String;
    final quantity = map['quantity'] as int;

    final product =
        allProducts.firstWhere((p) => p.name == productName, orElse: () {
      throw Exception('Product $productName not found in local list.');
    });

    return CartItem(product: product, quantity: quantity);
  }
}

class ProductsProvider extends ChangeNotifier {
  List<Product> _products = [];
  List<Product> _filteredProducts = [];
  List<CartItem> cartItems = [];

  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseDatabase _database = FirebaseDatabase.instance;

  List<Product> get products =>
      _filteredProducts.isNotEmpty ? _filteredProducts : _products;

  ProductsProvider() {
    _init();
  }

  Future<void> _init() async {
    await loadProducts();
    await loadCartFromFirebase();
  }

  Future<void> loadProducts() async {
    try {
      final jsonString = await rootBundle.loadString('assets/datare.json');
      final jsonList = json.decode(jsonString) as List<dynamic>;

      _products = jsonList
          .map((json) => Product.fromJson(json))
          .toList(growable: false);
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
        .where((p) =>
            p.color.toLowerCase() == color.toLowerCase() &&
            p.gender.toLowerCase() == gender.toLowerCase())
        .toList(growable: false);
    notifyListeners();
  }

  Future<void> addToCart(Product product) async {
    final existingIndex =
        cartItems.indexWhere((item) => item.product.name == product.name);

    if (existingIndex != -1) {
      cartItems[existingIndex].quantity++;
    } else {
      cartItems.add(CartItem(product: product, quantity: 1));
    }

    notifyListeners();
    await saveCartToFirebase();
  }

  Future<void> removeFromCart(Product product) async {
    final index =
        cartItems.indexWhere((item) => item.product.name == product.name);

    if (index != -1) {
      if (cartItems[index].quantity > 1) {
        cartItems[index].quantity--;
      } else {
        cartItems.removeAt(index);
      }

      notifyListeners();
      await saveCartToFirebase();
    }
  }

  CartItem? getCartItem(Product product) {
    try {
      return cartItems.firstWhere((item) => item.product.name == product.name);
    } catch (e) {
      return null;
    }
  }

  Future<void> loadCartFromFirebase() async {
    final user = _auth.currentUser;
    if (user == null) {
      // User not logged in, empty cart
      cartItems = [];
      notifyListeners();
      return;
    }

    final cartRef = _database.ref('carts/${user.uid}');
    try {
      final snapshot = await cartRef.get();
      if (snapshot.exists) {
        final cartData = snapshot.value as Map<dynamic, dynamic>;
        final loadedCart = <CartItem>[];

        cartData.forEach((key, value) {
          try {
            loadedCart.add(CartItem.fromMap(value, _products));
          } catch (e) {
            print('Warning: Skipping cart item due to error: $e');
          }
        });

        cartItems = loadedCart;
      } else {
        cartItems = [];
      }
      notifyListeners();
    } catch (e) {
      print('Failed to load cart from Firebase: $e');
    }
  }

  Future<void> saveCartToFirebase() async {
    final user = _auth.currentUser;
    if (user == null) return;

    final cartRef = _database.ref('carts/${user.uid}');
    try {
      final cartMap = <String, dynamic>{};
      for (int i = 0; i < cartItems.length; i++) {
        cartMap['item$i'] = cartItems[i].toMap();
      }
      await cartRef.set(cartMap);
    } catch (e) {
      print('Failed to save cart to Firebase: $e');
    }
  }

  static ProductsProvider of(BuildContext context, {bool listen = true}) =>
      Provider.of<ProductsProvider>(context, listen: listen);
}
