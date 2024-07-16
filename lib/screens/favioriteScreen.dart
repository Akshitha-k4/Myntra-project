import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:myntra/providers/products.dart'; // Adjust the import as per your project structure
import 'package:myntra/screens/productdetailScreen.dart'; // Adjust the import as per your project structure
import 'package:myntra/providers/product.dart'; // Adjust the import as per your project structure

class FavouritePage extends StatelessWidget {
  const FavouritePage({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.white,
        title: Text('Favorite Products'),
      ),
      body: Consumer<ProductsProvider>(
        builder: (_, productsProvider, __) {
          final favoriteProducts = productsProvider.products
              .where((product) => product.isFavorite)
              .toList();

          if (favoriteProducts.isEmpty) {
            return Center(
              child: Text('No favorite products yet.'),
            );
          }

          return ListView.builder(
            itemCount: favoriteProducts.length,
            itemBuilder: (context, index) {
              return ProductCard(
                product: favoriteProducts[index],
              );
            },
          );
        },
      ),
    );
  }
}

class ProductCard extends StatelessWidget {
  final Product product;

  const ProductCard({Key? key, required this.product}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => ProductDetailsScreen(product: product),
          ),
        );
      },
      child: Card(
        margin: EdgeInsets.all(8),
        child: ListTile(
          tileColor: Colors.white,
          leading: CircleAvatar(
            backgroundImage: NetworkImage(product.img),
          ),
          title: Text(product.name),
          subtitle: Text('₹${product.price}'),
          trailing: IconButton(
            icon: Icon(
              product.isFavorite ? Icons.favorite : Icons.favorite_border,
              color: product.isFavorite ? Colors.red : Colors.grey,
            ),
            onPressed: () {
              Provider.of<ProductsProvider>(context, listen: false)
                  .toggleFavorite(product);
            },
          ),
        ),
      ),
    );
  }
}
