import 'package:path/path.dart';
import 'package:path_provider/path_provider.dart';
import 'package:sqflite/sqflite.dart';
import 'models.dart';

class AppDb {
  AppDb._();
  static final AppDb I = AppDb._();

  static const _name = 'grocery.db';
  static const _version = 2; // <-- bump version for migration
  Database? _db;

  Future<Database> get db async {
    if (_db != null) return _db!;
    final dir = await getApplicationDocumentsDirectory();
    final path = join(dir.path, _name);

    _db = await openDatabase(
      path,
      version: _version,
      onCreate: _onCreate,
      onUpgrade: _onUpgrade,
    );
    return _db!;
  }

  // --- Migration for existing users ---
  Future<void> _onUpgrade(Database db, int oldVersion, int newVersion) async {
    if (oldVersion < 2) {
      await db.execute('''
        CREATE TABLE meals(
          id INTEGER PRIMARY KEY AUTOINCREMENT,
          name TEXT NOT NULL,
          category TEXT NOT NULL,
          qty REAL NOT NULL,
          unit TEXT NOT NULL,
          mealType TEXT NOT NULL,
          dateKey TEXT NOT NULL
        )
      ''');
    }
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
        weekday INTEGER NOT NULL,
        meal TEXT NOT NULL,
        item_id INTEGER NOT NULL,
        FOREIGN KEY(item_id) REFERENCES items(id) ON DELETE CASCADE
      )
    ''');

    await d.execute('''
      CREATE TABLE meals(
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        name TEXT NOT NULL,
        category TEXT NOT NULL,
        qty REAL NOT NULL,
        unit TEXT NOT NULL,
        mealType TEXT NOT NULL,
        dateKey TEXT NOT NULL
      )
    ''');
  }

  // --- RESET APP ---
  Future<void> resetApp() async {
    final d = await db;
    // Delete all data from tables
    await d.delete('items');
    await d.delete('meal_plan');
    await d.delete('meals');
  }

  // --- MEAL METHODS ---
  Future<int> addMeal({
    required String name,
    required String category,
    required double qty,
    required String unit,
    required String mealType,
    required String dateKey,
  }) async {
    final db = await this.db;
    return db.insert('meals', {
      'name': name,
      'category': category,
      'qty': qty,
      'unit': unit,
      'mealType': mealType,
      'dateKey': dateKey,
    });
  }

  Future<List<Map<String, dynamic>>> getMeals(String dateKey, String mealType) async {
    final db = await this.db;
    return db.query(
      'meals',
      where: 'dateKey=? AND mealType=?',
      whereArgs: [dateKey, mealType],
    );
  }

  Future<int> deleteMeal(int id) async {
    final db = await this.db;
    return db.delete('meals', where: 'id=?', whereArgs: [id]);
  }

  // --- ITEM METHODS ---
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
      orderBy: priorityFirst
          ? 'priority DESC, datetime(created_at) DESC'
          : 'datetime(created_at) DESC',
    );
    return rows.map(GItem.fromMap).toList();
  }

  Future<Map<String, num>> sums() async {
    final d = await db;

    Future<num> sum(String where) async {
      final rows = await d.rawQuery('SELECT COALESCE(SUM(price*qty), 0.0) AS s FROM items $where');
      final v = rows.first['s'];
      if (v is int) return v;
      if (v is double) return v;
      return 0;
    }

    final total = await sum('');
    final toBuy = await sum('WHERE done=0 AND active=1');
    final spent = await sum('WHERE done=1');

    return {'total': total, 'toBuy': toBuy, 'spent': spent};
  }

  Future<Map<String, int>> counters() async {
    final d = await db;

    Future<int> c(String where) async {
      return Sqflite.firstIntValue(
        await d.rawQuery('SELECT COUNT(*) FROM items $where'),
      ) ?? 0;
    }

    final total = await c('');
    final active = await c('WHERE active=1 AND done=0');
    final done = await c('WHERE done=1');
    final priority = await c('WHERE priority=1 AND active=1 AND done=0');

    return {'total': total, 'active': active, 'done': done, 'priority': priority};
  }

  Future<int> addMealToPlan({
    required int weekday,
    required String meal,
    required int itemId,
  }) async {
    final db = await this.db;
    return await db.insert('meal_plan', {
      'weekday': weekday,
      'meal': meal,
      'item_id': itemId,
    });
  }

  Future<int> deleteMealFromPlan(int id) async {
    final db = await this.db;
    return await db.delete('meal_plan', where: 'id=?', whereArgs: [id]);
  }
}
