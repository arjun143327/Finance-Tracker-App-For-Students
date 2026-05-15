import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../../core/app_colors.dart';
import '../../../core/app_theme.dart';
import 'setup_flow_screen.dart';

class WelcomeScreen extends StatelessWidget {
  const WelcomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: AppTheme.backgroundGradient,
      child: Scaffold(
        backgroundColor: Colors.transparent,
        body: SafeArea(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 32.0, vertical: 40.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Spacer(flex: 2),
                Container(
                  width: 56,
                  height: 56,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: Colors.white.withOpacity(0.05),
                    border: Border.all(color: Colors.white.withOpacity(0.1)),
                  ),
                  child: const Icon(
                    Icons.menu_book_rounded,
                    color: AppColors.primary,
                    size: 24,
                  ),
                ),
                const SizedBox(height: 32),
                Text(
                  'Welcome to',
                  style: GoogleFonts.cormorantGaramond(
                        color: AppColors.primaryLight,
                        fontSize: 42,
                        height: 1.1,
                        fontWeight: FontWeight.w400,
                      ),
                ),
                ShaderMask(
                  blendMode: BlendMode.srcIn,
                  shaderCallback: (bounds) => const LinearGradient(
                    colors: [AppColors.primaryLight, AppColors.primary, AppColors.primaryDark],
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  ).createShader(bounds),
                  child: Text(
                    'Budgetrix',
                    style: GoogleFonts.cormorantGaramond(
                          fontSize: 54,
                          height: 1.1,
                          fontStyle: FontStyle.italic,
                          letterSpacing: -0.5,
                          fontWeight: FontWeight.w300,
                        ),
                  ),
                ),
                const SizedBox(height: 24),
                Text(
                  'A calmer way to understand your money. No noise, no overwhelm — just clarity.',
                  style: GoogleFonts.dmSans(
                        color: AppColors.textSecondary,
                        fontSize: 16,
                        height: 1.5,
                        fontWeight: FontWeight.w300,
                      ),
                ),
                const SizedBox(height: 32),
                Row(
                  children: [
                    _buildFeatureChip(
                      icon: '◎',
                      label: 'Track expenses\neffortlessly',
                    ),
                    const SizedBox(width: 12),
                    _buildFeatureChip(
                      icon: '◈',
                      label: 'Monthly budget\ninsights',
                    ),
                  ],
                ),
                const Spacer(flex: 3),
                SizedBox(
                  width: double.infinity,
                  height: 56,
                  child: ElevatedButton(
                    onPressed: () {
                      Navigator.of(context).push(
                        PageRouteBuilder(
                          transitionDuration: const Duration(milliseconds: 600),
                          pageBuilder: (_, animation, __) => FadeTransition(
                            opacity: animation,
                            child: const SetupFlowScreen(),
                          ),
                        ),
                      );
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppColors.primary,
                      foregroundColor: AppColors.bgGradientStart,
                      elevation: 0,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(16),
                      ),
                      textStyle: GoogleFonts.dmSans(
                        fontSize: 13,
                        fontWeight: FontWeight.w500,
                        letterSpacing: 1.2,
                      ),
                    ),
                    child: const Text('BEGIN YOUR JOURNEY'),
                  ),
                ),
                const SizedBox(height: 12),
                const Center(
                  child: Text(
                    'Private & stored only on your device',
                    style: TextStyle(
                      color: AppColors.textMuted,
                      fontSize: 12,
                      fontWeight: FontWeight.w300,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildFeatureChip({
    required String icon,
    required String label,
  }) {
    return Expanded(
      child: TweenAnimationBuilder<double>(
        tween: Tween(begin: 0.0, end: 1.0),
        duration: const Duration(milliseconds: 800),
        curve: Curves.easeOut,
        builder: (context, value, child) {
          return Opacity(
            opacity: value,
            child: Transform.translate(
              offset: Offset(0, 20 * (1 - value)),
              child: child,
            ),
          );
        },
        child: Container(
          padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 12),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: AppColors.primary.withOpacity(0.12)),
            color: AppColors.primary.withOpacity(0.05),
          ),
          child: Column(
            children: [
              Text(
                icon,
                style: const TextStyle(
                  color: AppColors.primary,
                  fontSize: 20,
                ),
              ),
              const SizedBox(height: 8),
              Text(
                label,
                textAlign: TextAlign.center,
                style: const TextStyle(
                  color: AppColors.textSecondary,
                  fontSize: 11,
                  letterSpacing: 0.04,
                  height: 1.3,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
