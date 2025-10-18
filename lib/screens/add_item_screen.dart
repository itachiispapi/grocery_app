import 'package:flutter/material.dart';

class AddItemScreen extends StatefulWidget {
  const AddItemScreen({super.key});

  @override
  State<AddItemScreen> createState() => _AddItemScreenState();
}

class _AddItemScreenState extends State<AddItemScreen> {
  final _formKey = GlobalKey<FormState>();
  final _nameCtrl = TextEditingController();
  final _qtyCtrl = TextEditingController(text: '1');
  final _priceCtrl = TextEditingController();

  String? _category = 'Vegetables';

  @override
  void dispose() {
    _nameCtrl.dispose();
    _qtyCtrl.dispose();
    _priceCtrl.dispose();
    super.dispose();
  }

  void _save() {
    if (!_formKey.currentState!.validate()) return;

    // TODO: Hook into your state/store here
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
          'Added "${_nameCtrl.text}" • $_category • x${_qtyCtrl.text}${_priceCtrl.text.isEmpty ? '' : ' • \$${_priceCtrl.text}'}',
        ),
      ),
    );
    Navigator.pop(context);
  }

  @override
  Widget build(BuildContext context) {
    final titleStyle = Theme.of(context)
        .textTheme
        .titleLarge
        ?.copyWith(color: Colors.white, fontWeight: FontWeight.w700);

    return Scaffold(
      backgroundColor: const Color(0xFFF6F7FB),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.only(bottom: 24),
          child: Column(
            children: [
              // Gradient header
              Container(
                padding: const EdgeInsets.fromLTRB(8, 16, 16, 20),
                width: double.infinity,
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
                child: Row(
                  children: [
                    IconButton(
                      onPressed: () => Navigator.pop(context),
                      icon: const Icon(Icons.arrow_back_ios_new_rounded,
                          color: Colors.white),
                    ),
                    const SizedBox(width: 4),
                    Text('Add Item', style: titleStyle),
                  ],
                ),
              ),

              const SizedBox(height: 16),

              // Card form
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                child: Container(
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(18),
                    boxShadow: const [
                      BoxShadow(
                        color: Color(0x14000000),
                        blurRadius: 16,
                        offset: Offset(0, 10),
                      )
                    ],
                  ),
                  padding: const EdgeInsets.fromLTRB(16, 18, 16, 8),
                  child: Form(
                    key: _formKey,
                    child: Column(
                      children: [
                        _LabeledField(
                          label: 'Item name',
                          child: TextFormField(
                            controller: _nameCtrl,
                            decoration: const InputDecoration(
                              hintText: 'e.g., Tomatoes',
                              border: OutlineInputBorder(),
                            ),
                            validator: (v) =>
                                (v == null || v.trim().isEmpty) ? 'Required' : null,
                          ),
                        ),
                        const SizedBox(height: 14),
                        Row(
                          children: [
                            Expanded(
                              child: _LabeledField(
                                label: 'Quantity',
                                child: TextFormField(
                                  controller: _qtyCtrl,
                                  keyboardType: TextInputType.number,
                                  decoration: const InputDecoration(
                                    hintText: '1',
                                    border: OutlineInputBorder(),
                                  ),
                                  validator: (v) {
                                    if (v == null || v.isEmpty) return 'Required';
                                    final n = int.tryParse(v);
                                    if (n == null || n <= 0) return 'Enter a number';
                                    return null;
                                  },
                                ),
                              ),
                            ),
                            const SizedBox(width: 12),
                            Expanded(
                              child: _LabeledField(
                                label: 'Price (optional)',
                                child: TextFormField(
                                  controller: _priceCtrl,
                                  keyboardType:
                                      const TextInputType.numberWithOptions(
                                          decimal: true),
                                  decoration: const InputDecoration(
                                    prefixText: '\$ ',
                                    hintText: '0.00',
                                    border: OutlineInputBorder(),
                                  ),
                                ),
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 14),
                        _LabeledField(
                          label: 'Category',
                          child: DropdownButtonFormField<String>(
                            value: _category,
                            decoration: const InputDecoration(
                              border: OutlineInputBorder(),
                            ),
                            items: const [
                              DropdownMenuItem(
                                  value: 'Vegetables', child: Text('Vegetables')),
                              DropdownMenuItem(
                                  value: 'Fruits', child: Text('Fruits')),
                              DropdownMenuItem(
                                  value: 'Dairy', child: Text('Dairy')),
                              DropdownMenuItem(
                                  value: 'Bakery', child: Text('Bakery')),
                              DropdownMenuItem(
                                  value: 'Beverages', child: Text('Beverages')),
                              DropdownMenuItem(
                                  value: 'Snacks', child: Text('Snacks')),
                              DropdownMenuItem(
                                  value: 'Household', child: Text('Household')),
                            ],
                            onChanged: (v) => setState(() => _category = v),
                          ),
                        ),
                        const SizedBox(height: 20),
                        SizedBox(
                          width: double.infinity,
                          height: 52,
                          child: ElevatedButton.icon(
                            style: ElevatedButton.styleFrom(
                              backgroundColor: const Color(0xFF0AD06E),
                              foregroundColor: Colors.white,
                              shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(16)),
                              elevation: 0,
                            ),
                            icon: const Icon(Icons.check_rounded),
                            label: const Text(
                              'Add to List',
                              style: TextStyle(
                                  fontWeight: FontWeight.w700, fontSize: 16),
                            ),
                            onPressed: _save,
                          ),
                        ),
                        const SizedBox(height: 12),
                      ],
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _LabeledField extends StatelessWidget {
  final String label;
  final Widget child;
  const _LabeledField({required this.label, required this.child});

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label,
            style: Theme.of(context)
                .textTheme
                .labelLarge
                ?.copyWith(fontWeight: FontWeight.w600)),
        const SizedBox(height: 8),
        child,
      ],
    );
  }
}

