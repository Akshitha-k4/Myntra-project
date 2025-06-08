import 'package:flutter/material.dart';
import 'package:myntra/providers/product.dart';
import 'package:myntra/providers/products.dart';
import 'package:provider/provider.dart';

class ProductDetailsScreen extends StatefulWidget {
  final Product product;

  const ProductDetailsScreen({Key? key, required this.product})
      : super(key: key);

  @override
  State<ProductDetailsScreen> createState() => _ProductDetailsScreenState();
}

class _ProductDetailsScreenState extends State<ProductDetailsScreen> {
  late int quantity;
  String selectedSize = 'S'; // Default selected size
  @override
  void initState() {
    super.initState();
    final cartItem = Provider.of<ProductsProvider>(context, listen: false)
        .getCartItem(widget.product);
    quantity = cartItem?.quantity ?? 0;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Color(0xFFF9F9F9),
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          icon: Icon(Icons.arrow_back, color: Colors.black),
          onPressed: () {
            Navigator.of(context).pop();
          },
        ),
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Center(
                child: Stack(
                  children: [
                    ClipRRect(
                      borderRadius: BorderRadius.circular(15),
                      child: Image.network(
                        widget.product.img,
                        fit: BoxFit.fill,
                        width: double.infinity,
                        height: 500,
                      ),
                    ),
                    Positioned(
                      top: 16,
                      right: 16,
                      child: CircleAvatar(
                        backgroundColor: Colors.white,
                        child: Consumer<ProductsProvider>(
                          builder: (_, product, ch) => IconButton(
                            icon: Icon(
                              widget.product.isFavorite
                                  ? Icons.favorite
                                  : Icons.favorite_border,
                              color: widget.product.isFavorite
                                  ? Colors.red
                                  : Colors.grey,
                            ),
                            onPressed: () {
                              product.toggleFavorite(widget.product);
                            },
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              SizedBox(height: 16),
              Text(
                widget.product.name,
                style: TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                ),
              ),
              SizedBox(height: 8),
              Text(
                '\$${widget.product.price}',
                style: TextStyle(
                  fontSize: 20,
                  color: Colors.red,
                  fontWeight: FontWeight.bold,
                ),
              ),
              SizedBox(height: 8),
              Text(
                widget.product.desc,
                style: TextStyle(
                  fontSize: 14,
                  color: Colors.grey[600],
                ),
              ),
              SizedBox(height: 20),
              Center(
                child: quantity != 0
                    ? Container(
                        padding: EdgeInsets.symmetric(horizontal: 20),
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(30),
                          border: Border.all(color: Colors.grey),
                        ),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            IconButton(
                              onPressed: () {
                                setState(() {
                                  if (quantity > 1) {
                                    quantity--;
                                    Provider.of<ProductsProvider>(context,
                                            listen: false)
                                        .removeFromCart(widget.product);
                                  } else {
                                    quantity = 0;
                                    Provider.of<ProductsProvider>(context,
                                            listen: false)
                                        .removeFromCart(widget.product);
                                  }
                                });
                              },
                              icon: Icon(Icons.remove, size: 20),
                            ),
                            SizedBox(width: 10),
                            Text(
                              '$quantity',
                              style: TextStyle(fontSize: 20),
                            ),
                            SizedBox(width: 10),
                            IconButton(
                              onPressed: () {
                                setState(() {
                                  quantity++;
                                  Provider.of<ProductsProvider>(context,
                                          listen: false)
                                      .addToCart(widget.product);
                                });
                              },
                              icon: Icon(Icons.add, size: 20),
                            ),
                          ],
                        ),
                      )
                    : Consumer<ProductsProvider>(
                        builder: (BuildContext context, products, ch) =>
                            ElevatedButton(
                          onPressed: () {
                            setState(() {
                              quantity = 1;
                              products.addToCart(widget.product);
                            });
                          },
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.pink,
                            padding: EdgeInsets.symmetric(
                                horizontal: 100, vertical: 16),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(30),
                            ),
                          ),
                          child: Text(
                            'Add to Cart',
                            style: TextStyle(color: Colors.white, fontSize: 16),
                          ),
                        ),
                      ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
