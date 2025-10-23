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
                          _StatPill(label: '', value: '${c['priority'] ?? 0}', icon: Icons.star),
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

            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: Row(
                children: [
                  Expanded(
                    child: _BigButton(
                      label: 'Add Item',
                      icon: Icons.add,
                      background: const Color(0xFF0AD06E),
                      onTap: () async {
                        final added = await Navigator.pushNamed(context, '/add');
                        if (added == true && mounted) setState(_refresh);
                      },
                    ),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: _BigButton(
                      label: 'Weekly Plan',
                      icon: Icons.calendar_today_rounded,
                      background: const Color(0xFF9E65FF),
                      onTap: () async {
                        await Navigator.pushNamed(context, '/weekly');
                        if (mounted) setState(_refresh);
                      },
                    ),
                  ),
                ],
              ),
            ),

            const SizedBox(height: 16),

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
  });

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
            offset: const Offset(0, 6),
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
            children: [
              _EstimationTile(
                labelTop: 'Total',
                amount: '\$${total.toStringAsFixed(2)}',
                subtitle: '$totalCount items',
                amountColor: const Color(0xFF00B15D),
              ),
              const SizedBox(width: 12),
              _EstimationTile(
                labelTop: 'To Buy',
                amount: '\$${toBuy.toStringAsFixed(2)}',
                subtitle: '$leftCount left',
                amountColor: const Color(0xFF3B36FF),
              ),
              const SizedBox(width: 12),
              _EstimationTile(
                labelTop: 'Spent',
                amount: '\$${spent.toStringAsFixed(2)}',
                subtitle: '$doneCount done',
                amountColor: const Color(0xFF8A00D4),
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
        if (i == 0) {
          Navigator.popUntil(context, ModalRoute.withName('/'));
          return;
        }
        if (i == 1) {
          Navigator.pushNamed(context, '/weekly');
          return;
        }
        if (i == 2) Navigator.pushNamed(context, '/categories');
      },
    );
  }
}
