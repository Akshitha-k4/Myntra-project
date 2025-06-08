import 'package:camera/camera.dart';
import 'package:flutter/material.dart';
import 'package:myntra/consts/imageurls.dart';
import 'package:myntra/consts/productlist.dart';
import 'package:myntra/screens/astroformScreen.dart';
import 'package:myntra/screens/cameraScreen.dart';
import 'package:myntra/screens/cartScreen.dart';
import 'package:myntra/screens/categoryScreen.dart';
import 'package:myntra/screens/favioriteScreen.dart';
import 'package:myntra/screens/profileScreen.dart';
import 'package:myntra/widgets/cached_image.dart';

late CameraDescription firstCamera;

class HomeScreen extends StatefulWidget {
  const HomeScreen({Key? key}) : super(key: key);

  @override
  _HomeScreenState createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  int _selectedIndex = 0;

  static List<Widget> _widgetOptions = <Widget>[
    HomePage(),
    CartScreen(),
    FavouritePage(),
  ];

  void _onItemTapped(int index) {
    setState(() {
      _selectedIndex = index;
    });
  }

  @override
  void initState() {
    super.initState();
    WidgetsFlutterBinding.ensureInitialized();
    initCamera();
  }

  Future<void> initCamera() async {
    final cameras = await availableCameras();
    final frontCamera = cameras.firstWhere(
      (camera) => camera.lensDirection == CameraLensDirection.front,
      orElse: () => cameras.first,
    );
    firstCamera = frontCamera;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        surfaceTintColor: Colors.white,
        backgroundColor: Colors.white,
        leading: IconButton(
          icon: const Icon(Icons.menu),
          onPressed: () {},
        ),
        title: const Image(
          image:
              AssetImage('assets/myntra.jpg'), // Replace with your logo asset
          height: 32,
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.search),
            onPressed: () {},
          ),
          IconButton(
            icon: const Icon(Icons.shopping_cart),
            onPressed: () {
              Navigator.push(
                  context, MaterialPageRoute(builder: (_) => CartScreen()));
            },
          ),
        ],
      ),
      body: _widgetOptions.elementAt(_selectedIndex),
      bottomNavigationBar: BottomNavigationBar(
        items: const <BottomNavigationBarItem>[
          BottomNavigationBarItem(
            icon: Icon(Icons.home),
            label: 'Home',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.shopping_cart),
            label: 'Cart',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.favorite),
            label: 'Favourite',
          ),
        ],
        currentIndex: _selectedIndex,
        backgroundColor: Colors.white,
        selectedItemColor: Colors.pink,
        unselectedItemColor: Colors.grey,
        onTap: _onItemTapped,
      ),
    );
  }
}

class HomePage extends StatelessWidget {
  const HomePage({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return ListView(
      children: <Widget>[
        const CategoryList(),
        GestureDetector(
          onTap: () {
            Navigator.push(
                context,
                MaterialPageRoute(
                    builder: (_) => TakePictureScreen(camera: firstCamera)));
          },
          child: Container(
            height: 360,
            width: double.infinity,
            decoration: const BoxDecoration(
                image: DecorationImage(
                    fit: BoxFit.fill,
                    image: AssetImage(
                      'assets/astro.jpeg',
                    ))),
          ),
        ),
        //const PromoBanner(),
        const Padding(
          padding: EdgeInsets.all(16.0),
          child: Text(
            'Featured Products',
            style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
          ),
        ),
        productlist()
      ],
    );
  }
}

class CategoryList extends StatelessWidget {
  const CategoryList({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 120,
      child: ListView(
        scrollDirection: Axis.horizontal,
        children: <Widget>[
          CategoryItem(
            imag: men,
          ),
          CategoryItem(imag: women),
          CategoryItem(imag: kids),
          CategoryItem(
            imag: beauty,
          ),
        ],
      ),
    );
  }
}

class CategoryItem extends StatelessWidget {
  final String imag;

  const CategoryItem({Key? key, required this.imag}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
        width: 80,
        margin: const EdgeInsets.all(8.0),
        child: CachedImage(
          url: imag,
          height: 89,
          width: 76,
        ));
  }
}

class PromoBanner extends StatelessWidget {
  const PromoBanner({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      color: Colors.blue,
      margin: const EdgeInsets.all(8.0),
      padding: const EdgeInsets.all(16.0),
      child: Column(
        children: <Widget>[
          const Text(
            'Myntra Freedom Fest',
            style: TextStyle(
                fontSize: 20, fontWeight: FontWeight.bold, color: Colors.white),
          ),
          const SizedBox(height: 8),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: <Widget>[
              PromoCode(code: 'INDNEW300', discount: '₹300'),
              PromoCode(code: 'MYNTRA200', discount: '₹200'),
            ],
          ),
        ],
      ),
    );
  }
}

class PromoCode extends StatelessWidget {
  final String code;
  final String discount;

  const PromoCode({
    Key? key,
    required this.code,
    required this.discount,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Column(
      children: <Widget>[
        Text(
          'Extra $discount Off',
          style: const TextStyle(
              fontSize: 16, fontWeight: FontWeight.bold, color: Colors.white),
        ),
        const SizedBox(height: 4),
        Text(
          'Use Code: $code',
          style: const TextStyle(fontSize: 14, color: Colors.white),
        ),
      ],
    );
  }
}
