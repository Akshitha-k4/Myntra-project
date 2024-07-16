import 'package:flutter/material.dart';
import 'package:myntra/providers/products.dart';
import 'package:provider/provider.dart';

class CartScreen extends StatelessWidget {
  const CartScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.white,
        title: Text('Cart'),
      ),
      body: Consumer<ProductsProvider>(
        builder: (_, productProvider, __) {
          print(productProvider.cartItems);
          List<CartItem> cartItems = productProvider.cartItems;
          return ListView.builder(
            itemCount: cartItems.length,
            itemBuilder: (context, index) {
              return Padding(
                padding: const EdgeInsets.all(8.0),
                child: Card(
                  child: ListTile(
                    leading: Image.network(
                      cartItems[index].product.img,
                      width: 60,
                      height: 60,
                      fit: BoxFit.cover,
                    ),
                    title: Text(cartItems[index].product.name),
                    subtitle: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text('Quantity: ${cartItems[index].quantity}'),
                        Text(
                          '\$${cartItems[index].product.price * cartItems[index].quantity}',
                          style: TextStyle(
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ],
                    ),
                    trailing: IconButton(
                      icon: Icon(Icons.remove_circle),
                      onPressed: () {
                        //productProvider.removeFromCart(index);
                      },
                    ),
                  ),
                ),
              );
            },
          );
        },
      ),
    );
  }
}
