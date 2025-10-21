import 'package:flutter/material.dart';
import '../data/app_db.dart';
import '../data/models.dart';

class AddItemScreen extends StatefulWidget {
  const AddItemScreen({super.key});

  @override
  State<AddItemScreen> createState() => _AddItemScreenState();
}

class _AddItemScreenState extends State<AddItemScreen> {
  final _formKey = GlobalKey<FormState>();
  final _nameCtrl = TextEditingController();
  final _qtyCtrl = TextEditingController(text: '1');
  final _priceCtrl = TextEditingController(text: '0');
  final _notesCtrl = TextEditingController();

  final _units = const ['pcs', 'kg', 'g', 'lb', 'L', 'mL'];
  String _unit = 'pcs';

  final List<String> _cats = const [
    'Vegetables','Fruit','Dairy','Bakery', 'Meats','Beverages','Snacks','Household','Other'
  ];
  String _selectedCat = 'Other';

  @override
  void dispose() {
    _nameCtrl.dispose();
    _qtyCtrl.dispose();
    _priceCtrl.dispose();
    _notesCtrl.dispose();
    super.dispose();
  }

  OutlineInputBorder _rounded(Color color) => OutlineInputBorder(
    borderRadius: BorderRadius.circular(18),
    borderSide: BorderSide(color: color, width: 1.6),
  );

  @override
  Widget build(BuildContext context) {
    final headline = Theme.of(context).textTheme.titleLarge?.copyWith(
          color: Colors.white, fontWeight: FontWeight.w700,
        );

    return Scaffold(
      backgroundColor: const Color(0xFFF6F7FB),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.only(bottom: 24),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // gradient header
              Container(
                width: double.infinity,
                decoration: const BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                    colors: [Color(0xFF2FC28B), Color(0xFF6C8BFF)],
                  ),
                  borderRadius: BorderRadius.only(
                    bottomLeft: Radius.circular(28),
                    bottomRight: Radius.circular(28),
                  ),
                ),
                padding: const EdgeInsets.fromLTRB(8, 18, 16, 26),
                child: Row(
                  children: [
                    IconButton(
                      icon: const Icon(Icons.arrow_back_ios_new_rounded,
                          color: Colors.white),
                      onPressed: () => Navigator.pop(context),
                    ),
                    const SizedBox(width: 6),
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text('Add New Item', style: headline),
                        Text('Fill in the details below',
                            style: TextStyle(
                              color: Colors.white.withOpacity(.9),
                              fontWeight: FontWeight.w500,
                            )),
                      ],
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 18),

              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 18),
                child: Form(
                  key: _formKey,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      _FieldLabel('Item Name'),
                      TextFormField(
                        controller: _nameCtrl,
                        decoration: InputDecoration(
                          hintText: 'e.g., Organic Bananas',
                          filled: true,
                          fillColor: Colors.white,
                          contentPadding:
                              const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
                          enabledBorder: _rounded(const Color(0xFFD8E2FF)),
                          focusedBorder: _rounded(const Color(0xFF6C8BFF)),
                        ),
                        validator: (v) =>
                            (v == null || v.trim().isEmpty) ? 'Required' : null,
                      ),
                      const SizedBox(height: 16),

                      Row(
                        children: [
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                _FieldLabel('Quantity'),
                                TextFormField(
                                  controller: _qtyCtrl,
                                  keyboardType: TextInputType.number,
                                  decoration: InputDecoration(
                                    hintText: '1',
                                    filled: true,
                                    fillColor: Colors.white,
                                    contentPadding: const EdgeInsets.symmetric(
                                        horizontal: 16, vertical: 16),
                                    enabledBorder: _rounded(const Color(0xFFE7D8FF)),
                                    focusedBorder: _rounded(const Color(0xFFB08DFF)),
                                  ),
                                  validator: (v) {
                                    final n = int.tryParse(v ?? '');
                                    if (n == null || n <= 0) return 'Enter a number';
                                    return null;
                                  },
                                ),
                              ],
                            ),
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                _FieldLabel('Unit'),
                                DropdownButtonFormField<String>(
                                  initialValue: _unit,
                                  decoration: InputDecoration(
                                    filled: true,
                                    fillColor: Colors.white,
                                    contentPadding: const EdgeInsets.symmetric(
                                        horizontal: 16, vertical: 4),
                                    enabledBorder: _rounded(const Color(0xFFE7D8FF)),
                                    focusedBorder: _rounded(const Color(0xFFB08DFF)),
                                  ),
                                  items: _units
                                      .map((u) =>
                                          DropdownMenuItem(value: u, child: Text(u)))
                                      .toList(),
                                  onChanged: (v) => setState(() => _unit = v ?? _unit),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 16),

                      _FieldLabel('Category'),
                      Wrap(
                        spacing: 10,
                        runSpacing: 10,
                        children: _cats.map((c) {
                          final selected = _selectedCat == c;
                          return ChoiceChip(
                            label: Text(c),
                            selected: selected,
                            onSelected: (_) => setState(() => _selectedCat = c),
                            labelStyle: TextStyle(
                              fontWeight: FontWeight.w600,
                              color: selected ? Colors.white : Colors.black87,
                            ),
                            selectedColor: const Color(0xFF8B98FF),
                            backgroundColor: Colors.white,
                            side: BorderSide(
                                color: selected
                                    ? const Color(0xFF8B98FF)
                                    : const Color(0xFFE6EAF0)),
                            shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(14)),
                          );
                        }).toList(),
                      ),
                      const SizedBox(height: 16),

                      _FieldLabel('\$  Price (optional)'),
                      TextFormField(
                        controller: _priceCtrl,
                        keyboardType:
                            const TextInputType.numberWithOptions(decimal: true),
                        decoration: InputDecoration(
                          hintText: '0',
                          filled: true,
                          fillColor: Colors.white,
                          contentPadding:
                              const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
                          enabledBorder: _rounded(const Color(0xFFCDEFD9)),
                          focusedBorder: _rounded(const Color(0xFF2FC28B)),
                        ),
                      ),
                      const SizedBox(height: 16),

                      _FieldLabel('Notes'),
                      TextFormField(
                        controller: _notesCtrl,
                        maxLines: 4,
                        decoration: InputDecoration(
                          hintText: 'Any additional details...',
                          filled: true,
                          fillColor: Colors.white,
                          contentPadding:
                              const EdgeInsets.fromLTRB(16, 14, 16, 14),
                          enabledBorder: _rounded(const Color(0xFFD7E6FF)),
                          focusedBorder: _rounded(const Color(0xFF6C8BFF)),
                        ),
                      ),
                      const SizedBox(height: 22),

                      SizedBox(
                        width: double.infinity,
                        height: 56,
                        child: ElevatedButton(
                          style: ElevatedButton.styleFrom(
                            backgroundColor: const Color(0xFF2FC28B),
                            foregroundColor: Colors.white,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(18),
                            ),
                            elevation: 0,
                          ),
                          onPressed: () async {
                            if (!_formKey.currentState!.validate()) return;

                            final item = GItem(
                              name: _nameCtrl.text.trim(),
                              qty: double.tryParse(_qtyCtrl.text.trim())?.toDouble() ?? 1,
                              unit: _unit,
                              category: _selectedCat,
                              price: double.tryParse(_priceCtrl.text.trim()) ?? 0,
                              notes: _notesCtrl.text.trim(),
                              done: false,
                              active: true,
                              priority: false, // will add UI toggle in next commit
                              createdAt: DateTime.now(),
                            );
                            await AppDb.I.insertItem(item);

                            if (!mounted) return;
                            ScaffoldMessenger.of(context).showSnackBar(
                              SnackBar(content: Text('Added "${item.name}"')),
                            );
                            Navigator.pop(context, true);
                          },

                          child: const Text(
                            'Add to List',
                            style: TextStyle(
                                fontWeight: FontWeight.w800, fontSize: 16),
                          ),
                        ),
                      ),
                      const SizedBox(height: 8),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
      bottomNavigationBar: const _BottomNav(index: 1), // optional
    );
  }
}

class _FieldLabel extends StatelessWidget {
  final String text;
  const _FieldLabel(this.text);

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Text(text,
          style: Theme.of(context)
              .textTheme
              .labelLarge
              ?.copyWith(fontWeight: FontWeight.w700)),
    );
  }
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
        NavigationDestination(icon: Icon(Icons.folder_open), label: 'Categories'),
      ],
      onDestinationSelected: (i) {
        if (i == 0) Navigator.popUntil(context, ModalRoute.withName('/'));
        if (i == 1) {} // stay
        if (i == 2) Navigator.pushNamed(context, '/categories');
      },
    );
  }
}
