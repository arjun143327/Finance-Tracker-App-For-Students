import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../core/app_colors.dart';
import '../../core/app_theme.dart';
import '../../data/models/transaction_model.dart';
import '../../data/providers/transaction_provider.dart';
import '../../data/providers/category_provider.dart';
import '../../data/providers/currency_budget_provider.dart';
import '../widgets/glass_card.dart';

// ---------------------------------------------------------------------------
// Payment methods — single source of truth (DRY)
// ---------------------------------------------------------------------------
class _PaymentMethod {
  final String label;
  final IconData icon;
  const _PaymentMethod(this.label, this.icon);
}

const List<_PaymentMethod> _kPaymentMethods = [
  _PaymentMethod('Cash',     Icons.money_rounded),
  _PaymentMethod('GPay',     Icons.currency_rupee_rounded),
  _PaymentMethod('PhonePe',  Icons.phone_android_rounded),
  _PaymentMethod('Paytm',    Icons.account_balance_wallet_rounded),
  _PaymentMethod('Card',     Icons.credit_card_rounded),
  _PaymentMethod('UPI',      Icons.qr_code_rounded),
  _PaymentMethod('Net Banking', Icons.computer_rounded),
  _PaymentMethod('Other',    Icons.more_horiz_rounded),
];

// ---------------------------------------------------------------------------
// Screen
// ---------------------------------------------------------------------------
class AddExpenseScreen extends ConsumerStatefulWidget {
  final TransactionModel? initialTransaction;

  const AddExpenseScreen({super.key, this.initialTransaction});

  @override
  ConsumerState<AddExpenseScreen> createState() => _AddExpenseScreenState();
}

class _AddExpenseScreenState extends ConsumerState<AddExpenseScreen> {
  final _formKey     = GlobalKey<FormState>();
  final _titleController  = TextEditingController();
  final _amountController = TextEditingController();

  String          _category      = 'Food';
  String          _selectedMethod = 'Cash';
  TransactionType _type          = TransactionType.expense;
  bool            _isRecurring   = false;
  bool            _isSaving      = false;
  DateTime        _date          = DateTime.now();

  @override
  void initState() {
    super.initState();
    final tx = widget.initialTransaction;
    if (tx != null) {
      _titleController.text  = tx.title;
      _amountController.text = tx.amount.toStringAsFixed(0);
      _category = tx.category;
      _type     = tx.type;
      _isRecurring = tx.isRecurring;
      // Restore saved method if it matches our list, else fall back to 'Other'
      final found = _kPaymentMethods.any((m) => m.label == tx.method);
      _selectedMethod = found ? tx.method : 'Other';
      _date = tx.date;
    }
  }

  @override
  void dispose() {
    _titleController.dispose();
    _amountController.dispose();
    super.dispose();
  }

  Future<void> _save() async {
    if (!_formKey.currentState!.validate()) return;
    setState(() => _isSaving = true);

    final amount = double.tryParse(_amountController.text.trim()) ?? 0;
    final model = TransactionModel(
      id:       widget.initialTransaction?.id,
      title:    _titleController.text.trim(),
      category: _category,
      amount:   amount,
      date:     _date,
      method:   _selectedMethod,
      type:     _type,
      isRecurring: _isRecurring,
    );

    final notifier = ref.read(transactionsListProvider.notifier);
    if (widget.initialTransaction?.id == null) {
      await notifier.addTransaction(model);
    } else {
      await notifier.updateTransaction(model);
    }

    if (!mounted) return;
    Navigator.of(context).pop();
  }

  // ── UI ──────────────────────────────────────────────────────────────────

  @override
  Widget build(BuildContext context) {
    final isEdit         = widget.initialTransaction != null;
    final categoriesState = ref.watch(categoryListProvider);
    final currency       = ref.watch(currencySymbolProvider);

    return Container(
      decoration: AppTheme.backgroundGradient,
      child: Scaffold(
        backgroundColor: Colors.transparent,
        appBar: AppBar(
          title: Text(isEdit ? 'Edit Transaction' : 'Add Transaction'),
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
                // ── Amount card ───────────────────────────────────────────
                TweenAnimationBuilder<double>(
                  tween: Tween(begin: 0.94, end: 1),
                  duration: const Duration(milliseconds: 350),
                  builder: (context, scale, child) =>
                      Transform.scale(scale: scale, child: child),
                  child: GlassCard(
                    interactive: false,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        // Amount
                        Center(
                          child: Text(
                            'Amount',
                            style: Theme.of(context)
                                .textTheme
                                .labelLarge
                                ?.copyWith(letterSpacing: 1.6),
                          ),
                        ),
                        const SizedBox(height: 8),
                        Center(
                          child: TextFormField(
                            controller: _amountController,
                            textAlign: TextAlign.center,
                            keyboardType: const TextInputType.numberWithOptions(
                                decimal: true),
                            style: Theme.of(context)
                                .textTheme
                                .displayMedium
                                ?.copyWith(
                                  fontSize: 64,
                                  color: AppColors.primary,
                                  shadows: [
                                    Shadow(
                                      color: AppColors.primary
                                          .withValues(alpha: 0.24),
                                      blurRadius: 22,
                                      offset: const Offset(-4, -6),
                                    ),
                                  ],
                                ),
                            decoration: InputDecoration(
                              hintText: '$currency 0.00',
                              border: InputBorder.none,
                              enabledBorder: InputBorder.none,
                              focusedBorder: InputBorder.none,
                            ),
                            validator: (value) {
                              final parsed =
                                  double.tryParse((value ?? '').trim());
                              if (parsed == null || parsed <= 0) {
                                return 'Enter a valid amount';
                              }
                              return null;
                            },
                          ),
                        ),
                        const SizedBox(height: 20),

                        // Category
                        Text(
                          'Category',
                          style: Theme.of(context)
                              .textTheme
                              .labelLarge
                              ?.copyWith(letterSpacing: 1.3),
                        ),
                        const SizedBox(height: 12),
                        categoriesState.when(
                          loading: () => const LinearProgressIndicator(
                              color: AppColors.primary),
                          error: (err, _) =>
                              Text('Error loading categories: $err'),
                          data: (categories) {
                            final categoryNames =
                                categories.map((c) => c.name).toList();
                            if (!categoryNames.contains(_category) &&
                                categoryNames.isNotEmpty) {
                              _category = categoryNames.first;
                            }
                            return DropdownButtonFormField<String>(
                              initialValue: _category,
                              dropdownColor: AppColors.bgGradientEnd,
                              decoration: _inputDecoration(hint: 'Category'),
                              items: categoryNames
                                  .map((name) => DropdownMenuItem(
                                        value: name,
                                        child: Text(name),
                                      ))
                                  .toList(),
                              onChanged: (value) {
                                if (value == null) return;
                                setState(() => _category = value);
                              },
                            );
                          },
                        ),
                        const SizedBox(height: 18),

                        // Note / title
                        TextFormField(
                          controller: _titleController,
                          decoration:
                              _inputDecoration(hint: 'Add note (optional)'),
                          validator: (value) =>
                              (value == null || value.trim().isEmpty)
                                  ? 'Title is required'
                                  : null,
                        ),
                        const SizedBox(height: 22),

                        // Date picker
                        Text(
                          'Date',
                          style: Theme.of(context)
                              .textTheme
                              .labelLarge
                              ?.copyWith(letterSpacing: 1.3),
                        ),
                        const SizedBox(height: 12),
                        InkWell(
                          onTap: () async {
                            final picked = await showDatePicker(
                              context: context,
                              initialDate: _date,
                              firstDate: DateTime(2000),
                              lastDate: DateTime(2100),
                              builder: (context, child) {
                                return Theme(
                                  data: Theme.of(context).copyWith(
                                    colorScheme: const ColorScheme.dark(
                                      primary: AppColors.primary,
                                      onPrimary: Colors.white,
                                      surface: AppColors.bgGradientEnd,
                                      onSurface: Colors.white,
                                    ),
                                  ),
                                  child: child!,
                                );
                              },
                            );
                            if (picked != null) {
                              setState(() => _date = picked);
                            }
                          },
                          borderRadius: BorderRadius.circular(16),
                          child: Container(
                            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
                            decoration: BoxDecoration(
                              color: Colors.white.withValues(alpha: 0.04),
                              borderRadius: BorderRadius.circular(16),
                              border: Border.all(color: Colors.white.withValues(alpha: 0.08)),
                            ),
                            child: Row(
                              children: [
                                const Icon(Icons.calendar_today_rounded, color: AppColors.textSecondary, size: 20),
                                const SizedBox(width: 12),
                                Text(
                                  _date.year == DateTime.now().year && _date.month == DateTime.now().month && _date.day == DateTime.now().day
                                      ? 'Today'
                                      : '${_date.day}/${_date.month}/${_date.year}',
                                  style: Theme.of(context).textTheme.bodyLarge,
                                ),
                              ],
                            ),
                          ),
                        ),
                        const SizedBox(height: 22),

                        // ── Payment method chips ───────────────────────────
                        Text(
                          'Payment Method',
                          style: Theme.of(context)
                              .textTheme
                              .labelLarge
                              ?.copyWith(letterSpacing: 1.3),
                        ),
                        const SizedBox(height: 14),
                        Wrap(
                          spacing: 10,
                          runSpacing: 10,
                          children: _kPaymentMethods
                              .map((m) => _MethodChip(
                                    method: m,
                                    isSelected: _selectedMethod == m.label,
                                    onTap: () => setState(
                                        () => _selectedMethod = m.label),
                                  ))
                              .toList(),
                        ),
                        const SizedBox(height: 22),

                        _TypeToggle(
                          type: _type,
                          onChanged: (t) => setState(() => _type = t),
                        ),
                        const SizedBox(height: 22),

                        // ── Recurring toggle ───────────────────────────────
                        SwitchListTile(
                          title: Text(
                            'Recurring Transaction',
                            style: Theme.of(context).textTheme.bodyLarge,
                          ),
                          subtitle: Text(
                            'Automatically add this every month',
                            style: Theme.of(context).textTheme.bodySmall?.copyWith(color: AppColors.textSecondary),
                          ),
                          value: _isRecurring,
                          activeTrackColor: AppColors.primary,
                          contentPadding: EdgeInsets.zero,
                          onChanged: (val) {
                            setState(() {
                              _isRecurring = val;
                            });
                          },
                        ),
                      ],
                    ),
                  ),
                ),
                const SizedBox(height: 28),

                // ── Save button ────────────────────────────────────────────
                _SaveButton(
                  label: _isSaving
                      ? 'Saving...'
                      : (isEdit ? 'Update' : 'Save Transaction'),
                  onPressed: _isSaving ? null : _save,
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
      fillColor: Colors.white.withValues(alpha: 0.04),
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(14),
        borderSide: BorderSide(color: Colors.white.withValues(alpha: 0.1)),
      ),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(14),
        borderSide: BorderSide(color: Colors.white.withValues(alpha: 0.1)),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(14),
        borderSide: const BorderSide(color: AppColors.primary),
      ),
    );
  }
}

// ---------------------------------------------------------------------------
// Payment Method Chip — extracted private widget (DRY, single responsibility)
// ---------------------------------------------------------------------------
class _MethodChip extends StatelessWidget {
  final _PaymentMethod method;
  final bool isSelected;
  final VoidCallback onTap;

  const _MethodChip({
    required this.method,
    required this.isSelected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 180),
        curve: Curves.easeOut,
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
        decoration: BoxDecoration(
          color: isSelected
              ? AppColors.primary.withValues(alpha: 0.18)
              : Colors.white.withValues(alpha: 0.04),
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: isSelected
                ? AppColors.primary
                : Colors.white.withValues(alpha: 0.08),
            width: isSelected ? 1.5 : 1,
          ),
          boxShadow: isSelected
              ? [
                  BoxShadow(
                    color: AppColors.primary.withValues(alpha: 0.12),
                    blurRadius: 12,
                    spreadRadius: 0,
                  )
                ]
              : [],
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              method.icon,
              size: 15,
              color: isSelected ? AppColors.primary : AppColors.textMuted,
            ),
            const SizedBox(width: 7),
            Text(
              method.label,
              style: GoogleFonts.lato(
                color: isSelected ? AppColors.primaryLight : AppColors.textSecondary,
                fontSize: 13,
                fontWeight: isSelected ? FontWeight.w500 : FontWeight.w300,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// ---------------------------------------------------------------------------
// Transaction Type Toggle — extracted private widget
// ---------------------------------------------------------------------------
class _TypeToggle extends StatelessWidget {
  final TransactionType type;
  final ValueChanged<TransactionType> onChanged;

  const _TypeToggle({required this.type, required this.onChanged});

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        _toggleChip(
          context,
          label: 'Expense',
          icon: Icons.north_east_rounded,
          active: type == TransactionType.expense,
          activeColor: AppColors.expense,
          onTap: () => onChanged(TransactionType.expense),
        ),
        const SizedBox(width: 10),
        _toggleChip(
          context,
          label: 'Income',
          icon: Icons.south_west_rounded,
          active: type == TransactionType.income,
          activeColor: AppColors.income,
          onTap: () => onChanged(TransactionType.income),
        ),
      ],
    );
  }

  Widget _toggleChip(
    BuildContext context, {
    required String label,
    required IconData icon,
    required bool active,
    required Color activeColor,
    required VoidCallback onTap,
  }) {
    return Expanded(
      child: GestureDetector(
        onTap: onTap,
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 180),
          padding: const EdgeInsets.symmetric(vertical: 12),
          decoration: BoxDecoration(
            color: active
                ? activeColor.withValues(alpha: 0.14)
                : Colors.white.withValues(alpha: 0.03),
            borderRadius: BorderRadius.circular(12),
            border: Border.all(
              color: active
                  ? activeColor.withValues(alpha: 0.5)
                  : Colors.white.withValues(alpha: 0.08),
            ),
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(icon,
                  size: 15,
                  color: active ? activeColor : AppColors.textMuted),
              const SizedBox(width: 6),
              Text(
                label,
                style: GoogleFonts.lato(
                  color: active ? activeColor : AppColors.textSecondary,
                  fontSize: 13,
                  fontWeight: active ? FontWeight.w600 : FontWeight.w300,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

// ---------------------------------------------------------------------------
// Save Button — gradient elevated button
// ---------------------------------------------------------------------------
class _SaveButton extends StatelessWidget {
  final String label;
  final VoidCallback? onPressed;

  const _SaveButton({required this.label, required this.onPressed});

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(14),
        gradient: onPressed != null
            ? const LinearGradient(
                colors: [AppColors.primaryLight, AppColors.primaryDark],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              )
            : null,
        color: onPressed == null
            ? Colors.white.withValues(alpha: 0.08)
            : null,
        boxShadow: onPressed != null
            ? [
                BoxShadow(
                  color: AppColors.primary.withValues(alpha: 0.22),
                  blurRadius: 22,
                  offset: const Offset(-4, -5),
                )
              ]
            : [],
      ),
      child: Material(
        color: Colors.transparent,
        borderRadius: BorderRadius.circular(14),
        child: InkWell(
          borderRadius: BorderRadius.circular(14),
          onTap: onPressed,
          child: SizedBox(
            width: double.infinity,
            height: 54,
            child: Center(
              child: Text(
                label.toUpperCase(),
                style: GoogleFonts.lato(
                  color: onPressed != null
                      ? AppColors.bgGradientStart
                      : AppColors.textMuted,
                  fontSize: 14,
                  fontWeight: FontWeight.w600,
                  letterSpacing: 1.4,
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}

