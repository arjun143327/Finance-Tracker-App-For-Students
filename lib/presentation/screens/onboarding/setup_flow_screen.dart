import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../../core/app_colors.dart';
import '../../../core/app_theme.dart';
import '../../../data/models/user_profile_model.dart';
import '../../../data/providers/user_provider.dart';
import '../app_shell.dart';
import '../../widgets/glass_card.dart';

class SetupFlowScreen extends ConsumerStatefulWidget {
  const SetupFlowScreen({super.key});

  @override
  ConsumerState<SetupFlowScreen> createState() => _SetupFlowScreenState();
}

class _SetupFlowScreenState extends ConsumerState<SetupFlowScreen> {
  final PageController _pageController = PageController();
  int _currentIndex = 0;

  String _name = '';
  double _balance = 0;
  double _income = 0;
  String _goal = '';
  String _selectedCurrency = '₹';

  final _nameController = TextEditingController();
  final _balanceController = TextEditingController();
  final _incomeController = TextEditingController();

  void _nextPage() {
    // Pages: 0=name, 1=balance, 2=income, 3=goal, 4=notifications
    if (_currentIndex < 4) {
      if (_currentIndex == 0 && _nameController.text.trim().isEmpty) return;
      if (_currentIndex == 1 && _balanceController.text.trim().isEmpty) return;
      if (_currentIndex == 2 && _incomeController.text.trim().isEmpty) return;
      if (_currentIndex == 3 && _goal.isEmpty) return;

      if (_currentIndex == 0) _name = _nameController.text.trim();
      if (_currentIndex == 1) _balance = double.tryParse(_balanceController.text) ?? 0;
      if (_currentIndex == 2) _income = double.tryParse(_incomeController.text) ?? 0;

      _pageController.nextPage(
        duration: const Duration(milliseconds: 500),
        curve: Curves.easeInOut,
      );
    } else {
      _finishSetup();
    }
  }

  Future<void> _finishSetup() async {
    final profile = UserProfileModel(
      name: _name,
      balance: _balance,
      income: _income,
      budget: 0.0, // Budget setup deferred to Phase 3 (Settings screen)
      goal: _goal,
      onboardingComplete: true,
    );

    await ref.read(userProfileProvider.notifier).saveProfile(profile);

    if (mounted) {
      Navigator.of(context).pushReplacement(
        PageRouteBuilder(
          transitionDuration: const Duration(milliseconds: 600),
          pageBuilder: (_, animation, __) => FadeTransition(
            opacity: animation,
            child: const AppShell(),
          ),
        ),
      );
    }
  }

  @override
  void dispose() {
    _pageController.dispose();
    _nameController.dispose();
    _balanceController.dispose();
    _incomeController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: AppTheme.backgroundGradient,
      child: Scaffold(
        backgroundColor: Colors.transparent,
        appBar: AppBar(
          backgroundColor: Colors.transparent,
          elevation: 0,
          leading: _currentIndex > 0
              ? IconButton(
                  icon: const Icon(Icons.arrow_back_ios_new_rounded, color: AppColors.textSecondary),
                  onPressed: () {
                    _pageController.previousPage(
                      duration: const Duration(milliseconds: 400),
                      curve: Curves.easeInOut,
                    );
                  },
                )
              : null,
        ),
        body: PageView(
          controller: _pageController,
          physics: const NeverScrollableScrollPhysics(),
          onPageChanged: (index) => setState(() => _currentIndex = index),
          children: [
            _buildInputScreen(
              title: "What's your name?",
              subtitle: "Let's make this personal.",
              controller: _nameController,
              inputType: TextInputType.name,
              hint: "e.g. Alex",
            ),
            _buildInputScreen(
              title: "Let\u2019s begin with your\ncurrent balance",
              subtitle: "$_name, this helps Budgetrix understand your starting point.",
              controller: _balanceController,
              inputType: TextInputType.number,
              hint: "0.00",
              isBalance: true,
            ),
            _buildInputScreen(
              title: "What\u2019s your monthly\nincome?",
              subtitle: "Your average take-home per month.",
              controller: _incomeController,
              inputType: TextInputType.number,
              hint: "0.00",
              isBalance: true,
            ),
            _buildGoalScreen(),
            _buildNotificationScreen(),
          ],
        ),
      ),
    );
  }

  Widget _buildInputScreen({
    required String title,
    required String subtitle,
    required TextEditingController controller,
    required TextInputType inputType,
    required String hint,
    bool isBalance = false,
  }) {
    return LayoutBuilder(
      builder: (context, constraints) {
        return SingleChildScrollView(
          child: ConstrainedBox(
            constraints: BoxConstraints(minHeight: constraints.maxHeight),
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 32.0, vertical: 40.0),
              child: IntrinsicHeight(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    RichText(
                      text: TextSpan(
                        children: [
                          TextSpan(
                            text: title.split('\n')[0] + '\n',
                            style: GoogleFonts.cormorantGaramond(
                              color: Colors.white,
                              fontSize: 34,
                              fontWeight: FontWeight.w300,
                              letterSpacing: -0.5,
                            ),
                          ),
                          TextSpan(
                            text: title.split('\n').length > 1 ? title.split('\n')[1] : '',
                            style: GoogleFonts.cormorantGaramond(
                              color: AppColors.primaryLight,
                              fontSize: 34,
                              fontWeight: FontWeight.w400,
                              fontStyle: FontStyle.italic,
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 12),
                    Text(
                      subtitle,
                      style: GoogleFonts.dmSans(
                        color: AppColors.textSecondary,
                        fontSize: 14,
                        fontWeight: FontWeight.w300,
                      ),
                    ),
                    const SizedBox(height: 60),
                    if (isBalance) ...[
                      Row(
                        crossAxisAlignment: CrossAxisAlignment.baseline,
                        textBaseline: TextBaseline.alphabetic,
                        children: [
                          Text(
                            _selectedCurrency,
                            style: GoogleFonts.cormorantGaramond(
                              color: AppColors.primary,
                              fontSize: 42,
                              fontWeight: FontWeight.w300,
                            ),
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: TextField(
                              controller: controller,
                              keyboardType: inputType,
                              autofocus: true,
                              style: GoogleFonts.cormorantGaramond(
                                fontSize: 48,
                                color: AppColors.textPrimary,
                                fontWeight: FontWeight.w300,
                              ),
                              decoration: InputDecoration(
                                hintText: hint,
                                hintStyle: GoogleFonts.cormorantGaramond(
                                  color: AppColors.textSecondary.withOpacity(0.2),
                                  fontSize: 48,
                                  fontWeight: FontWeight.w300,
                                ),
                                border: InputBorder.none,
                                enabledBorder: InputBorder.none,
                                focusedBorder: InputBorder.none,
                                contentPadding: EdgeInsets.zero,
                              ),
                              onSubmitted: (_) => _nextPage(),
                            ),
                          ),
                        ],
                      ),
                      Container(
                        height: 1,
                        color: AppColors.primary.withOpacity(0.2),
                      ),
                      const SizedBox(height: 24),
                      _buildCurrencySelector(),
                      const SizedBox(height: 40),
                      _buildInsightCard(),
                    ] else ...[
                      TextField(
                        controller: controller,
                        keyboardType: inputType,
                        autofocus: true,
                        style: GoogleFonts.dmSans(
                          fontSize: 32,
                          color: AppColors.textPrimary,
                          fontWeight: FontWeight.w500,
                        ),
                        decoration: InputDecoration(
                          hintText: hint,
                          hintStyle: GoogleFonts.dmSans(
                            color: AppColors.textSecondary.withOpacity(0.3),
                            fontSize: 32,
                            fontWeight: FontWeight.w500,
                          ),
                          enabledBorder: UnderlineInputBorder(
                            borderSide: BorderSide(color: Colors.white.withOpacity(0.08), width: 1),
                          ),
                          focusedBorder: const UnderlineInputBorder(
                            borderSide: BorderSide(color: AppColors.primary, width: 2),
                          ),
                        ),
                        onSubmitted: (_) => _nextPage(),
                      ),
                    ],
                    const Spacer(),
                    const SizedBox(height: 20),
                    _buildNextButton(),
                  ],
                ),
              ),
            ),
          ),
        );
      },
    );
  }

  Widget _buildGoalScreen() {
    final goals = [
      "Save more money",
      "Control my spending",
      "Track my habits"
    ];

    return LayoutBuilder(
      builder: (context, constraints) {
        return SingleChildScrollView(
          child: ConstrainedBox(
            constraints: BoxConstraints(minHeight: constraints.maxHeight),
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 32.0, vertical: 40.0),
              child: IntrinsicHeight(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    RichText(
                      text: TextSpan(
                        children: [
                          TextSpan(
                            text: "What's your\n",
                            style: GoogleFonts.cormorantGaramond(
                              color: Colors.white,
                              fontSize: 34,
                              fontWeight: FontWeight.w300,
                              letterSpacing: -0.5,
                            ),
                          ),
                          TextSpan(
                            text: 'primary goal?',
                            style: GoogleFonts.cormorantGaramond(
                              color: AppColors.primaryLight,
                              fontSize: 34,
                              fontWeight: FontWeight.w400,
                              fontStyle: FontStyle.italic,
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 40),
                    ...goals.map((goal) => GestureDetector(
                      onTap: () {
                        setState(() => _goal = goal);
                        Future.delayed(const Duration(milliseconds: 300), _nextPage);
                      },
                      child: AnimatedContainer(
                        duration: const Duration(milliseconds: 200),
                        margin: const EdgeInsets.only(bottom: 16),
                        padding: const EdgeInsets.all(20),
                        decoration: BoxDecoration(
                          color: _goal == goal
                              ? AppColors.primary.withOpacity(0.15)
                              : Colors.white.withOpacity(0.04),
                          borderRadius: BorderRadius.circular(16),
                          border: Border.all(
                            color: _goal == goal
                                ? AppColors.primary
                                : Colors.white.withOpacity(0.06),
                          ),
                        ),
                        child: Row(
                          children: [
                            Icon(
                              _goal == goal
                                  ? Icons.radio_button_checked_rounded
                                  : Icons.radio_button_off_rounded,
                              color: _goal == goal ? AppColors.primary : AppColors.textMuted,
                              size: 20,
                            ),
                            const SizedBox(width: 16),
                            Text(
                              goal,
                              style: GoogleFonts.dmSans(
                                color: _goal == goal ? AppColors.primaryLight : AppColors.textPrimary,
                                fontWeight: _goal == goal ? FontWeight.w500 : FontWeight.w300,
                                fontSize: 15,
                              ),
                            ),
                          ],
                        ),
                      ),
                    )),
                    const Spacer(),
                    const SizedBox(height: 20),
                    _buildNextButton(enabled: _goal.isNotEmpty),
                  ],
                ),
              ),
            ),
          ),
        );
      },
    );
  }

  Widget _buildNotificationScreen() {
    return LayoutBuilder(
      builder: (context, constraints) {
        return SingleChildScrollView(
          child: ConstrainedBox(
            constraints: BoxConstraints(minHeight: constraints.maxHeight),
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 32.0, vertical: 40.0),
              child: IntrinsicHeight(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Container(
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        color: AppColors.primary.withOpacity(0.1),
                        shape: BoxShape.circle,
                      ),
                      child: const Icon(Icons.notifications_active_rounded, color: AppColors.primary, size: 40),
                    ),
                    const SizedBox(height: 32),
                    RichText(
                      text: TextSpan(
                        children: [
                          TextSpan(
                            text: 'Stay on\n',
                            style: GoogleFonts.cormorantGaramond(
                              color: Colors.white,
                              fontSize: 34,
                              fontWeight: FontWeight.w300,
                              letterSpacing: -0.5,
                            ),
                          ),
                          TextSpan(
                            text: 'top of it.',
                            style: GoogleFonts.cormorantGaramond(
                              color: AppColors.primaryLight,
                              fontSize: 34,
                              fontWeight: FontWeight.w400,
                              fontStyle: FontStyle.italic,
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 12),
                    Text(
                      "Budgetrix can remind you to log expenses after payments, helping you build a consistent habit.",
                      style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                            color: AppColors.textSecondary,
                            fontSize: 16,
                            height: 1.5,
                          ),
                    ),
                    const SizedBox(height: 50),
          GlassCard(
            padding: const EdgeInsets.all(20),
            interactive: false,
            child: Row(
              children: [
                const Icon(Icons.message_rounded, color: AppColors.textMuted),
                const SizedBox(width: 16),
                Expanded(
                  child: Text(
                    "You made a payment of ₹250. Add it to Budgetrix?",
                    style: Theme.of(context).textTheme.bodyMedium?.copyWith(fontStyle: FontStyle.italic),
                  ),
                ),
              ],
            ),
          ),
                    const Spacer(),
                    const SizedBox(height: 20),
                    _buildGradientButton(
                      label: 'ENABLE NOTIFICATIONS',
                      onPressed: _finishSetup,
                    ),
                    const SizedBox(height: 16),
                    Center(
                      child: TextButton(
                        onPressed: _finishSetup,
                        child: Text(
                          'Maybe later',
                          style: Theme.of(context).textTheme.bodyMedium?.copyWith(color: AppColors.textMuted),
                        ),
                      ),
                    ),
                    const SizedBox(height: 20),
                  ],
                ),
              ),
            ),
          ),
        );
      },
    );
  }

  Widget _buildCurrencySelector() {
    final currencies = [
      (symbol: '\u20b9', label: 'INR'),
      (symbol: '\u0024', label: 'USD'),
      (symbol: '\u20ac', label: 'EUR'),
      (symbol: '\u00a3', label: 'GBP'),
    ];
    return Row(
      children: currencies.map((c) {
        final isSelected = _selectedCurrency == c.symbol;
        return Padding(
          padding: const EdgeInsets.only(right: 8),
          child: InkWell(
            onTap: () => setState(() => _selectedCurrency = c.symbol),
            borderRadius: BorderRadius.circular(8),
            child: AnimatedContainer(
              duration: const Duration(milliseconds: 200),
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(8),
                border: Border.all(
                  color: isSelected
                      ? AppColors.primary.withOpacity(0.45)
                      : AppColors.primary.withOpacity(0.1),
                ),
                color: isSelected
                    ? AppColors.primary.withOpacity(0.12)
                    : Colors.transparent,
              ),
              child: Text(
                '${c.symbol} ${c.label}',
                style: GoogleFonts.dmSans(
                  color: isSelected ? AppColors.primaryLight : AppColors.textSecondary,
                  fontSize: 11,
                  fontWeight: isSelected ? FontWeight.w500 : FontWeight.w300,
                ),
              ),
            ),
          ),
        );
      }).toList(),
    );
  }

  Widget _buildInsightCard() {
    return Opacity(
      opacity: 0.7,
      child: GlassCard(
        padding: const EdgeInsets.all(16),
        interactive: false,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              "INSIGHT",
              style: GoogleFonts.dmSans(
                color: AppColors.textMuted,
                fontSize: 10,
                letterSpacing: 0.1,
                fontWeight: FontWeight.w400,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              "\"Knowing where you start is the first step to knowing where you can go.\"",
              style: GoogleFonts.cormorantGaramond(
                color: AppColors.textSecondary,
                fontSize: 14,
                fontStyle: FontStyle.italic,
                height: 1.4,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildNextButton({bool enabled = true}) {
    return Opacity(
      opacity: enabled ? 1.0 : 0.35,
      child: _buildGradientButton(
        label: 'CONTINUE',
        onPressed: enabled ? _nextPage : null,
      ),
    );
  }

  Widget _buildGradientButton({
    required String label,
    required VoidCallback? onPressed,
  }) {
    return Container(
      width: double.infinity,
      height: 56,
      margin: const EdgeInsets.only(bottom: 10),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [AppColors.primary, AppColors.primaryDark],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: AppColors.primary.withOpacity(0.25),
            blurRadius: 12,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: onPressed,
          borderRadius: BorderRadius.circular(16),
          child: Center(
            child: Text(
              label,
              style: GoogleFonts.dmSans(
                color: AppColors.bgGradientStart,
                fontSize: 13,
                fontWeight: FontWeight.w600,
                letterSpacing: 1.2,
              ),
            ),
          ),
        ),
      ),
    );
  }
}
