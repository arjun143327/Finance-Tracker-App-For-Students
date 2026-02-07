import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'providers/finance_providers.dart';
import 'theme/neo_colors.dart';
import 'dashboard_screen.dart';

class BudgetSetupScreen extends ConsumerStatefulWidget {
  const BudgetSetupScreen({super.key});

  @override
  ConsumerState<BudgetSetupScreen> createState() => _BudgetSetupScreenState();
}

class _BudgetSetupScreenState extends ConsumerState<BudgetSetupScreen> {
  final TextEditingController _budgetController = TextEditingController(text: '6,000');
  final FocusNode _budgetFocusNode = FocusNode();
  int _totalBudget = 6000;
  int _selectedQuickPick = 6000;

  // Dynamic category list for full customization
  List<Map<String, dynamic>> _budgetCategories = [
    {'emoji': '🍕', 'name': 'Food & Dining', 'percentage': 0.10, 'color': NeoColors.orange},
    {'emoji': '🚌', 'name': 'Transport', 'percentage': 0.08, 'color': NeoColors.blue},
    {'emoji': '🎬', 'name': 'Entertainment', 'percentage': 0.07, 'color': NeoColors.red},
    {'emoji': '🛍️', 'name': 'Shopping', 'percentage': 0.10, 'color': NeoColors.green},
    {'emoji': '📚', 'name': 'Books & Study', 'percentage': 0.15, 'color': const Color(0xFF9775FA)},
    {'emoji': '💰', 'name': 'Savings', 'percentage': 0.50, 'color': NeoColors.yellow}, // Savings is the buffer
  ];

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _budgetFocusNode.requestFocus();
    });
  }

  @override
  void dispose() {
    _budgetController.dispose();
    _budgetFocusNode.dispose();
    super.dispose();
  }

  void _updateBudget(int amount) {
    setState(() {
      _totalBudget = amount;
      _budgetController.text = _formatAmount(amount);
    });
  }

  String _formatAmount(int amount) {
    return amount.toString().replaceAllMapped(
      RegExp(r'(\d{1,3})(?=(\d{3})+(?!\d))'),
      (Match m) => '${m[1]},',
    );
  }

  int _getCategoryAmount(Map<String, dynamic> category) {
    return (_totalBudget * (category['percentage'] as double)).round();
  }

  void _normalizePercentages() {
    double total = _budgetCategories.fold(0.0, (sum, cat) => sum + (cat['percentage'] as double));
    if (total > 0) {
      for (var category in _budgetCategories) {
        category['percentage'] = (category['percentage'] as double) / total;
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: NeoColors.cream,
      body: Stack(
        children: [
          // Background geometric shapes
          Positioned(
            top: -80,
            right: -80,
            child: Container(
              width: 250,
              height: 250,
              decoration: BoxDecoration(
                color: NeoColors.blue,
                shape: BoxShape.circle,
                border: Border.all(color: NeoColors.black, width: 4),
              ),
            ),
          ),
          Positioned(
            bottom: 100,
            left: -30,
            child: Container(
              width: 80,
              height: 80,
              decoration: BoxDecoration(
                color: NeoColors.green,
                shape: BoxShape.circle,
                border: Border.all(color: NeoColors.black, width: 3),
              ),
            ),
          ),

          SafeArea(
            child: Column(
              children: [
                Expanded(
                  child: SingleChildScrollView(
                    padding: const EdgeInsets.only(bottom: 100),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: [
                        const SizedBox(height: 24),
                        // Progress indicator
                        Text(
                          'Step 2 of 3',
                          style: TextStyle(
                            fontSize: 14,
                            color: NeoColors.gray,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                        const SizedBox(height: 40),
                        // Title
                        const Text(
                          'Set Your Monthly Budget',
                          textAlign: TextAlign.center,
                          style: TextStyle(
                            fontSize: 28,
                            fontWeight: FontWeight.w900,
                            color: NeoColors.darkGray,
                            letterSpacing: -0.5,
                          ),
                        ),
                        const SizedBox(height: 8),
                        // Subtitle
                        Text(
                          'How much do you get each month?',
                          textAlign: TextAlign.center,
                          style: TextStyle(
                            fontSize: 15,
                            color: NeoColors.gray,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                        const SizedBox(height: 40),
                        
                        // Main budget input card
                        _buildBudgetInputCard(),
                        
                        const SizedBox(height: 12),
                        Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 40),
                          child: Text(
                            'This includes allowance, pocket money, part-time income',
                            textAlign: TextAlign.center,
                            style: TextStyle(
                              fontSize: 13,
                              color: NeoColors.gray,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                        ),
                        
                        const SizedBox(height: 32),
                        
                        // Quick picks
                        _buildQuickPicks(),
                        
                        const SizedBox(height: 32),
                        
                        // Category budget section
                        _buildCategoryBudget(),
                      ],
                    ),
                  ),
                ),
                
                // Bottom action buttons
                _buildActionButtons(),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildBudgetInputCard() {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 24),
      padding: const EdgeInsets.all(32),
      decoration: BoxDecoration(
        color: NeoColors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: NeoColors.black, width: 4),
        boxShadow: const [
          BoxShadow(
            color: NeoColors.black,
            offset: Offset(8, 8),
            blurRadius: 0,
          ),
        ],
      ),
      child: Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                '₹',
                style: TextStyle(
                  fontSize: 40,
                  fontWeight: FontWeight.w800,
                  color: NeoColors.orange,
                ),
              ),
              const SizedBox(width: 8),
              Flexible(
                child: IntrinsicWidth(
                  child: TextField(
                    controller: _budgetController,
                    focusNode: _budgetFocusNode,
                    keyboardType: TextInputType.number,
                    inputFormatters: [FilteringTextInputFormatter.digitsOnly],
                    textAlign: TextAlign.center,
                    style: const TextStyle(
                      fontSize: 48,
                      fontWeight: FontWeight.w900,
                      color: NeoColors.darkGray,
                      fontFamily: 'monospace',
                    ),
                    decoration: InputDecoration(
                      border: InputBorder.none,
                      isDense: true,
                      contentPadding: EdgeInsets.zero,
                      hintText: '0',
                      hintStyle: TextStyle(
                        color: NeoColors.gray.withOpacity(0.3),
                      ),
                    ),
                    onChanged: (value) {
                      if (value.isNotEmpty) {
                        setState(() {
                          _totalBudget = int.tryParse(value.replaceAll(',', '')) ?? 0;
                        });
                      }
                    },
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Container(
            height: 3,
            width: 200,
            color: NeoColors.orange,
          ),
        ],
      ),
    );
  }

  Widget _buildQuickPicks() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Padding(
          padding: EdgeInsets.only(left: 24),
          child: Text(
            'Quick picks for students',
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w700,
              color: NeoColors.darkGray,
            ),
          ),
        ),
        const SizedBox(height: 12),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 24),
          child: Row(
            children: [
              Expanded(child: _buildQuickPickButton(3000)),
              const SizedBox(width: 8),
              Expanded(child: _buildQuickPickButton(5000)),
              const SizedBox(width: 8),
              Expanded(child: _buildQuickPickButton(8000)),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildQuickPickButton(int amount) {
    final isSelected = _selectedQuickPick == amount;
    return GestureDetector(
      onTap: () {
        setState(() {
          _selectedQuickPick = amount;
          _updateBudget(amount);
        });
      },
      child: Container(
        height: 48,
        decoration: BoxDecoration(
          color: isSelected ? NeoColors.orange : NeoColors.white,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: NeoColors.black, width: 3),
          boxShadow: const [
            BoxShadow(
              color: NeoColors.black,
              offset: Offset(3, 3),
              blurRadius: 0,
            ),
          ],
        ),
        child: Center(
          child: Text(
            '₹${_formatAmount(amount)}',
            style: TextStyle(
              fontSize: 15,
              fontWeight: FontWeight.w700,
              color: isSelected ? NeoColors.white : NeoColors.darkGray,
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildCategoryBudget() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Divide your budget',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.w800,
              color: NeoColors.darkGray,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            "We'll suggest how to split it",
            style: TextStyle(
              fontSize: 13,
              color: NeoColors.gray,
              fontWeight: FontWeight.w500,
            ),
          ),
          const SizedBox(height: 16),
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: NeoColors.white,
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: NeoColors.black, width: 3),
              boxShadow: const [
                BoxShadow(
                  color: NeoColors.black,
                  offset: Offset(4, 4),
                  blurRadius: 0,
                ),
              ],
            ),
            child: Column(
              children: [
                ..._budgetCategories.asMap().entries.map((entry) {
                  final index = entry.key;
                  final category = entry.value;  
                  final amount = _getCategoryAmount(category);
                  final percentage = category['percentage'] as double;
                  final color = category['color'] as Color;
                  return Padding(
                    padding: const EdgeInsets.only(bottom: 12),
                    child: _buildCategoryRow(index, category, amount, percentage, color),
                  );
                }).toList(),
                const SizedBox(height: 8),
                // Add Category Button
                GestureDetector(
                  onTap: _showAddCategoryDialog,
                  child: Container(
                    padding: const EdgeInsets.symmetric(vertical: 12),
                    decoration: BoxDecoration(
                      color: NeoColors.cream,
                      borderRadius: BorderRadius.circular(8),
                      border: Border.all(color: NeoColors.black, width: 2, style: BorderStyle.solid),
                    ),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: const [
                        Icon(Icons.add_circle_outline, size: 20, color: NeoColors.orange),
                        SizedBox(width: 8),
                        Text(
                          'Add Category',
                          style: TextStyle(
                            fontSize: 14,
                            fontWeight: FontWeight.w700,
                            color: NeoColors.orange,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 8),
          Center(
            child: Text(
              'Tap any to customize',
              style: TextStyle(
                fontSize: 12,
                color: NeoColors.gray,
                fontWeight: FontWeight.w500,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildCategoryRow(int index, Map<String, dynamic> category, int amount, double percentage, Color color) {
    return GestureDetector(
      onTap: () => _showEditCategoryDialog(index, category, amount, color),
      child: Column(
        children: [
          Row(
            children: [
              Text(
                category['emoji'] as String,
                style: const TextStyle(fontSize: 20),
              ),
              const SizedBox(width: 8),
              Expanded(
                child: Text(
                  category['name'] as String,
                  style: const TextStyle(
                    fontSize: 15,
                    fontWeight: FontWeight.w600,
                    color: NeoColors.darkGray,
                  ),
                ),
              ),
              Text(
                '₹${_formatAmount(amount)}',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w800,
                  color: color,
                ),
              ),
              const SizedBox(width: 4),
              Icon(Icons.edit_outlined, size: 16, color: NeoColors.gray),
              const SizedBox(width: 8),
              GestureDetector(
                onTap: () => _deleteCategory(index),
                child: Icon(Icons.delete_outline, size: 18, color: NeoColors.red),
              ),
            ],
          ),
          const SizedBox(height: 6),
          Container(
            height: 10,
            decoration: BoxDecoration(
              color: const Color(0xFFE5E5E5),
              border: Border.all(color: NeoColors.black, width: 2),
            ),
            child: FractionallySizedBox(
              alignment: Alignment.centerLeft,
              widthFactor: percentage,
              child: Container(color: color),
            ),
          ),
        ],
      ),
    );
  }

  void _showEditCategoryDialog(int index, Map<String, dynamic> category, int currentAmount, Color color) {
    final nameController = TextEditingController(text: category['name'] as String);
    final amountController = TextEditingController(text: currentAmount.toString());
    
    showDialog(
      context: context,
      builder: (context) => Dialog(
        backgroundColor: Colors.transparent,
        child: Container(
          padding: const EdgeInsets.all(24),
          decoration: BoxDecoration(
            color: NeoColors.white,
            borderRadius: BorderRadius.circular(16),
            border: Border.all(color: NeoColors.black, width: 4),
            boxShadow: const [
              BoxShadow(
                color: NeoColors.black,
                offset: Offset(8, 8),
                blurRadius: 0,
              ),
            ],
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Text(
                'Edit Category',
                style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.w800,
                  color: NeoColors.darkGray,
                ),
              ),
              const SizedBox(height: 20),
              // Category Name Input
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                decoration: BoxDecoration(
                  color: NeoColors.cream,
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: NeoColors.black, width: 3),
                ),
                child: TextField(
                  controller: nameController,
                  textAlign: TextAlign.center,
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w700,
                    color: NeoColors.darkGray,
                  ),
                  decoration: const InputDecoration(
                    border: InputBorder.none,
                    isDense: true,
                    contentPadding: EdgeInsets.zero,
                    hintText: 'Category name',
                  ),
                ),
              ),
              const SizedBox(height: 16),
              // Amount Input
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                decoration: BoxDecoration(
                  color: NeoColors.cream,
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: NeoColors.black, width: 3),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      '₹',
                      style: TextStyle(
                        fontSize: 24,
                        fontWeight: FontWeight.w800,
                        color: color,
                      ),
                    ),
                    const SizedBox(width: 8),
                    SizedBox(
                      width: 120,
                      child: TextField(
                        controller: amountController,
                        keyboardType: TextInputType.number,
                        inputFormatters: [FilteringTextInputFormatter.digitsOnly],
                        textAlign: TextAlign.center,
                        style: const TextStyle(
                          fontSize: 24,
                          fontWeight: FontWeight.w800,
                          color: NeoColors.darkGray,
                        ),
                        decoration: const InputDecoration(
                          border: InputBorder.none,
                          isDense: true,
                          contentPadding: EdgeInsets.zero,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 24),
              Row(
                children: [
                  Expanded(
                    child: GestureDetector(
                      onTap: () => Navigator.pop(context),
                      child: Container(
                        height: 48,
                        decoration: BoxDecoration(
                          color: NeoColors.white,
                          borderRadius: BorderRadius.circular(12),
                          border: Border.all(color: NeoColors.black, width: 3),
                        ),
                        child: const Center(
                          child: Text(
                            'Cancel',
                            style: TextStyle(
                              fontSize: 15,
                              fontWeight: FontWeight.w700,
                              color: NeoColors.darkGray,
                            ),
                          ),
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: GestureDetector(
                      onTap: () {
                        final newName = nameController.text.trim();
                        final newAmount = int.tryParse(amountController.text) ?? currentAmount;
                        if (newName.isNotEmpty) {
                          setState(() {
                            _budgetCategories[index]['name'] = newName;
                            
                            // Lock the user's exact amount for this category
                            final oldAmount = _getCategoryAmount(_budgetCategories[index]);
                            _budgetCategories[index]['percentage'] = newAmount / _totalBudget;
                            
                            // Calculate the difference
                            final difference = newAmount - oldAmount;
                            
                            // Find Savings category and adjust it
                            for (int i = 0; i < _budgetCategories.length; i++) {
                              if (_budgetCategories[i]['name'] == 'Savings') {
                                final savingsAmount = _getCategoryAmount(_budgetCategories[i]);
                                final newSavingsAmount = savingsAmount - difference;
                                // Ensure Savings doesn't go negative
                                if (newSavingsAmount >= 0) {
                                  _budgetCategories[i]['percentage'] = newSavingsAmount / _totalBudget;
                                } else {
                                  // If Savings would go negative, cap this category at available budget
                                  _budgetCategories[i]['percentage'] = 0.0;
                                  final maxAmount = oldAmount + savingsAmount;
                                  _budgetCategories[index]['percentage'] = maxAmount / _totalBudget;
                                }
                                break;
                              }
                            }
                          });
                        }
                        Navigator.pop(context);
                      },
                      child: Container(
                        height: 48,
                        decoration: BoxDecoration(
                          color: color,
                          borderRadius: BorderRadius.circular(12),
                          border: Border.all(color: NeoColors.black, width: 3),
                          boxShadow: const [
                            BoxShadow(
                              color: NeoColors.black,
                              offset: Offset(4, 4),
                              blurRadius: 0,
                            ),
                          ],
                        ),
                        child: const Center(
                          child: Text(
                            'Save',
                            style: TextStyle(
                              fontSize: 15,
                              fontWeight: FontWeight.w800,
                              color: NeoColors.white,
                            ),
                          ),
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildActionButtons() {
    final isValid = _totalBudget > 0;
    return Container(
      padding: const EdgeInsets.fromLTRB(24, 16, 24, 24),
      decoration: const BoxDecoration(
        color: NeoColors.cream,
        border: Border(top: BorderSide(color: NeoColors.black, width: 2)),
      ),
      child: Row(
        children: [
          Expanded(
            flex: 2,
            child: GestureDetector(
              onTap: () {
                Navigator.pushReplacement(
                  context,
                  MaterialPageRoute(builder: (context) => const DashboardScreen()),
                );
              },
              child: Container(
                height: 56,
                decoration: BoxDecoration(
                  color: NeoColors.white,
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: NeoColors.black, width: 3),
                  boxShadow: const [
                    BoxShadow(
                      color: NeoColors.black,
                      offset: Offset(4, 4),
                      blurRadius: 0,
                    ),
                  ],
                ),
                child: const Center(
                  child: Text(
                    'Skip',
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w700,
                      color: NeoColors.darkGray,
                    ),
                  ),
                ),
              ),
            ),
          ),
          const SizedBox(width: 8),
          Expanded(
            flex: 3,
            child: GestureDetector(
              onTap: isValid
                  ? () {
                      // Calculate category budgets
                      final categoryBudgets = <String, double>{};
                      for (var category in _budgetCategories) {
                        final categoryName = category['name'] as String;
                        final percentage = category['percentage'] as double;
                        final amount = _totalBudget * percentage;
                        categoryBudgets[categoryName] = amount;
                      }
                      
                      ref.read(budgetProvider.notifier).setBudget(
                        _totalBudget.toDouble(),
                        categoryBudgets: categoryBudgets,
                      );
                      Navigator.pushReplacement(
                        context,
                        MaterialPageRoute(builder: (context) => const DashboardScreen()),
                      );
                    }
                  : null,
              child: Container(
                height: 56,
                decoration: BoxDecoration(
                  color: isValid ? NeoColors.orange : NeoColors.gray.withOpacity(0.5),
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: NeoColors.black, width: 4),
                  boxShadow: [
                    BoxShadow(
                      color: NeoColors.black,
                      offset: const Offset(8, 8),
                      blurRadius: 0,
                    ),
                  ],
                ),
                child: const Center(
                  child: Text(
                    'Continue',
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w800,
                      color: NeoColors.white,
                    ),
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  void _deleteCategory(int index) {
    if (_budgetCategories.length <= 1) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('You must have at least one category'),
          backgroundColor: NeoColors.red,
        ),
      );
      return;
    }

    showDialog(
      context: context,
      builder: (context) => Dialog(
        backgroundColor: Colors.transparent,
        child: Container(
          padding: const EdgeInsets.all(24),
          decoration: BoxDecoration(
            color: NeoColors.white,
            borderRadius: BorderRadius.circular(16),
            border: Border.all(color: NeoColors.black, width: 4),
            boxShadow: const [
              BoxShadow(
                color: NeoColors.black,
                offset: Offset(8, 8),
                blurRadius: 0,
              ),
            ],
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Text(
                'Delete Category?',
                style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.w900,
                  color: NeoColors.black,
                ),
              ),
              const SizedBox(height: 12),
              Text(
                'Are you sure you want to delete "${_budgetCategories[index]['name']}"?',
                textAlign: TextAlign.center,
                style: const TextStyle(
                  fontSize: 14,
                  color: NeoColors.gray,
                  fontWeight: FontWeight.w500,
                ),
              ),
              const SizedBox(height: 24),
              Row(
                children: [
                  Expanded(
                    child: GestureDetector(
                      onTap: () => Navigator.pop(context),
                      child: Container(
                        height: 48,
                        decoration: BoxDecoration(
                          color: NeoColors.white,
                          borderRadius: BorderRadius.circular(12),
                          border: Border.all(color: NeoColors.black, width: 3),
                        ),
                        child: const Center(
                          child: Text(
                            'Cancel',
                            style: TextStyle(
                              fontSize: 15,
                              fontWeight: FontWeight.w700,
                              color: NeoColors.black,
                            ),
                          ),
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: GestureDetector(
                      onTap: () {
                        setState(() {
                          _budgetCategories.removeAt(index);
                          _normalizePercentages();
                        });
                        Navigator.pop(context);
                      },
                      child: Container(
                        height: 48,
                        decoration: BoxDecoration(
                          color: NeoColors.red,
                          borderRadius: BorderRadius.circular(12),
                          border: Border.all(color: NeoColors.black, width: 3),
                          boxShadow: const [
                            BoxShadow(
                              color: NeoColors.black,
                              offset: Offset(4, 4),
                              blurRadius: 0,
                            ),
                          ],
                        ),
                        child: const Center(
                          child: Text(
                            'Delete',
                            style: TextStyle(
                              fontSize: 15,
                              fontWeight: FontWeight.w800,
                              color: NeoColors.white,
                            ),
                          ),
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _showAddCategoryDialog() {
    final nameController = TextEditingController();
    final amountController = TextEditingController(text: '500');
    String selectedEmoji = '🎯';
    Color selectedColor = NeoColors.blue;

    final emojis = ['🎯', '🎮', '🏋️', '🎓', '🍿', '🚕', '💊', '🎨', '⚽', '🏠'];
    final colors = [NeoColors.blue, NeoColors.orange, NeoColors.green, NeoColors.red, NeoColors.yellow];

    showDialog(
      context: context,
      builder: (context) => StatefulBuilder(
        builder: (context, setDialogState) => Dialog(
          backgroundColor: Colors.transparent,
          child: Container(
            padding: const EdgeInsets.all(24),
            decoration: BoxDecoration(
              color: NeoColors.white,
              borderRadius: BorderRadius.circular(16),
              border: Border.all(color: NeoColors.black, width: 4),
              boxShadow: const [
                BoxShadow(
                  color: NeoColors.black,
                  offset: Offset(8, 8),
                  blurRadius: 0,
                ),
              ],
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                const Text(
                  'Add Category',
                  style: TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.w800,
                    color: NeoColors.darkGray,
                  ),
                ),
                const SizedBox(height: 20),
                // Category Name Input
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                  decoration: BoxDecoration(
                    color: NeoColors.cream,
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(color: NeoColors.black, width: 3),
                  ),
                  child: TextField(
                    controller: nameController,
                    textAlign: TextAlign.center,
                    autofocus: true,
                    style: const TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w700,
                      color: NeoColors.darkGray,
                    ),
                    decoration: const InputDecoration(
                      border: InputBorder.none,
                      isDense: true,
                      contentPadding: EdgeInsets.zero,
                      hintText: 'Category name',
                    ),
                  ),
                ),
                const SizedBox(height: 16),
                // Amount Input
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                  decoration: BoxDecoration(
                    color: NeoColors.cream,
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(color: NeoColors.black, width: 3),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      const Text(
                        '₹',
                        style: TextStyle(
                          fontSize: 24,
                          fontWeight: FontWeight.w800,
                          color: NeoColors.orange,
                        ),
                      ),
                      const SizedBox(width: 8),
                      SizedBox(
                        width: 120,
                        child: TextField(
                          controller: amountController,
                          keyboardType: TextInputType.number,
                          inputFormatters: [FilteringTextInputFormatter.digitsOnly],
                          textAlign: TextAlign.center,
                          style: const TextStyle(
                            fontSize: 24,
                            fontWeight: FontWeight.w800,
                            color: NeoColors.darkGray,
                          ),
                          decoration: const InputDecoration(
                            border: InputBorder.none,
                            isDense: true,
                            contentPadding: EdgeInsets.zero,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 16),
                // Emoji Picker
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'Choose Icon:',
                      style: TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.w600,
                        color: NeoColors.gray,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Wrap(
                      spacing: 8,
                      children: emojis.map((emoji) {
                        final isSelected = selectedEmoji == emoji;
                        return GestureDetector(
                          onTap: () {
                            setDialogState(() {
                              selectedEmoji = emoji;
                            });
                          },
                          child: Container(
                            width: 40,
                            height: 40,
                            decoration: BoxDecoration(
                              color: isSelected ? NeoColors.orange : NeoColors.cream,
                              borderRadius: BorderRadius.circular(8),
                              border: Border.all(color: NeoColors.black, width: 2),
                            ),
                            child: Center(
                              child: Text(emoji, style: const TextStyle(fontSize: 20)),
                            ),
                          ),
                        );
                      }).toList(),
                    ),
                  ],
                ),
                const SizedBox(height: 16),
                // Color Picker
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'Choose Color:',
                      style: TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.w600,
                        color: NeoColors.gray,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Wrap(
                      spacing: 8,
                      children: colors.map((color) {
                        final isSelected = selectedColor == color;
                        return GestureDetector(
                          onTap: () {
                            setDialogState(() {
                              selectedColor = color;
                            });
                          },
                          child: Container(
                            width: 36,
                            height: 36,
                            decoration: BoxDecoration(
                              color: color,
                              shape: BoxShape.circle,
                              border: Border.all(
                                color: NeoColors.black,
                                width: isSelected ? 3 : 2,
                              ),
                            ),
                            child: isSelected
                                ? const Icon(Icons.check, color: NeoColors.white, size: 20)
                                : null,
                          ),
                        );
                      }).toList(),
                    ),
                  ],
                ),
                const SizedBox(height: 24),
                Row(
                  children: [
                    Expanded(
                      child: GestureDetector(
                        onTap: () => Navigator.pop(context),
                        child: Container(
                          height: 48,
                          decoration: BoxDecoration(
                            color: NeoColors.white,
                            borderRadius: BorderRadius.circular(12),
                            border: Border.all(color: NeoColors.black, width: 3),
                          ),
                          child: const Center(
                            child: Text(
                              'Cancel',
                              style: TextStyle(
                                fontSize: 15,
                                fontWeight: FontWeight.w700,
                                color: NeoColors.darkGray,
                              ),
                            ),
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(width: 8),
                    Expanded(
                      child: GestureDetector(
                        onTap: () {
                          final newName = nameController.text.trim();
                          final newAmount = int.tryParse(amountController.text) ?? 500;
                          if (newName.isNotEmpty) {
                            setState(() {
                              _budgetCategories.add({
                                'emoji': selectedEmoji,
                                'name': newName,
                                'percentage': newAmount / _totalBudget,
                                'color': selectedColor,
                              });
                              _normalizePercentages();
                            });
                          }
                          Navigator.pop(context);
                        },
                        child: Container(
                          height: 48,
                          decoration: BoxDecoration(
                            color: NeoColors.orange,
                            borderRadius: BorderRadius.circular(12),
                            border: Border.all(color: NeoColors.black, width: 3),
                            boxShadow: const [
                              BoxShadow(
                                color: NeoColors.black,
                                offset: Offset(4, 4),
                                blurRadius: 0,
                              ),
                            ],
                          ),
                          child: const Center(
                            child: Text(
                              'Add',
                              style: TextStyle(
                                fontSize: 15,
                                fontWeight: FontWeight.w800,
                                color: NeoColors.white,
                              ),
                            ),
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
