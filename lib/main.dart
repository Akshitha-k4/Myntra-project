import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:myntra/firebase_options.dart';
import 'package:myntra/providers/products.dart';
import 'package:myntra/screens/homeScreen.dart';
import 'package:myntra/screens/loginscreen.dart';
import 'package:provider/provider.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => ProductsProvider()),
        // Add other providers here like AuthProvider, etc.
      ],
      child: MaterialApp(
        debugShowCheckedModeBanner: false,
        title: 'Myntra Clone',
        theme: ThemeData(
          primarySwatch: Colors.pink,
          visualDensity: VisualDensity.adaptivePlatformDensity,
        ),
        home: LoginScreen(),
      ),
    );
  }
}
