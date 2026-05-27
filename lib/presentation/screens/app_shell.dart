import 'package:flutter/material.dart';
import '../../core/app_colors.dart';
import '../../core/app_theme.dart';
import 'dashboard_screen.dart';
import 'ledger_screen.dart';
import 'insights_screen.dart';
import 'budget_screen.dart';
import 'add_expense_screen.dart';
import 'voice_fill_screen.dart';

class AppShell extends StatefulWidget {
  const AppShell({super.key});

  @override
  State<AppShell> createState() => _AppShellState();
}

class _AppShellState extends State<AppShell> with SingleTickerProviderStateMixin {
  int _selectedIndex = 0;
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
    _micGlowAnim = Tween<double>(begin: 0.25, end: 0.55).animate(
      CurvedAnimation(parent: _micPulseController, curve: Curves.easeInOut),
    );
  }

  @override
  void dispose() {
    _micPulseController.dispose();
    super.dispose();
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
    return Container(
      decoration: AppTheme.backgroundGradient,
      child: Scaffold(
        backgroundColor: Colors.transparent,
        body: AnimatedSwitcher(
          duration: const Duration(milliseconds: 280),
          switchInCurve: Curves.easeOut,
          switchOutCurve: Curves.easeIn,
          child: KeyedSubtree(
            key: ValueKey(_selectedIndex),
            child: _screens[_selectedIndex],
          ),
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
              const SizedBox(width: 42),
              // Mic voice-fill button (left of center)
              _micButton(),
              _navItem(icon: Icons.insights_rounded, label: 'INSIGHTS', index: 2),
              _navItem(icon: Icons.pie_chart_outline_rounded, label: 'BUDGET', index: 3),
            ],
          ),
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

  Widget _micButton() {
    return InkWell(
      borderRadius: BorderRadius.circular(14),
      onTap: _openVoiceFill,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            AnimatedBuilder(
              animation: _micGlowAnim,
              builder: (_, child) => Container(
                padding: const EdgeInsets.all(4),
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: AppColors.primary.withValues(alpha: 0.15),
                  boxShadow: [
                    BoxShadow(
                      color: AppColors.primary.withValues(alpha: _micGlowAnim.value),
                      blurRadius: 10,
                      spreadRadius: 1,
                    ),
                  ],
                ),
                child: child,
              ),
              child: const Icon(
                Icons.mic_rounded,
                color: AppColors.primary,
                size: 20,
              ),
            ),
            const SizedBox(height: 3),
            Text(
              'VOICE',
              style: TextStyle(
                fontSize: 10,
                fontWeight: FontWeight.w600,
                color: AppColors.primary.withValues(alpha: 0.9),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

