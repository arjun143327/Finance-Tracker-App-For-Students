import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../core/app_colors.dart';
import '../../core/app_theme.dart';
import '../../data/models/transaction_model.dart';
import '../../data/providers/transaction_provider.dart';
import '../widgets/custom_button.dart';
import '../widgets/glass_card.dart';

class AddExpenseScreen extends ConsumerStatefulWidget {
  final TransactionModel? initialTransaction;

  const AddExpenseScreen({super.key, this.initialTransaction});

  @override
  ConsumerState<AddExpenseScreen> createState() => _AddExpenseScreenState();
}

class _AddExpenseScreenState extends ConsumerState<AddExpenseScreen> {
  final _formKey = GlobalKey<FormState>();
  final _titleController = TextEditingController();
  final _amountController = TextEditingController();
  final _methodController = TextEditingController();

  String _category = 'Food';
  TransactionType _type = TransactionType.expense;
  bool _isSaving = false;

  static const List<String> _categories = [
    'Food',
    'Transport',
    'Shopping',
    'Bills',
    'Health',
    'Education',
    'Other',
  ];

  @override
  void initState() {
    super.initState();
    final tx = widget.initialTransaction;
    if (tx != null) {
      _titleController.text = tx.title;
      _amountController.text = tx.amount.toStringAsFixed(0);
      _methodController.text = tx.method;
      _category = tx.category;
      _type = tx.type;
    }
  }

  @override
  void dispose() {
    _titleController.dispose();
    _amountController.dispose();
    _methodController.dispose();
    super.dispose();
  }

  Future<void> _save() async {
    if (!_formKey.currentState!.validate()) return;
    setState(() => _isSaving = true);

    final amount = double.tryParse(_amountController.text.trim()) ?? 0;
    final model = TransactionModel(
      id: widget.initialTransaction?.id,
      title: _titleController.text.trim(),
      category: _category,
      amount: amount,
      date: DateTime.now(),
      method: _methodController.text.trim(),
      type: _type,
    );

    final notifier = ref.read(transactionsListProvider.notifier);
    if (widget.initialTransaction == null) {
      await notifier.addTransaction(model);
    } else {
      await notifier.updateTransaction(model);
    }

    if (!mounted) return;
    Navigator.of(context).pop();
  }

  @override
  Widget build(BuildContext context) {
    final isEdit = widget.initialTransaction != null;
    return Container(
      decoration: AppTheme.backgroundGradient,
      child: Scaffold(
        backgroundColor: Colors.transparent,
        appBar: AppBar(
          title: Text(isEdit ? 'Edit Transaction' : 'Add Expense'),
          backgroundColor: Colors.transparent,
          elevation: 0,
        ),
        body: SingleChildScrollView(
          padding: const EdgeInsets.all(24),
          child: Form(
            key: _formKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                TweenAnimationBuilder<double>(
                  tween: Tween(begin: 0.94, end: 1),
                  duration: const Duration(milliseconds: 350),
                  builder: (context, scale, child) => Transform.scale(scale: scale, child: child),
                  child: GlassCard(
                    interactive: false,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Center(
                          child: Text(
                            'Amount',
                            style: Theme.of(context).textTheme.labelLarge?.copyWith(letterSpacing: 1.6),
                          ),
                        ),
                        const SizedBox(height: 8),
                        Center(
                          child: TextFormField(
                            controller: _amountController,
                            textAlign: TextAlign.center,
                            keyboardType: const TextInputType.numberWithOptions(decimal: true),
                            style: Theme.of(context).textTheme.displayMedium?.copyWith(
                                  fontSize: 64,
                                  color: AppColors.primary,
                                  shadows: [
                                    Shadow(
                                      color: AppColors.primary.withOpacity(0.24),
                                      blurRadius: 22,
                                      offset: const Offset(-4, -6),
                                    ),
                                  ],
                                ),
                            decoration: const InputDecoration(
                              hintText: '₹ 0.00',
                              border: InputBorder.none,
                              enabledBorder: InputBorder.none,
                              focusedBorder: InputBorder.none,
                            ),
                            validator: (value) {
                              final parsed = double.tryParse((value ?? '').trim());
                              if (parsed == null || parsed <= 0) return 'Enter a valid amount';
                              return null;
                            },
                          ),
                        ),
                        const SizedBox(height: 20),
                        Text(
                          'Category',
                          style: Theme.of(context).textTheme.labelLarge?.copyWith(letterSpacing: 1.3),
                        ),
                        const SizedBox(height: 12),
                        DropdownButtonFormField<String>(
                          value: _category,
                          dropdownColor: AppColors.bgGradientEnd,
                          decoration: _inputDecoration(hint: 'Category'),
                          items: _categories
                              .map((category) => DropdownMenuItem(value: category, child: Text(category)))
                              .toList(),
                          onChanged: (value) {
                            if (value == null) return;
                            setState(() => _category = value);
                          },
                        ),
                        const SizedBox(height: 18),
                        TextFormField(
                          controller: _titleController,
                          decoration: _inputDecoration(hint: 'Add note (optional)'),
                          validator: (value) =>
                              (value == null || value.trim().isEmpty) ? 'Title is required' : null,
                        ),
                        const SizedBox(height: 18),
                        TextFormField(
                          controller: _methodController,
                          decoration: _inputDecoration(hint: 'Payment method'),
                          validator: (value) => (value == null || value.trim().isEmpty)
                              ? 'Payment method is required'
                              : null,
                        ),
                        const SizedBox(height: 18),
                        SegmentedButton<TransactionType>(
                          style: ButtonStyle(
                            backgroundColor: MaterialStateProperty.resolveWith(
                              (states) => states.contains(MaterialState.selected)
                                  ? AppColors.primary.withOpacity(0.2)
                                  : Colors.white.withOpacity(0.02),
                            ),
                            foregroundColor: const MaterialStatePropertyAll(AppColors.textPrimary),
                            side: MaterialStatePropertyAll(
                              BorderSide(color: Colors.white.withOpacity(0.1)),
                            ),
                          ),
                          segments: const [
                            ButtonSegment(
                              value: TransactionType.expense,
                              label: Text('Expense'),
                            ),
                            ButtonSegment(
                              value: TransactionType.income,
                              label: Text('Income'),
                            ),
                          ],
                          selected: {_type},
                          onSelectionChanged: (selected) {
                            setState(() => _type = selected.first);
                          },
                        ),
                      ],
                    ),
                  ),
                ),
                const SizedBox(height: 28),
                Container(
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(14),
                    boxShadow: [
                      BoxShadow(
                        color: AppColors.primary.withOpacity(0.16),
                        blurRadius: 22,
                        offset: const Offset(-4, -5),
                      ),
                    ],
                  ),
                  child: CustomButton(
                    label: _isSaving ? 'Saving...' : (isEdit ? 'Update' : 'Save Expense'),
                    onPressed: _isSaving ? () {} : _save,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  InputDecoration _inputDecoration({required String hint}) {
    return InputDecoration(
      hintText: hint,
      filled: true,
      fillColor: Colors.white.withOpacity(0.04),
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(14),
        borderSide: BorderSide(color: Colors.white.withOpacity(0.1)),
      ),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(14),
        borderSide: BorderSide(color: Colors.white.withOpacity(0.1)),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(14),
        borderSide: const BorderSide(color: AppColors.primary),
      ),
    );
  }
}
