import 'package:flutter/material.dart';

class WeeklyListPopup extends StatefulWidget {
  const WeeklyListPopup({super.key});

  @override
  State<WeeklyListPopup> createState() => _WeeklyListPopupState();
}

class _WeeklyListPopupState extends State<WeeklyListPopup> {
  final Map<String, List<String>> _suggested = const {
    'Vegetables': ['Lettuce', 'Tomatoes', 'Onions', 'Cucumbers'],
    'Fruits': ['Bananas', 'Apples', 'Strawberries'],
    'Dairy': ['Milk', 'Eggs', 'Yogurt'],
    'Bakery': ['Bread', 'Bagels', 'Tortillas'],
    'Meats': ['Chicken Breast', 'Ground Beef', 'Salmon'],
    'Beverages': ['Orange Juice', 'Coffee'],
    'Snacks': ['Chips', 'Granola Bars'],
    'Household': ['Paper Towels', 'Dish Soap'],
    'Other': ['Foil', 'Sandwich Bags'],
  };

  final Set<String> _selected = {};

  @override
  Widget build(BuildContext context) {
    final titleStyle = Theme.of(context).textTheme.titleLarge?.copyWith(
          color: Colors.white, fontWeight: FontWeight.w800,
        );
    final subStyle = TextStyle(color: Colors.white.withOpacity(.95));

    return Scaffold(
      backgroundColor: const Color(0xFFF6F7FB),
      body: SafeArea(
        child: Column(
          children: [
            // Header
            Container(
              padding: const EdgeInsets.fromLTRB(8, 16, 16, 20),
              width: double.infinity,
              decoration: const BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topLeft, end: Alignment.bottomRight,
                  colors: [Color(0xFF7E56FF), Color(0xFF06C1FF)],
                ),
                borderRadius: BorderRadius.only(
                  bottomLeft: Radius.circular(24),
                  bottomRight: Radius.circular(24),
                ),
              ),
              child: Row(
                children: [
                  IconButton(
                    onPressed: () => Navigator.pop(context, null),
                    icon: const Icon(Icons.arrow_back_ios_new_rounded, color: Colors.white),
                  ),
                  const SizedBox(width: 6),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text('Weekly List', style: titleStyle),
                      Text('Select suggested items to add', style: subStyle),
                    ],
                  ),
                  const Spacer(),
                  ElevatedButton(
                    onPressed: _selected.isEmpty
                        ? null
                        : () {
                            // Build a structured payload: List<Map<String,dynamic>>
                            final picks = _selected.map((key) {
                              final split = key.split('::'); // [category, name]
                              return {
                                'name': split[1],
                                'category': split[0],
                                'qty': 1.0,
                                'unit': 'pcs',
                              };
                            }).toList();
                            Navigator.pop(context, picks);
                          },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFF34C759),
                      foregroundColor: Colors.white,
                      elevation: 0,
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(18)),
                      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
                    ),
                    child: Text('Add (${_selected.length})',
                        style: const TextStyle(fontWeight: FontWeight.w700)),
                  ),
                ],
              ),
            ),

            const SizedBox(height: 12),

            // Content
            Expanded(
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                child: ListView(
                  children: _suggested.entries.map((e) {
                    final cat = e.key;
                    final items = e.value;
                    if (items.isEmpty) return const SizedBox.shrink();
                    final anyUnchecked =
                        items.any((x) => !_selected.contains('$cat::$x'));

                    return Container(
                      margin: const EdgeInsets.only(bottom: 14),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(18),
                        border: Border.all(color: const Color(0xFFE9EEF4)),
                        boxShadow: const [
                          BoxShadow(
                            color: Color(0x14000000),
                            blurRadius: 12,
                            offset: Offset(0, 8),
                          ),
                        ],
                      ),
                      child: Column(
                        children: [
                          // Section header
                          Padding(
                            padding: const EdgeInsets.fromLTRB(14, 12, 8, 4),
                            child: Row(
                              children: [
                                Text(cat, style: const TextStyle(fontWeight: FontWeight.w700, fontSize: 16)),
                                const Spacer(),
                                TextButton(
                                  onPressed: () => setState(() {
                                    if (anyUnchecked) {
                                      for (final it in items) {
                                        _selected.add('$cat::$it');
                                      }
                                    } else {
                                      for (final it in items) {
                                        _selected.remove('$cat::$it');
                                      }
                                    }
                                  }),
                                  child: Text(anyUnchecked ? 'Select All' : 'Clear'),
                                ),
                              ],
                            ),
                          ),
                          const Divider(height: 1),
                          // Items
                          Padding(
                            padding: const EdgeInsets.symmetric(horizontal: 4),
                            child: Column(
                              children: items.map((it) {
                                final key = '$cat::$it';
                                final checked = _selected.contains(key);
                                return CheckboxListTile(
                                  dense: true,
                                  value: checked,
                                  onChanged: (_) => setState(() {
                                    if (checked) _selected.remove(key);
                                    else _selected.add(key);
                                  }),
                                  title: Text(it),
                                );
                              }).toList(),
                            ),
                          ),
                        ],
                      ),
                    );
                  }).toList(),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
