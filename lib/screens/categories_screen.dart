import 'package:flutter/material.dart';

class CategoriesScreen extends StatelessWidget {
  const CategoriesScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final titleStyle = Theme.of(context)
        .textTheme
        .titleLarge
        ?.copyWith(color: Colors.white, fontWeight: FontWeight.w700);

    return Scaffold(
      backgroundColor: const Color(0xFFF6F7FB),
      body: SafeArea(
        child: Column(
          children: [
            // Gradient header
            Container(
              padding: const EdgeInsets.fromLTRB(8, 16, 16, 20),
              width: double.infinity,
              decoration: const BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
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
                    onPressed: () => Navigator.pop(context),
                    icon: const Icon(Icons.arrow_back_ios_new_rounded,
                        color: Colors.white),
                  ),
                  const SizedBox(width: 4),
                  Text('Categories', style: titleStyle),
                  const Spacer(),
                  IconButton(
                    onPressed: () {
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(
                            content: Text('Add Category – coming soon')),
                      );
                    },
                    icon: const Icon(Icons.add_circle_outline_rounded,
                        color: Colors.white),
                  ),
                ],
              ),
            ),

            const SizedBox(height: 12),

            // Grid
            Expanded(
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                child: GridView.count(
                  crossAxisCount: 2,
                  mainAxisSpacing: 12,
                  crossAxisSpacing: 12,
                  childAspectRatio: 1.25,
                  children: const [
                    _CategoryCard(
                      color: Color(0xFFFFEDE3),
                      label: 'Vegetables',
                      icon: Icons.eco_rounded,
                    ),
                    _CategoryCard(
                      color: Color(0xFFEAF5FF),
                      label: 'Fruits',
                      icon: Icons.apple_rounded,
                    ),
                    _CategoryCard(
                      color: Color(0xFFEFF7EE),
                      label: 'Dairy',
                      icon: Icons.icecream_outlined,
                    ),
                    _CategoryCard(
                      color: Color(0xFFFFF2FC),
                      label: 'Bakery',
                      icon: Icons.cookie_outlined,
                    ),
                    _CategoryCard(
                      color: Color(0xFFFFF2FC),
                      label: 'Meats',
                      icon: Icons.outdoor_grill,
                    ),
                    _CategoryCard(
                      color: Color(0xFFEFF8FF),
                      label: 'Beverages',
                      icon: Icons.local_drink_outlined,
                    ),
                    _CategoryCard(
                      color: Color(0xFFF8F0FF),
                      label: 'Snacks',
                      icon: Icons.restaurant_menu_rounded,
                    ),
                    _CategoryCard(
                      color: Color(0xFFEFF4F9),
                      label: 'Household',
                      icon: Icons.home_outlined,
                    ),
                    _CategoryCard(
                      color: Color(0xFFEFFAF2),
                      label: 'Other',
                      icon: Icons.grid_view_rounded,
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _CategoryCard extends StatelessWidget {
  final String label;
  final Color color;
  final IconData icon;
  const _CategoryCard(
      {required this.label, required this.color, required this.icon});

  @override
  Widget build(BuildContext context) {
    return InkWell(
      borderRadius: BorderRadius.circular(18),
      onTap: () {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Open "$label"')),
        );
      },
      child: Container(
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(18),
          boxShadow: const [
            BoxShadow(
              color: Color(0x14000000),
              blurRadius: 12,
              offset: Offset(0, 8),
            ),
          ],
          border: Border.all(color: const Color(0xFFE9EEF4)),
        ),
        padding: const EdgeInsets.all(14),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              decoration:
                  BoxDecoration(color: color, borderRadius: BorderRadius.circular(14)),
              padding: const EdgeInsets.all(10),
              child: Icon(icon, size: 24, color: Colors.black87),
            ),
            const Spacer(),
            Text(
              label,
              style: const TextStyle(fontWeight: FontWeight.w700, fontSize: 16),
            ),
            const SizedBox(height: 4),
            Text('Tap to view items',
                style: Theme.of(context)
                    .textTheme
                    .bodySmall
                    ?.copyWith(color: Colors.black54)),
          ],
        ),
      ),
    );
  }
}
