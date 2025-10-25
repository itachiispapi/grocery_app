import 'package:flutter/material.dart';
import '../data/app_db.dart';
import '../data/models.dart';
import '../main.dart' show routeObserver;

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

class _HomeBody extends StatefulWidget {
  const _HomeBody();
  @override
  State<_HomeBody> createState() => _HomeBodyState();
}

class _HomeBodyState extends State<_HomeBody> with RouteAware {
  late Future<Map<String, int>> _counters;
  late Future<Map<String, num>> _sums;
  late Future<List<GItem>> _items;

  @override
  void initState() {
    super.initState();
    _refresh();
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    final route = ModalRoute.of(context);
    if (route != null) routeObserver.subscribe(this, route);
  }

  @override
  void dispose() {
    routeObserver.unsubscribe(this);
    super.dispose();
  }

  @override
  void didPopNext() {
    setState(_refresh);
  }

  void _refresh() {
    _counters = AppDb.I.counters();
    _sums = AppDb.I.sums();
    _items = AppDb.I.items(active: true, done: false, priorityFirst: true);
  }

  Future<void> _toggleDone(GItem it) async {
    await AppDb.I.updateItem(it.copyWith(done: !it.done));
    setState(_refresh);
  }

  Future<void> _togglePriority(GItem it) async {
    await AppDb.I.updateItem(it.copyWith(priority: !it.priority));
    setState(_refresh);
  }

  Future<void> _delete(GItem it) async {
    if (it.id != null) await AppDb.I.deleteItem(it.id!);
    setState(_refresh);
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return SafeArea(
      child: SingleChildScrollView(
        padding: const EdgeInsets.only(bottom: 24),
        child: Column(
          children: [
            // Top Header
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
                  FutureBuilder<Map<String,int>>(
                    future: _counters,
                    builder: (context, snap) {
                      final c = snap.data ?? {'total':0,'active':0,'done':0,'priority':0};
                      return Row(
                        children: [
                          _StatPill(label: 'Total', value: '${c['total'] ?? 0}'),
                          const SizedBox(width: 12),
                          _StatPill(label: 'Active', value: '${c['active'] ?? 0}'),
                          const SizedBox(width: 12),
                          _StatPill(label: 'Done', value: '${c['done'] ?? 0}'),
                          const SizedBox(width: 12),
                          _StatPill(label: 'Priority', value: '${c['priority'] ?? 0}', icon: Icons.star),
                        ],
                      );
                    },
                  ),
                  const SizedBox(height: 16),
                  const _SearchField(),
                ],
              ),
            ),

            const SizedBox(height: 16),

            // Button Row: Add, Weekly, Reset
            SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: Row(
                children: [
                  _BigButton(
                    label: 'Add Item',
                    icon: Icons.add,
                    background: const Color(0xFF0AD06E),
                    onTap: () async {
                      final added = await Navigator.pushNamed(context, '/add');
                      if (added == true && mounted) setState(_refresh);
                    },
                  ),
                  const SizedBox(width: 12),
                  _BigButton(
                    label: 'Weekly Plan',
                    icon: Icons.calendar_today_rounded,
                    background: const Color(0xFF9E65FF),
                    onTap: () async {
                      await Navigator.pushNamed(context, '/weekly');
                      if (mounted) setState(_refresh);
                    },
                  ),
                  const SizedBox(width: 12),
                  _BigButton(
                    label: 'Reset App',
                    icon: Icons.restart_alt,
                    background: Colors.redAccent,
                    onTap: () async {
                      final confirm = await showDialog<bool>(
                        context: context,
                        builder: (ctx) => AlertDialog(
                          title: const Text('Reset App'),
                          content: const Text('Are you sure you want to reset the app? All data will be lost.'),
                          actions: [
                            TextButton(onPressed: () => Navigator.pop(ctx, false), child: const Text('Cancel')),
                            ElevatedButton(onPressed: () => Navigator.pop(ctx, true), child: const Text('Reset')),
                          ],
                        ),
                      );

                      if (confirm == true) {
                        await AppDb.I.resetApp();
                        if (mounted) setState(_refresh);
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(content: Text('App reset successfully!')),
                        );
                      }
                    },
                  ),
                ],
              ),
            ),

            const SizedBox(height: 16),

            // Price Estimation Card
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: FutureBuilder<List<dynamic>>(
                future: Future.wait([_sums, _counters]),
                builder: (context, snap) {
                  if (!snap.hasData) {
                    return const _PriceEstimationCard(
                      total: 0.0, toBuy: 0.0, spent: 0.0,
                      totalCount: 0, leftCount: 0, doneCount: 0,
                    );
                  }
                  final sums = snap.data![0] as Map<String, num>;
                  final cnts = snap.data![1] as Map<String, int>;

                  return _PriceEstimationCard(
                    total: (sums['total'] ?? 0).toDouble(),
                    toBuy: (sums['toBuy'] ?? 0).toDouble(),
                    spent: (sums['spent'] ?? 0).toDouble(),
                    totalCount: cnts['total'] ?? 0,
                    leftCount: cnts['active'] ?? 0,
                    doneCount: cnts['done'] ?? 0,
                  );
                },
              ),
            ),

            const SizedBox(height: 24),

            // Item List
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: FutureBuilder<List<GItem>>(
                future: _items,
                builder: (context, snap) {
                  if (!snap.hasData) {
                    return const SizedBox(
                      height: 120,
                      child: Center(child: CircularProgressIndicator()),
                    );
                  }
                  final items = snap.data!;
                  if (items.isEmpty) {
                    return const _EmptyStateCard(
                      icon: Icons.shopping_bag_outlined,
                      message: 'No items yet',
                    );
                  }

                  return ListView.separated(
                    physics: const NeverScrollableScrollPhysics(),
                    shrinkWrap: true,
                    itemCount: items.length,
                    separatorBuilder: (_, __) => const SizedBox(height: 8),
                    itemBuilder: (_, i) {
                      final it = items[i];
                      final total = (it.qty * it.price).toStringAsFixed(2);
                      return ListTile(
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                        tileColor: Colors.white,
                        contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
                        leading: IconButton(
                          tooltip: it.priority ? 'Unmark priority' : 'Mark priority',
                          icon: Icon(it.priority ? Icons.star : Icons.star_border,
                              color: it.priority ? Colors.amber : Colors.black38),
                          onPressed: () => _togglePriority(it),
                        ),
                        title: Text(
                          '${it.name} • ${it.qty} ${it.unit} • \$${total}',
                          style: TextStyle(
                            fontWeight: it.priority ? FontWeight.w700 : FontWeight.w500,
                            decoration: it.done ? TextDecoration.lineThrough : null,
                            color: it.done ? Colors.black54 : null,
                          ),
                        ),
                        subtitle: Text(
                          it.category,
                          style: const TextStyle(color: Colors.black54),
                        ),
                        trailing: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            IconButton(
                              tooltip: it.done ? 'Mark not done' : 'Mark done',
                              icon: Icon(
                                it.done ? Icons.check_box : Icons.check_box_outline_blank,
                                color: it.done ? const Color(0xFF00B15D) : Colors.black54,
                              ),
                              onPressed: () => _toggleDone(it),
                            ),
                            IconButton(
                              tooltip: 'Delete',
                              icon: const Icon(Icons.delete_outline),
                              onPressed: () => _delete(it),
                            ),
                          ],
                        ),
                      );
                    },
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// ------------------ HELPER WIDGETS ------------------

class _StatPill extends StatelessWidget {
  final String label;
  final String value;
  final IconData? icon;

  const _StatPill({this.label = '', this.value = '', this.icon, super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(.2),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        children: [
          if (icon != null) Icon(icon, size: 16, color: Colors.white),
          if (icon != null) const SizedBox(width: 4),
          if (label.isNotEmpty)
            Text(label, style: const TextStyle(color: Colors.white)),
          if (label.isNotEmpty) const SizedBox(width: 4),
          Text(value, style: const TextStyle(color: Colors.white, fontWeight: FontWeight.w700)),
        ],
      ),
    );
  }
}

class _SearchField extends StatelessWidget {
  const _SearchField({super.key});

  @override
  Widget build(BuildContext context) {
    return TextField(
      decoration: InputDecoration(
        hintText: 'Search items...',
        filled: true,
        fillColor: Colors.white,
        prefixIcon: const Icon(Icons.search),
        contentPadding: const EdgeInsets.symmetric(vertical: 0, horizontal: 12),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide.none,
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
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        height: 48,
        padding: const EdgeInsets.symmetric(horizontal: 16),
        decoration: BoxDecoration(
          color: background,
          borderRadius: BorderRadius.circular(12),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(icon, color: Colors.white),
            const SizedBox(width: 8),
            Text(
              label,
              style: const TextStyle(color: Colors.white, fontWeight: FontWeight.w700),
            ),
          ],
        ),
      ),
    );
  }
}

class _PriceEstimationCard extends StatelessWidget {
  final double total;
  final double toBuy;
  final double spent;
  final int totalCount;
  final int leftCount;
  final int doneCount;

  const _PriceEstimationCard({
    required this.total,
    required this.toBuy,
    required this.spent,
    required this.totalCount,
    required this.leftCount,
    required this.doneCount,
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [BoxShadow(color: Colors.black12, blurRadius: 8)],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text('Price Estimation', style: TextStyle(fontWeight: FontWeight.w700)),
          const SizedBox(height: 8),
          _EstimationTile(label: 'Total', value: total),
          _EstimationTile(label: 'To Buy', value: toBuy),
          _EstimationTile(label: 'Spent', value: spent),
        ],
      ),
    );
  }
}

class _EstimationTile extends StatelessWidget {
  final String label;
  final double value;

  const _EstimationTile({required this.label, required this.value, super.key});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 2),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(label, style: const TextStyle(fontWeight: FontWeight.w500)),
          Text('\$${value.toStringAsFixed(2)}', style: const TextStyle(fontWeight: FontWeight.w700)),
        ],
      ),
    );
  }
}

class _EmptyStateCard extends StatelessWidget {
  final IconData icon;
  final String message;

  const _EmptyStateCard({required this.icon, required this.message, super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 120,
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
      ),
      child: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(icon, size: 40, color: Colors.black38),
            const SizedBox(height: 8),
            Text(message, style: const TextStyle(color: Colors.black38)),
          ],
        ),
      ),
    );
  }
}

class _BottomNav extends StatelessWidget {
  final int currentIndex;
  const _BottomNav({required this.currentIndex, super.key});

  @override
  Widget build(BuildContext context) {
    return NavigationBar(
      selectedIndex: currentIndex,
      destinations: const [
        NavigationDestination(icon: Icon(Icons.home_outlined), label: 'Home'),
        NavigationDestination(icon: Icon(Icons.calendar_today_rounded), label: 'Weekly'),
        NavigationDestination(icon: Icon(Icons.category_outlined), label: 'Categories'),
      ],
      onDestinationSelected: (i) {
        switch (i) {
          case 0:
            Navigator.popUntil(context, ModalRoute.withName('/'));
            break;
          case 1:
            Navigator.pushNamed(context, '/weekly');
            break;
          case 2:
            Navigator.pushNamed(context, '/categories');
            break;
        }
      },
    );
  }
}
