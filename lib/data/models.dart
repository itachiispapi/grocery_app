class GItem {
  final int? id;
  final String name;
  final double qty;
  final String unit;
  final String category;
  final double price;
  final String notes;
  final bool done;
  final bool active;
  final bool priority;
  final DateTime createdAt;

  GItem({
    this.id,
    required this.name,
    required this.qty,
    required this.unit,
    required this.category,
    required this.price,
    required this.notes,
    required this.done,
    required this.active,
    required this.priority,
    required this.createdAt,
  });

  GItem copyWith({
    int? id,
    String? name,
    double? qty,
    String? unit,
    String? category,
    double? price,
    String? notes,
    bool? done,
    bool? active,
    bool? priority,
    DateTime? createdAt,
  }) => GItem(
    id: id ?? this.id,
    name: name ?? this.name,
    qty: qty ?? this.qty,
    unit: unit ?? this.unit,
    category: category ?? this.category,
    price: price ?? this.price,
    notes: notes ?? this.notes,
    done: done ?? this.done,
    active: active ?? this.active,
    priority: priority ?? this.priority,
    createdAt: createdAt ?? this.createdAt,
  );

  Map<String, Object?> toMap() => {
    'id': id,
    'name': name,
    'qty': qty,
    'unit': unit,
    'category': category,
    'price': price,
    'notes': notes,
    'done': done ? 1 : 0,
    'active': active ? 1 : 0,
    'priority': priority ? 1 : 0,
    'created_at': createdAt.toIso8601String(),
  };

  static GItem fromMap(Map<String, Object?> m) => GItem(
    id: m['id'] as int?,
    name: m['name'] as String,
    qty: (m['qty'] as num).toDouble(),
    unit: m['unit'] as String,
    category: m['category'] as String,
    price: (m['price'] as num).toDouble(),
    notes: (m['notes'] as String?) ?? '',
    done: (m['done'] as int) == 1,
    active: (m['active'] as int) == 1,
    priority: (m['priority'] as int) == 1,
    createdAt: DateTime.parse(m['created_at'] as String),
  );
}
