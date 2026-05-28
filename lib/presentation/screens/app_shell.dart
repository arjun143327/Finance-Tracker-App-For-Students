import 'package:flutter/material.dart';
import '../../core/app_colors.dart';
import '../../core/app_theme.dart';
import 'dashboard_screen.dart';
import 'ledger_screen.dart';
import 'insights_screen.dart';
import 'budget_screen.dart';
import 'add_expense_screen.dart';
import 'voice_fill_screen.dart';
import '../../services/notification_service.dart';
import '../../services/sms_parser_service.dart';
import '../../data/models/transaction_model.dart';

class AppShell extends StatefulWidget {
  const AppShell({super.key});

  @override
  State<AppShell> createState() => _AppShellState();
}

class _AppShellState extends State<AppShell> with SingleTickerProviderStateMixin {
  int _selectedIndex = 0;

  // Draggable mic FAB position — starts at bottom-right above nav bar
  Offset _micPosition = const Offset(double.infinity, double.infinity);
  bool _micPositionInitialized = false;

  // Breathing glow animation for the mic FAB
  late AnimationController _micPulseController;
  late Animation<double> _micGlowAnim;

  final List<Widget> _screens = const [
    DashboardScreen(),
    LedgerScreen(),
    InsightsScreen(),
    BudgetScreen(),
  ];

  @override
  void initState() {
    super.initState();
    _micPulseController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1800),
    )..repeat(reverse: true);
    _micGlowAnim = Tween<double>(begin: 0.22, end: 0.55).animate(
      CurvedAnimation(parent: _micPulseController, curve: Curves.easeInOut),
    );

    // Setup deep-link listener for SMS notifications
    NotificationService.instance.onNotificationTapped = _onSmsNotificationTapped;
  }

  void _onSmsNotificationTapped(SmsParsedTransaction tx) {
    if (!mounted) return;
    
    // Convert parsed SMS into a TransactionModel
    final prefilled = TransactionModel(
      title: tx.merchant ?? '',
      category: 'Other', // Auto-categorization could be expanded here
      amount: tx.amount,
      date: DateTime.now(),
      method: tx.paymentMethod ?? 'Cash',
      type: TransactionType.expense,
    );

    Navigator.of(context).push(
      PageRouteBuilder(
        transitionDuration: const Duration(milliseconds: 280),
        pageBuilder: (_, animation, __) => FadeTransition(
          opacity: animation,
          child: AddExpenseScreen(initialTransaction: prefilled),
        ),
      ),
    );
  }

  @override
  void dispose() {
    NotificationService.instance.onNotificationTapped = null;
    _micPulseController.dispose();
    super.dispose();
  }

  void _initMicPosition(BuildContext context) {
    if (_micPositionInitialized) return;
    final size = MediaQuery.of(context).size;
    // Default: bottom-right corner, above bottom nav bar
    setState(() {
      _micPosition = Offset(size.width - 80, size.height - 180);
      _micPositionInitialized = true;
    });
  }

  Future<void> _openAddExpense() async {
    await Navigator.of(context).push(
      PageRouteBuilder(
        transitionDuration: const Duration(milliseconds: 280),
        pageBuilder: (_, animation, __) => FadeTransition(
          opacity: animation,
          child: const AddExpenseScreen(),
        ),
      ),
    );
  }

  Future<void> _openVoiceFill() async {
    await Navigator.of(context).push(
      PageRouteBuilder(
        transitionDuration: const Duration(milliseconds: 280),
        pageBuilder: (_, animation, __) => FadeTransition(
          opacity: animation,
          child: const VoiceFillScreen(),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    _initMicPosition(context);
    final size = MediaQuery.of(context).size;

    return Container(
      decoration: AppTheme.backgroundGradient,
      child: Scaffold(
        backgroundColor: Colors.transparent,
        body: Stack(
          children: [
            // ── Main content ──────────────────────────────────────────────
            AnimatedSwitcher(
              duration: const Duration(milliseconds: 280),
              switchInCurve: Curves.easeOut,
              switchOutCurve: Curves.easeIn,
              child: KeyedSubtree(
                key: ValueKey(_selectedIndex),
                child: _screens[_selectedIndex],
              ),
            ),

            // ── Draggable mic FAB ─────────────────────────────────────────
            if (_micPositionInitialized)
              Positioned(
                left: _micPosition.dx.clamp(0, size.width - 60),
                top: _micPosition.dy.clamp(0, size.height - 120),
                child: Draggable(
                  feedback: _buildMicFab(isDragging: true),
                  childWhenDragging: const SizedBox.shrink(),
                  onDragEnd: (details) {
                    setState(() {
                      // Clamp so it never goes off-screen
                      _micPosition = Offset(
                        details.offset.dx.clamp(0, size.width - 60),
                        details.offset.dy.clamp(0, size.height - 120),
                      );
                    });
                  },
                  child: _buildMicFab(isDragging: false),
                ),
              ),
          ],
        ),
        floatingActionButtonLocation: FloatingActionButtonLocation.centerDocked,
        floatingActionButton: Container(
          margin: const EdgeInsets.only(top: 20),
          child: FloatingActionButton(
            onPressed: _openAddExpense,
            backgroundColor: AppColors.primary,
            foregroundColor: AppColors.bgGradientStart,
            shape: const CircleBorder(),
            elevation: 4,
            child: const Icon(Icons.add, size: 32),
          ),
        ),
        bottomNavigationBar: Container(
          margin: const EdgeInsets.fromLTRB(10, 0, 10, 10),
          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 10),
          decoration: BoxDecoration(
            color: Colors.black.withValues(alpha: 0.22),
            borderRadius: BorderRadius.circular(22),
            border: Border.all(color: Colors.white.withValues(alpha: 0.08)),
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: [
              _navItem(icon: Icons.dashboard_outlined, label: 'HOME', index: 0),
              _navItem(icon: Icons.list_alt_rounded, label: 'TRANSACTIONS', index: 1),
              const SizedBox(width: 42), // gap for the + FAB
              _navItem(icon: Icons.insights_rounded, label: 'INSIGHTS', index: 2),
              _navItem(icon: Icons.pie_chart_outline_rounded, label: 'BUDGET', index: 3),
            ],
          ),
        ),
      ),
    );
  }

  // ── Draggable mic FAB widget ─────────────────────────────────────────────
  Widget _buildMicFab({required bool isDragging}) {
    return GestureDetector(
      onTap: isDragging ? null : _openVoiceFill,
      child: AnimatedBuilder(
        animation: _micGlowAnim,
        builder: (_, child) => Container(
          width: 54,
          height: 54,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            gradient: const RadialGradient(
              colors: [AppColors.primaryLight, AppColors.primary],
            ),
            boxShadow: [
              BoxShadow(
                color: AppColors.primary.withValues(
                    alpha: isDragging ? 0.7 : _micGlowAnim.value),
                blurRadius: isDragging ? 28 : 18,
                spreadRadius: isDragging ? 4 : 2,
              ),
            ],
          ),
          child: child,
        ),
        child: const Icon(
          Icons.mic_rounded,
          color: AppColors.bgGradientStart,
          size: 26,
        ),
      ),
    );
  }

  Widget _navItem({required IconData icon, required String label, required int index}) {
    final selected = _selectedIndex == index;
    final color = selected ? AppColors.primary : Colors.white.withValues(alpha: 0.65);
    return InkWell(
      borderRadius: BorderRadius.circular(14),
      onTap: () => setState(() => _selectedIndex = index),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 180),
        curve: Curves.easeOut,
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
        decoration: BoxDecoration(
          color: selected ? AppColors.primary.withValues(alpha: 0.14) : Colors.transparent,
          borderRadius: BorderRadius.circular(14),
          border: Border.all(
            color: selected ? AppColors.primary.withValues(alpha: 0.4) : Colors.transparent,
          ),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(icon, color: color, size: 20),
            const SizedBox(height: 3),
            Text(
              label,
              style: TextStyle(
                fontSize: 10,
                fontWeight: selected ? FontWeight.w700 : FontWeight.w500,
                color: color,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
