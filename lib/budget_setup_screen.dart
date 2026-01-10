import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'theme/neo_colors.dart';
import 'dashboard_screen.dart';

class BudgetSetupScreen extends StatefulWidget {
  const BudgetSetupScreen({super.key});

  @override
  State<BudgetSetupScreen> createState() => _BudgetSetupScreenState();
}

class _BudgetSetupScreenState extends State<BudgetSetupScreen> {
  final TextEditingController _budgetController = TextEditingController(text: '6,000');
  final FocusNode _budgetFocusNode = FocusNode();
  int _totalBudget = 6000;
  int _selectedQuickPick = 6000;

  // Category percentages
  final Map<String, double> _categoryPercentages = {
    '🍕 Food & Dining': 0.27,
    '🚌 Transport': 0.10,
    '🎬 Entertainment': 0.13,
    '🛍️ Shopping': 0.17,
    '📚 Books & Study': 0.10,
    '💰 Savings': 0.23,
  };

  final Map<String, Color> _categoryColors = {
    '🍕 Food & Dining': NeoColors.orange,
    '🚌 Transport': NeoColors.blue,
    '🎬 Entertainment': NeoColors.red,
    '🛍️ Shopping': NeoColors.green,
    '📚 Books & Study': const Color(0xFF9775FA),
    '💰 Savings': NeoColors.yellow,
  };

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

  int _getCategoryAmount(String category) {
    return (_totalBudget * _categoryPercentages[category]!).round();
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
                ..._categoryPercentages.keys.map((category) {
                  final amount = _getCategoryAmount(category);
                  final percentage = _categoryPercentages[category]!;
                  final color = _categoryColors[category]!;
                  return Padding(
                    padding: const EdgeInsets.only(bottom: 12),
                    child: _buildCategoryRow(category, amount, percentage, color),
                  );
                }).toList(),
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

  Widget _buildCategoryRow(String category, int amount, double percentage, Color color) {
    return GestureDetector(
      onTap: () => _showEditCategoryDialog(category, amount, color),
      child: Column(
        children: [
          Row(
            children: [
              Text(
                category.split(' ')[0],
                style: const TextStyle(fontSize: 20),
              ),
              const SizedBox(width: 8),
              Expanded(
                child: Text(
                  category.substring(category.indexOf(' ') + 1),
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

  void _showEditCategoryDialog(String category, int currentAmount, Color color) {
    final controller = TextEditingController(text: currentAmount.toString());
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
              Text(
                'Edit ${category.substring(category.indexOf(' ') + 1)}',
                style: const TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.w800,
                  color: NeoColors.darkGray,
                ),
              ),
              const SizedBox(height: 24),
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
                        controller: controller,
                        keyboardType: TextInputType.number,
                        inputFormatters: [FilteringTextInputFormatter.digitsOnly],
                        autofocus: true,
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
                        final newAmount = int.tryParse(controller.text) ?? currentAmount;
                        setState(() {
                          // Update the percentage based on new amount
                          _categoryPercentages[category] = newAmount / _totalBudget;
                        });
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
}
