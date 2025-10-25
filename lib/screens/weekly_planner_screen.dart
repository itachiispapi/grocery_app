import 'package:flutter/material.dart';
import '../data/app_db.dart';

class WeeklyPlannerScreen extends StatefulWidget {
  const WeeklyPlannerScreen({super.key});

  @override
  State<WeeklyPlannerScreen> createState() => _WeeklyPlannerScreenState();
}

class _WeeklyPlannerScreenState extends State<WeeklyPlannerScreen> {
  late DateTime _weekStart;
  int _selectedIndex = 0;

  @override
  void initState() {
    super.initState();
    final now = DateTime.now();
    _weekStart = _startOfWeek(now);
    _selectedIndex = now.weekday == DateTime.sunday ? 6 : now.weekday - 1;
  }

  DateTime _startOfWeek(DateTime d) {
    final int delta = (d.weekday + 6) % 7;
    return DateTime(d.year, d.month, d.day).subtract(Duration(days: delta));
  }

  String _monthName(int m) => const [
        'Jan','Feb','Mar','Apr','May','Jun','Jul','Aug','Sep','Oct','Nov','Dec'
      ][m - 1];

  String _weekTitle(DateTime start) {
    final end = start.add(const Duration(days: 6));
    if (start.month == end.month && start.year == end.year) {
      return 'Week of ${_monthName(start.month)} ${start.day} - ${end.day}, ${start.year}';
    } else if (start.year == end.year) {
      return 'Week of ${_monthName(start.month)} ${start.day} - ${_monthName(end.month)} ${end.day}, ${start.year}';
    } else {
      return 'Week of ${_monthName(start.month)} ${start.day}, ${start.year} - ${_monthName(end.month)} ${end.day}, ${end.year}';
    }
  }

  List<DateTime> get _days => List.generate(7, (i) => _weekStart.add(Duration(days: i)));

  void _prevWeek() => setState(() => _weekStart = _weekStart.subtract(const Duration(days: 7)));
  void _nextWeek() => setState(() => _weekStart = _weekStart.add(const Duration(days: 7)));
  void _selectDay(int i) => setState(() => _selectedIndex = i);

  @override
  Widget build(BuildContext context) {
    final selectedDate = _days[_selectedIndex];
    final dateKey = selectedDate.toIso8601String().substring(0, 10);
    return Scaffold(
      backgroundColor: const Color(0xFFF6F7FB),
      body: SafeArea(
        child: _WeeklyBody(
          weekTitle: _weekTitle(_weekStart),
          days: _days,
          selectedIndex: _selectedIndex,
          onTapPrev: _prevWeek,
          onTapNext: _nextWeek,
          onSelectDay: _selectDay,
          dateKey: dateKey,
        ),
      ),
    );
  }
}

class _WeeklyBody extends StatelessWidget {
  final String weekTitle;
  final List<DateTime> days;
  final int selectedIndex;
  final String dateKey;
  final VoidCallback onTapPrev;
  final VoidCallback onTapNext;
  final ValueChanged<int> onSelectDay;

  const _WeeklyBody({
    required this.weekTitle,
    required this.days,
    required this.selectedIndex,
    required this.dateKey,
    required this.onTapPrev,
    required this.onTapNext,
    required this.onSelectDay,
  });

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      padding: const EdgeInsets.only(bottom: 24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // === HEADER ===
          Container(
            margin: const EdgeInsets.only(bottom: 12),
            padding: const EdgeInsets.fromLTRB(12, 16, 16, 20),
            decoration: const BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: [Color(0xFF7E56FF), Color(0xFFFF6AA0)],
              ),
              borderRadius: BorderRadius.only(
                bottomLeft: Radius.circular(28),
                bottomRight: Radius.circular(28),
              ),
            ),
            child: Column(
              children: [
                Row(
                  children: [
                    IconButton(
                      icon: const Icon(Icons.arrow_back_ios_new_rounded, color: Colors.white),
                      onPressed: () => Navigator.pop(context),
                    ),
                    const SizedBox(width: 8),
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: const [
                        Text('Weekly Planner', style: TextStyle(color: Colors.white, fontSize: 20, fontWeight: FontWeight.bold)),
                        Text('Plan your meals & groceries', style: TextStyle(color: Colors.white70)),
                      ],
                    ),
                  ],
                ),
                const SizedBox(height: 16),
                Container(
                  decoration: BoxDecoration(
                    color: Colors.white.withOpacity(.12),
                    borderRadius: BorderRadius.circular(22),
                    border: Border.all(color: Colors.white.withOpacity(.25)),
                  ),
                  padding: const EdgeInsets.fromLTRB(12, 12, 12, 14),
                  child: Column(
                    children: [
                      Row(
                        children: [
                          IconButton(icon: const Icon(Icons.arrow_left, color: Colors.white), onPressed: onTapPrev),
                          const Spacer(),
                          Text(weekTitle, style: const TextStyle(color: Colors.white, fontWeight: FontWeight.w700)),
                          const Spacer(),
                          IconButton(icon: const Icon(Icons.arrow_right, color: Colors.white), onPressed: onTapNext),
                        ],
                      ),
                      const SizedBox(height: 10),
                      SizedBox(
                        height: 72,
                        child: ListView.builder(
                          scrollDirection: Axis.horizontal,
                          itemCount: days.length,
                          itemBuilder: (context, i) {
                            final d = days[i];
                            final label = const ['Mon','Tue','Wed','Thu','Fri','Sat','Sun'][i];
                            final selected = i == selectedIndex;
                            return GestureDetector(
                              onTap: () => onSelectDay(i),
                              child: Container(
                                margin: const EdgeInsets.symmetric(horizontal: 6),
                                padding: const EdgeInsets.all(12),
                                decoration: BoxDecoration(
                                  color: selected ? Colors.white : Colors.transparent,
                                  borderRadius: BorderRadius.circular(16),
                                ),
                                child: Column(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: [
                                    Text(label, style: TextStyle(color: selected ? Colors.black : Colors.white)),
                                    Text('${d.day}', style: TextStyle(color: selected ? Colors.black : Colors.white)),
                                  ],
                                ),
                              ),
                            );
                          },
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),

          // === MEAL SECTIONS ===
          _MealSection(title: 'Breakfast', mealType: 'breakfast', dateKey: dateKey),
          _MealSection(title: 'Lunch', mealType: 'lunch', dateKey: dateKey),
          _MealSection(title: 'Dinner', mealType: 'dinner', dateKey: dateKey),
        ],
      ),
    );
  }
}

// === MEAL SECTION ===
class _MealSection extends StatefulWidget {
  final String title;
  final String mealType;
  final String dateKey;

  const _MealSection({
    required this.title,
    required this.mealType,
    required this.dateKey,
  });

  @override
  State<_MealSection> createState() => _MealSectionState();
}

class _MealSectionState extends State<_MealSection> {
  List<Map<String, dynamic>> _meals = [];

  @override
  void initState() {
    super.initState();
    _loadMeals();
  }

  Future<void> _loadMeals() async {
    final data = await AppDb.I.getMeals(widget.dateKey, widget.mealType);
    setState(() => _meals = data);
  }

  Future<void> _addMeal() async {
    final controller = TextEditingController();
    final result = await showDialog<String>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: Text('Add ${widget.title}'),
        content: TextField(controller: controller, decoration: const InputDecoration(hintText: 'Enter meal name')),
        actions: [
          TextButton(onPressed: () => Navigator.pop(ctx), child: const Text('Cancel')),
          ElevatedButton(onPressed: () => Navigator.pop(ctx, controller.text.trim()), child: const Text('Add')),
        ],
      ),
    );

    if (result != null && result.isNotEmpty) {
      await AppDb.I.addMeal(
        name: result,
        category: 'Default',
        qty: 1,
        unit: 'pcs',
        mealType: widget.mealType,
        dateKey: widget.dateKey,
      );
      _loadMeals();
    }
  }

  Future<void> _deleteMeal(int id) async {
    await AppDb.I.deleteMeal(id);
    _loadMeals();
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(16),
      child: Container(
        decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(16)),
        child: Column(
          children: [
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(color: Colors.grey[200], borderRadius: const BorderRadius.only(topLeft: Radius.circular(16), topRight: Radius.circular(16))),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(widget.title, style: const TextStyle(fontWeight: FontWeight.bold)),
                  IconButton(icon: const Icon(Icons.add), onPressed: _addMeal),
                ],
              ),
            ),
            if (_meals.isEmpty)
              GestureDetector(
                onTap: _addMeal,
                child: Container(
                  padding: const EdgeInsets.all(16),
                  child: Text('Plan your ${widget.title.toLowerCase()}', style: const TextStyle(color: Colors.grey)),
                ),
              )
            else
              Column(
                children: _meals.map((m) => ListTile(
                  title: Text(m['name']),
                  trailing: IconButton(
                    icon: const Icon(Icons.delete, color: Colors.redAccent),
                    onPressed: () => _deleteMeal(m['id']),
                  ),
                )).toList(),
              ),
          ],
        ),
      ),
    );
  }
}
