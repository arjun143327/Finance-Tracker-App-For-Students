import 'dart:ui';
import 'dart:math' as math;
import 'package:flutter/material.dart';

class AddExpenseScreen extends StatefulWidget {
  const AddExpenseScreen({super.key});

  @override
  State<AddExpenseScreen> createState() => _AddExpenseScreenState();
}

class _AddExpenseScreenState extends State<AddExpenseScreen> with TickerProviderStateMixin {
  late AnimationController _bgController;
  late AnimationController _splitController;
  late Animation<double> _splitAnimation;

  final TextEditingController _amountController = TextEditingController();
  final FocusNode _amountFocus = FocusNode();
  
  String _selectedCategory = "Food & Dining";
  bool _isSplitEnabled = false;
  int _splitCount = 2;
  
  // Date & Time
  DateTime _selectedDate = DateTime.now();
  TimeOfDay _selectedTime = TimeOfDay.now();

  @override
  void initState() {
    super.initState();
    _bgController = AnimationController(duration: const Duration(seconds: 10), vsync: this)..repeat(reverse: true);
    
    _splitController = AnimationController(duration: const Duration(milliseconds: 200), vsync: this);
    _splitAnimation = CurvedAnimation(parent: _splitController, curve: Curves.easeInOut);

    // Auto-focus amount
    WidgetsBinding.instance.addPostFrameCallback((_) {
      FocusScope.of(context).requestFocus(_amountFocus);
    });
  }

  @override
  void dispose() {
    _bgController.dispose();
    _splitController.dispose();
    _amountController.dispose();
    _amountFocus.dispose();
    super.dispose();
  }

  void _onCategorySelected(String category) {
    setState(() {
      _selectedCategory = category;
    });
  }

  void _toggleSplit(bool value) {
    setState(() {
      _isSplitEnabled = value;
      if (value) {
        _splitController.forward();
      } else {
        _splitController.reverse();
      }
    });
  }

  void _incrementSplit() {
    setState(() {
      _splitCount++;
    });
  }

  void _decrementSplit() {
    if (_splitCount > 2) {
      setState(() {
        _splitCount--;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black, // Fallback
      body: Stack(
        children: [
          // 1. Background
          _buildBackground(),

          // 2. Content
          SafeArea(
            child: Column(
              children: [
                _buildTopBar(),
                Expanded(
                  child: SingleChildScrollView(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        _buildAmountInput(),
                        const SizedBox(height: 24),
                        _buildCategorySection(),
                        const SizedBox(height: 24),
                        _buildDescriptionInput(),
                        const SizedBox(height: 16),
                        _buildDateTimeSection(),
                        const SizedBox(height: 16),
                        _buildSplitBillSection(),
                        const SizedBox(height: 100), // Space for bottom buttons
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),

          // 3. Bottom Buttons
          Positioned(
            left: 0,
            right: 0,
            bottom: 0,
            child: _buildBottomButtons(),
          ),
        ],
      ),
    );
  }

  Widget _buildBackground() {
    return Stack(
      children: [
        Container(
          decoration: const BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topCenter,
              end: Alignment.bottomCenter,
              colors: [Color(0xFF0F172A), Color(0xFF1E293B)],
            ),
          ),
        ),
        Positioned.fill(child: CustomPaint(painter: _GridPainter())),
        AnimatedBuilder(
          animation: _bgController,
          builder: (context, child) {
            double offset = math.sin(_bgController.value * math.pi) * 20;
            return Stack(
              children: [
                Positioned(top: -50, right: -50 + offset, child: _MeshOrb(color: const Color(0xFF06B6D4), size: 200)),
                Positioned(bottom: 100, left: -50 - offset, child: _MeshOrb(color: const Color(0xFF8B5CF6), size: 250)),
              ],
            );
          },
        ),
         Positioned.fill(
          child: Container(
             decoration: BoxDecoration(
               gradient: RadialGradient(
                 colors: [Colors.white.withOpacity(0.03), Colors.transparent],
                 center: Alignment.center,
                 radius: 0.8,
               ),
             ),
          ),
        ),
      ],
    );
  }

  Widget _buildTopBar() {
    return Container(
      height: 60,
      padding: const EdgeInsets.symmetric(horizontal: 16),
      decoration: BoxDecoration(
        color: const Color(0xFF0F172A).withOpacity(0.5),
        border: Border(bottom: BorderSide(color: Colors.white.withOpacity(0.05))),
      ),
      child: ClipRRect(
         child: BackdropFilter(
           filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
           child: Row(
            children: [
              IconButton(
                onPressed: () => Navigator.of(context).pop(),
                icon: const Icon(Icons.close, color: Colors.white),
              ),
              const Expanded(
                child: Center(
                  child: Text(
                    "Add Expense",
                    style: TextStyle(color: Colors.white, fontSize: 18, fontWeight: FontWeight.w600),
                  ),
                ),
              ),
              const SizedBox(width: 48), // Balance for centering
            ],
          ),
         ),
      ),
    );
  }

  Widget _buildAmountInput() {
    return Padding(
      padding: const EdgeInsets.only(top: 40, left: 24, right: 24),
      child: Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              const Text("₹", style: TextStyle(color: Color(0xFF06B6D4), fontSize: 32, fontWeight: FontWeight.bold)),
              const SizedBox(width: 8),
              IntrinsicWidth(
                child: TextField(
                  controller: _amountController,
                  focusNode: _amountFocus,
                  keyboardType: TextInputType.number,
                  style: const TextStyle(color: Colors.white, fontSize: 56, fontWeight: FontWeight.bold, fontFamily: 'monospace'),
                  cursorColor: const Color(0xFF06B6D4),
                  decoration: const InputDecoration(
                    hintText: "0",
                    hintStyle: TextStyle(color: Color(0xFF64748B)),
                    border: InputBorder.none,
                    isDense: true,
                    contentPadding: EdgeInsets.zero,
                  ),
                  onChanged: (val) => setState(() {}),
                ),
              ),
            ],
          ),
          if (_amountController.text.isEmpty)
            const Text("Tap to enter amount", style: TextStyle(color: Color(0xFF94A3B8), fontSize: 13)),
          
          const SizedBox(height: 8),
          AnimatedContainer(
            duration: const Duration(milliseconds: 200),
            height: 2,
            width: _amountFocus.hasFocus ? 120 : 60,
            color: const Color(0xFF06B6D4),
          ),
        ],
      ),
    );
  }

  Widget _buildCategorySection() {
    final categories = [
      {"icon": "🍕", "name": "Food & Dining", "short": "Food"},
      {"icon": "🚌", "name": "Transport", "short": "Transport"},
      {"icon": "🎬", "name": "Entertainment", "short": "Movies"},
      {"icon": "🛍️", "name": "Shopping", "short": "Shopping"},
      {"icon": "📚", "name": "Education", "short": "Books"},
      {"icon": "📱", "name": "Bills & Utilities", "short": "Bills"},
      {"icon": "💊", "name": "Healthcare", "short": "Health"},
      {"icon": "➕", "name": "Other", "short": "Other"},
    ];

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Padding(
          padding: EdgeInsets.only(left: 24),
          child: Text("Category", style: TextStyle(color: Colors.white, fontSize: 16, fontWeight: FontWeight.w600)),
        ),
        const SizedBox(height: 16),
        SingleChildScrollView(
          scrollDirection: Axis.horizontal,
          padding: const EdgeInsets.symmetric(horizontal: 24),
          child: Row(
            children: categories.map((cat) {
              final isSelected = _selectedCategory == cat["name"];
              return Padding(
                padding: const EdgeInsets.only(right: 8),
                child: GestureDetector(
                  onTap: () => _onCategorySelected(cat["name"]!),
                  child: AnimatedContainer(
                    duration: const Duration(milliseconds: 200),
                    padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                    decoration: BoxDecoration(
                      color: isSelected 
                          ? const Color(0xFF06B6D4).withOpacity(0.2) 
                          : Colors.white.withOpacity(0.05),
                      borderRadius: BorderRadius.circular(20),
                      border: Border.all(
                        color: isSelected 
                            ? const Color(0xFF06B6D4) 
                            : Colors.white.withOpacity(0.1),
                        width: isSelected ? 2 : 1,
                      ),
                      boxShadow: isSelected
                          ? [BoxShadow(color: const Color(0xFF06B6D4).withOpacity(0.3), blurRadius: 12, offset: const Offset(0, 4))]
                          : [],
                    ),
                    child: Row(
                      children: [
                        Text(cat["icon"]!, style: const TextStyle(fontSize: 18)),
                        const SizedBox(width: 8),
                        Text(
                          cat["short"]!,
                          style: TextStyle(
                            color: isSelected ? const Color(0xFF06B6D4) : const Color(0xFF94A3B8),
                            fontSize: 14,
                            fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              );
            }).toList(),
          ),
        ),
      ],
    );
  }

  Widget _buildDescriptionInput() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Padding(
          padding: EdgeInsets.only(left: 24, bottom: 16),
          child: Text("Description (Optional)", style: TextStyle(color: Colors.white, fontSize: 16)),
        ),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 24),
          child: _GlassContainer(
            child: TextField(
              style: const TextStyle(color: Colors.white),
              decoration: const InputDecoration(
                hintText: "e.g., Lunch with friends",
                hintStyle: TextStyle(color: Color(0xFF64748B)),
                border: InputBorder.none,
                contentPadding: EdgeInsets.all(16),
              ),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildDateTimeSection() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 24),
      child: Row(
        children: [
          Expanded(
            child: GestureDetector(
              onTap: () async {
                 final date = await showDatePicker(
                  context: context,
                  initialDate: _selectedDate,
                  firstDate: DateTime(2020),
                  lastDate: DateTime(2030),
                  builder: (context, child) => Theme(
                    data: ThemeData.dark().copyWith(
                      colorScheme: const ColorScheme.dark(
                        primary: Color(0xFF06B6D4),
                        onPrimary: Colors.white,
                        surface: Color(0xFF1E293B),
                        onSurface: Colors.white,
                      ),
                    ),
                    child: child!,
                  ),
                );
                if (date != null) setState(() => _selectedDate = date);
              },
              child: _GlassContainer(
                padding: const EdgeInsets.all(12),
                height: 70,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    const Icon(Icons.calendar_today, color: Color(0xFF06B6D4), size: 16),
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text("Date", style: TextStyle(color: Color(0xFF94A3B8), fontSize: 11)),
                        const SizedBox(height: 2),
                        Text(
                          "${_selectedDate.day}/${_selectedDate.month}", // Simple formatting
                          style: const TextStyle(color: Colors.white, fontSize: 14, fontWeight: FontWeight.bold),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
          ),
          const SizedBox(width: 8),
          Expanded(
            child: GestureDetector(
              onTap: () async {
                final time = await showTimePicker(
                  context: context,
                  initialTime: _selectedTime,
                  builder: (context, child) => Theme(
                    data: ThemeData.dark().copyWith(
                      colorScheme: const ColorScheme.dark(
                        primary: Color(0xFF06B6D4),
                        onPrimary: Colors.white,
                        surface: Color(0xFF1E293B),
                        onSurface: Colors.white,
                      ),
                    ),
                    child: child!,
                  ),
                );
                if (time != null) setState(() => _selectedTime = time);
              },
              child: _GlassContainer(
                padding: const EdgeInsets.all(12),
                height: 70,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    const Icon(Icons.access_time, color: Color(0xFF8B5CF6), size: 16),
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text("Time", style: TextStyle(color: Color(0xFF94A3B8), fontSize: 11)),
                        const SizedBox(height: 2),
                        Text(
                          _selectedTime.format(context), 
                          style: const TextStyle(color: Colors.white, fontSize: 14, fontWeight: FontWeight.bold),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSplitBillSection() {
    return Column(
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 24),
          child: _GlassContainer(
            padding: const EdgeInsets.all(16),
            child: Row(
              children: [
                Container(
                  width: 32, height: 32,
                  decoration: const BoxDecoration(
                    shape: BoxShape.circle,
                    gradient: LinearGradient(colors: [Color(0xFF8B5CF6), Color(0xFF6366F1)]),
                  ),
                  child: const Icon(Icons.people, color: Colors.white, size: 16),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: const [
                      Text("Split with Friends?", style: TextStyle(color: Colors.white, fontSize: 15, fontWeight: FontWeight.w600)),
                      Text("Divide expense equally", style: TextStyle(color: Color(0xFF94A3B8), fontSize: 12)),
                    ],
                  ),
                ),
                Switch(
                  value: _isSplitEnabled,
                  onChanged: _toggleSplit,
                  activeColor: const Color(0xFF06B6D4),
                  activeTrackColor: const Color(0xFF06B6D4).withOpacity(0.3),
                  inactiveThumbColor: Colors.grey,
                  inactiveTrackColor: Colors.white.withOpacity(0.1),
                ),
              ],
            ),
          ),
        ),
        
        SizeTransition(
          sizeFactor: _splitAnimation,
          axisAlignment: -1.0,
          child: Padding(
            padding: const EdgeInsets.only(left: 24, right: 24, top: 12),
            child: _GlassContainer(
              padding: const EdgeInsets.all(16),
              child: Column(
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      const Text("Number of people", style: TextStyle(color: Colors.white, fontSize: 14)),
                      Row(
                        children: [
                          _buildCircleBtn(Icons.remove, _decrementSplit),
                          const SizedBox(width: 12),
                          Text(
                            "$_splitCount",
                            style: const TextStyle(color: Colors.white, fontSize: 20, fontWeight: FontWeight.bold),
                          ),
                          const SizedBox(width: 12),
                          _buildCircleBtn(Icons.add, _incrementSplit),
                        ],
                      ),
                    ],
                  ),
                  const SizedBox(height: 12),
                  // Calculate split amount
                  Builder(
                    builder: (context) {
                      double amount = double.tryParse(_amountController.text) ?? 0;
                      double perPerson = _splitCount > 0 ? amount / _splitCount : 0;
                      return Row(
                        children: [
                           const Spacer(),
                           Text(
                             "You pay: ₹${perPerson.toStringAsFixed(0)} each",
                             style: const TextStyle(color: Color(0xFF10B981), fontSize: 13, fontWeight: FontWeight.w600),
                           ),
                        ],
                      );
                    }
                  ),
                ],
              ),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildCircleBtn(IconData icon, VoidCallback onTap) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: 32, height: 32,
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          color: Colors.white.withOpacity(0.1),
        ),
        child: Icon(icon, color: Colors.white, size: 16),
      ),
    );
  }

  Widget _buildBottomButtons() {
    return Container(
      padding: const EdgeInsets.fromLTRB(24, 16, 24, 40),
      decoration: BoxDecoration(
        color: const Color(0xFF1E293B).withOpacity(0.95),
        border: Border(top: BorderSide(color: Colors.white.withOpacity(0.05))),
      ),
      child: ClipRRect(
        child: BackdropFilter(
          filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
          child: Row(
            children: [
              // Cancel Button
              Expanded(
                flex: 4,
                child: GestureDetector(
                  onTap: () => Navigator.of(context).pop(),
                  child: Container(
                    height: 56,
                    decoration: BoxDecoration(
                      color: Colors.white.withOpacity(0.08),
                      borderRadius: BorderRadius.circular(16),
                      border: Border.all(color: Colors.white.withOpacity(0.1)),
                    ),
                    alignment: Alignment.center,
                    child: const Text("Cancel", style: TextStyle(color: Colors.white, fontSize: 16)),
                  ),
                ),
              ),
              const SizedBox(width: 12),
              // Save Button
              Expanded(
                flex: 6,
                child: GestureDetector(
                  onTap: () {
                    if (_amountController.text.isNotEmpty) {
                      // TODO: Save logic
                      Navigator.of(context).pop();
                    }
                  },
                  child: Container(
                    height: 56,
                    decoration: BoxDecoration(
                      gradient: const LinearGradient(colors: [Color(0xFF06B6D4), Color(0xFF8B5CF6)]),
                      borderRadius: BorderRadius.circular(16),
                      boxShadow: [
                        BoxShadow(
                          color: const Color(0xFF8B5CF6).withOpacity(0.4),
                          offset: const Offset(0, 8),
                          blurRadius: 24,
                        ),
                      ],
                    ),
                    alignment: Alignment.center,
                    child: const Text(
                      "Add Expense",
                      style: TextStyle(color: Colors.white, fontSize: 16, fontWeight: FontWeight.bold),
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

class _GlassContainer extends StatelessWidget {
  final Widget child;
  final EdgeInsetsGeometry? padding;
  final double? height;

  const _GlassContainer({required this.child, this.padding, this.height});

  @override
  Widget build(BuildContext context) {
    return Container(
      height: height,
      padding: padding,
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.08),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.white.withOpacity(0.1)),
      ),
      child: child,
    );
  }
}

class _MeshOrb extends StatelessWidget {
  final Color color;
  final double size;

  const _MeshOrb({required this.color, required this.size});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: size,
      height: size,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        color: color.withOpacity(0.05),
        boxShadow: [
          BoxShadow(
            color: color.withOpacity(0.05),
            blurRadius: 100,
            spreadRadius: 50,
          ),
        ],
      ),
    );
  }
}

class _GridPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = Colors.white.withOpacity(0.02)
      ..strokeWidth = 1;

    const double spacing = 40;

    for (double i = 0; i < size.width; i += spacing) {
      canvas.drawLine(Offset(i, 0), Offset(i, size.height), paint);
    }
    for (double i = 0; i < size.height; i += spacing) {
      canvas.drawLine(Offset(0, i), Offset(size.width, i), paint);
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}
