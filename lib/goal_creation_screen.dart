import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'theme/neo_colors.dart';

class GoalCreationScreen extends StatefulWidget {
  const GoalCreationScreen({super.key});

  @override
  State<GoalCreationScreen> createState() => _GoalCreationScreenState();
}

class _GoalCreationScreenState extends State<GoalCreationScreen> {
  String? _selectedGoalType;
  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _amountController = TextEditingController();
  int _targetAmount = 0;
  DateTime? _targetDate;
  int _monthsToGoal = 6;
  
  final Map<String, String> _goalTypes = {
    '📱 New Phone': '📱',
    '✈️ Trip/Travel': '✈️',
    '🎮 Gaming Console': '🎮',
    '👕 New Clothes': '👕',
    '🏍️ Bike/Vehicle': '🏍️',
    '➕ Custom Goal': '➕',
  };

  @override
  void initState() {
    super.initState();
    _targetDate = DateTime.now().add(Duration(days: 30 * _monthsToGoal));
  }

  @override
  void dispose() {
    _nameController.dispose();
    _amountController.dispose();
    super.dispose();
  }

  int get _monthlyContribution {
    if (_targetAmount == 0 || _monthsToGoal == 0) return 0;
    return (_targetAmount / _monthsToGoal).ceil();
  }

  String _formatAmount(int amount) {
    return amount.toString().replaceAllMapped(
      RegExp(r'(\d{1,3})(?=(\d{3})+(?!\d))'),
      (Match m) => '${m[1]},',
    );
  }

  bool get _isValid {
    return _selectedGoalType != null && 
           _nameController.text.isNotEmpty && 
           _targetAmount > 0;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: NeoColors.cream,
      body: Stack(
        children: [
          // Background shapes
          Positioned(
            top: -60,
            left: -60,
            child: Container(
              width: 180,
              height: 180,
              decoration: BoxDecoration(
                color: NeoColors.orange,
                shape: BoxShape.circle,
                border: Border.all(color: NeoColors.black, width: 4),
              ),
            ),
          ),
          Positioned(
            bottom: -40,
            right: -40,
            child: Container(
              width: 120,
              height: 120,
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
                // Top bar
                _buildTopBar(),
                
                Expanded(
                  child: SingleChildScrollView(
                    padding: const EdgeInsets.only(bottom: 100),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const SizedBox(height: 24),
                        
                        // Goal type selection
                        _buildGoalTypeSelection(),
                        
                        if (_selectedGoalType != null) ...[
                          const SizedBox(height: 32),
                          _buildGoalDetailsForm(),
                        ],
                      ],
                    ),
                  ),
                ),
                
                // Bottom buttons
                if (_selectedGoalType != null) _buildActionButtons(),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTopBar() {
    return Padding(
      padding: const EdgeInsets.all(16),
      child: Row(
        children: [
          GestureDetector(
            onTap: () => Navigator.pop(context),
            child: Container(
              width: 40,
              height: 40,
              decoration: BoxDecoration(
                color: NeoColors.white,
                shape: BoxShape.circle,
                border: Border.all(color: NeoColors.black, width: 2),
              ),
              child: const Icon(Icons.arrow_back, size: 20),
            ),
          ),
          const Expanded(
            child: Center(
              child: Text(
                'Create a Goal',
                style: TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.w800,
                  color: NeoColors.darkGray,
                ),
              ),
            ),
          ),
          const SizedBox(width: 40), // Balance
        ],
      ),
    );
  }

  Widget _buildGoalTypeSelection() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'What are you saving for?',
            style: TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.w800,
              color: NeoColors.darkGray,
            ),
          ),
          const SizedBox(height: 16),
          GridView.builder(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 2,
              crossAxisSpacing: 8,
              mainAxisSpacing: 8,
              childAspectRatio: 2.0, // Increased from 1.9 to fix overflow
            ),
            itemCount: _goalTypes.length,
            itemBuilder: (context, index) {
              final goalType = _goalTypes.keys.elementAt(index);
              final isSelected = _selectedGoalType == goalType;
              return GestureDetector(
                onTap: () {
                  setState(() {
                    _selectedGoalType = goalType;
                    if (goalType != '➕ Custom Goal') {
                      _nameController.text = goalType.substring(goalType.indexOf(' ') + 1);
                    }
                  });
                },
                child: Container(
                  padding: const EdgeInsets.all(8), // Reduced from 10
                  decoration: BoxDecoration(
                    color: isSelected ? NeoColors.orange : NeoColors.white,
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(color: NeoColors.black, width: 3),
                    boxShadow: [
                      BoxShadow(
                        color: NeoColors.black,
                        offset: isSelected ? const Offset(6, 6) : const Offset(4, 4),
                        blurRadius: 0,
                      ),
                    ],
                  ),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text(
                        _goalTypes[goalType]!,
                        style: const TextStyle(fontSize: 24), // Reduced from 28
                      ),
                      const SizedBox(height: 2),
                      Text(
                        goalType.substring(goalType.indexOf(' ') + 1),
                        textAlign: TextAlign.center,
                        style: TextStyle(
                          fontSize: 12, // Reduced from 13
                          fontWeight: FontWeight.w600,
                          color: isSelected ? NeoColors.white : NeoColors.darkGray,
                        ),
                      ),
                    ],
                  ),
                ),
              );
            },
          ),
        ],
      ),
    );
  }

  Widget _buildGoalDetailsForm() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Name input
          const Text(
            'Name your goal',
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w700,
              color: NeoColors.darkGray,
            ),
          ),
          const SizedBox(height: 12),
          Container(
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
            child: TextField(
              controller: _nameController,
              style: const TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w600,
                color: NeoColors.darkGray,
              ),
              decoration: InputDecoration(
                hintText: 'e.g., iPhone 15',
                hintStyle: TextStyle(color: NeoColors.gray),
                border: InputBorder.none,
                contentPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
              ),
            ),
          ),
          
          const SizedBox(height: 24),
          
          // Target amount
          const Text(
            'How much do you need?',
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w700,
              color: NeoColors.darkGray,
            ),
          ),
          const SizedBox(height: 12),
          Container(
            padding: const EdgeInsets.all(20),
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
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Text(
                  '₹',
                  style: TextStyle(
                    fontSize: 32,
                    fontWeight: FontWeight.w800,
                    color: NeoColors.orange,
                  ),
                ),
                const SizedBox(width: 8),
                Flexible(
                  child: IntrinsicWidth(
                    child: TextField(
                      controller: _amountController,
                      keyboardType: TextInputType.number,
                      inputFormatters: [FilteringTextInputFormatter.digitsOnly],
                      textAlign: TextAlign.center,
                      style: const TextStyle(
                        fontSize: 32,
                        fontWeight: FontWeight.w800,
                        color: NeoColors.darkGray,
                      ),
                      decoration: InputDecoration(
                        border: InputBorder.none,
                        isDense: true,
                        contentPadding: EdgeInsets.zero,
                        hintText: '0',
                        hintStyle: TextStyle(color: NeoColors.gray.withOpacity(0.3)),
                      ),
                      onChanged: (value) {
                        setState(() {
                          _targetAmount = int.tryParse(value) ?? 0;
                        });
                      },
                    ),
                  ),
                ),
              ],
            ),
          ),
          
          const SizedBox(height: 12),
          Row(
            children: [
              Expanded(child: _buildQuickAmountPill(5000)),
              const SizedBox(width: 8),
              Expanded(child: _buildQuickAmountPill(10000)),
              const SizedBox(width: 8),
              Expanded(child: _buildQuickAmountPill(20000)),
            ],
          ),
          
          const SizedBox(height: 24),
          
          // Target date
          const Text(
            'When do you need it?',
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w700,
              color: NeoColors.darkGray,
            ),
          ),
          const SizedBox(height: 12),
          GestureDetector(
            onTap: _showMonthPicker,
            child: Container(
              height: 56,
              padding: const EdgeInsets.symmetric(horizontal: 20),
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
              child: Row(
                children: [
                  const Text('📅', style: TextStyle(fontSize: 24)),
                  const SizedBox(width: 12),
                  Text(
                    '$_monthsToGoal months from now',
                    style: const TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                      color: NeoColors.darkGray,
                    ),
                  ),
                ],
              ),
            ),
          ),
          
          const SizedBox(height: 24),
          
          // Monthly contribution
          if (_targetAmount > 0) _buildMonthlyContribution(),
        ],
      ),
    );
  }

  Widget _buildQuickAmountPill(int amount) {
    return GestureDetector(
      onTap: () {
        setState(() {
          _targetAmount = amount;
          _amountController.text = amount.toString();
        });
      },
      child: Container(
        height: 40,
        decoration: BoxDecoration(
          color: NeoColors.white,
          borderRadius: BorderRadius.circular(20),
          border: Border.all(color: NeoColors.black, width: 2),
          boxShadow: const [
            BoxShadow(
              color: NeoColors.black,
              offset: Offset(2, 2),
              blurRadius: 0,
            ),
          ],
        ),
        child: Center(
          child: Text(
            '₹${_formatAmount(amount)}',
            style: const TextStyle(
              fontSize: 13,
              fontWeight: FontWeight.w700,
              color: NeoColors.darkGray,
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildMonthlyContribution() {
    final monthlyAmount = _monthlyContribution;
    final isHigh = monthlyAmount > 3000; // Example threshold
    
    return Container(
      padding: const EdgeInsets.all(20),
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
      child: Row(
        children: [
          const Text('💡', style: TextStyle(fontSize: 32)),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'You need to save',
                  style: TextStyle(
                    fontSize: 14,
                    color: NeoColors.gray,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  '₹${_formatAmount(monthlyAmount)}/month',
                  style: const TextStyle(
                    fontSize: 28,
                    fontWeight: FontWeight.w900,
                    color: NeoColors.darkGray,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  isHigh ? '⚠️ This is high!' : 'to reach your goal on time',
                  style: TextStyle(
                    fontSize: 13,
                    color: isHigh ? NeoColors.orange : NeoColors.gray,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  void _showMonthPicker() {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      builder: (context) => Container(
        height: 320,
        decoration: const BoxDecoration(
          color: NeoColors.white,
          borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
          border: Border(
            top: BorderSide(color: NeoColors.black, width: 4),
            left: BorderSide(color: NeoColors.black, width: 4),
            right: BorderSide(color: NeoColors.black, width: 4),
          ),
        ),
        child: Column(
          children: [
            const SizedBox(height: 20),
            const Text(
              'Select Timeline',
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.w800,
                color: NeoColors.darkGray,
              ),
            ),
            const SizedBox(height: 20),
            Expanded(
              child: ListView.builder(
                itemCount: 24, // 1-24 months
                itemBuilder: (context, index) {
                  final months = index + 1;
                  return GestureDetector(
                    onTap: () {
                      setState(() {
                        _monthsToGoal = months;
                        _targetDate = DateTime.now().add(Duration(days: 30 * months));
                      });
                      Navigator.pop(context);
                    },
                    child: Container(
                      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
                      decoration: BoxDecoration(
                        color: _monthsToGoal == months ? NeoColors.orange.withOpacity(0.1) : null,
                      ),
                      child: Text(
                        '$months ${months == 1 ? 'month' : 'months'} from now',
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: _monthsToGoal == months ? FontWeight.w700 : FontWeight.w600,
                          color: _monthsToGoal == months ? NeoColors.orange : NeoColors.darkGray,
                        ),
                      ),
                    ),
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildActionButtons() {
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
              onTap: () => Navigator.pop(context),
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
                    'Cancel',
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
              onTap: _isValid ? _createGoal : null,
              child: Container(
                height: 56,
                decoration: BoxDecoration(
                  color: _isValid ? NeoColors.orange : NeoColors.gray.withOpacity(0.5),
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
                    'Create Goal',
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

  void _createGoal() {
    // Show success message
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        backgroundColor: NeoColors.green,
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
          side: const BorderSide(color: NeoColors.black, width: 3),
        ),
        content: const Text(
          'Goal Created! 🎉',
          style: TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.w800,
            color: NeoColors.white,
          ),
        ),
      ),
    );
    
    // Navigate back after delay
    Future.delayed(const Duration(milliseconds: 800), () {
      Navigator.pop(context);
    });
  }
}
