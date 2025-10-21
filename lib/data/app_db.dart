import 'package:path/path.dart';
import 'package:path_provider/path_provider.dart';
import 'package:sqflite/sqflite.dart';
import 'models.dart';

class AppDb {
  AppDb._();
  static final AppDb I = AppDb._();

  static const _name = 'grocery.db';
  static const _version = 1;
  Database? _db;

  Future<Database> get db async {
    if (_db != null) return _db!;
    final dir = await getApplicationDocumentsDirectory();
    final path = join(dir.path, _name);
    _db = await openDatabase(path, version: _version, onCreate: _onCreate);
    return _db!;
  }

  Future<void> _onCreate(Database d, int v) async {
    await d.execute('''
      CREATE TABLE items(
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        name TEXT NOT NULL,
        qty REAL NOT NULL,
        unit TEXT NOT NULL,
        category TEXT NOT NULL,
        price REAL NOT NULL,
        notes TEXT,
        done INTEGER NOT NULL,
        active INTEGER NOT NULL,
        priority INTEGER NOT NULL,
        created_at TEXT NOT NULL
      )
    ''');

    await d.execute('''
      CREATE TABLE meal_plan(
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        weekday INTEGER NOT NULL, -- 1..7 (Mon..Sun)
        meal TEXT NOT NULL,       -- 'breakfast' | 'lunch' | 'dinner'
        item_id INTEGER NOT NULL,
        FOREIGN KEY(item_id) REFERENCES items(id) ON DELETE CASCADE
      )
    ''');
  }

  // CRUD: items
  Future<int> insertItem(GItem it) async =>
      (await db).insert('items', it.toMap());

  Future<int> updateItem(GItem it) async =>
      (await db).update('items', it.toMap(), where: 'id=?', whereArgs: [it.id]);

  Future<int> deleteItem(int id) async =>
      (await db).delete('items', where: 'id=?', whereArgs: [id]);

  Future<List<GItem>> items({
    String? category,
    bool? done,
    bool? active,
    bool? priority,
    String? query,
    bool priorityFirst = false,
  }) async {
    final w = <String>[];
    final a = <Object?>[];
    if (category != null) { w.add('category=?'); a.add(category); }
    if (done != null)     { w.add('done=?');     a.add(done ? 1 : 0); }
    if (active != null)   { w.add('active=?');   a.add(active ? 1 : 0); }
    if (priority != null) { w.add('priority=?'); a.add(priority ? 1 : 0); }
    if (query != null && query.trim().isNotEmpty) {
      w.add('name LIKE ?'); a.add('%${query.trim()}%');
    }
    final rows = await (await db).query(
      'items',
      where: w.isEmpty ? null : w.join(' AND '),
      whereArgs: w.isEmpty ? null : a,
      orderBy: priorityFirst ? 'priority DESC, created_at DESC' : 'created_at DESC',
    );
    return rows.map(GItem.fromMap).toList();
  }

  // price/counters
  Future<Map<String, num>> sums() async {
  final d = await db;

  Future<num> _sum(String where) async {
    final rows = await d.rawQuery('SELECT COALESCE(SUM(price*qty), 0.0) AS s FROM items $where');
    final v = rows.first['s'];
    if (v is int) return v;
    if (v is double) return v;
    return 0;
  }

  final total = await _sum('');
  final toBuy = await _sum('WHERE done=0 AND active=1');
  final spent = await _sum('WHERE done=1');

  return {'total': total, 'toBuy': toBuy, 'spent': spent};
}

Future<Map<String, int>> counters() async {
  final d = await db;

  Future<int> _c(String where) async {
    return Sqflite.firstIntValue(
              await d.rawQuery('SELECT COUNT(*) FROM items $where'),
           ) ?? 0;
  }

  final total = await _c('');
  final active = await _c('WHERE active=1 AND done=0');
  final done = await _c('WHERE done=1');
  final priority = await _c('WHERE priority=1 AND done=0');

  return {'total': total, 'active': active, 'done': done, 'priority': priority};
}

  // meal plan
  Future<int> addMeal({required int weekday, required String meal, required int itemId}) async =>
      (await db).insert('meal_plan', {'weekday': weekday, 'meal': meal, 'item_id': itemId});

  Future<int> deleteMeal(int id) async =>
      (await db).delete('meal_plan', where: 'id=?', whereArgs: [id]);
}
