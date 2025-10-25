import 'package:flutter/material.dart';
import '../data/app_db.dart';
import '../data/models.dart';

class CategoryItemsScreen extends StatefulWidget {
  final String category;
  const CategoryItemsScreen({super.key, required this.category});

  @override
  State<CategoryItemsScreen> createState() => _CategoryItemsScreenState();
}

class _CategoryItemsScreenState extends State<CategoryItemsScreen> {
  late Future<List<GItem>> _items;

  @override
  void initState() {
    super.initState();
    _load();
  }

  void _load() {
    _items = AppDb.I.items(category: widget.category, priorityFirst: true);
  }

  void _refresh() => setState(_load);

  Future<void> _toggleDone(GItem it) async {
    await AppDb.I.updateItem(it.copyWith(done: !it.done));
    _refresh();
  }

  Future<void> _togglePriority(GItem it) async {
    await AppDb.I.updateItem(it.copyWith(priority: !it.priority));
    _refresh();
  }

  Future<void> _toggleActive(GItem it) async {
    await AppDb.I.updateItem(it.copyWith(active: !it.active));
    _refresh();
  }

  Future<void> _delete(GItem it) async {
    if (it.id != null) await AppDb.I.deleteItem(it.id!);
    _refresh();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF6F7FB),
      appBar: AppBar(
        title: Text(widget.category, style: const TextStyle(fontWeight: FontWeight.w700)),
      ),
      body: FutureBuilder<List<GItem>>(
        future: _items,
        builder: (context, snap) {
          if (!snap.hasData) {
            return const Center(child: CircularProgressIndicator());
          }
          final items = snap.data!;
          if (items.isEmpty) {
            return const Center(child: Text('No items yet'));
          }
          return ListView.separated(
            padding: const EdgeInsets.all(16),
            itemCount: items.length,
            separatorBuilder: (_, __) => const SizedBox(height: 8),
            itemBuilder: (_, i) {
              final it = items[i];
              final total = (it.qty * it.price).toStringAsFixed(2);
              return ListTile(
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                tileColor: Colors.white,
                title: Text(
                  '${it.name} • ${it.qty} ${it.unit} • \$${total}',
                  style: TextStyle(
                    decoration: it.done ? TextDecoration.lineThrough : null,
                    color: it.done ? Colors.black54 : null,
                    fontWeight: it.priority ? FontWeight.w700 : FontWeight.w500,
                  ),
                ),
                subtitle: it.notes.isEmpty ? null : Text(it.notes),
                leading: IconButton(
                  tooltip: it.priority ? 'Unmark priority' : 'Mark priority',
                  icon: Icon(it.priority ? Icons.star : Icons.star_border, color: Colors.amber),
                  onPressed: () => _togglePriority(it),
                ),
                trailing: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    IconButton(
                      tooltip: it.active ? 'Set inactive' : 'Activate',
                      icon: Icon(it.active ? Icons.radio_button_checked : Icons.radio_button_unchecked,
                          color: it.active ? const Color(0xFF3B36FF) : Colors.black45),
                      onPressed: () => _toggleActive(it),
                    ),
                    IconButton(
                      tooltip: it.done ? 'Mark not done' : 'Mark done',
                      icon: Icon(it.done ? Icons.check_box : Icons.check_box_outline_blank,
                          color: it.done ? const Color(0xFF00B15D) : Colors.black54),
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
    );
  }
}