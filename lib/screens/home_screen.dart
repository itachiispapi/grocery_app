import 'package:flutter/material.dart';

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF6F7FB),
      body: const _HomeBody(),
      bottomNavigationBar: const _BottomNav(currentIndex: 0),
    );
  }
}

class _HomeBody extends StatelessWidget {
  const _HomeBody();

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return SafeArea(
      child: SingleChildScrollView(
        padding: const EdgeInsets.only(bottom: 24),
        child: Column(
          children: [
            // Gradient header
            Container(
              width: double.infinity,
              padding: const EdgeInsets.fromLTRB(16, 20, 16, 24),
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
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Title row
                  Row(
                    children: [
                      Container(
                        padding: const EdgeInsets.all(10),
                        decoration: BoxDecoration(
                          color: Colors.white.withOpacity(.2),
                          borderRadius: BorderRadius.circular(14),
                        ),
                        child: const Icon(Icons.shopping_bag_outlined,
                            color: Colors.white, size: 24),
                      ),
                      const SizedBox(width: 12),
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'My Grocery List',
                            style: theme.textTheme.titleLarge?.copyWith(
                              color: Colors.white,
                              fontWeight: FontWeight.w700,
                            ),
                          ),
                          Text(
                            'Smart shopping made easy',
                            style: theme.textTheme.bodyMedium?.copyWith(
                              color: Colors.white.withOpacity(.9),
                            ),
                          )
                        ],
                      ),
                    ],
                  ),
                  const SizedBox(height: 18),

                  // Stats row
                  Row(
                    children: const [
                      _StatPill(label: 'Total', value: '0'),
                      SizedBox(width: 12),
                      _StatPill(label: 'Active', value: '0'),
                      SizedBox(width: 12),
                      _StatPill(label: 'Done', value: '0'),
                      SizedBox(width: 12),
                      _StatPill(label: '', value: '0', icon: Icons.star),
                    ],
                  ),
                  const SizedBox(height: 16),

                  // Search field
                  const _SearchField(),
                ],
              ),
            ),

            const SizedBox(height: 16),

            // Big CTA buttons
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: Row(
                children: [
                  Expanded(
                    child: _BigButton(
                      label: 'Add Item',
                      icon: Icons.add,
                      background: const Color(0xFF0AD06E),
                      onTap: () => Navigator.pushNamed(context, '/add'),
                    ),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: _BigButton(
                      label: 'Weekly Plan',
                      icon: Icons.calendar_today_rounded,
                      background: const Color(0xFF9E65FF),
                      onTap: () => Navigator.pushNamed(context, '/weekly'), // ✅ now opens your Weekly Planner
                    ),
                  ),
                ],
              ),
            ),

            const SizedBox(height: 16),

            // Price Estimation card
            const Padding(
              padding: EdgeInsets.symmetric(horizontal: 16),
              child: _PriceEstimationCard(),
            ),

            const SizedBox(height: 24),

            // Empty state
            const Padding(
              padding: EdgeInsets.symmetric(horizontal: 16),
              child: _EmptyStateCard(
                icon: Icons.shopping_bag_outlined,
                message: 'No items yet',
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// ──────────────────────────────
// Reusable widgets below
// ──────────────────────────────

class _StatPill extends StatelessWidget {
  final String label;
  final String value;
  final IconData? icon;
  const _StatPill({required this.label, required this.value, this.icon});

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: Container(
        height: 64,
        decoration: BoxDecoration(
          color: Colors.white.withOpacity(.15),
          borderRadius: BorderRadius.circular(14),
          border: Border.all(color: Colors.white.withOpacity(.25)),
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            icon == null
                ? Text(value,
                    style: const TextStyle(
                        color: Colors.white, fontWeight: FontWeight.w700))
                : Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(icon, color: Colors.amberAccent, size: 18),
                      const SizedBox(width: 4),
                      Text(value,
                          style: const TextStyle(
                              color: Colors.white, fontWeight: FontWeight.w700)),
                    ],
                  ),
            if (label.isNotEmpty)
              Text(label,
                  style: TextStyle(
                      color: Colors.white.withOpacity(.9), fontSize: 12)),
          ],
        ),
      ),
    );
  }
}

class _SearchField extends StatelessWidget {
  const _SearchField();

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 48,
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
      ),
      child: const TextField(
        decoration: InputDecoration(
          hintText: 'Search items...',
          prefixIcon: Icon(Icons.search),
          border: InputBorder.none,
          contentPadding: EdgeInsets.symmetric(horizontal: 12, vertical: 14),
        ),
      ),
    );
  }
}

class _BigButton extends StatelessWidget {
  final String label;
  final IconData icon;
  final Color background;
  final VoidCallback onTap;
  const _BigButton({
    required this.label,
    required this.icon,
    required this.background,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return InkWell(
      borderRadius: BorderRadius.circular(18),
      onTap: onTap,
      child: Container(
        height: 84,
        decoration: BoxDecoration(
          color: background,
          borderRadius: BorderRadius.circular(18),
          boxShadow: [
            BoxShadow(
              color: background.withOpacity(.35),
              blurRadius: 16,
              offset: const Offset(0, 8),
            ),
          ],
        ),
        padding: const EdgeInsets.symmetric(horizontal: 16),
        child: Row(
          children: [
            Container(
              decoration: BoxDecoration(
                color: Colors.white.withOpacity(.2),
                borderRadius: BorderRadius.circular(12),
              ),
              padding: const EdgeInsets.all(10),
              child: Icon(icon, color: Colors.white),
            ),
            const SizedBox(width: 12),
            Text(
              label,
              style: const TextStyle(
                  color: Colors.white, fontSize: 16, fontWeight: FontWeight.w700),
            ),
          ],
        ),
      ),
    );
  }
}

class _PriceEstimationCard extends StatelessWidget {
  const _PriceEstimationCard();

  @override
  Widget build(BuildContext context) {
    final titleStyle = Theme.of(context).textTheme.titleMedium?.copyWith(
          fontWeight: FontWeight.w700,
        );

    return Container(
      padding: const EdgeInsets.fromLTRB(16, 14, 16, 16),
      decoration: BoxDecoration(
        color: const Color(0xFFEFFFF8),
        borderRadius: BorderRadius.circular(18),
        boxShadow: const [
          BoxShadow(
            color: Color(0x14000000),
            blurRadius: 12,
            offset: Offset(0, 6),
          ),
        ],
        border: Border.all(color: const Color(0xFFE0F5EA)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(children: [
            Container(
              decoration: const BoxDecoration(
                color: Color(0xFF00C16A),
                shape: BoxShape.circle,
              ),
              padding: const EdgeInsets.all(6),
              child: const Icon(Icons.savings_rounded,
                  color: Colors.white, size: 16),
            ),
            const SizedBox(width: 8),
            Text('Price Estimation', style: titleStyle),
          ]),
          const SizedBox(height: 12),
          Row(
            children: const [
              _EstimationTile(
                labelTop: 'Total',
                amount: '\$0.00',
                subtitle: '0 items',
                amountColor: Color(0xFF00B15D),
              ),
              SizedBox(width: 12),
              _EstimationTile(
                labelTop: 'To Buy',
                amount: '\$0.00',
                subtitle: '0 left',
                amountColor: Color(0xFF3B36FF),
              ),
              SizedBox(width: 12),
              _EstimationTile(
                labelTop: 'Spent',
                amount: '\$0.00',
                subtitle: '0 done',
                amountColor: Color(0xFF8A00D4),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _EstimationTile extends StatelessWidget {
  final String labelTop;
  final String amount;
  final String subtitle;
  final Color amountColor;

  const _EstimationTile({
    required this.labelTop,
    required this.amount,
    required this.subtitle,
    required this.amountColor,
  });

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: Container(
        height: 90,
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: const Color(0xFFE9EEF4)),
        ),
        padding: const EdgeInsets.all(12),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(labelTop, style: const TextStyle(fontSize: 12, color: Colors.black54)),
            const SizedBox(height: 4),
            Text(amount,
                style: TextStyle(
                    fontWeight: FontWeight.w800, fontSize: 16, color: amountColor)),
            const Spacer(),
            Text(subtitle, style: const TextStyle(fontSize: 12, color: Colors.black45)),
          ],
        ),
      ),
    );
  }
}

class _EmptyStateCard extends StatelessWidget {
  final IconData icon;
  final String message;
  const _EmptyStateCard({required this.icon, required this.message});

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 180,
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(22),
        boxShadow: const [
          BoxShadow(color: Color(0x0F000000), blurRadius: 12, offset: Offset(0, 8))
        ],
      ),
      child: Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              padding: const EdgeInsets.all(18),
              decoration: const BoxDecoration(
                color: Color(0xFFF4F6FA),
                shape: BoxShape.circle,
              ),
              child: Icon(icon, size: 36, color: Colors.black38),
            ),
            const SizedBox(height: 12),
            Text(message, style: Theme.of(context).textTheme.titleMedium),
          ],
        ),
      ),
    );
  }
}

class _BottomNav extends StatelessWidget {
  final int currentIndex;
  const _BottomNav({required this.currentIndex});

  @override
  Widget build(BuildContext context) {
    return NavigationBar(
      selectedIndex: currentIndex,
      destinations: const [
        NavigationDestination(icon: Icon(Icons.home_outlined), label: 'Home'),
        NavigationDestination(icon: Icon(Icons.calendar_today), label: 'Weekly'),
        NavigationDestination(icon: Icon(Icons.category_outlined), label: 'Categories'),
      ],
      onDestinationSelected: (i) {
        if (i == 0) return;
        if (i == 1) {
          Navigator.pushNamed(context, '/weekly'); // ✅ now opens Weekly Planner
          return;
        }
        if (i == 2) Navigator.pushNamed(context, '/categories');
      },
    );
  }
}
