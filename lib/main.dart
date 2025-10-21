import 'package:flutter/material.dart';
import 'screens/home_screen.dart';
import 'screens/add_item_screen.dart';
import 'screens/categories_screen.dart';
import 'screens/weekly_planner_screen.dart'; // 👈 import this

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
        '/': (context) => const HomeScreen(),
        '/add': (context) => const AddItemScreen(),
        '/categories': (context) => const CategoriesScreen(),
        '/weekly': (context) => const WeeklyPlannerScreen(), // ✅ added this
      },
    );
  }
}
