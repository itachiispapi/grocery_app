import 'package:flutter/material.dart';
import 'screens/home_screen.dart';
import 'screens/add_item_screen.dart';
import 'screens/categories_screen.dart';

void main() {
  runApp(const GroceryApp());
}

class GroceryApp extends StatelessWidget {
  const GroceryApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Smart Grocery List',
      theme: ThemeData(
        primarySwatch: Colors.green,
        useMaterial3: true,
      ),
      initialRoute: '/',
      routes: {
        '/': (context) => HomeScreen(),
        '/add': (context) => const AddItemScreen(),
        '/categories': (context) => CategoriesScreen(),
      },
    );
  }
}
