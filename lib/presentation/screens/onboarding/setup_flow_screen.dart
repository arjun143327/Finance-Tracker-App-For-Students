import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
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
  double _budget = 0;
  String _goal = '';

  final _nameController = TextEditingController();
  final _balanceController = TextEditingController();
  final _incomeController = TextEditingController();
  final _budgetController = TextEditingController();

  void _nextPage() {
    if (_currentIndex < 5) {
      // Validate inputs before moving
      if (_currentIndex == 0 && _nameController.text.trim().isEmpty) return;
      if (_currentIndex == 1 && _balanceController.text.trim().isEmpty) return;
      if (_currentIndex == 2 && _incomeController.text.trim().isEmpty) return;
      if (_currentIndex == 3 && _budgetController.text.trim().isEmpty) return;
      if (_currentIndex == 4 && _goal.isEmpty) return;

      if (_currentIndex == 0) _name = _nameController.text.trim();
      if (_currentIndex == 1) _balance = double.tryParse(_balanceController.text) ?? 0;
      if (_currentIndex == 2) _income = double.tryParse(_incomeController.text) ?? 0;
      if (_currentIndex == 3) _budget = double.tryParse(_budgetController.text) ?? 0;

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
      budget: _budget,
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
    _budgetController.dispose();
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
              title: "Current Bank Balance",
              subtitle: "Start tracking from your real financial state.",
              controller: _balanceController,
              inputType: TextInputType.number,
              hint: "₹ 0.00",
            ),
            _buildInputScreen(
              title: "Monthly Income",
              subtitle: "Your average expected income per month.",
              controller: _incomeController,
              inputType: TextInputType.number,
              hint: "₹ 0.00",
            ),
            _buildInputScreen(
              title: "Monthly Budget",
              subtitle: "How much do you plan to spend this month?",
              controller: _budgetController,
              inputType: TextInputType.number,
              hint: "₹ 0.00",
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
                    Text(
                      title,
                      style: Theme.of(context).textTheme.displayMedium?.copyWith(
                            color: Colors.white,
                            fontSize: 34,
                            fontWeight: FontWeight.w700,
                            letterSpacing: -0.5,
                          ),
                    ),
                    const SizedBox(height: 12),
                    Text(
                      subtitle,
                      style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                            color: AppColors.textSecondary,
                            fontSize: 16,
                          ),
                    ),
                    const SizedBox(height: 60),
                    TextField(
                      controller: controller,
                      keyboardType: inputType,
                      style: const TextStyle(
                        fontSize: 32,
                        color: AppColors.textPrimary,
                        fontWeight: FontWeight.w500,
                      ),
                      decoration: InputDecoration(
                        hintText: hint,
                        hintStyle: TextStyle(
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
                    Text(
                      "What's your primary goal?",
                      style: Theme.of(context).textTheme.displayMedium?.copyWith(
                            color: Colors.white,
                            fontSize: 34,
                            fontWeight: FontWeight.w700,
                            letterSpacing: -0.5,
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
                    color: _goal == goal ? AppColors.primary.withOpacity(0.2) : Colors.white.withOpacity(0.05),
                    borderRadius: BorderRadius.circular(16),
                    border: Border.all(
                      color: _goal == goal ? AppColors.primary : Colors.white.withOpacity(0.05),
                    ),
                  ),
                  child: Row(
                    children: [
                      Icon(
                        _goal == goal ? Icons.radio_button_checked_rounded : Icons.radio_button_off_rounded,
                        color: _goal == goal ? AppColors.primary : AppColors.textMuted,
                      ),
                      const SizedBox(width: 16),
                      Text(
                        goal,
                        style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                              color: _goal == goal ? AppColors.primaryLight : AppColors.textPrimary,
                              fontWeight: _goal == goal ? FontWeight.w600 : FontWeight.normal,
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
                    Text(
                      "Stay on top of it.",
                      style: Theme.of(context).textTheme.displayMedium?.copyWith(
                            color: Colors.white,
                            fontSize: 34,
                            fontWeight: FontWeight.w700,
                            letterSpacing: -0.5,
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
                    SizedBox(
                      width: double.infinity,
                      height: 56,
                      child: ElevatedButton(
                        onPressed: () {
                          // Request real permission in phase 3. For now, simulate acceptance.
                          _finishSetup();
                        },
                        style: ElevatedButton.styleFrom(
                          backgroundColor: AppColors.primary,
                          foregroundColor: AppColors.bgGradientStart,
                          elevation: 0,
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                          textStyle: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold, letterSpacing: 1.1),
                        ),
                        child: const Text('ENABLE NOTIFICATIONS'),
                      ),
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

  Widget _buildNextButton({bool enabled = true}) {
    return Container(
      width: double.infinity,
      height: 56,
      margin: const EdgeInsets.only(bottom: 10),
      child: ElevatedButton(
        onPressed: enabled ? _nextPage : null,
        style: ElevatedButton.styleFrom(
          backgroundColor: AppColors.primary,
          foregroundColor: AppColors.bgGradientStart,
          disabledBackgroundColor: AppColors.primary.withOpacity(0.15),
          disabledForegroundColor: AppColors.textPrimary.withOpacity(0.2),
          elevation: 0,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
          textStyle: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold, letterSpacing: 1.1),
        ),
        child: const Text('CONTINUE'),
      ),
    );
  }
}
