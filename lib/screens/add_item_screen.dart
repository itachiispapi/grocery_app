// lib/screens/add_item_screen.dart
import 'package:flutter/material.dart';

class AddItemScreen extends StatelessWidget {
  const AddItemScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Add Item')),
      body: const Center(child: Text('Here you can add a grocery item.')),
    );
  }
}
