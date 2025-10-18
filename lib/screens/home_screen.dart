// lib/screens/home_screen.dart
import 'package:flutter/material.dart';

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Home')),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Text('Welcome to Smart Grocery List!'),
            ElevatedButton(
              onPressed: () {
                Navigator.pushNamed(context, '/add');
              },
              child: const Text('Add Item'),
            ),
            ElevatedButton(
              onPressed: () {
                Navigator.pushNamed(context, '/categories');
              },
              child: const Text('Categories'),
            ),
          ],
        ),
      ),
    );
  }
}
