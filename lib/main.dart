import 'package:flutter/material.dart';

void main() => runApp(const GroceryApp());

class GroceryApp extends StatelessWidget {
  const GroceryApp({super.key});
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'My Grocery List',
      debugShowCheckedModeBanner: false,
      home: const HomeShell(),
    );
  }
}

class HomeShell extends StatefulWidget {
  const HomeShell({super.key});
  @override
  State<HomeShell> createState() => _HomeShellState();
}

class _HomeShellState extends State<HomeShell> {
  int _index = 0;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF5F7FB),
      body: SafeArea(
        child: ListView(
          padding: EdgeInsets.zero,
          children: [
            const _Header(),
            const SizedBox(height: 16),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20),
              child: Row(
                children: [
                  Expanded(
                    child: _BigAction(
                      label: 'Add Item',
                      icon: Icons.add,
                      gradient: const LinearGradient(
                        colors: [Color(0xFF4CD964), Color(0xFF2DBE6F)],
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                      ),
                      onTap: () {},
                    ),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: _BigAction(
                      label: 'Weekly Plan',
                      icon: Icons.event_note,
                      gradient: const LinearGradient(
                        colors: [Color(0xFFB06BF3), Color(0xFF7C58FF)],
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                      ),
                      onTap: () {},
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 16),
            const Padding(
              padding: EdgeInsets.symmetric(horizontal: 20),
              child: _PriceEstimation(),
            ),
            const SizedBox(height: 16),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20),
              child: _EmptyState(),
            ),
            const SizedBox(height: 24),
          ],
        ),
      ),
      bottomNavigationBar: NavigationBar(
        selectedIndex: _index,
        onDestinationSelected: (i) => setState(() => _index = i),
        destinations: const [
          NavigationDestination(icon: Icon(Icons.home_outlined), selectedIcon: Icon(Icons.home), label: 'Home'),
          NavigationDestination(icon: Icon(Icons.calendar_month_outlined), selectedIcon: Icon(Icons.calendar_month), label: 'Weekly'),
          NavigationDestination(icon: Icon(Icons.folder_outlined), selectedIcon: Icon(Icons.folder), label: 'Categories'),
        ],
      ),
    );
  }
}

class _Header extends StatelessWidget {
  const _Header();
  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: const BoxDecoration(
        gradient: LinearGradient(
          colors: [Color(0xFF6B63FF), Color(0xFF9B5CFF)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
      ),
      child: Column(
        children: [
          const SizedBox(height: 20),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Container(
                  height: 56,
                  width: 56,
                  decoration: BoxDecoration(
                    color: const Color(0x33FFFFFF),
                    borderRadius: BorderRadius.circular(16),
                  ),
                  alignment: Alignment.center,
                  child: const Icon(Icons.shopping_bag_outlined, color: Colors.white, size: 30),
                ),
                const SizedBox(width: 12),
                const Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text('My Grocery List', style: TextStyle(color: Colors.white, fontSize: 28, fontWeight: FontWeight.w700)),
                      SizedBox(height: 4),
                      Text('Smart shopping made easy', style: TextStyle(color: Colors.white70, fontSize: 16)),
                    ],
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 16),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: Row(
              children: const [
                _StatChip(title: 'Total', value: '0'),
                SizedBox(width: 12),
                _StatChip(title: 'Active', value: '0'),
                SizedBox(width: 12),
                _StatChip(title: 'Done', value: '0'),
                SizedBox(width: 12),
                _StatChip(title: ' ', value: '0', icon: Icons.star, star: true),
              ],
            ),
          ),
          const SizedBox(height: 16),
          Padding(
            padding: const EdgeInsets.fromLTRB(20, 0, 20, 20),
            child: Container(
              height: 54,
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(16),
              ),
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: const Row(
                children: [
                  Icon(Icons.search, color: Colors.black54),
                  SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      'Search items...',
                      style: TextStyle(color: Colors.black45, fontSize: 16),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _StatChip extends StatelessWidget {
  final String title;
  final String value;
  final IconData? icon;
  final bool star;
  const _StatChip({required this.title, required this.value, this.icon, this.star = false});
  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: Container(
        height: 95,
        decoration: BoxDecoration(
          color: const Color(0x26FFFFFF),
          borderRadius: BorderRadius.circular(20),
          border: Border.all(color: const Color(0x59FFFFFF)),
        ),
        padding: const EdgeInsets.symmetric(horizontal: 12),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            if (star) Icon(icon ?? Icons.star, color: Colors.amberAccent, size: 22),
            const Text('0', style: TextStyle(color: Colors.white, fontSize: 28, fontWeight: FontWeight.w700)),
            Text(title == ' ' ? '' : title, style: const TextStyle(color: Colors.white70)),
          ],
        ),
      ),
    );
  }
}

class _BigAction extends StatelessWidget {
  final String label;
  final IconData icon;
  final LinearGradient gradient;
  final VoidCallback onTap;
  const _BigAction({required this.label, required this.icon, required this.gradient, required this.onTap});
  @override
  Widget build(BuildContext context) {
    return InkWell(
      borderRadius: BorderRadius.circular(20),
      onTap: onTap,
      child: Ink(
        height: 120,
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(20),
          gradient: gradient,
          boxShadow: const [
            BoxShadow(color: Color(0x14000000), blurRadius: 16, offset: Offset(0, 8)),
          ],
        ),
        child: Center(
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(icon, color: Colors.white, size: 28),
              const SizedBox(width: 12),
              Text(label, style: const TextStyle(color: Colors.white, fontSize: 20, fontWeight: FontWeight.w700)),
            ],
          ),
        ),
      ),
    );
  }
}

class _PriceEstimation extends StatelessWidget {
  const _PriceEstimation();
  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: const Color(0xFFF2FFFA),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: const Color(0xFFBEE7D5)),
        boxShadow: const [
          BoxShadow(color: Color(0x0A000000), blurRadius: 12, offset: Offset(0, 6)),
        ],
      ),
      padding: const EdgeInsets.fromLTRB(16, 16, 16, 20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: const [
              CircleAvatar(
                radius: 18,
                backgroundColor: Colors.white,
                child: Text('💰', style: TextStyle(fontSize: 18)),
              ),
              SizedBox(width: 10),
              Text('Price Estimation', style: TextStyle(fontSize: 22, fontWeight: FontWeight.w800)),
            ],
          ),
          const SizedBox(height: 14),
          Row(
            children: const [
              _EstimationTile(
                title: 'Total',
                amountColor: Color(0xFF2DBE6F),
                amount: '\$0.00',
                sub: '0 items',
              ),
              SizedBox(width: 12),
              _EstimationTile(
                title: 'To Buy',
                amountColor: Color(0xFF256BFF),
                amount: '\$0.00',
                sub: '0 left',
              ),
              SizedBox(width: 12),
              _EstimationTile(
                title: 'Spent',
                amountColor: Color(0xFF7C58FF),
                amount: '\$0.00',
                sub: '0 done',
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _EstimationTile extends StatelessWidget {
  final String title;
  final String amount;
  final String sub;
  final Color amountColor;
  const _EstimationTile({required this.title, required this.amount, required this.sub, required this.amountColor});
  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: Container(
        height: 140,
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16),
        ),
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(title, style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w600, color: Colors.black87)),
            const SizedBox(height: 8),
            Text(amount, style: TextStyle(fontSize: 26, fontWeight: FontWeight.w800, color: amountColor)),
            const Spacer(),
            Text(sub, style: const TextStyle(color: Colors.black45)),
          ],
        ),
      ),
    );
  }
}

class _EmptyState extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Container(
      height: 220,
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(22),
        boxShadow: const [
          BoxShadow(color: Color(0x0D000000), blurRadius: 14, offset: Offset(0, 8)),
        ],
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: const [
          CircleAvatar(
            radius: 48,
            backgroundColor: Color(0xFFF1F3F6),
            child: Icon(Icons.shopping_bag_outlined, size: 42, color: Colors.black38),
          ),
          SizedBox(height: 16),
          Text('No items yet', style: TextStyle(fontSize: 18, color: Colors.black54)),
        ],
      ),
    );
  }
}
