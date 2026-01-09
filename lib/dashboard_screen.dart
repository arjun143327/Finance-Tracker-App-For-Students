import 'dart:ui';
import 'dart:math' as math;
import 'package:flutter/material.dart';
import 'add_expense_screen.dart';

class DashboardScreen extends StatefulWidget {
  const DashboardScreen({super.key});

  @override
  State<DashboardScreen> createState() => _DashboardScreenState();
}

class _DashboardScreenState extends State<DashboardScreen> with TickerProviderStateMixin {
  // Animation Controllers
  late AnimationController _entranceController;
  late AnimationController _bgController;
  
  // Staggered Animations
  late Animation<double> _fadeHeader;
  late Animation<Offset> _slideBudget;
  late Animation<double> _fadeBudget;
  late Animation<Offset> _slideActions;
  late Animation<double> _fadeActions;
  late Animation<double> _fadeCategories;
  late Animation<double> _fadeGoals;
  late Animation<double> _fadeTransactions;
  late Animation<Offset> _slideBottomNav;

  @override
  void initState() {
    super.initState();

    // 1. Entrance Controller
    _entranceController = AnimationController(
      duration: const Duration(milliseconds: 1500),
      vsync: this,
    );

    // Staggered definitions
    _fadeHeader = CurvedAnimation(
      parent: _entranceController,
      curve: const Interval(0.0, 0.3, curve: Curves.easeIn),
    );

    _slideBudget = Tween<Offset>(begin: const Offset(0, 0.2), end: Offset.zero).animate(
      CurvedAnimation(
        parent: _entranceController,
        curve: const Interval(0.1, 0.5, curve: Curves.easeOutCubic),
      ),
    );
    _fadeBudget = CurvedAnimation(
      parent: _entranceController,
      curve: const Interval(0.1, 0.5, curve: Curves.easeIn),
    );

    _slideActions = Tween<Offset>(begin: const Offset(0.2, 0.0), end: Offset.zero).animate(
      CurvedAnimation(
        parent: _entranceController,
        curve: const Interval(0.3, 0.7, curve: Curves.easeOutCubic),
      ),
    );
    _fadeActions = CurvedAnimation(
      parent: _entranceController,
      curve: const Interval(0.3, 0.6, curve: Curves.easeIn),
    );

    _fadeCategories = CurvedAnimation(
      parent: _entranceController,
      curve: const Interval(0.4, 0.8, curve: Curves.easeIn),
    );

    _fadeGoals = CurvedAnimation(
      parent: _entranceController,
      curve: const Interval(0.5, 0.9, curve: Curves.easeIn),
    );

    _fadeTransactions = CurvedAnimation(
      parent: _entranceController,
      curve: const Interval(0.6, 1.0, curve: Curves.easeIn),
    );

    _slideBottomNav = Tween<Offset>(begin: const Offset(0, 1.0), end: Offset.zero).animate(
      CurvedAnimation(
        parent: _entranceController,
        curve: const Interval(0.7, 1.0, curve: Curves.easeOut),
      ),
    );

    // 2. Background Controller
    _bgController = AnimationController(duration: const Duration(seconds: 10), vsync: this)..repeat(reverse: true);

    _entranceController.forward();
  }

  @override
  void dispose() {
    _entranceController.dispose();
    _bgController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      extendBody: true, // For transparent bottom nav
      body: Stack(
        children: [
           // 1. Background (Gradient + Mesh)
          _buildBackground(),

          // 2. Main Content
          SafeArea(
            bottom: false,
            child: SingleChildScrollView(
              padding: const EdgeInsets.only(bottom: 100), // Space for bottom nav
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _buildAppBar(),
                  const SizedBox(height: 16),
                  _buildBudgetCard(),
                  const SizedBox(height: 24),
                  _buildQuickActions(),
                  const SizedBox(height: 24),
                  _buildSpendingCategories(),
                  const SizedBox(height: 24),
                  _buildSavingsGoals(),
                  const SizedBox(height: 24),
                  _buildRecentTransactions(),
                ],
              ),
            ),
          ),

          // 3. Bottom Navigation
          Positioned(
            left: 0,
            right: 0,
            bottom: 0,
            child: SlideTransition(
              position: _slideBottomNav,
              child: _buildBottomNav(),
            ),
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
            double offset = math.sin(_bgController.value * math.pi) * 30;
            return Stack(
              children: [
                Positioned(top: -100, left: -50 + offset, child: _MeshOrb(color: const Color(0xFF06B6D4), size: 200)),
                Positioned(top: 100, right: -50 - offset, child: _MeshOrb(color: const Color(0xFF8B5CF6), size: 250)),
                Positioned(bottom: -50 - offset, left: 50 + offset, child: _MeshOrb(color: const Color(0xFF06B6D4), size: 300)),
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

  Widget _buildAppBar() {
    return FadeTransition(
      opacity: _fadeHeader,
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 24.0, vertical: 10),
        child: Row(
          children: [
            // Avatar
            Container(
              width: 40,
              height: 40,
              decoration: const BoxDecoration(
                shape: BoxShape.circle,
                gradient: LinearGradient(colors: [Color(0xFF06B6D4), Color(0xFF8B5CF6)]),
              ),
              child: const Center(
                child: Text(
                  "R",
                  style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
                ),
              ),
            ),
            const SizedBox(width: 12),
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: const [
                Text("Hi, Rahul", style: TextStyle(color: Colors.white, fontSize: 20, fontWeight: FontWeight.bold)),
                Text("January 2026", style: TextStyle(color: Color(0xFF94A3B8), fontSize: 13)),
              ],
            ),
            const Spacer(),
            Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: Colors.white.withOpacity(0.05),
                shape: BoxShape.circle,
              ),
              child: const Icon(Icons.notifications_outlined, color: Colors.white, size: 24),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildBudgetCard() {
    return FadeTransition(
      opacity: _fadeBudget,
      child: SlideTransition(
        position: _slideBudget,
        child: Container(
          margin: const EdgeInsets.symmetric(horizontal: 24),
          padding: const EdgeInsets.all(24),
          decoration: _glassDecoration(borderRadius: 24),
          child: Column(
            children: [
              Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text("Monthly Budget", style: TextStyle(color: Color(0xFF94A3B8), fontSize: 14)),
                        const SizedBox(height: 8),
                        const Text("₹3,500 left", style: TextStyle(color: Colors.white, fontSize: 36, fontWeight: FontWeight.bold)),
                        const Text("of ₹6,000", style: TextStyle(color: Color(0xFF94A3B8), fontSize: 14)),
                      ],
                    ),
                  ),
                  SizedBox(
                    width: 60,
                    height: 60,
                    child: CustomPaint(
                      painter: _ProgressRingPainter(color: const Color(0xFF06B6D4), percent: 0.58),
                      child: const Center(
                        child: Text("58%", style: TextStyle(color: Colors.white, fontSize: 12, fontWeight: FontWeight.bold)),
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 24),
              Row(
                children: [
                  _buildBudgetBadge(Icons.calendar_today, "17 days left in month", const Color(0xFF64748B)),
                  const Spacer(),
                  _buildBudgetBadge(Icons.lightbulb_outline, "Spend max ₹205/day", const Color(0xFF10B981)),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildBudgetBadge(IconData icon, String text, Color color) {
    return Row(
      children: [
        Icon(icon, color: color, size: 14),
        const SizedBox(width: 4),
        Text(text, style: TextStyle(color: color, fontSize: 12)),
      ],
    );
  }

  Widget _buildQuickActions() {
    return FadeTransition(
      opacity: _fadeActions,
      child: SlideTransition(
        position: _slideActions,
        child: SingleChildScrollView(
          scrollDirection: Axis.horizontal,
          padding: const EdgeInsets.symmetric(horizontal: 24),
          child: Row(
            children: [
              _buildActionButton(Icons.remove, "Expense", const Color(0xFFEF4444)),
              const SizedBox(width: 12),
              _buildActionButton(Icons.add, "Income", const Color(0xFF10B981)),
              const SizedBox(width: 12),
              _buildActionButton(Icons.call_split, "Split Bill", const Color(0xFF8B5CF6)),
              const SizedBox(width: 12),
              _buildActionButton(Icons.flag, "Goals", const Color(0xFF06B6D4)),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildActionButton(IconData icon, String label, Color color) {
    return GestureDetector(
      onTap: () {
        if (label == "Expense") {
          Navigator.of(context).push(
            MaterialPageRoute(
               builder: (context) => const AddExpenseScreen(),
               fullscreenDialog: true,
            ),
          );
        }
      },
      child: Container(
        width: 100,
        height: 100,
        decoration: _glassDecoration(borderRadius: 16),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              width: 40,
              height: 40,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                gradient: LinearGradient(
                  colors: [color.withOpacity(0.8), color],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
              ),
              child: Icon(icon, color: Colors.white, size: 20),
            ),
            const SizedBox(height: 12),
            Text(label, style: const TextStyle(color: Colors.white, fontSize: 13)),
          ],
        ),
      ),
    );
  }

  Widget _buildSpendingCategories() {
    return FadeTransition(
      opacity: _fadeCategories,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 24),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: const [
                Text("Where Your Money Went", style: TextStyle(color: Colors.white, fontSize: 18, fontWeight: FontWeight.bold)),
                Text("Top categories this month", style: TextStyle(color: Color(0xFF94A3B8), fontSize: 13)),
              ],
            ),
          ),
          const SizedBox(height: 16),
          SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            padding: const EdgeInsets.symmetric(horizontal: 24),
            child: Row(
              children: [
                _buildCategoryCard("🍕", "Food & Dining", "₹1,400", "of ₹1,600", 0.87, const Color(0xFFF59E0B), "13% left"),
                const SizedBox(width: 12),
                _buildCategoryCard("🚌", "Transport", "₹350", "of ₹600", 0.58, const Color(0xFF06B6D4), "42% left"),
                const SizedBox(width: 12),
                _buildCategoryCard("🎬", "Entertainment", "₹750", "of ₹800", 0.94, const Color(0xFFEF4444), "6% left"),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildCategoryCard(String emoji, String title, String amount, String sub, double progress, Color color, String status) {
    return Container(
      width: 140,
      height: 140,
      padding: const EdgeInsets.all(16),
      decoration: _glassDecoration(borderRadius: 20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(emoji, style: const TextStyle(fontSize: 24)),
          const Spacer(),
          Text(title, style: const TextStyle(color: Colors.white, fontSize: 12), maxLines: 1, overflow: TextOverflow.ellipsis),
          const SizedBox(height: 4),
          RichText(
            text: TextSpan(
              children: [
                TextSpan(text: "$amount ", style: const TextStyle(color: Colors.white, fontSize: 16, fontWeight: FontWeight.bold)),
                TextSpan(text: sub, style: const TextStyle(color: Color(0xFF64748B), fontSize: 10)),
              ],
            ),
          ),
          const SizedBox(height: 8),
          LinearProgressIndicator(value: progress, backgroundColor: Colors.white.withOpacity(0.1), color: color, minHeight: 4),
          const SizedBox(height: 4),
          Text(status, style: TextStyle(color: color, fontSize: 11)),
        ],
      ),
    );
  }

  Widget _buildSavingsGoals() {
    return FadeTransition(
      opacity: _fadeGoals,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 24),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: const [
                Text("Your Goals 🎯", style: TextStyle(color: Colors.white, fontSize: 18, fontWeight: FontWeight.bold)),
                Text("Keep going!", style: TextStyle(color: Color(0xFF94A3B8), fontSize: 13)),
              ],
            ),
          ),
          const SizedBox(height: 16),
          _buildGoalItem(Icons.phone_iphone, "New Phone", "₹11,500", "of ₹20,000", 0.57, "2 months"),
          const SizedBox(height: 12),
          _buildGoalItem(Icons.airplanemode_active, "Goa Trip", "₹3,000", "of ₹12,000", 0.25, "5 months"),
        ],
      ),
    );
  }

  Widget _buildGoalItem(IconData icon, String title, String current, String total, double progress, String timeLeft) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 24),
      padding: const EdgeInsets.all(16),
      decoration: _glassDecoration(borderRadius: 16),
      child: Row(
        children: [
          Container(
            width: 50,
            height: 50,
            decoration: const BoxDecoration(
              shape: BoxShape.circle,
              gradient: LinearGradient(colors: [Color(0xFF0F172A), Color(0xFF334155)]),
            ),
            child: Icon(icon, color: Colors.white, size: 24),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Text(title, style: const TextStyle(color: Colors.white, fontSize: 16, fontWeight: FontWeight.w600)),
                    const Spacer(),
                    Icon(Icons.access_time, size: 12, color: const Color(0xFF10B981)),
                    const SizedBox(width: 4),
                    Text(timeLeft, style: const TextStyle(color: Color(0xFF10B981), fontSize: 12)),
                  ],
                ),
                const SizedBox(height: 4),
                RichText(
                  text: TextSpan(
                    children: [
                      TextSpan(text: current, style: const TextStyle(color: Color(0xFF94A3B8), fontSize: 13)),
                      TextSpan(text: " $total", style: const TextStyle(color: Color(0xFF64748B), fontSize: 12)),
                    ],
                  ),
                ),
                const SizedBox(height: 8),
                ClipRRect(
                  borderRadius: BorderRadius.circular(4),
                  child: LinearProgressIndicator(
                    value: progress,
                    backgroundColor: Colors.white.withOpacity(0.1),
                    color: const Color(0xFF8B5CF6), // Simple color for now or could use gradient manually
                    minHeight: 8,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildRecentTransactions() {
    return FadeTransition(
      opacity: _fadeTransactions,
      child: Column(
        children: [
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 24),
            child: Row(
              children: const [
                Text("Recent Activity", style: TextStyle(color: Colors.white, fontSize: 18, fontWeight: FontWeight.bold)),
                Spacer(),
                Text("See All", style: TextStyle(color: Color(0xFF06B6D4), fontSize: 14)),
              ],
            ),
          ),
          const SizedBox(height: 16),
          _buildTransactionItem("🍔", Colors.orange, "Canteen - Lunch", "Today, 1:30 PM", "-₹80", const Color(0xFFEF4444)),
          const SizedBox(height: 12),
          _buildTransactionItem("💰", Colors.green, "Monthly Allowance", "Jan 1, 2026", "+₹6,000", const Color(0xFF10B981)),
          const SizedBox(height: 12),
          _buildTransactionItem("☕", Colors.brown, "Coffee - Split", "Yesterday, 4:15 PM", "-₹120", const Color(0xFFEF4444), isSplit: true),
           const SizedBox(height: 12),
          _buildTransactionItem("📚", Colors.blue, "Textbook", "Jan 6", "-₹450", const Color(0xFFEF4444)),
        ],
      ),
    );
  }

  Widget _buildTransactionItem(String icon, Color bg, String title, String time, String amount, Color amountColor, {bool isSplit = false}) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 24),
      padding: const EdgeInsets.all(16),
      decoration: _glassDecoration(borderRadius: 16),
      child: Row(
        children: [
          Container(
            width: 40,
            height: 40,
            decoration: BoxDecoration(
              color: bg.withOpacity(0.2),
              shape: BoxShape.circle,
            ),
            alignment: Alignment.center,
            child: Text(icon, style: const TextStyle(fontSize: 20)),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(title, style: const TextStyle(color: Colors.white, fontSize: 15)),
                const SizedBox(height: 4),
                Text(time, style: const TextStyle(color: Color(0xFF64748B), fontSize: 12)),
              ],
            ),
          ),
          Column(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Text(amount, style: TextStyle(color: amountColor, fontSize: 16, fontWeight: FontWeight.bold)),
              if (isSplit)
                 Padding(
                   padding: const EdgeInsets.only(top: 2.0),
                   child: Container(
                     padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                     decoration: BoxDecoration(color: Colors.white.withOpacity(0.1), borderRadius: BorderRadius.circular(4)),
                     child: const Text("÷3", style: TextStyle(color: Colors.white70, fontSize: 10)),
                   ),
                 ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildBottomNav() {
    return Container(
      height: 70,
      decoration: BoxDecoration(
        color: const Color(0xFF1E293B).withOpacity(0.95),
        border: Border(top: BorderSide(color: Colors.white.withOpacity(0.05))),
      ),
      child: ClipRRect(
        child: BackdropFilter(
          filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: [
              _buildNavItem(Icons.home, true),
              _buildNavItem(Icons.pie_chart_outline, false),
              Container(
                width: 48,
                height: 48,
                decoration: const BoxDecoration(
                  shape: BoxShape.circle,
                  gradient: LinearGradient(colors: [Color(0xFF06B6D4), Color(0xFF8B5CF6)]),
                  boxShadow: [BoxShadow(color: Color(0xFF06B6D4), blurRadius: 10, offset: Offset(0, 4))],
                ),
                child: const Icon(Icons.add, color: Colors.white),
              ),
              _buildNavItem(Icons.flag_outlined, false),
              _buildNavItem(Icons.person_outline, false),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildNavItem(IconData icon, bool isActive) {
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Icon(icon, color: isActive ? const Color(0xFF06B6D4) : const Color(0xFF64748B), size: 24),
        if (isActive)
          Container(
            margin: const EdgeInsets.only(top: 4),
            width: 4,
            height: 4,
            decoration: const BoxDecoration(color: Color(0xFF06B6D4), shape: BoxShape.circle),
          )
      ],
    );
  }

  BoxDecoration _glassDecoration({required double borderRadius}) {
    return BoxDecoration(
      color: Colors.white.withOpacity(0.08),
      borderRadius: BorderRadius.circular(borderRadius),
      border: Border.all(color: Colors.white.withOpacity(0.1)),
      boxShadow: [
        BoxShadow(
          color: const Color(0xFF06B6D4).withOpacity(0.1),
          blurRadius: 32,
          offset: const Offset(0, 8),
        ),
      ],
    );
  }
}

class _ProgressRingPainter extends CustomPainter {
  final Color color;
  final double percent;

  _ProgressRingPainter({required this.color, required this.percent});

  @override
  void paint(Canvas canvas, Size size) {
    final center = Offset(size.width / 2, size.height / 2);
    final radius = size.width / 2;
    final strokeWidth = 6.0;

    final bgPaint = Paint()
      ..color = Colors.white.withOpacity(0.1)
      ..style = PaintingStyle.stroke
      ..strokeWidth = strokeWidth
      ..strokeCap = StrokeCap.round;

    final fgPaint = Paint()
      ..shader = LinearGradient(colors: [color, const Color(0xFF8B5CF6)]).createShader(Rect.fromCircle(center: center, radius: radius))
      ..style = PaintingStyle.stroke
      ..strokeWidth = strokeWidth
      ..strokeCap = StrokeCap.round;

    canvas.drawCircle(center, radius, bgPaint);
    canvas.drawArc(
      Rect.fromCircle(center: center, radius: radius),
      -math.pi / 2,
      2 * math.pi * percent,
      false,
      fgPaint,
    );
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
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
