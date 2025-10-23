import 'dart:math' as math;
import 'package:flutter/material.dart';
import '../widgets/weekly_list_popup.dart';
import '../data/app_db.dart';

class WeeklyPlannerScreen extends StatefulWidget {
  const WeeklyPlannerScreen({super.key});

  @override
  State<WeeklyPlannerScreen> createState() => _WeeklyPlannerScreenState();
}

class _WeeklyPlannerScreenState extends State<WeeklyPlannerScreen> {
  late DateTime _weekStart;
  int _selectedIndex = 0;
  bool _mutated = false;

  @override
  void initState() {
    super.initState();
    final now = DateTime.now();
    _weekStart = _startOfWeek(now);
    _selectedIndex = now.weekday == DateTime.sunday ? 6 : now.weekday - 1;
  }

  DateTime _startOfWeek(DateTime d) {
    final int delta = (d.weekday + 6) % 7;
    final monday = DateTime(d.year, d.month, d.day).subtract(Duration(days: delta));
    return DateTime(monday.year, monday.month, monday.day);
  }

  String _monthName(int m) => const [
        'Jan','Feb','Mar','Apr','May','Jun','Jul','Aug','Sep','Oct','Nov','Dec'
      ][m - 1];

  String _weekTitle(DateTime start) {
    final end = start.add(const Duration(days: 6));
    final sameMonth = start.month == end.month;
    final sameYear  = start.year == end.year;

    if (sameMonth && sameYear) {
      return 'Week of ${_monthName(start.month)} ${start.day} - ${end.day}, ${start.year}';
    } else if (!sameMonth && sameYear) {
      return 'Week of ${_monthName(start.month)} ${start.day} - ${_monthName(end.month)} ${end.day}, ${start.year}';
    } else {
      return 'Week of ${_monthName(start.month)} ${start.day}, ${start.year} - ${_monthName(end.month)} ${end.day}, ${end.year}';
    }
  }

  List<DateTime> get _days =>
      List.generate(7, (i) => _weekStart.add(Duration(days: i)));

  void _prevWeek() => setState(() => _weekStart = _weekStart.subtract(const Duration(days: 7)));
  void _nextWeek() => setState(() => _weekStart = _weekStart.add(const Duration(days: 7)));
  void _selectDay(int i) => setState(() => _selectedIndex = i);

  @override
  Widget build(BuildContext context) {
    return WillPopScope(
      onWillPop: () async {
        Navigator.pop(context, _mutated);
        return false;
      },
      child: Scaffold(
        backgroundColor: const Color(0xFFF6F7FB),
        body: SafeArea(
          child: _WeeklyBody(
            weekTitle: _weekTitle(_weekStart),
            days: _days,
            selectedIndex: _selectedIndex,
            onTapPrev: _prevWeek,
            onTapNext: _nextWeek,
            onSelectDay: _selectDay,
          ),
        ),
        bottomNavigationBar: const _BottomNav(index: 1),
      ),
    );
  }
}

class _WeeklyBody extends StatelessWidget {
  final String weekTitle;
  final List<DateTime> days;
  final int selectedIndex;
  final VoidCallback onTapPrev;
  final VoidCallback onTapNext;
  final ValueChanged<int> onSelectDay;

  const _WeeklyBody({
    required this.weekTitle,
    required this.days,
    required this.selectedIndex,
    required this.onTapPrev,
    required this.onTapNext,
    required this.onSelectDay,
  });

  @override
  Widget build(BuildContext context) {
    final title = Theme.of(context).textTheme.titleLarge?.copyWith(
          color: Colors.white, fontWeight: FontWeight.w800,
        );
    final subtitle = TextStyle(color: Colors.white.withOpacity(.95));

    return SingleChildScrollView(
      padding: const EdgeInsets.only(bottom: 24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
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
                    _HeaderIconButton(
                      icon: Icons.arrow_back_ios_new_rounded,
                      onTap: () => Navigator.pop(context, false),
                    ),
                    const SizedBox(width: 8),
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text('Weekly Planner', style: title),
                        Text('Plan your meals & groceries', style: subtitle),
                      ],
                    ),
                    const Spacer(),
                    _HeaderIconButton(
                      icon: Icons.calendar_month_rounded,
                      onTap: () {},
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
                          _CircleArrow(left: true, onTap: onTapPrev),
                          const Spacer(),
                          Text(
                            weekTitle,
                            style: const TextStyle(
                              color: Colors.white, fontWeight: FontWeight.w700),
                          ),
                          const Spacer(),
                          _CircleArrow(left: false, onTap: onTapNext),
                        ],
                      ),
                      const SizedBox(height: 10),
                      MediaQuery(
                        data: MediaQuery.of(context).copyWith(
                          textScaler: const TextScaler.linear(1.0),
                        ),
                        child: SizedBox(
                          height: 72,
                          child: SingleChildScrollView(
                            scrollDirection: Axis.horizontal,
                            child: Row(
                              children: List.generate(days.length, (i) {
                                final d = days[i];
                                final label = const ['Mon','Tue','Wed','Thu','Fri','Sat','Sun'][i];
                                return GestureDetector(
                                  onTap: () => onSelectDay(i),
                                  child: _DayPill(
                                    label: label,
                                    day: d.day.toString(),
                                    selected: i == selectedIndex,
                                  ),
                                );
                              }),
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),

          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: Row(
              children: [
                Text(
                  "${const ['Mon','Tue','Wed','Thu','Fri','Sat','Sun'][selectedIndex]}'s Meals",
                  style: Theme.of(context).textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.w800),
                ),
                const Spacer(),
                ElevatedButton(
                  onPressed: () async {
                    final picks = await Navigator.push<List<Map<String, dynamic>>>(
                      context,
                      MaterialPageRoute<List<Map<String, dynamic>>>(
                        builder: (_) => const WeeklyListPopup(),
                      ),
                    );
                    if (picks == null || picks.isEmpty) return;

                    for (final p in picks) {
                      final name = (p['name'] as String).trim();
                      final category = (p['category'] as String).trim();
                      final qty = (p['qty'] as num).toDouble();
                      final unit = p['unit'] as String;

                      await AppDb.I.addOrActivate(
                        name: name,
                        category: category,
                        qty: qty,
                        unit: unit,
                        price: 0,
                        notes: '',
                        priority: false,
                      );
                    }

                    if (!context.mounted) return;
                    Navigator.pop(context, true);
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF34C759),
                    foregroundColor: Colors.white,
                    elevation: 0,
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(18)),
                    padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
                  ),
                  child: const Text('Generate List',
                      style: TextStyle(fontWeight: FontWeight.w700, fontSize: 14)),
                ),
              ],
            ),
          ),
          const SizedBox(height: 8),

          const _MealSection(
            colorTop: Color(0xFFFFF3BF),
            dividerColor: Color(0xFFF7D34A),
            title: 'Breakfast',
            placeholder: 'Plan breakfast',
          ),
          const _MealSection(
            colorTop: Color(0xFFFFE4CB),
            dividerColor: Color(0xFFF2B070),
            title: 'Lunch',
            placeholder: 'Plan lunch',
          ),
          const _MealSection(
            colorTop: Color(0xFFEEDBFF),
            dividerColor: Color(0xFFB581F7),
            title: 'Dinner',
            placeholder: 'Plan dinner',
          ),
        ],
      ),
    );
  }
}

class _HeaderIconButton extends StatelessWidget {
  final IconData icon;
  final VoidCallback onTap;
  const _HeaderIconButton({required this.icon, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return InkResponse(
      onTap: onTap,
      radius: 26,
      child: Container(
        decoration: BoxDecoration(
          color: Colors.white.withOpacity(.22),
          borderRadius: BorderRadius.circular(14),
        ),
        padding: const EdgeInsets.all(8),
        child: Icon(icon, color: Colors.white),
      ),
    );
  }
}

class _CircleArrow extends StatelessWidget {
  final bool left;
  final VoidCallback onTap;
  const _CircleArrow({required this.left, required this.onTap});
  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      customBorder: const CircleBorder(),
      child: Container(
        decoration: BoxDecoration(
          color: Colors.white.withOpacity(.25),
          shape: BoxShape.circle,
        ),
        padding: const EdgeInsets.all(6),
        child: Icon(
          left ? Icons.chevron_left_rounded : Icons.chevron_right_rounded,
          color: Colors.white,
        ),
      ),
    );
  }
}

class _DayPill extends StatelessWidget {
  final String label;
  final String day;
  final bool selected;
  const _DayPill({required this.label, required this.day, this.selected = false});

  @override
  Widget build(BuildContext context) {
    final bg = selected ? Colors.white : Colors.white.withOpacity(.18);
    final fg = selected ? const Color(0xFF7E56FF) : Colors.white;

    return Container(
      width: 110,
      margin: const EdgeInsets.symmetric(horizontal: 6),
      padding: const EdgeInsets.symmetric(vertical: 8),
      decoration: BoxDecoration(
        color: bg,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: Colors.white.withOpacity(.3)),
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Text(label,
              style: TextStyle(
                  color: fg, fontWeight: FontWeight.w700, fontSize: 14, height: 1.1)),
          const SizedBox(height: 2),
          Text(day,
              style:
                  TextStyle(color: fg, fontSize: 12, height: 1.1, fontWeight: FontWeight.w600)),
        ],
      ),
    );
  }
}

class _MealSection extends StatelessWidget {
  final Color colorTop;
  final Color dividerColor;
  final String title;
  final String placeholder;
  const _MealSection({
    required this.colorTop,
    required this.dividerColor,
    required this.title,
    required this.placeholder,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 10, 16, 0),
      child: Container(
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(22),
          boxShadow: const [
            BoxShadow(color: Color(0x14000000), blurRadius: 16, offset: Offset(0, 8)),
          ],
        ),
        child: Column(
          children: [
            Container(
              width: double.infinity,
              decoration: BoxDecoration(
                color: colorTop,
                borderRadius: const BorderRadius.only(
                  topLeft: Radius.circular(22),
                  topRight: Radius.circular(22),
                ),
              ),
              padding: const EdgeInsets.fromLTRB(16, 14, 16, 10),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(title,
                      style: const TextStyle(fontWeight: FontWeight.w800, fontSize: 16)),
                  const SizedBox(height: 10),
                  Container(height: 3, width: double.infinity, color: dividerColor),
                ],
              ),
            ),
            const SizedBox(height: 12),
            Padding(
              padding: const EdgeInsets.fromLTRB(16, 0, 16, 20),
              child: _DashedBox(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const Icon(Icons.add, size: 32, color: Colors.black38),
                    const SizedBox(height: 6),
                    Text(placeholder,
                        style: Theme.of(context)
                            .textTheme
                            .bodyMedium
                            ?.copyWith(color: Colors.black45)),
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

class _DashedBox extends StatelessWidget {
  final Widget child;
  const _DashedBox({required this.child});

  @override
  Widget build(BuildContext context) {
    return CustomPaint(
      painter: _DashedRRectPainter(
        color: const Color(0xFFBFC7D3),
        dashWidth: 6,
        gap: 6,
        radius: 16,
        strokeWidth: 2,
      ),
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 24),
        alignment: Alignment.center,
        child: child,
      ),
    );
  }
}

class _DashedRRectPainter extends CustomPainter {
  final Color color;
  final double dashWidth;
  final double gap;
  final double radius;
  final double strokeWidth;
  const _DashedRRectPainter({
    required this.color,
    required this.dashWidth,
    required this.gap,
    required this.radius,
    required this.strokeWidth,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final rrect = RRect.fromRectAndRadius(Offset.zero & size, Radius.circular(radius));
    final path = Path()..addRRect(rrect);
    final paint = Paint()
      ..color = color
      ..style = PaintingStyle.stroke
      ..strokeWidth = strokeWidth;

    for (final metric in path.computeMetrics()) {
      double distance = 0.0;
      while (distance < metric.length) {
        final next = math.min(dashWidth, metric.length - distance);
        final segment = metric.extractPath(distance, distance + next);
        canvas.drawPath(segment, paint);
        distance += dashWidth + gap;
      }
    }
  }

  @override
  bool shouldRepaint(covariant _DashedRRectPainter old) =>
      old.color != color ||
      old.dashWidth != dashWidth ||
      old.gap != gap ||
      old.radius != radius ||
      old.strokeWidth != strokeWidth;
}

class _BottomNav extends StatelessWidget {
  final int index;
  const _BottomNav({required this.index});

  @override
  Widget build(BuildContext context) {
    return NavigationBar(
      selectedIndex: index,
      destinations: const [
        NavigationDestination(icon: Icon(Icons.home_outlined), label: 'Home'),
        NavigationDestination(icon: Icon(Icons.calendar_month), label: 'Weekly'),
        NavigationDestination(icon: Icon(Icons.category_outlined), label: 'Categories'),
      ],
      onDestinationSelected: (i) {
        if (i == 0) Navigator.popUntil(context, ModalRoute.withName('/'));
        if (i == 1) {}
        if (i == 2) Navigator.pushNamed(context, '/categories');
      },
    );
  }
}
